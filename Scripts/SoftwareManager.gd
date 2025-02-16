extends Node

signal microoperacao_executada
signal inicialização_finalizada

var memory_file_path 	: String 		= ""
var unico_microcodigo 	: bool 			= false
var em_execução 		: bool 			= false
var fila_instrucoes 	: Array[String] = []

var unica_instrucao 	: bool 			= false
var instrucao_executada : bool 			= false
var ultima_operacao		: String		= ""

@export var time_delay 	: float 		= 0.1
var execucao_timer		: Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	execucao_timer = Timer.new()
	execucao_timer.one_shot = true
	add_child(execucao_timer)

	self.prepara_o_estado_inicial.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if em_execução and execucao_timer.is_stopped():
		if fila_instrucoes.size() > 0:
			var instrucao = fila_instrucoes.pop_front()
			ultima_operacao = instrucao
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
		microoperacao_executada.emit()
		execucao_timer.start(time_delay)

func recarregar_memoria(caminho: String="res://MEMORIA.MEM"):
	if FileAccess.file_exists(caminho):
		var file 	: FileAccess 		= FileAccess.open(caminho, FileAccess.READ)
		var dados 	: PackedByteArray 	= file.get_buffer(file.get_length())
		Memoria.sobrescrever_toda_a_memoria(dados)
		file.close()
	else:
		push_error("Arquivo de memoria \"" + caminho + "\" não existe")

func executar_programa(endereco_inicial : int):
	CPU.iniciar_registrador_pc(endereco_inicial)
	em_execução = true

func salvar_codigo_em_memoria(codigo: String, endereco_inicial: int):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)

	for linha in linhas:
		var instrucao : Instrucao = Compilador.compilar(linha)
		
		# instrução inválida
		if not instrucao:
			return # finaliza a execução
		
		var byte = Operacoes.mnemonico_para_byte(instrucao.mnemonico, instrucao.enderecamento)
		parte_memoria.push_back(Utils.de_hex_string_para_inteiro(byte))
		
		# instrução de saída
		if instrucao.parametros and instrucao.parametros[0] == "EXIT":
			parte_memoria.push_back(0x12)
			parte_memoria.push_back(0x00)
			break # salta os parâmetros
		
		# Resolução dos parâmetros da instrução na memória
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
			Instrucao.Enderecamentos.INDIRETO:
				var valor_em_hex 	= Utils.formatar_hex_como_endereco(instrucao.parametros[0])
				var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
				for valor in valor_dividido:
					parte_memoria.push_back(valor)
			Instrucao.Enderecamentos.POS_INDEXADO:
				# TODO
				pass
			Instrucao.Enderecamentos.PRE_INDEXADO:
				# TODO
				pass
			

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



func prepara_o_estado_inicial():
	self.carregar_estado_inicial()
	inicialização_finalizada.emit()

func carregar_estado_inicial(caminho: String="res://inicio.estado"):
	var config = ConfigFile.new()
	var err = config.load(caminho)

	if err != OK:
		push_error("Erro na leitura do arquivo de estado \"" + caminho + "\"")
		return
	
	# carrega a memória
	var arquivo_memoria = config.get_value("estado", "memoria")

	if not arquivo_memoria or (typeof(arquivo_memoria) != TYPE_STRING):
		push_error("Valor de \"memoria\" é inválido.")
		return
	
	self.recarregar_memoria(arquivo_memoria)

	# carrega os registradores
	var registrador_a = config.get_value("estado", "registrador.a", "0")
	var registrador_b = config.get_value("estado", "registrador.b", "0")
	var registrador_pc = config.get_value("estado", "registrador.pc", "0")
	var registrador_pp = config.get_value("estado", "registrador.pp", "0")
	var registrador_aux = config.get_value("estado", "registrador.aux", "0")
	var registrador_ir = config.get_value("estado", "registrador.ir", "0")
	var registrador_ix = config.get_value("estado", "registrador.ix", "0")
	var registrador_mbr = config.get_value("estado", "registrador.mbr", "0")
	var registrador_mar = config.get_value("estado", "registrador.mar", "0")

	CPU.atualizar_registrador_a(Utils.de_hex_string_para_inteiro(registrador_a))
	CPU.atualizar_registrador_b(Utils.de_hex_string_para_inteiro(registrador_b))
	CPU.atualizar_registrador_pc(Utils.de_hex_string_para_inteiro(registrador_pc))
	CPU.atualizar_registrador_pp(Utils.de_hex_string_para_inteiro(registrador_pp))
	CPU.atualizar_registrador_aux(Utils.de_hex_string_para_inteiro(registrador_aux))
	CPU.atualizar_registrador_ir(Utils.de_hex_string_para_inteiro(registrador_ir))
	CPU.atualizar_registrador_ix(Utils.de_hex_string_para_inteiro(registrador_ix))
	CPU.atualizar_registrador_mbr(Utils.de_hex_string_para_inteiro(registrador_mbr))
	CPU.atualizar_registrador_mar(Utils.de_hex_string_para_inteiro(registrador_mar))

	# carrega as flags
	var flag_z = config.get_value("estado", "flag.z", "0")
	var flag_n = config.get_value("estado", "flag.n", "0")
	var flag_c = config.get_value("estado", "flag.c", "0")
	var flag_o = config.get_value("estado", "flag.o", "0")

	CPU.atualizar_flag_z(Utils.de_hex_string_para_inteiro(flag_z))
	CPU.atualizar_flag_n(Utils.de_hex_string_para_inteiro(flag_n))
	CPU.atualizar_flag_c(Utils.de_hex_string_para_inteiro(flag_c))
	CPU.atualizar_flag_o(Utils.de_hex_string_para_inteiro(flag_o))
