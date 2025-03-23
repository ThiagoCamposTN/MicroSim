extends Node

signal microoperacao_executada
signal execucao_finalizada
signal mudanca_de_ciclo
signal programa_iniciado

enum Estagio 		{ BUSCA, DECODIFICACAO, ENDERECAMENTO, EXECUCAO, PAUSA, SUSPENSAO }
enum Fase 			{ INICIALIZACAO, OPERACAO }
enum ModoExecucao 	{ UNICA_MICROOPERACAO, UNICA_INSTRUCAO, TUDO }


@export var time_delay 		: float = 0.1
var execucao_timer			: Timer
var estagio_atual 			: Estagio		= Estagio.SUSPENSAO
var estagio_anterior		: Estagio
var fase_atual 				: Fase			= Fase.INICIALIZACAO
var modo_atual 				: ModoExecucao	= ModoExecucao.TUDO
var instrucao_atual 		: Instrucao
var atualizacao_visual_ativa: bool 			= true
var fila_de_microoperacoes	: Array 		= []


# Called when the node enters the scene tree for the first time.
func _ready():
	execucao_timer = Timer.new()
	execucao_timer.one_shot = true
	add_child(execucao_timer)

	self.prepara_o_estado_inicial.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if execucao_timer.is_stopped() or Teste.teste_em_execucao():
		match estagio_atual:
			Estagio.SUSPENSAO:
				return
			Estagio.PAUSA:
				return
			Estagio.BUSCA:
				match self.fase_atual:
					Fase.INICIALIZACAO:
						self.mudanca_de_ciclo.emit("busca")
						self.preparar_busca_de_instrucao()
						self.alternar_fase()
					Fase.OPERACAO:
						if fila_esta_vazia():
							self.avancar_estagio()
							return

						self.executar_proxima_microoperacao_da_fila()
			Estagio.DECODIFICACAO:
				match self.fase_atual:
					Fase.INICIALIZACAO:
						self.mudanca_de_ciclo.emit("decodificacao")
						self.preparar_decodificacao()
						self.alternar_fase()
					Fase.OPERACAO:
						if fila_esta_vazia():
							self.instrucao_atual = self.decodificar()
							self.avancar_estagio()
							return

						self.executar_proxima_microoperacao_da_fila()
			Estagio.ENDERECAMENTO:
				match self.fase_atual:
					Fase.INICIALIZACAO:
						self.mudanca_de_ciclo.emit("execucao")
						self.preparar_enderecamento(self.instrucao_atual)
						self.alternar_fase()
					Fase.OPERACAO:
						if fila_esta_vazia():
							# Se a instrução atual for CAL EXIT, finalizar a execução
							if CPU.instrucao_atual_finalizacao():
								self.finalizar_execucao(true)
								return
							
							self.avancar_estagio()
							return

						self.executar_proxima_microoperacao_da_fila()
			Estagio.EXECUCAO:
				match self.fase_atual:
					Fase.INICIALIZACAO:
						self.preparar_execucao(self.instrucao_atual)
						self.alternar_fase()
					Fase.OPERACAO:
						if fila_esta_vazia():
							self.finalizar_execucao(true)
							return

						self.executar_proxima_microoperacao_da_fila()

func executar_proxima_microoperacao_da_fila():
	var _instrucao = self.obter_proxima_microoperacao()
	var instrucao: String

	match typeof(_instrucao):
		TYPE_STRING:
			instrucao = _instrucao
		TYPE_DICTIONARY:
			for condicional in _instrucao:
				if UnidadeDeControle.call(condicional):
					for _microoperacao in _instrucao[condicional]:
						# self.inserir_no_comeco_da_fila(_microoperacao)
						self.adicionar_a_fila(_microoperacao)
			return
		_:
			push_error("Operador de instrução inválido")
	
	if not Teste.em_modo_multiplos_teste():
		print("Executando: ", instrucao)

	UnidadeDeControle.call(instrucao)
	
	self.microoperacao_executada.emit()
	self.execucao_timer.start(self.time_delay)

	if self.modo_atual == ModoExecucao.UNICA_MICROOPERACAO:
		self.pausar_estagio()

func executar_programa(endereco_inicial: Valor, modo: ModoExecucao = ModoExecucao.TUDO):
	CPU.iniciar_registrador_pc(endereco_inicial)
	if self.estagio_atual == Estagio.SUSPENSAO:
		self.alterar_estagio_para(Estagio.BUSCA)
	elif self.estagio_atual == Estagio.PAUSA:
		self.alterar_estagio_para(self.estagio_anterior)
	self.modo_atual = modo
	programa_iniciado.emit()

func salvar_codigo_em_memoria(linhas_codigo: PackedStringArray, endereco_inicial: Valor):
	var parte_memoria: PackedByteArray

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
	
	return instrucao.instrucao_como_bytes()

