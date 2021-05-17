extends MarginContainer


onready var S1 = $HBox3/Label
onready var S2 = $HBox3/Label2
onready var S3 = $HBox3/Label3


func _on_player_location_updated(player: Player, _silent: bool = false) -> void:
	if player.status == G.IN.SPACE:
		S1.text = T.get("S_InSpace")
	elif player.status == G.IN.STARLANE:
		S1.text = T.get("S_OnLane")
	elif player.status == G.IN.STATION:
		S1.text = T.get("S_InStation")


func _on_destination_set(star: Star, _silent: bool = false) -> void:
	if star:
		S2.text = T.get("S_destination_set", {star_name = star.name})
	else:
		S2.text = T.get("S_destination_cleared")
