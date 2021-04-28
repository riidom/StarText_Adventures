extends ColorRect


onready var Label = $Scroll/Margin/RichTextLabel


func _ready() -> void:
	add("Welcome onboard, captain!")
	add("Your ship is ready.", 2)


func print_location(player: Player) -> void:
	if player.location.get_class() == "Star":
		add("You are now in the system %s, " % player.location.name, 0)
		if player.status == G.IN_STATION:
			add("inside the station.")
			
		elif player.status == G.IN_SPACE:
			if player.came_from == G.FROM_STARLANE:
				add("after leaving the starlane, the station is nearby.")
				
			elif player.came_from == G.FROM_STATION:
				add("outside the station in space.")
				
			else: err("player.came_from")
				
		else: err("player.status")
			
	elif player.location.get_class() == "Starlane":
		add("You are now on the starlane between %s and %s." % [player.location.star_1, player.location.star_2])
		
	else: err("player.location")


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
	print_location(player)

