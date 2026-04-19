extends Node2D

var tween

func play():
	if $Tune.playing:
		return
		
	$Tune.volume_db = -90
	$Tune.play()
	fade_in()


func fade_in():
	if tween: 
		tween.stop()
	print("FADING IN")
	tween = get_tree().create_tween()
	tween.tween_property($Tune, 'volume_db', -10, 3)
		
		
func fade_out():
	if tween:
		tween.stop()
	print("FADING OUT")
	tween = get_tree().create_tween()
	tween.tween_property($Tune, 'volume_db', -80, 2)
	tween.tween_callback(func(): $Tune.stop())
