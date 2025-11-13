extends Node2D

@onready var estado_label: Label = $Label
@onready var conectar_btn: Button = $Button
@onready var atacar_btn: Button = $Button2
@onready var jugadores_btn: Button = $Button3
@onready var solicitar_btn: Button = $Button4
@onready var menu: Button = $Menu
@export var playerData: player_data

# 🔹 Cambiá el nombre aquí para cada jugador (Claudio, Benja, etc)
var ws := WebSocketPeer.new()
var url : String 
var game_key := "B2VAFIF18P"

var conectado := false
var login_enviado := false
var jugadores := []
var en_partida := false
var id_jugador := ""
var id_enemigo := ""
var nombre_enemigo := ""
var buscando_oponente := false

var vida_jugador := 100
var vida_enemigo := 100


# ==============================================================================
# === Inicialización y Señales ===
# ==============================================================================
func _ready():
	if playerData:
		url = "ws://cross-game-ucn.martux.cl:4010/?gameId=D&playerName=" + playerData.player_name
	else:
		url = "ws://cross-game-ucn.martux.cl:4010/?gameId=D&playerName=Unnamed"
	
	estado_label.text = "Desconectado"

	conectar_btn.text = "Conectar"
	atacar_btn.text = "Atacar"
	jugadores_btn.text = "Ver Jugadores"
	solicitar_btn.text = "Solicitar Partida"
	menu.text = "Volver al Menú"

	atacar_btn.disabled = true
	solicitar_btn.disabled = true
	menu.disabled = true

	conectar_btn.pressed.connect(_on_conectar_pressed)
	jugadores_btn.pressed.connect(_on_ver_jugadores_pressed)
	atacar_btn.pressed.connect(_on_atacar_pressed)
	solicitar_btn.pressed.connect(_on_solicitar_pressed)
	menu.pressed.connect(_on_volver_pressed)


func _process(_delta):
	if conectado:
		ws.poll()
		while ws.get_available_packet_count() > 0:
			var msg = ws.get_packet().get_string_from_utf8()
			_on_mensaje_recibido(msg)


# ==============================================================================
# === Botones ===
# ==============================================================================
func _on_conectar_pressed():
	if not conectado:
		var err = ws.connect_to_url(url)
		if err == OK:
			estado_label.text = "Conectando..."
			print("🔌 Conectando al servidor...")
			conectado = true
		else:
			estado_label.text = "Error al conectar"
			print("❌ No se pudo conectar:", err)
	else:
		print("⚠️ Ya estás conectado.")


func _on_ver_jugadores_pressed():
	var payload = {"event": "online-players"}
	ws.send_text(JSON.stringify(payload))
	estado_label.text = "Buscando jugadores..."


func _on_solicitar_pressed():
	if en_partida:
		estado_label.text = "⚠️ Ya estás en una partida."
		return

	buscando_oponente = true
	ws.send_text(JSON.stringify({"event": "online-players"}))
	estado_label.text = "Buscando jugador disponible..."

	await get_tree().create_timer(10.0).timeout
	if not en_partida and buscando_oponente:
		estado_label.text = "❌ Ningún jugador respondió al desafío."
		buscando_oponente = false


func _on_atacar_pressed():
	if not en_partida or id_enemigo == "":
		estado_label.text = "⚠️ No estás en una partida activa."
		return

	var payload = {"event": "attack", "data": {"enemyId": id_enemigo, "damage": 10}}
	ws.send_text(JSON.stringify(payload))
	print("💥 Enviando ataque a", nombre_enemigo)
	estado_label.text = "💥 ¡Ataque enviado a " + nombre_enemigo + "!"


func _on_volver_pressed():
	if conectado:
		ws.close()
		conectado = false
		login_enviado = false
		en_partida = false
		buscando_oponente = false
		id_jugador = ""
		id_enemigo = ""
		nombre_enemigo = ""
		vida_jugador = 100
		vida_enemigo = 100
		atacar_btn.disabled = true
		solicitar_btn.disabled = true
		menu.disabled = true
		estado_label.text = "Desconectado"
		print("🔚 Conexión cerrada.")


