extends tower

@export var arrowtrail: PackedScene
@export var explosion: PackedScene
@onready var archerpos = $ArcherPos
@onready var animatedsprite = $AnimatedSprite3D

func effect(body):
	var arrow = arrowtrail.instantiate()
	arrow.start_position = archerpos.global_position
	arrow.enemy = body
	get_tree().current_scene.add_child(arrow)
	animation()
	await arrow.tree_exited
	var kboom = explosion.instantiate()
	kboom.mainTarget = body
	kboom.towerDamage = damage
	get_tree().current_scene.add_child(kboom)

func animation():
	animatedsprite.play("Shoot")
	await animatedsprite.animation_finished
	animatedsprite.play("Idle")
