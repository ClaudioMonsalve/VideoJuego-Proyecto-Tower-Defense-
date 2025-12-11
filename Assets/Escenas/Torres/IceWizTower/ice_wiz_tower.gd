extends tower

@export var arrowtrail: PackedScene
@export var explosion: PackedScene
@onready var archerpos = $ArcherPos

func effect(body):
	var arrow = arrowtrail.instantiate()
	arrow.start_position = archerpos.global_position
	arrow.enemy = body
	get_tree().current_scene.add_child(arrow)
	await arrow.tree_exited
	var kboom = explosion.instantiate()
	kboom.mainTarget = body
	kboom.towerDamage = damage
	get_tree().current_scene.add_child(kboom)
