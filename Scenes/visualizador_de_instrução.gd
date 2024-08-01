extends VBoxContainer

# baseado em ghidra e em cheat engine


# Called when the node enters the scene tree for the first time.
func _ready():
	SoftwareManager.alterar_caminho_memoria("res://MEMORIA.MEM")
	descompilar_a_partir_do_endereco("FE0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func descompilar_a_partir_do_endereco(endereco : String):
	var endereco_int 	: int 		= Utils.de_hex_string_para_inteiro(endereco)
	var valor 			: String
	var instrucao_atual : Instrucao
	
	while endereco_int < Memoria.celulas.size():
		valor 			= Memoria.ler_hex_no_endereco(endereco_int)
		instrucao_atual = Compilador.descompilar(valor)
		
		if instrucao_atual:
			instrucao_atual.opcode 		= valor
			instrucao_atual.parametros 	= Compilador.buscar_parametros_na_memoria(endereco_int, instrucao_atual.enderecamento)
		
		# Parte do endereço
		
		var label_endereco := Label.new()
		label_endereco.text = Utils.int_para_hex(endereco_int, 3)
		$ScrollContainer/GridContainer.add_child(label_endereco)
		
		# Parte dos bytes
		
		var label_bytes := Label.new()
		label_bytes.text = valor
		endereco_int += 1
		
		if instrucao_atual and instrucao_atual.parametros.size():
			label_bytes.text += " " + " ".join(instrucao_atual.parametros)
			endereco_int += instrucao_atual.parametros.size()
		
		$ScrollContainer/GridContainer.add_child(label_bytes)
		
		# Parte da instrução
		
		var label_instrucao := Label.new()
		
		if instrucao_atual:
			label_instrucao.text = instrucao_atual.instrucao_em_string()
		else:
			label_instrucao.text = "??"
		
		$ScrollContainer/GridContainer.add_child(label_instrucao)
