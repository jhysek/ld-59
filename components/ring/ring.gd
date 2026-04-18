extends Node2D

@export var radius := 100.0
@export var thickness := 12.0
@export var segments := 8

var active_segments := []

func _draw():
	var angle_per_segment = PI * 2 / segments

	for i in range(segments):
		var start_angle = i * angle_per_segment
		var end_angle = start_angle + angle_per_segment

		var color = Color(0.835, 0.825, 0.81, 0.4)

		if i in active_segments:
			color = Color(1.0, 1.0, 1.0, 0.725)

		draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 32, color, thickness, true)

func highlight_segments(segments):
	set_active_segments(segments)

func set_active_segments(indices: Array):
	active_segments = indices
	queue_redraw()
