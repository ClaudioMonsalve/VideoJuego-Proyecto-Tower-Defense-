extends enemy

var bigberthamp3 = preload("res://Assets/Musica/19 2000 instrumental low quality.mp3")
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

func _ready() -> void:
	maxhp = 100.0
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	speed = 6
	audio_stream_player.play()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(audio_stream_player):
			audio_stream_player.stop()
