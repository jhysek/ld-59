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
var variant = 0
var current_output = Vector2.RIGHT

# output: Vector2(direction, ring_offset)
const VARIANTS = [ 
		{ "scale": Vector2(0.8, 0.8), "output": Vector2(1, 0) }, 
		{ "scale": Vector2(0.8,-0.8), "output": Vector2(1, -1) }, 
		{ "scale": Vector2(-0.8, -0.8), "output": Vector2(-1, -1)  }, 
		{ "scale": Vector2(-0.8, 0.8), "output": Vector2(-1, 0)  } ]
		
func emit_draging_over(polar_coords):
	if !placed && polar_coords != Vector2i.ZERO:
		emit_signal("on_dragging_over", polar_coords, self)
		
func switch_variant():
	variant = (variant + 1) % VARIANTS.size()
	print("SWITCHING VARIANT TO " + str(variant))
	var current_variant = VARIANTS[variant]
	$Sprite.scale = current_variant.scale
	current_output = current_variant.output
	
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
		var s1 = signals.pop_front()
		var s2 = signals.pop_front()
		or_signals(s1, s2)
		
	for signal_node in signals:
		signal_node.annihilate()

func or_signals(signal1, signal2):
	var result = Global.COLOR_BLACK
	if signal1.color_code == Global.COLOR_WHITE || signal2.color_code == Global.COLOR_WHITE:
		result = Global.COLOR_WHITE
	
	if result == Global.COLOR_BLACK:
		Sfx.play("Low")
	else:
		Sfx.play("Higher")
		
	var direction = 1
	if signal1.direction - signal2.direction < 0:
		direction = -1
	
	signal1.state = signal1.States.GONE
	signal2.state = signal2.States.GONE
	signal1.queue_free()
	signal2.queue_free()
	
	create_signal(result, polar_pos.y + current_output.y, current_output.x)

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
	
	
	
