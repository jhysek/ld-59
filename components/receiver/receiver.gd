extends Node2D

@export var delay_ticks = 4
@export var segment = 0
@export var ring = 0


func place(target_ring, target_segment, world_config):
	ring = target_ring
	segment = target_segment
	position = Coords.polar_to_world(Vector2(segment, ring), world_config)
	rotation = position.angle() + PI / 2
