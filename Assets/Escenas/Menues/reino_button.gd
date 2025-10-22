extends Area2D

# --- Datos del reino ---
@export var nombre: String = "Midgard"
@export var niveles: int = 10
@export var id: String = "reino_id"

# --- Cámara ---
@export var cam_offset: Vector2 = Vector2(-470, 70)        # desplazamiento al acercar
@export var cam_zoom: Vector2 = Vector2(2, 2)          # zoom al hacer click
@export var cam_return_offset: Vector2 = Vector2(114, -65) # ajuste al alejar

# --- Señal ---
signal reino_seleccionado(data: Dictionary)

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ButtonSound.play()
		emit_signal("reino_seleccionado", {
			"id": id,
			"nombre": nombre,
			"niveles": niveles,
			"cam_offset": cam_offset,
			"cam_zoom": cam_zoom,
			"cam_return_offset": cam_return_offset
		})
