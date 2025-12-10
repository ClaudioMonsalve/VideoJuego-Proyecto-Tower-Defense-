extends Label

func mostrar_resultado(gane: bool) -> void:
	if gane:
		_mostrar_victoria()
	else:
		_mostrar_derrota()


func _mostrar_victoria() -> void:
	text = "🏆 ¡VICTORIA!"
	self.add_theme_color_override("font_color", Color(0.1, 1.0, 0.1))  # Verde


func _mostrar_derrota() -> void:
	text = "💀 DERROTA"
	self.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))  # Rojo
