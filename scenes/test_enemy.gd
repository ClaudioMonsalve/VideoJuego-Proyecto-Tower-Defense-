extends RigidBody3D
class_name enemy

@onready var pathfollow = $".."

@export var speed = 30


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pathfollow.progress += delta * speed
