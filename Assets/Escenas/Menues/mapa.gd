extends Node2D

# --- Nodos ---
@onready var cam: Camera2D = $Camera2D
@onready var menu_btn: Button = $Button
@onready var reinos_container: Node = $ReinosContainer

# --- Variables ---
var reino_seleccionado_data: Dictionary = {}
var cam_origin: Vector2
var cam_zoom_origin: Vector2
var active_tween: Tween = null

func _ready():

	menu_btn.pressed.connect(Callable(self, "_on_MenuBtn_pressed"))

# --- Volver al menú ---
func _on_MenuBtn_pressed():
	ButtonSound.play()
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
