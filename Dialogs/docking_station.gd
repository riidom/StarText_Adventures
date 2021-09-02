extends Resource


export(Dictionary) var story = {}


func eval_step(step: String, params: Array = []):
	return call(step, params)

# button: button text
# echo: confirmation of button press in text window; "~" to repeat button text, omit for to next, or custom text
# reaction: answer from other side (it's a dialog); written in italics
# options: which new buttons to create here
func init(station_name: String) -> void:
	# every dialog must begin with "D_entry"
	story["D_entry"] = {
		button = "You contact the station, requesting permission to dock.",
		echo = "You contact the station with an automated signal.",
		reaction = "'Welcome to %s. Identify yourself please.'" % station_name,
		options = ["D_tell_ship_name", "D_tell_fake_name", "D_stay_silent"]
	}
	story["D_tell_ship_name"] = {
		button = "'Hello Station, this is the St.Tead on private duty.'",
		echo = "~",
		reaction = "'Checked. Use landing bay %d.'" % (randi() % 5 + 1),
		options = ["D_dock_ship"]
	}
	story["D_tell_fake_name"] = {
		button = "\"Hello Station, this is John Doe 123 with undetermined business.\"",
		echo = "~",
		reaction = "'You won't try this again, be sure!'",
		story_signal = ["D_game_over"]
	}
	story["D_stay_silent"] = {
		button = "\"...\" Don't answer.",
		echo = "You don't answer and wait what happens.",
		reaction = "'Fine, you just got scheduled. Try again much later.'",
		story_signal = ["D_wait"]
	}
	story["D_dock_ship"] = {
		button = "Move the ship to the assigned bay.",
		reaction = "You move the ship to the assigned bay.",
		story_signal = ["D_end"]
	}


# every function must have parameter-array in signature
func D_entry(_p: Array):
	print("entry!")

func D_tell_ship_name(_p: Array) -> void:
	print("tell_ship_name!")


func D_tell_fake_name(_p: Array) -> void:
	print("fake")


func D_stay_silent(_p: Array) -> void:
	print("psst")


func D_dock_ship(_p: Array) -> void:
	print("DOCKED !!!!")
