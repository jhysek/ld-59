extends Node2D


@export var SPEED = 2.0        # radians/sec
@export var ring_node: Node2D
@export var direction = 1

var previous_time = Global.TIME
var color_code = Global.COLOR_WHITE
var polar_pos = Vector2.ZERO
var lifetime = 0

enum States { 
	INITIALIZING,
	RUNNING,
	GONE	
}

var angle = 0.0
var state = States.INITIALIZING

func initialize(_direction, _polar_position, _ring, _color_code, _bpm):
	polar_pos = _polar_position
	position = Coords.polar_to_world(polar_pos)
	
	direction = _direction 
	ring_node = _ring 
	color_code = _color_code
	state = States.RUNNING
	SPEED = 2 * PI / 8 * _bpm / 60.0 * 2
	angle = position.angle()
	$Sprite.modulate = Global.COLORS[color_code]
	$Sprite/Trail.modulate = Global.COLORS[color_code]

func change_color(new_color_code):
	color_code = new_color_code
	$Sprite.modulate = Global.COLORS[color_code]
	$Sprite/Trail.modulate = Global.COLORS[color_code]
	
func _process(delta):
	if state != States.RUNNING:
		return
		
	var global_delta = Global.TIME - previous_time
	previous_time = Global.TIME
	
	angle += SPEED * global_delta * direction
	lifetime += global_delta
	
	if !ring_node:
		annihilate()
		return
	
	# Move along circle
	position = Vector2.ZERO + Vector2(cos(angle), sin(angle)) * ring_node.radius
	polar_pos = Coords.world_to_polar(position)
	
	
func get_segment_from_angle(angle: float) -> int:
	var normalized = fmod(angle, PI * 2)
	if normalized < 0:
		normalized += PI * 2
	
	return int(normalized / (PI * 2 / ring_node.segments))
	
	
func annihilate():
	queue_free()
