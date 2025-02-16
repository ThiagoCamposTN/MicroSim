extends Node

var config: ConfigFile

func _ready():
	config = ConfigFile.new()

func abrir_programa(nome : String):
	config.load(nome)
	var conteudo_memoria = config.get_value("começo", "memoria")
	for endereco : String in conteudo_memoria:
		var dado : String = conteudo_memoria[endereco]
		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var dado_convertido 	= Utils.de_hex_string_para_inteiro(dado)
		Memoria.sobrescrever_uma_celula(dado_convertido, endereco_convertido)

func metodo2(parametro: int):
	print("Método 2 chamado com parâmetro:", parametro)
