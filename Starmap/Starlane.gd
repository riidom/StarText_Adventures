extends Line2D
class_name Starlane


var star_1: Star = null
var star_2: Star = null


func init(s1, s2) -> void:
	star_1 = s1
	star_2 = s2
	name = star_1.name + "__" + star_2.name
	add_point(star_1.position)
	add_point(star_2.position)


func get_other_side(star: Star) -> Star:
	if star != star_1 and star != star_2:
		printerr("Star '%s' doesn't belong to this starlane '%s'." % [star.name, self.name])
		print_stack()
		return star
	if star == star_1:
		return star_2
	else:
		return star_1

