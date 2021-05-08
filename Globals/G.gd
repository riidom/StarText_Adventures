extends Node


# status
enum IN {
	STATION,
	SPACE,
	STARLANE,
}

# came_from
enum FROM {
	GAME_START,
	STATION,
	STARLANE,
	SPACE,
}

# modal
enum DOING {
	NO_MODAL,
	NAV,
}


# warning-ignore:unused_signal
signal player_location_updated(player)
# warning-ignore:unused_signal
signal star_clicked(star)
# warning-ignore:unused_signal
signal destination_set(star, silent)
