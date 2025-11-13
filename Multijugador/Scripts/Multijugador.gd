extends Control

# === NODOS UI ===
@onready var label: Label = $Panel/Label
@onready var lista: VBoxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var scroll: ScrollContainer = $Panel/ScrollContainer
@onready var btn_enviar: Button = $Panel/Enviar
@onready var btn_ver: Button = $Panel/Ver
@onready var volver: Button = $Volver
@onready var lobby: Panel = $Panel/Lobby

# === CONFIGURACIÓN DEL JUEGO ===
const MY_PLAYER_NAME := "RV"      # cambia esto en cada instancia
const MY_GAME_ID := "A"
const MY_GAME_KEY := "5NLQK3EMIZ"

# === VARIABLES ===
var ws := WebSocketPeer.new()
var conectado := false
var jugadores: Dictionary = {}      # otros jugadores
var invitaciones: Array = []
var posicion_menu := 0
var modo := 0
var match_id: String = ""
var match_status: String = "WAITING_PLAYERS"

# === READY ===
func _ready():
	lobby.visible = false
	_limpiar_todo()
	await get_tree().create_timer(0.2).timeout
	_conectar_servidor()

	scroll.visible = false
	label.text = "Modo Multijugador"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	btn_enviar.pressed.connect(_on_enviar_pressed)
	btn_ver.pressed.connect(_on_ver_pressed)
	volver.pressed.connect(_on_volver_pressed)

# === LOOP PRINCIPAL ===
func _process(_delta):
	if not conectado:
		return

	if ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		print("⚠️ Conexión cerrada, limpiando todo.")
		conectado = false
		_limpiar_todo()
		return

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

# === UTILIDADES ===
func _enviar(dic: Dictionary):
	if not conectado:
		return
	ws.send_text(JSON.stringify(dic))

