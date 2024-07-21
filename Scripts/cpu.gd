extends Node

# TODO: talvez trocar tudo para PackedByteArray

signal registrador_a_foi_atualizado
signal registrador_b_foi_atualizado

# registradores
var registrador_a	: int = 0x00	# Registrador de 8 bits
var registrador_b	: int = 0x08	# Registrador de 8 bits
var registrador_co	: int = 0x0000	# Registrador de 16 bits
var registrador_ix	: int = 0x6E35	# Registrador de 16 bits
var registrador_pp	: int = 0x0FFF	# Registrador de 16 bits
var registrador_don : int			# Registrador de 8 bits
var registrador_aux : int			# Registrador de 8 bits
var registrador_rad : int			# Registrador de 16 bits
var registrador_z	: int = 0x0		# Registrador de 1 bit
var registrador_n	: int = 0x0		# Registrador de 1 bit
var registrador_r	: int = 0x0		# Registrador de 1 bit
var registrador_d	: int = 0x1		# Registrador de 1 bit

# unidade de controle
var registrador_dcod : int  # Registrador de 1 bit

# unidade lógica e aritmética
var ula_entrada_a 	: int  # Registrador de 16 bits
var ula_entrada_b 	: int  # Registrador de 16 bits
var ula_saida 		: int  # Registrador de 16 bits


func atualizar_registrador_a(novo_valor : int):
	self.registrador_a = novo_valor
	registrador_a_foi_atualizado.emit()

func atualizar_registrador_b(novo_valor : int):
	self.registrador_b = novo_valor
	registrador_b_foi_atualizado.emit()
