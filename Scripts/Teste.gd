extends Node

var arquivo_de_teste : String
var teste_em_execucao: bool = false
var lista_de_testes: Array[String] = []
var teste_atual


func _ready():
	SoftwareManager.execucao_finalizada.connect(fim_da_execucao)
	Estado.sobrecarregar_programa.connect(atualizar_programa)

func inicializar_teste(arquivo : String):
	print("###### ", arquivo, " ######")
	self.arquivo_de_teste = arquivo
	self.teste_em_execucao = true

	# limpar a fila de instruções (não é necessário aqui, mas é mais uma medida de segurança)
	SoftwareManager.fila_instrucoes.clear()

	# carregar o estado antes de executar o teste
	Estado.carregar_estado(arquivo)
	
	# inicia a execução do teste
	self.executar_teste()


func executar_teste():
	SoftwareManager.executar_programa(CPU.registrador_pc)

func fim_da_execucao():
	# realiza a comparação do estado final com o esperado

	if not self.teste_em_execucao:
		return
	
	# carrega o arquivo de estado
	var config: ConfigFile = Estado.obter_configuração_de_estado(self.arquivo_de_teste)

	if not config:
		return
	
	# validando resultado final nos registradores
	self.validar_valor(config, "registrador.a", CPU.registrador_a)
	self.validar_valor(config, "registrador.b", CPU.registrador_b)
	self.validar_valor(config, "registrador.pc", CPU.registrador_pc)
	self.validar_valor(config, "registrador.pp", CPU.registrador_pp)
	self.validar_valor(config, "registrador.aux", CPU.registrador_aux)
	self.validar_valor(config, "registrador.ir", CPU.registrador_ir)
	self.validar_valor(config, "registrador.ix", CPU.registrador_ix)
	self.validar_valor(config, "registrador.mbr", CPU.registrador_mbr)
	self.validar_valor(config, "registrador.mar", CPU.registrador_mar)
	
		# validando resultado final nas flags
	self.validar_valor(config, "flag.z", CPU.flag_z)
	self.validar_valor(config, "flag.n", CPU.flag_n)
	self.validar_valor(config, "flag.c", CPU.flag_c)
	self.validar_valor(config, "flag.o", CPU.flag_o)

	# validando resultado final na memória
	self.validar_memoria(config)

	self.teste_em_execucao = false

func atualizar_programa(instrucoes: PackedStringArray):
	if self.teste_em_execucao:
		SoftwareManager.salvar_codigo_em_memoria(instrucoes, CPU.registrador_pc)

func validar_valor(config: ConfigFile, chave: String, valor_atual : int):
	var valor_esperado = config.get_value("fim", chave, "")
	
	if not valor_esperado:
		return
	
	if typeof(valor_esperado) != TYPE_STRING:
		push_error("\"" + chave + "\" tem um tipo inválido.")
		return

	if not (Utils.de_hex_string_para_inteiro(valor_esperado) == valor_atual):
		print("Falha: \"" + chave + "\" deveria ser \"0x" + str(valor_esperado) + "\" mas resultou em \"0x" + Utils.int_para_hex(valor_atual, 1) + "\".")

func validar_memoria(config: ConfigFile):
	var valores_memoria = config.get_value("fim", "memoria", {})

	if typeof(valores_memoria) != TYPE_DICTIONARY:
		push_error("\"memoria\" tem um tipo inválido. Abortando verificação.")
		return

	for endereco in valores_memoria:
		if typeof(endereco) != TYPE_STRING:
			push_error("\"memoria\" tem um valor inválido. Abortando verificação.")
			return

		var valor_esperado = valores_memoria[endereco]

		if typeof(valor_esperado) != TYPE_STRING:
			push_error("\"memoria\" tem um valor inválido. Abortando verificação.")
			return

		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var valor_esperado_int = Utils.de_hex_string_para_inteiro(valor_esperado)
		var valor_atual_int = Memoria.celulas[endereco_convertido]
		
		if valor_esperado_int != valor_atual_int:
			print("Falha: O valor na memória no endereço \"" + Utils.int_para_hex(endereco_convertido, 1) + "\" deveria ser \"0x" + valor_esperado + "\" mas resultou em \"0x" + Utils.int_para_hex(valor_atual_int, 1) + "\".")
