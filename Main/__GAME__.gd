extends Control

onready var MainMenu = $MainMenu

onready var Starmap = $MainUI/HBox/Map_Status/StarMapContainer/Starmap
var Star = preload("res://Starmap/Star.tscn")

onready var StarsFolder = $MainUI/HBox/Map_Status/StarMapContainer/Starmap/StarsFolder
var StarsArray := []

onready var MapHighlighter = $MainUI/HBox/Map_Status/StarMapContainer/MapHighlighter

onready var Statuszeile = $MainUI/HBox/Map_Status/Statuszeile
onready var Hinweiszeile = $MainUI/HBox/Map_Status/Hinweiszeile

onready var InTextButtons = $MainUI/HBox/TextLeft/Scroll/M/VBox/Grid
onready var TextLeft = $MainUI/HBox/TextLeft

onready var Player = $Player


func _ready() -> void:
	Starmap.custom_ready()
	for s in StarsFolder.get_children(): StarsArray.append(s)
	
	G.connect("main_menu_opened", MainMenu, "_on_opened")
	G.connect("main_menu_closed", MainMenu, "_on_closed")
	G.connect("main_menu_closed", self, "_on_main_menu_closed")
	
	G.connect("game_saved", self, "_on_game_saved")
	G.connect("game_loaded", self, "_on_game_loaded")
	G.connect("language_toggled", self, "_on_language_toggled")
	
	G.connect("action_triggered", self, "_on_action_triggered")
	
	G.connect("player_location_updated", Starmap, "_on_player_location_updated")
	G.connect("player_location_updated", TextLeft, "_on_player_location_updated")
	G.connect("player_location_updated", Statuszeile, "_on_player_location_updated")
	
	G.connect("star_clicked", self, "_on_star_clicked")
	G.connect("destination_set", Starmap, "_on_destination_set")
	G.connect("destination_set", Statuszeile, "_on_destination_set")
	G.connect("destination_set", TextLeft, "_on_destination_set")
	
	G.connect("nav_started", self, "_on_nav_started")
	G.connect("nav_started", Hinweiszeile, "_on_nav_started")
	G.connect("nav_finished", self, "_on_nav_finished")
	
	# hide menu
	MainMenu.rect_position.x = -MainMenu.rect_size.x * 1.1
	
	# various loads and inits
	G.load_settings()
	
	# set player to random star at beginning
	Player.update_location(StarsArray[randi() % StarsArray.size()])
	G.emit_signal("player_location_updated", Player)
	G.emit_signal("destination_set", null, true)
	
	InTextButtons.update_buttons(Player)
	

func _unhandled_key_input(key: InputEventKey) -> void:
	if key.pressed and !key.echo and key.scancode == KEY_ESCAPE:
		
		if Player.status.modal == G.DOING.NO_MODAL:
			Player.status.modal = G.DOING.MAIN_MENU
			G.emit_signal("main_menu_opened")
		
		elif Player.status.modal == G.DOING.NAV:
			Player.status.modal = G.DOING.NO_MODAL
			G.emit_signal("nav_finished")
		
		elif Player.status.modal == G.DOING.MAIN_MENU:
			Player.status.modal = G.DOING.NO_MODAL
			G.emit_signal("main_menu_closed")
		
		InTextButtons.update_buttons(Player)


func _on_action_triggered(meta: String) -> void:
	print("in main_game: %s" % meta)
	
	if meta == "I_E_Engines":
		Player.status.current = G.IN.SPACE
		Player.status.came_from = G.FROM.STATION
		G.emit_signal("player_location_updated", Player)
		
	elif meta == "I_N_Nav":
		Player.status.modal = G.DOING.NAV
		G.emit_signal("nav_started")
		
	elif meta == "I_W_Wait":
		Player.status.current = G.IN.SPACE
		Player.status.came_from = G.FROM.STARLANE
		Player.update_location(Player.pos.to)
		G.emit_signal("destination_set", null, true)
		G.emit_signal("player_location_updated", Player)
		
	elif meta == "I_D_Dock":
#		Player.status.current = G.IN.STATION
#		Player.status.came_from = G.FROM.SPACE
#		G.emit_signal("player_location_updated", Player)
		Player.status.modal = G.DOING.IN_DIALOG
		Player.dialog_type = "DockingStation"
		Dialogs[Player.dialog_type].init(Player.pos.at.name)
		G.emit_signal("action_triggered", "D_entry")
		
	elif meta == "I_J_Jump":
		Player.status.current = G.IN.STARLANE
		Player.status.came_from = G.FROM.SPACE
		Player.update_location(Player.pos.at, Player.pos.to)
		G.emit_signal("player_location_updated", Player)
		
	elif meta == "I_C_ClearNav":
		Player.pos.to = null
		Player.status.modal = G.DOING.NO_MODAL
		G.emit_signal("destination_set", null)
		G.emit_signal("nav_finished")
	
	elif meta == "I_ESC_Menu":
		Player.status.modal = G.DOING.MAIN_MENU
		G.emit_signal("main_menu_opened")
	
	elif meta == "I_ESC_Cancel":
		if Player.status.modal == G.DOING.NAV:
			Player.status.modal = G.DOING.NO_MODAL
			G.emit_signal("nav_finished")
		else:
			push_error("_on_action_triggered(), meta==\"I_ESC_Cancel\": neuen Modal vergessen?")
	
	elif meta.begins_with("D_"):
		TextLeft.print_dialog(Player, meta)
		Dialogs[Player.dialog_type].eval_step(meta)
		Player.dialog_current_step = meta
	
	InTextButtons.update_buttons(Player)


func _on_star_clicked(star: Star) -> void:
	if Player.status.modal == G.DOING.NAV:
		
		if Player.pos.type != "Star":
			Hinweiszeile.display_message(T.get("A_nav_on_lane"))
			return
		if Player.pos.at == star:
			Hinweiszeile.display_message(T.get("A_destination_to_current"))
			return
		for adj in Player.pos.at.adj_stars:
			if star == adj:
				Player.pos.to = star
				Player.status.modal = G.DOING.NO_MODAL
				G.emit_signal("destination_set", star)
				G.emit_signal("nav_finished")
				InTextButtons.update_buttons(Player)
				return
		Hinweiszeile.display_message(T.get("A_only_adjacent"))


func _on_nav_started() -> void:
	MapHighlighter.visible = true
	
	
func _on_nav_finished() -> void:
	MapHighlighter.visible = false

	
func _on_main_menu_closed() -> void:
	Player.status.modal = G.DOING.NO_MODAL
	InTextButtons.update_buttons(Player)


func _on_game_saved(slot: int) -> void:
	G.save_game(self, slot)


func _on_game_loaded(slot: int):
	var save_data = G.load_game(slot)
	Starmap.custom_ready(save_data)
	Player.load_data(save_data, StarsFolder.get_children())
	TextLeft.replace_text(save_data.t.text)
	G.emit_signal("player_location_updated", Player, true)
	G.emit_signal("destination_set", Player.pos.to, true)
	Hinweiszeile.display_message(T.get("A_game_loaded", {slot = slot}))


func _on_language_toggled() -> void:
	G.settings.lang = "de" if G.settings.lang == "en" else "en"
	G.save_settings()
