extends Button

func _ready():
	pressed.connect(_enviar_ataque)

func _enviar_ataque():
	if Globals.match_id == "":
		print("⚠️ [ATTACK] No hay match_id, no se puede atacar.")
		return

	if Network.ws == null or Network.ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("⚠️ [ATTACK] WebSocket no está abierto.")
		return

	var payload := {
		"type": "attack",
		"player": Globals.my_player_name,
		"damage": 10
	}

	print("⚔️ [ATTACK] Enviando ataque:", payload)

	Network.ws.send_text(JSON.stringify({
		"event": "send-game-data",
		"data": {
			"matchId": Globals.match_id,
			"payload": payload
		}
	}))
