extends Panel

signal on_goal_achieved
signal on_signal_rejected
signal on_signal_consumed

@export var DISTANCE = 30
@onready var cursor = $Colors/Cursor

var texture = load("res://components/goal_indicator/circle.png")

var goal = []
var cursor_idx = 0

func init(_goal):
	goal = _goal
	reset()
	
func reset():
	cursor_idx = 0
	
	$Colors/Cursor.show()
	$Colors/Cursor.position = Vector2(0,0)
	
	for goal in $Colors.get_children():
		if goal.name != "Cursor":
			goal.queue_free()
			
	var idx = 0
	for color in goal:
		var sprite = Sprite2D.new()
		sprite.scale = Vector2(0.1, 0.1)
		sprite.texture = texture
		$Colors.add_child(sprite)
		sprite.name = "Goal" + str(idx)
		sprite.position = Vector2(idx * DISTANCE, 0)	
		sprite.modulate = Global.COLORS[color]
		idx += 1
	cursor.position = Vector2(cursor_idx * DISTANCE, 0)
	
func next_expected():
	if goal.size() > cursor_idx:
		return goal[cursor_idx]
	else:
		return null
	
func consume_signal(color_code):
	if cursor_idx >= goal.size():
		return
			
	if goal[cursor_idx] != color_code:
		emit_signal("on_signal_rejected", color_code)
		$Sfx/Rejected.play()
		return
		
	emit_signal("on_signal_consumed", color_code)
	$Sfx/Consumed.play()
	
	cursor_idx += 1
	if cursor_idx >= goal.size():
		emit_signal("on_goal_achieved")
		cursor.hide()
				
	cursor.position = Vector2(cursor_idx * DISTANCE, 0)
	
	var idx = 0
	for goal in $Colors.get_children():
		if goal.name != "Cursor":
			print("IDX: " + str(idx) + " -  CURSOR IDX " + str(cursor_idx))
			if idx < cursor_idx:
				goal.self_modulate = Color(1,1,1,0.4)
			else:
				goal.self_modulate = Color(1,1,1,1)
			idx += 1
	 	
func update_indicator():
	pass
	
