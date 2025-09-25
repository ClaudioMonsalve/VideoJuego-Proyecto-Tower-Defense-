extends Node3D

@onready var camera = $Camera3D
@onready var baseobj = $"../Map/Base"
@onready var label = $Label

@export var camera_sens = 0.01

var dragging := false
var last_pos := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				last_pos = event.position
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(baseobj.hp)
	pass
