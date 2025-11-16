extends Node3D
class_name towerPlatform

# 1. Creamos un diccionario para Cargar TODAS las escenas de torres
var tower_scenes = {
	"test": preload("res://BranchOtro/scenes/test_tower.tscn"),
	"torre_nueva": preload("res://BranchOtro/scenes/tower_2.tscn") # <-- CAMBIA ESTO
}

var hasTower = false

@onready var area: Area3D = $Area3D
@onready var camera: Camera3D = $"../../Player/Camera3D"
@onready var tower_card: PanelContainer = $"../../Player/HBoxContainer/TowerCard"


func _ready():
	pass

# ---------------------
# Spawn de torre
# ---------------------
# 2. Modificamos la función para que acepte un "tower_type" (un string)
func spawnTower(tower_type: String):
	# Verificamos que no haya torre Y que el tipo de torre exista
	if not hasTower and tower_scenes.has(tower_type):
		
		# 3. Obtenemos la escena correcta del diccionario
		var tower_scene = tower_scenes[tower_type]
		
		# 4. Instanciamos la escena
		var tower_instance = tower_scene.instantiate()
		
		# 5. Añadimos la instancia como hijo (tu lógica original)
		add_child(tower_instance)
		tower_instance.position.y += 2
		hasTower = true
		print("Torre '" + tower_type + "' spawneada!")
		
	else:
		if hasTower:
			print("Error: Ya existe una torre en esta plataforma.")
		else:
			print("Error: Tipo de torre desconocido: " + tower_type)
