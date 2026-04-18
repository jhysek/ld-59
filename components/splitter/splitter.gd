extends Node2D

signal fire_signal(config)
signal annihilate_signal(config)
signal signal_in_center(config)

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
		split_signal(signals[0])

func split_signal(signal_node):
	if Global.SPLIT_RULES.has(signal_node.color_code):
		var new_signals = Global.SPLIT_RULES[signal_node.color_code]
		signal_node.queue_free()
		
		if new_signals.size() == 3:
			create_signal(new_signals[0], polar_pos.y + 1, signal_node.direction)
			create_signal(new_signals[1], polar_pos.y, signal_node.direction)
			create_signal(new_signals[2], polar_pos.y - 1, signal_node.direction, signal_node)
			$Sfx/Split.play()
			
		if new_signals.size() == 2:
			create_signal(new_signals[0], polar_pos.y + 1, signal_node.direction)
			create_signal(new_signals[1], polar_pos.y - 1, signal_node.direction, signal_node)	
			$Sfx/Split.play()
	else:
		print("NO SPLIT RULE FOR COLOR: " + str(signal_node.color_code))
	
func create_signal(color_code, ring_idx, direction, signal_node = null):
	print("MAX: " + str(Coords.current_level_config.rings ) + "    current: " + str(ring_idx))
	if Coords.current_level_config.rings < ring_idx:
		print("ANNIHILATED " + color_code)
		emit_signal("annihilate_signal", { 
			"color_code": color_code,
			"ring_idx": ring_idx,
			"segment": polar_pos.x
		})
		return 
			
	if ring_idx == 0:
		emit_signal("signal_in_center", {
			"color_code": color_code,
			signal_node: signal_node
		})
		return
		
	print("CREATED " + color_code)
	emit_signal("fire_signal", {
		"color_code": color_code,
		"ring_idx": ring_idx,
		"segment": polar_pos.x,
		"start_pos": Vector2(polar_pos.x, ring_idx),
		"direction": direction
	})
	
	
	
