class_name Instrucao

enum Enderecamentos { POS_INDEXADO, PRE_INDEXADO, INDIRETO, IMEDIATO, DIRETO, IMPLICITO, INDEXADO }

var enderecamento 	: Enderecamentos
var mnemonico		: String
var parametros		: PackedStringArray
var opcode			: String
	
func _init(enderecamento : Enderecamentos, mnemonico : String):
	self.enderecamento 	= enderecamento
	self.mnemonico 		= mnemonico

func enderecamento_como_string() -> String:
	match self.enderecamento:
		Enderecamentos.POS_INDEXADO:
			return "pós-indexado"
		Enderecamentos.PRE_INDEXADO:
			return "pré-indexado"
		Enderecamentos.INDIRETO:
			return "indireto"
		Enderecamentos.IMEDIATO:
			return "imediato"
		Enderecamentos.DIRETO:
			return "direto"
		Enderecamentos.IMPLICITO:
			return "implícito"
		Enderecamentos.INDEXADO:
			return "indexado"
		_ :
			return ""

func instrucao_em_string() -> String:
	match self.enderecamento:
		Enderecamentos.POS_INDEXADO:
			return ""
		Enderecamentos.PRE_INDEXADO:
			return ""
		Enderecamentos.INDIRETO:
			return self.mnemonico + " [" + "".join(self.parametros) + "]"
		Enderecamentos.IMEDIATO:
			return self.mnemonico + " #" + "".join(self.parametros)
		Enderecamentos.DIRETO:
			return self.mnemonico + " " + "".join(self.parametros)
		Enderecamentos.IMPLICITO:
			return self.mnemonico
		Enderecamentos.INDEXADO:
			return self.mnemonico + " " + "".join(self.parametros) + ", X"
		_ :
			return ""

func parametros_em_bytes() -> PackedByteArray:
	var bytes: PackedByteArray

	if self.parametros and self.parametros[0] == "EXIT":
		bytes.push_back(0x12)
		bytes.push_back(0x00)
		return bytes # salta os parâmetros

	# Resolução dos parâmetros da instrução na memória
	match self.enderecamento:
		Instrucao.Enderecamentos.IMEDIATO:
			var valor: Valor = Valor.novo_de_hex(self.parametros[0])
			bytes.push_back(valor.como_int())
		Instrucao.Enderecamentos.IMPLICITO:
			# Não precisa tratar parâmetros
			pass
		Instrucao.Enderecamentos.DIRETO, Instrucao.Enderecamentos.INDEXADO, \
		Instrucao.Enderecamentos.INDIRETO, Instrucao.Enderecamentos.POS_INDEXADO, \
		Instrucao.Enderecamentos.PRE_INDEXADO:
			var valor: Valor = Valor.novo_de_hex(self.parametros[0])
			for _valor: int in valor.como_byte_array(4):
				bytes.push_back(_valor)
	
	return bytes

func instrucao_em_bytes() -> PackedByteArray:
	var bytes: PackedByteArray
	
	var byte: String = Operacoes.mnemonico_para_byte(self.mnemonico, self.enderecamento)
	bytes.push_back(Valor.hex_para_int(byte))
	
	# Resolução dos parâmetros da instrução na memória
	bytes.append_array(self.parametros_em_bytes())

	return bytes

static func instrucao_call_exit(instrucao : Instrucao):
	if not instrucao:
		return false
	return (instrucao.mnemonico == "CAL") and (instrucao.parametros == PackedStringArray(["12", "00"]))
