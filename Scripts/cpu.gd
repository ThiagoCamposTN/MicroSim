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
signal endereco_selecionado_foi_alterado

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


func atualizar_registrador_a(novo_valor: Valor) -> void:
	self.registrador_a = novo_valor
	registrador_a_foi_atualizado.emit()
	self.atualizar_flags(novo_valor, true, true, false, false)

func atualizar_registrador_b(novo_valor: Valor) -> void:
	self.registrador_b = novo_valor
	registrador_b_foi_atualizado.emit()
	self.atualizar_flags(novo_valor, true, true, false, false)

func atualizar_registrador_pc(novo_valor: Valor) -> void:
	self.registrador_pc = novo_valor
	registrador_pc_foi_atualizado.emit()

func atualizar_registrador_ix(novo_valor: Valor) -> void:
	self.registrador_ix = novo_valor
	registrador_ix_foi_atualizado.emit()
	self.atualizar_flags(novo_valor, true, true, false, false)

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

func incrementar_registrador_pc() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_pc)
	resultado.somar_int(1)
	atualizar_registrador_pc(resultado)

func incrementar_registrador_mar() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_mar)
	resultado.somar_int(1)
	atualizar_registrador_mar(resultado)

func incrementar_registrador_pp() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_pp)
	resultado.somar_int(1)
	atualizar_registrador_pp(resultado)

func decrementar_registrador_pp() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_pp)
	resultado.somar_int(-1)
	atualizar_registrador_pp(resultado)

func decrementar_registrador_ix() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_ix)
	resultado.somar_int(-1)
	atualizar_registrador_ix(resultado)

func decrementar_registrador_a() -> void:
	var resultado = Valor.novo_de_valor(self.registrador_a)
	resultado.somar_int(-1)
	atualizar_registrador_a(resultado)

func mover_pc_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pc)

func transferir_mbr_para_ir() -> void:
	atualizar_registrador_ir(self.registrador_mbr)

func transferir_mbr_para_a() -> void:
	atualizar_registrador_a(registrador_mbr)

func transferir_mbr_para_b() -> void:
	atualizar_registrador_b(registrador_mbr)

func iniciar_registrador_pc(endereco: Valor) -> void:
	atualizar_registrador_pc(endereco)

func unir_mbr_ao_aux_e_mover_para_mar() -> void:
	var resultado: Valor = Valor.novo_de_valor(self.registrador_mbr)
	resultado.somar_int(self.registrador_aux.como_int() << 8)
	atualizar_registrador_mar(resultado)

func unir_mbr_ao_aux_e_mover_para_pc() -> void:
	var resultado: Valor = Valor.novo_de_valor(self.registrador_aux)
	resultado.somar_int(self.registrador_mbr.como_int() << 8)
	atualizar_registrador_pc(resultado)

func unir_mbr_ao_aux_e_mover_para_ix() -> void:
	var resultado: Valor = Valor.novo_de_valor(self.registrador_mbr)
	resultado.somar_int(self.registrador_aux.como_int() << 8)
	atualizar_registrador_ix(resultado)

func dividir_ix_e_mover_para_mbr_e_aux() -> void:
	var registrador: PackedByteArray = self.registrador_ix.como_byte_array(4)
	atualizar_registrador_aux(Valor.new(registrador[0]))
	atualizar_registrador_mbr(Valor.new(registrador[1]))

func dividir_pc_e_mover_para_mbr_e_aux() -> void:
	var registrador: PackedByteArray = self.registrador_pc.como_byte_array(4)
	atualizar_registrador_mbr(Valor.new(registrador[0]))
	atualizar_registrador_aux(Valor.new(registrador[1]))

func transferir_a_para_mbr() -> void:
	atualizar_registrador_mbr(self.registrador_a)

func transferir_b_para_mbr() -> void:
	atualizar_registrador_mbr(self.registrador_b)

func transferir_a_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_a)

func transferir_b_para_alu_b() -> void:
	atualizar_alu_entrada_b(self.registrador_b)
	
func transferir_b_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_b)

func transferir_mar_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_mar)

func transferir_ix_para_alu_b() -> void:
	atualizar_alu_entrada_b(self.registrador_ix)
	
func transferir_mbr_para_alu_b() -> void:
	atualizar_alu_entrada_b(self.registrador_mbr)
	
func transferir_mbr_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_mbr)

func transferir_mar_para_pc() -> void:
	atualizar_registrador_pc(self.registrador_mar)

func transferir_b_para_a() -> void:
	atualizar_registrador_a(self.registrador_b)

func transferir_mar_para_pp() -> void:
	atualizar_registrador_pp(self.registrador_mar)

