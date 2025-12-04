extends Button

@onready var salir_multi: Panel = $".."
@onready var panel: Panel = $"../../Panel"

func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	salir_multi.visible = false
	panel.visible = true
	
