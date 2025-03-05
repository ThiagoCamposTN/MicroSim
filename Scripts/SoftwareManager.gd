extends Node

signal microoperacao_executada
signal execucao_finalizada
signal mudanca_de_fase

var fila_de_instrucoes 	: Array 		= []

@export var time_delay 	: float 		= 0.1
var execucao_timer		: Timer

enum Estagio 		{ PREPARACAO, OPERACAO, TERMINO }
enum Fase 			{ BUSCA, DECODIFICACAO, EXECUCAO }
enum ModoExecucao 	{ UNICO_MICROCODIGO, UNICA_INSTRUCAO, TUDO }

var estagio_atual 	: Estagio		= Estagio.TERMINO
var modo_atual 		: ModoExecucao	= ModoExecucao.TUDO

var atualizacao_visual_ativa: bool = true

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
			Estagio.TERMINO:
				return
			Estagio.PREPARACAO:
				if self.fila_de_instrucoes_esta_vazia():
					preparar_proxima_instrucao()
				estagio_atual = Estagio.OPERACAO
			Estagio.OPERACAO:
				if self.fila_de_instrucoes_esta_vazia():
					if self.modo_atual == ModoExecucao.UNICA_INSTRUCAO:
						estagio_atual = Estagio.TERMINO
					else:
						estagio_atual = Estagio.PREPARACAO
					return

				executar_proxima_microoperacao()
				
				if self.modo_atual == ModoExecucao.UNICO_MICROCODIGO:
					self.estagio_atual = Estagio.TERMINO

				microoperacao_executada.emit()
				execucao_timer.start(time_delay)
			_:
				pass

func executar_proxima_microoperacao():
	var _instrucao = fila_de_instrucoes.pop_front()
	var instrucao: String

	match typeof(_instrucao):
		TYPE_STRING:
			instrucao = _instrucao
		TYPE_DICTIONARY:
			for condicional in _instrucao:
				if CPU.call(condicional):
					for _microcodigo in _instrucao[condicional]:
						fila_de_instrucoes.push_front(_microcodigo)
			return
		_:
			push_error("Operador de instrução inválido")
	
	if not Teste.em_modo_multiplos_teste():
		print("Executando: ", instrucao)

	if CPU.has_method(instrucao):
		CPU.call(instrucao)
	else:
		if instrucao == "---":
			self.mudanca_de_fase.emit(Fase.BUSCA)
		else:
			self.call(instrucao)

func executar_programa(endereco_inicial: Valor, modo: ModoExecucao = ModoExecucao.TUDO):
	CPU.iniciar_registrador_pc(endereco_inicial)
	self.estagio_atual = Estagio.PREPARACAO
	self.modo_atual = modo

func salvar_codigo_em_memoria(linhas_codigo: PackedStringArray, endereco_inicial: Valor):
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
	
	return instrucao.instrucao_como_bytes()

func preparar_proxima_instrucao():
	# Coloca todos os microcódigos necessários para a execução de uma instrução na fila
	# Inicia-se a fase de acesso à instrução;

	# Início da instrução
	fila_de_instrucoes.push_back("---")

	# Transferência do CO (Contador Ordinal) para o RAD (Registrador de Endereço);
	fila_de_instrucoes.push_back("mover_pc_para_mar")
	
	# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
	fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
	
	# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
	fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
	
	# O valor de DON é transferido ao DCOD (Decodificador de instrução) via o BUS de Dados;
	fila_de_instrucoes.push_back("transferir_mbr_para_ir")

	# O CO é incrementado em 1;
	fila_de_instrucoes.push_back("incrementar_registrador_pc")

	fila_de_instrucoes.push_back("decodificar_instrucao")

