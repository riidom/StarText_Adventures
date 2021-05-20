extends Node2D


onready var StarsFolder = $StarsFolder

var init_seed := 0
var map := [] # becomes 2D array
var amount_of_stars := 15
var lanes := {}
var astar = AStar2D.new()

var map_size := Vector2(10, 10) # measured in sectors
var sector_size := 40 # in pixels
var sector_padding := round(sector_size / 15.0) # dont place stars closer than # px to sector border
var map_px_size := map_size.x * sector_size
var draw_sector_grid := false

onready var PlayerIndicator = $PlayerIndicator
var player_on_star_icon = preload("res://Starmap/player_indicator_star.png")
var player_on_lane_icon = preload("res://Starmap/player_indicator_lane.png")
onready var DestinationIndicator = $DestinationIndicator
var destination_icon = preload("res://Starmap/destination_indicator.png")


func custom_ready(data = null) -> void:
	if !data:
		randomize()
		init_seed = randi()# % 1000000
		seed(init_seed)
		init_map()
	else:
		load_map(data)


func load_map(d) -> void:
	NameGen.used = {}
	init_seed = d.s.init_seed
	map = d.s.map
	amount_of_stars = d.s.amount_of_stars
	lanes = d.s.lanes
	map_size = d.s.map_size
	sector_size = d.s.sector_size
	sector_padding = d.s.sector_padding
	map_px_size = d.s.map_px_size
	draw_sector_grid = d.s.draw_sector_grid
	astar = d.s.astar
	
	# first give all star-nodes the correct name
	for i in amount_of_stars:
		var star:Star = StarsFolder.get_child(i)
		var loaded = d.s.stars[i]
		star.name = loaded[0]
		star.position = loaded[1]
		star.sector = loaded[2]
		star.index = loaded[3]
		star.position_importance = loaded[4]
	
	# then iterate again to assign adjacent stars, which requires correct star names
	for i in amount_of_stars:
		var star: Star = StarsFolder.get_child(i)
		star.adj_stars.clear()
		var loaded_adj: Array = d.s.stars[i][3] # only asking for 4th element (array-in-array of adj. stars)
		for a in loaded_adj:
			star.adj_stars.append(get_star_node_by_name(a))
	
	update()


func get_star_node_by_name(name: String):
	for s in StarsFolder.get_children():
		if s.name == name: return s
	push_error("No star named %s inside 'StarsFolder'." % name)


func init_map() -> void:
	NameGen.used = {}
	lanes = {}
	self.map = init_map_array(map_size)
	# instance and place stars
	for i in amount_of_stars:
		while true:
			var temp_x = randi() % int(map_size.x)
			var temp_y = randi() % int(map_size.y)
			if map[temp_x][temp_y]: continue
			define_star(i, temp_x, temp_y)
			break
	
	place_lanes()
	find_chokepoints()


func init_map_array(size: Vector2) -> Array:
	var new_map := []
	for x in range(size.x):
		new_map.append([])
		for _y in range(size.y):
			new_map[x].append(null)
	return new_map

	
func define_star(index: int, x: int, y: int) -> void:
	var star = StarsFolder.get_child(index)
	star.index = index
	star.sector = Vector2(x, y)
	star.set_px_size(round(sector_size / 3.0))
	var star_offset = Vector2(
		int(rand_range(sector_padding + 8, sector_size - sector_padding - 8)),
		int(rand_range(sector_padding + 8, sector_size - sector_padding - 8))
	) # the 8 is half the tilesize of the sun-icon
	star.position = Vector2(x * sector_size, y * sector_size) + star_offset
	star.name = NameGen.generate_system_name(x, y)
	map[x][y] = star
	astar.add_point(star.index, star.position)


func place_lanes() -> void:
	var undone_stars:Array = StarsFolder.get_children()
	var done_stars := []
	done_stars.append(undone_stars.pop_front())
	
	# first pass with Minimum Spanning Tree; all stars connected
	while !undone_stars.empty():
		var best_distance = INF
		var candidate_start = null
		var candidate_end = null
		for s1 in done_stars:
			for s2 in undone_stars:
				var current_distance = s1.position.distance_to(s2.position)
				if current_distance <= best_distance:
					best_distance = current_distance
					candidate_start = s1
					candidate_end = s2
		add_lane(candidate_start, candidate_end)
		var s = undone_stars.find(candidate_end)
		done_stars.append(undone_stars[s])
		undone_stars.remove(s)
	
	# add random lanes, check for intersections and narrow angles
	for _i in range(3):
		done_stars.shuffle()
		for s1 in done_stars:
			for s2 in done_stars:
				if s1 == s2: continue
				if lanes.has(assemble_lane_name(s1.name, s2.name)): continue
				if is_intersecting(s1, s2): continue
				if is_touching_star(s1, s2, done_stars): continue
				if are_angles_narrow(s1, s2, 25): continue
				add_lane(s1, s2)


