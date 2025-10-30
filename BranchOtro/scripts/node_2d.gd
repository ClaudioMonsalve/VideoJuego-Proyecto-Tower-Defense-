extends Node2D

@onready var panel: Panel = $Panel
@onready var Cartas: HBoxContainer = $"../Player/HBoxContainer"
@onready var button: Button = $Pause
@onready var sprite_1: AnimatedSprite2D = $Sprites/Sprite1
@onready var sprite_2: AnimatedSprite2D = $Sprites/Sprite2
@onready var volume_slider: HSlider = $Panel/HSlider
@onready var sfx_slider: HSlider = $Panel/HSlider2

const DIALOGO = preload("res://Assets/Dialogos/Dialogo.dialogue")
const MOTORHEAD = preload("res://Assets/Musica/Motörhead - Ace Of Spades (drumless).mp3")

var escena_musica_res = preload("res://Assets/Escenas/Enemigos/big_bertha.tscn")
var escena_musica_escena: Node = null
var lista_sonidos: Array = []  # 👈 aquí guardaremos todos los AudioStreamPlayer

func _ready() -> void:
	# Instanciar la escena
	escena_musica_escena = escena_musica_res.instantiate()
	add_child(escena_musica_escena)

	# Buscar todos los sonidos dentro de la escena
	lista_sonidos = buscar_todos_los_audio_streams(escena_musica_escena)

	if lista_sonidos.size() > 0:
		print("🎧 Se encontraron", lista_sonidos.size(), "sonidos:")
		for s in lista_sonidos:
			print("  •", s.name)
	else:
		print("⚠️ No se encontraron AudioStreamPlayers en la escena.")

	# Configurar sliders
	volume_slider.value = db_to_linear(MusicPlayer.volume_db)
	volume_slider.value_changed.connect(_on_volume_changed)

	if lista_sonidos.size() > 0:
		sfx_slider.value = db_to_linear(lista_sonidos[0].volume_db)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	panel.visible = false
	escena()


# 🔍 Función recursiva para encontrar *todos* los AudioStreamPlayer y AudioStreamPlayer3D
func buscar_todos_los_audio_streams(nodo: Node) -> Array:
	var lista: Array = []
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer3D:
		lista.append(nodo)
	for hijo in nodo.get_children():
		lista += buscar_todos_los_audio_streams(hijo)
	print(lista)
	return lista


func escena():
	sprite_1.play()
	sprite_2.play()
	button.cambiar(true, false)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(DIALOGO, "start")


func _on_dialogue_ended(resource):
	MusicPlayer.stream = MOTORHEAD
	MusicPlayer.play_music()
	sprite_1.stop()
	sprite_2.stop()
	sprite_1.visible = false
	sprite_2.visible = false
	print("✅ Diálogo terminado.")
	panel.visible = true
	Cartas.visible = true
	button.cambiar(false)


# 🎵 Controla el volumen global (música)
func _on_volume_changed(value: float) -> void:
	MusicPlayer.volume_db = linear_to_db(value)


# 🔊 Controla el volumen de *todos* los sonidos encontrados
func _on_sfx_changed(value: float) -> void:
	var db = linear_to_db(value)
	for sonido in lista_sonidos:
		if is_instance_valid(sonido):
			sonido.volume_db = db
	print("🔈 Volumen SFX ajustado a:", db, "dB")
