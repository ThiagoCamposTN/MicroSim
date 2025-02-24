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
var registrador_a	: int = 0x00	# Registrador de 8 bits
var registrador_b	: int = 0x08	# Registrador de 8 bits
var registrador_pc	: int = 0x0000	# Registrador contador de programa - 16 bits (co)
var registrador_ix	: int = 0x6E35	# Registrador de 16 bits
var registrador_pp	: int = 0x0FFF	# Registrador apontador de pilha - 16 bits
var registrador_mbr : int			# Registrador de buffer de memória - 8 bits (don)
var registrador_aux : int			# Registrador auxiliar - 8 bits
var registrador_mar : int			# Registrador de endereço de memória - 16 bits (rad)

# flags
var flag_z : int = 0x0 # Registrador de 1 bit (Zero)
var flag_n : int = 0x0 # Registrador de 1 bit (Negativo)
var flag_c : int = 0x0 # Registrador de 1 bit (Carry)
var flag_o : int = 0x1 # Registrador de 1 bit (Overflow)

var _flag_z_buffer : int = 0x0 # Registrador de 1 bit
var _flag_n_buffer : int = 0x0 # Registrador de 1 bit
var _flag_c_buffer : int = 0x0 # Registrador de 1 bit
var _flag_o_buffer : int = 0x0 # Registrador de 1 bit

# unidade de controle
var registrador_ir : int # Registrador de instrução - 1 bit (ir)

# unidade lógica e aritmética
var alu_entrada_a 	: int # Registrador de 16 bits
var alu_entrada_b 	: int # Registrador de 16 bits
var alu_saida 		: int # Registrador de 16 bits


func atualizar_registrador_a(novo_valor : int) -> void:
	self.registrador_a = novo_valor
	atualizar_buffers(novo_valor)
	registrador_a_foi_atualizado.emit()

func atualizar_registrador_b(novo_valor : int) -> void:
	self.registrador_b = novo_valor
	atualizar_buffers(novo_valor)
	registrador_b_foi_atualizado.emit()

func atualizar_registrador_pc(novo_valor : int) -> void:
	self.registrador_pc = novo_valor
	registrador_pc_foi_atualizado.emit()

func atualizar_registrador_ix(novo_valor : int) -> void:
	self.registrador_ix = novo_valor
	registrador_ix_foi_atualizado.emit()

func atualizar_registrador_pp(novo_valor : int) -> void:
	self.registrador_pp = novo_valor
	registrador_pp_foi_atualizado.emit()

func atualizar_registrador_mbr(novo_valor : int) -> void:
	self.registrador_mbr = novo_valor
	registrador_mbr_foi_atualizado.emit()

func atualizar_registrador_aux(novo_valor : int) -> void:
	self.registrador_aux = novo_valor
	registrador_aux_foi_atualizado.emit()

func atualizar_registrador_mar(novo_valor : int) -> void:
	self.registrador_mar = novo_valor
	registrador_mar_foi_atualizado.emit()

func atualizar_registrador_ir(novo_valor : int) -> void:
	self.registrador_ir = novo_valor
	registrador_ir_foi_atualizado.emit()

func atualizar_alu_entrada_a(novo_valor : int) -> void:
	self.alu_entrada_a = novo_valor
	alu_entrada_a_foi_atualizado.emit()

func atualizar_alu_entrada_b(novo_valor : int) -> void:
	self.alu_entrada_b = novo_valor
	alu_entrada_b_foi_atualizado.emit()

func atualizar_alu_saida(novo_valor : int) -> void:
	self.alu_saida = novo_valor
	alu_saida_foi_atualizado.emit()

func incrementar_registrador_pc() -> void:
	atualizar_registrador_pc(self.registrador_pc + 1)

func incrementar_registrador_mar() -> void:
	atualizar_registrador_mar(self.registrador_mar + 1)

func incrementar_registrador_pp() -> void:
	atualizar_registrador_pp(self.registrador_pp + 1)

func decrementar_registrador_pp() -> void:
	atualizar_registrador_pp(self.registrador_pp - 1)

func mover_pc_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pc)

