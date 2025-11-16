extends MeshInstance3D

@export var grid_pos: Vector3i

func _ready() -> void:
	add_to_group("deletable")
	add_to_group("flammable")
	set_meta("burn_value", 1.5)

func _process(delta: float) -> void:
	pass
