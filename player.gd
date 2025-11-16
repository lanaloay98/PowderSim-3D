extends CharacterBody3D
@export var BedrockScene: PackedScene
@export var SandScene: PackedScene
@export var WaterScene: PackedScene
@export var WoodScene: PackedScene
@export var OilScene: PackedScene
@export var FireScene: PackedScene
@export var GlassScene: PackedScene
@export var IceScene: PackedScene
#Nodes
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var walkAudio = $runningAudio
@onready var rainAudio = $rainAudio
@onready var elementsim = $"../ElementSim"
#UI bars
@onready var walls_bar = $WallsLayer/WallsBar
@onready var powder_bar = $powderlayer/PowderContainer
@onready var liquids_bar = $LiquidsLayer/LiquidsContainer
@onready var solids_bar = $SolidsLayer/SolidsContainer
@onready var explosives_bar = $ExplosivesLayer/ExplosivesContainer
#Buttons
@onready var bedrock_button = $WallsLayer/WallsBar/Bedrock
@onready var glass_button = $WallsLayer/WallsBar/Glass
@onready var sand_button = $powderlayer/PowderContainer/SandButton
@onready var ice_button = $powderlayer/PowderContainer/IceButton
@onready var water_button = $LiquidsLayer/LiquidsContainer/WaterButton
@onready var oil_button = $LiquidsLayer/LiquidsContainer/OilButton
@onready var wood_button = $SolidsLayer/SolidsContainer/WoodButton
@onready var fire_button = $ExplosivesLayer/ExplosivesContainer/FireButton
#config
const SPEED = 5.0
const JUMP_VELOCITY = 6
const RAY_LENGTH = 50.0
const PLACE_INTERVAL = 0.2
const DELETE_INTERVAL = 0.2
# placement distance controls
const PLACE_DIST_MIN := 1.0
const PLACE_DIST_MAX := 40.0
const PLACE_DIST_STEP := 1.0
var place_distance := 5.0
#state
var is_placing = false
var is_deleting = false
var place_timer = 0.0
var delete_timer = 0.0
var line_mode:= false
var line_anchor: Vector3i = Vector3i.ZERO
var last_line_end: Vector3i = Vector3i(999999, 999999, 999999)

enum BlockType { BEDROCK, WATER, SAND, WOOD, OIL, FIRE, GLASS, ICE}
var current_block : BlockType = BlockType.BEDROCK
var Rotate = false
var ghost_voxel: MeshInstance3D
var ghost_materials := {}

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("rotate"):
		Rotate = true
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			place_distance = clamp(place_distance - PLACE_DIST_STEP, PLACE_DIST_MIN, PLACE_DIST_MAX)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			place_distance = clamp(place_distance + PLACE_DIST_STEP, PLACE_DIST_MIN, PLACE_DIST_MAX)
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_placing = event.pressed
			if is_placing:
				if Input.is_key_pressed(KEY_SHIFT):
					var result = get_ray_hit()
					if result:
						line_mode = true
						line_anchor = _grid_from_hit(result)
						last_line_end = Vector3i(999999, 999999, 999999)
				else:
					line_mode = false
			else:
				line_mode = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_deleting = event.pressed
	elif event.is_action_pressed("esc"):
		Rotate = false
	if event.is_action_released("ui_shift"):
		line_mode = false
	if Rotate and event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * 0.01)
		camera.rotate_x(-event.relative.y * 0.01)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(90))

func _ready():
	walls_bar.visible = false
	powder_bar.visible = false
	liquids_bar.visible = false
	solids_bar.visible = false
	explosives_bar.visible = false
	_create_ghost_voxel()
	_update_ghost_material()

var button_map = {
	BlockType.BEDROCK: bedrock_button,
	BlockType.GLASS: glass_button,
	BlockType.SAND: sand_button,
	BlockType.WATER: water_button,
	BlockType.WOOD: wood_button,
	BlockType.OIL: oil_button,
	BlockType.FIRE: fire_button,
	BlockType.ICE: ice_button
}

func _create_ghost_voxel() -> void:
	ghost_voxel = MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE
	ghost_voxel.mesh = cube
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.8, 0.8, 0.8, 0.3)
	mat.flags_unshaded = true
	mat.flags_transparent = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.disable_receive_shadows = true
	ghost_voxel.material_override = mat
	ghost_voxel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ghost_voxel)
	ghost_voxel.visible = false

