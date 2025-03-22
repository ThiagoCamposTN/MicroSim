extends Node

signal microoperacao_executada
signal execucao_finalizada
signal mudanca_de_fase
signal programa_iniciado


@export var time_delay 	: float = 0.1
var execucao_timer		: Timer

enum Estagio 		{ PREPARACAO, ENDERECAMENTO, OPERACAO, SUSPENSAO }
enum Fase 			{ BUSCA, DECODIFICACAO, EXECUCAO }
enum ModoExecucao 	{ UNICA_MICROOPERACAO, UNICA_INSTRUCAO, TUDO }

var estagio_atual 	: Estagio		= Estagio.SUSPENSAO
var modo_atual 		: ModoExecucao	= ModoExecucao.TUDO
var fase_atual 		: Fase			= Fase.BUSCA

var atualizacao_visual_ativa: bool = true

var filas_de_microoperacoes: Dictionary = {
	Fase.BUSCA			: [],
	Fase.DECODIFICACAO	: [],
	Fase.EXECUCAO		: []
}


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
			Estagio.PREPARACAO:
				self.buscar_instrucao()
				self.alterar_estagio(Estagio.OPERACAO)
				self.alterar_fase(Fase.BUSCA)
			Estagio.ENDERECAMENTO:
				var instrucao_descompilada: Instrucao = self.decodificar()
				self.preparar_enderecamento(instrucao_descompilada)
				self.alterar_fase(Fase.EXECUCAO)
				self.alterar_estagio(Estagio.OPERACAO)
			Estagio.OPERACAO:
				# se fim da fila da fase atual
				if self.fila_da_fase_atual_esta_vazia():
					match fase_atual:
						Fase.BUSCA:
							self.alterar_fase(Fase.DECODIFICACAO)
							self.preparar_decodificacao()
						Fase.DECODIFICACAO:
							self.alterar_estagio(Estagio.ENDERECAMENTO)
						Fase.EXECUCAO:
							self.finalizar_execucao()
					return
				
				if self.modo_atual == ModoExecucao.UNICA_INSTRUCAO:
					self.alterar_estagio(Estagio.SUSPENSAO)

				self.executar_microoperacao_da_fila_atual()
				# self.verificar_se_fim_de_execucao()
			_:
				pass

func executar_microoperacao_da_fila_atual():
	var _instrucao = self.obter_proxima_microoperacao()
	var instrucao: String

	match typeof(_instrucao):
		TYPE_STRING:
			instrucao = _instrucao
		TYPE_DICTIONARY:
			for condicional in _instrucao:
				if UnidadeDeControle.call(condicional):
					for _microoperacao in _instrucao[condicional]:
						self.inserir_na_fila_como_proxima_microoperacao(_microoperacao)
			return
		_:
			push_error("Operador de instrução inválido")
	
	if not Teste.em_modo_multiplos_teste():
		print("Executando: ", instrucao)

	# TODO: provavelmente isso não é mais necessário
	if CPU.has_method(instrucao):
		CPU.call(instrucao)
	elif UnidadeDeControle.has_method(instrucao):
		UnidadeDeControle.call(instrucao)
	else:
		Simulador.call(instrucao)
	
	self.microoperacao_executada.emit()
	self.execucao_timer.start(self.time_delay)

func executar_programa(endereco_inicial: Valor, modo: ModoExecucao = ModoExecucao.TUDO):
	CPU.iniciar_registrador_pc(endereco_inicial)
	self.estagio_atual = Estagio.PREPARACAO
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

func buscar_instrucao():
	# Coloca todos os microcódigos necessários para a execução de uma operacao em fila
	# Inicia-se a fase de acesso à instrução;

	# Transferência do PC (Contador de Programa) para o MAR (Registrador de Endereço de Memória);
	self.adicionar_a_fila_de_busca("transferir_pc_para_mar")
	
	# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
	self.adicionar_a_fila_de_busca("transferir_mar_ao_endereco_de_memoria")
	
	# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
	self.adicionar_a_fila_de_busca("transferir_valor_da_memoria_ao_mbr")

	# O PC é incrementado em 1;
	self.adicionar_a_fila_de_busca("transferir_pc_para_alu_a")
	self.adicionar_a_fila_de_busca("incrementar_um_na_alu_a_16_bits")
	self.adicionar_a_fila_de_busca("transferir_alu_saida_para_pc")