func find_chokepoints() -> void:
	for s1 in astar.get_points():
		for s2 in astar.get_points():
			if s1 == s2: continue
			for p in astar.get_id_path(s1, s2):
				StarsFolder.get_child(p).position_importance += 1
	
	var imp_min:float = INF
	var imp_max:float = 0.0
	for s in StarsFolder.get_children():
		if s.position_importance < imp_min:
			imp_min = s.position_importance
		if s.position_importance > imp_max:
			imp_max = s.position_importance

	for s in StarsFolder.get_children():
		s.position_importance -= imp_min
	imp_max -= imp_min
	
	for s in StarsFolder.get_children():
		s.position_importance /= imp_max
		s.Icon.self_modulate = s.heat_gradient.interpolate(s.position_importance)


func is_intersecting(s1: Star, s2: Star) -> bool:
	var pos1 = s1.position
	var pos2 = s2.position
	for l in lanes.values():
		var e1 = l[1]
		var e2 = l[2]
		var isct = Geometry.segment_intersects_segment_2d(pos1, pos2, e1, e2)
		# also exclude origins of segments:
		if isct or (isct == pos1 or isct == pos2 or isct == e1 or isct == e2):
			return true
	return false


func is_touching_star(s1: Star, s2: Star, stars: Array) -> bool:
	for s in stars:
		if s == s1 or s == s2: continue
		if Geometry.segment_intersects_circle(s1.position, s2.position, s.position, 20) > -1:
			return true
	return false


func are_angles_narrow(s1: Star, s2: Star, limit: float) -> bool:
	limit = deg2rad(limit)
	var p1 := s1.position
	var p2 := s2.position
	
	var angle_candidate = p1.angle_to_point(p2)
	for a in s1.adj_stars:
		var angle_lane = p1.angle_to_point(a.position)
		if abs(angle_lane - angle_candidate) < limit:
			return true
	
	angle_candidate = p2.angle_to_point(p1)
	for a in s2.adj_stars:
		var angle_lane = p2.angle_to_point(a.position)
		if abs(angle_lane - angle_candidate) < limit:
			return true
		
	return false


func add_lane(star_1: Star, star_2: Star) -> void:
	var s1 := star_1
	var s2 := star_2
	if s1.name.casecmp_to(s2.name) == 1:
		# sort them by name, to avoid duplicate lanes (a->b and b->a)
		# and have the positions in equivalent order
		s1 = star_2
		s2 = star_1
	
	var lane_name := "%s - %s" % [s1.name, s2.name]
	var mid_point := Vector2(
		int((s1.position.x + s2.position.x) / 2),
		int((s1.position.y + s2.position.y) / 2)
	)
	if lanes.has(lane_name):
		push_error("Wanted to add lane, but already existing: %s." % lane_name)
		return
	
	lanes[lane_name] = [mid_point, s1.position, s2.position]
	s1.add_adj(s2)
	s2.add_adj(s1)
	astar.connect_points(s1.index, s2.index)


func assemble_lane_name(n1: String, n2: String) -> String:
	var compare = n1.casecmp_to(n2)
	if compare == -1:
		return n1 + " - " + n2
	elif compare == 1:
		return n2 + " - " + n1
	else:
		push_error("Can't create lanename from identical star names (%s)." % n1)
		return ""
	

func get_lane(s1: Star, s2: Star) -> Array:
	var l_name = assemble_lane_name(s1.name, s2.name)
	if lanes.has(l_name):
		return lanes[l_name]
	else:
		push_warning("Lane %s not existing." % l_name)
		return []

	
func _draw() -> void:
	# draw background stars
	draw_bg_stars(map_px_size / 2, .25, .25, 1, .5) # small stars
	draw_bg_stars(map_px_size / 10, .1, .75, 2, .75) # big stars
	
	# draw sector grid
	if draw_sector_grid:
		for x in range(map_size.x):
			for y in range(map_size.y):
				draw_rect(
					Rect2(Vector2(x * sector_size, y * sector_size), Vector2(sector_size, sector_size)),
					Color(.25, .25, .25), false, 1.0)
	
	# draw lanes
	for l in lanes.values():
		draw_line(l[1], l[2], Color(1, 1, 1, 0.85), 1, true)


func draw_bg_stars(amount: float, max_sat: float, min_val: float, size: float, alpha: float) -> void:
	var bg_star_pos = Vector2.ZERO
	var bg_star_col = Color(0,0,0, 1)
	for _i in range(int(amount)):
		bg_star_pos.x = round(rand_range(0, map_px_size))
		bg_star_pos.y = round(rand_range(0, map_px_size))
		bg_star_col = Color.from_hsv(randf(), rand_range(0, max_sat), rand_range(min_val, 1), alpha)
		draw_circle(bg_star_pos, size, bg_star_col)


func get_size() -> float:
	return map_px_size


func _on_player_location_updated(player, _silent: bool = false):
	if player.location_type == "Star":
		PlayerIndicator.texture = player_on_star_icon
		PlayerIndicator.position = player.location.position
		PlayerIndicator.rotation = 0
	elif player.location_type == "Lane":
		var lane = lanes[assemble_lane_name(player.origin.name, player.destination.name)]
		PlayerIndicator.texture = player_on_lane_icon
		PlayerIndicator.position = lane[0]
		var angle = lane[1].angle_to_point(lane[2])
		PlayerIndicator.rotation = angle + PI/2


func _on_destination_set(star: Star, _silent: bool = false) -> void:
	if star == null:
		DestinationIndicator.visible = false
		return
	DestinationIndicator.visible = true
	DestinationIndicator.position = star.position
	