func transferir_ix_para_a() -> void:
	var resultado: PackedStringArray = self.registrador_ix.como_hex_array()
	var nibble_inferior: String = resultado[-1]
	var valor: Valor = Valor.novo_de_hex(nibble_inferior)
	atualizar_registrador_a(valor)

func transferir_ix_para_b() -> void:
	var resultado: PackedStringArray = self.registrador_ix.como_hex_array()
	var nibble_superior: String = resultado[0]
	var valor: Valor = Valor.novo_de_hex(nibble_superior)
	atualizar_registrador_b(valor)

func transferir_b_para_aux() -> void:
	atualizar_registrador_aux(self.registrador_b)

func adicao_alu_a_alu_b() -> void:
	# TODO: Lidar com flags e overflow
	var resultado: Valor = Valor.novo_de_valor(self.alu_entrada_a)
	resultado.somar_valor(self.alu_entrada_b)
	resultado._valor = resultado._valor & 0xFFFF
	atualizar_alu_saida(resultado)
	
func transferir_alu_saida_para_a() -> void:
	# TODO: Garantir que a saída é 8 bits
	var resultado: Valor = Valor.novo_de_valor(self.alu_saida)
	resultado._valor = resultado._valor & 0xFF
	atualizar_registrador_a(resultado)
	self.atualizar_flags(resultado, true, true, true, true)

func transferir_alu_saida_para_b() -> void:
	# TODO: Garantir que a saída é 8 bits
	var resultado: Valor = Valor.novo_de_valor(self.alu_saida)
	resultado._valor = resultado._valor & 0xFF
	atualizar_registrador_b(resultado)

func transferir_alu_saida_para_mar() -> void:
	atualizar_registrador_mar(self.alu_saida)

func transferir_alu_saida_para_mbr() -> void:
	atualizar_registrador_mbr(self.alu_saida)

func transferir_pp_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pp)

func transferir_flags_para_mbr() -> void:
	var registrador_flag: PackedStringArray = ['0', '0', self.flag_o.como_hex(1), 
	self.flag_c.como_hex(1), self.flag_n.como_hex(1), self.flag_z.como_hex(1), '0', '0']
	var flag_como_int: int = "".join(registrador_flag).bin_to_int()
	atualizar_registrador_mbr(Valor.new(flag_como_int))

func mover_mar_ao_endereco_de_memoria() -> void:
	Memoria.endereco_selecionado = CPU.registrador_mar
	endereco_selecionado_foi_alterado.emit()

func mover_valor_da_memoria_ao_aux() -> void:
	var valor = Memoria.ler_conteudo_no_endereco_selecionado()
	CPU.atualizar_registrador_aux(valor)

func mover_valor_da_memoria_ao_mbr() -> void:
	var valor = Memoria.ler_conteudo_no_endereco_selecionado()
	CPU.atualizar_registrador_mbr(valor)

func mover_mbr_para_endereco_selecionado() -> void:
	Memoria.atualizar_valor_no_endereco_selecionado(CPU.registrador_mbr)
	endereco_selecionado_foi_alterado.emit()

func mover_aux_para_endereco_selecionado() -> void:
	Memoria.atualizar_valor_no_endereco_selecionado(CPU.registrador_aux)
	endereco_selecionado_foi_alterado.emit()

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

func validar_fim_de_execucao() -> void:
	# Se a instrução atual for CAL EXIT, finalizar a execução
	if (self.registrador_ir.como_int() == 0x58) and (self.registrador_mar.como_int() == 0x1200):
		SoftwareManager.finalizar_execucao()

func realizar_complemento_a_dois_na_alu() -> void:
	var resultado = ~self.alu_entrada_a.como_int() + 1
	var valor = Valor.new(resultado & 0xFF)
	atualizar_alu_saida(valor)

func realizar_complemento_a_um_na_alu_a() -> void:
	var resultado = ~self.alu_entrada_a.como_int()
	var valor = Valor.new(resultado & 0xFF)
	atualizar_alu_saida(valor)

func realizar_e_logico_alu_a_alu_b():
	var resultado: int = self.alu_entrada_a.como_int() & self.alu_entrada_b.como_int()
	var valor = Valor.new(resultado)
	atualizar_alu_saida(valor)

func atualizar_flags(valor: Valor, z: bool, n: bool, c: bool, o: bool):
	if z:
		self.flag_z = Valor.new(valor.como_int() == 0)
		self.flag_z_foi_atualizada.emit()
	
	if n:
		self.flag_n = Valor.new(valor.como_int() >= 128)
		self.flag_n_foi_atualizada.emit()
	
	if c:
		self.flag_c_foi_atualizada.emit()
	
	if o:
		self.flag_o_foi_atualizada.emit()
	
	SoftwareManager.realizar_calculo_de_flags()

func se_ix_diferente_de_zero():
	return not CPU.registrador_ix.igual(Valor.new(0))
