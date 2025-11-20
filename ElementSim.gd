extends Node3D
@export var BedrockScene: PackedScene
@export var SandScene: PackedScene
@export var WaterScene: PackedScene
@export var WoodScene: PackedScene
@export var OilScene: PackedScene
@export var FireScene: PackedScene
@export var GlassScene: PackedScene
@export var IceScene: PackedScene
@export var SteamScene: PackedScene
@onready var temp_canvas := CanvasLayer.new()
@onready var temp_label  := Label.new()
@onready var bedrockAudio = $bedrockAudio
@onready var glassAudio = $glassAudio
@onready var fireAudio = $fireAudio
@onready var steamAudio = $steamAudio
@onready var fluidAudio = $fluidAudio
@onready var woodAudio = $woodAudio
@onready var sandAudio = $sandAudio
@onready var iceAudio = $iceAudio
const GRID_X = 50
const GRID_Y = 50
const GRID_Z = 50
const TEMP_AIR := 27.0
const TEMP_WATER := 27.0
const TEMP_SAND := 27.0
const TEMP_GLASS := 27.0
const TEMP_OIL := 27.0
const TEMP_ICE := 0.0
const TEMP_FIRE := 600.0
const FIRE_LIFETIME := 5.0
const STEAM_LIFETIME := 2.0
const WATER_COOLDOWN := 1
const OIL_COOLDOWN := 1.5
const FIRE_COOLDOWN := 0.5
const SAND_MELT := 400.0
const ICE_MELT := 40.0
const AMBIENT_TEMP := 27.0
const COOLING_RATE := 50.0
const FREEZE_THRESHOLD := 5.0

var filled_cells = {}
var voxel_nodes = {}
var active_voxels = {}
var voxel_cooldowns = {}
var fire_lifetimes = {}
var physical_wood = {}
var ice_melt_progress = {}
var ice_freeze_cooldowns = {}
var voxel_temperature = {}

func is_in_bounds(pos: Vector3i) -> bool:
	return pos.x >= 0 and pos.x < GRID_X and pos.y >= 0 and pos.y < GRID_Y and pos.z >= 0 and pos.z < GRID_Z

func _ready():
	for x in range(GRID_X):
		for z in range(GRID_Z):
			var ground_pos = Vector3i(x, 0, z)
			filled_cells[ground_pos] = "ground"
	add_child(temp_canvas)
	temp_label.text = "Temprature: --"
	temp_label.position = Vector2(30, 0)
	temp_label.add_theme_color_override("font_color", Color.BLACK)
	temp_canvas.add_child(temp_label)

func world_to_grid(world_pos: Vector3) -> Vector3i:
	var snapped_vec = world_pos.snapped(Vector3.ONE)
	return Vector3i(snapped_vec.x, snapped_vec.y, snapped_vec.z)

func add_voxel_at(world_pos: Vector3, type: String, scene: PackedScene):
	var grid_pos: Vector3i = world_to_grid(world_pos)
	if not is_in_bounds(grid_pos) or filled_cells.has(grid_pos):
		return
	if filled_cells.get(grid_pos) == "ground":
		return
	if type == "bedrock":
		bedrockAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
	elif type == "glass":
		glassAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
	elif type == "sand":
		sandAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
	elif type == "fire":
		if not fireAudio.playing:
			fireAudio.play()
		fire_lifetimes[grid_pos] = FIRE_LIFETIME
		voxel_temperature[grid_pos] = TEMP_FIRE
	elif type == "water":
		fluidAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
	elif type == "ice":
		iceAudio.play()
		voxel_temperature[grid_pos] = TEMP_ICE
	elif type == "oil":
		fluidAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
	elif type == "wood":
		woodAudio.play()
		voxel_temperature[grid_pos] = AMBIENT_TEMP
		spawn_physical_wood(world_pos)
		return
	var voxel = scene.instantiate()	
	voxel.set_meta("grid_pos", grid_pos)
	voxel.position = Vector3(grid_pos.x, grid_pos.y, grid_pos.z)
	add_child(voxel)
	voxel_nodes[grid_pos] = voxel
	filled_cells[grid_pos] = type
	if type in ["water", "sand", "oil", "fire", "ice"]:
		active_voxels[grid_pos] = true
	voxel_nodes[grid_pos] = voxel
	filled_cells[grid_pos] = type
	activate_neighbors6(grid_pos)

