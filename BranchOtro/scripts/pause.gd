extends Button

# Referencia directa al CreepManager
@onready var creep_manager: Node = $"../../CreepManager"
@onready var test_tower: Node3D = $"../../Map/testTower"
@onready var panel: Panel = $"../Panel"
@onready var hbox_Cards: HBoxContainer = $"../../Player/HBox Cards"
@onready var player_Data: VBoxContainer = $"../../Player/VBox playerdata"
@onready var pause: Button = $"."

# Variable local para saber si está pausado
var is_paused = false

func _ready():
	panel.visible = false
	pressed.connect(_on_pressed)
	text = "Pausar"  # texto inicial

func _on_pressed():
		is_paused = !is_paused
		cambiar(is_paused)

func cambiar(decision,mostrar_panel: bool = true):
	is_paused = decision
	if is_paused:
		get_tree().call_group("torres", "pausar")
		creep_manager.pausar()
		pause.visible = false
		text = ""
		hbox_Cards.visible = false
		player_Data.visible = false
		MusicPlayer.stream_paused = true
			
		if mostrar_panel:
			panel.visible = true
		else:
			panel.visible = false
		
	else:
		text = "Pausar"
		hbox_Cards.visible = true
		player_Data.visible = true
		panel.visible = false
		pause.visible = true
		get_tree().call_group("torres", "reanudar")
		creep_manager.reanudar()
		MusicPlayer.stream_paused = false
