extends MarginContainer


onready var S1 = $HBox3/Label
onready var S2 = $HBox3/Label2
onready var S3 = $HBox3/Label3


func _on_player_location_updated(player: Player) -> void:
	if player.status == G.IN_SPACE:
		S1.text = "Ship is in space"
	elif player.status == G.IN_STARLANE:
		S1.text = "Ship is on starlane"
	elif player.status == G.IN_STATION:
		S1.text = "Ship is in station"


func _on_destination_set(star: Star, silent: bool = false) -> void:
	if star:
		S2.text = "Destination: %s" % star.name
	else:
		S2.text = "No destination set"
