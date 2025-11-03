extends Button

# Referencia directa al CreepManager
@onready var creep_manager: Node = $"../../CreepManager"
@onready var test_tower: Node3D = $"../../Map/testTower"
@onready var panel: Panel = $"../Panel"
@onready var h_box_container: HBoxContainer = $"../../Player/HBoxContainer"
@onready var health: Label = $"../../Player/Health"
@onready var money: Label = $"../../Player/Money"
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
		test_tower.pausar()
		creep_manager.pausar()
		pause.visible = false
		text = ""
		h_box_container.visible = false
		money.visible = false
		health.visible = false
		MusicPlayer.stream_paused = true
			
		if mostrar_panel:
			panel.visible = true
		else:
			panel.visible = false
		
	else:
		text = "Pausar"
		h_box_container.visible = true
		money.visible = true	
		panel.visible = false
		pause.visible = true
		health.visible = true
		test_tower.reanudar()
		creep_manager.reanudar()
		MusicPlayer.stream_paused = false
