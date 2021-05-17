extends ColorRect


onready var Label = $Scroll/Margin/RichTextLabel


func _ready() -> void:
	add(T.get("T_Welcome_1"))
	add(T.get("T_Welcome_2"), 2)


func print_location(player: Player) -> void:

	var mention_system = tell_system(player)
	var loc = ""
	var s_at = player.location.name if player.location else ""
	var s_from = player.origin.name if player.origin else ""
	var s_to = player.destination.name if player.destination else ""
	
	if player.status == G.IN.STATION:
		loc = "station"
		
	if player.status == G.IN.SPACE:
		if player.came_from == G.FROM.STATION:
			loc = "station->space"
		elif player.came_from == G.FROM.STARLANE:
			loc = "lane->space"
		elif player.came_from == G.FROM.SPACE:
			loc = "space->space"
	
	if player.status == G.IN.STARLANE:
		if player.came_from == G.FROM.STARLANE:
			loc = "lane"
		elif player.came_from == G.FROM.SPACE:
			loc = "space->lane"
	
	add(T.get("T_location_description",
		{mention_system = mention_system, loc = loc, s_at = s_at, s_from = s_from, s_to = s_to}), 2)



func tell_system(player: Player) -> bool:
	return (player.came_from == G.FROM.STARLANE and player.status != G.IN.STARLANE)\
		or (player.status == G.IN.STATION and player.came_from == G.FROM.GAME_START)


func add(text: String, linebreaks: int = 1) -> void:
# Two linebreaks for a blank line (end the paragraph)
# in the long run we want to keep just the last n entries (with array, or smth else?)
	Label.text += text
	for _i in range(linebreaks):
		Label.text += "\n"


func get_text() -> String:
	# for saving data
	return Label.text


func replace_text(t: String) -> void:
	# for loading data
	Label.text = t


func _on_player_location_updated(player: Player, silent: bool = false) -> void:
	if !silent: print_location(player)


func _on_destination_set(star: Star, silent: bool = false) -> void:
	if silent: return
	if star:
		add(T.get("T_destination_set", {star_name = star.name}), 2)
	else:
		add(T.get("T_destination_cleared"))
