extends Node3D

@export var enemy1 = preload("res://scenes/test_enemy.tscn")

@onready var path1 = $"../Map/path1"

var waveDelay = 5.0
var spanwDelay = 0.1

var waves = [[2],[5]]

func waveManager():
	for wave in waves:
		for amount in waves:
			for i in range(amount[0]):
				var creep = enemy1.instantiate()
				path1.add_child(creep)
				await get_tree().create_timer(spanwDelay).timeout
			await get_tree().create_timer(waveDelay).timeout



func spawnonenibbler():
	var creep = enemy1.instantiate()
	path1.add_child(creep)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waveManager()
	pass # Replace with function body.
