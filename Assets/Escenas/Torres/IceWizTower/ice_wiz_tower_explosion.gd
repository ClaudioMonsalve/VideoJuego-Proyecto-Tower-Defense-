extends Node3D

@onready var collider = $Area3D
@onready var mesh = $Area3D/MeshInstance3D
var mainTarget: enemy
var towerDamage = 0
var victims = []

func _ready() -> void:
	collider.body_entered.connect(_on_enemy_enter)
	if mainTarget:
		global_position = mainTarget.global_position
		mesh.visible = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	inflictPainOnVictims()

func _on_enemy_enter(body):
	if body is enemy and body not in victims:
		victims.append(body)

func inflictPainOnVictims():
	for body in victims:
		if body:
			body.ouch(towerDamage)
	await get_tree().physics_frame
	queue_free()
