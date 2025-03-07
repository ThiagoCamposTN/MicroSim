class_name Compilador

static func compilar(linha : String) -> Instrucao:
	var mnemonico	: String = linha.substr(0, 3)
	var restante	: String = linha.substr(3, -1)

	var enderecamento		: Instrucao.Enderecamentos 	= detectar_enderecamento(restante)
	var parametro_detectado	: RegExMatch 				= detectar_parametro(restante, enderecamento)
	var parametro			: Valor 					= extrair_parametro(parametro_detectado)
	var instrucao			: Instrucao 				= Instrucao.new(mnemonico, enderecamento)
	instrucao.parametro = parametro

	return instrucao

static func detectar_enderecamento(texto : String = "") -> Instrucao.Enderecamentos:
	# Endereçamento pré-indexado
	var enderecamento_pre_indexado: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.PRE_INDEXADO)
	if enderecamento_pre_indexado:
		return Instrucao.Enderecamentos.PRE_INDEXADO

	# Endereçamento pós-indexado
	var enderecamento_pos_indexado: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.POS_INDEXADO)
	if enderecamento_pos_indexado:
		return Instrucao.Enderecamentos.POS_INDEXADO
	
	# Endereçamento indireto
	var enderecamento_indireto: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.INDIRETO)
	if enderecamento_indireto:
		return Instrucao.Enderecamentos.INDIRETO
	
	# Endereçamento indexado
	var enderecamento_indexado: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.INDEXADO)
	if enderecamento_indexado:
		return Instrucao.Enderecamentos.INDEXADO

	# Endereçamento imediato
	var enderecamento_imediato: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.IMEDIATO)
	if enderecamento_imediato:
		return Instrucao.Enderecamentos.IMEDIATO
	
	# Endereçamento direto
	var enderecamento_direto: RegExMatch = detectar_parametro(texto, Instrucao.Enderecamentos.DIRETO)
	if enderecamento_direto:
		return Instrucao.Enderecamentos.DIRETO
	
	# Endereçamento implicito
	return Instrucao.Enderecamentos.IMPLICITO

static func obter_regra_de_enderecamento(enderecamento: Instrucao.Enderecamentos) -> String:
	match enderecamento:
		Instrucao.Enderecamentos.PRE_INDEXADO:
			return  r'\[(.+?),\s*?X\s*?\]'
		Instrucao.Enderecamentos.POS_INDEXADO:
			return r'\[(.+?)\]\s*,\s*X'
		Instrucao.Enderecamentos.INDIRETO:
			return r'\[(.+?)\]'
		Instrucao.Enderecamentos.INDEXADO:
			return r'(.+?)\s*,\s*X'
		Instrucao.Enderecamentos.IMEDIATO:
			return r'#(.+?)'
		Instrucao.Enderecamentos.DIRETO:
			return r'(.+?)'
		_:
			# Endereçamento implicito
			return r''

static func detectar_parametro(texto : String, enderecamento: Instrucao.Enderecamentos) -> RegExMatch:
	var regex := RegEx.new()
	regex.compile(obter_regra_de_enderecamento(enderecamento))
	var resultado: RegExMatch = regex.search(texto)
	return resultado

static func extrair_parametro(parametro : RegExMatch) -> Valor:
	var resultados : PackedStringArray = parametro.get_strings()
	var _parametro : PackedStringArray 
	resultados.remove_at(0)
	for i in resultados:
		_parametro.push_back(i.strip_edges())
	return Valor.novo_de_hex("".join(_parametro))

static func descompilar(opcode: Valor) -> Instrucao:
	var instrucao_em_hex: String = opcode.como_hex(2)
	return Operacoes.byte_para_mnemonico(instrucao_em_hex)

static func buscar_parametro_na_memoria(endereco_inicial: Valor, tamanho: int) -> Valor:
	var parametro_em_bytes: PackedByteArray
	for endereco: int in range(endereco_inicial.como_int(), endereco_inicial.como_int() + tamanho):
		var valor_endereco	: Valor = Valor.new(endereco)
		var conteudo_memoria: Valor = Memoria.ler_conteudo_no_endereco(valor_endereco)
		parametro_em_bytes.append(conteudo_memoria.como_int())
	return Valor.novo_de_byte_array(parametro_em_bytes)
