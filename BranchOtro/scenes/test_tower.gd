extends Node3D

@onready var enemyColl = $AttackRange
@onready var clickColl = $Interactable

@export var price = 5.0
@export var damage = 2.0
@export var attkspeed = 2.0
var attkSpeedCalculated = 1.0 / attkspeed

var attacking = false
var paused = false

var creepQueue = []

func _ready() -> void:
	enemyColl.body_entered.connect(_on_enemy_enter)
	enemyColl.body_exited.connect(_on_enemy_exit)

func _process(delta: float) -> void:
	pass

func _on_enemy_enter(body):
	if body is enemy:
		creepQueue.append(body)
		if not attacking and not paused:
			attacking = true
			attack()  # llamada inicial

func _on_enemy_exit(body):
	if body in creepQueue:
		creepQueue.erase(body)  # mejor erase que pop_front, por si no es el primero

func pausar():
	paused = true

func reanudar():
	paused = false
	if not attacking:
		attacking = true
		attack()

func attack() -> void:
	# Función asíncrona "manual" usando await
	while creepQueue.size() > 0 and not paused:
		var target = creepQueue[0]
		if target != null:
			target.ouch(damage)
			await get_tree().create_timer(attkSpeedCalculated).timeout
		else:
			creepQueue.pop_front()
	attacking = false
