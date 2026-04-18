extends Node2D

var Ring = preload("res://components/ring/ring.tscn")
var SignalNode = preload("res://components/signal/signal.tscn")

@onready var Rings = get_node("Rings")
@onready var Components = get_node("Components")
@onready var Signals = get_node("Signals")

@export var rings = 4
@export var ring_distance = 50
@export var segments = 8
@export var BPM = 60

var time = 0
var beat_timeout = BPM / 60.0 / float(segments / 4)
var beat_cooldown = beat_timeout

var current_polar_coords = Vector2(0,0)
var current_ring_center = Vector2(0,0)

var ring_data = []

enum States { 
	PAUSED,
	RUNNING
}

var state = States.PAUSED

func _ready():
	Coords.current_level_config = {
		rings = rings,
		ring_distance = ring_distance,
		segments = segments,
		bpm = BPM
	}
	
	refresh_ui()
	initialize_rings()
	initialize_receivers()
	
func _process(delta):
	if state == States.PAUSED:
		return

	Global.TIME = Global.TIME + delta
	
	if beat_cooldown <= 0:
		tick()
		beat_cooldown = beat_timeout
		print(beat_cooldown)
		
	beat_cooldown -= delta
		
	
func tick():
	time += 1
	$Sfx/Tick.play()
	
	propagate_time(time)
	evaluate_components()
	
	refresh_ui()
	
func propagate_time(time):
	for component in Components.get_children():
		component.tick(time)
	
func evaluate_components():
	for component in Components.get_children():
		var signals = []
		for signal_node in Signals.get_children():
			if Vector2i(signal_node.polar_pos) == Vector2i(component.polar_pos):
				signals.append(signal_node)
		if signals.size() > 0:
			component.process_signals(signals)
	
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
		if receiver.is_in_group("receiver"):
			receiver.place(Vector2i(receiver.segment, receiver.ring))
			receiver.fire_signal.connect(spawn_signal)

func signal_in_segment(polar_pos):
	for node in get_tree().get_nodes_in_group("signal"):
		if Vector2i(node.polar_pos) == Vector2i(polar_pos):
			return true
	return false

func spawn_signal(config):
	if signal_in_segment(config.start_pos):
		print("Already existing signal...")
		return
		
	var signal_node = SignalNode.instantiate()
	Signals.add_child(signal_node)
	signal_node.initialize(config.direction, config.start_pos, ring_data[config.start_pos.y - 1].node, config.color, BPM)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		$Label.text = str(mouse_pos)
		
		current_polar_coords = Coords.world_to_polar(mouse_pos)
		current_ring_center = Coords.polar_to_world(current_polar_coords)
			
		highlight_active_segment(current_polar_coords.y, current_polar_coords.x)
		
		$Label.text = $Label.text + "\n RING: " + str(current_polar_coords.y) + "  SEG: " + str(current_polar_coords.x)

	if Input.is_action_just_pressed("ui_accept"):
		if state == States.PAUSED:
			state = States.RUNNING	
		else:
			state = States.PAUSED
		refresh_ui()
		
	if Input.is_action_just_pressed("ui_restart"):
		reset_simulation()
		refresh_ui()
	
func reset_simulation():
	time = 0
	state = States.PAUSED
	for node in Signals.get_children():
		node.queue_free()
		
func refresh_ui():
	$Ticks.text = str(time)
	if time == 0:
		$Paused.text = "Press space to start simulation"
	else:
		$Paused.text = "Simulation paused"
		
	$Paused.visible = state == States.PAUSED
		
func highlight_active_segment(ring_index, ring_segment):
	for ring in ring_data: 
		ring.node.set_active_segments([])
			
	if (ring_index - 1) < rings && ring_index >= 1:
		ring_data[ring_index - 1].node.set_active_segments([ring_segment])
	
