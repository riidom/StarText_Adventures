extends Node2D
class_name Player


var status = G.IN.STATION
var came_from = G.FROM.GAME_START
var modal = G.DOING.NO_MODAL

var origin: Star = null
var destination: Star = null
var location = null setget fuckyou
var location_type = "" # if "Star": origin and destination are null; if "Lane": location is null


func _ready() -> void:
	pass


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


func fuckyou(_fu):
	location = _fu
	push_error("someone used player.location!")
