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

static func instrucao_call_exit(instrucao : Instrucao):
	if not instrucao:
		return false
	return (instrucao.mnemonico == "CAL") and (instrucao.parametros == PackedStringArray(["12", "00"]))
