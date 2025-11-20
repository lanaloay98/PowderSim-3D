extends CanvasLayer
@onready var element_bar = $ElementBar

func _ready() -> void:
	pass 
	
func _on_ToggleElementBar_pressed():
	element_bar.visible = !element_bar.visible

func _process(delta: float) -> void:
	pass
