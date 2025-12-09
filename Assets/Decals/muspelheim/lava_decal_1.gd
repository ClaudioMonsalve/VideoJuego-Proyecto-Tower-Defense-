extends Decal

@onready var aniplayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aniplayer.play("glo")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
