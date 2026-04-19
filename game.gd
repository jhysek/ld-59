extends Node2D

var Ring = preload("res://components/ring/ring.tscn")
var SignalNode = preload("res://components/signal/signal.tscn")
var Splitter = preload("res://components/splitter/splitter.tscn")
var Merger = preload("res://components/merger/merger.tscn")
var Mover = preload("res://components/mover/mover.tscn")
var LogicCopy = preload("res://components/logic_splitter/logic_splitter.tscn")
var LogicNot = preload("res://components/logic_not/logic_not.tscn")
var LogicAnd = preload("res://components/logic_and/logic_and.tscn")
var LogicOr = preload("res://components/logic_or/logic_or.tscn")
var Explosion = preload("res://components/explosion/explosion.tscn")
var Alternator = preload("res://components/alternator/alternator.tscn")
var LogicBranch = preload("res://components/logic_branch/logic_branch.tscn")

@onready var Rings = get_node("Rings")
@onready var Components = get_node("Components")
@onready var Signals = get_node("Signals")
@onready var GoalIndicator = get_node("CanvasLayer/Control/GoalIndicator")
@onready var Metrics = get_node("CanvasLayer/Control/Metrics")
@onready var Center = get_node("Center")

@export var title = "Level 01"
@export var rings = 4
@export var ring_distance = 50
@export var segments = 8
@export var BPM = 60
@export var GOAL = ["BLACK", "WHITE", "BLACK", "WHITE"]
@export var ring_color = Color(0.303, 0.303, 0.303, 0.4)

@export var ENABLED_TOOLS = ["Mover"]

var time = 0
var consumed = []
var beat_timeout = (60 / float(BPM)) / 2.0 # float(segments)  # 1 beat = 1 segment  BPM = SPM  #(BPM / 60.0 / float(segments / 4))
var beat_cooldown = beat_timeout

var current_polar_coords = Vector2(0,0)
var current_ring_center = Vector2(0,0)
var dragging = false

var ring_data = []

enum States { 
	PAUSED,
	RUNNING,
	DRAGGING,
	REJECTED,
	FINISHED
}

var state = States.PAUSED

func _ready():
	randomize()
	Loops.fade_out()
	Transition.openScene()
	
	if Engine.is_editor_hint():
		initialize_rings()
		return
		
	print("BPM: " + str(BPM))
	print("length of a beat: " + str(beat_cooldown))
		
	Coords.current_level_config = {
		rings = rings,
		ring_distance = ring_distance,
		segments = segments,
		bpm = BPM
	}
	
	refresh_ui()
	initialize_title()
	initialize_tools()
	$CanvasLayer/Control/GoalIndicator.init(GOAL)
	initialize_rings()
	initialize_receivers()
	initialize_center()
	
## Initialization ##############################################################
func initialize_title():
	$CanvasLayer/LevelTitle.text = title
	$CanvasLayer/LevelTitle/LevelTitleCyan.text = title
	$CanvasLayer/LevelTitle/LevelTitleMagenta.text = title
	
func initialize_tools():
	$CanvasLayer/Palette.initialize(ENABLED_TOOLS)
		
func initialize_center():
	Center.set_color(GOAL[0])
	
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


## Godot standard handlers #####################################################
func _process(delta):
	# $Lights.rotation -= delta * 0.1
	if state == States.PAUSED or state == States.REJECTED or state == States.FINISHED:
		return

	Global.TIME = Global.TIME + delta
	
	if beat_cooldown <= 0:
		tick()
		beat_cooldown = beat_timeout
		print(beat_cooldown)
		
	beat_cooldown -= delta
	
	highlight_active_segments()
	
