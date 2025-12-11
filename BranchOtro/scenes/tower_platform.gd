extends Node3D
class_name towerPlatform

var towerTest = preload("res://BranchOtro/scenes/test_tower.tscn")
var currentTower: tower

@onready var area: Area3D = $Area3D
@onready var camera: Camera3D = $"../../Player/Camera3D"
@onready var tower_card: PanelContainer = $"../../Player/HBoxContainer/TowerCard"


# ---------------------
# Spawn de torre
# ---------------------
func spawnTower(newtower):
	if not currentTower:
		add_child(newtower)
		newtower.position.y += 2
		currentTower = newtower
		print("Torre spawneada!")
