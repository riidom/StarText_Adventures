extends Node2D
class_name Star
func get_class(): return "Star"


var sector := Vector2.ZERO
var adj_stars := [] # connected stars

onready var Infotext = $Z_Index/Infotext


func _ready():
	Infotext.visible = false

	
func set_px_size(size: float) -> void:
	$Icon.rect_scale = Vector2(size / 16, size / 16)


func add_adj(s: Star) -> void:
	if adj_stars.find(s) > -1:
		push_error("Star %s is already noted as adjacent to this star (%s)." % [s.name, self.name])
		return
	adj_stars.append(s)


func set_label() -> void:
	var text = [
		self.name,
		"",
		"Sector: %02d-%02d" % [sector.x, sector.y],
		"Pixelpos: %d, %d" % [position.x, position.y],
		"",
	]
	for a in adj_stars:
		text.append("-> " + a.name)
	Infotext.text = PoolStringArray(text).join("\n")


func _on_Icon_mouse_entered() -> void:
	set_label()
	Infotext.visible = true


func _on_Icon_mouse_exited() -> void:
	Infotext.visible = false


func _on_Icon_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		G.emit_signal("star_clicked", self)
