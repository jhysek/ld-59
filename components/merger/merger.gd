extends Node2D

signal fire_signal(config)
signal anihilate_signal(config)

signal on_component_placed(node)
signal on_component_lifted(node)

var polar_pos = Vector2i(0,0)
var placed = false

func place(to_coords):
	polar_pos = to_coords
	position = Coords.polar_to_world(polar_pos)
	rotation = position.angle() + PI / 2
	placed = true
	emit_signal("on_component_placed", self)

func lift():
	if placed:
		emit_signal("on_component_lifted", self)

func tick(time):
	pass
	
func start_dragging():
	var draggable = $Draggable
	draggable.mouse_offset = Vector2(0,0) 
	draggable.selected = true
	placed = false
	
func process_signals(signals):
	if !placed:
		return
		
	if signals.size() > 0:
		merge_signals(signals)

func merge_signals(signal_nodes):	
	for result in Global.SPLIT_RULES:
		var prerequisities = Global.SPLIT_RULES[result]
		var can_merge = true
		var sources = []
		var direction = 0
		
		for color_code in prerequisities:
			var idx = signal_nodes.find_custom(func(node): return node.color_code == color_code)
			if idx == -1:
				can_merge = false
			else:
				direction += signal_nodes[idx].direction
				sources.append(signal_nodes[idx])
		
		if can_merge and sources.size() > 0:
			print("SOURCES: " + str(sources.map(func(x): return x.color_code)))
			print("TARGET: " + str(result))
			if direction == 0:
				direction = 1
			if direction < 0:
				direction = -1
			if direction > 0:
				direction = 1
			create_signal(result, polar_pos.y, direction)
			for source in sources:
				source.queue_free()
	
	
func create_signal(color_code, ring_idx, direction):
	emit_signal("fire_signal", {
		"color_code": color_code,
		"ring_idx": ring_idx,
		"segment": polar_pos.x,
		"start_pos": polar_pos,
		"direction": direction
	})
	
	
	
