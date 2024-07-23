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
