extends enemy


func _ready() -> void:
	meshOrSprite = $enemySprite
	maxhp = 6
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	speed = 12
	var offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	position += offset
