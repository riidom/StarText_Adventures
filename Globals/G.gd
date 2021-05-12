extends Node


enum IN {STATION, SPACE, STARLANE}
enum FROM { GAME_START, STATION, STARLANE, SPACE}
enum DOING { NO_MODAL, NAV, MAIN_MENU}


# warning-ignore:unused_signal
signal main_menu_closed
# warning-ignore:unused_signal
signal main_menu_opened

# warning-ignore:unused_signal
signal game_saved(slot)
# warning-ignore:unused_signal
signal game_loaded(slot)

# warning-ignore:unused_signal
signal player_location_updated(player)
# warning-ignore:unused_signal
signal star_clicked(star)
# warning-ignore:unused_signal
signal destination_set(star, silent)


func save_game(data, slot: int) -> void:
	print("\n------- SAVE -------\n")
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	file.open(file_name, File.WRITE)

	file.store_var(data.Starmap.init_seed, true)
	
	file.close()


func load_game(slot: int):
	print("\n------- LOAD -------\n")
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	if !file.file_exists(file_name): return
	file.open(file_name, File.READ)
	
	var init_seed = file.get_var(true)
	
	file.close()
	return init_seed