func preparar_decodificacao():
	# O valor de MBR (Registrador de Buffer de Memória) é 
	# transferido ao IR (Registrador de Instrução) via o BUS de Dados;
	self.adicionar_a_fila_de_decodificacao("transferir_mbr_para_ir")

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
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")

			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")

			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("transferir_ix_para_alu_b")
			self.adicionar_a_fila_de_execucao("adicao_alu_a_alu_b")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")

			# O PC é incrementado em 2
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")


		Instrucao.Enderecamentos.PRE_INDEXADO:
			# Transferência de PC para MAR
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")
			
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("transferir_ix_para_alu_b")
			self.adicionar_a_fila_de_execucao("adicao_alu_a_alu_b")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")

			# O PC é incrementado em 2
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.INDIRETO:
			# Transferência de PC para MAR
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.IMEDIATO:
			# Transferência de PC para MAR
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")

			# PC é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.DIRETO:
			# Transferência de PC para MAR
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			# Transferência de PC para MAR
			self.adicionar_a_fila_de_execucao("transferir_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			self.adicionar_a_fila_de_execucao("transferir_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			self.adicionar_a_fila_de_execucao("transferir_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			self.adicionar_a_fila_de_execucao("unir_mbr_ao_aux_e_transferir_para_mar")
			
			# Somar o valor de IX ao endereço calculado
			self.adicionar_a_fila_de_execucao("transferir_mar_para_alu_a")
			self.adicionar_a_fila_de_execucao("transferir_ix_para_alu_b")
			self.adicionar_a_fila_de_execucao("adicao_alu_a_alu_b")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_mar")
			
			# O PC é incrementado em 2
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
			self.adicionar_a_fila_de_execucao("transferir_pc_para_alu_a")
			self.adicionar_a_fila_de_execucao("incrementar_um_na_alu_a_16_bits")
			self.adicionar_a_fila_de_execucao("transferir_alu_saida_para_pc")
		_:
			pass
	
	self.realizar_execucao(instrucao_descompilada)

func realizar_execucao(instrucao_descompilada: Instrucao) -> void:
	# Estagio de execução
	# Busca a lista de microoperacoes enumeradas no recurso do Operador
	var microoperacoes = Operacoes.obter_microoperacoes(instrucao_descompilada.mnemonico)

	for microoperacao in microoperacoes:
		# Chama a função declarada em CPU que tem nome equivalente ao especificado no microcodigo do operador
		# Nota: `CPU.call("transferir_a_para_mbr")` é equivalente a `CPU.transferir_a_para_mbr()`
		self.adicionar_a_fila_de_execucao(microoperacao)
	
	self.mudanca_de_fase.emit(Fase.DECODIFICACAO)

func finalizar_execucao(sucesso: bool=true):
	estagio_atual = Estagio.SUSPENSAO
	self.limpar_fila_de_microoperacoes() # todo: verificar se a lista não esvaziar sozinha é bug ou não
	execucao_finalizada.emit(sucesso)

func prepara_o_estado_inicial(_emitir_sinal_de_finalização: bool = true):
	Estado.carregar_estado()
	# if emitir_sinal_de_finalização:
	# 	self.inicialização_finalizada.emit()

func verificar_se_fim_de_execucao() -> void:
	# Se a instrução atual for CAL EXIT, finalizar a execução
	if CPU.eh_fim_de_execucao():
		self.finalizar_execucao()

func realizar_calculo_de_flags():
	# pode haver multiplos calcular flags empurrados pois pode haver
	# multiplas operacoes que dão push da flag em seguida uma da outra
	self.inserir_na_fila_como_proxima_microoperacao("calcular_flags")

func limpar_fila_de_microoperacoes() -> void:
	for fase in self.filas_de_microoperacoes:
		self.filas_de_microoperacoes[fase].clear()

func consultar_microperacao_atual():
	if self.fila_de_microoperacoes_esta_vazia():
		return ""
	return self.filas_de_microoperacoes[0]

func fila_de_microoperacoes_esta_vazia() -> bool:
	for fase in self.filas_de_microoperacoes:
		if len(self.filas_de_microoperacoes[fase]) > 0:
			return false
	return true

# func fila_esta_vazia(fase: Fase) -> bool:
# 	if len(self.filas_de_microoperacoes[fase]) > 0:
# 		return false
# 	return true

func fila_da_fase_atual_esta_vazia() -> bool:
	if len(self.filas_de_microoperacoes[fase_atual]) > 0:
		return false
	return true

func adicionar_a_fila(microoperacao: Variant, fase: Fase) -> void:
	self.filas_de_microoperacoes[fase].push_back(microoperacao)

func adicionar_a_fila_de_busca(microoperacao) -> void:
	self.adicionar_a_fila(microoperacao, Fase.BUSCA)

func adicionar_a_fila_de_decodificacao(microoperacao) -> void:
	self.adicionar_a_fila(microoperacao, Fase.DECODIFICACAO)

func adicionar_a_fila_de_execucao(microoperacao) -> void:
	self.adicionar_a_fila(microoperacao, Fase.EXECUCAO)

func adicionar_a_fila_de_microoperacoes(microoperacao) -> void:
	self.adicionar_a_fila(microoperacao, fase_atual)

func inserir_na_fila_como_proxima_microoperacao(microoperacao) -> void:
	self.filas_de_microoperacoes[fase_atual].push_front(microoperacao)

func obter_proxima_microoperacao():
	return self.filas_de_microoperacoes[fase_atual].pop_front()

func alterar_estagio(novo_estagio: Estagio) -> void:
	self.estagio_atual = novo_estagio

func alterar_fase(nova_fase: Fase) -> void:
	self.fase_atual = nova_fase
	self.mudanca_de_fase.emit(nova_fase)
