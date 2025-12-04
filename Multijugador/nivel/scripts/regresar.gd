extends Button

func _ready():
	pressed.connect(_salir_partida)


func _salir_partida() -> void:
	print("\n🚪 === SALIENDO DE LA PARTIDA ===")

	# Acceder al autoload exacto: "Multiplayer"
	var manager = get_node_or_null("/root/Multiplayer")

	if manager == null:
		print("❌ ERROR: No encontré /root/Multiplayer")
		Network.apagar()
		await get_tree().create_timer(0.2).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
		return

	var match_id = manager.match_id

	# Si no hay partida, solo salir
	if match_id == "":
		print("⚠️ No hay match activo. Solo cambio de escena.")
		Network.apagar()
		await get_tree().create_timer(0.2).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
		return

	# ===============================
	# 1) finish-game (gana el rival)
	# ===============================
	print("🏁 Enviando finish-game…")

	Network.ws.send_text(JSON.stringify({
		"event": "finish-game",
		"data": {"matchId": match_id, "winner": "RIVAL"}
	}))
	await get_tree().create_timer(0.25).timeout

	# ===============================
	# 2) quit-match
	# ===============================
	print("📤 Enviando quit-match…")

	Network.ws.send_text(JSON.stringify({
		"event": "quit-match",
		"data": {"matchId": match_id}
	}))
	await get_tree().create_timer(0.25).timeout

	# ==================================
	# 3) Avisar al rival → close:true
	# ==================================
	print("📡 Enviando close:true al rival…")

	Network.ws.send_text(JSON.stringify({
		"event": "send-game-data",
		"data": {
			"matchId": match_id,
			"payload": {"close": true}
		}
	}))
	await get_tree().create_timer(0.25).timeout

	# ==================================
	# 4) Limpiar datos del manager
	# ==================================
	manager.match_id = ""
	manager.match_status = "WAITING_PLAYERS"
	manager.jugadores_del_match.clear()

	print("🧹 Limpieza local lista.")

	# ==================================
	# 5) Cerrar WebSocket
	# ==================================
	print("🔌 Cerrando WebSocket…")
	Network.apagar()
	await get_tree().create_timer(0.3).timeout

	# ==================================
	# 6) Regresar al menú (con await)
	# ==================================
	print("🏠 Volviendo al menú…")
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
