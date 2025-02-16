extends Node

var config: ConfigFile
var teste_em_execucao: bool = false
var lista_de_testes: Array[String] = []
var teste_atual

func _ready():
	config = ConfigFile.new()
	SoftwareManager.execucao_finalizada.connect(fim_da_execucao)

func _physics_process(_delta):
	if (lista_de_testes.size() > 0) and (not teste_em_execucao):
		teste_em_execucao = true
		teste_atual = lista_de_testes.pop_front()
		# reiniciar cena para limpar todas as modificações
		if get_tree():
			get_tree().reload_current_scene()

func preparar_teste(arquivo_de_teste : String):
	print("###### ", arquivo_de_teste, " ######")
	self.teste_em_execucao = true
	
	self.config.load(arquivo_de_teste)

	# inicializar registradores
	self.atualizar_registrador("começo", "registrador.a", CPU.atualizar_registrador_a)
	self.atualizar_registrador("começo", "registrador.b", CPU.atualizar_registrador_b)
	self.atualizar_registrador("começo", "registrador.pc", CPU.atualizar_registrador_pc)
	self.atualizar_registrador("começo", "registrador.pp", CPU.atualizar_registrador_pp)
	self.atualizar_registrador("começo", "registrador.aux", CPU.atualizar_registrador_aux)
	self.atualizar_registrador("começo", "registrador.ir", CPU.atualizar_registrador_ir)
	self.atualizar_registrador("começo", "registrador.ix", CPU.atualizar_registrador_ix)
	self.atualizar_registrador("começo", "registrador.mbr", CPU.atualizar_registrador_mbr)
	self.atualizar_registrador("começo", "registrador.mar", CPU.atualizar_registrador_mar)
	
	# inicializar flags
	self.atualizar_flag("começo", "flags.z", CPU.atualizar_flag_z)
	self.atualizar_flag("começo", "flags.n", CPU.atualizar_flag_n)
	self.atualizar_flag("começo", "flags.c", CPU.atualizar_flag_c)
	self.atualizar_flag("começo", "flags.o", CPU.atualizar_flag_o)
	
	# inicializar memória
	self.atualizar_memoria()

	# iniciar o teste
	self.iniciar_teste_atual()
	
func iniciar_teste_atual():
	# carregar programa na memória
	var programa_eh_valido : bool = self.atualizar_programa()

	# executar programa
	if programa_eh_valido:
		print("----programa válido-----")
		SoftwareManager.executar_programa(CPU.registrador_pc)
	else:
		self.teste_em_execucao = false

func adicionar_teste_a_fila(nome : String):
	self.lista_de_testes.append(nome)

func adicionar_multiplos_testes_a_fila(pasta: String, arquivos: Array[String]):
	for arquivo in arquivos:
		self.adicionar_teste_a_fila(pasta.path_join(arquivo))

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

func atualizar_registrador(secao: String, registrador: String, funcao: Callable) -> void:
	var valor_registrador = self.config.get_value(secao, registrador, "")
	
	if typeof(valor_registrador) != TYPE_STRING:
		push_error("\"" + registrador + "\" tem um tipo inválido")
		return
	
	if not valor_registrador:
		return

	funcao.call(Utils.de_hex_string_para_inteiro(valor_registrador))

func atualizar_flag(secao: String, flag: String, funcao: Callable) -> void:
	var valor_flag = self.config.get_value(secao, flag, "")

	if typeof(valor_flag) != TYPE_STRING:
		push_error("\"" + flag + "\" tem um tipo inválido")
		return

	if not valor_flag:
		return
	
	funcao.call(Utils.de_hex_string_para_inteiro(valor_flag))

func atualizar_memoria() -> void:
	var conteudo_memoria = self.config.get_value("começo", "memoria", {})

	if typeof(conteudo_memoria) != TYPE_DICTIONARY:
		push_error("\"memoria\" tem um tipo inválido")
		return

	for endereco : String in conteudo_memoria:
		var dado : String = conteudo_memoria[endereco]
		var endereco_convertido = Utils.de_hex_string_para_inteiro(endereco)
		var dado_convertido 	= Utils.de_hex_string_para_inteiro(dado)
		Memoria.sobrescrever_uma_celula(dado_convertido, endereco_convertido)

func atualizar_programa() -> bool:
	var instrucoes = self.config.get_value("começo", "instrucoes", [])
	
	if typeof(instrucoes) != TYPE_ARRAY:
		push_error("\"instrucoes\" tem um tipo inválido")
		return false
	
	if not instrucoes:
		return false
	
	SoftwareManager.salvar_codigo_em_memoria(instrucoes, CPU.registrador_pc)
	return true

func hexview_recarregado():
	# essa função só vai ser chamada se um teste já estiver
	# em execução e após o sinal da memória recarregada
	# for emitido, assim não começa antes dela finalizar
	if teste_em_execucao:
		self.iniciar_teste_atual()
