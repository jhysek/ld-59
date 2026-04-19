extends Node2D

signal fire_signal(config)
signal signal_in_center(config)
signal on_component_placed(node)
signal on_component_lifted(node)

var polar_pos = Vector2i(0,0)
var placed = false
var direction = -1

func can_be_placed(to_coords):
	if to_coords.y == 1 or to_coords.y > Coords.current_level_config.rings:
		return false
	
	return true

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
	
func source_rings():
	return [polar_pos.y, polar_pos.y - 1]
	
func process_signals(signals):
	if !placed:
		return
		
	print("PROCESING SIGNALS: " + str(signals))
	if signals.size() > 1:
		or_signals(signals[0], signals[1])

func or_signals(signal1, signal2):
	var result = Global.COLOR_BLACK
	if signal1.color_code == Global.COLOR_WHITE || signal2.color_code == Global.COLOR_WHITE:
		result = Global.COLOR_WHITE
	
	var direction = 1
	if signal1.direction - signal2.direction < 0:
		direction = -1
	
	signal1.state = signal1.States.GONE
	signal2.state = signal2.States.GONE
	signal1.queue_free()
	signal2.queue_free()
	
	create_signal(result, polar_pos.y, direction)

	# $Sfx/Split.play()
	

func create_signal(color_code, ring_idx, direction, signal_node = null):
	# print("CREATED " + color_code + " => " + str(Vector2(polar_pos.x, ring_idx)))
	emit_signal("fire_signal", {
		"color_code": color_code,
		"ring_idx": ring_idx,
		"segment": polar_pos.x,
		"start_pos": Vector2(polar_pos.x, ring_idx),
		"direction": direction,
		"force": true
	})
	
	
	