func _input(event):		
	if state == States.FINISHED:
		return
		
	if event is InputEventKey and state == States.REJECTED:
		$CanvasLayer/InfoBox.hide()
		state = States.PAUSED
		return
		
	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		$Label.text = str(mouse_pos)
		
		current_polar_coords = Coords.world_to_polar(mouse_pos)
		current_ring_center = Coords.polar_to_world(current_polar_coords)
					
		$Label.text = $Label.text + "\n RING: " + str(current_polar_coords.y) + "  SEG: " + str(current_polar_coords.x) + " DRAGGING: " + str(dragging) + " OCCUPIED: " + str(is_occupied(current_polar_coords))
		if dragging:
			if is_occupied(current_polar_coords):
				highlight_segments([current_polar_coords], Global.COLOR_RED)
			else:
				highlight_segments([], Global.COLOR_RED)
		
		
	if Input.is_action_just_pressed("ui_accept"):
		if state == States.PAUSED:
			state = States.RUNNING	
			$CanvasLayer/Control/Panel/Button.text = "⏸"
			$CanvasLayer/InfoBox.hide()
		else:
			state = States.PAUSED
			$CanvasLayer/Control/Panel/Button.text = "▶"
		refresh_ui()
		
	if Input.is_action_just_pressed("ui_restart"):
		reset_simulation()
		refresh_ui()

## code spaghetti ingredients....

# Does any component occupy given coordinate?
func is_occupied(polar_pos: Vector2i):
	for component in Components.get_children():
		if component.placed:
			for coord in component.SHAPE:
				if polar_pos == Vector2i(component.polar_pos) + Vector2i(coord):
					return true
	return false
	
func set_dragging(_dragging):
	if dragging == _dragging:
		return
		
	state = States.PAUSED
	Loops.fade_out()
	reset_simulation()
		
	dragging = _dragging
	if !dragging:
		print("NO DRAGGING")
		highlight_segments([], ring_color)
	refresh_component_metric()

func highlight_active_segments():
	var positions = {}
	for signal_node in Signals.get_children():
		var ring = str(int(signal_node.polar_pos.y - 1))
		if !positions.has(ring):
			positions[ring] = []
		positions[ring].append(signal_node.polar_pos.x)
	
	#if positions == {}:
	#	return
	
	var idx = 0
	for ring in ring_data:
		if positions.has(str(idx)):
			ring.node.highlight_segments(positions[str(idx)], ring_color)
		else:
			ring.node.highlight_segments([], ring_color)
		idx = idx + 1
		
func tick():
	time += 1
	$Sfx/Tick.play()
	
	if time == 8:

		Loops.play()
	
	evaluate_components()
	propagate_time(time)
	refresh_ui()
	
func propagate_time(time):
	for component in Components.get_children():
		component.tick(time)
	
func evaluate_components():
	for component in Components.get_children():
		annihilate_blocked_signals(component)
		evaluate_source_signals(component)

func annihilate_blocked_signals(component):
	if !component.has_method("blocking_rings"):
		return
	
	for ring_idx in component.blocking_rings():
		var source_polar_pos = Vector2i(component.polar_pos.x, ring_idx)
		for signal_node in Signals.get_children():
			if Vector2i(signal_node.polar_pos) == source_polar_pos:
				print("ANNIHILATING: " + str(source_polar_pos))
				# Do not annihilate signals that were just created
				if signal_node.lifetime > 1:
					signal_node.annihilate()

func evaluate_source_signals(component):
	var signals = []
	var source_rings = [component.polar_pos.y]
	
	if component.has_method("source_rings"):
		source_rings = component.source_rings()
	
	for ring_idx in source_rings:
		var source_polar_pos = Vector2i(component.polar_pos.x, ring_idx)
		for signal_node in Signals.get_children():
			if Vector2i(signal_node.polar_pos) == source_polar_pos:
				signals.append(signal_node)
				
	if signals.size() > 0:
		component.process_signals(signals)


func same_signal_in_segment(polar_pos, color_code):
	for node in get_tree().get_nodes_in_group("signal"):
		if Vector2i(node.polar_pos) == Vector2i(polar_pos) and  node.color_code == color_code and node.state != node.States.GONE:
			return true
	return false
	
