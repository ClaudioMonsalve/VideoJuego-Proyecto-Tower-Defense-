extends Button

# Estas variables deben venir del autoload o asignarse desde afuera
var match_id := ""
var conectado := false

func _ready():
	pressed.connect(_cerrar_conexion_con_rival)


func _cerrar_conexion_con_rival() -> void:
	print("🚪 Saliendo manualmente de la partida…")

	# Si hay match activo, lo cerramos correctamente
	if match_id != "":
		print("🏁 Enviando finish-game (gana el rival)…")
		Network.ws.send_text(JSON.stringify({
			"event": "finish-game",
			"data": {
				"matchId": match_id,
				"winner": "RIVAL"
			}
		}))
		await get_tree().create_timer(0.2).timeout

		print("📤 Enviando quit-match…")
		Network.ws.send_text(JSON.stringify({
			"event": "quit-match",
			"data": {"matchId": match_id}
		}))
		await get_tree().create_timer(0.2).timeout

		print("📡 Enviando close:true al rival…")
		Network.ws.send_text(JSON.stringify({
			"event": "send-game-data",
			"data": {
				"matchId": match_id,
				"payload": {"close": true}
			}
		}))
		await get_tree().create_timer(0.2).timeout

	# Cerrar WebSocket local
	if Network.ws:
		print("🔌 Cerrando WebSocket local…")
		Network.ws.close()
		conectado = false

	# Reset interno
	match_id = ""
	print("🧹 Partida limpiada. Regresando al menú.")

	# Cambiar escena
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
