extends Node

var memory_file_path 	: String 		= ""
var unico_microcodigo 	: bool 			= false
var em_execução 		: bool 			= false
var fila_instrucoes 	: Array[String] = []

var unica_instrucao 	: bool 			= false
var instrucao_executada : bool 			= false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if em_execução:
		if fila_instrucoes.size() > 0:
			var instrucao = fila_instrucoes.pop_front()
			print("Executando: ", instrucao)

			if CPU.has_method(instrucao):
				CPU.call(instrucao)
			else:
				self.call(instrucao)
			
			if unico_microcodigo:
				em_execução = false
				unico_microcodigo = false
		else:
			if instrucao_executada and unica_instrucao:
				em_execução = false
				unica_instrucao = false
				instrucao_executada = false
			else:
				adicionar_instrucao_na_fila()
				instrucao_executada = true
			

func recarregar_memoria():
	var file 	: FileAccess 		= FileAccess.open(self.memory_file_path, FileAccess.READ)
	var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
	Memoria.sobrescrever_memoria(dados)
	file.close()

func alterar_caminho_memoria(caminho : String):
	self.memory_file_path = caminho
	self.recarregar_memoria()

func executar_programa(endereco_inicial : int):
	CPU.iniciar_registrador_pc(endereco_inicial)
	em_execução = true

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

func adicionar_instrucao_na_fila():
	# Coloca todos os microcódigos necessários para a execução de uma instrução na fila
	# Inicia-se a fase de acesso à instrução;

	# Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
	fila_instrucoes.push_back("mover_pc_para_mar")
	
	# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
	fila_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
	
	# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
	fila_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
	
	# O valor de DON é transferido ao DCOD (Decodificador de instrução) via o BUS de Dados;
	fila_instrucoes.push_back("transferir_mbr_para_ir")

	# O CO é incrementado em 1;
	fila_instrucoes.push_back("incrementar_registrador_pc")

	fila_instrucoes.push_back("adicionar_instrucao")
	# Fim da instrução.
	
	# Fim da execução


func adicionar_instrucao():
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	var instrucao_em_hex 		: String 	= Utils.int_para_hex(CPU.registrador_ir, 2)
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
			fila_instrucoes.push_back("mover_pc_para_mar")

			# PC é incrementado em 1
			fila_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.DIRETO:
			# Transferência de PC para MAR
			fila_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			# O PC é incrementado em 2
			fila_instrucoes.push_back("incrementar_registrador_pc")
			fila_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			# Transferência de PC para MAR
			fila_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			fila_instrucoes.push_back("transferir_mar_para_alu_a")
			fila_instrucoes.push_back("transferir_ix_para_alu_b")
			fila_instrucoes.push_back("adicao_alu_a_alu_b")
			fila_instrucoes.push_back("transferir_alu_saida_para_mar")
			fila_instrucoes.push_back("incrementar_registrador_pc")
			fila_instrucoes.push_back("incrementar_registrador_pc")
		_:
			pass
	
	# Fase de execução
	# Busca a lista de microcodigos enumeradas no recurso do Operador
	var microcodigos = Operacoes.get_microcodigos(instrucao_descompilada.mnemonico)
	if microcodigos:
		for microcodigo in microcodigos:
			# Chama a função declarada em CPU que tem nome equivalente ao especificado nos microcodigos do operador
			# Nota: `CPU.call("transferir_a_para_mbr")` é equivalente a `CPU.transferir_a_para_mbr()`
			fila_instrucoes.push_back(microcodigo)
	else:
		em_execução = false
