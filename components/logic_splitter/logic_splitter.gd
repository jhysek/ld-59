extends Node2D

signal fire_signal(config)
signal signal_in_center(config)
signal on_component_placed(node)
signal on_component_lifted(node)
signal on_dragging_over(coords, object)

var polar_pos = Vector2i(0,0)
var placed = false
var direction = -1
var variant = 0
var current_outputs = [Vector2(0, -1), Vector2(1, 0)]

# output: Vector2(direction, ring_offset)
const VARIANTS = [ 
	{ "rotation": PI / 2.0, "outputs": [Vector2(0, 0), Vector2(0, -1)] },
	{ "rotation": 0, "outputs": [Vector2(0, 0), Vector2(0, 1)] }, 	
	{ "rotation": - PI / 2.0, "outputs": [Vector2(-1, 0), Vector2(0, 1)] }, 	
	{ "rotation": - PI , "outputs": [Vector2(-1, 0), Vector2(0, -1)] }, 
	]
		
const SHAPE = [ Vector2.ZERO ]

func emit_draging_over(polar_coords):
	if !placed && polar_coords != Vector2i.ZERO:
		emit_signal("on_dragging_over", polar_coords, self)
		
func _ready():
	var current_variant = VARIANTS[variant]
	$Sprite.rotation = current_variant.rotation
	current_outputs = current_variant.outputs
		
func switch_variant():
	variant = (variant + 1) % VARIANTS.size()
	print("SWITCHING VARIANT TO " + str(variant))
	var current_variant = VARIANTS[variant]
	$Sprite.rotation = current_variant.rotation
	current_outputs = current_variant.outputs
	
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
		# Take the first signal
		var first_signal = signals.pop_front()
		copy_signal(first_signal)
		
		# Drop the rest
		for signal_node in signals:
			signal_node.annihilate()
		

func copy_signal(signal_node):
	signal_node.state = signal_node.States.GONE
	for output in current_outputs:
		var result_direction = output.x
		if result_direction == 0:
			result_direction = signal_node.direction
		
		create_signal(signal_node.color_code, polar_pos.y + output.y, result_direction)
		
	signal_node.queue_free()
	$Sfx/Split.play()
			

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
	
	
