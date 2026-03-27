extends Button
@onready var pause: Button = $"../../Pause"

func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	pause.cambiar(false)
	
