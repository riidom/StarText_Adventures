extends Node2D
class_name Star
func get_class() -> String: return "Star"


enum {V, C, SC} # for generate_names(): vowel, consonant, support-consonant
var letters := [
	["a", "e", "i", "o", "u"],
	["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"],
	["c", "h", "y"]
]

var sector := Vector2.ZERO
var lanes := [] # starlanes connecting to this star

onready var Infotext = $Z_Index/Infotext


func _ready():
	Infotext.visible = false

	
func set_px_size(size: float) -> void:
	$Icon.rect_scale = Vector2(size / 16, size / 16)


func set_label() -> void:
	var text = [
		self.name,
		"",
		"Sector: %02d-%02d" % [sector.x, sector.y],
		"Pixelpos: %d, %d" % [position.x, position.y],
		"",
	]
	for l in lanes:
		text.append("-> " + l.get_other_side(self).name)
	Infotext.text = PoolStringArray(text).join("\n")


func generate_name() -> String:
	var num = "-%02d%02d" % [sector.x, sector.y]
	var pattern := randi() % 3
	match pattern:
		0:
			return get_l(V, true) + get_l(SC) + get_l(C) + num
		1:
			return get_l(C, true) + get_l(V) + get_l(C) + num
		_:
			return get_l(C, true) + get_l(SC) + get_l(V) + num


func get_l(type: int, uppercase: bool = false) -> String:
	var l = letters[type][randi() % letters[type].size()]
	if uppercase: l = l.to_upper()
	return l


func _on_Icon_mouse_entered() -> void:
	set_label()
	Infotext.visible = true


func _on_Icon_mouse_exited() -> void:
	Infotext.visible = false
