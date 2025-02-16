extends Node

var config: ConfigFile
var teste_em_execucao: bool = false

func _ready():
	config = ConfigFile.new()

	SoftwareManager.execucao_finalizada.connect(fim_da_execucao)

func abrir_teste(nome : String):
	self.config.load(nome)

	# inicializar registradores
	CPU.atualizar_registrador_a(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.a")))
	CPU.atualizar_registrador_b(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.b")))
	CPU.atualizar_registrador_pc(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.pc")))
	CPU.atualizar_registrador_pp(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.pp")))
	CPU.atualizar_registrador_aux(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.aux")))
	CPU.atualizar_registrador_ir(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.ir")))
	CPU.atualizar_registrador_ix(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.ix")))
	CPU.atualizar_registrador_mbr(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.mbr")))
	CPU.atualizar_registrador_mar(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "registrador.mar")))

	# inicializar flags
	CPU.atualizar_flag_z(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "flags.z")))
	CPU.atualizar_flag_n(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "flags.n")))
	CPU.atualizar_flag_c(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "flags.c")))
	CPU.atualizar_flag_o(Utils.de_hex_string_para_inteiro(self.config.get_value("começo", "flags.o")))
	
	# inicializar memória
	var conteudo_memoria = self.config.get_value("começo", "memoria")
	for endereco : String in conteudo_memoria:
		var dado : String = conteudo_memoria[endereco]
		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var dado_convertido 	= Utils.de_hex_string_para_inteiro(dado)
		Memoria.sobrescrever_uma_celula(dado_convertido, endereco_convertido)
	
	# carregar programa na memória
	var instrucoes = self.config.get_value("começo", "instrucoes")
	SoftwareManager.salvar_codigo_em_memoria(instrucoes, CPU.registrador_pc)

	# executar programa
	SoftwareManager.executar_programa(CPU.registrador_pc)

	# validar resultado final dos registradores, flags e memória
	self.teste_em_execucao = true

func fim_da_execucao():
	if not self.teste_em_execucao:
		return
	
	# validando resultado final nos registradores
	var registrador_a = Utils.de_hex_string_para_inteiro(self.config.get_value("fim", "registrador.a"))
	var registrador_b = Utils.de_hex_string_para_inteiro(self.config.get_value("fim", "registrador.b"))

	if (CPU.registrador_a == registrador_a):
		print("Registrador A está correto")
	else:
		print("Registrador A está incorreto")

	if (CPU.registrador_b == registrador_b):
		print("Registrador B está correto")
	else:
		print("Registrador B está incorreto")

	#TODO: finalizar verificação dos registradores
	
	# validando resultado final nas flags
	#TODO: implementar verificação das flags

	# validando resultado final na memória
	#TODO: implementar verificação de memória

	self.teste_em_execucao = false
