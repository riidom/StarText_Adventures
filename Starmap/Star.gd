extends Node2D
class_name Star

var sector := Vector2.ZERO
var closest_neighbor = null setget set_closest_neighbor

onready var Infotext = $Z_Index/Infotext


func _ready():
	Infotext.visible = false


func set_label() -> void:
	var text = [
		#self.name,
		"%02d-%02d" % [sector.x, sector.y],
		"(%d, %d)" % [position.x, position.y]
	]
	if closest_neighbor:
		text.append(closest_neighbor.name)
	Infotext.text = PoolStringArray(text).join("\n")


func set_closest_neighbor(otherStar) -> void:
	closest_neighbor = otherStar
	set_label()


func _on_Icon_mouse_entered() -> void:
	Infotext.visible = true


func _on_Icon_mouse_exited() -> void:
	Infotext.visible = false
