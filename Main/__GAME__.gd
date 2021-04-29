extends Control


onready var Starmap = $MainUI/HBox/Map_Status/StarMapContainer/Starmap
var Star = preload("res://Starmap/Star.tscn")

onready var StarsFolder = $MainUI/HBox/Map_Status/StarMapContainer/Starmap/StarsFolder
var StarsArray := []

onready var StarlanesFolder = $MainUI/HBox/Map_Status/StarMapContainer/Starmap/StarlanesFolder
var StarlanesArray := []

onready var Statuszeile = $MainUI/HBox/Map_Status/Statuszeile
onready var Hinweiszeile = $MainUI/HBox/Map_Status/Hinweiszeile

onready var TextLeft = $MainUI/HBox/TextLeft
onready var TextRight = $MainUI/HBox/TextRight

onready var Player = $Player




func _ready() -> void:
	for s in StarsFolder.get_children(): StarsArray.append(s)
	for l in StarlanesFolder.get_children(): StarlanesArray.append(l)
	
	G.connect("player_location_updated", Starmap, "_on_player_location_updated")
	G.connect("player_location_updated", TextLeft, "_on_player_location_updated")
	G.connect("player_location_updated", TextRight, "_on_player_location_updated")
	G.connect("player_location_updated", Statuszeile, "_on_player_location_updated")
	
	G.connect("star_clicked", self, "_on_star_clicked")
	G.connect("destination_set", Statuszeile, "_on_destination_set")
	G.connect("destination_set", TextLeft, "_on_destination_set")
	
	# set player to random star at beginning
	Player.status = G.IN_STATION
	Player.came_from = G.FROM_STATION
	Player.location = StarsArray[randi() % StarsArray.size()]
	G.emit_signal("player_location_updated", Player)
	G.emit_signal("destination_set", null, true)


func _process(_delta: float) -> void:
	if Player.status == G.IN_SPACE:
		
		if Input.is_action_just_pressed("dock_station"):
			pass
		
		if Input.is_action_just_pressed("jump_starlane"):
			pass
		
		if Input.is_action_just_pressed("navigation"):
			Player.modal = G.DOING_NAV
			TextRight.nav_options()
			
	if Player.status == G.IN_STARLANE:
		
		if Input.is_action_just_pressed("continue_travel"):
			pass
	
	if Player.status == G.IN_STATION:
		
		if Input.is_action_just_pressed("navigation"):
			Player.modal = G.DOING_NAV
			TextRight.nav_options(Player)
		
		if Input.is_action_just_pressed("exit_station"):
			pass
			
	if Player.modal > -1:
		if Input.is_action_just_pressed("ui_cancel"):
			Player.modal = -1
			TextRight.general_options(Player)
	
	if Player.modal == G.DOING_NAV:
		if Input.is_action_just_pressed("clear"):
			Player.destination = null
			G.emit_signal("destination_set", null)
			Player.modal = -1
			TextRight.general_options(Player)


func _on_star_clicked(star: Star) -> void:
	if Player.modal != G.DOING_NAV: return
	if Player.location == star:
		Hinweiszeile.display_message("You are already there.")
		return
	for lane in Player.location.lanes:
		if star == lane.get_other_side(Player.location):
			Player.destination = star
			Player.modal = -1
			TextRight.general_options(Player)
			G.emit_signal("destination_set", star)
			return
	Hinweiszeile.display_message("Only adjacent stars are valid destinations.")
