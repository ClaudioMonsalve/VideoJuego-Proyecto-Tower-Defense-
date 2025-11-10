extends Control

# === NODOS UI ===
@onready var label: Label = $Panel/Label
@onready var lista: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var scroll: ScrollContainer = $Panel/ScrollContainer
@onready var btn_enviar: Button = $Panel/Enviar
@onready var btn_ver: Button = $Panel/Ver
@onready var volver: Button = $Volver

# === CONFIGURACIÓN DEL JUEGO ===
const MY_PLAYER_NAME := "ene0"        # Nombre del jugador local
const MY_GAME_ID := "B"                # ID del juego
const MY_GAME_KEY := "V832E2HO8X"      # Clave del juego (asignada por el profe)

# === VARIABLES ===
var ws := WebSocketPeer.new()
var conectado := false
var jugadores: Dictionary = {}         # playerId -> {name, status, game_name}
var invitaciones: Array = []           # invitaciones recibidas
var posicion_menu := 0
var modo := 0                          # 0=menu, 1=jugadores, 2=invitaciones

# === READY ===
func _ready():
	_conectar_servidor()
	scroll.visible = false
	label.text = "Modo Multijugador"
	btn_enviar.pressed.connect(_on_enviar_pressed)
	btn_ver.pressed.connect(_on_ver_pressed)
	volver.pressed.connect(_on_volver_pressed)

# === LOOP PRINCIPAL ===
func _process(_delta):
	if conectado:
		ws.poll()
		while ws.get_available_packet_count() > 0:
			var msg := ws.get_packet().get_string_from_utf8()
			print("📩 Recibido:", msg)
			_on_mensaje_recibido(msg)

# === CONEXIÓN ===
func _conectar_servidor():
	var url := "ws://cross-game-ucn.martux.cl:4010/?gameId=%s&playerName=%s" % [MY_GAME_ID, MY_PLAYER_NAME]
	print("🌐 Conectando a:", url)
	var err := ws.connect_to_url(url)
	if err == OK:
		conectado = true
	await get_tree().create_timer(0.4).timeout

# === MANEJAR MENSAJES ===
func _on_mensaje_recibido(msg: String):
	var data: Variant = JSON.parse_string(msg)
	if data == null:
		return
	if not data.has("event"):
		return

	var evento: String = str(data["event"])
	print("🧩 EVENTO DETECTADO:", evento)

	match evento:
		"connected-to-server":
			print("✅ Conectado. Enviando login...")
			var payload = {"event": "login", "data": {"gameKey": MY_GAME_KEY}}
			ws.send_text(JSON.stringify(payload))

		"login":
			if data.has("status") and data["status"] == "OK":
				print("🧠 Sesión iniciada como:", MY_PLAYER_NAME)

		"online-players":
			if data.has("data"):
				_actualizar_jugadores(data["data"])

		"player-connected":
			if data.has("data"):
				var info = data["data"]
				if info.has("id"):
					jugadores[info["id"]] = {
						"name": info.get("name", "Desconocido"),
						"status": info.get("status", "UNKNOWN"),
						"game_name": info.get("game", {}).get("name", "???")
					}
				_actualizar_lista()

		"player-disconnected":
			if data.has("data") and data["data"].has("id"):
				jugadores.erase(data["data"]["id"])
			_actualizar_lista()

		"player-status-changed":
			var info = data.get("data", {})
			if info.has("playerId") and jugadores.has(info["playerId"]):
				jugadores[info["playerId"]]["status"] = info.get("playerStatus", "UNKNOWN")
			_actualizar_lista()

		"send-match-request":
			if data.get("status", "") == "OK":
				print("📨 Invitación enviada:", data.get("msg", ""))
			else:
				print("⚠️ Error al enviar:", data.get("msg", ""))

		# === 📥 INVITACIÓN RECIBIDA ===
		"match-request-received":
			if data.has("data"):
				var info = data["data"]
				var pid: String = info.get("playerId", "")
				var mid: String = info.get("matchId", "")
				
				# 🧩 Intentar extraer el nombre desde el mensaje
				var nombre: String = "Desconocido"
				if data.has("msg"):
					var msg_text: String = str(data["msg"])
					var inicio := msg_text.find("'")
					var fin := msg_text.rfind("'")
					if inicio != -1 and fin > inicio:
						nombre = msg_text.substr(inicio + 1, fin - inicio - 1)
				
				# 🧩 Si no se encontró, intentar con la lista de jugadores
				if jugadores.has(pid) and jugadores[pid].has("name"):
					nombre = jugadores[pid]["name"]
				
				print("💌 Invitación recibida de:", nombre, " (ID:", pid, ")")
				
				invitaciones.append({"playerId": pid, "matchId": mid, "name": nombre})
				if modo == 2:
					_actualizar_lista_invitaciones()



		# === 🟢 PARTIDA ACEPTADA ===
		"match-accepted":
			print("🎮 Partida aceptada:", data.get("msg", ""))

		# === 🔴 PARTIDA RECHAZADA ===
		"match-rejected":
			print("🚫 Invitación rechazada:", data.get("msg", ""))

		# === 🚫 PARTIDA CANCELADA ===
		"match-canceled-by-sender":
			if data.has("data"):
				var pid = data["data"].get("playerId", "")
				var nombre = "Desconocido"
				if jugadores.has(pid):
					nombre = jugadores[pid].get("name", "Desconocido")
				print("❌ Solicitud cancelada por:", nombre)
				invitaciones = invitaciones.filter(func(i): return i.get("playerId", "") != pid)
				_actualizar_lista_invitaciones()


		_:
			print("ℹ️ Evento no manejado:", evento)