func annihilate_colliding_signals(polar_pos):
	for node in get_tree().get_nodes_in_group("signal"):
		if Vector2i(node.polar_pos) == Vector2i(polar_pos):
			node.annihilate()

func spawn_signal(config):
	annihilate_colliding_signals(config.start_pos)
	if false and !config.has("force") and same_signal_in_segment(config.start_pos, config.color_code):
		print("Already existing signal...")
		explode(Coords.polar_to_world(config.start_pos))
		
		return
		
	var signal_node = SignalNode.instantiate()
	if config.has("lifetime"):
		signal_node.lifetime = config.lifetime + 1
		
	Signals.add_child(signal_node)
	signal_node.initialize(config.direction, config.start_pos, ring_data[config.start_pos.y - 1].node, config.color_code, BPM)

func consume_signal(config):
	GoalIndicator.consume_signal(config.color_code)
	Center.set_color(GoalIndicator.next_expected())
	consumed.append(config.color_code)
	print(consumed)

	
func reset_simulation():
	time = 0
	Metrics.set_time_metric(time)
	consumed = []
	state = States.PAUSED
	Loops.fade_out()
	$CanvasLayer/Control/GoalIndicator.reset()
	for node in Signals.get_children():
		node.annihilate()
	
	# reset alternator
	for alternator in get_tree().get_nodes_in_group("alternator"):
		alternator.reset_to_initial_position()
		
		
func refresh_ui():
	$Ticks.text = "TICKS: " + str(time)
	Metrics.set_time_metric(time)
	$Center.pulse()
	
	if time == 0:
		$Paused.text = "Press [space] to start simulation"
	else:
		$Paused.text = "Simulation paused"
		
	$Paused.visible = state == States.PAUSED
	
		
func highlight_active_segment(ring_index, ring_segment):
	for ring in ring_data: 
		ring.node.set_active_segments([])
			
	if (ring_index - 1) < rings && ring_index >= 1:
		ring_data[ring_index - 1].node.set_active_segments([ring_segment])
	

func component_placed():
	$Sfx/Placed.play()
	refresh_component_metric()
	state = States.PAUSED
	reset_simulation()
	
func component_lifted():
	$Sfx/Lifted.play()
	refresh_component_metric()
	state = States.PAUSED
	reset_simulation()
	
func component_dragging(polar_pos, component_node):
	pass

func highlight_segments(segments, color):
	var positions = {}
	
	for segment in segments:
		var ring = str(int(segment.y - 1))
		if !positions.has(ring):
			positions[ring] = []
		positions[ring].append(segment.x)
	
	var idx = 0
	for ring in ring_data:
		if positions.has(str(idx)):
			ring.node.highlight_segments(positions[str(idx)], color)
		else:
			ring.node.highlight_segments([])
		idx = idx + 1

func refresh_component_metric():
	var count = 0
	for component in $Components.get_children():
		if !component.is_in_group("receiver"):
			count += 1
	
	Metrics.set_size_metric(count)
	
## Component palette start dragging ############################################

func _on_splitter_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var splitter = Splitter.instantiate()
			$Components.add_child(splitter)
		
			splitter.position = get_global_mouse_position()
			splitter.start_dragging()
			dragging = true
			connect_splitter_signals(splitter)
			Sfx.play("Picked")

func _on_merger_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var merger = Merger.instantiate()
			$Components.add_child(merger)
			
			merger.position = get_global_mouse_position()
			merger.start_dragging()
			dragging = true
			connect_merger_signals(merger)
			Sfx.play("Picked")

func _on_mover_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mover = Mover.instantiate()
			$Components.add_child(mover)
		
			mover.position = get_global_mouse_position()
			mover.start_dragging()
			dragging = true
			connect_mover_signals(mover)
			Sfx.play("Picked")
	
func _on_logic_copy_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = LogicCopy.instantiate()
			$Components.add_child(component)
		
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_coppier_signals(component)
			Sfx.play("Picked")