# ==============================================================================
# === WebSocket y Eventos ===
# ==============================================================================
func _on_mensaje_recibido(msg: String):
	print("📩 Recibido:", msg)
	var data = JSON.parse_string(msg)
	if data == null or not data.has("event"):
		return

	match data["event"]:
		"connected-to-server":
			print("✅ Conectado al servidor. Enviando login...")
			estado_label.text = "Conectado al servidor"
			_enviar_login()

		"login":
			if data["status"] == "OK":
				estado_label.text = "Login exitoso ✅"
				atacar_btn.disabled = false
				solicitar_btn.disabled = false
				menu.disabled = false
			else:
				estado_label.text = "Error de login ⚠️"

		"online-players":
			_manejar_lista_jugadores(data)

		# ==============================================================
		# 🔹 AUTO-ACEPTACIÓN DE PARTIDAS
		# ==============================================================
		"match-request-received":
			if data.has("data") and data["data"].has("matchId"):
				var rival_id = data["data"].get("playerId", "")
				print("🎯 Desafío recibido de:", rival_id)
				var payload = {"event": "accept-match"}
				ws.send_text(JSON.stringify(payload))
				print("🤝 Aceptando automáticamente el desafío...")
				estado_label.text = "🤝 ¡Desafío recibido! Aceptando partida..."

		# ==============================================================
		# 🔹 ESTADO DE JUGADORES
		# ==============================================================
		"player-status-changed":
			if data.has("data"):
				var jugador_id = data["data"].get("playerId")
				var nuevo_estado = data["data"].get("playerStatus")

				# Si soy yo → no hago nada
				if jugador_id == id_jugador:
					return

				# Si el enemigo pasa a IN_MATCH → comenzamos
				if jugador_id == id_enemigo and nuevo_estado == "IN_MATCH":
					print("⚔️ El rival ha aceptado. ¡Partida activa!")
					en_partida = true
					vida_jugador = 100
					vida_enemigo = 100
					atacar_btn.disabled = false
					solicitar_btn.disabled = true
					estado_label.text = "⚔️ ¡Partida contra " + nombre_enemigo + " iniciada!"

		# ==============================================================
		# 🔹 CONFIRMACIÓN DE PARTIDA
		# ==============================================================
		"accept-match":
			if data.get("status") == "OK":
				en_partida = true
				vida_jugador = 100
				vida_enemigo = 100
				atacar_btn.disabled = false
				solicitar_btn.disabled = true
				estado_label.text = "⚔️ ¡Partida ACTIVA! ¡A luchar!"
				print("🎉 Partida aceptada y activa.")

		# ==============================================================
		# 🔹 ATAQUES
		# ==============================================================
		"attack":
			if data.has("data") and data["data"].has("damage"):
				var danio = data["data"]["damage"]
				vida_jugador -= danio
				if vida_jugador < 0: vida_jugador = 0
				print("💥 Ataque recibido. Vida actual:", vida_jugador)
				estado_label.text = "💥 ¡Recibiste " + str(danio) + " de daño! Vida: " + str(vida_jugador)

				# Confirmar el daño al atacante
				var payload = {"event": "attack-confirmation", "data": {"targetId": id_enemigo, "damage": danio}}
				ws.send_text(JSON.stringify(payload))
				print("📤 Confirmando daño recibido:", danio)

		"attack-confirmation":
			if data.has("data") and data["data"].has("targetId") and data["data"].has("damage"):
				var target_id = data["data"]["targetId"]
				var danio = data["data"]["damage"]

				if target_id == id_enemigo:
					vida_enemigo -= danio
					if vida_enemigo < 0: vida_enemigo = 0
					print("🎯 Ataque confirmado. Vida enemigo:", vida_enemigo)
					estado_label.text = "⚔️ ¡Golpe a " + nombre_enemigo + "! Vida restante: " + str(vida_enemigo)

		"match-finished":
			_manejar_fin_partida(data)

		_:
			print("Evento no manejado:", data["event"])


# ==============================================================================
# === Funciones auxiliares ===
# ==============================================================================
func _enviar_login():
	if not login_enviado:
		var payload = {"event": "login", "data": {"gameKey": game_key}}
		ws.send_text(JSON.stringify(payload))
		login_enviado = true
		print("📤 Login enviado...")


func _manejar_lista_jugadores(data: Dictionary):
	if data.has("data") and typeof(data["data"]) == TYPE_ARRAY:
		jugadores = data["data"]
		for j in jugadores:
			if j.get("name") in [get_player_name_from_url()]:
				id_jugador = str(j.get("id"))
			elif j.get("status") == "AVAILABLE" and str(j.get("id")) != id_jugador:
				id_enemigo = str(j.get("id"))
				nombre_enemigo = str(j.get("name"))

		var texto = "👥 Jugadores:\n"
		for j in jugadores:
			texto += "• " + str(j.get("name")) + " (" + str(j.get("status")) + ")\n"
		estado_label.text = texto


func get_player_name_from_url() -> String:
	var parts = url.split("playerName=")
	return parts[-1] if parts.size() > 1 else "Desconocido"


func _manejar_fin_partida(data: Dictionary):
	en_partida = false
	atacar_btn.disabled = true
	solicitar_btn.disabled = false
	vida_jugador = 100
	vida_enemigo = 100

	var ganador = data["data"].get("winnerId", "")
	var resultado = "🤝 Empate."
	if ganador == id_jugador:
		resultado = "🏆 ¡Victoria!"
	elif ganador != "":
		resultado = "💀 Derrota."

	estado_label.text = "🏁 Partida terminada: " + resultado
	print("🔚 Resultado:", resultado)
