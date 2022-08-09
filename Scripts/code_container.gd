extends VBoxContainer

onready var line_prefab = preload("res://Objects/hex_line.tscn") 


# Called when the node enters the scene tree for the first time.
func _ready():
	var total_lines = range(0, SoftwareManager.memory_size, 16)
	for i in total_lines:
		var new_line = line_prefab.instance()
		new_line.set_line_number(i)
		var line_data = SoftwareManager.memory_data.subarray(i, i+15)
		new_line.set_values(line_data)
		add_child(new_line)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
