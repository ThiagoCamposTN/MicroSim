extends Node


var instrucoes : Array[InstrucaoRes]

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
				instrucoes.append(load(file_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func mnemonico_para_byte(mnemonico: String, endereçamento: Instrucao.Enderecamentos) -> String:
	for instrucao in instrucoes:
		if instrucao.mnemônico == mnemonico:
			match endereçamento:
				Instrucao.Enderecamentos.POS_INDEXADO:
					return instrucao.pos_indexado
				Instrucao.Enderecamentos.PRE_INDEXADO:
					return instrucao.pre_indexado
				Instrucao.Enderecamentos.INDIRETO:
					return instrucao.indireto
				Instrucao.Enderecamentos.IMEDIATO:
					return instrucao.imediato
				Instrucao.Enderecamentos.DIRETO:
					return instrucao.direto
				Instrucao.Enderecamentos.IMPLICITO:
					return instrucao.implicito
				Instrucao.Enderecamentos.INDEXADO:
					return instrucao.indexado
	
	print("Instrução não encontrada.")
	return ""

func byte_para_mnemonico(byte: String) -> Instrucao:
	for instrucao in instrucoes:
		match byte:
			instrucao.pos_indexado:
				return Instrucao.new(Instrucao.Enderecamentos.POS_INDEXADO, instrucao.mnemônico)
			instrucao.pre_indexado:
				return Instrucao.new(Instrucao.Enderecamentos.PRE_INDEXADO, instrucao.mnemônico)
			instrucao.indireto:
				return Instrucao.new(Instrucao.Enderecamentos.INDIRETO, instrucao.mnemônico)
			instrucao.imediato:
				return Instrucao.new(Instrucao.Enderecamentos.IMEDIATO, instrucao.mnemônico)
			instrucao.direto:
				return Instrucao.new(Instrucao.Enderecamentos.DIRETO, instrucao.mnemônico)
			instrucao.implicito:
				return Instrucao.new(Instrucao.Enderecamentos.IMPLICITO, instrucao.mnemônico)
			instrucao.indexado:
				return Instrucao.new(Instrucao.Enderecamentos.INDEXADO, instrucao.mnemônico)
	
	print("Byte não encontrado.")
	return null
