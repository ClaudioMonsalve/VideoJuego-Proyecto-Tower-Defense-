extends Button

const cancion_ = preload("res://Assets/Musica/Viking l Medieval Nordic Valhalla Throat Singing Meditative l 30 min l By Vadym Kuznietsov [sRuib4auqQw].mp3")
func _ready():
	pressed.connect(_on_pressed)
	
func _on_pressed():
	call_deferred("_cambiar_escena")

# NUEVA FUNCIÓN
func _cerrar_match_y_cambiar_escena():
	# 1) Buscar el nodo del script multijugador
	var multi := get_tree().root.find_child("Multijugador", true, false)

	if multi and multi.has_method("_salir_partida_completa"):
		print("🔌 Cerrando partida antes de salir…")
		await multi._salir_partida_completa()
	else:
		print("⚠️ No se encontró nodo Multijugador o método _salir_partida_completa")

	# 2) Reproducir música
	MusicPlayer.stream = cancion_
	MusicPlayer.play_music()

	await get_tree().process_frame

	# 3) Cambiar escena
	get_tree().change_scene_to_file("res://Multijugador/Escenas/Multijugador.tscn")
