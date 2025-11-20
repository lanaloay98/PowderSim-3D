extends RigidBody3D

var last_grid_pos: Vector3i
var world_ref: Node
func _physics_process(_delta):
	if world_ref == null:
		return
	var current_grid_pos = world_ref.world_to_grid(global_transform.origin)
	if current_grid_pos != last_grid_pos:
		# Remove old entry
		world_ref.physical_wood.erase(last_grid_pos)
		world_ref.filled_cells.erase(last_grid_pos)
		# Add new entry
		world_ref.physical_wood[current_grid_pos] = self
		world_ref.filled_cells[current_grid_pos] = "wood"
		last_grid_pos = current_grid_pos
