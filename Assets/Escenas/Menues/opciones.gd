extends Node2D

@onready var h_slider_2: HSlider = $Panel/HSlider2
@onready var h_slider: HSlider = $HSlider


func _ready():
	# Cargar valores guardados
	h_slider.value = Settings.music_volume
	h_slider_2.value = Settings.sfx_volume

	# Conectar sliders
	h_slider.value_changed.connect(func(value): Settings.set_music(value))
	h_slider_2.value_changed.connect(func(value): Settings.set_sfx(value))



# 🎵 CONTROL DE MÚSICA (bus "Music")
func _on_volume_changed(value: float) -> void:
	var db = lerp(-40.0, 0.0, value)  # 0 → silencioso, 1 → volumen máximo

	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus == -1:
		music_bus = AudioServer.get_bus_index("Master")

	AudioServer.set_bus_volume_db(music_bus, db)


# 💥 CONTROL DE EFECTOS (bus "SFX")
func _on_sfx_changed(value: float) -> void:
	var db = lerp(-40.0, 0.0, value)

	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		sfx_bus = AudioServer.get_bus_index("Master")  # ← FIX

	AudioServer.set_bus_volume_db(sfx_bus, db)
