extends Node2D

@onready var panel: Panel = $Panel
@onready var Cartas: HBoxContainer = $"../Player/HBox Cards"
@onready var button: Button = $Pause
@onready var volume_slider: HSlider = $Panel/HSlider
@onready var sfx_slider: HSlider = $Panel/HSlider2

const DIALOGO = preload("res://Assets/Dialogos/Dialogo.dialogue")
const MOTORHEAD = preload("res://Assets/Musica/Motörhead - Ace Of Spades (drumless).mp3")

var escena_musica_res = preload("res://Assets/Escenas/Enemigos/big_bertha.tscn")
var escena_musica_escena: Node = null
var lista_sonidos: Array = []


func _ready() -> void:
	# Instanciar escena de enemigos / efectos
	escena_musica_escena = escena_musica_res.instantiate()
	# Buscar todos los AudioStreamPlayers dentro
	lista_sonidos = buscar_todos_los_audio_streams(escena_musica_escena)
	# --- CONFIGURAR SLIDERS ---
	volume_slider.min_value = 0
	volume_slider.max_value = 1
	volume_slider.step = 0.01
	volume_slider.value = 1.0  # 1 = volumen máximo
	volume_slider.value_changed.connect(_on_volume_changed)

	sfx_slider.min_value = 0
	sfx_slider.max_value = 1
	sfx_slider.step = 0.01
	sfx_slider.value = 1.0  # 1 = volumen máximo
	sfx_slider.value_changed.connect(_on_sfx_changed)

	MusicPlayer.stream = MOTORHEAD
	MusicPlayer.bus = "Music"
	MusicPlayer.play_music()
	panel.visible = true
	Cartas.visible = true
	button.cambiar(false)


# 🔍 Busca todos los AudioStreamPlayers dentro de la escena
func buscar_todos_los_audio_streams(nodo: Node, lista: Array = []) -> Array:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		lista.append(nodo)
	for hijo in nodo.get_children():
		buscar_todos_los_audio_streams(hijo, lista)
	return lista



# 🎵 CONTROL DE MÚSICA (bus MUSIC)
func _on_volume_changed(value: float) -> void:
	var db = lerp(-40.0, 0.0, value)  # 0 = silencio, 1 = máximo
	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus == -1:
		music_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(music_bus, db)


# 💥 CONTROL DE EFECTOS (bus SFX)
func _on_sfx_changed(value: float) -> void:
	var db = lerp(-40.0, 0.0, value)  # 0 = silencio, 1 = máximo
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		sfx_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_bus, db)
