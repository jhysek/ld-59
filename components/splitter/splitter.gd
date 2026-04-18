extends Node2D

var Splitter = preload("res://components/splitter/splitter.tscn")

var polar_pos = Vector2i(0,0)

func place(to_coords):
	polar_pos = to_coords
	position = Coords.polar_to_world(polar_pos)
	rotation = position.angle() + PI / 2

func tick(time):
	pass
	
func process_signals(signals):
	if signals.size() > 0:
		split_signal(signals[0])

func split_signal(signal_node):
	if Global.SPLIT_RULES.has(signal_node.color):
		print("SPLIT TO " + str(Global.SPLIT_RULES[signal_node.color]))
	else:
		print("NO SPLIT RULE FOR COLOR: " + str(signal_node.color))
	
