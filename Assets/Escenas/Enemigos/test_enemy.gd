extends RigidBody3D
class_name enemy

@onready var pathfollow = $".."
@onready var progBar = $"../SubViewport/CanvasLayer/ProgressBar"
var base: Area3D

@export var worth = 4
@export var maxhp =  10.0
@export var speed = 10
@export var dmg = 1
var radius = 3
var hp = maxhp
var spawned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = clamp(hp,0,maxhp)
	var offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	position.x += offset.x
	position.y += offset.y
	pass # Replace with function body.

func linkBase(baseobj):
	base = baseobj	

func ouch(damage):
	hp -= damage
	progBar.value = hp/maxhp * 100
	if hp == 0:
		base.muni += worth
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pathfollow.progress += delta * speed
