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

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: String):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)
	print("Antes: ", Memoria.dados.slice(0,10))

	for linha in linhas:
		var valores = linha.split(" ", false)
		
		if valores[0] == "LDA":
			parte_memoria.push_back(0x20) # LDA
			parte_memoria.push_back(int(valores[1]))
		elif valores[0] == "ABA":
			parte_memoria.push_back(0x48) # ABA
		elif (valores[0] == "CAL" and valores[1] == "EXIT") or valores[0] == "CALEXIT":
			parte_memoria.push_back(0x58)
			parte_memoria.push_back(0x12)
			parte_memoria.push_back(0x00)
	print("Parte: ", PackedByteArray(parte_memoria))
	Memoria.sobrescrever_parte_da_memoria(parte_memoria, Utils.de_hex_string_para_inteiro(endereco_inicial))
	print("Depois: ", Memoria.dados.slice(0,10))
