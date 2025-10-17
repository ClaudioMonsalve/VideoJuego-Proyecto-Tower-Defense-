extends Node3D

@export var enemy1 = preload("res://scenes/test_enemy.tscn")
@export var enemy2 = preload("res://scenes/test_enemy2.tscn") 


@export var enemy2_spawn_chance: float = 0.5

@export var spawn_radius: float = 1.5

@onready var pathHolder = $"../Map/Paths"

var waveDelay = 5.0
var spanwDelay = 0.1

# --- ESTRUCTURA DE OLEADAS  ---
var waves = [
	[5, 7],  # Oleada 1: 5 enemigos en total por el camino 0, 7 por el camino 1
	[10, 14]   # Oleada 2: 10 enemigos en total por el camino 0 y 14 por el 1
]


func waveManager():
	for wave in waves:
		for path_index in range(wave.size()):
			var amount = wave[path_index] # Cantidad total para este camino
			
			for i in range(amount):
				var enemy_to_spawn 
				
				if randf() < enemy2_spawn_chance:
					enemy_to_spawn = enemy2 # Si el número es bajo, elige el enemigo 2
				else:
					enemy_to_spawn = enemy1 # Si no, elige el enemigo 1 (por defecto)
				
				# Instanciamos el enemigo que fue seleccionado al azar.
				var creep = enemy_to_spawn.instantiate()
				# ------------------------------------
				
				pathHolder.get_child(path_index).add_child(creep)
				
				var random_offset = Vector3(randf_range(-spawn_radius, spawn_radius), 
											0, 
											randf_range(-spawn_radius, spawn_radius))
				creep.position += random_offset
				
				await get_tree().create_timer(spanwDelay).timeout
				
		await get_tree().create_timer(waveDelay).timeout

func spawnonenibbler():
	var creep = enemy1.instantiate()
	pathHolder.get_child(0).add_child(creep)

func _ready() -> void:
	randomize()
	waveManager()
	pass
