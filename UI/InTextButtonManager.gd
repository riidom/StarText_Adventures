extends GridContainer


var button = preload("res://UI/InTextButton.tscn")


func add_button(translate_id: String) -> void:
	var b = button.instance()
	b.init(T.get(translate_id), translate_id)
	add_child(b)


func is_button_active(id: String) -> bool:
	for b in get_children():
		if b.name == id: return true
	return false


func update_buttons(player: Player) -> void:
	for b in get_children():
		b.queue_free()
	
	if player.status.modal == G.DOING.NO_MODAL:
		
		if player.status.current == G.IN.SPACE:
			add_button("I_D_Dock")
			add_button("I_N_Nav")
			
			if player.pos.to:
				add_button("I_J_Jump")
		
		elif player.status.current == G.IN.STATION:
			add_button("I_E_Engines")
			add_button("I_N_Nav")
		
		elif player.status.current == G.IN.STARLANE:
			add_button("I_W_Wait")
		
		add_button("I_ESC_Menu")
	
	if player.status.modal == G.DOING.NAV:
		
		if player.pos.to:
			add_button("I_C_ClearNav")
		
		add_button("I_ESC_Cancel")