# === BOTONES ===
func _on_enviar_pressed():
	label.text = "Jugadores conectados"
	var payload = {"event": "online-players"}
	ws.send_text(JSON.stringify(payload))
	btn_enviar.visible = false
	btn_ver.visible = false
	scroll.visible = true
	posicion_menu = 1


func _on_ver_pressed():
	posicion_menu = 1
	btn_enviar.visible = false
	btn_ver.visible = false
	scroll.visible = true
	modo = 2
	label.text = "Invitaciones recibidas"
	_actualizar_lista_invitaciones()

# === ACTUALIZAR LISTAS ===
func _actualizar_jugadores(lista_servidor: Array):
	jugadores.clear()
	for j in lista_servidor:
		if not j.has("id"):
			continue
		var id = str(j["id"])
		jugadores[id] = {
			"name": j.get("name", "Sin nombre"),
			"status": j.get("status", "UNKNOWN"),
			"game_name": j.get("game", {}).get("name", "???")
		}
	_actualizar_lista()

#Actualizar Lista
func _actualizar_lista():
	for c in lista.get_children():
		c.queue_free()

	if jugadores.is_empty():
		var lbl := Label.new()
		lbl.text = "❌ No hay jugadores conectados"
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lista.add_child(lbl)
		return

	for id in jugadores.keys():
		var j = jugadores[id]
		if j.get("name", "") == MY_PLAYER_NAME:
			continue

		# === Panel principal del jugador ===
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(600, 110)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# 🎨 Estilo visual (borde + color + esquinas redondeadas)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.95, 0.95, 0.95)
		style.border_color = Color(0.25, 0.25, 0.25)
		style.set_border_width_all(2)
		style.set_corner_radius_all(25)
		panel.add_theme_stylebox_override("panel", style)

		# === Margen interior para respiración visual ===
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_bottom", 16)
		margin.add_theme_constant_override("margin_left", 24)
		margin.add_theme_constant_override("margin_right", 40)
		margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# === Fila centrada con nombre + botón ===
		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
		fila.add_theme_constant_override("separation", 60)
		fila.add_theme_constant_override("margin_right", 40)

		# === Etiqueta del jugador ===
		var lbl := Label.new()
		lbl.text = "%s  🎮  (%s)" % [j.get("name", "Desconocido"), j.get("game_name", "?")]
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(0, 0, 0))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(lbl)

		# === Botón de acción ===
		var btn := Button.new()
		var estado: String = j.get("status", "AVAILABLE")
		btn.custom_minimum_size = Vector2(180, 49)
		btn.add_theme_font_size_override("font_size", 20)

		if estado == "BUSY":
			btn.text = "🕹️ Ocupado"
			btn.disabled = true
		else:
			btn.text = "📨 Invitar"
			btn.disabled = false
			btn.pressed.connect(func(): _enviar_invitacion(id, j))

		fila.add_child(btn)

		# === Ensamblaje final ===
		margin.add_child(fila)
		panel.add_child(margin)
		lista.add_child(panel)



