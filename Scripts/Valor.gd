class_name Valor


var _valor: int = 0


func _init(valor_inicial: int):
	self._valor = valor_inicial

func como_hex(casas: int = 2, prefixado: bool = false):
	return Valor.int_para_hex(self._valor, casas, prefixado)

func como_inteiro() -> int:
	return self._valor

func como_binario() -> String:
	# Baseado nessa função por Ryn
	# https://forum.godotengine.org/t/convert-int-to-binary-string/63279/3
	var valor = self._valor
	if valor == 0:
		return "0"
	var bin_str: String = ""
	while valor > 0:
		bin_str = str(valor & 1) + bin_str
		valor = valor >> 1
	return bin_str

func como_byte_array(casas:int = 2) -> PackedByteArray:
	var valor_em_hex = self.como_hex(casas)
	var resultado : PackedByteArray
	for i in range(0, valor_em_hex.length(), 2):
		resultado.push_back(Utils.de_hex_string_para_inteiro(valor_em_hex.substr(i, 2)) )
	return resultado

static func novo_de_hex(valor_em_hex: String) -> Valor:
	return Valor.new(Valor.hex_para_int(valor_em_hex))

static func hex_para_int(numero: String) -> int:
	return numero.hex_to_int()

static func int_para_hex(valor_em_int: int, casas: int, prefixado: bool = false) -> String:
	var resultado = (("%0" + str(casas) + "x") % valor_em_int)
	if prefixado:
		resultado = "0x" + resultado
	return resultado
