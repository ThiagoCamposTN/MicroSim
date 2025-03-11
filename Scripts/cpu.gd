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

func incrementar_um_na_alu_a_8_bits() -> void:
	self.operacao_de_soma_na_alu(self.alu_entrada_a, 1, 1)

func incrementar_um_na_alu_a_16_bits() -> void:
	self.operacao_de_soma_na_alu(self.alu_entrada_a, 2, 1)

func decrementar_um_na_alu_a_8_bits() -> void:
	self.operacao_de_soma_na_alu(self.alu_entrada_a, 2, -1)

func decrementar_um_na_alu_a_16_bits() -> void:
	self.operacao_de_soma_na_alu(self.alu_entrada_a, 2, -1)

func mover_pc_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pc)

func transferir_mbr_para_ir() -> void:
	atualizar_registrador_ir(self.registrador_mbr)

func transferir_mbr_para_a() -> void:
	atualizar_registrador_a(registrador_mbr)

func transferir_mbr_para_b() -> void:
	atualizar_registrador_b(registrador_mbr)

func transferir_aux_para_b() -> void:
	var valor: Valor = Valor.novo_de_valor(self.registrador_aux)
	atualizar_registrador_b(valor)

func iniciar_registrador_pc(endereco: Valor) -> void:
	atualizar_registrador_pc(endereco)

func unir_mbr_ao_aux_e_mover_para_mar() -> void:
	var resultado: Valor = Valor.novo_de_valor(self.registrador_mbr)
	resultado.somar_int(self.registrador_aux.como_int() << 8)
	atualizar_registrador_mar(resultado)

func unir_mbr_ao_aux_e_mover_para_pc() -> void:
	var resultado: Valor = self.unir_mbr_ao_aux()
	atualizar_registrador_pc(resultado)

func unir_mbr_ao_aux_e_mover_para_ix() -> void:
	# TODO: nesse caso, mbr e aux são concatenados ao contrário por alguma razão
	var resultado: Valor = Valor.novo_de_valor(self.registrador_mbr)
	resultado.somar_int(self.registrador_aux.como_int() << 8)
	atualizar_registrador_ix(resultado)

func unir_mbr_ao_aux_e_mover_para_alu_a() -> void:
	var resultado: Valor = self.unir_mbr_ao_aux()
	atualizar_alu_entrada_a(resultado)

func unir_mbr_ao_aux() -> Valor:
	var byte_array: PackedByteArray = [
		self.registrador_mbr.como_int(),
		self.registrador_aux.como_int()
	]
	var resultado: Valor = Valor.novo_de_byte_array(byte_array)
	return resultado

func dividir_ix_e_mover_para_mbr_e_aux() -> void:
	var registrador: PackedByteArray = self.registrador_ix.como_byte_array(4)
	atualizar_registrador_aux(Valor.new(registrador[0]))
	atualizar_registrador_mbr(Valor.new(registrador[1]))

func dividir_pc_e_mover_para_mbr_e_aux() -> void:
	var registrador: PackedByteArray = self.registrador_pc.como_byte_array(4)
	atualizar_registrador_mbr(Valor.new(registrador[0]))
	atualizar_registrador_aux(Valor.new(registrador[1]))

func dividir_alu_saida_e_mover_para_mbr_e_aux() -> void:
	var registrador: PackedByteArray = self.alu_saida.como_byte_array(4)
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

func transferir_alu_saida_para_b() -> void:
	# TODO: Garantir que a saída é 8 bits
	var resultado: Valor = Valor.novo_de_valor(self.alu_saida)
	resultado._valor = resultado._valor & 0xFF
	atualizar_registrador_b(resultado)

func transferir_alu_saida_para_mar() -> void:
	#TODO: analisar se precisa converter a saída de 2 bytes para 1
	var resultado: int = self.alu_saida.como_int()
	var valor: Valor = Valor.novo_de_int(resultado)
	atualizar_registrador_mar(valor)

func transferir_alu_saida_para_mbr() -> void:
	#TODO: analisar se precisa converter a saída de 2 bytes para 1
	var valor: Valor = Valor.novo_de_valor(self.alu_saida)
	atualizar_registrador_mbr(valor)

func transferir_pp_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pp)