func get_place_target() -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos).normalized()
	var to = from + dir * RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var hit := space_state.intersect_ray(query)
	if hit and hit.has("position") and hit.has("normal"):
		var hit_dist = from.distance_to(hit.position)
		if hit_dist <= place_distance:
			var pos = (hit.position - hit.normal * 0.5).snapped(Vector3.ONE)
			return {"position": pos, "normal": hit.normal}
	var free_pos = (from + dir * place_distance).snapped(Vector3.ONE)
	return {"position": free_pos, "normal": Vector3.UP}

func _physics_process(delta: float) -> void:
	if is_placing:
		place_timer -= delta
		if place_timer <= 0.0:
			place_element()
			place_timer = PLACE_INTERVAL
	else:
		place_timer = 0.0
	if is_deleting:
		delete_timer -= delta
		if delete_timer <= 0.0:
			delete_block_under_mouse()
			delete_timer = DELETE_INTERVAL
	else:
		delete_timer = 0.0
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	var is_moving = direction.length() > 0.1 and is_on_floor()
	if is_moving and not walkAudio.playing:
		walkAudio.play()
	elif not is_moving and walkAudio.playing:
		walkAudio.stop()
	if is_placing and current_block == BlockType.WATER:
		if not rainAudio.playing:
			rainAudio.play()
	else:
		if rainAudio.playing:
			rainAudio.stop()
	_update_ghost_preview()

func _update_ghost_preview() -> void:
	var result := get_place_target()
	if result and result.has("position") and result.has("normal"):
		var grid_pos: Vector3i = _grid_from_hit(result)
		ghost_voxel.global_transform.origin = Vector3(grid_pos)
		ghost_voxel.visible = true
	else:
		ghost_voxel.visible = false

func _material_for_block(bt: BlockType) -> StandardMaterial3D:
	if ghost_materials.has(bt):
		return ghost_materials[bt]
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_unshaded = true
	mat.flags_transparent = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.disable_receive_shadows = true
	match bt:
		BlockType.BEDROCK: mat.albedo_color = Color(0.6, 0.6, 0.6, 0.35)
		BlockType.SAND:    mat.albedo_color = Color(0.95, 0.85, 0.55, 0.35)
		BlockType.WATER:   mat.albedo_color = Color(0.25, 0.55, 1.0, 0.30)
		BlockType.WOOD:    mat.albedo_color = Color(0.55, 0.35, 0.2, 0.35)
		BlockType.OIL:     mat.albedo_color = Color(0.15, 0.15, 0.15, 0.35)
		BlockType.FIRE:    mat.albedo_color = Color(1.0, 0.3, 0.0, 0.30)
		BlockType.GLASS:   mat.albedo_color = Color(0.85, 0.95, 1.0, 0.20)
		BlockType.ICE:     mat.albedo_color = Color(0.7, 0.9, 1.0, 0.28)
		_:
			mat.albedo_color = Color(0.8, 0.8, 0.8, 0.3)
	ghost_materials[bt] = mat
	return mat

func _update_ghost_material() -> void:
	if ghost_voxel:
		ghost_voxel.material_override = _material_for_block(current_block)

func place_element():
	var result = get_place_target()
	if not result or not result.has("position"):
		return

	if line_mode and Input.is_key_pressed(KEY_SHIFT):
		var end_pos_i: Vector3i = _grid_from_hit(result)
		var axis: int = _dominant_axis(line_anchor, end_pos_i)
		var constrained_end: Vector3i = end_pos_i
		match axis:
			0:
				constrained_end.y = line_anchor.y
				constrained_end.z = line_anchor.z
			1:
				constrained_end.x = line_anchor.x
				constrained_end.z = line_anchor.z
			2:
				constrained_end.x = line_anchor.x
				constrained_end.y = line_anchor.y
		if constrained_end != last_line_end:
			last_line_end = constrained_end
			var pts: Array[Vector3i] = _line_points_on_grid(line_anchor, constrained_end)
			for p in pts:
				_place_current_block_at(p)
	else:
		var p: Vector3i = _grid_from_hit(result)
		_place_current_block_at(p)