func move_voxel(from: Vector3i, to: Vector3i):
	if not is_in_bounds(to):
		return
	if not voxel_nodes.has(from):
		return
	var voxel = voxel_nodes[from]
	if not is_instance_valid(voxel):
		voxel_nodes.erase(from)
		filled_cells.erase(from)
		active_voxels.erase(from)
		voxel_cooldowns.erase(from)
		return
	var temp = voxel_temperature.get(from, 27)
	voxel_temperature.erase(from)
	voxel_temperature[to] = temp
	voxel_cooldowns.erase(to)
	var moved_type = filled_cells[from]
	filled_cells.erase(from)
	filled_cells[to] = moved_type
	voxel_nodes[to] = voxel
	voxel_nodes.erase(from)	
	active_voxels[to] = true
	active_voxels.erase(from)
	voxel_cooldowns.erase(from)
	voxel.position = Vector3(to.x, to.y, to.z)
	voxel.set_meta("grid_pos", to)
	notify_above(from)
	voxel.grid_pos = to
	voxel.position = Vector3(to.x, to.y, to.z)
	voxel.set_meta("grid_pos", to)
	notify_above(from)
	activate_neighbors6(to)
	activate_neighbors6(from)

func _process(_delta):
	var next_active = {}
	for pos in active_voxels.keys():
		var moved = false
		if not filled_cells.has(pos):
			continue
		var element = filled_cells[pos]
		match element:
			"sand":
				var below = pos + Vector3i(0, -1, 0)
				if is_in_bounds(below):
					if not filled_cells.has(below):
						move_voxel(pos, below)
						next_active[below] = true
						moved = true
					elif filled_cells.get(below) == "water":
						swap_voxels(pos, below)
						next_active[below] = true
						moved = true
				var diagonals = [
					Vector3i(-1, -1, 0), Vector3i(1, -1, 0),
					Vector3i(0, -1, -1), Vector3i(0, -1, 1)
				]
				diagonals.shuffle()
				for dir in diagonals:
					var target = pos + dir
					if is_in_bounds(target) and not filled_cells.has(target):
						move_voxel(pos, target)
						next_active[target] = true
						moved = true; 
						break
				var sides = [
					Vector3i(-1, 0, 0), Vector3i(1, 0, 0),
					Vector3i(0, 0, -1), Vector3i(0, 0, 1)
				]
				sides.shuffle()
				for dir in sides:
					var side = pos + dir
					var below_side = side + Vector3i(0, -1, 0)
					if is_in_bounds(side) and not filled_cells.has(side) and not filled_cells.has(below_side):
						move_voxel(pos, side)
						next_active[side] = true
						continue
				next_active[pos] = true
			"water":
				if voxel_temperature.get(pos, 20.0) >= 100.0:
					convert_voxel_type(pos, "steam", SteamScene)
					next_active[pos] = true
					continue
				spawn_liquids(pos, _delta, next_active, WATER_COOLDOWN)
			"steam":
				fire_lifetimes[pos] -= _delta
				if fire_lifetimes[pos] <= 0.0:
					remove_voxel(pos)
					fire_lifetimes.erase(pos)
				else:
					next_active[pos] = true
			"oil":
				spawn_liquids(pos, _delta, next_active, OIL_COOLDOWN)
			"fire":
				spawn_fire(pos, _delta, next_active)
			"ice":
				var fell := apply_gravity_solid(pos, next_active)
				if not fell:
					process_ice(pos, _delta, next_active)
	active_voxels = next_active
	update_fire_audio()
	update_steam_audio()
	update_temperature(_delta)
	update_hover_temperature_label()

func update_fire_audio():
	var any_fire := false
	for k in filled_cells.keys():
		if filled_cells[k] == "fire":
			any_fire = true
			break
	if any_fire:
		if not fireAudio.playing:
			fireAudio.play()
	else:
		if fireAudio.playing:
			fireAudio.stop()

