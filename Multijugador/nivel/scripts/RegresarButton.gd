extends Button
@onready var salir_multi: Panel = $"../../SalirMulti"
@onready var button_2: Button = $"."
@onready var panel: Panel = $".."

const cancion_ = preload("res://Assets/Musica/Viking l Medieval Nordic Valhalla Throat Singing Meditative l 30 min l By Vadym Kuznietsov [sRuib4auqQw].mp3")
func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	salir_multi.visible = true
	panel.visible = false
	call_deferred("_cambiar_escena")

func _cambiar_escena():
	MusicPlayer.stream = cancion_
	MusicPlayer.play_music()
	await get_tree().process_frame
