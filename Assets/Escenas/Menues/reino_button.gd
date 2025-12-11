extends Area2D

# --- Datos del reino ---
@export var nombre: String = "Nombre del reino"
@export var niveles: int = 1
@export var nombreNivel1: String = "nivel1"
@export var rutaNivel1: String = ""
@export var nombreNivel2: String = "nivel2"
@export var rutaNivel2: String = ""
@export var nombreNivel3: String = "nivel3"
@export var rutaNivel3: String = ""
@export var fondo: Texture2D
@export var ico: Texture2D

# --- Selector de Nivel ---
@onready var nodoIco = $ReinoIco/Ico
@onready var nivelSeleccionado: Label = $OpenMap/Label
var rutaNivelSeleccionado: String
@onready var nodoFondo = $OpenMap/Panel/TextureRect
@onready var openMap = $OpenMap
@onready var reinoLabel = $OpenMap/Panel/ReinoLabel
@onready var jugarBtn = $OpenMap/jugar
@onready var cerrarBtn = $OpenMap/cerrar
@onready var reinoIco = $ReinoIco
@onready var banner1 = $OpenMap/areaLevel1
@onready var banner2 = $OpenMap/areaLevel2
@onready var banner3 = $OpenMap/areaLevel3

# --- Cámara ---
@export var cam: Camera2D
var cam_origin
var cam_offset: Vector2     # desplazamiento al acercar
var cam_target
var cam_origin_zoom: Vector2 = Vector2(1, 1)
@export var cam_zoom: Vector2 = Vector2(2, 2)          # zoom al hacer click
@export var cam_return_offset: Vector2 = Vector2(-116, 64) # ajuste al alejar
var active_tween: Tween = null

# --- Seleccion de nivelS ---


# --- Señal ---
signal reino_seleccionado(data: Dictionary)

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	cam_offset = Vector2(global_position.x, global_position.y)
	if cam:
		cam_origin = Vector2(cam.global_position.x, cam.global_position.y)
	cam_target = cam_origin + cam_offset
	
	reinoLabel.text = nombre
	reinoLabel.pivot_offset = reinoLabel.size/2
	
	if fondo:
		nodoFondo.set_texture(fondo)
	if ico:
		nodoIco.set_texture(ico)
		
	openMap.visible = false
	input_pickable = true
	
	banner1.input_event.connect(Callable(self, "_level_banner_input_event").bind(banner1))
	banner2.input_event.connect(Callable(self, "_level_banner_input_event").bind(banner2))
	banner3.input_event.connect(Callable(self, "_level_banner_input_event").bind(banner3))
	
	jugarBtn.pressed.connect(Callable(self, "_on_jugar_pressed"))
	cerrarBtn.pressed.connect(Callable(self, "_on_cerrar_pressed"))

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ButtonSound.play()
		
		if active_tween and active_tween.is_valid():
			active_tween.kill()
		
		active_tween = create_tween()
		active_tween.parallel().tween_property(cam, "zoom", cam_zoom, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		active_tween.parallel().tween_property(cam, "global_position", cam_offset, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		
		reinoIco.disabled = true
		reinoIco.visible = false
		openMap.visible = true
		
		if rutaNivelSeleccionado == "":
			jugarBtn.disabled = true

func _on_cerrar_pressed():
	ButtonSound.play()
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.parallel().tween_property(cam, "zoom", cam_origin_zoom, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	active_tween.parallel().tween_property(cam, "global_position", cam_origin, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	
	rutaNivelSeleccionado = ""
	reinoIco.visible = true
	reinoIco.disabled = false
	openMap.visible = false

func _on_jugar_pressed():
	ButtonSound.play()
	Globals.nextLevel = rutaNivelSeleccionado
	MusicPlayer.stop_music()
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/control.tscn")

func _level_banner_input_event(viewport, event, shape_idx, banner):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ButtonSound.play()
		match banner:
			banner1:
				nivelSeleccionado.text = "Nivel Seleccionado: " + nombreNivel1
				rutaNivelSeleccionado = rutaNivel1
				if jugarBtn.disabled == true and rutaNivelSeleccionado != "":
					jugarBtn.disabled = false
				else:
					jugarBtn.disabled = true
				return
			banner2:
				nivelSeleccionado.text = "Nivel Seleccionado: " + nombreNivel2
				rutaNivelSeleccionado = rutaNivel2
				if jugarBtn.disabled == true and rutaNivelSeleccionado != "":
					jugarBtn.disabled = false
				else:
					jugarBtn.disabled = true
				return
			banner3:
				nivelSeleccionado.text = "Nivel Seleccionado: " + nombreNivel3
				rutaNivelSeleccionado = rutaNivel3
				if jugarBtn.disabled == true and rutaNivelSeleccionado != "":
					jugarBtn.disabled = false
				else:
					jugarBtn.disabled = true
				return
		pass
