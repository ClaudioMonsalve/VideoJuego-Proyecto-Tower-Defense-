extends Node3D

@onready var camera = $Camera3D
@export var baseobj: Base
@onready var hpLabel = $Health
@onready var mnLabel = $Money
@onready var debug = $"../debug"

#tarjetas de torres
#============================
@export var card1: PanelContainer
@export var card2: PanelContainer
@export var card3: PanelContainer
@export var card4: PanelContainer
@export var card5: PanelContainer
@export var card6: PanelContainer
#============================

#torres
#============================
@export var torre_test: PackedScene

@export var camera_sens = 0.01
@export var zoomSens = 2
@export var minH = 8 
@export var maxH = 30
@export var muni = 0
var rotSens = 0.04
var minRot = 50
var maxRot = 30
var dragging := false
var last_pos := Vector2.ZERO

#variables de las tarjetas
#===============================
var is_hovered = false
var detectedPlatform = null

func _ready() -> void:
	card1.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card1))
	card2.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card2))
	card3.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card3))
	card4.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card4))
	card5.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card5))
	card6.connect("gui_input", Callable(self, "_on_tower_card_input").bind(card6))

func detect_tower_card_over_platform(tower_card):
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
		if result and result.collider.get_parent() is towerPlatform:
			detectedPlatform = result.collider.get_parent()
			success = true
			break
	
	print(success)
	if success and !is_hovered:
		is_hovered = true
		
	if !success and is_hovered:
		is_hovered = false

# ---------------------
# Evento de soltar la carta
# ---------------------
func _on_tower_card_input(event: InputEvent, card):
	if event is InputEventMouseButton:
		detect_tower_card_over_platform(card)
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_hovered:
				var tower = buyTower(card.myTowerType)
				if tower != null:
					detectedPlatform.spawnTower(tower)
				else:
					print("no muni :c")
				detectedPlatform = null
					

func buyTower(towerName):
	var tower = getTower(towerName)
	print(baseobj.muni)
	if  tower.price <= baseobj.muni:
		baseobj.muni -= tower.price
		return tower
	else:
		return null

func getTower(towerName):
	match towerName:
		"test_tower":
			return torre_test.instantiate()

func handle_click_or_tap(event_pos: Vector2):
	var spaceState = get_world_3d().direct_space_state
	
	var rayOrigin = camera.project_ray_origin(event_pos)
	var rayDir = camera.project_ray_normal(event_pos)
	var rayEnd = rayOrigin + rayDir * 1000
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	query.collide_with_areas = true
	query.collision_mask = 1
	var result = spaceState.intersect_ray(query)
	
	if result:
		var interactPos = result.position
		var interactedObjct = result.collider
		debug.position = interactPos
		print("clicked at:", interactPos, "on:", interactedObjct.get_parent())

	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				last_pos = event.position
			elif !dragging:
				handle_click_or_tap(event.position)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera.rotate_x(rotSens)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, maxRot, minRot)
			position.y = clamp(position.y - zoomSens, minH, maxH)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and position.y < maxH:
			camera.rotate_x(-rotSens)
			camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, maxRot, minRot)
			position.y = clamp(position.y + zoomSens, minH, maxH)
	 
	elif event is InputEventScreenTouch:
		dragging = event.pressed
		if dragging:
			last_pos = event.position
	elif (event is InputEventMouseMotion and dragging) or (event is InputEventScreenDrag and dragging):
		var delta = event.position - last_pos
		last_pos = event.position
		
		var dx = delta.x * camera_sens
		var dy = delta.y * camera_sens

		translate(Vector3(-dx,dy,0))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hpLabel.text = str(baseobj.hp)
	mnLabel.text = str(baseobj.muni)
	pass
