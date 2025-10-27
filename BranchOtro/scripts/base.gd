extends Area3D
class_name Base

@onready var prog_bar: ProgressBar = $SubViewport/CanvasLayer/ProgressBar

@export var muni: int = 0
@export var maxhp: float = 30.0
var hp: float
var gd: int = 0


func _ready() -> void:
	hp = maxhp
	body_entered.connect(_on_body_entered)
	_update_bar()
	print("HP inicial:", hp)


func _on_body_entered(body: Node) -> void:
	if body is enemy:
		hp -= body.dmg
		hp = clamp(hp, 0, maxhp)
		_update_bar()

		# Espera un frame antes de liberar el enemigo
		body.get_parent().call_deferred("queue_free")

		if hp <= 0:
			print("Base destruida!")
			queue_free()


func _update_bar() -> void:
	if is_instance_valid(prog_bar):
		prog_bar.value = (hp / maxhp) * 100
