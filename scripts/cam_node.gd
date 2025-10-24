extends Node3D

@onready var camera = $Camera3D
@onready var baseobj = $"../Map/Base"
@onready var label = $Label

#Limites
@export var min_x: float = 0.0
@export var max_x: float = 80.0
@export var min_z: float = -50.0
@export var max_z: float = 50.0

@export var camera_sens = 0.05
@export var zoomSens = 2
@export var minH = 8 
@export var maxH = 30
var rotSens = 0.04
var minRot = 50
var maxRot = 30
var dragging := false
var last_pos := Vector2.ZERO


func handle_click_or_tap(_event_pos: Vector2):
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				last_pos = event.position
			else:
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
		
		var new_pos = global_position
		new_pos.x = clamp(new_pos.x, min_x, max_x)
		new_pos.z = clamp(new_pos.z, min_z, max_z)
		global_position = new_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = str(baseobj.hp)
	pass
