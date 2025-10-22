extends enemy

var bigberthamp3 = preload("res://Assets/Musica/19 2000 instrumental low quality.mp3")


func _ready() -> void:
	maxhp = 100.0
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	speed = 6
	if MusicPlayer.stream != bigberthamp3:
		MusicPlayer.stream = bigberthamp3
		MusicPlayer.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		MusicPlayer.stop()
