extends PanelContainer
@onready var elements_container = $ElementsContainer

func _ready():
	elements_container.visible = false

func _on_ToggleButton_pressed():
	elements_container.visible = !elements_container.visible
