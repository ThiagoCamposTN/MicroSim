extends Node

var memory_size 		: int 		= 4096 # 0x1000
var memory_file_path 	: String 	= ""

var memory_data 		: PackedByteArray


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recarregar_memoria():
	var file : FileAccess = FileAccess.open(self.memory_file_path, FileAccess.READ)
	self.memory_data = file.get_buffer(file.get_length())
	file.close()

func alterar_caminho_memoria(caminho : String):
	self.memory_file_path = caminho
	self.recarregar_memoria()
