extends Node

var memory_file_path 	: String 	= ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recarregar_memoria():
	var file : FileAccess = FileAccess.open(self.memory_file_path, FileAccess.READ)
	var dados = file.get_buffer(file.get_length())
	Memoria.sobrescrever_memoria(dados)
	file.close()

func alterar_caminho_memoria(caminho : String):
	self.memory_file_path = caminho
	self.recarregar_memoria()

func executar_programa(endereco_inicial : int):
	var em_execução : bool = true

	# Inicia-se a fase de acesso à instrução;
	CPU.iniciar_registrador_co(endereco_inicial)

	while em_execução:
		# Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
		CPU.mover_co_para_rad()

		var dado : int = CPU.ler_dado_do_endereço_do_rad()

		# O valor é transferido ao DON (Registrador de Dados) via o BUS de Dados;
		CPU.atualizar_registrador_don(dado)
#
		# O valor é transferido ao DCOD (Decodificador de instrução);
		CPU.transferir_don_para_dcod()
#
		# O CO é incrementado em 1;
		CPU.incrementar_registrador_co(1)

		em_execução = decodificar_instrucao(CPU.registrador_dcod)
	
		# Fim da instrução.
	
	# Fim da execução

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: String):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)
	print("Antes: ", Memoria.dados.slice(0,10))

	for linha in linhas:
		var valores = linha.split(" ", false)
		
		if valores[0] == "LDA":
			parte_memoria.push_back(0x20) # LDA
			parte_memoria.push_back(int(valores[1]))
		elif valores[0] == "LDB":
			parte_memoria.push_back(0x60) # LDB
			parte_memoria.push_back(int(valores[1]))
		elif valores[0] == "ABA":
			parte_memoria.push_back(0x48) # ABA
		elif (valores[0] == "CAL" and valores[1] == "EXIT") or valores[0] == "CALEXIT":
			parte_memoria.push_back(0x58)
			parte_memoria.push_back(0x12)
			parte_memoria.push_back(0x00)
	print("Parte: ", PackedByteArray(parte_memoria))
	Memoria.sobrescrever_parte_da_memoria(parte_memoria, Utils.de_hex_string_para_inteiro(endereco_inicial))
	print("Depois: ", Memoria.dados.slice(0,10))

func decodificar_instrucao(instrucao : int):
	# LDA - endereçamento direto
	if instrucao == 0x20:
		# Transferência do CO para o RAD
		CPU.mover_co_para_rad()
		
		# O CO é incrementado em 1
		CPU.incrementar_registrador_co(1)
		
		# Transferência do RAD para o Endereço de Memória via o BUS de Endereço
		var endereco = CPU.registrador_rad
		
		# O conteúdo da memória no endereço fornecido é lido
		var dado = Memoria.ler_dado_no_endereco(endereco)
		
		# O valor é transferido ao DON via o BUS de Dados
		CPU.atualizar_registrador_don(dado)
		
		# O valor é transferido do DON para o Registrador A
		CPU.atualizar_registrador_a(CPU.registrador_don)
		
		# A flag Z (zero) é verificada
		# calcular_z()
		
		# A flag N (negativo) é verificada
		# calcular_n()
	# LDB - endereçamento direto
	elif instrucao == 0x60:
		# Transferência do CO para o RAD
		CPU.mover_co_para_rad()
		
		# O CO é incrementado em 1
		CPU.incrementar_registrador_co(1)
		
		# Transferência do RAD para o Endereço de Memória via o BUS de Endereço
		var endereco = CPU.registrador_rad
		
		# O conteúdo da memória no endereço fornecido é lido
		var dado = Memoria.ler_dado_no_endereco(endereco)
		
		# O valor é transferido ao DON via o BUS de Dados
		CPU.atualizar_registrador_don(dado)
		
		# O valor é transferido do DON para o Registrador B
		CPU.atualizar_registrador_b(CPU.registrador_don)
		
		# A flag Z (zero) é verificada
		# calcular_z()
		
		# A flag N (negativo) é verificada
		# calcular_n()
	else:
		# comando invalido
		return false
	
	return true
