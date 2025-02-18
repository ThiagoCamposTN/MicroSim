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
	var registrador_a = Utils.de_hex_string_para_inteiro(config.get_value("fim", "registrador.a"))
	var registrador_b = Utils.de_hex_string_para_inteiro(config.get_value("fim", "registrador.b"))

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



func atualizar_programa(instrucoes: PackedStringArray):
	if self.teste_em_execucao:
		SoftwareManager.salvar_codigo_em_memoria(instrucoes, CPU.registrador_pc)
