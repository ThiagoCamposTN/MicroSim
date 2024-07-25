extends Node

class_name CODEC

enum Enderecamentos { POS_INDEXADO, PRE_INDEXADO, INDIRETO, IMEDIATO, DIRETO, IMPLICITO, INDEXADO }

class Instrucao:
	var tipo 		: Enderecamentos
	var mnemonico	: String
	var parametros	: PackedStringArray
	
	func _init(tipo : Enderecamentos, mnemonico : String):
		self.tipo = tipo
		self.mnemonico = mnemonico

static func codificar(linha : String) -> Instrucao:
	var mnemonico 	= linha.substr(0, 3)
	var restante 	= linha.substr(3, -1)
	
	# Endereçamento implicito
	if not restante:
		return Instrucao.new(Enderecamentos.IMPLICITO, mnemonico)
	
	# Endereçamento pré-indexado
	var enderecamento_pre_indexado = detectar_parametros(restante, r'\[(.+?),(.+?)\]')
	if enderecamento_pre_indexado:
		var instrucao := Instrucao.new(Enderecamentos.PRE_INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_pre_indexado)
		return instrucao
	
	# Endereçamento pós-indexado
	var enderecamento_pos_indexado = detectar_parametros(restante, r'\[(.+?)\],(.+)')
	if enderecamento_pos_indexado:
		var instrucao := Instrucao.new(Enderecamentos.POS_INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_pos_indexado)
		return instrucao
	
	# Endereçamento indireto
	var enderecamento_indireto = detectar_parametros(restante, r'\[(.+?)\]')
	if enderecamento_indireto:
		var instrucao := Instrucao.new(Enderecamentos.INDIRETO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_indireto)
		return instrucao
	
	# Endereçamento indexado
	var enderecamento_indexado = detectar_parametros(restante, r'(.+?),(.+)')
	if enderecamento_indexado:
		var instrucao := Instrucao.new(Enderecamentos.INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_indexado)
		return instrucao
	
	# Endereçamento imediato
	var enderecamento_imediato = detectar_parametros(restante, r'#(.+)')
	if enderecamento_imediato:
		var instrucao := Instrucao.new(Enderecamentos.IMEDIATO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_imediato)
		return instrucao
	
	# Endereçamento direto
	var enderecamento_direto = detectar_parametros(restante, r'(.+)')
	if enderecamento_direto:
		var instrucao := Instrucao.new(Enderecamentos.DIRETO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_direto)
		return instrucao
	
	return null

static func detectar_parametros(string_com_parametros : String, expressao_regex : String) -> RegExMatch:
	var regex := RegEx.new()
	regex.compile(expressao_regex)
	var enderecamento = regex.search(string_com_parametros)
	return enderecamento

static func extrair_parametros(parametros_detectados : RegExMatch):
	var resultados : PackedStringArray = parametros_detectados.get_strings()
	var parametros : PackedStringArray 
	resultados.remove_at(0)
	for i in resultados:
		parametros.push_back(i.strip_edges())
	return parametros
