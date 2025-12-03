extends Control

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar  # Asegúrate de tener un ProgressBar en la escena

var dot_count: int = 0
var dot_timer: Timer
var total_time: float = 0.0
var max: float = 1.0  
var next_scene: String
var progress := []
var loader

func _ready():
	# === SINGLEPLAYER ===
	if Globals.nextLevel != "":
		next_scene = Globals.nextLevel
	
	# === MULTIPLAYER ===
	elif Globals.multiplayer_level_random != "":
		next_scene = Globals.multiplayer_level_random

	# === NINGÚN NIVEL ASIGNADO ===
	else:
		push_error("❌ No existe nextLevel ni multiplayer_level_random.")
		return
	ResourceLoader.load_threaded_request(next_scene, "PackedScene")
	
	label.text = "Cargando"
	progress_bar.value = 0
	progress_bar.max_value = max
	
	# Crear un Timer para animar los puntos
	dot_timer = Timer.new()
	dot_timer.wait_time = 0.5  # cada medio segundo cambia
	dot_timer.one_shot = false
	add_child(dot_timer)
	dot_timer.start()
	dot_timer.timeout.connect(_on_dot_timer_timeout)
	set_process(true)

func _process(delta):
	var status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0]
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var packed = ResourceLoader.load_threaded_get(next_scene)
			if packed:
				get_tree().change_scene_to_packed(packed)
			set_process(false)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			push_error("mano q como que fallo el resourceloader")

func _on_dot_timer_timeout():
	dot_count = (dot_count + 1) % 4  # de 0 a 3 puntos
	label.text = "Cargando" + ".".repeat(dot_count)
