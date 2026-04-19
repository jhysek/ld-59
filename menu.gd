extends Node2D

func _ready():
	Transition.openScene()
	
	if LevelSwitcher.current_level > 0:
		var btn = get_node("Button")
		if btn:
			btn.text = "Continue game"

func _on_button_pressed() -> void:
	LevelSwitcher.start_level()	

func _on_back_pressed() -> void:
	LevelSwitcher.current_level = 0
	Transition.switchTo("res://menu.tscn")
