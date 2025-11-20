extends tower

@export var arrowtrail: PackedScene
@onready var archerpos = $ArcherPos

func effect(body):
	var arrow = arrowtrail.instantiate()
	arrow.start_position = archerpos.global_position
	arrow.enemy = body
	get_tree().current_scene.add_child(arrow)
	await arrow.tree_exited
	if body:
		body.ouch(damage)
