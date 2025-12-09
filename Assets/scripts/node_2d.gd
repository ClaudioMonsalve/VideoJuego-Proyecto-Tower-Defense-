extends Node2D

@onready var panel: Panel = $Panel
@onready var Cartas: HBoxContainer = $"../Player/HBox Cards"
@onready var button: Button = $Pause
@onready var volume_slider: HSlider = $Panel/HSlider
@onready var sfx_slider: HSlider = $Panel/HSlider2
@export var DIALOGO: DialogueResource
@onready var salir_multi: Panel = $SalirMulti
@onready var player: Node3D = $"../Player"
@onready var base: Base = $"../Map/Base"
@onready var pause: Button = $Pause
@onready var color_rect: ColorRect = $"../ColorRect"
@onready var atacar: Button = $Atacar
@onready var v_box_playerdata: VBoxContainer = $"../Player/VBox playerdata"



const MOTORHEAD = preload("res://Assets/Musica/Motörhead - Ace Of Spades (drumless).mp3")

var escena_musica_res = preload("res://Assets/Escenas/Enemigos/big_bertha.tscn")
var escena_musica_escena: Node = null
var lista_sonidos: Array = []




func _ready() -> void:
	color_rect.visible = false
	salir_multi.visible = true
	if not Network.mensaje_recibido.is_connected(_on_receive):
		Network.mensaje_recibido.connect(_on_receive)

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

	panel.visible = false
	salir_multi.visible = false


func _process(delta: float) -> void:
		if base.hp == 0:
			_MenuDerrota()
			return


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

func _on_receive(msg: String):

#IMPORTANTE
	var data = JSON.parse_string(msg)


#IMPROTNTE
	var evento : String = data.get("event", "")

#IMPORTANTE 2
	var data_interna = data.get("data", {})
	var payload = data_interna.get("payload", {})


#IMPORTANTE
	var tipo = payload.get("type", "")
	if tipo == "attack":
		var dmg = payload.get("damage", 0)
		player.recibir_ataque(10)

	return
	
	
	
func _MenuDerrota():
	var fade := $"../ColorRect"
	v_box_playerdata.visible = false
	fade.visible = true
	atacar.visible = false
	# Animación simple: aumentar opacidad de 0 a 0.8 en 1.2s
	var tween = get_tree().create_tween()
	tween.tween_property(fade, "modulate:a", 0.8, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pause.visible = false
	Cartas.visible = false
	MusicPlayer.stream_paused = true
	
	
	
	
