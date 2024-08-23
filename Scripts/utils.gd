extends Node

class_name Utils

static func de_hex_string_para_inteiro(numero : String) -> int:
	return ("0x" + numero).hex_to_int()

static func formatar_hex_como_endereco(valor : String) -> String:
	return "%04x" % Utils.de_hex_string_para_inteiro(valor)

static func de_endereco_hex_para_bytes(valor : String) -> PackedByteArray:
	var resultado : PackedByteArray
	for i in range(0, valor.length(), 2):
		resultado.push_back(Utils.de_hex_string_para_inteiro(valor.substr(i, 2)) )
	return resultado

static func int_para_hex(valor : int, casas : int) -> String:
	return (("%0" + str(casas) + "x") % valor).to_upper()

static func int_para_bin(valor : int) -> String:
	# Baseado nessa função por Ryn
	# https://forum.godotengine.org/t/convert-int-to-binary-string/63279/3
	if valor == 0:
		return "0"
	var bin_str: String = ""
	while valor > 0:
		bin_str = str(valor & 1) + bin_str
		valor = valor >> 1
	return bin_str

static func limitar_para_endereco(valor : int) -> int:
	if valor < 0:
		return 0
	if valor >= Memoria.TAMANHO_MEMORIA:
		return Memoria.TAMANHO_MEMORIA - 1
	return valor
