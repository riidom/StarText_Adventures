extends Node2D
class_name Player


var status = -1 # is player in station, space or lane?
var came_from = -1 # if status is IN_SPACE, did the player come from a station or a lane?
var modal = -1 # for things like navigation computer

var destination: Star = null
var location = null # Star or Lane


func _ready() -> void:
	pass
