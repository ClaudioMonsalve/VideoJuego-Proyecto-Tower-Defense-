extends Button
@onready var creep_manager: CreepManager = $"../../../CreepManager"

func _ready():
	pressed.connect(_salir_partida)


func _salir_partida() -> void:
	print("\n🚪 === ABANDONANDO PARTIDA ===")

	# 2) ENVIAR 'defeat' AL RIVAL (avisamos que nosotros perdimos)
	var payload := {
		"type": "defeat",
		"player": Globals.my_player_name
	}

	print("📤 Enviando derrota al rival...")
	Network.send_game_data(payload)

	await get_tree().create_timer(0.1).timeout   # Pequeño delay para asegurar envío


	# 3) ENVIAR AL SERVIDOR: quit-match
	print("📤 Enviando quit-match al servidor...")

	Network.ws.send_text(JSON.stringify({
		"event": "quit-match",
		"data": {"matchId": Globals.match_id}
	}))



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
