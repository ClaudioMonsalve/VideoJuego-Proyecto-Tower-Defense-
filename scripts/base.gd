extends Area3D
class_name base

var hp = 30


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	print(hp)
	pass # Replace with function body.

func _on_body_entered(body):
	print("lol")
	if body is enemy:
		hp -= 1
		print(hp)
		body.get_parent().call_deferred("queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
