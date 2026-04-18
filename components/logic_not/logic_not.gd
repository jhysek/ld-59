extends Node2D

signal fire_signal(config)
signal signal_in_center(config)
signal on_component_placed(node)
signal on_component_lifted(node)

var polar_pos = Vector2i(0,0)
var placed = false
var direction = -1

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
		negate_signal(signals[0])

func negate_signal(signal_node):
	print("COPYING SIGNAL...")
	var color = Global.COLOR_BLACK
	if signal_node.color_code == Global.COLOR_BLACK:
		color = Global.COLOR_WHITE
	
	signal_node.change_color(color)	
	# $Sfx/Split.play()
			
