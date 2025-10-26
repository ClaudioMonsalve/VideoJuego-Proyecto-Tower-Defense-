extends Node2D

@onready var panel: Panel = $Panel
@onready var Cartas: HBoxContainer = $"../Player/HBoxContainer"
const dialogue = preload("res://Assets/Dialogos/Dialogo.dialogue")
@onready var button: Button = $Button
const DIALOGO = preload("res://Assets/Dialogos/Dialogo.dialogue")
@onready var sprite_1: AnimatedSprite2D = $Sprites/Sprite1
@onready var sprite_2: AnimatedSprite2D = $Sprites/Sprite2

func _ready() -> void:
	panel.visible = false
	escena()

func escena():
	button.cambiar(true,false)
	sprite_1.play()
	sprite_2.play()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(DIALOGO, "start")

func _on_dialogue_ended(resource):
	sprite_1.stop()
	sprite_1.visible = false
	sprite_2.visible = false
	print("✅ Diálogo terminado.")
	# Aquí haces la acción que quieres que ocurra:
	panel.visible = true   # Por ejemplo, mostrar el panel
	Cartas.visible = true  # O activar tus cartas
	button.cambiar(false)  # O cambiar el botón
