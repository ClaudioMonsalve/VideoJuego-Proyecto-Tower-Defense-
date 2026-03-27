extends Node3D
class_name towerPlatform

var towerTest = preload("res://BranchOtro/scenes/test_tower.tscn")
var hasTower = false

@onready var area: Area3D = $Area3D
@onready var camera: Camera3D = $"../../Player/Camera3D"
@onready var tower_card: PanelContainer = $"../../Player/HBoxContainer/TowerCard"



func _ready():
	pass

# ---------------------
# Spawn de torre
# ---------------------
func spawnTower(tower):
	if not hasTower:
		add_child(tower)
		tower.position.y += 2
		hasTower = true
		print("Torre spawneada!")
