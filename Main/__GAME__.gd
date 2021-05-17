extends Control

onready var MainMenu = $MainMenu

onready var Starmap = $MainUI/HBox/Map_Status/StarMapContainer/Starmap
var Star = preload("res://Starmap/Star.tscn")

onready var StarsFolder = $MainUI/HBox/Map_Status/StarMapContainer/Starmap/StarsFolder
var StarsArray := []

onready var Statuszeile = $MainUI/HBox/Map_Status/Statuszeile
onready var Hinweiszeile = $MainUI/HBox/Map_Status/Hinweiszeile

onready var TextLeft = $MainUI/HBox/TextLeft
onready var TextRight = $MainUI/HBox/TextRight

onready var Player = $Player


func _ready() -> void:
	Starmap.custom_ready()
	for s in StarsFolder.get_children(): StarsArray.append(s)
	
	G.connect("main_menu_opened", MainMenu, "_on_opened")
	G.connect("main_menu_closed", MainMenu, "_on_closed")
	G.connect("main_menu_closed", self, "_on_main_menu_closed")
	
	G.connect("game_saved", self, "_on_game_saved")
	G.connect("game_loaded", self, "_on_game_loaded")
	G.connect("game_loaded", Hinweiszeile, "_on_game_loaded")
	G.connect("language_toggled", self, "_on_language_toggled")
	
	G.connect("player_location_updated", Starmap, "_on_player_location_updated")
	G.connect("player_location_updated", TextLeft, "_on_player_location_updated")
	G.connect("player_location_updated", TextRight, "_on_player_location_updated")
	G.connect("player_location_updated", Statuszeile, "_on_player_location_updated")
	
	G.connect("star_clicked", self, "_on_star_clicked")
	G.connect("destination_set", Starmap, "_on_destination_set")
	G.connect("destination_set", Statuszeile, "_on_destination_set")
	G.connect("destination_set", TextLeft, "_on_destination_set")
	
	# hide menu
	MainMenu.rect_position.x = -MainMenu.rect_size.x
	
	# load settings and init strings
	G.load_settings()
	#T.init()
	
	# set player to random star at beginning
	Player.update_location(StarsArray[randi() % StarsArray.size()])
	G.emit_signal("player_location_updated", Player)
	G.emit_signal("destination_set", null, true)


func _process(_delta: float) -> void:
	if Player.status == G.IN.SPACE:
		
		if Input.is_action_just_pressed("dock_station"):
			Player.status = G.IN.STATION
			Player.came_from = G.FROM.SPACE
			G.emit_signal("player_location_updated", Player)
			TextRight.general_options(Player)
		
		if Input.is_action_just_pressed("jump_starlane"):
			Player.status = G.IN.STARLANE
			Player.came_from = G.FROM.SPACE
			Player.update_location(Player.location, Player.destination)
			G.emit_signal("player_location_updated", Player)
			TextRight.general_options(Player)
			
		if Input.is_action_just_pressed("navigation"):
			Player.modal = G.DOING.NAV
			TextRight.nav_options(Player)
			
	if Player.status == G.IN.STARLANE:
		
		if Input.is_action_just_pressed("continue_travel"):
			Player.status = G.IN.SPACE
			Player.came_from = G.FROM.STARLANE
			Player.update_location(Player.destination)
			Player.destination = null
			G.emit_signal("destination_set", null, true)
			G.emit_signal("player_location_updated", Player)
			TextRight.general_options(Player)
	
	if Player.status == G.IN.STATION:
		
		if Input.is_action_just_pressed("navigation"):
			Player.modal = G.DOING.NAV
			TextRight.nav_options(Player)
		
		if Input.is_action_just_pressed("exit_station"):
			Player.status = G.IN.SPACE
			Player.came_from = G.FROM.STATION
			G.emit_signal("player_location_updated", Player)
			TextRight.general_options(Player)
			
	if Player.modal == G.DOING.NO_MODAL:
		
		if Input.is_action_just_pressed("ui_cancel"):
			Player.modal = G.DOING.MAIN_MENU
			G.emit_signal("main_menu_opened")
			
	else:
		
		if Input.is_action_just_pressed("ui_cancel"):
			if Player.modal == G.DOING.NAV:
				TextRight.general_options(Player)
			elif Player.modal == G.DOING.MAIN_MENU:
				G.emit_signal("main_menu_closed")
			Player.modal = G.DOING.NO_MODAL
	
	if Player.modal == G.DOING.NAV:
		
		if Input.is_action_just_pressed("clear"):
			Player.destination = null
			G.emit_signal("destination_set", null)
			Player.modal = G.DOING.NO_MODAL
			TextRight.general_options(Player)


func _on_star_clicked(star: Star) -> void:
	if Player.modal == G.DOING.NAV:
		
		if Player.location_type != "Star":
			Hinweiszeile.display_message("You can't use the navigation computer while on a lane.")
			return
		if Player.location == star:
			Hinweiszeile.display_message("You are already there.")
			return
		for adj in Player.location.adj_stars:
			if star == adj:
				Player.destination = star
				Player.modal = -1
				TextRight.general_options(Player)
				G.emit_signal("destination_set", star)
				return
		Hinweiszeile.display_message("Only adjacent stars are valid destinations.")


func _on_main_menu_closed() -> void:
	Player.modal = G.DOING.NO_MODAL


func _on_game_saved(slot: int) -> void:
	G.save_game(self, slot)


func _on_game_loaded(slot: int):
	var save_data = G.load_game(slot)
	Starmap.custom_ready(save_data)
	Player.load_data(save_data, StarsFolder.get_children())
	TextLeft.replace_text(save_data.t.text)
	G.emit_signal("player_location_updated", Player, true)
	G.emit_signal("destination_set", Player.destination, true)


func _on_language_toggled() -> void:
	if G.settings.lang == "de":
		G.settings.lang = "en"
	else:
		G.settings.lang = "de"
	G.save_settings()
