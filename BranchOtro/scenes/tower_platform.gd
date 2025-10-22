extends Node3D
class_name towerPlatform

var towerTest = preload("res://BranchOtro/scenes/test_tower.tscn")
var hasTower = false

@onready var area: Area3D = $Area3D
@onready var camera: Camera3D = $"../../Player/Camera3D"
@onready var tower_card: PanelContainer = $"../../Player/HBoxContainer/TowerCard"

var is_hovered = false

func _ready():
	tower_card.connect("gui_input", Callable(self, "_on_tower_card_input"))

# ---------------------
# Spawn de torre
# ---------------------
func spawnTower(towerName):
	if not hasTower:
		var tower = getTower(towerName)
		add_child(tower)
		tower.position.y += 2
		hasTower = true
		print("Torre spawneada!")

func getTower(towerName):
	match towerName:
		"test_tower":
			return towerTest.instantiate()

# ---------------------
# Detección de hover de la carta
# ---------------------
func _process(delta):
	detect_tower_card_over_platform()

func detect_tower_card_over_platform():
	if not camera or not tower_card:
		return
	
	var rect = tower_card.get_global_rect()
	var space_state = get_world_3d().direct_space_state
	
	var samples = [
		rect.position,  # top-left
		rect.position + rect.size * Vector2(0.5, 0.0),  # top-center
		rect.position + Vector2(rect.size.x, 0),  # top-right
		rect.position + rect.size * Vector2(0.0, 0.5),  # mid-left
		rect.position + rect.size * 0.5,  # center
		rect.position + Vector2(rect.size.x, rect.size.y * 0.5),  # mid-right
		rect.position + Vector2(0, rect.size.y),  # bottom-left
		rect.position + Vector2(rect.size.x * 0.5, rect.size.y),  # bottom-center
		rect.position + rect.size  # bottom-right
	]
	
	var success = false
	
	for pos in samples:
		var ray_origin = camera.project_ray_origin(pos)
		var ray_dir = camera.project_ray_normal(pos)
		var ray_end = ray_origin + ray_dir * 1000
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_end
		query.collide_with_bodies = true
		query.collide_with_areas = true
		query.collision_mask = 1
		
		var result = space_state.intersect_ray(query)
		if result and result.collider == area:
			success = true
			break

	if success and !is_hovered:
		is_hovered = true
		print("TowerCard está sobre la plataforma:", name)
		
	if !success and is_hovered:
		is_hovered = false
		print("TowerCard salió de la plataforma:", name)

# ---------------------
# Evento de soltar la carta
# ---------------------
func _on_tower_card_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_hovered:
				spawnTower("test_tower")
