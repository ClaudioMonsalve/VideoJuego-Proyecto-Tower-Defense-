extends Node2D

@onready var button: Button = $Control/Button


const MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_ = preload("res://Assets/Musica/Viking l Medieval Nordic Valhalla Throat Singing Meditative l 30 min l By Vadym Kuznietsov [sRuib4auqQw].mp3")

func _ready():
	# Asignar la música al Autoload
	if MusicPlayer.stream != MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_:
		MusicPlayer.stream = MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_
		MusicPlayer.play()

	# Conectar la señal pressed del botón
	button.pressed.connect(Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Mapa.tscn")
