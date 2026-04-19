extends CPUParticles2D

func _on_finished() -> void:
	queue_free()

func explode():
	$Sfx/Explode.play()
	emitting = true
