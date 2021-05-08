extends ColorRect


onready var Label = $Margin/RichTextLabel


func general_options(player: Player) -> void:
	cls()
	if player.status == G.IN.SPACE:
		add("D - Contact station and ask for permission to dock.", 2)
		add("N - Navigation computer, pick a destination from map.", 2)
		if player.destination:
			add("J - Start the warp engine and enter the starlane.", 2)
	elif player.status == G.IN.STATION:
		add("N - Navigation computer, pick a destination from map.", 2)
		add("E - Fire up the engines and exit the station.", 2)
	elif player.status == G.IN.STARLANE:
		add("W - Wait while the travel on the starlane continues.", 2)
	add("ESC - Main Menu", 2)


func nav_options(player: Player) -> void:
	cls()
	add("Navigation Computer - Click an adjacent star system on the map to pick your next destination.", 2)
	if player.destination:
		add("C - Clear current destination.", 2)
	add("ESC - Cancel", 2)


func cls() -> void:
	Label.text = ""


func add(text: String, linebreaks: int = 1) -> void:
# Two linebreaks for a blank line (end the paragraph)
# in the long run we want to keep just the last n entries (with array, or smth else?)
	Label.text += text
	for _i in range(linebreaks):
		Label.text += "\n"


func err(variable: String) -> void:
	printerr("BUG: '%s' possibly wrong." % variable)
	print_stack()


func _on_player_location_updated(player: Player) -> void:
	general_options(player)
