extends Node3D

@export var enemy1 = preload("res://scenes/test_enemy.tscn")

@onready var path1 = $"../Map/path1"

func spawnonenibbler():
	var creep = enemy1.instantiate()
	path1.add_child(creep)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnonenibbler()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
