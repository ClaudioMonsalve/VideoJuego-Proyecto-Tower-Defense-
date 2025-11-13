extends enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maxhp = 100.0
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	speed = 5
	var offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	position += offset
