extends Node2D

@onready var estado_label: Label = $Label
@onready var conectar_btn: Button = $Button
@onready var atacar_btn: Button = $Button2
@onready var jugadores_btn: Button = $Button3
@onready var solicitar_btn: Button = $Button4  # Nuevo botón para solicitud
@onready var menu: Button = $Menu

var ws := WebSocketPeer.new()
var url := "ws://localhost:4010/?gameId=I&playerName=Claudio"
var clave := "defaultkey"
var ultimo_id_jugador := ""  # Para guardar el ID del último jugador disponible

var login_enviado := false
var en_partida := false
var partida_iniciada := false
var jugadores := []

func _ready():
	estado_label.text = "Desconectado"
	conectar_btn.text = "Conectar"
	atacar_btn.text = "Atacar"
	jugadores_btn.text = "Ver Jugadores"
	solicitar_btn.text = "Solicitar Partida"
	
	atacar_btn.disabled = true
	solicitar_btn.disabled = true
	
	conectar_btn.pressed.connect(_on_conectar_pressed)
	atacar_btn.pressed.connect(_on_atacar_pressed)
	jugadores_btn.pressed.connect(_on_ver_jugadores_pressed)
	solicitar_btn.pressed.connect(_on_solicitar_pressed)
	menu.pressed.connect(_on_back_pressed)
	set_process(true)

func _on_conectar_pressed():
	if ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		estado_label.text = "Conectando..."
		var err = ws.connect_to_url(url)
		if err != OK:
			estado_label.text = "❌ Error al conectar (" + str(err) + ")"
	else:
		estado_label.text = "Ya conectado o en proceso"

func _on_atacar_pressed():
	if partida_iniciada:
		_enviar_ataque()

func _on_ver_jugadores_pressed():
	var msg = {
		"event": "online-players"
	}
	ws.send_text(JSON.stringify(msg))
	print("👥 Solicitando lista de jugadores")

func _on_solicitar_pressed():
	if ultimo_id_jugador != "":
		_enviar_solicitud_partida(ultimo_id_jugador)
		estado_label.text = "Enviando solicitud de partida..."
		solicitar_btn.disabled = true

func _on_back_pressed():
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.close(1000, "Cerrando conexión desde cliente")  # Código 1000 = cierre normal
		print("🔌 Desconectando del servidor...")
		
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
	
	
func _enviar_ataque():
	var ataque = {
		"event": "send-game-data",
		"data": {
			"subEvent": "attack",
			"attackType": "BASIC_ATTACK",
			"damage": 25,
			"position": Vector2(100, 100)
		}
	}
	var json_text = JSON.stringify(ataque)
	ws.send_text(json_text)
	print("⚔️ Ataque enviado:", json_text)

func _process(_delta):
	ws.poll()

	match ws.get_ready_state():
		WebSocketPeer.STATE_CONNECTING:
			estado_label.text = "Conectando..."

		WebSocketPeer.STATE_OPEN:
			while ws.get_available_packet_count() > 0:
				var msg = ws.get_packet().get_string_from_utf8()
				print("📩 Servidor:", msg)
				_manejar_mensaje(msg)

		WebSocketPeer.STATE_CLOSING:
			estado_label.text = "Cerrando conexión..."

		WebSocketPeer.STATE_CLOSED:
			if estado_label.text != "❌ Desconectado":
				estado_label.text = "❌ Desconectado"
			login_enviado = false
			en_partida = false
			partida_iniciada = false
			atacar_btn.disabled = true
			solicitar_btn.disabled = true

func _enviar_login():
	var login = {
		"event": "login",
		"data": {
			"gameKey": clave.strip_edges()
		}
	}
	var json_text = JSON.stringify(login)
	ws.send_text(json_text)
	print("🔑 Login enviado:", json_text)

func _enviar_solicitud_partida(id: String):
	var msg = {
		"event": "send-match-request",
		"data": {
			"playerId": id
		}
	}
	ws.send_text(JSON.stringify(msg))
	print("🎮 Enviando solicitud de partida a:", id)

func _conectar_a_partida():
	var connect_match = {
		"event": "connect-match"
	}
	var json_text = JSON.stringify(connect_match)
	ws.send_text(json_text)
	print("🎮 Conectando a partida:", json_text)

func _enviar_ping():
	var ping = {
		"event": "ping-match"
	}
	var json_text = JSON.stringify(ping)
	ws.send_text(json_text)
	print("📍 Ping enviado:", json_text)

func _manejar_mensaje(msg: String):
	var parsed = JSON.parse_string(msg)
	if typeof(parsed) == TYPE_DICTIONARY:
		match parsed.get("event", ""):
			"connected-to-server":
				estado_label.text = "🟢 Conectado: enviando login..."
				if not login_enviado:
					_enviar_login()
					login_enviado = true

			"login":
				if parsed.get("status", "") == "OK":
					estado_label.text = "✅ Login exitoso"
				else:
					estado_label.text = "⚠️ Error: " + parsed.get("msg", "")

			"online-players":
				if parsed.get("status", "") == "OK":
					jugadores = parsed.get("data", [])
					var texto_jugadores = "=== Jugadores Disponibles ===\n"
					var hay_jugadores = false
					
					for jugador in jugadores:
						if jugador.get("status") == "AVAILABLE" and jugador.get("name") != "Claudio":
							hay_jugadores = true
							ultimo_id_jugador = jugador.get("id")
							texto_jugadores += "- " + jugador.get("name") + "\n"
					
					if hay_jugadores:
						estado_label.text = texto_jugadores + "\nPresiona 'Solicitar Partida' para jugar"
						solicitar_btn.disabled = false
					else:
						estado_label.text = "No hay jugadores disponibles"
						solicitar_btn.disabled = true

			"match-request-received":
				estado_label.text = "📨 Solicitud de partida recibida"
				var msg_accept = {
					"event": "accept-match"
				}
				ws.send_text(JSON.stringify(msg_accept))
				print("✅ Aceptando solicitud de partida")

			"match-accepted":
				estado_label.text = "✅ Partida aceptada"
				_conectar_a_partida()

			"connect-match":
				if parsed.get("status", "") == "OK":
					en_partida = true
					estado_label.text = "🎮 Conectado a partida: esperando jugadores..."

			"players-ready":
				estado_label.text = "👥 Jugadores listos: enviando ping..."
				_enviar_ping()

			"match-start":
				estado_label.text = "🎮 ¡Partida iniciada!"
				partida_iniciada = true
				atacar_btn.disabled = false

			"receive-game-data":
				var data = parsed.get("data", {})
				if data.get("subEvent") == "attack":
					estado_label.text = "💥 ¡Recibiste un ataque! Daño: " + str(data.get("damage", 0))

			"game-ended":
				estado_label.text = "🏁 Partida terminada"
				partida_iniciada = false
				atacar_btn.disabled = true
				solicitar_btn.disabled = true

			_:
				estado_label.text = "📨 " + parsed.get("event", "")
	else:
		estado_label.text = "Mensaje no válido"
