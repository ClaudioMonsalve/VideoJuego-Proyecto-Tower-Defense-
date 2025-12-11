extends Node3D

@onready var collider = $Area3D
var mainTarget: enemy
var towerDamage = 0
var victims = []

func _ready() -> void:
	collider.body_entered.connect(_on_enemy_enter)
	if mainTarget:
		global_position = mainTarget.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	print("im doing damage now")
	inflictPainOnVictims()

func _on_enemy_enter(body):
	if body is enemy and body not in victims:
		print("i just appended" + body.name + "into victims")
		victims.append(body)

func inflictPainOnVictims():
	print("overlaps:", collider.get_overlapping_bodies())
	for body in victims:
		if body:
			print("i just told" + body.name + "to die")
			body.ouch(towerDamage)
	await get_tree().physics_frame
	queue_free()
