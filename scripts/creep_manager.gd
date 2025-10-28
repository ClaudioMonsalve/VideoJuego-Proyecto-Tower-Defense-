extends Node3D

@export var enemy1 = preload("res://scenes/test_enemy.tscn")
@export var enemy2 = preload("res://scenes/test_enemy2.tscn") 

@export var enemy2_spawn_chance: float = 0.5

@export var spawn_radius: float = 1.5

@onready var pathHolder = $"../Map/Paths"

var waveDelay = 5.0
var spanwDelay = 0.1 # (Tu script original dice "spanwDelay", lo mantengo)

# --- ESTRUCTURA DE OLEADAS (MODIFICADA PARA 6 CAMINOS) ---
var waves = [
	# Formato: [Camino 0, Camino 1, Camino 2, Camino 3, Camino 4, Camino 5]
	[5, 7, 0, 0, 0, 0],  # Oleada 1: 5 enemigos por el camino 0, 7 por el 1. El resto 0.
	[10, 14, 5, 5, 0, 0], # Oleada 2: 10 por el 0, 14 por el 1, 5 por el 2, 5 por el 3.
	[20, 20, 10, 10, 5, 5]  # Oleada 3: Enemigos en todos los caminos.
]


func waveManager():
	for wave in waves:
		# Esta línea lee el tamaño de la oleada (ahora 6)
		# por lo que el bucle se ejecutará 6 veces (de 0 a 5).
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
				
				# Esta línea ahora llamará a get_child(0), get_child(1), ..., get_child(5)
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
