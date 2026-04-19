extends Node

var TIME = 0.0

var opened_levels = 0

const COLOR_WHITE = "WHITE"
const COLOR_CYAN = "CYAN"
const COLOR_MAGENTA = "MAGENTA"
const COLOR_YELLOW = "YELLOW"
const COLOR_BLUE = "BLUE"
const COLOR_RED = "RED"
const COLOR_GREEN = "GREEN"
const COLOR_BLACK = "BLACK"

const COLORS = {
	COLOR_WHITE: Color.CYAN,
	COLOR_CYAN: Color.CYAN,
	COLOR_MAGENTA: Color.MAGENTA,
	COLOR_YELLOW: Color.YELLOW,
	COLOR_BLUE: Color.BLUE,
	COLOR_RED: Color.RED,
	COLOR_GREEN: Color.GREEN,
	COLOR_BLACK: Color.MAGENTA
}

const SPLIT_RULES = {
	COLOR_WHITE: ["CYAN", "MAGENTA", "YELLOW"],
	COLOR_CYAN: ["BLUE","GREEN"],
	COLOR_MAGENTA: [ "BLUE", "RED" ],
	COLOR_YELLOW: ["GREEN", "RED"],
	COLOR_RED: [],
	COLOR_GREEN: [],
	COLOR_BLUE: []
}

func sort_nodes_by_color_code(nodes):
	return nodes.sort_custom(
		func(a, b): 
			return a.color_code.naturalnocasecmp_to(b.color_code) < 0)
			
func sort_color_codes(codes):
	return codes.sort_custom(
		func(a, b):
			return a.naturalnocasecmp_to(b) < 0
	)
