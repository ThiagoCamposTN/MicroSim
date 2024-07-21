extends Node

var memory_file_path 	: String 	= ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recarregar_memoria():
	var file : FileAccess = FileAccess.open(self.memory_file_path, FileAccess.READ)
	var dados = file.get_buffer(file.get_length())
	Memoria.sobrescrever_memoria(dados)
	file.close()

func alterar_caminho_memoria(caminho : String):
	self.memory_file_path = caminho
	self.recarregar_memoria()

func executar_codigo(endereco_inicial : String, codigo : String):
	var endereco 		: int 				= Utils.de_hex_string_para_inteiro(endereco_inicial)
	var codigo_divido 	: PackedStringArray = codigo.split("\n")
	#
	#print("codigo")
	#print(endereco)
	#print(codigo_divido[1])
