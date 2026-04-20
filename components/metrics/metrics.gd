extends Panel

func _ready():
	reset()
	
func set_time_metric(time):
	$Time.text = "Time: " + str(time)
	
func set_size_metric(number_of_components):
	$Size.text = "Size: " + str(number_of_components)

func reset():
	$Time.text = "Time: 0"
	$Size.text = "Size: 0"
