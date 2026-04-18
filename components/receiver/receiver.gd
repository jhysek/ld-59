extends Node2D

@export var delay_ticks = 4
@export var segment = 0
@export var ring: Node2D = null


func place(target_ring, target_segment):
	ring = target_ring
	segment = target_segment
	
	# TODO: 
	# - get position and angle of given segment in given ring
	
