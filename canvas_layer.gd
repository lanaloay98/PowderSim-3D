extends CanvasLayer
@onready var element_bar = $ElementBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_ToggleElementBar_pressed():
	element_bar.visible = !element_bar.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
