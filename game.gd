extends Node2D

var Ring = preload("res://components/ring/ring.tscn")
var SignalNode = preload("res://components/signal/signal.tscn")
var Splitter = preload("res://components/splitter/splitter.tscn")
var Merger = preload("res://components/merger/merger.tscn")
var Mover = preload("res://components/mover/mover.tscn")

@onready var Rings = get_node("Rings")
@onready var Components = get_node("Components")
@onready var Signals = get_node("Signals")
@onready var GoalIndicator = get_node("CanvasLayer/Control/GoalIndicator")

@export var rings = 4
@export var ring_distance = 50
@export var segments = 8
@export var BPM = 60
@export var GOAL = ["MAGENTA", "MAGENTA", "MAGENTA"]

var time = 0
var consumed = []
var beat_timeout = (60 / float(BPM)) / 2.0 # float(segments)  # 1 beat = 1 segment  BPM = SPM  #(BPM / 60.0 / float(segments / 4))
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
	print("BPM: " + str(BPM))
	print("length of a beat: " + str(beat_cooldown))
		
	Coords.current_level_config = {
		rings = rings,
		ring_distance = ring_distance,
		segments = segments,
		bpm = BPM
	}
	
	refresh_ui()
	$CanvasLayer/Control/GoalIndicator.init(GOAL)
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
	
	highlight_active_segments()
	
	
func highlight_active_segments():
	var positions = {}
	for signal_node in Signals.get_children():
		var ring = str(int(signal_node.polar_pos.y - 1))
		if !positions.has(ring):
			positions[ring] = []
		positions[ring].append(signal_node.polar_pos.x)
	
	if positions == {}:
		return
	
	var idx = 0
	for ring in ring_data:
		if positions.has(str(idx)):
			ring.node.highlight_segments(positions[str(idx)])
		idx = idx + 1
		
	
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
	
			# Connect new signal triggers
			receiver.fire_signal.connect(spawn_signal)


func same_signal_in_segment(polar_pos, color_code):
	for node in get_tree().get_nodes_in_group("signal"):
		if Vector2i(node.polar_pos) == Vector2i(polar_pos) and  node.color_code == color_code:
			return true
	return false

func spawn_signal(config):
	if same_signal_in_segment(config.start_pos, config.color_code):
		print("Already existing signal...")
		return
		
	var signal_node = SignalNode.instantiate()
	Signals.add_child(signal_node)
	signal_node.initialize(config.direction, config.start_pos, ring_data[config.start_pos.y - 1].node, config.color_code, BPM)

func consume_signal(config):
	GoalIndicator.consume_signal(config.color_code)
	config.signal_node.queue_free()
	consumed.append(config.color_code)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		$Label.text = str(mouse_pos)
		
		current_polar_coords = Coords.world_to_polar(mouse_pos)
		current_ring_center = Coords.polar_to_world(current_polar_coords)
			
		# highlight_active_segment(current_polar_coords.y, current_polar_coords.x)
		
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
	consumed = []
	state = States.PAUSED
	$CanvasLayer/Control/GoalIndicator.reset()
	for node in Signals.get_children():
		node.queue_free()
		
func refresh_ui():
	$Ticks.text = "TICKS: " + str(time)
	
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
	

## Component palette start dragging ############################################

func _on_splitter_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var splitter = Splitter.instantiate()
			$Components.add_child(splitter)
		
			splitter.position = get_global_mouse_position()
			splitter.start_dragging()
			connect_splitter_signals(splitter)

func _on_merger_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var merger = Merger.instantiate()
			$Components.add_child(merger)
		
			merger.position = get_global_mouse_position()
			merger.start_dragging()
			connect_merger_signals(merger)

func _on_mover_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mover = Mover.instantiate()
			$Components.add_child(mover)
		
			mover.position = get_global_mouse_position()
			mover.start_dragging()
			connect_mover_signals(mover)
			
## Component signals ###############################################
func connect_splitter_signals(splitter):
	if splitter.is_in_group("splitter"):
		splitter.fire_signal.connect(spawn_signal)
		splitter.signal_in_center.connect(consume_signal)
		# splitter.anihilate_signal.connect(anihilate_signal)

func connect_merger_signals(merger):
	if merger.is_in_group("merger"):
		merger.fire_signal.connect(spawn_signal)

func connect_mover_signals(mover):
	if mover.is_in_group("mover"):
		mover.fire_signal.connect(spawn_signal)
		mover.signal_in_center.connect(consume_signal)
		
		


## Goal indicator handlers #####################################################
func _on_goal_indicator_on_goal_achieved() -> void:
	state = States.PAUSED
	print("WIN!!!")

func _on_goal_indicator_on_signal_rejected() -> void:
	state = States.PAUSED
	print("LOSE!!!")
