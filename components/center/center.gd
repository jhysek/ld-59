extends Node2D

func pulse():
	$AnimationPlayer.play("Pulse")

func set_color(color_code):
	if color_code and Global.COLORS.has(color_code):
		$Sprite.modulate = Global.COLORS[color_code]
		$PointLight2D.modulate = Global.COLORS[color_code]
