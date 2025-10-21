extends PanelContainer

@onready var camera = $"../../Camera3D"
var dragging = false
var drag_offset = Vector2.ZERO
var originalPos = global_position

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
				global_position = originalPos
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
