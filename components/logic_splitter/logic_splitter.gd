extends Node2D

signal fire_signal(config)
signal signal_in_center(config)
signal on_component_placed(node)
signal on_component_lifted(node)
signal on_dragging_over(coords, object)

var polar_pos = Vector2i(0,0)
var placed = false
var direction = -1

const SHAPE = [ Vector2.ZERO, Vector2(0, -1) ]

func emit_draging_over(polar_coords):
	if !placed && polar_coords != Vector2i.ZERO:
		emit_signal("on_dragging_over", polar_coords, self)
		
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
		
	print("PRICESING SIGNALS: " + str(signals))
	if signals.size() > 0:
		copy_signal(signals[0])

func copy_signal(signal_node):
	print("COPYING SIGNAL...")
	create_signal(signal_node.color_code, polar_pos.y + direction, signal_node.direction)
	# $Sfx/Split.play()
			

func create_signal(color_code, ring_idx, direction, signal_node = null):
	if Coords.current_level_config.rings < ring_idx:
		print("ANIHILATED " + color_code)
		emit_signal("anihilate_signal", { 
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
		
	print("CREATED " + color_code + " => " + str(Vector2(polar_pos.x, ring_idx)))
	emit_signal("fire_signal", {
		"color_code": color_code,
		"ring_idx": ring_idx,
		"segment": polar_pos.x,
		"start_pos": Vector2(polar_pos.x, ring_idx),
		"direction": direction
	})
	
func source_rings():
	return [polar_pos.y]	
	
func blocking_rings():
	return [polar_pos.y - 1]
	
	