func _on_logic_not_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = LogicNot.instantiate()
			$Components.add_child(component)
		
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_not_signals(component)
			Sfx.play("Picked")

func _on_logic_and_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = LogicAnd.instantiate()
			$Components.add_child(component)
			print("CLICKED ON AND 0 " + str(component))
				
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_and_signals(component)
			Sfx.play("Picked")

func _on_logic_or_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = LogicOr.instantiate()
			$Components.add_child(component)
		
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_or_signals(component)
			Sfx.play("Picked")
		
func _on_alternator_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = Alternator.instantiate()
			$Components.add_child(component)
		
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_alternator_signals(component)
			Sfx.play("Picked")
		
func _on_logic_branch_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var component = LogicBranch.instantiate()
			$Components.add_child(component)
		
			component.position = get_global_mouse_position()
			component.start_dragging()
			dragging = true
			connect_logic_branch_signals(component)
			Sfx.play("Picked")
	
## Component signals ###############################################
func connect_splitter_signals(splitter):
	if splitter.is_in_group("splitter"):
		splitter.fire_signal.connect(spawn_signal)
		splitter.signal_in_center.connect(consume_signal)
		splitter.on_component_placed.connect(component_placed)
		splitter.on_component_lifted.connect(component_lifted)
		# splitter.annihilate_signal.connect(annihilate_signal)

func connect_merger_signals(merger):
	if merger.is_in_group("merger"):
		merger.fire_signal.connect(spawn_signal)
		merger.on_component_placed.connect(component_placed)
		merger.on_component_lifted.connect(component_lifted)

func connect_mover_signals(component):
	if component.is_in_group("mover"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)
		
func connect_coppier_signals(component):
	if component.is_in_group("coppier"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)

func connect_not_signals(component):
	if component.is_in_group("logic_not"):
		component.fire_signal.connect(spawn_signal)
		connect_placement_signals(component)

func connect_and_signals(component):
	if component.is_in_group("logic_and"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)
			
func connect_or_signals(component):
	if component.is_in_group("logic_or"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)
		
func connect_alternator_signals(component):
	if component.is_in_group("alternator"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)
		
func connect_logic_branch_signals(component):
	if component.is_in_group("logic_branch"):
		component.fire_signal.connect(spawn_signal)
		component.signal_in_center.connect(consume_signal)
		connect_placement_signals(component)
		
func connect_placement_signals(component):
	component.on_component_placed.connect(component_placed)
	component.on_component_lifted.connect(component_lifted)
	component.on_dragging_over.connect(component_dragging)
		
## Goal indicator handlers #####################################################
func _on_goal_indicator_on_goal_achieved() -> void:
	state = States.FINISHED
	$CanvasLayer/InfoBox/Title.text = "Signal successfully transmitted!"
	$CanvasLayer/InfoBox.show()
	$Timer.start()

func _on_goal_indicator_on_signal_rejected(color_code) -> void:
	reset_simulation()
	Loops.fade_out()
	state = States.REJECTED
	$CanvasLayer/InfoBox/Title.text = "Incorrect signal transmitted!\n\npress any key..."
	$CanvasLayer/InfoBox.show()


func explode(pos):
	var explosion = Explosion.instantiate()
	add_child(explosion)
	explosion.position = pos
	explosion.explode()

func _on_timer_timeout() -> void:
	LevelSwitcher.next_level()


func _on_goal_indicator_on_signal_consumed(color_code) -> void:
	pass

func _on_reset_pressed() -> void:
	reset_simulation()

func _on_button_pressed() -> void:
	if state == States.FINISHED:
		return
		
	if state == States.PAUSED:
		state = States.RUNNING	
		$CanvasLayer/Control/Panel/Button.text = "⏸"
		$CanvasLayer/InfoBox.hide()
	else:
		state = States.PAUSED
		Loops.fade_out()
		$CanvasLayer/Control/Panel/Button.text = "▶"
