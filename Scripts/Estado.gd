extends Node


signal sobrecarregar_programa
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
		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var dado_convertido = Utils.de_hex_string_para_inteiro(valor)
		memoria.set(endereco_convertido, dado_convertido)
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

	CPU.atualizar_registrador_a(Utils.de_hex_string_para_inteiro(registrador_a))
	CPU.atualizar_registrador_b(Utils.de_hex_string_para_inteiro(registrador_b))
	CPU.iniciar_registrador_pc(Utils.de_hex_string_para_inteiro(registrador_pc))
	CPU.atualizar_registrador_pp(Utils.de_hex_string_para_inteiro(registrador_pp))
	CPU.atualizar_registrador_aux(Utils.de_hex_string_para_inteiro(registrador_aux))
	CPU.atualizar_registrador_ir(Utils.de_hex_string_para_inteiro(registrador_ir))
	CPU.atualizar_registrador_ix(Utils.de_hex_string_para_inteiro(registrador_ix))
	CPU.atualizar_registrador_mbr(Utils.de_hex_string_para_inteiro(registrador_mbr))
	CPU.atualizar_registrador_mar(Utils.de_hex_string_para_inteiro(registrador_mar))

	# carrega as flags
	var flag_z = config.get_value("inicio", "flag.z", "0")
	var flag_n = config.get_value("inicio", "flag.n", "0")
	var flag_c = config.get_value("inicio", "flag.c", "0")
	var flag_o = config.get_value("inicio", "flag.o", "0")

	CPU.atualizar_flag_z(Utils.de_hex_string_para_inteiro(flag_z))
	CPU.atualizar_flag_n(Utils.de_hex_string_para_inteiro(flag_n))
	CPU.atualizar_flag_c(Utils.de_hex_string_para_inteiro(flag_c))
	CPU.atualizar_flag_o(Utils.de_hex_string_para_inteiro(flag_o))

	# carrega o programa
	var programa = config.get_value("inicio", "instrucoes", [])
	self.sobrecarregar_programa.emit(programa)
