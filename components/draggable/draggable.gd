extends Area2D

@export var parent_object: Node2D

var selected = false
var placed_at = Vector2.ZERO
var mouse_offset = Vector2.ZERO

func _ready():
	parent_object = get_parent()
	assert(parent_object)
	
func _process(delta):
	if selected:
		parent_object.position = get_global_mouse_position() + mouse_offset 
		parent_object.rotation = parent_object.position.angle() + PI / 2
		
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = parent_object.position - get_global_mouse_position()
			selected = true
		else:
			selected = false
			dropped()

func dropped():
	placed_at = Coords.world_to_polar(parent_object.position)
	if placed_at != Vector2i.ZERO:
		parent_object.place(placed_at)
		#parent_object.position = Coords.polar_to_world(placed_at)
		#parent_object.rotation = parent_object.position.angle() + PI / 2
		print("DROPPED TO " + str(placed_at))
	else:
		print("DELETED...")
	pass