func update_steam_audio():
	var any_steam := false
	for k in filled_cells.keys():
		if filled_cells[k] == "steam":
			any_steam = true
			break
	if any_steam:
		if not steamAudio.playing:
			steamAudio.play()
	else:
		if steamAudio.playing:
			steamAudio.stop()

func remove_voxel(pos: Vector3i):
	var current = pos
	fire_lifetimes.erase(pos)
	ice_melt_progress.erase(pos)
	ice_freeze_cooldowns.erase(pos)
	while true:
		voxel_cooldowns.erase(current)
		active_voxels.erase(current)
		if filled_cells.has(current):
			var material = filled_cells[current]
			filled_cells.erase(current)
		else:
			print("Nothing in filled_cells at", current)
		if voxel_nodes.has(current):
			var voxel = voxel_nodes[current]
			voxel_nodes.erase(current)
			if is_instance_valid(voxel):
				voxel.queue_free()
		notify_above(current)
		if active_voxels.has(current):
			active_voxels.erase(current)
		var above = current + Vector3i(0, 1, 0)
		if filled_cells.has(above) or voxel_nodes.has(above):
			if filled_cells.get(above, "") in ["sand", "water"]:
				active_voxels[above] = true
			current = above
		else:
			break
	update_fire_audio()

func remove_physical_wood(pos: Vector3i):
	fire_lifetimes.erase(pos)
	if physical_wood.has(pos):
		var wood = physical_wood[pos]
		if is_instance_valid(wood):
			wood.queue_free()
		physical_wood.erase(pos)
		filled_cells.erase(pos)
		update_fire_audio()

func swap_voxels(pos_a: Vector3i, pos_b: Vector3i):
	if not filled_cells.has(pos_a) or not filled_cells.has(pos_b):
		return
	var tA = voxel_temperature[pos_a]
	var tB = voxel_temperature[pos_b]
	voxel_temperature[pos_a] = tB
	voxel_temperature[pos_b] = tA

	var type_a = filled_cells[pos_a]
	var type_b = filled_cells[pos_b]
	filled_cells[pos_a] = type_b
	filled_cells[pos_b] = type_a
	if voxel_nodes.has(pos_a) and voxel_nodes.has(pos_b):
		var voxel_a = voxel_nodes[pos_a]
		var voxel_b = voxel_nodes[pos_b]
		voxel_a.position = Vector3(pos_b.x, pos_b.y, pos_b.z)
		voxel_b.position = Vector3(pos_a.x, pos_a.y, pos_a.z)
		voxel_a.set_meta("grid_pos", pos_b)
		voxel_b.set_meta("grid_pos", pos_a)
		voxel_nodes[pos_a] = voxel_b
		voxel_nodes[pos_b] = voxel_a
	elif voxel_nodes.has(pos_a):
		var voxel_a = voxel_nodes[pos_a]
		voxel_a.position = Vector3(pos_b.x, pos_b.y, pos_b.z)
		voxel_a.set_meta("grid_pos", pos_b)
		voxel_nodes.erase(pos_a)
		voxel_nodes[pos_b] = voxel_a
	elif voxel_nodes.has(pos_b):
		var voxel_b = voxel_nodes[pos_b]
		voxel_b.position = Vector3(pos_a.x, pos_a.y, pos_a.z)
		voxel_b.set_meta("grid_pos", pos_a)
		voxel_nodes.erase(pos_b)
		voxel_nodes[pos_a] = voxel_b
	active_voxels[pos_a] = true
	active_voxels[pos_b] = true
	voxel_cooldowns.erase(pos_a)
	voxel_cooldowns.erase(pos_b)
	activate_neighbors6(pos_a)
	activate_neighbors6(pos_b)

func notify_above(pos: Vector3i):
	var above = pos + Vector3i(0, 1, 0)
	if filled_cells.has(above) and filled_cells[above] in ["sand", "water"]:
		active_voxels[above] = true

