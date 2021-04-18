extends Control


onready var Starmap = $MainUI/HBoxContainer/StarMapContainer/Starmap

onready var StarsFolder = $MainUI/HBoxContainer/StarMapContainer/Starmap/StarsFolder
var StarsArray := []
onready var StarlanesFolder = $MainUI/HBoxContainer/StarMapContainer/Starmap/StarlanesFolder
var StarlanesArray := []

onready var Player = $Player

signal player_location_updated(location)


func _ready() -> void:
	for s in StarsFolder.get_children(): StarsArray.append(s)
	for l in StarlanesFolder.get_children(): StarlanesArray.append(l)
	
				# warning-ignore:return_value_discarded
	self.connect("player_location_updated", Starmap, "on_player_location_updated")
	
	# set player to random star at beginning
	Player.on_station = true
	Player.current_location = StarlanesArray[randi() % StarlanesArray.size()]
	print("Player is on " + Player.current_location.name)
	emit_signal("player_location_updated", Player.current_location)

