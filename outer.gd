extends Sprite2D

@export var SPEED = 0.1

func _process(delta):
	rotation += delta * SPEED
