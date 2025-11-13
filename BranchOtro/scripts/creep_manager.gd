extends Node3D
class_name CreepManager

@export var enemy1: PackedScene
@export var enemy2: PackedScene
@export var base: Area3D
@export var waves: wave_data 

@onready var pathHolder = $"../Map/Paths"
@onready var paths := pathHolder.get_children()

var waveDelay := 5.0
var spawnDelay := 0.5
var pausa := false
var spawning := false

# nuevo manejo de oleadas para permitir distintos carriles por oleada
# y un tiempo entre oleadas personalizado

#estructura:
#spawns: [lista con {enemigo1, camino}, {enemigo1, enemigo2, camino} etc]
#wave_delay: autoexplanatorio 🥀

var newWavesArr: Array = []


# Control interno
var wave_index := 0
var enemy_types := []
var current_enemy_index := 0
var spawn_timer := 0.0
var wave_timer := 0.0
var phase := "idle"  # idle | spawning | waiting_wave | done

func _ready():
	if waves:
		newWavesArr = waves.waves
	startWaves()


# === Inicio de las oleadas ===
func startWaves():
	if spawning:
		return
	spawning = true
	phase = "spawning"
	wave_index = 0
	waveManager()

# === Corutinas para spawnear multiples enemigos paralelamente ===
func waveManager() -> void:
	for wave in newWavesArr:
		# Create a list of async tasks for all spawns
		var spawn_tasks: Array = []
		for group in wave["spawns"]:
			spawn_tasks.append(await spawnGroup(group))
		
		# Wait for all groups in this wave to finish spawning
		for t in spawn_tasks:
			await t
		
		await waitWhileNotPaused(wave["wave_delay"])
	spawning = false


# === Utility: pauses correctly even when paused ===
func waitWhileNotPaused(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		if not pausa:
			elapsed += get_process_delta_time()
		await get_tree().process_frame #<<<<<===== error


# === Spawns a group of enemies (one path) ===
func spawnGroup(group: Dictionary) -> void:
	await _spawnGroup(group)

func _spawnGroup(group: Dictionary) -> void:
	var path_index = group["path"]
	var path = paths[path_index]
	
	# For each enemy type and count in this group
	for key in group.keys():
		if key == "path":
			continue
		var count = group[key]
		for i in range(count):
			while pausa:
				await get_tree().process_frame
			
			spawnEnemy(key, path)
			await waitWhileNotPaused(spawnDelay)


# === Actualización principal ===
func _process(delta: float) -> void:
	if pausa or not spawning:
		return


# === Spawnea un enemigo ===
func spawnEnemy(type: String, path: Node) -> void:
	var creep = returnCreep(type)
	if creep:
		var enemyNode = creep.get_child(0)
		if enemyNode:
			enemyNode.linkBase(base)
			enemyNode.add_to_group("Creeps")
		path.add_child(creep)


func returnCreep(type: String) -> Node:
	match type:
		"enemy1":
			return enemy1.instantiate() if enemy1 else null
		"enemy2":
			return enemy2.instantiate() if enemy2 else null
		_:
			return null


# === Pausar / Reanudar ===
func pausar():
	pausa = true
	for creep in get_tree().get_nodes_in_group("Creeps"):
		if creep.has_method("pausar"):
			creep.pausar()


func reanudar():
	pausa = false
	for creep in get_tree().get_nodes_in_group("Creeps"):
		if creep.has_method("reanudar"):
			creep.reanudar()
