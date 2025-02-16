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
			var valor = Utils.de_hex_string_para_inteiro(self.parametros[0])
			bytes.push_back(valor)
		Instrucao.Enderecamentos.DIRETO:
			var valor_em_hex 	= Utils.formatar_hex_como_endereco(self.parametros[0])
			var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
			for valor in valor_dividido:
				bytes.push_back(valor)
		Instrucao.Enderecamentos.IMPLICITO:
			# Não precisa tratar parâmetros
			pass
		Instrucao.Enderecamentos.INDEXADO:
			var valor_em_hex 	= Utils.formatar_hex_como_endereco(self.parametros[0])
			var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
			for valor in valor_dividido:
				bytes.push_back(valor)
		Instrucao.Enderecamentos.INDIRETO:
			var valor_em_hex 	= Utils.formatar_hex_como_endereco(self.parametros[0])
			var valor_dividido 	= Utils.de_endereco_hex_para_bytes(valor_em_hex)
			for valor in valor_dividido:
				bytes.push_back(valor)
		Instrucao.Enderecamentos.POS_INDEXADO:
			# TODO
			pass
		Instrucao.Enderecamentos.PRE_INDEXADO:
			# TODO
			pass
	
	return bytes

static func instrucao_call_exit(instrucao : Instrucao):
	if not instrucao:
		return false
	return (instrucao.mnemonico == "CAL") and (instrucao.parametros == PackedStringArray(["12", "00"]))
