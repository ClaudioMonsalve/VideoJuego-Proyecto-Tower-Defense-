extends Button
@onready var button: Button = $"../../Button"

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	button.cambiar(false)
