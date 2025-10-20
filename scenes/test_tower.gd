extends Node3D

@onready var enemyColl = $AttackRange
@onready var clickColl = $Interactable

@export var damage = 2.0
@export var attkspeed = 2.0
var attkSpeedCalculated = 1.0/attkspeed

var attacking = false

var creepQueue = []
var firstcreep = null

func _ready() -> void:
	enemyColl.body_entered.connect(_on_enemy_enter)
	enemyColl.body_exited.connect(_on_enemy_exit)

func attack():
	while !creepQueue.is_empty():
		if creepQueue[0] != null:
			creepQueue[0].ouch(damage)
			await get_tree().create_timer(attkSpeedCalculated).timeout
		else:
			creepQueue.pop_front()
	attacking = false
	print(creepQueue)

func _on_enemy_enter(body):
	if body is enemy:
		creepQueue.append(body)
		if !attacking:
			attacking = true
			attack()

func _on_enemy_exit(body):
	if body in creepQueue:
		creepQueue.pop_front()
		if !attacking:
			attacking = true
			attack()
	pass


func _process(delta: float) -> void:
	pass