func _crear_panel_estilo(color: Color = Color(0.94, 0.94, 0.94)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.2, 0.2, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(25)
	return style

func _crear_label(texto: String, size := 22) -> Label:
	var lbl := Label.new()
	lbl.text = texto
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl

func _crear_boton(texto, size := 18, ancho := 140, alto := 45, accion = null) -> Button:
	var btn := Button.new()
	btn.text = texto
	btn.custom_minimum_size = Vector2(ancho, alto)
	btn.add_theme_font_size_override("font_size", size)
	if accion != null:
		btn.pressed.connect(accion)
	return btn

# === LIMPIAR ESTADO GLOBAL ===
func _limpiar_todo():
	jugadores.clear()
	invitaciones.clear()
	scroll.visible = false
	btn_enviar.visible = true
	btn_ver.visible = true
	posicion_menu = 0
	modo = 0
	match_id = ""
	match_status = "WAITING_PLAYERS"
	for c in lista.get_children():
		c.queue_free()

# === MANEJAR MENSAJES ===
func _on_mensaje_recibido(msg: String):
	var data = JSON.parse_string(msg)
	if typeof(data) != TYPE_DICTIONARY or not data.has("event"):
		return

	var evento := str(data["event"])
	print("📩 Evento:", evento)

	match evento:
		# === CONEXIÓN / LOGIN ===
		"connected-to-server":
			print("✅ Conectado. Enviando login…")
			_enviar({"event": "login", "data": {"gameKey": MY_GAME_KEY}})

		"login":
			if data.get("status") == "OK":
				print("🧠 Login OK como:", MY_PLAYER_NAME)
				_enviar({"event": "online-players"})
			else:
				print("❌ Error de login:", data.get("msg", ""))

		# === LISTA DE JUGADORES ===
		"online-players":
			if data.get("status") == "OK":
				_actualizar_jugadores(data.get("data", []))

		"player-connected":
			_registrar_jugador(data.get("data", {}))

		"player-disconnected":
			_borrar_jugador(data.get("data", {}))

		"player-status-changed":
			_actualizar_estado(data.get("data", {}))

		# === MATCHMAKING ===
		"match-request-received":
			_recibir_invitacion(data)

		"send-match-request":
			if data.get("status") == "OK":
				match_id = data.get("data", {}).get("matchId", "")
				print("📨 Invitación enviada. Match ID:", match_id)
			else:
				print("❌ Error en send-match-request:", data.get("msg", ""))

		"accept-match":
			if data.get("status") == "OK":
				match_id = data.get("data", {}).get("matchId", "")
				print("🤝 Invitación aceptada. Match ID:", match_id)
				_enviar({"event": "connect-match", "data": {"matchId": match_id}})
			else:
				print("❌ Error en accept-match:", data.get("msg", ""))

		"match-accepted":
			match_id = data.get("data", {}).get("matchId", "")
			print("🎮 El otro jugador aceptó la invitación. Match ID:", match_id)
			_enviar({"event": "connect-match", "data": {"matchId": match_id}})

		"connect-match":
			if data.get("status") == "OK":
				match_id = data.get("data", {}).get("matchId", "")
				match_status = "CONNECTED"
				print("🔗 Match conectado:", match_id)
				_actualizar_lista()
			else:
				print("❌ Error en connect-match:", data.get("msg", ""))

		# === READY / LOBBY ===
		"players-ready":
			print("🟢 Ambos jugadores READY. Abriendo lobby…")
			match_status = "READY"
			_abrir_lobby()
			await get_tree().create_timer(0.3).timeout
			_enviar({"event": "ping-match", "data": {"matchId": match_id}})

		"ping-match":
			print("📶 Ping-match OK.")

		"match-start":
			print("🚀 Partida iniciada.")
			match_status = "PLAYING"

		# === CIERRE REMOTO (OTRO JUGADOR) ===
		"close-match":
			print("🚪 close-match recibido — rival salió.")
			await _finalizar_partida_por_rival()

		"game-ended":
			print("🏁 game-ended recibido — partida terminó.")
			await _finalizar_partida_por_rival()

		"receive-game-data":
			var payload = data.get("data", {}).get("payload", {})

			# ✅ CUANDO EL OTRO JUGADOR APRIETA "LISTO"
			if payload.has("ready"):
				var jugador = str(payload["player"])
				var listo = payload["ready"]

				print("🔄 Estado recibido:", jugador, "→", listo)

				_actualizar_ready_ui_de(jugador, listo)
				_evaluar_listos_y_arrancar()


			# ✅ CUANDO EL OTRO JUGADOR CIERRA LA PARTIDA
			if payload.has("close") and payload["close"] == true:
				print("🚪 rival envió close — cerrando partida por remoto.")
				await _finalizar_partida_por_rival()


		"finish-game":
			print("📤 Respuesta a finish-game:", data)

		# === REMATCH (si lo implementas después) ===
		"rematch-request":
			print("🔄 Rematch solicitado por el otro jugador.")

		_:
			print("ℹ️ Evento no manejado:", evento)

# === CUANDO EL RIVAL SALE DEL MATCH ===
func _finalizar_partida_por_rival():
	print("🧹 Cierre remoto REAL de la partida")

	match_id = ""
	match_status = "WAITING_PLAYERS"

	# Cerrar lobby
	if lobby.visible:
		lobby.visible = false
		var box: VBoxContainer = $Panel/Lobby/VBoxContainer
		for c in box.get_children():
			c.queue_free()

	# Cerrar WebSocket LOCAL para que el server me ponga AVAILABLE
	if ws and conectado:
		print("🔌 Cerrando WebSocket local por cierre remoto…")
		ws.close()
		conectado = false

	# Reconectar y pedir lista actualizada
	await get_tree().create_timer(0.5).timeout
	_conectar_servidor()

	await get_tree().create_timer(0.5).timeout
	if conectado:
		_enviar({"event": "online-players"})

	# Restaurar UI base
	scroll.visible = false
	btn_enviar.visible = true
	btn_ver.visible = true
	posicion_menu = 0
	label.text = "Modo Multijugador"

# === LOBBY ===
func _abrir_lobby():
	print("🪩 Mostrando lobby...")
	lobby.visible = true

	var box: VBoxContainer = $Panel/Lobby/VBoxContainer
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 25)

	for c in box.get_children():
		c.queue_free()

	var titulo = _crear_label("🏁 LOBBY DE PARTIDA", 28)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(titulo)

	var lista_final: Array = []
	lista_final.append({"name": MY_PLAYER_NAME, "id": "local"})
	for id in jugadores.keys():
		lista_final.append(jugadores[id])

	for jugador in lista_final:
		var jugador_nombre: String = str(jugador["name"])

		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_theme_constant_override("separation", 40)

		var game_name := ""
		if jugador_nombre.to_lower() == MY_PLAYER_NAME.to_lower():
			game_name = "Guardian del Palafito"    # local
		else:
			# buscar el juego desde el diccionario "jugadores"
			for pid in jugadores.keys():
				if jugadores[pid]["name"].to_lower() == jugador_nombre.to_lower():
					game_name = jugadores[pid].get("game_name", "Juego?")
					break

		# Si no estaba aún en el diccionario, lo cargamos desde el servidor
		if game_name == "" and jugador.has("game") and jugador["game"].has("name"):
			game_name = jugador["game"]["name"]

		var lbl = _crear_label("👤 " + jugador_nombre + "  |  🎮 " + game_name, 24)

		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fila.add_child(lbl)

		var btn_estado := _crear_boton("❌ No listo", 18, 160, 45)
		btn_estado.name = jugador_nombre
		btn_estado.toggle_mode = true

		if jugador_nombre.to_lower() == MY_PLAYER_NAME.to_lower():
			btn_estado.pressed.connect(func():
				# Cambiar localmente entre listo / no listo
				var nuevo_estado := btn_estado.text == "❌ No listo"

				if nuevo_estado:
					btn_estado.text = "✅ Listo"
				else:
					btn_estado.text = "❌ No listo"

				print("🔄 Cambiando estado:", MY_PLAYER_NAME, "→", btn_estado.text)

				# ENVIAR al rival
				_enviar({
					"event": "send-game-data",
					"data": {
						"matchId": match_id,
						"payload": {
							"ready": nuevo_estado,
							"player": MY_PLAYER_NAME
						}
					}
				})

				# Ver si ambos están listos
				_evaluar_listos_y_arrancar()
			)
		else:
			btn_estado.disabled = true


		fila.add_child(btn_estado)
		box.add_child(fila)

	print("🎯 Lobby listo con", lista_final.size(), "jugadores.")

