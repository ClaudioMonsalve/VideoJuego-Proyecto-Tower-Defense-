extends Button

func _ready():
	pressed.connect(_salir_partida)
	
func _salir_partida():

# 4) LIMPIAR DATOS LOCALES
	var manager = get_node_or_null("/root/Multiplayer")
	if manager:
		manager.match_id = ""
		manager.match_status = "WAITING_PLAYERS"
		manager.jugadores_del_match.clear()

	print("🧹 Datos locales limpiados.")


	# 5) CERRAR WEBSOCKET
	print("🔌 Cerrando WebSocket…")
	Network.apagar()



	# 6) VOLVER AL MENÚ
	print("🏠 Volviendo al menú principal…")
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
