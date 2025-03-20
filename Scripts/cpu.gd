extends Node

# TODO: talvez trocar tudo para PackedByteArray

signal registrador_a_foi_atualizado
signal registrador_b_foi_atualizado
signal registrador_pc_foi_atualizado
signal registrador_ix_foi_atualizado
signal registrador_pp_foi_atualizado
signal registrador_mbr_foi_atualizado
signal registrador_aux_foi_atualizado
signal registrador_mar_foi_atualizado
signal registrador_ir_foi_atualizado

signal alu_entrada_a_foi_atualizado
signal alu_entrada_b_foi_atualizado
signal alu_saida_foi_atualizado

signal flag_z_foi_atualizada
signal flag_n_foi_atualizada
signal flag_c_foi_atualizada
signal flag_o_foi_atualizada

# registradores
var registrador_a	: Valor = Valor.new(0x00) # Registrador de 8 bits
var registrador_b	: Valor = Valor.new(0x08) # Registrador de 8 bits
var registrador_pc	: Valor = Valor.new(0x0000) # Registrador contador de programa - 16 bits (co)
var registrador_ix	: Valor = Valor.new(0x6E35) # Registrador de 16 bits
var registrador_pp	: Valor = Valor.new(0x0FFF) # Registrador apontador de pilha - 16 bits
var registrador_mbr	: Valor = Valor.new(0x00) # Registrador de buffer de memória - 8 bits (don)
var registrador_aux : Valor = Valor.new(0x00) # Registrador auxiliar - 8 bits
var registrador_mar : Valor = Valor.new(0x00) # Registrador de endereço de memória - 16 bits (rad)

# flags
var flag_z: Valor = Valor.new(0x0) # Registrador de 1 bit (Zero)
var flag_n: Valor = Valor.new(0x0) # Registrador de 1 bit (Negativo)
var flag_c: Valor = Valor.new(0x0) # Registrador de 1 bit (Carry)
var flag_o: Valor = Valor.new(0x0) # Registrador de 1 bit (Overflow)

# unidade de controle
var registrador_ir : Valor = Valor.new(0x0) # Registrador de instrução - 1 bit (ir)

# unidade lógica e aritmética
var alu_entrada_a 	: Valor = Valor.new(0x0000) # Registrador de 16 bits
var alu_entrada_b 	: Valor = Valor.new(0x0000) # Registrador de 16 bits
var alu_saida 		: Valor = Valor.new(0x0000) # Registrador de 16 bits


func iniciar_registrador_pc(endereco: Valor) -> void:
	self.atualizar_registrador_pc(endereco)

func atualizar_registrador_a(novo_valor: Valor) -> void:
	self.registrador_a = novo_valor
	registrador_a_foi_atualizado.emit()

func atualizar_registrador_b(novo_valor: Valor) -> void:
	self.registrador_b = novo_valor
	registrador_b_foi_atualizado.emit()

func atualizar_registrador_pc(novo_valor: Valor) -> void:
	self.registrador_pc = novo_valor
	registrador_pc_foi_atualizado.emit()

func atualizar_registrador_ix(novo_valor: Valor) -> void:
	self.registrador_ix = novo_valor
	registrador_ix_foi_atualizado.emit()

func atualizar_registrador_pp(novo_valor: Valor) -> void:
	self.registrador_pp = novo_valor
	registrador_pp_foi_atualizado.emit()

func atualizar_registrador_mbr(novo_valor: Valor) -> void:
	self.registrador_mbr = novo_valor
	registrador_mbr_foi_atualizado.emit()

func atualizar_registrador_aux(novo_valor: Valor) -> void:
	self.registrador_aux = novo_valor
	registrador_aux_foi_atualizado.emit()

func atualizar_registrador_mar(novo_valor: Valor) -> void:
	self.registrador_mar = novo_valor
	registrador_mar_foi_atualizado.emit()

func atualizar_registrador_ir(novo_valor: Valor) -> void:
	self.registrador_ir = novo_valor
	registrador_ir_foi_atualizado.emit()

func atualizar_alu_entrada_a(novo_valor: Valor) -> void:
	self.alu_entrada_a = novo_valor
	alu_entrada_a_foi_atualizado.emit()

func atualizar_alu_entrada_b(novo_valor: Valor) -> void:
	self.alu_entrada_b = novo_valor
	alu_entrada_b_foi_atualizado.emit()

func atualizar_alu_saida(novo_valor: Valor) -> void:
	self.alu_saida = novo_valor
	alu_saida_foi_atualizado.emit()

func atualizar_flag_z(novo_valor: Valor):
	self.flag_z = novo_valor
	self.flag_z_foi_atualizada.emit()

func atualizar_flag_n(novo_valor: Valor):
	self.flag_n = novo_valor
	self.flag_n_foi_atualizada.emit()

func atualizar_flag_c(novo_valor: Valor):
	self.flag_c = novo_valor
	self.flag_c_foi_atualizada.emit()

func atualizar_flag_o(novo_valor: Valor):
	self.flag_o = novo_valor
	self.flag_o_foi_atualizada.emit()

func filtrar_resultado_e_verificar_flags(valor: Valor, bytes) -> Valor:
	var resultado: int = valor.como_int()
	
	var _flag_z: Valor = Valor.new(resultado == 0)
	self.atualizar_flag_z(_flag_z)
	
	var _flag_n: Valor

	if bytes == 2:
		_flag_n = Valor.new(resultado > 0x7FFF)
	else:
		_flag_n = Valor.new(resultado > 0x7F)

	self.atualizar_flag_n(_flag_n)

	if bytes == 2:
		return Valor.new(resultado & 0xFFFF)
	else:
		return Valor.new(resultado & 0xFF)

func eh_fim_de_execucao() -> bool:
	return (CPU.registrador_ir.como_int() == 0x58) and (CPU.registrador_mar.como_int() == 0x1200)