func preparar_busca_de_instrucao():
	# Coloca todos os microcódigos necessários para a execução de uma operacao em fila
	# Inicia-se a fase de acesso à instrução;

	# Transferência do PC (Contador de Programa) para o MAR (Registrador de Endereço de Memória);
	self.adicionar_a_fila("transferir_pc_para_mar")
	
	# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
	self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
	
	# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
	self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")

	# O PC é incrementado em 1;
	self.adicionar_a_fila("transferir_pc_para_alu_a")
	self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
	self.adicionar_a_fila("transferir_alu_saida_para_pc")

func preparar_decodificacao():
	# O valor de MBR (Registrador de Buffer de Memória) é 
	# transferido ao IR (Registrador de Instrução) via o BUS de Dados;
	self.adicionar_a_fila("transferir_mbr_para_ir")

func decodificar() -> Instrucao:
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	var instrucao_descompilada: Instrucao = Compilador.descompilar(CPU.registrador_ir)
	
	# se não a instrução não existe
	if not instrucao_descompilada:
		print("Instrução inválida. Encerrando execução.")
		self.finalizar_execucao()
		return
	
	return instrucao_descompilada

func preparar_enderecamento(instrucao_descompilada: Instrucao) -> void:
	# Estagio de pesquisa e endereço do operando
	match instrucao_descompilada.enderecamento:
		Instrucao.Enderecamentos.POS_INDEXADO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")

			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")

			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("transferir_ix_para_alu_b")
			self.adicionar_a_fila("adicao_alu_a_alu_b")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")

			# O PC é incrementado em 2
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")


		Instrucao.Enderecamentos.PRE_INDEXADO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")
			
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("transferir_ix_para_alu_b")
			self.adicionar_a_fila("adicao_alu_a_alu_b")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")

			# O PC é incrementado em 2
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.INDIRETO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.IMEDIATO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")

			# PC é incrementado em 1
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.DIRETO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			# Transferência de PC para MAR
			self.adicionar_a_fila("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# Somar o valor de IX ao endereço calculado
			self.adicionar_a_fila("transferir_mar_para_alu_a")
			self.adicionar_a_fila("transferir_ix_para_alu_b")
			self.adicionar_a_fila("adicao_alu_a_alu_b")
			self.adicionar_a_fila("transferir_alu_saida_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
			self.adicionar_a_fila("transferir_pc_para_alu_a")
			self.adicionar_a_fila("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila("transferir_alu_saida_para_pc")
		_:
			pass

func preparar_execucao(instrucao_descompilada: Instrucao) -> void:
	# Estagio de execução
	# Busca a lista de microoperacoes enumeradas no recurso do Operador
	var microoperacoes = Operacoes.obter_microoperacoes(instrucao_descompilada.mnemonico)

	for microoperacao in microoperacoes:
		# Chama a função declarada em CPU que tem nome equivalente ao especificado no microcodigo do operador
		# Nota: `CPU.call("transferir_a_para_mbr")` é equivalente a `CPU.transferir_a_para_mbr()`
		self.adicionar_a_fila(microoperacao)

func finalizar_execucao(sucesso: bool=true):
	self.alterar_estagio_para(Estagio.SUSPENSAO)
	self.limpar_fila_de_microoperacoes() # todo: verificar se a lista não esvaziar sozinha é bug ou não
	execucao_finalizada.emit(sucesso)

func prepara_o_estado_inicial(_emitir_sinal_de_finalização: bool = true):
	Estado.carregar_estado()
	# if emitir_sinal_de_finalização:
	# 	self.inicialização_finalizada.emit()

func limpar_fila_de_microoperacoes() -> void:
	for fase in self.fila_de_microoperacoes:
		self.fila_de_microoperacoes[fase].clear()

func consultar_microperacao_atual() -> Variant:
	if self.fila_esta_vazia():
		return ""
	return self.fila_de_microoperacoes[0]

func fila_esta_vazia() -> bool:
	return len(self.fila_de_microoperacoes) <= 0

func adicionar_a_fila(microoperacao: Variant) -> void:
	self.fila_de_microoperacoes.push_back(microoperacao)

# func inserir_no_comeco_da_fila(microoperacao: Variant) -> void:
# 	self.fila_de_microoperacoes.push_front(microoperacao)

func obter_proxima_microoperacao() -> Variant:
	return self.fila_de_microoperacoes.pop_front()

func alternar_fase() -> void:
	match self.fase_atual:
		Fase.INICIALIZACAO:
			self.fase_atual = Fase.OPERACAO
		Fase.OPERACAO:
			self.fase_atual = Fase.INICIALIZACAO

func avancar_estagio() -> void:
	match self.estagio_atual:
		Estagio.BUSCA:
			self.alterar_estagio_para(Estagio.DECODIFICACAO)
		Estagio.DECODIFICACAO:
			self.alterar_estagio_para(Estagio.ENDERECAMENTO)
		Estagio.ENDERECAMENTO:
			self.alterar_estagio_para(Estagio.EXECUCAO)
		Estagio.EXECUCAO:
			self.alterar_estagio_para(Estagio.BUSCA)
	
	self.alternar_fase()

func alterar_estagio_para(estagio: Estagio) -> void:
	self.estagio_atual = estagio

func pausar_estagio() -> void:
	self.estagio_anterior = self.estagio_atual
	self.alterar_estagio_para(Estagio.PAUSA)
