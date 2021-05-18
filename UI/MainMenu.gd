extends ColorRect


onready var NewGame = $M/VB/HB_TopRow/NewGame
onready var Back = $M/VB/HB_TopRow/BackToGame
onready var Quit = $M/VB/HB_TopRow/Quit

onready var SwitchLanguage = $M/VB/HB_BottomRow/SwitchLanguage
onready var Fullscreen = $M/VB/HB_BottomRow/Fullscreen

onready var S1 = $M/VB/GridContainer/Save_1
onready var I1 = $M/VB/GridContainer/Info_1
onready var L1 = $M/VB/GridContainer/Load_1
onready var D1 = $M/VB/GridContainer/Delete_1

onready var S2 = $M/VB/GridContainer/Save_2
onready var I2 = $M/VB/GridContainer/Info_2
onready var L2 = $M/VB/GridContainer/Load_2
onready var D2 = $M/VB/GridContainer/Delete_2

onready var S3 = $M/VB/GridContainer/Save_3
onready var I3 = $M/VB/GridContainer/Info_3
onready var L3 = $M/VB/GridContainer/Load_3
onready var D3 = $M/VB/GridContainer/Delete_3


func _ready() -> void:
	NewGame.text = T.get("MM_NewGame")
	Back.text = T.get("MM_Back")
	Quit.text = T.get("MM_Quit")
	SwitchLanguage.text = T.get("MM_SwitchLanguage")
	Fullscreen.text = T.get("MM_Fullscreen")
	S1.text = T.get("MM_Save")
	S2.text = T.get("MM_Save")
	S3.text = T.get("MM_Save")
	L1.text = T.get("MM_Load")
	L2.text = T.get("MM_Load")
	L3.text = T.get("MM_Load")


func update_savegame_display() -> void:
	var savegame_1 = check_saved_game(1)
	I1.text = savegame_1
	if savegame_1 == "---":
		L1.disabled = true
		D1.disabled = true
	else:
		L1.disabled = false
		D1.disabled = false
	
	var savegame_2 = check_saved_game(2)
	I2.text = savegame_2
	if savegame_2 == "---":
		L2.disabled = true
		D2.disabled = true
	else:
		L2.disabled = false
		D2.disabled = false
	
	var savegame_3 = check_saved_game(3)
	I3.text = savegame_3
	if savegame_3 == "---":
		L3.disabled = true
		D3.disabled = true
	else:
		L3.disabled = false
		D3.disabled = false


func check_saved_game(slot: int):
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	if file.file_exists(file_name):
		file.open(file_name, File.READ)
		var title = file.get_line()
		file.close()
		return title
	else:
		return "---"


func delete_save_game(slot: int) -> void:
	var dir = Directory.new()
	var file_name = "user://save-%d.save" % slot
	if !dir.file_exists(file_name):
		push_error("Tried to delete non-existing savegame '%s'." % file_name)
		return
	dir.remove(file_name)
	update_savegame_display()


func _on_opened() -> void:
	rect_position.x = 0
	update_savegame_display()


func _on_closed() -> void:
	rect_position.x = -rect_size.x * 1.1


func _on_NewGame_pressed() -> void:
	var _x = get_tree().reload_current_scene()


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_BackToGame_pressed() -> void:
	G.emit_signal("main_menu_closed")


func _on_Fullscreen_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen


func _on_Save_1_pressed() -> void:
	G.emit_signal("game_saved", 1)
	update_savegame_display()


func _on_Save_2_pressed() -> void:
	G.emit_signal("game_saved", 2)
	update_savegame_display()


func _on_Save_3_pressed() -> void:
	G.emit_signal("game_saved", 3)
	update_savegame_display()


func _on_Load_1_pressed() -> void:
	G.emit_signal("game_loaded", 1)
	G.emit_signal("main_menu_closed")


func _on_Load_2_pressed() -> void:
	G.emit_signal("game_loaded", 2)
	G.emit_signal("main_menu_closed")


func _on_Load_3_pressed() -> void:
	G.emit_signal("game_loaded", 3)
	G.emit_signal("main_menu_closed")



func _on_Delete_1_pressed() -> void:
	delete_save_game(1)


func _on_Delete_2_pressed() -> void:
	delete_save_game(2)


func _on_Delete_3_pressed() -> void:
	delete_save_game(3)


func _on_SwitchLanguage_pressed() -> void:
	G.emit_signal("language_toggled")
