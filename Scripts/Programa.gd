extends Node

var config: ConfigFile

func _ready():
	config = ConfigFile.new()

func abrir_teste(nome : String):
	config.load(nome)

	# inicializar registradores
	CPU.atualizar_registrador_a(config.get_value("começo", "registrador.a"))
	CPU.atualizar_registrador_b(config.get_value("começo", "registrador.b"))
	CPU.atualizar_registrador_pc(config.get_value("começo", "registrador.pc"))
	CPU.atualizar_registrador_pp(config.get_value("começo", "registrador.pp"))
	CPU.atualizar_registrador_aux(config.get_value("começo", "registrador.aux"))
	CPU.atualizar_registrador_ir(config.get_value("começo", "registrador.ir"))
	CPU.atualizar_registrador_ix(config.get_value("começo", "registrador.ix"))
	CPU.atualizar_registrador_mbr(config.get_value("começo", "registrador.mbr"))
	CPU.atualizar_registrador_mar(config.get_value("começo", "registrador.mar"))

	# inicializar flags
	CPU.atualizar_flag_z(config.get_value("começo", "flags.z"))
	CPU.atualizar_flag_n(config.get_value("começo", "flags.n"))
	CPU.atualizar_flag_c(config.get_value("começo", "flags.c"))
	CPU.atualizar_flag_o(config.get_value("começo", "flags.o"))
	
	# inicializar memória
	var conteudo_memoria = config.get_value("começo", "memoria")
	for endereco : String in conteudo_memoria:
		var dado : String = conteudo_memoria[endereco]
		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var dado_convertido 	= Utils.de_hex_string_para_inteiro(dado)
		Memoria.sobrescrever_uma_celula(dado_convertido, endereco_convertido)
	
	# carregar programa

	# executar programa

func metodo2(parametro: int):
	print("Método 2 chamado com parâmetro:", parametro)
