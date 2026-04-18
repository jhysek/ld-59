extends Node2D

@export var rings = 4
@export var ring_distance = 50
@export var segments = 8

var Ring = preload("res://components/ring/ring.tscn")

@onready var Rings = get_node("Rings")


var current_ring_index = 0
var current_ring_segment = 0
var current_polar_coords = Vector2(0,0)
var current_ring_center = Vector2(0,0)

var ring_data = []

func _ready():
	initialize_rings()
	initialize_receivers()
	
func initialize_rings():
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

func initialize_receivers():
	for receiver in $Components.get_children():
		receiver.place(receiver.segment, receiver.ring, self)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		$Label.text = str(mouse_pos)
		
		current_polar_coords = Coords.world_to_polar(mouse_pos, self)
		current_ring_center = Coords.polar_to_world(current_polar_coords, self)
		$Components/Receiver.position = current_ring_center
		$Components/Receiver.rotation = current_ring_center.angle() + PI / 2
			
		highlight_active_segment(current_polar_coords.y, current_polar_coords.x)
		
		$Label.text = $Label.text + "\n RING: " + str(current_polar_coords.y) + "  SEG: " + str(current_polar_coords.x)

		
func highlight_active_segment(ring_index, ring_segment):
	for ring in ring_data: 
		ring.node.set_active_segments([])
			
	if (ring_index - 1) < rings && ring_index >= 1:
		ring_data[ring_index - 1].node.set_active_segments([ring_segment])
	