func _actualizar_ready_ui_de(jugador_ready: String, listo: bool):
	var box: VBoxContainer = $Panel/Lobby/VBoxContainer

	for c in box.get_children():
		for sub in c.get_children():
			if sub is Button and sub.name.to_lower() == jugador_ready.to_lower():
				if listo:
					sub.text = "✅ Listo"
				else:
					sub.text = "❌ No listo"
				return

func _evaluar_listos_y_arrancar():
	var box: VBoxContainer = $Panel/Lobby/VBoxContainer

	var todos_listos := true

	for c in box.get_children():
		for sub in c.get_children():
			if sub is Button:
				if sub.text != "✅ Listo":
					todos_listos = false

	if todos_listos:
		print("🚀 Ambos jugadores listos — iniciando partida…")
		get_tree().change_scene_to_file("res://Assets/Escenas/Menues/control.tscn")


# === GESTIÓN DE JUGADORES ===
func _registrar_jugador(info: Dictionary):
	if info.has("id"):
		jugadores[info["id"]] = {
			"name": info.get("name", "Desconocido"),
			"status": info.get("status", "UNKNOWN")
		}
	_actualizar_lista()

func _borrar_jugador(info: Dictionary):
	if info.has("id"):
		jugadores.erase(info["id"])
	_actualizar_lista()

func _actualizar_estado(info: Dictionary):
	var pid = info.get("playerId")
	if pid and jugadores.has(pid):
		jugadores[pid]["status"] = info.get("playerStatus", "UNKNOWN")
	_actualizar_lista()

func _actualizar_jugadores(lista_servidor: Array):
	jugadores.clear()
	for j in lista_servidor:
		if j.get("name") == MY_PLAYER_NAME:
			continue
		if j.has("id") and j.get("status") != "DISCONNECTED":
			jugadores[str(j["id"])] = {
			"name": j.get("name", "Sin nombre"),
			"status": j.get("status", "UNKNOWN"),
			"game_name": j.get("game", {}).get("name", "Juego?")
		}
	_actualizar_lista()

# === BOTONES PRINCIPALES ===
func _on_enviar_pressed():
	scroll.visible = true
	btn_enviar.visible = false
	btn_ver.visible = false
	posicion_menu = 1
	label.text = "Jugadores conectados"
	_enviar({"event": "online-players"})

func _on_ver_pressed():
	scroll.visible = true
	btn_enviar.visible = false
	btn_ver.visible = false
	posicion_menu = 1
	modo = 2
	label.text = "Invitaciones recibidas"
	_actualizar_lista_invitaciones()

# === LISTA DE JUGADORES ===
func _actualizar_lista():
	for c in lista.get_children():
		c.queue_free()

	if jugadores.is_empty():
		lista.add_child(_crear_label("❌ No hay jugadores conectados", 22))
		return

	for id in jugadores.keys():
		var j = jugadores[id]

		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(600, 110)
		panel.add_theme_stylebox_override("panel", _crear_panel_estilo())

		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.add_theme_constant_override("separation", 60)

		var lbl := _crear_label(j["name"], 22)
		var center := CenterContainer.new()
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.add_child(lbl)
		fila.add_child(center)

		var estado = j.get("status", "AVAILABLE")
		var btn: Button
		if estado == "BUSY" or estado == "IN_MATCH":
			btn = _crear_boton("🕹️ Ocupado", 20)
			btn.disabled = true
		else:
			btn = _crear_boton("📨 Invitar", 20, 180, 49, func(): _enviar_invitacion(j))
		fila.add_child(btn)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_bottom", 16)
		margin.add_theme_constant_override("margin_left", 24)
		margin.add_theme_constant_override("margin_right", 24)
		margin.add_child(fila)
		panel.add_child(margin)
		lista.add_child(panel)

