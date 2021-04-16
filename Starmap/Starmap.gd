extends Node2D


var Star = preload("res://Starmap/Star.tscn")
onready var StarsFolder = $StarsFolder
var Starlane = preload("res://Starmap/Starlane.tscn")
onready var StarlanesFolder = $StarlanesFolder


var init_seed := 0
var map_size := Vector2(10, 10) # measured in sectors
var map := [] # becomes 2D array
var star_density := 0.15 # ratio of sectors who have a star
var sector_size := 50 # in pixels
var sector_padding := 3 # dont place stars closer than # px to sector border
var amount_of_stars := 0 # gets counted during map creation

var debug_points := []

func _ready() -> void:
	randomize()
	# 363574
	# 872921
	init_seed = randi()%1000000
	print("Seed: %s" % init_seed)
	seed(init_seed)
	$ColorRect.rect_size = get_viewport().size
	init_map()


func init_map() -> void:
	# set up 2D array
	for x in range(map_size.x):
		map.append([])
		for _y in range(map_size.y):
			map[x].append(null)
	
	# instance and place stars
	for i in int(map_size.x * map_size.y * star_density):
		while true:
			var temp_x = randi() % int(map_size.x)
			var temp_y = randi() % int(map_size.y)
			if map[temp_x][temp_y]: continue
			instance_star(temp_x, temp_y)
			break
	
	amount_of_stars = StarsFolder.get_child_count()
	place_starlanes()


func instance_star(x: int, y: int) -> void:
	var star = Star.instance()
	star.sector = Vector2(x, y)
	var star_offset = Vector2(
		int(rand_range(sector_padding + 8, sector_size - sector_padding - 8)),
		int(rand_range(sector_padding + 8, sector_size - sector_padding - 8))
	) # the 8 is half the tilesize of the sun-icon
	star.position = Vector2(x * sector_size, y * sector_size) + star_offset
	star.name = star.generate_name()
	map[x][y] = star
	StarsFolder.add_child(star)
	star.set_label()


func place_starlanes() -> void:
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
		create_starlane(candidate_start, candidate_end)
		var s = undone_stars.find(candidate_end)
		done_stars.append(undone_stars[s])
		undone_stars.remove(s)
	
	# add random lanes, check for intersections and narrow angles
	for s1 in done_stars:
		for s2 in done_stars:
			if s1 == s2: continue
			var starlanes = StarlanesFolder.get_children()
			var t1 = "StarlanesFolder/" + s1.name + "__" + s2.name
			var t2 = "StarlanesFolder/" + s2.name + "__" + s1.name
			var t = get_node_or_null(t1) or get_node_or_null(t2)
			if t: continue # such a starlane already existing?
			if is_intersecting(s1, s2, starlanes): continue
			if is_touching_star(s1, s2, done_stars): continue
			if are_angles_narrow(s1, s2, 30): continue
			create_starlane(s1, s2)


func is_intersecting(s1: Star, s2: Star, lanes: Array) -> bool:
	var pos1 = s1.position
	var pos2 = s2.position
	for l in lanes:
		var e1 = l.star_1.position
		var e2 = l.star_2.position
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
	var p1 := s1.position
	var p2 := s2.position
	
	var angle_candidate = rad2deg(p1.angle_to_point(p2))
	for l in s1.lanes:
		var s_target = l.get_other_side(s1)
		var angle_lane = rad2deg(p1.angle_to_point(s_target.position))
		if abs(angle_lane - angle_candidate) < limit:
			return true
	
	angle_candidate = rad2deg(p2.angle_to_point(p1))
	for l in s2.lanes:
		var s_target = l.get_other_side(s2)
		var angle_lane = rad2deg(p2.angle_to_point(s_target.position))
		if abs(angle_lane - angle_candidate) < limit:
			return true
		
	return false


func create_starlane(s1: Star, s2: Star) -> void:
	var lane = Starlane.instance()
	lane.init(s1, s2)
	StarlanesFolder.add_child(lane)
	s1.lanes.append(lane)
	s2.lanes.append(lane)


func _draw() -> void:
	# draw background stars
	draw_bg_stars(350, .25, .25, 1, .5) # small stars
	draw_bg_stars(50, .1, .75, 2, .75) # big stars
	
	# draw sector grid
	for x in range(map_size.x):
		for y in range(map_size.y):
			continue
			draw_rect(
				Rect2(Vector2(x * sector_size, y * sector_size), Vector2(sector_size, sector_size)),
				Color(.25, .25, .25), false, 1.0)
	
	for d in debug_points:
		draw_circle(d, 3, Color(1, 0, 0))


func draw_bg_stars(amount: int, max_saturation: float, min_value: float, size: float, alpha: float) -> void:
	var bg_star_pos = Vector2.ZERO
	var bg_star_col = Color(0,0,0, 1)
	for _i in range(amount):
		bg_star_pos.x = round(rand_range(0, get_viewport().size.x))
		bg_star_pos.y = round(rand_range(0, get_viewport().size.y))
		bg_star_col = Color.from_hsv(randf(), rand_range(0, max_saturation), rand_range(min_value, 1), alpha)
		draw_circle(bg_star_pos, size, bg_star_col)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		recreate_map()


func recreate_map() -> void:
	var _x = get_tree().reload_current_scene()