func decodificar_instrucao():
	# TODO: Todos os caminhos de dados devem ter suas próprias funções no futuro
	var instrucao_descompilada: Instrucao = Compilador.descompilar(CPU.registrador_ir)
	
	# se não a instrução não existe
	if not instrucao_descompilada:
		print("Instrução inválida. Encerrando execução.")
		finalizar_execucao()
		return
	
	# Estagio de pesquisa e endereço do operando
	match instrucao_descompilada.enderecamento:
		Instrucao.Enderecamentos.POS_INDEXADO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")

			fila_de_instrucoes.push_back("transferir_mar_para_alu_a")
			fila_de_instrucoes.push_back("transferir_ix_para_alu_b")
			fila_de_instrucoes.push_back("adicao_alu_a_alu_b")
			fila_de_instrucoes.push_back("transferir_alu_saida_para_mar")

			# O PC é incrementado em 2
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.PRE_INDEXADO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			fila_de_instrucoes.push_back("transferir_mar_para_alu_a")
			fila_de_instrucoes.push_back("transferir_ix_para_alu_b")
			fila_de_instrucoes.push_back("adicao_alu_a_alu_b")
			fila_de_instrucoes.push_back("transferir_alu_saida_para_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")

			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")

			# O PC é incrementado em 2
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.INDIRETO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			# O PC é incrementado em 2
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.IMEDIATO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")

			# PC é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.DIRETO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			# O PC é incrementado em 2
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		Instrucao.Enderecamentos.IMPLICITO:
			pass
		Instrucao.Enderecamentos.INDEXADO:
			# Transferência de PC para MAR
			fila_de_instrucoes.push_back("mover_pc_para_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao AUX via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_aux")
			
			# O MAR é incrementado em 1
			fila_de_instrucoes.push_back("incrementar_registrador_mar")
			
			# Transferência do MAR para o Endereço de Memória via o BUS de Endereço
			fila_de_instrucoes.push_back("mover_mar_ao_endereco_de_memoria")
			
			# O valor no Endereço de Memória é transferido ao MBR via o BUS de Dados
			fila_de_instrucoes.push_back("mover_valor_da_memoria_ao_mbr")
			
			# Une MBR e AUX para formar um endereço 16 bits que é transferido para MAR
			fila_de_instrucoes.push_back("unir_mbr_ao_aux_e_mover_para_mar")
			
			fila_de_instrucoes.push_back("transferir_mar_para_alu_a")
			fila_de_instrucoes.push_back("transferir_ix_para_alu_b")
			fila_de_instrucoes.push_back("adicao_alu_a_alu_b")
			fila_de_instrucoes.push_back("transferir_alu_saida_para_mar")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
			fila_de_instrucoes.push_back("incrementar_registrador_pc")
		_:
			pass

	# checando se houve o término do programa
	fila_de_instrucoes.push_back("validar_fim_de_execucao")
	
	# Estagio de execução
	# Busca a lista de microcodigos enumeradas no recurso do Operador
	var microcodigos = Operacoes.get_microcodigos(instrucao_descompilada.mnemonico)

	for microcodigo in microcodigos:
		# Chama a função declarada em CPU que tem nome equivalente ao especificado nos microcodigos do operador
		# Nota: `CPU.call("transferir_a_para_mbr")` é equivalente a `CPU.transferir_a_para_mbr()`
		fila_de_instrucoes.push_back(microcodigo)
	
	self.mudanca_de_fase.emit(Fase.DECODIFICACAO)

func finalizar_execucao():
	estagio_atual = Estagio.TERMINO
	self.limpar_fila_de_instrucoes() # todo: verificar se a lista não esvaziar sozinha é bug ou não
	execucao_finalizada.emit()

func prepara_o_estado_inicial(_emitir_sinal_de_finalização: bool = true):
	Estado.carregar_estado()
	# if emitir_sinal_de_finalização:
	# 	self.inicialização_finalizada.emit()

func validar_fim_de_execucao() -> void:
	self.mudanca_de_fase.emit(Fase.EXECUCAO)

	# Se a instrução atual for CAL EXIT, finalizar a execução
	if CPU.eh_fim_de_execucao():
		self.finalizar_execucao()

func realizar_calculo_de_flags():
	# pode haver multiplos calcular flags empurrados pois pode haver
	# multiplas operacoes que dão push da flag em seguida uma da outra
	self.fila_de_instrucoes.push_front("calcular_flags")

func calcular_flags():
	pass

func limpar_fila_de_instrucoes() -> void:
	self.fila_de_instrucoes.clear()

func obter_instrucao_atual():
	if self.fila_de_instrucoes_esta_vazia():
		return ""
	
	return self.fila_de_instrucoes[0]

func fila_de_instrucoes_esta_vazia() -> bool:
	return self.fila_de_instrucoes.size() == 0
