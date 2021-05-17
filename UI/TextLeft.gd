extends ColorRect


onready var Label = $Scroll/Margin/RichTextLabel


func _ready() -> void:
	add(T.get("T_Welcome_1"))
	add(T.get("T_Welcome_2"), 2)
	#add("Welcome onboard, captain!")
	#add("The ship is ready.", 2)


func print_location(player: Player) -> void:
	add("You are ", 0)
	add(tell_system(player), 0)
	
	if player.status == G.IN.STATION:
		
		add("inside the station.", 2)
		
	if player.status == G.IN.SPACE:
		
		if player.came_from == G.FROM.STATION:
			add("outside the station.", 2)
		elif player.came_from == G.FROM.STARLANE:
			add("nearby the station, after leaving the starlane.", 2)
		elif player.came_from == G.FROM.SPACE:
			add("still in space?", 2)
	
	if player.status == G.IN.STARLANE:
		
		if player.came_from == G.FROM.STARLANE:
			add("on the starlane between %s and %s." % [player.origin.name, player.destination.name], 2)
		elif player.came_from == G.FROM.SPACE:
			add("entering the starlane towards %s." % player.destination.name, 2)


func tell_system(player: Player) -> String:
	if (player.came_from == G.FROM.STARLANE and player.status != G.IN.STARLANE)\
	or (player.status == G.IN.STATION and player.came_from == G.FROM.GAME_START):
		return "in the system %s, " % player.location.name
	else: return ""


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
		add("Destination set to %s." % star.name, 2)
	else:
		add("Destination cleared.", 2)
