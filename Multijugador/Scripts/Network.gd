extends Node2D

var ws := WebSocketPeer.new()
var conectado := false
var ping_timer := 0.0
const PING_INTERVAL := 10.0

var player_name := ""
var game_id := ""
var game_key := ""
var my_id := ""

signal mensaje_recibido(msg: String)
signal conectado_servidor()


# ===========================================================
# INICIAR NETWORK
# ===========================================================
func iniciar(nombre, gameId, gameKey):
	if conectado:
		return

	player_name = nombre
	game_id = gameId
	game_key = gameKey

	_conectar()



# ===========================================================
# LOOP PRINCIPAL DEL SOCKET (ÚNICO poll DEL JUEGO)
# ===========================================================
func _process(delta):
	if not conectado:
		return

	# --- KEEP ALIVE ---
	ping_timer += delta
	if ping_timer >= PING_INTERVAL:
		ping_timer = 0.0
		_enviar({"event": "ping"})

	# --- LEER MENSAJES ---
	ws.poll()

	while ws.get_available_packet_count() > 0:
		var msg := ws.get_packet().get_string_from_utf8()
		# FORWARD al resto del juego
		emit_signal("mensaje_recibido", msg)

 
	# --- SI EL SOCKET SE CIERRA ---
	if ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		conectado = false
		_reconectar()


# ===========================================================
# CONECTAR
# ===========================================================
func _conectar():
	var url := "ws://cross-game-ucn.martux.cl:4010/?gameId=%s&playerName=%s" % [game_id, player_name]

	var err := ws.connect_to_url(url)

	if err == OK:
		conectado = true
		emit_signal("conectado_servidor")
	else:
		await get_tree().create_timer(1).timeout
		_conectar()


func _reconectar():
	await get_tree().create_timer(1).timeout
	_conectar()


# ===========================================================
# ENVIAR MENSAJES CRUDOS
# ===========================================================
func _enviar(dic: Dictionary):
	if not conectado:
		print("❌ [NETWORK] Intento de envío sin conexión")
		return

	ws.send_text(JSON.stringify(dic))


# ===========================================================
# APAGAR
# ===========================================================
func apagar():

	conectado = false
	ping_timer = 0.0

	if ws and ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.close(1000, "User exit")

	ws = WebSocketPeer.new()


# ===========================================================
# ENVIAR EVENTOS DE JUEGO (ATAQUES, ETC)
# ===========================================================
func send_game_data(payload: Dictionary):

	var paquete := {
		"event": "send-game-data",
		"data": {
			"matchId": Globals.match_id,
			"payload": payload,
			"damage": 10
		}
	}

	var json := JSON.stringify(paquete)

	ws.send_text(json)
