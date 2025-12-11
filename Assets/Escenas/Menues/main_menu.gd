extends Node2D

@onready var label1: Label = $Control/Label
@onready var label2: Label = $Control/Label2

@onready var button: Button = $Control/Button
@onready var button2: Button = $Control/Button2
@onready var button3: Button = $Control/Button3

@onready var tex: TextureRect = $Control/TextureRect


const MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_ = preload("res://Assets/Musica/Viking l Medieval Nordic Valhalla Throat Singing Meditative l 30 min l By Vadym Kuznietsov [sRuib4auqQw].mp3")
static var first_time := true
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready():
	# Música
	if MusicPlayer.stream != MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_:
		MusicPlayer.stream = MOTÖRHEAD___ACE_OF_SPADES__DRUMLESS_
		MusicPlayer.play()
		

	# Señales botones
	button.pressed.connect(Callable(self, "_on_button_pressed"))
	button2.pressed.connect(Callable(self, "_on_button_opciones"))
	button3.pressed.connect(Callable(self, "_on_button_multijugador"))
	
	if first_time:
		_animar_texture()
		_animar_labels()
		first_time = false
	else:
		
		print("Saltando animación")



# ----------------------------------------------------------
#     ANIMACIÓN DEL TEXTURERECT (NEGRO → COLOR AJUSTABLE)
# ----------------------------------------------------------
func _animar_texture():
	var original_color = tex.modulate           # color real del TextureRect
	tex.modulate = Color(0,0,0,1)               # empieza completamente negro

	var tween_tex = create_tween()
	tween_tex.tween_property(
		tex,
		"modulate",
		original_color,       
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)



# ----------------------------------------------------------
#     LABEL1 CAE DESDE ARRIBA → LUEGO LABEL2 APARECE
# ----------------------------------------------------------
func _animar_labels():
	var final_pos_label1 = label1.position

	# LABEL1 inicia arriba + invisible
	label1.position = final_pos_label1 + Vector2(0, -190)
	label1.modulate.a = 0

	# LABEL2 invisible al inicio
	label2.modulate.a = 0

	# ANIMACIÓN LABEL1
	var t1 = create_tween()

	# baja desde arriba
	t1.tween_property(label1, "position", final_pos_label1, 1.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	# aparece mientras baja
	t1.parallel().tween_property(label1, "modulate:a", 1.0, 0.9)

	# CUANDO TERMINA LABEL1 → aparece LABEL2
	t1.finished.connect(func():
		var t2 = create_tween()
		t2.tween_property(label2, "modulate:a", 1.0, 0.4)
	)
	

# ----------------------------------------------------------
#                  MÉTODOS DE LOS BOTONES
# ----------------------------------------------------------

func _on_button_pressed():
	ButtonSound.play()
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Mapa.tscn")


func _on_button_opciones():
	ButtonSound.play()   # o ButtonSound._play() si usas versión custom
	get_tree().change_scene_to_file("res://Assets/Escenas/Menues/Opciones.tscn")


func _on_button_multijugador():
	ButtonSound.play()
	get_tree().change_scene_to_file("res://Multijugador/Escenas/Multijugador.tscn")
