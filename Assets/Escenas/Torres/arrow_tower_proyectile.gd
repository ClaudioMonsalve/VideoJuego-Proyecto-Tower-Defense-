extends MeshInstance3D

var enemy: enemy
var start_position: Vector3
var end_position: Vector3
var speed := 40.0
var done := false

func _ready():
	global_transform.origin = start_position

func _process(delta):
	var dir
	var dist
	if done:
		return

	if enemy:
		dir = (enemy.global_transform.origin - global_transform.origin)
		dist = dir.length()
	else:
		done = true	

	if  done or dist < 0.5:
		done = true
		queue_free()
		return

	global_transform.origin += dir.normalized() * speed * delta
