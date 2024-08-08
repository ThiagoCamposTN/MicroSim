extends Node

var memory_file_path 	: String 	= ""
var unica_instrucao := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recarregar_memoria():
	var file 	: FileAccess 		= FileAccess.open(self.memory_file_path, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	Memoria.sobrescrever_memoria(dados)
	file.close()

func alterar_caminho_memoria(caminho : String):
	self.memory_file_path = caminho
	self.recarregar_memoria()

func executar_programa(endereco_inicial : int):
	var em_execução : bool = true

	# Inicia-se a fase de acesso à instrução;
	CPU.iniciar_registrador_pc(endereco_inicial)

	while em_execução:
		# Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
		CPU.mover_pc_para_mar()
		
		# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
		CPU.mover_mar_ao_endereco_de_memoria()
		
		# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
		CPU.mover_valor_da_memoria_ao_mbr()
#
		# O valor de DON é transferido ao DCOD (Decodificador de instrução) via o BUS de Dados;
		CPU.transferir_mbr_para_ir()
#
		# O CO é incrementado em 1;
		CPU.incrementar_registrador_pc(1)

		em_execução = executar_instrucao(CPU.registrador_ir)
		
		if unica_instrucao:
			return
	
		# Fim da instrução.
	
	# Fim da execução

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: int):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)

	for linha in linhas:
		var instrucao : Instrucao = Compilador.compilar(linha)
		var deve_pular_parametros = false
		
		# instrução inválida
		if not instrucao:
			return
		
		var byte = Operacoes.mnemonico_para_byte(instrucao.mnemonico, instrucao.enderecamento)
		parte_memoria.push_back(Utils.de_hex_string_para_inteiro(byte))
		
		if instrucao.parametros and instrucao.parametros[0] == "EXIT":
			parte_memoria.push_back(0x12)
			parte_memoria.push_back(0x00)
			deve_pular_parametros = true
		
		# Resolução dos parâmetros da instrução na memória
		if not deve_pular_parametros:
			match instrucao.enderecamento:
				Instrucao.Enderecamentos.IMEDIATO:
					var valor = Utils.de_hex_string_para_inteiro(instrucao.parametros[0])
					parte_memoria.push_back(valor)
				Instrucao.Enderecamentos.DIRETO:
					var valor_em_hex 	= Utils.formatar_hex_como_endereco(instrucao.parametros[0])
					var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
					for valor in valor_dividido:
						parte_memoria.push_back(valor)
				Instrucao.Enderecamentos.IMPLICITO:
					# Não precisa tratar parâmetros
					pass
				Instrucao.Enderecamentos.INDEXADO:
					var valor_em_hex 	= Utils.formatar_hex_como_endereco(instrucao.parametros[0])
					var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
					for valor in valor_dividido:
						parte_memoria.push_back(valor)
			

	Memoria.sobrescrever_parte_da_memoria(parte_memoria, endereco_inicial)
	#print("Depois: ", Memoria.celulas.slice(0,15))

func executar_instrucao(instrucao : int):
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	var instrucao_em_hex 		: String 	= Utils.int_para_hex(instrucao, 2)
	var instrucao_descompilada 	: Instrucao = Compilador.descompilar(instrucao_em_hex)
	
	# se não a instrução não existe
	if not instrucao_descompilada:
		return false
	
	# Fase de pesquisa e endereço do operando
	match instrucao_descompilada.enderecamento:
		Instrucao.Enderecamentos.POS_INDEXADO:
			pass
		Instrucao.Enderecamentos.PRE_INDEXADO:
			pass
		Instrucao.Enderecamentos.INDIRETO:
			pass
		Instrucao.Enderecamentos.IMEDIATO:
			# Transferência de PC para MAR
			CPU.mover_pc_para_mar()
			
			# PC é incrementado em 1
			CPU.incrementar_registrador_pc(1)
		Instrucao.Enderecamentos.DIRETO:
			# Transferência de PC para MAR
			CPU.mover_pc_para_mar()
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			CPU.mover_mar_ao_endereco_de_memoria()
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			CPU.mover_valor_da_memoria_ao_aux()
			
			# O MAR é incrementado em 1
			CPU.incrementar_registrador_mar(1)
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			CPU.mover_mar_ao_endereco_de_memoria()
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			CPU.mover_valor_da_memoria_ao_mbr()
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			CPU.unir_mbr_ao_aux_e_mover_para_mar()
			
			# O PC é incrementado em 2
			CPU.incrementar_registrador_pc(2)
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			# Transferência de PC para MAR
			CPU.mover_pc_para_mar()
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			CPU.mover_mar_ao_endereco_de_memoria()
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			CPU.mover_valor_da_memoria_ao_aux()
			
			# O MAR é incrementado em 1
			CPU.incrementar_registrador_mar(1)
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			CPU.mover_mar_ao_endereco_de_memoria()
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			CPU.mover_valor_da_memoria_ao_mbr()
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			CPU.unir_mbr_ao_aux_e_mover_para_mar()
			
			CPU.transferir_mar_para_alu_a()
			CPU.transferir_ix_para_alu_b()
			CPU.adicao_alu_a_alu_b()
			CPU.transferir_alu_saida_para_mar()
			CPU.incrementar_registrador_pc(2)
		_:
			pass
	
	# Fase de execução
	# Busca a lista de microcodigos enumeradas no recurso do Operador
	var microcodigos = Operacoes.get_microcodigos(instrucao_descompilada.mnemonico)
	if microcodigos:
		for microcodigo in microcodigos:
			# Chama a função declarada em CPU que tem nome equivalente ao especificado nos microcodigos do operador
			# Nota: `CPU.call("transferir_a_para_mbr")` é equivalente a `CPU.transferir_a_para_mbr()`
			CPU.call(microcodigo)
	else:
		return false
	
	return true
