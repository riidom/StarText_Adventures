extends Node2D
class_name Player


var status = G.IN.STATION
var came_from = G.FROM.GAME_START
var modal = G.DOING.NO_MODAL

var origin: Star = null
var destination: Star = null
var location = null
var location_type = "" # if "Star": origin and destination are null; if "Lane": location is null


func _ready() -> void:
	pass


func load_data(d, stars) -> void:
	status = d.p.status
	came_from = d.p.came_from
	modal = d.p.modal
	
	if d.p.origin_name == "": origin = null
	else: origin = get_star_node_by_name(d.p.origin_name, stars)
	
	if d.p.destination_name == "": destination = null
	else: destination = get_star_node_by_name(d.p.destination_name, stars)
	
	if d.p.location_name == "": location = null
	else: location = get_star_node_by_name(d.p.location_name, stars)
	
	location_type = d.p.location_type


func get_star_node_by_name(name: String, stars: Array):
	for s in stars:
		if s.name == name: return s
	push_error("No star named %s inside array of 'StarsFolder'." % name)


func update_location(s1: Star, s2: Star = null) -> void:
	if !s2: # Player is on a star
		origin = null
		destination = null
		location = s1
		location_type = "Star"
	else:
		origin = s1
		destination = s2
		location = null
		location_type = "Lane"

