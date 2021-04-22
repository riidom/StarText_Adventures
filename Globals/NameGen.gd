extends Node


enum {V, C, vCC, CCv} # kleingeschriebene Teile: Voraussetzung, nicht Bestandteil
var letters := [
	["a", "e", "i", "o", "u"],
	["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z"],
	["bb", "dd", "ff", "gg", "kk", "ll", "mm", "nn", "pp", "rr", "ss", "tt", "zz", "np", "nk", "nt", "xy", "xt", "nd", "md", "hb", "hd", "hf", "hg", "hk", "hl", "hm", "hn", "hp", "hr", "hs", "ht", "hx", "hy", "hz", "rb", "rd", "rg", "rk", "rl", "rm", "rn", "rp", "rs", "rt", "rw", "rx", "ry", "rz", "gs", "ng", "tt", "ll", "ch", "st", "ts", "sz"],
	["pr", "yx", "bh", "ch", "fh", "gh", "kh", "mh", "ph", "rh", "sh", "wh", "yh", "zh", "br", "dr", "fr", "gr", "kr", "pr", "tr", "yr", "st", "pl"],
]
var used := {}


func generate_system_name(x, y) -> String:
	var num = "-%02d%02d" % [x, y]
	var result := ""
	while true:
		var pattern := randi() % 4
		match pattern:
			0:
				result = get_l(V) + get_l(vCC)
			1:
				result = get_l(C) + get_l(V) + get_l(C)
			2:
				result = get_l(V) + get_l(C) + get_l(V)
			3:
				result = get_l(CCv) + get_l(V)
			_:
				result = "rii"
		
		if !used.has(result):
			used[result] = true
			break
			
	return result.capitalize() + num


func get_l(type: int) -> String:
	return letters[type][randi() % letters[type].size()]
