extends Node

@onready var config_padrao : ConfigFile = ConfigFile.new()


func carregar_estado_inicial(caminho: String="res://padrão.estado") -> void:
	var err = self.config_padrao.load(caminho)

	if err != OK:
		push_error("Erro na leitura do arquivo de estado \"" + caminho + "\"")
		return

func obter_nome_arquivo_memoria() -> String:
	var nome_arquivo_memoria = self.config_padrao.get_value("estado", "memoria")

	if not nome_arquivo_memoria or (typeof(nome_arquivo_memoria) != TYPE_STRING):
		push_error("Valor de \"memoria\" é inválido.")
		return ""
	
	return nome_arquivo_memoria

func obter_dados_memoria() -> PackedByteArray:
	var caminho_arquivo: String = self.obter_nome_arquivo_memoria()

	if not FileAccess.file_exists(caminho_arquivo):
		push_error("Arquivo de memoria \"" + caminho_arquivo + "\" não existe")
		return []
	
	var file 	: FileAccess 		= FileAccess.open(caminho_arquivo, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	file.close()
	return dados
