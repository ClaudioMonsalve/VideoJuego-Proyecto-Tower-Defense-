extends enemy


func _ready() -> void:
	meshOrSprite = $enemySprite
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	var offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	position += offset
