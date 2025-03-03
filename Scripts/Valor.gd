class_name Valor


var _valor: int = 0


func _init(valor_inicial: int):
	self._valor = valor_inicial

func como_hex(casas: int = 2, prefixado: bool = false) -> String:
	return Valor.int_para_hex(self._valor, casas, prefixado)

func como_int() -> int:
	return self._valor

func como_bin() -> String:
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
	var hex_array = self.como_hex_array(casas)
	var resultado : PackedByteArray
	for i in hex_array:
		resultado.push_back(Valor.hex_para_int(i))
	return resultado

func como_hex_array(casas:int = 2) -> PackedStringArray:
	var valor_em_hex: String = self.como_hex(casas)
	var resultado : PackedStringArray
	for i in range(0, valor_em_hex.length(), 2):
		resultado.push_back(valor_em_hex.substr(i, 2))
	return resultado

func somar_valor(outro: Valor) -> void:
	self.somar_int(outro._valor)

func somar_int(outro: int) -> void:
	self._valor += outro

func igual(outro: Valor) -> bool:
	return (self._valor == outro._valor)

func limitar_entre(minimo: int, maximo: int) -> void:
	self._valor = clampi(self._valor, minimo, maximo)

func nibble_superior():
	pass

static func novo_de_int(valor_int: int) -> Valor:
	return Valor.new(valor_int)

static func novo_de_hex(valor_hex: String) -> Valor:
	return Valor.new(Valor.hex_para_int(valor_hex))

static func novo_de_valor(valor: Valor) -> Valor:
	return Valor.new(valor.como_int())

static func hex_para_int(numero: String) -> int:
	return numero.hex_to_int()

static func int_para_hex(valor_em_int: int, casas: int, prefixado: bool = false) -> String:
	var resultado = (("%0" + str(casas) + "x") % valor_em_int).to_upper()
	if prefixado:
		resultado = "0x" + resultado
	return resultado
