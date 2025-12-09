extends Node

var nextLevel := ""
var levelName: String
var match_id: String = ""
var my_player_name: String = ""

# 🔥 AGREGA ESTO
var multiplayer_levels := [
	"res://Multijugador/nivel/Nivel1_1Multi.tscn",
	"res://Multijugador/nivel/Nivel2_1Multi.tscn"
]

var multiplayer_level_random := ""