func _place_current_block_at(pos_i: Vector3i) -> void:
	var pos: Vector3 = Vector3(pos_i)
	match current_block:
		BlockType.BEDROCK: elementsim.add_voxel_at(pos, "bedrock", elementsim.BedrockScene)
		BlockType.SAND:    elementsim.add_voxel_at(pos, "sand",    elementsim.SandScene)
		BlockType.WATER:   elementsim.add_voxel_at(pos, "water",   elementsim.WaterScene)
		BlockType.WOOD:    elementsim.add_voxel_at(pos, "wood",    elementsim.WoodScene)
		BlockType.OIL:     elementsim.add_voxel_at(pos, "oil",     elementsim.OilScene)
		BlockType.FIRE:    elementsim.add_voxel_at(pos, "fire",    elementsim.FireScene)
		BlockType.GLASS:   elementsim.add_voxel_at(pos, "glass",   elementsim.GlassScene)
		BlockType.ICE:     elementsim.add_voxel_at(pos, "ice",     elementsim.IceScene)

func get_ray_hit():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	return space_state.intersect_ray(query)

func delete_block_under_mouse():
	var result = get_ray_hit()
	if result:
		var target = result.collider
		while target and not (target.is_in_group("deletable") or target.has_meta("grid_pos")) and target.get_parent():
			target = target.get_parent()
		if target and target.is_in_group("deletable"):
			if target.has_meta("grid_pos"):
				var grid_pos = target.get_meta("grid_pos")
				elementsim.remove_voxel(grid_pos)
			target.queue_free()

#UI button callbacks: set block + collapse bars
func _on_bedrock_button_pressed() -> void:
	current_block = BlockType.BEDROCK
	_update_ghost_material()
	_hide_all_bars()

func _on_sand_button_pressed() -> void:
	current_block = BlockType.SAND
	_update_ghost_material()
	_hide_all_bars()

func _on_water_button_pressed() -> void:
	current_block = BlockType.WATER
	_update_ghost_material()
	_hide_all_bars()

func _on_wood_button_pressed() -> void:
	current_block = BlockType.WOOD
	_update_ghost_material()
	_hide_all_bars()

func _on_oil_button_pressed() -> void:
	current_block = BlockType.OIL
	_update_ghost_material()
	_hide_all_bars()

func _on_fire_button_pressed() -> void:
	current_block = BlockType.FIRE
	_update_ghost_material()
	_hide_all_bars()

func _on_glass_pressed() -> void:
	current_block = BlockType.GLASS
	_update_ghost_material()
	_hide_all_bars()

func _on_ice_button_pressed() -> void:
	current_block = BlockType.ICE
	_update_ghost_material()
	_hide_all_bars()

#UI toggles
func _on_powder_toggle_pressed() -> void:
	powder_bar.visible = !powder_bar.visible

func _on_liquids_toggle_pressed() -> void:
	liquids_bar.visible = !liquids_bar.visible

func _on_walls_toggle_element_bar_pressed() -> void:
	walls_bar.visible = !walls_bar.visible

func _on_solids_pressed() -> void:
	solids_bar.visible = !solids_bar.visible

func _on_explosives_toggle_pressed() -> void:
	explosives_bar.visible = !explosives_bar.visible

func _hide_all_bars() -> void:
	walls_bar.visible = false
	powder_bar.visible = false
	liquids_bar.visible = false
	solids_bar.visible = false
	explosives_bar.visible = false

#Grid helpers
func _grid_from_hit(result: Dictionary) -> Vector3i:
	var place_pos: Vector3 = (result.position + result.normal * 0.5).snapped(Vector3.ONE)
	if place_pos.y == 0.0:
		place_pos.y = 1.0
	return Vector3i(int(place_pos.x), int(place_pos.y), int(place_pos.z))

func _dominant_axis(a: Vector3i, b: Vector3i) -> int:
	var d: Vector3i = b - a
	var ax: int = abs(d.x)
	var ay: int = abs(d.y)
	var az: int = abs(d.z)
	if ax >= ay and ax >= az:
		return 0
	elif ay >= ax and ay >= az:
		return 1
	return 2

func _line_points_on_grid(a: Vector3i, b: Vector3i) -> Array[Vector3i]:
	var axis := _dominant_axis(a, b)
	var pts: Array[Vector3i] = []
	match axis:
		0:
			var step := 1 if b.x >= a.x else -1
			for x in range(a.x, b.x + step, step):
				pts.append(Vector3i(x, a.y, a.z))
		1:
			var step := 1 if b.y >= a.y else -1
			for y in range(a.y, b.y + step, step):
				pts.append(Vector3i(a.x, y, a.z))
		2:
			var step := 1 if b.z >= a.z else -1
			for z in range(a.z, b.z + step, step):
				pts.append(Vector3i(a.x, a.y, z))
	return pts
