extends Button

func _ready():
	pressed.connect(_enviar_ataque)


func _enviar_ataque():
	# --- VALIDACIONES ---
	if Globals.match_id == "":
		print("⚠️ [ATTACK] No hay match_id, no se puede atacar.")
		return

	if Network.ws == null:
		print("⚠️ [ATTACK] Network.ws es null.")
		return

	if Network.ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("⚠️ [ATTACK] WebSocket no está abierto.")
		return

	# --- PAYLOAD DEL ATAQUE ---
	var payload := {
		"type": "attack",
		"player": Globals.my_player_name,
		"damage": 10   # daño base, no importa, el rival hará su propio sistema de sabotaje
	}

	print("⚔️ [ATTACK] Enviando ataque:", payload)

	# --- ENVIAR AL SERVIDOR ---
	var paquete := {
		"event": "send-game-data",
		"data": {
			"matchId": Globals.match_id,
			"payload": payload
		}
	}

	Network.ws.send_text(JSON.stringify(paquete))
