extends Node

var memory_size : int = 4096 # 0x1000
var memory_location_path = ""
var memory_data = null

func _enter_tree():
	self.memory_location_path = "res://MEMORIA.MEM"
	load_memory(self.memory_location_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_memory(memory_path):
	var file := FileAccess.open(memory_path, FileAccess.READ)
	self.memory_size = file.get_length()
	self.memory_data = file.get_buffer(memory_size)
	file.close()
