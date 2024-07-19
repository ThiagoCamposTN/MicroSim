extends VBoxContainer

@export var line_scene : Resource

# Called when the node enters the scene tree for the first time.
func _ready():
	var memory_size : int = SoftwareManager.memory_data.size()
	var total_lines = range(0, memory_size, 16)
	for i in total_lines:
		var new_line = line_scene.instantiate()
		new_line.set_line_number(i)
		var line_data = SoftwareManager.memory_data.slice(i, i+16)
		new_line.set_values(line_data)
		add_child(new_line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
