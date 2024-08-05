extends Node

var memory_file_path 	: String 	= ""

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

		var dado : int = CPU.ler_dado_do_endereço_do_mar()

		# O valor é transferido ao DON (Registrador de Dados) via o BUS de Dados;
		CPU.atualizar_registrador_mbr(dado)
#
		# O valor de DON é transferido ao DCOD (Decodificador de instrução) via o BUS de Dados;
		CPU.transferir_mbr_para_ir()
#
		# O CO é incrementado em 1;
		CPU.incrementar_registrador_pc(1)

		em_execução = executar_instrucao(CPU.registrador_ir)
	
		# Fim da instrução.
	
	# Fim da execução

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: int):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)
	#print("Antes: ", Memoria.celulas.slice(0,15))

	for linha in linhas:
		var instrucao : Instrucao = Compilador.compilar(linha)
		var deve_pular_parametros = false
		
		# instrução inválida
		if not instrucao:
			return
		
		#print("instrução: enderecamento - ", instrucao.enderecamento, ", mnemonico: ", instrucao.mnemonico, ", parametros: ", instrucao.parametros)
		
		match instrucao.mnemonico:
			"LDA":
				if instrucao.enderecamento == Instrucao.Enderecamentos.IMEDIATO:
					parte_memoria.push_back(0x20)
				if instrucao.enderecamento == Instrucao.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x10)
			"LDB":
				if instrucao.enderecamento == Instrucao.Enderecamentos.IMEDIATO:
					parte_memoria.push_back(0x60)
			"ABA":
				if instrucao.enderecamento == Instrucao.Enderecamentos.IMPLICITO:
					parte_memoria.push_back(0x48)
			"STA":
				if instrucao.enderecamento == Instrucao.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x11)
			"STB":
				if instrucao.enderecamento == Instrucao.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x51)
			"CAL":
				if instrucao.enderecamento == Instrucao.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x58)
					
					if instrucao.parametros[0] == "EXIT":
						parte_memoria.push_back(0x12)
						parte_memoria.push_back(0x00)
						deve_pular_parametros = true
			_:
				# instrução não existe
				pass
		
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
			

	Memoria.sobrescrever_parte_da_memoria(parte_memoria, endereco_inicial)
	#print("Depois: ", Memoria.celulas.slice(0,15))

func executar_instrucao(instrucao : int):
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	var instrucao_em_hex 		: String 	= Utils.int_para_hex(instrucao, 2)
	var instrucao_descompilada 	: Instrucao = Compilador.descompilar(instrucao_em_hex)
	
	# se não a instrução não existe
	if not instrucao_descompilada:
		return false
	
	var endereco
	var dado
	
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
			
			# Transferência de MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O conteúdo da memória no endereço fornecido é lido
			dado = Memoria.ler_conteudo_no_endereco(endereco)
			
			# O valor é transferido ao AUX via o BUS de Dados
			CPU.atualizar_registrador_aux(dado)
			
			# O MAR é incrementado em 1
			CPU.incrementar_registrador_mar(1)
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O conteúdo da memória no endereço fornecido é lido
			dado = Memoria.ler_conteudo_no_endereco(endereco)
			
			# O valor é transferido ao MBR via o BUS de Dados
			CPU.atualizar_registrador_mbr(dado)
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			CPU.unir_mbr_ao_aux_e_mover_para_mar()
			
			# O PC é incrementado em 2
			CPU.incrementar_registrador_pc(2)
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			pass
		_:
			pass
	
	# Fase de execução
	match instrucao_descompilada.mnemonico:
		"LDA":
			# Transferência de MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O conteúdo da memória no endereço fornecido é lido
			dado = Memoria.ler_conteudo_no_endereco(endereco)
			
			# O valor é transferido ao MBR via o BUS de Dados
			CPU.atualizar_registrador_mbr(dado)
			
			# O valor é transferido de MBR para o Registrador A
			CPU.atualizar_registrador_a(CPU.registrador_mbr)
			
			# A flag Z (zero) é verificada
			# calcular_z()
			
			# A flag N (negativo) é verificada
			# calcular_n()
		"LDB":
			# Transferência de MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O conteúdo da memória no endereço fornecido é lido
			dado = Memoria.ler_conteudo_no_endereco(endereco)
			
			# O valor é transferido ao MBR via o BUS de Dados
			CPU.atualizar_registrador_mbr(dado)
			
			# O valor é transferido de MBR para o Registrador B
			CPU.atualizar_registrador_b(CPU.registrador_mbr)
			
			# A flag Z (zero) é verificada
			# calcular_z()
			
			# A flag N (negativo) é verificada
			# calcular_n()
		"ABA":
			# Transferência do A para a ALU A
			CPU.transferir_a_para_alu_a()
			
			# Transferência do B para a ALU B
			CPU.transferir_b_para_alu_b()
			
			# Adição de 8 bits na ALU
			CPU.adicao_alu_a_alu_b()
			
			# Transferência da saída da ALU para A
			CPU.transferir_alu_saida_para_a()
			
			# TODO: Verificar as flags
		"STA":
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O valor de A é transferido ao MBR
			CPU.transferir_a_para_mbr()
			
			# O conteúdo da memória no endereço fornecido é substituído por MBR via o BUS de Dados
			Memoria.atualizar_dado_no_endereco(endereco, CPU.registrador_mbr)
		"STB":
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_mar
			
			# O valor de B é transferido ao MBR
			CPU.transferir_b_para_mbr()
			
			# O conteúdo da memória no endereço fornecido é substituído por MBR via o BUS de Dados
			Memoria.atualizar_dado_no_endereco(endereco, CPU.registrador_mbr)
		_:
			# instrução inválida
			return false
	
	return true
