extends Area3D
class_name base

@onready var progBar = $SubViewport/CanvasLayer/ProgressBar

var maxhp = 30.0
var hp = maxhp
var gd = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	print(hp)
	pass # Replace with function body.

func _on_body_entered(body):
	print("lol")
	if body is enemy:
		hp -= 1
		progBar.value = hp/maxhp * 100
		body.get_parent().call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass


func _on_boton_reinicio_pressed() -> void:
	pass # Replace with function body.
