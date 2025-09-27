extends Node3D

@onready var enemyColl = $AttackRange
@onready var clickColl = $Interactable

@export var damage = 2
@export var attkspeed = 10

var attacking = false

var creepQueue = []

func _ready() -> void:
	enemyColl.body_entered.connect(_on_enemy_enter)
	enemyColl.body_exited.connect(_on_enemy_exit)

func attack():
	while !creepQueue.is_empty():
		creepQueue[0].ouch(damage)
		await get_tree().create_timer(1.0).timeout
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