func spawn_physical_wood(world_pos: Vector3):
	if WoodScene:
		var wood = WoodScene.instantiate()
		var grid_pos = world_to_grid(world_pos)
		wood.global_transform.origin = Vector3(grid_pos.x, grid_pos.y, grid_pos.z)
		add_child(wood)
		wood.add_to_group("flammable")
		wood.rotation.y = randf() * TAU
		wood.add_to_group("deletable")
		if wood.has_method("set"):
			wood.world_ref = self
			wood.last_grid_pos = grid_pos
		physical_wood[grid_pos] = wood
		filled_cells[grid_pos] = "wood"

func spawn_liquids(pos: Vector3i, _delta: float, next_active: Dictionary, cooldown_time: float):
	var moved = false
	var from_type = filled_cells.get(pos, "")
	var cooldown = voxel_cooldowns.get(pos, 0.0)
	if cooldown > 0.0:
		voxel_cooldowns[pos] = cooldown - 5 * _delta
		next_active[pos] = true
		return
	voxel_cooldowns[pos] = cooldown_time
	# Try move down
	var below = pos + Vector3i(0, -1, 0)
	if is_in_bounds(below):
		var below_type = filled_cells.get(below, "")
		if not filled_cells.has(below):
			move_voxel(pos, below)
			next_active[below] = true
			return
		elif from_type == "water" and below_type == "oil":
			swap_voxels(pos, below)
			next_active[below] = true
			next_active[pos] = true
			return
	# Try move sideways
	var dirs = [
		Vector3i(-1, 0, 0), Vector3i(1, 0, 0),
		Vector3i(0, 0, -1), Vector3i(0, 0, 1)
	]
	dirs.shuffle()
	for dir in dirs:
		var neighbor = pos + dir
		if is_in_bounds(neighbor) and not filled_cells.has(neighbor):
			move_voxel(pos, neighbor)
			next_active[neighbor] = true
			voxel_cooldowns[neighbor] = cooldown_time
			return
	next_active[pos] = true

func spawn_fire(pos: Vector3i, _delta: float, next_active: Dictionary):
	var cooldown = voxel_cooldowns.get(pos, 0.0)
	if cooldown > 0.0:
		voxel_cooldowns[pos] = cooldown - _delta
		next_active[pos] = true
		return
	var below = pos + Vector3i(0, -1, 0)
	if filled_cells.get(below, "") == "wood":
		convert_voxel_type(below, "fire", FireScene)
		fire_lifetimes[pos] += 2.0
		next_active[below] = true
	elif filled_cells.get(below, "") == "oil":
		convert_voxel_type(below, "fire", FireScene)
		fire_lifetimes[pos] += 1.5
		next_active[below] = true
	elif filled_cells.get(below, "") == "sand":
		voxel_temperature[below] += 50.0 * _delta
		if voxel_temperature[below] >= SAND_MELT:
			convert_voxel_type(below, "glass", GlassScene)
			next_active[below] = true
	elif filled_cells.get(below, "") == "ice":
		convert_voxel_type(below, "water", WaterScene)
		next_active[below] = true
	for n in neighbors6(pos):
		if voxel_temperature.has(n):
			voxel_temperature[n] += TEMP_FIRE * _delta
	voxel_cooldowns[pos] = FIRE_COOLDOWN
	for neighbor in neighbors26(pos):
		if filled_cells.get(neighbor, "") == "water":
			convert_voxel_type(neighbor, "steam", SteamScene)
			remove_voxel(pos)
			fire_lifetimes.erase(pos)
			return
		if filled_cells.get(neighbor, "") == "oil":
			convert_voxel_type(neighbor, "fire", FireScene)
			fire_lifetimes[pos] = fire_lifetimes.get(pos, FIRE_LIFETIME) + 1.5
			next_active[neighbor] = true
			continue
		if filled_cells.get(neighbor, "") == "sand":
			voxel_temperature[neighbor] = voxel_temperature.get(neighbor, 27.0) + 50.0 * _delta
			if voxel_temperature[neighbor] >= SAND_MELT:
				convert_voxel_type(neighbor, "glass", GlassScene)
				next_active[neighbor] = true
				continue
			next_active[neighbor] = true
			continue
		if filled_cells.get(neighbor, "") == "wood":
			convert_voxel_type(neighbor, "fire", FireScene)
			fire_lifetimes[pos] = fire_lifetimes.get(pos, FIRE_LIFETIME) + 2.0
			next_active[neighbor] = true
			continue
		if physical_wood.has(neighbor):
			var wood = physical_wood[neighbor]
			if is_instance_valid(wood) and wood.is_in_group("flammable"):
				remove_physical_wood(neighbor)
				convert_voxel_type(neighbor, "fire", FireScene)
				fire_lifetimes[pos] = fire_lifetimes.get(pos, FIRE_LIFETIME) + 8.0
				next_active[neighbor] = true
				continue
		if voxel_nodes.has(neighbor):
			var v = voxel_nodes[neighbor]
			if is_instance_valid(v) and v.is_in_group("flammable"):
				remove_voxel(neighbor)
				convert_voxel_type(neighbor, "fire", FireScene)
				fire_lifetimes[pos] = fire_lifetimes.get(pos, FIRE_LIFETIME) + 2.0
				next_active[neighbor] = true
				continue
	fire_lifetimes[pos] = fire_lifetimes.get(pos, FIRE_LIFETIME) - 20 * _delta
	if fire_lifetimes[pos] <= 0.0:
		remove_voxel(pos)
		fire_lifetimes.erase(pos)
		return
	next_active[pos] = true

