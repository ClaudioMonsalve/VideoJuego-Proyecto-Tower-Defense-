extends Control

@onready var label_nombre: Label = $LabelNombre

func _on_InfoPanel_Jugar_pressed():
	var id = label_nombre.text 
	print("Cargar escena del reino:", id)
