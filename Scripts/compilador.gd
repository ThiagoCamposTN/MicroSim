class_name Compilador

static func compilar(linha : String) -> Instrucao:
	var mnemonico 	= linha.substr(0, 3)
	var restante 	= linha.substr(3, -1)
	
	# Endereçamento implicito
	if not restante:
		return Instrucao.new(mnemonico, Instrucao.Enderecamentos.IMPLICITO)
	
	# Endereçamento pré-indexado
	var enderecamento_pre_indexado = detectar_parametros(restante, r'\[(.+?),\s*?X\s*?\]')
	if enderecamento_pre_indexado:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.PRE_INDEXADO)
		instrucao.parametros = extrair_parametros(enderecamento_pre_indexado)
		return instrucao
	
	# Endereçamento pós-indexado
	var enderecamento_pos_indexado = detectar_parametros(restante, r'\[(.+?)\]\s*,\s*X')
	if enderecamento_pos_indexado:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.POS_INDEXADO)
		instrucao.parametros = extrair_parametros(enderecamento_pos_indexado)
		return instrucao
	
	# Endereçamento indireto
	var enderecamento_indireto = detectar_parametros(restante, r'\[(.+?)\]')
	if enderecamento_indireto:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.INDIRETO)
		instrucao.parametros = extrair_parametros(enderecamento_indireto)
		return instrucao
	
	# Endereçamento indexado
	var enderecamento_indexado = detectar_parametros(restante, r'(.+?)\s*,\s*X')
	if enderecamento_indexado:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.INDEXADO)
		instrucao.parametros = extrair_parametros(enderecamento_indexado)
		return instrucao
	
	# Endereçamento imediato
	var enderecamento_imediato = detectar_parametros(restante, r'#(.+)')
	if enderecamento_imediato:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.IMEDIATO)
		instrucao.parametros = extrair_parametros(enderecamento_imediato)
		return instrucao
	
	# Endereçamento direto
	var enderecamento_direto = detectar_parametros(restante, r'(.+)')
	if enderecamento_direto:
		var instrucao := Instrucao.new(mnemonico, Instrucao.Enderecamentos.DIRETO)
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

static func descompilar(opcode: Valor) -> Instrucao:
	var instrucao_em_hex: String = opcode.como_hex(2)
	return Operacoes.byte_para_mnemonico(instrucao_em_hex)

static func buscar_parametros_na_memoria(endereco_inicial: Valor, tamanho: int) -> Valor:
	var parametro_em_bytes: PackedByteArray
	for endereco: int in range(endereco_inicial.como_int(), endereco_inicial.como_int() + tamanho):
		var valor_endereco	: Valor = Valor.new(endereco)
		var conteudo_memoria: Valor = Memoria.ler_conteudo_no_endereco(valor_endereco)
		parametro_em_bytes.append(conteudo_memoria.como_int())
	return Valor.novo_de_byte_array(parametro_em_bytes)
