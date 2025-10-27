extends Node2D

@onready var panel: Panel = $Panel
@onready var Cartas: HBoxContainer = $"../Player/HBoxContainer"
@onready var button: Button = $Pause
@onready var sprite_1: AnimatedSprite2D = $Sprites/Sprite1
@onready var sprite_2: AnimatedSprite2D = $Sprites/Sprite2
@onready var volume_slider: HSlider = $Panel/HSlider


const DIALOGO = preload("res://Assets/Dialogos/Dialogo.dialogue")
const MOTÖRHEAD = preload("res://Assets/Musica/Motörhead - Ace Of Spades (drumless).mp3")

func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	volume_slider.value_changed.connect(_on_volume_changed)
	panel.visible = false
	escena()

func escena():
	sprite_1.play()
	sprite_2.play()
	button.cambiar(true,false)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(DIALOGO, "start")

func _on_dialogue_ended(resource):
	MusicPlayer.stream = MOTÖRHEAD
	MusicPlayer.play_music()
	sprite_1.stop()
	sprite_2.stop()
	sprite_1.visible = false
	sprite_2.visible = false
	print("✅ Diálogo terminado.")
	# Aquí haces la acción que quieres que ocurra:
	panel.visible = true   # Por ejemplo, mostrar el panel
	Cartas.visible = true  # O activar tus cartas
	button.cambiar(false)  # O cambiar el botón

func _on_volume_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(0, db)
