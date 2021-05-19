extends MarginContainer


onready var S1 = $HBox3/Label
onready var S2 = $HBox3/Label2
onready var S3 = $HBox3/Label3

var in_station = preload("res://UI/icons/ship_in_station.png")
var in_lane = preload("res://UI/icons/ship_on_lane.png")
var in_space = preload("res://UI/icons/ship_in_space.png")


func _on_player_location_updated(player: Player, _silent: bool = false) -> void:
	if player.status == G.IN.SPACE:
		S1.texture = in_space
	elif player.status == G.IN.STARLANE:
		S1.texture = in_lane
	elif player.status == G.IN.STATION:
		S1.texture = in_station


func _on_destination_set(star: Star, _silent: bool = false) -> void:
	if star:
		S2.text = star.name
	else:
		S2.text = "---"
