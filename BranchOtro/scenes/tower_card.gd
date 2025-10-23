extends PanelContainer



@export var myTowerType = ""

@onready var nameLabel = $"Label"
@onready var camera = $"../../Camera3D"
var dragging = false
var drag_offset = Vector2.ZERO
var originalPos = Vector2.ZERO
var parent: HBoxContainer
var index = 0

func _ready() -> void:
	index = get_index()
	nameLabel.text = myTowerType
	originalPos = global_position

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				Input.set_default_cursor_shape(Input.CURSOR_MOVE)

			else:
				dragging = false
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
				parent = get_parent()
				parent.remove_child(self)
				parent.add_child(self)
				get_parent().move_child(self, index)
				
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