func neighbors6(pos: Vector3i) -> Array:
	return [
		pos + Vector3i( 1, 0, 0), pos + Vector3i(-1, 0, 0),
		pos + Vector3i( 0, 1, 0), pos + Vector3i( 0,-1, 0),
		pos + Vector3i( 0, 0, 1), pos + Vector3i( 0, 0,-1),
	]

func convert_voxel_type(pos: Vector3i, new_type: String, new_scene: PackedScene):
	if not is_in_bounds(pos):
		return
	if voxel_nodes.has(pos):
		var old = voxel_nodes[pos]
		if is_instance_valid(old):
			old.queue_free()
		voxel_nodes.erase(pos)
	var voxel = new_scene.instantiate()
	voxel.set_meta("grid_pos", pos)
	voxel.position = Vector3(pos.x, pos.y, pos.z)
	add_child(voxel)
	voxel_nodes[pos] = voxel
	filled_cells[pos] = new_type
	var old_temp = voxel_temperature.get(pos, TEMP_AIR)
	match new_type:
		"fire":
			voxel_temperature[pos] = TEMP_FIRE
		"ice":
			voxel_temperature[pos] = TEMP_ICE
		"water":
			voxel_temperature[pos] = old_temp
		"sand":
			voxel_temperature[pos] = max(old_temp, TEMP_SAND)
		"glass":
			voxel_temperature[pos] = old_temp
		_:
			voxel_temperature[pos] = old_temp
	active_voxels[pos] = true
	voxel_cooldowns.erase(pos)
	activate_neighbors6(pos)
	if new_type == "fire":
		fire_lifetimes[pos] = FIRE_LIFETIME
		update_fire_audio()
	if new_type == "steam":
		fire_lifetimes[pos] = STEAM_LIFETIME
	if new_type == "glass":
		glassAudio.play()
	if new_type == "water":
		fluidAudio.play()
	if new_type == "ice":
		iceAudio.play()

func process_ice(pos: Vector3i, _delta: float, next_active: Dictionary):
	if not voxel_temperature.has(pos):
		return
	var t = voxel_temperature[pos]
	for n in neighbors6(pos):
		if filled_cells.get(n, "") == "water":
			voxel_temperature[n] = lerp(voxel_temperature.get(n, AMBIENT_TEMP), 0.0, 0.6)
			if voxel_temperature[n] <= FREEZE_THRESHOLD:
				convert_voxel_type(n, "ice", IceScene)
				next_active[n] = true
	next_active[pos] = true

func activate_neighbors6(pos: Vector3i):
	for n in neighbors6(pos):
		if filled_cells.has(n):
			if filled_cells[n] in ["ice", "water", "fire", "oil", "sand"]:
				active_voxels[n] = true

func neighbors26(pos: Vector3i) -> Array:
	var result: Array = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				if x == 0 and y == 0 and z == 0:
					continue
				result.append(pos + Vector3i(x, y, z))
	return result

