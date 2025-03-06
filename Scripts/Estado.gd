extends Node


signal sobrecarregar_memoria


func obter_memoria_do_arquivo(arquivo: String) -> PackedByteArray:
	if (not arquivo) or (typeof(arquivo) != TYPE_STRING):
		push_error("Valor de \"memoria\" é inválido.")
		return []

	var dados_memoria: PackedByteArray = self.obter_valores_memoria_base(arquivo)
	
	return dados_memoria

func obter_valores_memoria_base(arquivo: String) -> PackedByteArray:
	if not FileAccess.file_exists(arquivo):
		push_error("Arquivo de memoria \"" + arquivo + "\" não existe")
		return []
	
	var file 	: FileAccess 		= FileAccess.open(arquivo, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	file.close()
	return dados

func obter_substituicoes_memoria(arquivo: String) -> PackedByteArray:
	if not FileAccess.file_exists(arquivo):
		push_error("Arquivo de memoria \"" + arquivo + "\" não existe")
		return []
	
	var file 	: FileAccess 		= FileAccess.open(arquivo, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	file.close()
	return dados

func obter_configuração_de_estado(caminho) -> ConfigFile:
	# carrega o arquivo de estado
	var config : ConfigFile = ConfigFile.new()
	var err = config.load(caminho)

	if err != OK:
		push_error("Erro na leitura do arquivo de estado \"" + caminho + "\"")
		return

	return config

func realizar_substituicoes_memoria(memoria: PackedByteArray, substituicoes: Dictionary) -> PackedByteArray:
	for endereco in substituicoes:
		var valor = substituicoes[endereco]
		var endereco_convertido = Valor.novo_de_hex(endereco)
		var dado_convertido = Valor.novo_de_hex(valor)
		memoria.set(endereco_convertido.como_int(), dado_convertido.como_int())
	return memoria


func carregar_estado(caminho: String = "res://padrão.sta") -> void:
	# carrega o arquivo de estado
	var config: ConfigFile = self.obter_configuração_de_estado(caminho)

	if not config:
		return
	
	# carrega a memória base
	var nome_arquivo_memoria = config.get_value("inicio", "memoria.base", "")
	var memoria = self.obter_memoria_do_arquivo(nome_arquivo_memoria)

	# carrega as substituições de células de memória se existirem
	var novos_valores_memoria = config.get_value("inicio", "memoria.substituicoes", {})
	memoria = self.realizar_substituicoes_memoria(memoria, novos_valores_memoria)
	self.sobrecarregar_memoria.emit(memoria)
	
	# carrega os registradores
	var registrador_a = config.get_value("inicio", "registrador.a", "0")
	var registrador_b = config.get_value("inicio", "registrador.b", "0")
	var registrador_pc = config.get_value("inicio", "registrador.pc", "0")
	var registrador_pp = config.get_value("inicio", "registrador.pp", "0")
	var registrador_aux = config.get_value("inicio", "registrador.aux", "0")
	var registrador_ir = config.get_value("inicio", "registrador.ir", "0")
	var registrador_ix = config.get_value("inicio", "registrador.ix", "0")
	var registrador_mbr = config.get_value("inicio", "registrador.mbr", "0")
	var registrador_mar = config.get_value("inicio", "registrador.mar", "0")

	CPU.atualizar_registrador_a(Valor.novo_de_hex(registrador_a))
	CPU.atualizar_registrador_b(Valor.novo_de_hex(registrador_b))
	CPU.iniciar_registrador_pc(Valor.novo_de_hex(registrador_pc))
	CPU.atualizar_registrador_pp(Valor.novo_de_hex(registrador_pp))
	CPU.atualizar_registrador_aux(Valor.novo_de_hex(registrador_aux))
	CPU.atualizar_registrador_ir(Valor.novo_de_hex(registrador_ir))
	CPU.atualizar_registrador_ix(Valor.novo_de_hex(registrador_ix))
	CPU.atualizar_registrador_mbr(Valor.novo_de_hex(registrador_mbr))
	CPU.atualizar_registrador_mar(Valor.novo_de_hex(registrador_mar))

	# carrega as flags
	var flag_z = config.get_value("inicio", "flag.z", "0")
	var flag_n = config.get_value("inicio", "flag.n", "0")
	var flag_c = config.get_value("inicio", "flag.c", "0")
	var flag_o = config.get_value("inicio", "flag.o", "0")

	CPU.atualizar_flag_z(Valor.novo_de_hex(flag_z))
	CPU.atualizar_flag_n(Valor.novo_de_hex(flag_n))
	CPU.atualizar_flag_c(Valor.novo_de_hex(flag_c))
	CPU.atualizar_flag_o(Valor.novo_de_hex(flag_o))

	SoftwareManager.fila_instrucoes.clear()

	# carrega o programa
	var programa = config.get_value("inicio", "instrucoes", [])
	Programa.programa_carregado.emit(programa)
