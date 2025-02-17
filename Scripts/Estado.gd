class_name Estado

static func obter_arquivo_de_estado(caminho: String="res://padrão.estado") -> ConfigFile:
	var config = ConfigFile.new()
	var err = config.load(caminho)

	if err != OK:
		push_error("Erro na leitura do arquivo de estado \"" + caminho + "\"")
		return
	
	return config

static func obter_nome_arquivo_memoria(config: ConfigFile) -> String:
	var nome_arquivo_memoria = config.get_value("estado", "memoria")

	if not nome_arquivo_memoria or (typeof(nome_arquivo_memoria) != TYPE_STRING):
		push_error("Valor de \"memoria\" é inválido.")
		return ""
	
	return nome_arquivo_memoria

static func obter_dados_memoria(caminho: String="res://MEMORIA.MEM") -> PackedByteArray:
	if not FileAccess.file_exists(caminho):
		push_error("Arquivo de memoria \"" + caminho + "\" não existe")
		return []
	
	var file 	: FileAccess 		= FileAccess.open(caminho, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	file.close()
	return dados
