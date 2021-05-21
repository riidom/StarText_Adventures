extends Node2D
class_name Player


var status = {}
var pos := {}


func _ready() -> void:
	pos.from = null
	pos.to = null
	pos.at = null
	pos.type = "" # if "Star": origin and destination are null; if "Lane": location is null
	status.current = G.IN.STATION
	status.came_from = G.FROM.GAME_START
	status.modal = G.DOING.NO_MODAL


func load_data(d, stars) -> void:
	status = d.p.status
	pos = d.p.pos
	# saving references to stars (as node) is a problem, so we save names only
	# and find star-node by name to re-create proper reference to star-node
	pos.at = get_star_node_by_name(d.p.pos.at, stars) if d.p.pos.at else null
	pos.from = get_star_node_by_name(d.p.pos.from, stars) if d.p.pos.from else null
	pos.to = get_star_node_by_name(d.p.pos.to, stars) if d.p.pos.to else null


func get_star_node_by_name(name: String, stars: Array):
	for s in stars:
		if s.name == name: return s
	push_error("No star named %s inside array of 'StarsFolder'." % name)


func update_location(s1: Star, s2: Star = null) -> void:
	if !s2: # Player is on a star
		pos.from = null
		pos.to = null
		pos.at = s1
		pos.type = "Star"
	else:
		pos.from = s1
		pos.to = s2
		pos.at = null
		pos.type = "Lane"

