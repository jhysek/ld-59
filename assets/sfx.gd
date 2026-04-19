extends Node

func play(name):
	if has_node(name):
		get_node(name).play()
