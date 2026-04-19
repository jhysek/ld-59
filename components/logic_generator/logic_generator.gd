extends Node2D

signal fire_signal(config)

@export var delay_ticks = 4
@export var delay_offset = 0
@export var segment = 0
@export var ring = 0
@export var direction = 1
@export var color_code = "WHITE"
@export var clock = false

@onready var anim = $AnimationPlayer

var polar_pos = Vector2.ZERO 
const SHAPE = [ Vector2.ZERO ]
var placed = true

func _ready():
	$Box/Arrow.modulate = Global.COLORS[color_code]
	$Box/Dot.modulate = Global.COLORS[color_code]
	if direction == 1:
		$Box.rotation_degrees = 180
	

func place(polar_coords: Vector2i):
	ring = polar_coords.y
	segment = polar_coords.x
	position = Coords.polar_to_world(polar_coords)
	rotation = position.angle() + PI / 2
	polar_pos = polar_coords

func tick(time):
	if (time - delay_offset) % delay_ticks == 0:
		fire()
		return
	else:
		if clock:
			fire(Global.COLOR_BLACK)
			return
		
	anim.stop()	
	anim.play("Pulse")

func fire(signal_color = color_code):
	anim.play("Fire")
	if signal_color == Global.COLOR_BLACK:
		$Sfx/Black.play()
	else:
		$Sfx/White.play()
		
	emit_signal("fire_signal", signal_config(signal_color))

func signal_config(signal_color = color_code):
	return {
		direction = direction,
		start_pos = Vector2(segment, ring),
		color_code = signal_color,
		force = true
	}

func process_signals(signals):
	for signal_node in signals:
		print("SIGNALS: " + str(signal_node.lifetime))
		if signal_node.lifetime > 1:
			signal_node.annihilate()
			
func blocking_rings():
	return [polar_pos.y]
