extends Button

func _ready():
	pressed.connect(_on_boton_reinicio_pressed)
	
func _on_boton_reinicio_pressed():
	get_tree().reload_current_scene()
