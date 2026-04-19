extends Node2D


signal fire_signal(config)
signal annihilate_signal(config)
signal signal_in_center(config)

signal on_component_placed(node)
signal on_component_lifted(node)
signal on_dragging_over(coords, object)

var polar_pos = Vector2i(0,0)
var placed = false
var direction = -1

var variant = 0
var alternative = 0
var current_output = Vector2(0, -1)

# output: Vector2(direction, ring_offset)
const VARIANTS = [ 
		{ "rotation": PI / 2.0, "outputs": [Vector2(0, -1), Vector2(0, 0)] }, 
		{ "rotation": 0, "outputs": [Vector2(1, 0), Vector2(0, 1)] }, 
		{ "rotation": PI, "outputs": [Vector2(-1, 0), Vector2(0, -1)]  }, 
		{ "rotation": 3 * PI / 2.0, "outputs": [Vector2(0, 1), Vector2(-1, 0)]  } 
	]

const SHAPE = [ Vector2.ZERO ]

func _ready():
	var current_variant = VARIANTS[variant]
	$Box.rotation = current_variant.rotation
	current_output = current_variant.outputs[alternative]
	
func switch_variant():
	variant = (variant + 1) % VARIANTS.size()
	print("SWITCHING VARIANT TO " + str(variant))
	var current_variant = VARIANTS[variant]
	$Box.rotation = current_variant.rotation
	current_output = current_variant.outputs[alternative]
	
func emit_draging_over(polar_coords):
	if !placed && polar_coords != Vector2.ZERO:
		emit_signal("on_dragging_over", polar_coords, self)
		
func alternate():
	alternative = (alternative + 1) % 2
	var current_variant = VARIANTS[variant]
	current_output = current_variant.outputs[alternative]
	
	if $Box/Arrow.rotation == 0:
		$Box/Arrow.rotation = - PI / 2.0
	else: 
		$Box/Arrow.rotation = 0
		
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
		move_signal(signals[0])
		alternate()

func move_signal(signal_node):
	$AnimationPlayer.play("Pulse")
	var target_ring = polar_pos.y + current_output.y
	
	if target_ring > Coords.current_level_config.rings:
		#emit_signal("annihilate_signal", { 
		#	"color_code": signal_node.color_code,
		#	"ring_idx": target_ring,
		#	"segment": polar_pos.x
		#})
		signal_node.annihilate()
		return 
	
	if target_ring == 0:
		emit_signal("signal_in_center", {
			"signal_node": signal_node, 
			"color_code": signal_node.color_code 
		})
		return
	
	var result_direction = current_output.x
	if result_direction == 0:
		result_direction = signal_node.direction
		
	signal_node.state = signal_node.States.GONE
	print("FIRING TO ring: " + str(target_ring) + " direction: " + str(result_direction))
	emit_signal("fire_signal", {
		"color_code": signal_node.color_code,
		"ring_idx": target_ring,
		"segment": polar_pos.x,
		"start_pos": Vector2(polar_pos.x, target_ring),
		"direction": result_direction,
		"lifetime": signal_node.lifetime
	})
	$Sfx/Move.play()
	
	signal_node.queue_free()
	
	
