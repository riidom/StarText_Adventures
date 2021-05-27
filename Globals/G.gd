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
signal language_toggled

# warning-ignore:unused_signal
signal action_triggered(id)

# warning-ignore:unused_signal
signal player_location_updated(player)
# warning-ignore:unused_signal
signal star_clicked(star)
# warning-ignore:unused_signal
signal destination_set(star, silent)
# warning-ignore:unused_signal
signal nav_started
# warning-ignore:unused_signal
signal nav_finished


var settings = load_settings()


func save_settings() -> void:
	var file_name = "user://settings.save"
	var file = File.new()
	file.open(file_name, File.WRITE)
	
	file.store_line(settings.lang)
	
	file.close()


func load_settings() -> Dictionary:
	settings = {}
	settings.lang = "en"	
	var file_name = "user://settings.save"
	var file = File.new()
	if !file.file_exists(file_name): return settings
	file.open(file_name, File.READ)
	
	settings.lang = file.get_line()
	
	file.close()
	return settings


func save_game(data, slot: int) -> void:
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	file.open(file_name, File.WRITE)

	var ds = data.Starmap
	
	var gdt = OS.get_datetime()
	var file_title = "%04d - %02d - %02d  |  %02d : %02d  |  %d"\
	% [gdt.year, gdt.month, gdt.day, gdt.hour, gdt.minute, ds.init_seed]
	
	file.store_line(file_title)
	file.store_64(ds.init_seed)
	file.store_var(ds.map)
	file.store_var(ds.lanes)
	file.store_var(ds.astar)
	
	for i in ds.map.amount_of_stars:
		var s:Star = ds.StarsFolder.get_child(i)
		var star_data := {
			name = s.name,
			position = s.position,
			sector = s.sector,
			index = s.index,
			centrality = s.centrality,
		}
		var adj_stars := []
		for a in s.adj_stars:
			adj_stars.append(a.name)
		star_data.adj_stars = adj_stars
		
		file.store_var(star_data)

	# replace star references with star names for saving
	var mod_pos = data.Player.pos.duplicate(true)
	mod_pos.from = mod_pos.from.name if mod_pos.from else null
	mod_pos.to = mod_pos.to.name if mod_pos.to else null
	mod_pos.at = mod_pos.at.name if mod_pos.at else null

	file.store_var(data.Player.status)
	file.store_var(mod_pos)
	file.store_var(data.TextLeft.get_text())
	
	file.close()


func load_game(slot: int) -> Dictionary:
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	if !file.file_exists(file_name): return {}
	file.open(file_name, File.READ)
	
	var _file_title = file.get_line() # not needed for actual loading the save game
	
	var d := {}
	
	d.s = {} # data for starmap & stars
	
	d.s.init_seed = file.get_64()
	d.s.map = file.get_var()
	d.s.lanes = file.get_var()
	d.s.astar = file.get_var()
	
	d.s.stars = []
	for i in d.s.map.amount_of_stars:
		d.s.stars.append(file.get_var())
	
	d.p = {} # data for player
	
	d.p.status = file.get_var()
	d.p.pos = file.get_var()
	
	d.t = {} # data for text
	
	d.t.text = file.get_var()
	
	file.close()
	return d
