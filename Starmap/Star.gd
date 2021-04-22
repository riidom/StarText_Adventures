extends Node2D
class_name Star
func get_class(): return "Star"


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


func _on_Icon_mouse_entered() -> void:
	set_label()
	Infotext.visible = true


func _on_Icon_mouse_exited() -> void:
	Infotext.visible = false
