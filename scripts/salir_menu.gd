extends Button

func _ready() -> void:
	pressed.connect(_on_salir_menu_pressed)

func _on_salir_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
