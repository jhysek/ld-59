extends Node2D

@export var radius := 100.0
@export var thickness := 12.0
@export var segments := 8

var active_segments := []
var standard_color = Color(0.0, 0.0, 0.0, 0.4)
var active_color = Color(0.3, 0.3, 0.3, 0.776)

func _draw():
	var angle_per_segment = PI * 2 / segments

	for i in range(segments):
		var start_angle = i * angle_per_segment
		var end_angle = start_angle + angle_per_segment

		var color = Color(0.0, 0.0, 0.0, 0.4)

		if i in active_segments:
			color = active_color

		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 32, color, thickness, true)

func highlight_segments(segments, color = null):
	print("ACTIVE SEGS: " + str(segments))
	set_active_segments(segments, color)

func set_active_segments(indices: Array, color = null):
	active_segments = indices
	if color:
		active_color = color
	queue_redraw()
