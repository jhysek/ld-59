extends Node2D

@export var rings = 4
@export var ring_distance = 50
@export var segments = 8

var Ring = preload("res://components/ring/ring.tscn")

@onready var Rings = get_node("Rings")


var current_ring_index = 0
var current_ring_segment = 0

var ring_data = []

func _ready():
	initialize()
	
func initialize():
	for i in range(rings):
		var ring = Ring.instantiate()
		ring.radius = (i + 1) * ring_distance
		ring.thickness = 4 + i
		ring.segments = segments
		
		ring_data.append({
			radius = ring.radius,
			segments = ring.segments,
			node = ring
		})
		Rings.add_child(ring)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		$Label.text = str(mouse_pos)
		
		current_ring_index = get_current_ring_index(mouse_pos)
		current_ring_segment = get_current_ring_segment(mouse_pos)
		
		if current_ring_index > rings || current_ring_index == 0:
			current_ring_index = 0
			current_ring_segment = 0
		
		highlight_active_segment(current_ring_index, current_ring_segment)
		
		$Label.text = $Label.text + " RING: " + str(current_ring_index) + "  SEG: " + str(current_ring_segment)
	
	
func highlight_active_segment(ring_index, ring_segment):
	for ring in ring_data: 
		ring.node.set_active_segments([])
			
	if (ring_index - 1) < rings && ring_index >= 1:
		ring_data[ring_index - 1].node.set_active_segments([ring_segment])
	
func get_current_ring_index(mouse_pos):
	var distance = Vector2(0,0).distance_to(mouse_pos)
	return floor((distance + ring_distance / 2) / ring_distance)

func get_current_ring_segment(mouse_pos):
	var angle = mouse_pos.angle()

	if angle < 0:
		angle += 2 * PI

	var segment_size = 2 * PI / segments
	return int(angle / segment_size) % segments
