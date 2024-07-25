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
		# O valor de DON é transferido ao DCOD (Decodificador de instrução) via o BUS de Dados;
		CPU.transferir_don_para_dcod()
#
		# O CO é incrementado em 1;
		CPU.incrementar_registrador_co(1)

		em_execução = executar_instrucao(CPU.registrador_dcod)
	
		# Fim da instrução.
	
	# Fim da execução

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: String):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)
	print("Antes: ", Memoria.dados.slice(0,15))

	for linha in linhas:
		var comando : CODEC.Instrucao = CODEC.codificar(linha)
		
		if not comando:
			# comando inválido
			return
		
		print("comando: tipo - ", comando.tipo, ", mnemonico: ", comando.mnemonico, ", parametros: ", comando.parametros)
		
		match comando.mnemonico:
			"LDA":
				if comando.tipo == CODEC.Enderecamentos.IMEDIATO:
					parte_memoria.push_back(0x20) # LDA
					parte_memoria.push_back(int(comando.parametros[0]))
			"LDB":
				if comando.tipo == CODEC.Enderecamentos.IMEDIATO:
					parte_memoria.push_back(0x60) # LDB
					parte_memoria.push_back(int(comando.parametros[0]))
			"ABA":
				if comando.tipo == CODEC.Enderecamentos.IMPLICITO:
					parte_memoria.push_back(0x48) # ABA
			"STA":
				if comando.tipo == CODEC.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x11) # STA
					var valor_em_hex 	= Utils.formatar_hex_como_endereco(comando.parametros[0])
					var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
					for valor in valor_dividido:
						parte_memoria.push_back(valor)
			"CAL":
				if comando.tipo == CODEC.Enderecamentos.DIRETO:
					parte_memoria.push_back(0x58) # CAL
					
					if comando.parametros[0] == "EXIT":
						parte_memoria.push_back(0x12)
						parte_memoria.push_back(0x00)
					else:
						var valor_em_hex 	= Utils.formatar_hex_como_endereco(comando.parametros[0])
						var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
						for valor in valor_dividido:
							parte_memoria.push_back(valor)
			_:
				# comando não existe
				pass
	Memoria.sobrescrever_parte_da_memoria(parte_memoria, Utils.de_hex_string_para_inteiro(endereco_inicial))
	print("Depois: ", Memoria.dados.slice(0,15))

func executar_instrucao(instrucao : int):
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	
	print(instrucao)
	
	# LDA - endereçamento direto
	match instrucao:
		0x20:
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
		0x60:
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
		# ABA - endereçamento implícito
		0x48:
			# Transferência do A para a ULA A
			CPU.transferir_a_para_ula_a()
			
			# Transferência do B para a ULA B
			CPU.transferir_b_para_ula_b()
			
			# Adição de 8 bits na ULA
			CPU.adicao_ula_a_ula_b()
			
			# Transferência da saída da ULA para A
			CPU.transferir_ula_saida_para_a()
			
			# TODO: Verificar as flags
			
		# STA - endereçamento direto
		0x11:
			# Fase de pesquisa e endereço do operando
			
			# Transferência do CO para o RAD
			CPU.mover_co_para_rad()
			
			# Transferência do RAD para o Endereço de Memória via o BUS de Endereço
			var endereco = CPU.registrador_rad
			
			# O conteúdo da memória no endereço fornecido é lido
			var dado = Memoria.ler_dado_no_endereco(endereco)
			
			print("primeira parte do endereço: ", dado)
			
			# O valor é transferido ao AUX via o BUS de Dados
			CPU.atualizar_registrador_aux(dado)
			
			# O RAD é incrementado em 1
			CPU.incrementar_registrador_rad(1)
			
			# Transferência do RAD para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_rad
			
			# O conteúdo da memória no endereço fornecido é lido
			dado = Memoria.ler_dado_no_endereco(endereco)
			
			print("segunda parte do endereço: ", dado)
			
			# O valor é transferido ao DON via o BUS de Dados
			CPU.atualizar_registrador_don(dado)
			
			# Une DON e AUX para formar um endereço 16 bits que é transferido para RAD
			CPU.unir_don_ao_aux_e_mover_para_rad()
			
			print("endereço final: ", CPU.registrador_rad)
			
			# O CO é incrementado em 2
			CPU.incrementar_registrador_co(2)
			
			# Fase de execução
			
			# Transferência do RAD para o Endereço de Memória via o BUS de Endereço
			endereco = CPU.registrador_rad
			
			# O valor de A é transferido ao DON
			CPU.transferir_a_para_don()
			
			# O valor de DON é transferido para a memória
			CPU.transferir_a_para_don()
			
			# O conteúdo da memória no endereço fornecido é substituído por DON via o BUS de Dados
			Memoria.atualizar_dado_no_endereco(endereco, CPU.registrador_don)
		_:
			# comando invalido
			return false
	
	return true
