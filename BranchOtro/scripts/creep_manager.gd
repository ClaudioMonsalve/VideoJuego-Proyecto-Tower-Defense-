extends Node3D
class_name CreepManager

@export var enemy1: PackedScene
@export var enemy2: PackedScene
@export var base: Area3D

@onready var pathHolder = $"../Map/Paths"

var waveDelay = 5.0
var spawnDelay = 0.1
var pausa = false
var spawning = false

var wavesArr = [
	{"enemy1": 2},
	{"enemy1": 5},
	{"enemy1": 3},
	{"enemy2": 1}
]

# Inicia la generación de oleadas
func startWaves():
	if not spawning:
		spawning = true
		await waveManager()

# Manager de las oleadas
func waveManager() -> void:
	for wave in wavesArr:
		for key in wave:
			for i in range(wave[key]):
				while pausa:
					await get_tree().process_frame
				var creep = returnCreep(key)
				if creep:
					var enemyNode = creep.get_child(0)
					if enemyNode:
						enemyNode.linkBase(base)
						enemyNode.add_to_group("Creeps")
					pathHolder.get_child(0).add_child(creep)
				await waitWhileNotPaused(spawnDelay)

		await waitWhileNotPaused(waveDelay)

	spawning = false

# Función auxiliar: espera que pase el tiempo sin avanzar si está en pausa
func waitWhileNotPaused(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		if not pausa:
			elapsed += get_process_delta_time()
		await get_tree().create_timer(0.01).timeout


# Retorna la instancia del creep correspondiente
func returnCreep(type: String) -> Node:
	match type:
		"enemy1":
			if enemy1:
				return enemy1.instantiate()
			else:
				push_error("enemy1 no asignado en el Inspector")
				return null
		"enemy2":
			if enemy2:
				return enemy2.instantiate()
			else:
				push_error("enemy2 no asignado en el Inspector")
				return null
		_:
			return null

# Pausar spawn y creeps existentes
func pausar():
	pausa = true
	for creep in get_tree().get_nodes_in_group("Creeps"):
		if creep.has_method("pausar"):
			creep.pausar()

# Reanudar spawn y creeps existentes
func reanudar():
	pausa = false
	for creep in get_tree().get_nodes_in_group("Creeps"):
		if creep.has_method("reanudar"):
			creep.reanudar()

func _ready() -> void:
	startWaves()
