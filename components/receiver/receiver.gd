extends Node2D

signal fire_signal(config)

@export var delay_ticks = 4
@export var delay_offset = 0
@export var segment = 0
@export var ring = 0
@export var direction = 1
@export var color_code = "WHITE"

var polar_pos = Vector2.ZERO 
const SHAPE = [ Vector2.ZERO ]

func place(polar_coords: Vector2i):
	ring = polar_coords.y
	segment = polar_coords.x
	position = Coords.polar_to_world(polar_coords)
	rotation = position.angle() + PI / 2
	polar_pos = polar_coords

func tick(time):
	if (time - delay_offset) % delay_ticks == 0:
		fire()

func fire():
	if color_code == Global.COLOR_CYAN:
		$Sfx/Fire2.play()
	else:
		$Sfx/Fire.play()
	emit_signal("fire_signal", signal_config())

func signal_config():
	return {
		direction = direction,
		start_pos = Vector2(segment, ring),
		color_code = color_code
	}

func process_signals(signals):
	pass
