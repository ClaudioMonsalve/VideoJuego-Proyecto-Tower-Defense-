extends RigidBody3D
class_name enemy

@onready var pathfollow = $".."
@onready var progBar = $"../SubViewport/CanvasLayer/ProgressBar"

@export var worth = 4
@export var maxhp =  10.0
@export var speed = 30
var hp = maxhp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = clamp(hp,0,maxhp)
	pass # Replace with function body.

func ouch(damage):
	hp -= damage
	progBar.value = hp/maxhp * 100
	if hp == 0:
		
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pathfollow.progress += delta * speed
