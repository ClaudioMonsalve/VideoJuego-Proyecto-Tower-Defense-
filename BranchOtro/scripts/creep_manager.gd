extends Node3D

@export var enemy1: PackedScene
@export var enemy2: PackedScene
@export var base: Area3D

@onready var pathHolder = $"../Map/Paths"

var waveDelay = 5.0
var spanwDelay = 0.1

var wavesArr = [
	{
		"enemy1": 2
	},
	{
		"enemy1": 5
	},
	{
		"enemy1": 3
	},
	{
		"enemy2": 1
	}
]

func waveManager():
	for wave in wavesArr:
		for key in wave:
			for i in range(wave[key]):
				var creep = returnCreep(key)
				creep.get_child(0).linkBase(base)
				pathHolder.get_child(0).add_child(creep)
				await get_tree().create_timer(spanwDelay).timeout
			await get_tree().create_timer(waveDelay).timeout

func returnCreep(type):
	match type:
		"enemy1":
			return enemy1.instantiate()
		"enemy2":
			return enemy2.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waveManager()
	pass # Replace with function body.
