extends Button

const cancion_ = preload("res://Assets/Musica/Viking l Medieval Nordic Valhalla Throat Singing Meditative l 30 min l By Vadym Kuznietsov [sRuib4auqQw].mp3")
func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	call_deferred("_cambiar_escena")

func _cambiar_escena():
	MusicPlayer.stream = cancion_
	MusicPlayer.play_music()
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Mapa.tscn")
