extends MeshInstance3D

@export var grid_pos: Vector3i

func _ready() -> void:
	add_to_group("deletable")

func _process(delta: float) -> void:
	pass
