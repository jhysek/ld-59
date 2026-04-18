extends Node

# Polar coordinates: x = segment number, y = ring number
func world_to_polar(world_pos, world_config):
	# get ring number
	var distance = Vector2.ZERO.distance_to(world_pos)
	var ring = floor((distance + world_config.ring_distance / 2) / world_config.ring_distance)

	# get segment number
	var angle = world_pos.angle()

	if angle < 0:
		angle += 2 * PI

	var segment_size = 2 * PI / world_config.segments
	var segment = int(angle / segment_size) % world_config.segments
	
	if ring > world_config.rings || ring == 0:
		ring = 0
		segment = 0
	
	return Vector2i(int(segment), int(ring))
	
	
func polar_to_world(polar_pos, world_config):
	var segment = polar_pos.x
	var ring = polar_pos.y
	
	var segment_size = 2 * PI / world_config.segments
	
	# center angle of the segment
	var angle = (segment + 0.5) * segment_size
	
	# center radius of the ring
	var radius = ring * world_config.ring_distance
	
	return Vector2(cos(angle), sin(angle)) * radius
