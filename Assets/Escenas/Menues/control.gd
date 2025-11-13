extends Control

@onready var label: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar  # Asegúrate de tener un ProgressBar en la escena

var dot_count: int = 0
var dot_timer: Timer
var total_time: float = 0.0
var duration: float = 1  # duración total en segundos
var next_scene: String = "res://BranchOtro/scenes/test_scene.tscn"

func _ready():
	label.text = "Cargando"
	progress_bar.value = 0
	progress_bar.max_value = duration
	
	# Crear un Timer para animar los puntos
	dot_timer = Timer.new()
	dot_timer.wait_time = 0.5  # cada medio segundo cambia
	dot_timer.one_shot = false
	add_child(dot_timer)
	dot_timer.start()
	dot_timer.timeout.connect(_on_dot_timer_timeout)

func _process(delta):
	total_time += delta
	
	# Actualizar barra de progreso
	progress_bar.value = total_time
	
	if total_time >= duration:
		# Detener el timer y cambiar de escena
		dot_timer.stop()
		get_tree().change_scene_to_file(next_scene)

func _on_dot_timer_timeout():
	dot_count = (dot_count + 1) % 4  # de 0 a 3 puntos
	label.text = "Cargando" + ".".repeat(dot_count)
