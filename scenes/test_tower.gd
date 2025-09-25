extends Node3D

@onready var enemyColl = $AttackRange
@onready var clickColl = $Interactable

@export var damage = 2
@export var attkspeed = 10

var creepQueue = []

func _ready() -> void:
	enemyColl.body_entered.connect(_on_enemy_enter)
	enemyColl.body_exited.connect(_on_enemy_exit)

func _on_enemy_enter(body):
	creepQueue.append(body)

func _on_enemy_exit(body):
	if body in creepQueue:
		creepQueue.pop_front()
	pass

func _process(delta: float) -> void:
	while !creepQueue.is_empty():
		creepQueue[0].ouch(damage)
		await get_tree().create_timer(1.0).timeout
		
