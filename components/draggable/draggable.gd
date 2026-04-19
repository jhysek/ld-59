extends Area2D

var Explosion = preload("res://components/explosion/explosion.tscn")

@export var parent_object: Node2D

var selected = false
var placed_at = Vector2.ZERO
var mouse_offset = Vector2.ZERO

# I know... but I don't have much time left
@onready var map = get_node("/root/Game")

func _ready():
	parent_object = get_parent()
	assert(parent_object)
	
func _process(delta):
	if selected:
		parent_object.position = get_global_mouse_position() + mouse_offset 
		parent_object.rotation = parent_object.position.angle() + PI / 2
		parent_object.polar_pos = Coords.world_to_polar(parent_object.position)
			
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			selected = false
			map.set_dragging(false)
			dropped()
		
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_offset = parent_object.position - get_global_mouse_position()
			selected = true
			map.set_dragging(true)
			if parent_object.placed:
				parent_object.lift()
				
			parent_object.placed = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_RIGHT and event.pressed:
		if parent_object.is_in_group("mover"):
			parent_object.switch_variant()

func dropped():
	placed_at = Coords.world_to_polar(parent_object.position)
		
	if !can_be_placed(placed_at):
		print("NONONONE")
		explode()
		parent_object.queue_free()

	if placed_at != Vector2i.ZERO:
		parent_object.place(placed_at)
		#parent_object.position = Coords.polar_to_world(placed_at)
		#parent_object.rotation = parent_object.position.angle() + PI / 2
		print("DROPPED TO " + str(placed_at))
	else:
		explode()
		parent_object.queue_free()
	pass

func explode():
	var explosion = Explosion.instantiate()
	map.add_child(explosion)
	explosion.position = global_position
	explosion.explode()

	

func can_be_placed(polar_coord):
	for pos in parent_object.SHAPE:
		if map.is_occupied(Vector2i(polar_coord) + Vector2i(pos)):
			return false
	return true
