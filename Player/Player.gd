extends Node2D
class_name Player


var status = G.IN.STATION
var came_from = G.FROM.GAME_START
var modal = G.DOING.NO_MODAL

var destination: Star = null
var location = null # Star or Lane


func _ready() -> void:
	pass
