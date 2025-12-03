extends RigidBody3D
class_name enemy

@onready var pathfollow: PathFollow3D = get_parent()
@onready var progBar: ProgressBar = $"../SubViewport/CanvasLayer/ProgressBar"
@onready var animationPlayer: AnimationPlayer = $"../AnimationPlayer"
@onready var collider = $CollisionShape3D
@onready var meshOrSprite = $MeshInstance3D
@onready var barSprite = $Sprite3D
@onready var rigidbody = $RigidBody3D

@export var worth: int = 4
@export var maxhp: float = 10.0
@export var speed: float = 10.0
@export var dmg: int = 1
var radius: float = 3.0

var died = false
var hp: float
var base: Area3D
var paused: bool = false

func _ready() -> void:
	hp = maxhp
	hp = clamp(hp,0,maxhp)
	var offset = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
	position += offset

func linkBase(baseobj: Area3D):
	base = baseobj	

func ouch(damage: float):
	hp -= damage
	progBar.value = (hp / maxhp) * 100
	if hp <= 0:
		if base and !died:
			base.muni += worth
			died = true
			paused = true
			if collider:
				collider.queue_free()
			if meshOrSprite:
				meshOrSprite.queue_free()
			if barSprite:
				barSprite.queue_free()
			animationPlayer.play("money")
			await animationPlayer.animation_finished
		get_parent().queue_free()

func _process(delta: float) -> void:
	if not paused and is_instance_valid(pathfollow):
		pathfollow.progress += delta * speed

func pausar():
	paused = true

func reanudar():
	paused = false