func transferir_flags_para_mbr() -> void:
	var registrador_flag: PackedStringArray = ['0', '0', self.flag_o.como_hex(1), 
	self.flag_c.como_hex(1), self.flag_n.como_hex(1), self.flag_z.como_hex(1), '0', '0']
	var flag_como_int: int = "".join(registrador_flag).bin_to_int()
	atualizar_registrador_mbr(Valor.new(flag_como_int))

func transferir_pp_para_alu_a() -> void:
	var resultado: Valor = Valor.novo_de_valor(self.registrador_pp)
	atualizar_alu_entrada_a(resultado)

func transferir_alu_saida_para_pp() -> void:
	var valor: Valor = Valor.novo_de_valor(self.alu_saida)
	atualizar_registrador_pp(valor)

func transferir_pc_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_pc)

func transferir_alu_saida_para_pc() -> void:
	var valor: Valor = Valor.novo_de_valor(self.alu_saida)
	atualizar_registrador_pc(valor)

func transferir_ix_para_alu_a() -> void:
	atualizar_alu_entrada_a(self.registrador_ix)

func transferir_alu_saida_para_ix() -> void:
	var valor: Valor = Valor.novo_de_valor(self.alu_saida)
	atualizar_registrador_ix(valor)

func mover_mar_ao_endereco_de_memoria() -> void:
	Memoria.endereco_selecionado = Valor.novo_de_valor(CPU.registrador_mar)
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

func realizar_complemento_a_dois_na_alu_8_bits() -> void:
	var resultado = Valor.new(~self.alu_entrada_a.como_int())
	self.operacao_de_soma_na_alu(resultado, 1, 1)

func realizar_complemento_a_um_na_alu_a_8_bits() -> void:
	var resultado = Valor.new(~self.alu_entrada_a.como_int())
	var valor: Valor = self.filtrar_resultado_e_verificar_flags(resultado, 1)
	atualizar_alu_saida(valor)

func realizar_e_logico_alu_a_alu_b():
	var resultado: int = self.alu_entrada_a.como_int() & self.alu_entrada_b.como_int()
	var valor = Valor.new(resultado)
	atualizar_alu_saida(valor)

func realizar_divisao_na_alu():
	var dividendo	: int = self.alu_entrada_a.como_int()
	var divisor		: int = self.alu_entrada_b.como_int()

	if divisor == 0:
		print("Errro de divisão por zero")
		SoftwareManager.finalizar_execucao(false)
		return

	var resto		: int = dividendo % divisor
	var quociente	: Valor = Valor.new(floori(dividendo / float(divisor)))
	
	var resultado: PackedByteArray = quociente.como_byte_array(2)
	var valor: Valor = Valor.novo_de_byte_array([resultado[0], resto])

	valor = self.filtrar_resultado_e_verificar_flags(valor, 2)

	atualizar_alu_saida(valor)

func realizar_multiplicacao_na_alu_16_bits():
	var fator_um	: int = self.alu_entrada_a.como_int()
	var fator_dois	: int = self.alu_entrada_b.como_int()
	var produto		: Valor = Valor.new(fator_um * fator_dois)

	var _flag_o: Valor = Valor.new(produto.como_int() > 0xFFFF)
	self.atualizar_flag_o(_flag_o)

	var valor: Valor = self.filtrar_resultado_e_verificar_flags(produto, 2)

	atualizar_alu_saida(valor)

func eh_fim_de_execucao() -> bool:
	return (CPU.registrador_ir.como_int() == 0x58) and (CPU.registrador_mar.como_int() == 0x1200)

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
	
	SoftwareManager.realizar_calculo_de_flags()

	if bytes == 2:
		return Valor.new(resultado & 0xFFFF)
	else:
		return Valor.new(resultado & 0xFF)

func se_ix_diferente_de_zero():
	return not CPU.registrador_ix.igual(Valor.new(0))

func atribuir_um_a_flag_c():
	self.atualizar_flag_c(Valor.new(1))

func atribuir_um_a_flag_o():
	self.atualizar_flag_o(Valor.new(1))

func operacao_de_soma_na_alu(entrada: Valor, bytes: int, quantia: int) -> void:
	var resultado = Valor.novo_de_valor(entrada)
	resultado.somar_int(quantia)
	var _flag_o: Valor = Valor.new(resultado.como_int() > 0xFFFF)
	self.atualizar_flag_o(_flag_o)
	var valor: Valor = self.filtrar_resultado_e_verificar_flags(resultado, bytes)
	atualizar_alu_saida(valor)
