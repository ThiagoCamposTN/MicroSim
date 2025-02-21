extends Node

signal microoperacao_executada
signal inicialização_finalizada
signal execucao_finalizada

var memory_file_path 	: String 		= ""
var unico_microcodigo 	: bool 			= false
var em_execução 		: bool 			= false
var fila_instrucoes 	: Array[String] = []

var unica_instrucao 	: bool 			= false
var instrucao_executada : bool 			= false
var ultima_operacao		: String		= ""

@export var time_delay 	: float 		= 0.1
var execucao_timer		: Timer
var config_inicial		: ConfigFile


# Called when the node enters the scene tree for the first time.
func _ready():
	execucao_timer = Timer.new()
	execucao_timer.one_shot = true
	add_child(execucao_timer)

	self.prepara_o_estado_inicial.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if em_execução and (execucao_timer.is_stopped() or Teste.teste_em_execucao):
		if fila_instrucoes.size() > 0:
			var instrucao = fila_instrucoes.pop_front()
			ultima_operacao = instrucao
			
			if not Teste.teste_em_execucao:
				print("Executando: ", instrucao)

			if CPU.has_method(instrucao):
				CPU.call(instrucao)
			else:
				self.call(instrucao)
			
			if unico_microcodigo:
				finalizar_execucao()
				unico_microcodigo = false
		else:
			if instrucao_executada and unica_instrucao:
				finalizar_execucao()
				unica_instrucao = false
				instrucao_executada = false
			else:
				adicionar_instrucao_na_fila()
				instrucao_executada = true
		microoperacao_executada.emit()
		execucao_timer.start(time_delay)

func executar_programa(endereco_inicial : int):
	CPU.iniciar_registrador_pc(endereco_inicial)
	em_execução = true

func salvar_codigo_em_memoria(linhas_codigo: PackedStringArray, endereco_inicial: int):
	var parte_memoria = Array()

	for linha in linhas_codigo:
		var bytes: PackedByteArray = self.compilar_linha_em_bytes(linha)
		
		# instrução inválida
		if not bytes:
			return
		
		parte_memoria.append_array(bytes)
	
	Memoria.sobrescrever_parte_da_memoria(parte_memoria, endereco_inicial)

func compilar_linha_em_bytes(linha: String) -> PackedByteArray:
	var instrucao: Instrucao = Compilador.compilar(linha)
		
	# instrução inválida
	if not instrucao:
		return []
	
	return instrucao.instrucao_em_bytes()

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

			fila_instrucoes.push_back("transferir_mar_para_alu_a")
			fila_instrucoes.push_back("transferir_ix_para_alu_b")
			fila_instrucoes.push_back("adicao_alu_a_alu_b")
			fila_instrucoes.push_back("transferir_alu_saida_para_mar")

			# O PC é incrementado em 2
			fila_instrucoes.push_back("incrementar_registrador_pc")
			fila_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.PRE_INDEXADO:
			# TODO: Esse começo é idêntico ao INDEXADO

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

			# TODO: Essa parte é nova

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
		finalizar_execucao()

func finalizar_execucao():
	em_execução = false
	self.fila_instrucoes.clear() # todo: verificar se a lista não esvaziar sozinha é bug ou não
	execucao_finalizada.emit()

func prepara_o_estado_inicial(emitir_sinal_de_finalização: bool = true):
	Estado.carregar_estado()
	# if emitir_sinal_de_finalização:
	# 	self.inicialização_finalizada.emit()
