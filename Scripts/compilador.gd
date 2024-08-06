class_name Compilador

static func compilar(linha : String) -> Instrucao:
	var mnemonico 	= linha.substr(0, 3)
	var restante 	= linha.substr(3, -1)
	
	# Endereçamento implicito
	if not restante:
		return Instrucao.new(Instrucao.Enderecamentos.IMPLICITO, mnemonico)
	
	# Endereçamento pré-indexado
	var enderecamento_pre_indexado = detectar_parametros(restante, r'\[(.+?),(.+?)\]')
	if enderecamento_pre_indexado:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.PRE_INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_pre_indexado)
		return instrucao
	
	# Endereçamento pós-indexado
	var enderecamento_pos_indexado = detectar_parametros(restante, r'\[(.+?)\],(.+)')
	if enderecamento_pos_indexado:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.POS_INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_pos_indexado)
		return instrucao
	
	# Endereçamento indireto
	var enderecamento_indireto = detectar_parametros(restante, r'\[(.+?)\]')
	if enderecamento_indireto:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.INDIRETO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_indireto)
		return instrucao
	
	# Endereçamento indexado
	var enderecamento_indexado = detectar_parametros(restante, r'(.+?),.+')
	if enderecamento_indexado:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.INDEXADO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_indexado)
		return instrucao
	
	# Endereçamento imediato
	var enderecamento_imediato = detectar_parametros(restante, r'#(.+)')
	if enderecamento_imediato:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.IMEDIATO, mnemonico)
		instrucao.parametros = extrair_parametros(enderecamento_imediato)
		return instrucao
	
	# Endereçamento direto
	var enderecamento_direto = detectar_parametros(restante, r'(.+)')
	if enderecamento_direto:
		var instrucao := Instrucao.new(Instrucao.Enderecamentos.DIRETO, mnemonico)
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

static func descompilar(opcode_hex : String) -> Instrucao:
	match opcode_hex:
		# LDA
		"10":
			return Instrucao.new(Instrucao.Enderecamentos.DIRETO, "LDA")
		"20":
			return Instrucao.new(Instrucao.Enderecamentos.IMEDIATO, "LDA")
		"30":
			return Instrucao.new(Instrucao.Enderecamentos.INDEXADO, "LDA")
		"90":
			return Instrucao.new(Instrucao.Enderecamentos.INDIRETO, "LDA")
		"C0":
			return Instrucao.new(Instrucao.Enderecamentos.PRE_INDEXADO, "LDA")
		"B0":
			return Instrucao.new(Instrucao.Enderecamentos.POS_INDEXADO, "LDA")
		
		# LDB
		"50":
			return Instrucao.new(Instrucao.Enderecamentos.DIRETO, "LDB")
		"60":
			return Instrucao.new(Instrucao.Enderecamentos.IMEDIATO, "LDB")
		
		#ABA
		"48":
			return Instrucao.new(Instrucao.Enderecamentos.IMPLICITO, "ABA")
		
		#STA
		"11":
			return Instrucao.new(Instrucao.Enderecamentos.DIRETO, "STA")
		
		# STB
		"51":
			return Instrucao.new(Instrucao.Enderecamentos.DIRETO, "STB")
		"71":
			return Instrucao.new(Instrucao.Enderecamentos.INDEXADO, "STB")
		"D1":
			return Instrucao.new(Instrucao.Enderecamentos.INDIRETO, "STB")
		"F1":
			return Instrucao.new(Instrucao.Enderecamentos.PRE_INDEXADO, "STB")
		"E1":
			return Instrucao.new(Instrucao.Enderecamentos.POS_INDEXADO, "STB")
		
		"58": # CAL - endereçamento
			return Instrucao.new(Instrucao.Enderecamentos.DIRETO, "CAL")
		_:
			# comando invalido
			return null

static func buscar_parametros_na_memoria(endereco : int, tipo_enderecamento : Instrucao.Enderecamentos) -> PackedStringArray:
	var parametros : PackedStringArray
	
	match tipo_enderecamento:
		Instrucao.Enderecamentos.POS_INDEXADO:
			pass
		Instrucao.Enderecamentos.PRE_INDEXADO:
			pass
		Instrucao.Enderecamentos.INDIRETO:
			pass
		Instrucao.Enderecamentos.IMEDIATO:
			parametros.push_back(Memoria.ler_hex_no_endereco(endereco + 1))
		Instrucao.Enderecamentos.DIRETO:
			parametros.push_back(Memoria.ler_hex_no_endereco(endereco + 1))
			parametros.push_back(Memoria.ler_hex_no_endereco(endereco + 2))
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			parametros.push_back(Memoria.ler_hex_no_endereco(endereco + 1))
			parametros.push_back(Memoria.ler_hex_no_endereco(endereco + 2))
		_:
			pass
	
	return parametros
