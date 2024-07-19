extends Node

class_name Utils

static func de_hex_string_para_inteiro(numero : String) -> int:
	return ("0x" + numero).hex_to_int()
