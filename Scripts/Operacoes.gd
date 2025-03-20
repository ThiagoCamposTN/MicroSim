extends Node

var operacoes: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.carregar_recursos()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func carregar_recursos() -> void:
	var caminho = "res://Resources/"
	
	var diretorio = DirAccess.open(caminho)
	if diretorio:
		diretorio.list_dir_begin()
		var nome_arquivo = diretorio.get_next()
		while nome_arquivo != "":
			if not diretorio.current_is_dir():
				var caminho_arquivo = caminho + nome_arquivo
				var operador: Operador = load(caminho_arquivo)
				operacoes[operador.mnemônico] = operador
			nome_arquivo = diretorio.get_next()
	else:
		print("Ocorreu um erro ao tentar acessar o caminho.")

func obter_operador(mnemonico: String) -> Operador:
	if not mnemonico in operacoes:
		return null
	return operacoes[mnemonico]

func mnemonico_para_byte(mnemonico: String, endereçamento: Instrucao.Enderecamentos) -> String:
	var operacao = obter_operador(mnemonico)
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

func opcode_para_instrucao(opcode: Valor) -> Instrucao:
	for operacao: Operador in operacoes.values():
		match opcode.como_hex(2):
			operacao.pos_indexado:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.POS_INDEXADO)
			operacao.pre_indexado:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.PRE_INDEXADO)
			operacao.indireto:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.INDIRETO)
			operacao.imediato:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.IMEDIATO)
			operacao.direto:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.DIRETO)
			operacao.implicito:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.IMPLICITO)
			operacao.indexado:
				return Instrucao.new(operacao.mnemônico, Instrucao.Enderecamentos.INDEXADO)
	return null

func obter_microoperacoes(mnemonico: String) -> Array:
	var operacao: Operador = obter_operador(mnemonico)
	if operacao != null:
		return operacao.microoperacoes
	return []
