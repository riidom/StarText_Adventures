extends ColorRect


onready var Label = $Scroll/M/VBox/Text


func _ready() -> void:
	add(T.get("T_Welcome_1"))
	add(T.get("T_Welcome_2"), 2)


func print_location(player: Player) -> void:
	var mention_system = tell_system(player)
	var loc = ""
	var s_at = player.pos.at.name if player.pos.at else ""
	var s_from = player.pos.from.name if player.pos.from else ""
	var s_to = player.pos.to.name if player.pos.to else ""
	
	if player.status.current == G.IN.STATION:
		loc = "station"
		
	if player.status.current == G.IN.SPACE:
		if player.status.came_from == G.FROM.STATION:
			loc = "station->space"
		elif player.status.came_from == G.FROM.STARLANE:
			loc = "lane->space"
		elif player.status.came_from == G.FROM.SPACE:
			loc = "space->space"
	
	if player.status.current == G.IN.STARLANE:
		if player.status.came_from == G.FROM.STARLANE:
			loc = "lane"
		elif player.status.came_from == G.FROM.SPACE:
			loc = "space->lane"
	
	add(T.get("T_location_description",
		{mention_system = mention_system, loc = loc, s_at = s_at, s_from = s_from, s_to = s_to}), 2)


func tell_system(player: Player) -> bool:
	return (player.status.came_from == G.FROM.STARLANE and player.status.current != G.IN.STARLANE)\
		or (player.status.current == G.IN.STATION and player.status.came_from == G.FROM.GAME_START)


func print_dialog(player: Player, meta: String) -> void:
	var id = player.dialog_type
	var text_section = Dialogs[id].story[meta]
	if !text_section.has("echo"):
		pass
	elif text_section.echo == "~":
		add("[i]%s[/i]" % Dialogs[id].story[meta].button, 2)
	else:
		add("[i]%s[/i]" % Dialogs[id].story[meta].echo, 2)
		
	add(Dialogs[id].story[meta].reaction, 2)


func add(text: String, linebreaks: int = 1) -> void:
# Two linebreaks for a blank line (end the paragraph)
# in the long run we want to keep just the last n entries (with array, or smth else?)
	Label.append_bbcode(text)
	for _i in range(linebreaks):
		Label.append_bbcode("\n")


func get_text() -> String:
	# for saving data
	return Label.text


func replace_text(t: String) -> void:
	# for loading data
	Label.bbcode_text = t


func _on_player_location_updated(player: Player, silent: bool = false) -> void:
	if !silent: print_location(player)


func _on_destination_set(star: Star, silent: bool = false) -> void:
	if silent: return
	if star:
		add(T.get("T_destination_set", {star_name = star.name}), 2)
	else:
		add(T.get("T_destination_cleared"))
