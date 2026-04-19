extends Panel

var distance = 80

func initialize(allowed_commands):
	for tool in get_children():
		if tool.name != "Label":
			if !allowed_commands.has(tool.name):
				tool.queue_free()
				
	var idx = 0
	for tool in get_children():
		if tool.name != "Label":
			tool.position.y = idx * distance + 94
			idx += 1
