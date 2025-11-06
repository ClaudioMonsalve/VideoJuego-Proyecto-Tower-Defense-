extends Node3D
class_name CreepManager

@export var enemy1: PackedScene
@export var enemy2: PackedScene
@export var base: Area3D

@onready var pathHolder = $"../Map/Paths"

var waveDelay := 5.0
var spawnDelay := 0.5
var pausa := false
var spawning := false

var wavesArr = [
	{"enemy1": 2, "path": 0},
	{"enemy1": 5, "path": 0},
	{"enemy1": 3, "enemy2": 1, "path": 0},
	{"enemy2": 2, "path": 1}
]

# Control interno
var wave_index := 0
var enemy_types := []
var current_enemy_index := 0
var spawn_timer := 0.0
var wave_timer := 0.0
var phase := "idle"  # idle | spawning | waiting_wave | done

func _ready():
	startWaves()


# === Inicio de las oleadas ===
func startWaves():
	if spawning:
		return
	spawning = true
	phase = "spawning"
	wave_index = 0
	setupWave()


# === Actualización principal ===
func _process(delta: float) -> void:
	if pausa or not spawning:
		return

	match phase:
		"spawning":
			handleSpawning(delta)
		"waiting_wave":
			handleWaveDelay(delta)
		_:
			pass


# === Configura la siguiente wave ===
func setupWave():
	if wave_index >= wavesArr.size():
		print("✅ Todas las oleadas terminadas.")
		spawning = false
		phase = "done"
		return

	var wave = wavesArr[wave_index]
	enemy_types = []

	# Prepara lista como [("enemy1", 2), ("enemy2", 1)] sin incluir "path"
	for key in wave.keys():
		if key == "path":
			continue
		enemy_types.append({"type": key, "count": wave[key]})

	current_enemy_index = 0
	spawn_timer = 0.0
	print("🔥 Iniciando Wave ", wave_index + 1)
	phase = "spawning"


# === Maneja el spawn individual ===
func handleSpawning(delta: float):
	spawn_timer += delta
	if spawn_timer < spawnDelay:
		return
	spawn_timer = 0.0

	var wave = wavesArr[wave_index]
	var path = pathHolder.get_child(wave["path"])

	# Busca el tipo de enemigo actual
	if current_enemy_index < enemy_types.size():
		var enemy_info = enemy_types[current_enemy_index]
		if enemy_info["count"] > 0:
			spawnEnemy(enemy_info["type"], path)
			enemy_info["count"] -= 1
			enemy_types[current_enemy_index] = enemy_info
		else:
			current_enemy_index += 1
	else:
		# Wave completa → pasar al delay entre oleadas
		phase = "waiting_wave"
		wave_timer = 0.0
		print("⏳ Oleada ", wave_index + 1, " completada.")
		wave_index += 1


# === Delay entre waves ===
func handleWaveDelay(delta: float):
	wave_timer += delta
	if wave_timer >= waveDelay:
		setupWave()


# === Spawnea un enemigo ===
func spawnEnemy(type: String, path: Node) -> void:
	var creep = returnCreep(type)
	if creep:
		var enemyNode = creep.get_child(0)
		if enemyNode:
			enemyNode.linkBase(base)
			enemyNode.add_to_group("Creeps")
		path.add_child(creep)
		print("🧟 Spawneado ", type, " en path ", path.name)


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
