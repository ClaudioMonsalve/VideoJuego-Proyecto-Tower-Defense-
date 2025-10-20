extends Button

func _ready():
	pressed.connect(_on_pausa_pressed)

func _on_pausa_pressed():
	get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		text = "Reanudar" 
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	else:
		text = "Pausa"
		process_mode = Node.PROCESS_MODE_INHERIT
