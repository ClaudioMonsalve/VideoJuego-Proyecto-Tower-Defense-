extends Node2D

# --- Nodos ---
@onready var cam: Camera2D = $Camera2D
@onready var info_panel: Control = $CanvasLayer/InfoPanel
@onready var label_name: Label = info_panel.get_node("Nombre")
@onready var label_levels: Label = info_panel.get_node("Niveles")
@onready var cerrar_btn: Button = info_panel.get_node("Cerrar")
@onready var jugar_btn: Button = info_panel.get_node("Jugar")
@onready var menu_btn: Button = $Button
@onready var reinos_container: Node = $ReinosContainer

# --- Variables ---
var reino_seleccionado_data: Dictionary = {}
var cam_origin: Vector2
var cam_zoom_origin: Vector2
var active_tween: Tween = null

func _ready():
	# Guardar posición y zoom iniciales
	cam_origin = cam.global_position
	cam_zoom_origin = cam.zoom

	# Panel invisible al inicio
	info_panel.visible = false
	_center_info_panel()

	# Conectar señal de click de cada reino
	for reino in reinos_container.get_children():
		reino.connect("reino_seleccionado", Callable(self, "_on_reino_seleccionado"))

	# Conectar botones
	cerrar_btn.pressed.connect(Callable(self, "_on_InfoPanel_Cerrar_pressed"))
	jugar_btn.pressed.connect(Callable(self, "_on_InfoPanel_Jugar_pressed"))
	menu_btn.pressed.connect(Callable(self, "_on_MenuBtn_pressed"))

# --- Selección de reino ---
func _on_reino_seleccionado(data: Dictionary):
	# Guardar data
	reino_seleccionado_data = {
		"id": data.get("id"),
		"nombre": data.get("nombre", "Reino"),
		"niveles": data.get("niveles", 0),
		"cam_offset": data.get("cam_offset", Vector2(0,0)),
		"cam_zoom": data.get("cam_zoom", Vector2(2,2)),
		"cam_return_offset": data.get("cam_return_offset", Vector2(0,0))
	}

	# Actualizar panel
	label_name.text = reino_seleccionado_data["nombre"]
	label_levels.text = "Nivel Actual: %d" % reino_seleccionado_data["niveles"]
	info_panel.visible = true

	# Detener tween anterior
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	# Tween hacia posición y zoom del reino
	var target_pos = cam_origin + reino_seleccionado_data["cam_offset"]
	var target_zoom = reino_seleccionado_data["cam_zoom"]

	active_tween = create_tween()
	active_tween.parallel().tween_property(cam, "zoom", target_zoom, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	active_tween.parallel().tween_property(cam, "global_position", target_pos, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	# Ocultar los demás reinos
	for reino in reinos_container.get_children():
		reino.visible = false

# --- Cerrar panel ---
func _on_InfoPanel_Cerrar_pressed():
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	# Posición de regreso
	var return_pos = cam_origin
	if reino_seleccionado_data.has("cam_return_offset"):
		return_pos += reino_seleccionado_data["cam_return_offset"]

	# Tween de regreso
	active_tween = create_tween()
	active_tween.parallel().tween_property(cam, "zoom", cam_zoom_origin, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	active_tween.parallel().tween_property(cam, "global_position", return_pos, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	info_panel.visible = false

	# Mostrar todos los reinos
	for reino in reinos_container.get_children():
		reino.visible = true

# --- Jugar ---
func _on_InfoPanel_Jugar_pressed():
	if reino_seleccionado_data.size() == 0:
		return
	print("Cargando niveles del reino: ", reino_seleccionado_data["nombre"])
	# get_tree().change_scene_to_file("res://niveles/%s.tscn" % reino_seleccionado_data["id"])
	
	 # Abrir la escena del nivel del reino
	# Ajusta el nombre según la escena que corresponda
	MusicPlayer.stop_music()
		
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/control.tscn")
	
# --- Volver al menú ---
func _on_MenuBtn_pressed():
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")

# --- Centrar InfoPanel ---
func _center_info_panel():
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = info_panel.get_size()
	info_panel.position = (viewport_size - panel_size) / 2
