extends Node2D


var Star = preload("res://Starmap/Star.tscn")
onready var StarsFolder = $StarsFolder

var map_size := Vector2(10, 10) # measured in sectors
var map := [] # becomes 2D array
var star_density := 0.1 # probability for a star in a sector
var sector_size := 50 # in pixels
var sector_padding := 3 # dont place stars closer than # px to sector border
var amount_of_stars := 0 # gets counted during map creation
var starlanes := []


func _ready() -> void:
	randomize()
	var init_seed = 82168 #randi()%100000
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
	for x in range(map_size.x):
		for y in range(map_size.y):
			if randf() > star_density:
				continue
			var star = Star.instance()
			star.name = "Star_%02d-%02d" % [x, y]
			star.sector = Vector2(x, y)
			var star_offset = Vector2(
				int(rand_range(sector_padding + 8, sector_size - sector_padding - 8)),
				int(rand_range(sector_padding + 8, sector_size - sector_padding - 8))
			)
			star.position = Vector2(x * sector_size, y * sector_size) + star_offset
			map[x][y] = star
			StarsFolder.add_child(star)
			star.set_label()
	amount_of_stars = StarsFolder.get_child_count()
	
	# starlanes
	create_starlanes()


func create_starlanes() -> void:
	# connect each star to its closest neighbor
	var star_1:Star = null
	var star_2:Star = null
	for s1 in range(amount_of_stars):
		for s2 in range(amount_of_stars):
			if s1 == s2:
				continue
			star_1 = StarsFolder.get_child(s1)
			star_2 = StarsFolder.get_child(s2)
			if star_1.closest_neighbor == null:
				star_1.closest_neighbor = star_2
				continue
			var distance_candidate = star_1.position.distance_to(star_2.position)
			var distance_sofarbest = star_1.position.distance_to(star_1.closest_neighbor.position)
			if distance_candidate < distance_sofarbest:
				star_1.closest_neighbor = star_2
	for s in range(amount_of_stars):
		var star = StarsFolder.get_child(s)
		starlanes.append([star.position, star.closest_neighbor.position])
		


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
				Color(.25, .25, .25), false, 1.0
			)
			
	# draw starlanes
	for i in starlanes:
		draw_line(i[0], i[1], Color(.8, .8, .8), 1.1, true)


func draw_bg_stars(amount: int, max_saturation: float, min_value: float, size: float, alpha: float) -> void:
	var bg_star_pos = Vector2.ZERO
	var bg_star_col = Color(0,0,0, 1)
	for _i in range(amount):
		bg_star_pos.x = round(rand_range(0, get_viewport().size.x))
		bg_star_pos.y = round(rand_range(0, get_viewport().size.y))
		bg_star_col = Color.from_hsv(randf(), rand_range(0, max_saturation), rand_range(min_value, 1), alpha)
		draw_circle(bg_star_pos, size, bg_star_col)
