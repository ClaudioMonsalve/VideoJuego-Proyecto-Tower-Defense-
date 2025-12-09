extends Button

@onready var base: Base = $"../../Map/Base"

func _ready():
	pressed.connect(_enviar_ataque)

func _enviar_ataque():
	if base.muni >= 15: 
		base.muni = base.muni - 15


		# --- PAYLOAD DEL ATAQUE ---
		var payload := {
			"type": "attack",
			"player": Globals.my_player_name,
			"damage": 10
		}

		print("⚔️ [ATTACK] Enviando ataque:", payload)

		# --- ENVIAR USANDO NETWORK ---
		Network.send_game_data(payload)
