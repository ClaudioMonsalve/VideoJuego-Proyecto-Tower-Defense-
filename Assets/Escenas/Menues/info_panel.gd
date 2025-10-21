extends Control

@onready var label_nombre: Label = $LabelNombre

func _on_InfoPanel_Jugar_pressed():
	var id = label_nombre.text  # <-- así obtienes el texto del Label
	print("Cargar escena del reino:", id)
	
	# Aquí cargas la escena correspondiente al reino
	# Suponiendo que el nombre del archivo coincide con el texto del Label
	# get_tree().change_scene_to_file("res://niveles/%s.tscn" % id)
