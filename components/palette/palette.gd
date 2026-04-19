extends Panel

var distance = 80

func initialize(allowed_commands):
	var idx = 0
	for tool in get_children():
		if tool.name != "Label":
			if !allowed_commands.has(tool.name):
				tool.queue_free()
			else:
				tool.position.y = idx * distance + 94
				print("SETTING TOOL POS TO " + str(tool.position.y ))
				idx += 1
				
			
			
