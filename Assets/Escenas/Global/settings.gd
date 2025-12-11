extends Node

var music_volume: float = 1.0
var sfx_volume: float = 1.0

const FILE_PATH := "user://settings.cfg"

func _ready():
	load_settings()
	apply_volumes()

func set_music(value: float):
	music_volume = value
	save_settings()
	apply_volumes()

func set_sfx(value: float):
	sfx_volume = value
	save_settings()
	apply_volumes()

func apply_volumes():
	var db_music = lerp(-40.0, 0.0, music_volume)
	var db_sfx = lerp(-40.0, 0.0, sfx_volume)

	var bus_music := AudioServer.get_bus_index("Music")
	if bus_music == -1:
		bus_music = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_music, db_music)

	var bus_sfx := AudioServer.get_bus_index("SFX")
	if bus_sfx == -1:
		bus_sfx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_sfx, db_sfx)

func save_settings():
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.save(FILE_PATH)

func load_settings():
	var cfg = ConfigFile.new()
	var err = cfg.load(FILE_PATH)

	if err == OK:
		music_volume = cfg.get_value("audio", "music_volume", 1.0)
		sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)