# === LISTA DE INVITACIONES ===
func _actualizar_lista_invitaciones():
	for c in lista.get_children():
		c.queue_free()

	if invitaciones.is_empty():
		var lbl := Label.new()
		lbl.text = "❌ No tienes invitaciones recibidas"
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lista.add_child(lbl)
		return

	for info in invitaciones:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(600, 120)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# 🎨 Estilo visual mejorado
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.94, 0.94, 0.94)  # fondo gris claro
		style.border_color = Color(0.2, 0.2, 0.2)  # borde oscuro
		style.set_border_width_all(2)
		style.set_corner_radius_all(25)
		panel.add_theme_stylebox_override("panel", style)

		# === Contenedor centrado vertical/horizontal ===
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_bottom", 16)
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.size_flags_vertical = Control.SIZE_EXPAND_FILL
		fila.add_theme_constant_override("separation", 40)

		var lbl := Label.new()
		lbl.text = info["name"]
		lbl.add_theme_font_size_override("font_size", 24)
		lbl.add_theme_color_override("font_color", Color(0, 0, 0))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(lbl)

		var btn_aceptar := Button.new()
		btn_aceptar.text = "✅ Aceptar"
		btn_aceptar.custom_minimum_size = Vector2(140, 45)
		btn_aceptar.add_theme_font_size_override("font_size", 18)
		btn_aceptar.pressed.connect(func(): _aceptar_invitacion(info))
		fila.add_child(btn_aceptar)

		var btn_rechazar := Button.new()
		btn_rechazar.text = "❌ Rechazar"
		btn_rechazar.custom_minimum_size = Vector2(140, 45)
		btn_rechazar.add_theme_font_size_override("font_size", 18)
		btn_rechazar.pressed.connect(func(): _rechazar_invitacion(info))
		fila.add_child(btn_rechazar)

		margin.add_child(fila)
		panel.add_child(margin)
		lista.add_child(panel)


# === INVITACIONES ===
func _enviar_invitacion(id: String, jugador: Dictionary):
	print("⚔️ Enviando invitación a:", jugador.get("name", "?"))
	var payload = {"event": "send-match-request", "data": {"playerId": id}}
	ws.send_text(JSON.stringify(payload))

func _aceptar_invitacion(info: Dictionary):
	print("✅ Aceptando invitación de", info.get("name", "?"))
	var payload = {"event": "accept-match"}
	ws.send_text(JSON.stringify(payload))


func _rechazar_invitacion(info: Dictionary):
	print("❌ Rechazando invitación de", info.get("name", "?"))
	var payload = {"event": "reject-match"}
	ws.send_text(JSON.stringify(payload))
	invitaciones.erase(info)
	_actualizar_lista_invitaciones()


# === VOLVER ===
func _on_volver_pressed():
	if posicion_menu == 0:
		ws.close()
		get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
	else:
		scroll.visible = false
		btn_enviar.visible = true
		btn_ver.visible = true
		posicion_menu = 0
		label.text = "Modo Multijugador"
