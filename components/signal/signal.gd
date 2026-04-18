extends Node2D


@export var SPEED = 2.0        # radians/sec
@export var ring: Node2D
@export var direction = 1

var angle = 0.0
var center = Vector2.ZERO

func _ready():
	center = position

func _process(delta):
	angle += SPEED * delta * direction
	
	if !ring:
		anihilate()
		return
	
	# Move along circle
	position = center + Vector2(cos(angle), sin(angle)) * ring.radius
	
	# Determine current segment
	var segment = get_segment_from_angle(angle)
	
	# Tell ring to light it
	
	if ring:
		ring.set_active_segments([
			segment,
			#(segment - 1 + SEGMENTS) % SEGMENTS,
			#(segment - 2 + SEGMENTS) % SEGMENTS
		])
	
func get_segment_from_angle(angle: float) -> int:
	var normalized = fmod(angle, PI * 2)
	if normalized < 0:
		normalized += PI * 2
	
	return int(normalized / (PI * 2 / ring.segments))
	
	
func anihilate():
	queue_free()
