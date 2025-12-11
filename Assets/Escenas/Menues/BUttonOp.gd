extends Button

@onready var button_2: Button = $"."

func _ready():

	button_2.pressed.connect(Callable(self, "_on_MenuBtn_pressed"))

# --- Volver al menú ---
func _on_MenuBtn_pressed():
	ButtonSound.play()
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
