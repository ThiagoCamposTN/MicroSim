extends Node

# TODO: talvez trocar tudo para PackedByteArray

signal registrador_a_foi_atualizado
signal registrador_b_foi_atualizado
signal registrador_mbr_foi_atualizado
signal registrador_pc_foi_atualizado

# registradores
var registrador_a	: int = 0x00	# Registrador de 8 bits
var registrador_b	: int = 0x08	# Registrador de 8 bits
var registrador_pc	: int = 0x0000	# Registrador contador de programa - 16 bits (co)
var registrador_ix	: int = 0x6E35	# Registrador de 16 bits
var registrador_pp	: int = 0x0FFF	# Registrador apontador de pilha - 16 bits
var registrador_mbr : int			# Registrador de buffer de memória - 8 bits (don)
var registrador_aux : int			# Registrador auxiliar - 8 bits
var registrador_mar : int			# Registrador de endereço de memória - 16 bits (rad)

# flags
var flag_z : int = 0x0 # Registrador de 1 bit
var flag_n : int = 0x0 # Registrador de 1 bit
var flag_r : int = 0x0 # Registrador de 1 bit
var flag_d : int = 0x1 # Registrador de 1 bit

# unidade de controle
var registrador_ir : int # Registrador de instrução - 1 bit (ir)

# unidade lógica e aritmética
var alu_entrada_a 	: int # Registrador de 16 bits
var alu_entrada_b 	: int # Registrador de 16 bits
var alu_saida 		: int # Registrador de 16 bits


func atualizar_registrador_a(novo_valor : int) -> void:
	self.registrador_a = novo_valor
	registrador_a_foi_atualizado.emit()

func atualizar_registrador_b(novo_valor : int) -> void:
	self.registrador_b = novo_valor
	registrador_b_foi_atualizado.emit()

func atualizar_registrador_mbr(novo_valor : int) -> void:
	self.registrador_mbr = novo_valor
	registrador_mbr_foi_atualizado.emit()

func incrementar_registrador_pc(quantia : int) -> void:
	self.registrador_pc += quantia
	registrador_pc_foi_atualizado.emit()

func mover_pc_para_mar() -> void:
	CPU.registrador_mar = CPU.registrador_pc

func ler_dado_do_endereço_do_mar() -> int:
	# Transferência do MAR para o Endereço de Memória via o BUS (Barramento) de Endereço;
	var endereco = CPU.registrador_mar
	# O conteúdo da memória no endereço fornecido é lido;
	var conteudo = Memoria.ler_conteudo_no_endereco(endereco)
	return conteudo

func transferir_mbr_para_ir() -> void:
	CPU.registrador_ir = CPU.registrador_mbr

func iniciar_registrador_pc(endereco : int) -> void:
	self.registrador_pc = endereco

func atualizar_registrador_aux(novo_valor : int) -> void:
	self.registrador_aux = novo_valor

func incrementar_registrador_mar(quantia : int) -> void:
	self.registrador_mar += quantia

func unir_mbr_ao_aux_e_mover_para_mar() -> void:
	self.registrador_mar = self.registrador_mbr + (self.registrador_aux << 8)

func transferir_a_para_mbr() -> void:
	atualizar_registrador_mbr(self.registrador_a)

func transferir_b_para_mbr() -> void:
	atualizar_registrador_mbr(self.registrador_b)

func transferir_a_para_alu_a() -> void:
	self.alu_entrada_a = self.registrador_a
	
func transferir_b_para_alu_b() -> void:
	self.alu_entrada_b = self.registrador_b

func adicao_alu_a_alu_b() -> void:
	self.alu_saida = self.alu_entrada_a + self.alu_entrada_b
	
func transferir_alu_saida_para_a() -> void:
	atualizar_registrador_a(self.alu_saida)
