extends Node

var operacoes : Array[Operador]

# Called when the node enters the scene tree for the first time.
func _ready():
	carregar_recursos()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func carregar_recursos():
	var path = "res://Resources/"
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var file_path = path + file_name
				operacoes.append(load(file_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func encontrar_operador(mnemonico: String) -> Operador:
	for operador in operacoes:
		if operador.mnemônico == mnemonico:
			return operador
	return null

func mnemonico_para_byte(mnemonico: String, endereçamento: Instrucao.Enderecamentos) -> String:
	var operacao = encontrar_operador(mnemonico)
	if operacao:
		match endereçamento:
			Instrucao.Enderecamentos.POS_INDEXADO:
				return operacao.pos_indexado
			Instrucao.Enderecamentos.PRE_INDEXADO:
				return operacao.pre_indexado
			Instrucao.Enderecamentos.INDIRETO:
				return operacao.indireto
			Instrucao.Enderecamentos.IMEDIATO:
				return operacao.imediato
			Instrucao.Enderecamentos.DIRETO:
				return operacao.direto
			Instrucao.Enderecamentos.IMPLICITO:
				return operacao.implicito
			Instrucao.Enderecamentos.INDEXADO:
				return operacao.indexado
	
	print("Instrução não encontrada.")
	return ""

func byte_para_mnemonico(byte: String) -> Instrucao:
	for operacao in operacoes:
		match byte.to_upper():
			operacao.pos_indexado:
				return Instrucao.new(Instrucao.Enderecamentos.POS_INDEXADO, operacao.mnemônico)
			operacao.pre_indexado:
				return Instrucao.new(Instrucao.Enderecamentos.PRE_INDEXADO, operacao.mnemônico)
			operacao.indireto:
				return Instrucao.new(Instrucao.Enderecamentos.INDIRETO, operacao.mnemônico)
			operacao.imediato:
				return Instrucao.new(Instrucao.Enderecamentos.IMEDIATO, operacao.mnemônico)
			operacao.direto:
				return Instrucao.new(Instrucao.Enderecamentos.DIRETO, operacao.mnemônico)
			operacao.implicito:
				return Instrucao.new(Instrucao.Enderecamentos.IMPLICITO, operacao.mnemônico)
			operacao.indexado:
				return Instrucao.new(Instrucao.Enderecamentos.INDEXADO, operacao.mnemônico)
	return null

func get_microcodigos(mnemonico: String):
	var operacao = encontrar_operador(mnemonico)
	if operacao != null:
		return operacao.microcodigos
	return null
