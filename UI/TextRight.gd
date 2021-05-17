extends ColorRect


onready var Label = $Margin/RichTextLabel


func general_options(player: Player) -> void:
	cls()
	if player.status == G.IN.SPACE:
		add(T.get("I_D_Dock"), 2)
		add(T.get("I_N_Nav"), 2)
		if player.destination:
			add(T.get("I_J_Jump"), 2)
	elif player.status == G.IN.STATION:
		add(T.get("I_N_Nav"), 2)
		add(T.get("I_E_Engines"), 2)
	elif player.status == G.IN.STARLANE:
		add(T.get("I_W_Wait"), 2)
	add(T.get("I_ESC_Menu"), 2)


func nav_options(player: Player) -> void:
	cls()
	add(T.get("I_Nav_Instructions"), 2)
	if player.destination:
		add(T.get("I_C_ClearNav"), 2)
	add(T.get("I_ESC_Cancel"), 2)


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


func _on_player_location_updated(player: Player, _silent: bool = false) -> void:
	general_options(player)
