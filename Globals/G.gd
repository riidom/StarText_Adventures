extends Node


# status
enum {
	IN_STATION,
	IN_SPACE,
	IN_STARLANE,
}

# came_from
enum {
	FROM_STATION,
	FROM_STARLANE,
}

# modal
enum {
	DOING_NAV,
}


# warning-ignore:unused_signal
signal player_location_updated(player)
# warning-ignore:unused_signal
signal star_clicked(star)
# warning-ignore:unused_signal
signal destination_set(star)
