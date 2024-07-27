class_name Instrucao

enum Enderecamentos { POS_INDEXADO, PRE_INDEXADO, INDIRETO, IMEDIATO, DIRETO, IMPLICITO, INDEXADO }

var enderecamento 	: Enderecamentos
var mnemonico		: String
var parametros		: PackedStringArray
	
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
