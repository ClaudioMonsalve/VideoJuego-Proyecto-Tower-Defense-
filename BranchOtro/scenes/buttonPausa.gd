extends Button

# Referencia directa al CreepManager
@onready var creep_manager: Node = $"../../CreepManager"
@onready var torre: Node = $"../../Map/testTower"
@onready var Cartas: HBoxContainer = $"../../Player/HBoxContainer"
@onready var panel: Panel = $"../Panel"
@onready var money: Label = $"../../Player/Money"
@onready var button: Button = $"."

# Variable local para saber si está pausado
var is_paused = false

func _ready():
	pressed.connect(_on_pressed)
	text = "Pausar"  # texto inicial

func _on_pressed():
	cambiar(true)
	

func cambiar(decision: bool, mostrar_panel: bool = true):
	is_paused = decision
	if is_paused:
		torre.pausar()
		creep_manager.pausar()
		button.visible = false
		text = ""
		Cartas.visible = false
		money.visible = false

		if mostrar_panel:
			panel.visible = true
		else:
			panel.visible = false
	else:
		text = "Pausar"
		Cartas.visible = true
		money.visible = true	
		panel.visible = false
		button.visible = true
		torre.reanudar()
		creep_manager.reanudar()