# === INVITACIONES ===
func _recibir_invitacion(data: Dictionary):
	var info = data.get("data", {})
	var pid = info.get("playerId", "")
	var mid = info.get("matchId", "")
	var nombre = jugadores.get(pid, {}).get("name", "Desconocido")
	invitaciones.append({"playerId": pid, "matchId": mid, "name": nombre})
	_actualizar_lista_invitaciones()

func _enviar_invitacion(jugador: Dictionary):
	for pid in jugadores.keys():
		if jugadores[pid] == jugador:
			print("⚔️ Enviando invitación a:", jugador["name"])
			_enviar({"event": "send-match-request", "data": {"playerId": pid}})
			return

func _aceptar_invitacion(info: Dictionary):
	print("✅ Aceptando invitación...")
	_enviar({"event": "accept-match"})

	var mid = info.get("matchId", "")
	invitaciones = invitaciones.filter(func(i):
		return i.get("matchId", "") != mid
	)

	_actualizar_lista_invitaciones()


func _rechazar_invitacion(info: Dictionary):
	_enviar({"event": "reject-match"})

	var mid = info.get("matchId", "")
	invitaciones = invitaciones.filter(func(i):
		return i.get("matchId", "") != mid
	)

	_actualizar_lista_invitaciones()


func _actualizar_lista_invitaciones():
	for c in lista.get_children():
		c.queue_free()

	if invitaciones.is_empty():
		lista.add_child(_crear_label("No hay invitaciones", 22))
		return

	for info in invitaciones:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(600, 120)
		panel.add_theme_stylebox_override("panel", _crear_panel_estilo())

		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.add_theme_constant_override("separation", 40)
		fila.add_child(_crear_label(info["name"], 24))
		fila.add_child(_crear_boton("✅ Aceptar", 18, 140, 45, func(): _aceptar_invitacion(info)))
		fila.add_child(_crear_boton("❌ Rechazar", 18, 140, 45, func(): _rechazar_invitacion(info)))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_bottom", 16)
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_child(fila)
		panel.add_child(margin)
		lista.add_child(panel)

# === VOLVER ===
func _on_volver_pressed():
	if lobby.visible:
		print("🚪 Saliendo del lobby manualmente…")

		# 1. terminar partida local (finish-game + quit-match + aviso close)
		await _salir_partida_completa()

		# 2. cerrar WebSocket local
		if ws and conectado:
			print("🔌 Cerrando WebSocket local (VOLVER)…")
			ws.close()
			conectado = false

		# 3. reconectar
		await get_tree().create_timer(0.5).timeout
		_conectar_servidor()

		# 4. pedir lista nueva
		await get_tree().create_timer(0.5).timeout
		if conectado:
			_enviar({"event": "online-players"})

		# 5. limpiar UI
		_finalizar_match_desde_servidor()
		return

	# === VOLVER NORMAL ===
	if posicion_menu == 0:
		if ws and conectado:
			ws.close()
		_limpiar_todo()
		get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Main menu.tscn")
	else:
		scroll.visible = false
		btn_enviar.visible = true
		btn_ver.visible = true
		posicion_menu = 0
		label.text = "Modo Multijugador"

# === TERMINAR PARTIDA LOCAL (finish + quit + aviso close) ===
func _salir_partida_completa():
	if match_id == "":
		return

	print("🏁 [EXIT] Enviando finish-game…")
	_enviar({
		"event": "finish-game",
		"data": {"matchId": match_id, "winner": MY_PLAYER_NAME}
	})
	await get_tree().create_timer(0.3).timeout

	print("📤 [EXIT] Enviando quit-match…")
	_enviar({
		"event": "quit-match",
		"data": {"matchId": match_id}
	})
	await get_tree().create_timer(0.2).timeout

	print("📡 [EXIT] Enviando payload close:true para rival…")
	_enviar({
		"event": "send-game-data",
		"data": {"matchId": match_id, "payload": {"close": true}}
	})
	await get_tree().create_timer(0.2).timeout

# === LIMPIEZA GENERAL ===
func _finalizar_match_desde_servidor():
	print("🧹 Limpieza general de partida…")

	match_id = ""
	match_status = "WAITING_PLAYERS"

	if lobby.visible:
		lobby.visible = false
		var box: VBoxContainer = $Panel/Lobby/VBoxContainer
		for c in box.get_children():
			c.queue_free()

	scroll.visible = false
	btn_enviar.visible = true
	btn_ver.visible = true
	posicion_menu = 0
	label.text = "Modo Multijugador"

	if conectado:
		_enviar({"event": "online-players"})
