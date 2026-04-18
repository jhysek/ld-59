extends Node2D


signal fire_signal(config)
signal anihilate_signal(config)
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
	
func switch_variant():
	direction = direction * -1
	if direction == -1:
		$Sprite.rotation_degrees = 180
	else: 
		$Sprite.rotation_degrees = 0

	
func process_signals(signals):
	if !placed:
		return
		
	if signals.size() > 0:
		move_signal(signals[0])

func move_signal(signal_node):
	var target_ring = polar_pos.y + direction
	if target_ring > Coords.current_level_config.rings:
		emit_signal("anihilate_signal", { 
			"color_code": signal_node.color_code,
			"ring_idx": target_ring,
			"segment": polar_pos.x
		})
		signal_node.anihilate()
		return 
	
	if target_ring == 0:
		emit_signal("signal_in_center", {
			"signal_node": signal_node,
			"color_code": signal_node.color_code 
		})
		return
	
	emit_signal("fire_signal", {
		"color_code": signal_node.color_code,
		"ring_idx": target_ring,
		"segment": polar_pos.x,
		"start_pos": Vector2(polar_pos.x, target_ring),
		"direction": signal_node.direction
	})
	$Sfx/Move.play()
	signal_node.queue_free()
	
	