func transferir_mbr_para_ir() -> void:
	atualizar_registrador_ir(self.registrador_mbr)

func transferir_mbr_para_a() -> void:
	atualizar_registrador_a(registrador_mbr)

func transferir_mbr_para_b() -> void:
	atualizar_registrador_b(registrador_mbr)

func iniciar_registrador_pc(endereco : int) -> void:
	atualizar_registrador_pc(endereco)

func unir_mbr_ao_aux_e_mover_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_mbr + (self.registrador_aux << 8))

func unir_mbr_ao_aux_e_mover_para_pc() -> void:
	atualizar_registrador_pc(self.registrador_aux + (self.registrador_mbr << 8))

func dividir_ix_e_mover_para_mbr_e_aux() -> void:
	var registrador	: PackedByteArray = Valor.new(self.registrador_ix).como_byte_array(4)
	atualizar_registrador_aux(registrador[0])
	atualizar_registrador_mbr(registrador[1])

func dividir_pc_e_mover_para_mbr_e_aux() -> void:
	var registrador_em_hex	: String 			= Utils.int_para_hex(self.registrador_pc, 4)
	var registrador_em_bytes: PackedByteArray 	= Utils.de_endereco_hex_para_bytes(registrador_em_hex)
	atualizar_registrador_mbr(registrador_em_bytes[0])
	atualizar_registrador_aux(registrador_em_bytes[1])

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

func adicao_alu_a_alu_b() -> void:
	# TODO: Lidar com flags e overflow
	var resultado = self.alu_entrada_a + self.alu_entrada_b
	atualizar_alu_saida(resultado & 0xFFFF)

func transferir_alu_saida_para_a() -> void:
	# TODO: Garantir que a saída é 8 bits
	atualizar_registrador_a(self.alu_saida & 0xFF)

func transferir_alu_saida_para_b() -> void:
	# TODO: Garantir que a saída é 8 bits
	atualizar_registrador_b(self.alu_saida & 0xFF)

func transferir_alu_saida_para_mar() -> void:
	atualizar_registrador_mar(self.alu_saida)

func transferir_alu_saida_para_mbr() -> void:
	atualizar_registrador_mbr(self.alu_saida)

func transferir_pp_para_mar() -> void:
	atualizar_registrador_mar(self.registrador_pp)

func transferir_flags_para_mbr() -> void:
	var registrador_flag: PackedStringArray = ['0', '0', str(self.flag_o), str(self.flag_c), str(self.flag_n), str(self.flag_z), '0', '0']
	var flag_como_hex 	: int 				= "".join(registrador_flag).bin_to_int()
	atualizar_registrador_mbr(flag_como_hex)

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

func atualizar_buffers(novo_valor: int) -> void:
	_flag_z_buffer = (novo_valor == 0)
	_flag_n_buffer = (novo_valor >= 128)

func calcular_z():
	self.atualizar_flag_z(_flag_z_buffer)

func calcular_n():
	self.atualizar_flag_n(_flag_n_buffer)

func calcular_c():
	self.atualizar_flag_c(_flag_c_buffer)

func calcular_o():
	self.atualizar_flag_o(_flag_o_buffer)

func atualizar_flag_z(novo_valor: int) -> void:
	self.flag_z = novo_valor
	flag_z_foi_atualizada.emit()

func atualizar_flag_n(novo_valor: int) -> void:
	self.flag_n = novo_valor
	flag_n_foi_atualizada.emit()

func atualizar_flag_c(novo_valor: int) -> void:
	self.flag_c = novo_valor
	flag_c_foi_atualizada.emit()

func atualizar_flag_o(novo_valor: int) -> void:
	self.flag_o = novo_valor
	flag_o_foi_atualizada.emit()

func validar_fim_de_execucao() -> void:
	# Se a instrução atual for CAL EXIT, finalizar a execução
	if (self.registrador_ir == 0x58) and (self.registrador_mar == 0x1200):
		SoftwareManager.finalizar_execucao()

func realizar_complemento_a_dois_na_alu() -> void:
	var resultado = (~self.alu_entrada_a + 1)
	atualizar_alu_saida(resultado & 0xFF)