func local_temperature(center: Vector3i) -> float:
	var total := 0.0
	var count := 0	
	for n in neighbors6(center):
		if voxel_temperature.has(n):
			total += voxel_temperature[n]
			count += 1
	if count == 0:
		return 0.0
	return total / count

func apply_gravity_solid(pos: Vector3i, next_active: Dictionary) -> bool:
	if not filled_cells.has(pos):
		return false
	var below := pos + Vector3i(0, -1, 0)
	if is_in_bounds(below) and not filled_cells.has(below):
		move_voxel(pos, below)
		next_active[below] = true
		return true
	return false

func update_temperature(delta):
	var to_cool = []
	for pos in filled_cells.keys():
		if filled_cells[pos] == "ice":
			to_cool.append(pos)
	for pos in to_cool:
		for n in neighbors6(pos):
			if voxel_temperature.has(n):
				voxel_temperature[n] = lerp(voxel_temperature[n], 0.0, 0.35)
	var heat_changes = {}
	var to_evaporate = []
	var to_glass = []
	var to_freeze = []
	var to_melt = []
	for pos in voxel_temperature.keys():
		var t = voxel_temperature[pos]
		var neighbors = neighbors6(pos)
		for n in neighbors:
			if voxel_temperature.has(n):
				var t2 = voxel_temperature[n]
				var diff = (t2 - t) * 0.1
				heat_changes[pos] = heat_changes.get(pos, 0.0) + diff
	for pos in heat_changes.keys():
		voxel_temperature[pos] += heat_changes[pos]
	for pos in voxel_temperature.keys():
		var temp = voxel_temperature[pos]		
		if temp > AMBIENT_TEMP:
			voxel_temperature[pos] = max(AMBIENT_TEMP, temp - COOLING_RATE * delta)
		elif temp < AMBIENT_TEMP:
			voxel_temperature[pos] = min(AMBIENT_TEMP, temp + COOLING_RATE * delta)
	for pos in voxel_temperature.keys():
		if not filled_cells.has(pos):
			continue
		var t = voxel_temperature.get(pos, AMBIENT_TEMP)
		var type = filled_cells.get(pos, "")
		if type == "water" and t >= 100.0:
			to_evaporate.append(pos)
			continue
		if type == "water" and t <= FREEZE_THRESHOLD:
			to_freeze.append(pos)
			continue
		if type == "ice":
			if not ice_melt_progress.has(pos):
				ice_melt_progress[pos] = 0.0
			if t > 0.0:
				ice_melt_progress[pos] += delta * (t / 30.0)
			else:
				ice_melt_progress[pos] = max(0.0, ice_melt_progress[pos] - delta)
			if ice_melt_progress[pos] >= 1.0:
				to_melt.append(pos)
		if type == "sand" and t >= SAND_MELT:
			to_glass.append(pos)
			continue
	for pos in to_evaporate:
			convert_voxel_type(pos, "steam", SteamScene)
			voxel_temperature[pos] = 120.0
	for pos in to_glass:
		convert_voxel_type(pos, "glass", GlassScene)
		voxel_temperature[pos] = voxel_temperature.get(pos, SAND_MELT)
	for pos in to_freeze:
		convert_voxel_type(pos, "ice", IceScene)
		voxel_temperature[pos] = min(voxel_temperature.get(pos, 0.0), 0.0)
	for pos in to_melt:
		convert_voxel_type(pos, "water", WaterScene)
		voxel_temperature[pos] = max(voxel_temperature.get(pos, 10.0), 10.0)

func activate_after_conversion(pos: Vector3i):
	active_voxels[pos] = true
	activate_neighbors6(pos)

func update_hover_temperature_label():
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_from  := cam.project_ray_origin(mouse_pos)
	var ray_dir   := cam.project_ray_normal(mouse_pos)
	var ray_to    := ray_from + ray_dir * 1000.0
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var hit := space.intersect_ray(query)
	if hit.size() > 0:
		var hit_pos : Vector3 = hit.position
		var cell : Vector3i = world_to_grid(hit_pos)
		var t := local_temperature(cell)
		temp_label.text = "temprature: %.1f°C" % t
