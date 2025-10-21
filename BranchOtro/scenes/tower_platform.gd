extends Node3D
class_name towerPlatform

var towerTest = preload("res://BranchOtro/scenes/test_tower.tscn")
var hasTower = false

func spawnTower(towerName):
	if !hasTower:
		var tower = getTower(towerName)
		self.add_child(tower)
		tower.position.y += 2
		hasTower = true

func getTower(towerName):
	match towerName:
		"test_tower":
			return towerTest.instantiate()
