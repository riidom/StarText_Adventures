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
signal player_location_updated(player)
# warning-ignore:unused_signal
signal star_clicked(star)
# warning-ignore:unused_signal
signal destination_set(star, silent)

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
	file.store_8(ds.amount_of_stars)
	file.store_var(ds.map_size)
	file.store_var(ds.map)
	file.store_8(ds.sector_size)
	file.store_8(ds.sector_padding)
	file.store_16(ds.map_px_size)
	file.store_var(ds.draw_sector_grid)
	file.store_var(ds.lanes)
	file.store_var(ds.astar)
	
	for i in ds.amount_of_stars:
		var s:Star = ds.StarsFolder.get_child(i)
		var star_data := [
			s.name, s.position, s.sector, s.index, # 0-3
			s.position_importance, # 4
		]
		var adj_stars := []
		for a in s.adj_stars:
			adj_stars.append(a.name)
		star_data.append(adj_stars)
		file.store_var(star_data)

	var dp = data.Player
	
	file.store_8(dp.status)
	file.store_8(dp.came_from)
	file.store_8(dp.modal)
	if dp.origin: file.store_line(dp.origin.name)
	else: file.store_line("")
	if dp.destination: file.store_line(dp.destination.name)
	else: file.store_line("")
	if dp.location: file.store_line(dp.location.name)
	else: file.store_line("")
	file.store_line(dp.location_type)
	
	var dt = data.TextLeft
	
	file.store_var(dt.get_text())
	
	file.close()


func load_game(slot: int) -> Dictionary:
	var file_name = "user://save-%d.save" % slot
	var file = File.new()
	if !file.file_exists(file_name): return {}
	file.open(file_name, File.READ)
	
	var _file_title = file.get_line() # not needed for actual loading the save game
	
	var d := {}
	
	d.s = {}
	
	d.s.init_seed = file.get_64()
	d.s.amount_of_stars = file.get_8()
	d.s.map_size = file.get_var()
	d.s.map = file.get_var()
	d.s.sector_size = file.get_8()
	d.s.sector_padding = file.get_8()
	d.s.map_px_size = file.get_16()
	d.s.draw_sector_grid = file.get_var()
	d.s.lanes = file.get_var()
	d.s.astar = file.get_var()
	
	d.s.stars = []
	for i in d.s.amount_of_stars:
		d.s.stars.append(file.get_var())
	
	d.p = {}
	
	d.p.status = file.get_8()
	d.p.came_from = file.get_8()
	d.p.modal = file.get_8()
	d.p.origin_name = file.get_line()
	d.p.destination_name = file.get_line()
	d.p.location_name = file.get_line()
	d.p.location_type = file.get_line()
	
	d.t = {}
	
	d.t.text = file.get_var()
	
	file.close()
	return d
