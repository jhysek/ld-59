extends Line2D

var previous_pos: Vector2 = Vector2.ZERO 
var signal_radius = 10

func _ready():
	var texture = get_parent().texture
	signal_radius = texture.get_size().x * 0.5 
	previous_pos = get_parent().global_position
	
func _process(delta):
	var current_pos = get_parent().global_position
	var direction = (current_pos - previous_pos).normalized()
	add_point(current_pos - signal_radius * direction)
	if points.size() > 30:
		remove_point(0)

	previous_pos = current_pos
