extends Node

var current_level = 0

var levels = [
	"res://levels/level01.tscn",
	"res://levels/level02.tscn",
	"res://levels/level03.tscn",
	"res://levels/level04.tscn",
	"res://levels/finished.tscn"
]

func _ready():
	set_process_input(true)

	if Input.is_key_pressed(KEY_N) and Input.is_key_pressed(KEY_SHIFT):
		next_level()

func get_current_level():
	return levels[current_level]

func restart_level():
	start_level()

func start_level():
	if Global.opened_levels < current_level + 1:
		Global.opened_levels = current_level + 1
	Transition.switchTo(levels[current_level])

func next_level():
	current_level += 1

	if current_level < levels.size():
		if Global.opened_levels < current_level + 1:
			Global.opened_levels = current_level + 1
		start_level()
