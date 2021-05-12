extends ColorRect


func _on_opened() -> void:
	rect_position.x = 0


func _on_closed() -> void:
	rect_position.x = -rect_size.x


func _on_NewGame_pressed() -> void:
	pass


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_BackToGame_pressed() -> void:
	G.emit_signal("main_menu_closed")


func _on_Fullscreen_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen


func _on_Save_1_pressed() -> void:
	G.emit_signal("game_saved", 1)


func _on_Load_1_pressed() -> void:
	G.emit_signal("game_loaded", 1)
