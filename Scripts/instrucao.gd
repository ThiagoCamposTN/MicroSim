class_name Instrucao

enum Enderecamentos { POS_INDEXADO, PRE_INDEXADO, INDIRETO, IMEDIATO, DIRETO, IMPLICITO, INDEXADO }

var enderecamento 		: Enderecamentos
var mnemonico			: String
var parametro			: Valor
var opcode				: String
var tamanho_parametro	: int
	
func _init(mnemônico: String, tipo_enderecamento: Enderecamentos):
	var operador: Operador = Operacoes.obter_operador(mnemônico)
	self.enderecamento 		= tipo_enderecamento
	self.mnemonico 			= mnemônico
	self.tamanho_parametro 	= operador.bytes
	self.opcode 			= Operacoes.mnemonico_para_byte(mnemônico, tipo_enderecamento)

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
			return "{0} [{1}], X".format([self.mnemonico, self.parametro_como_hex()])
		Enderecamentos.PRE_INDEXADO:
			return "{0} [{1}, X]".format([self.mnemonico, self.parametro_como_hex()])
		Enderecamentos.INDIRETO:
			return "{0} [{1}]".format([self.mnemonico, self.parametro_como_hex()])
		Enderecamentos.IMEDIATO:
			return "{0} #{1}".format([self.mnemonico, self.parametro_como_hex()])
		Enderecamentos.DIRETO:
			return "{0} {1}".format([self.mnemonico, self.parametro_como_hex()])
		Enderecamentos.IMPLICITO:
			return self.mnemonico
		Enderecamentos.INDEXADO:
			return "{0} {1}, X".format([self.mnemonico, self.parametro_como_hex()])
		_ :
			return ""

func parametro_como_hex() -> String:
	return self.parametro.como_hex(self.tamanho_parametro)

func instrucao_como_bytes() -> PackedByteArray:
	var bytes: Array = self.parametro.como_byte_array(self.tamanho_parametro)
	var mnemonico_como_byte: String = Operacoes.mnemonico_para_byte(self.mnemonico, self.enderecamento)
	bytes.push_front(Valor.hex_para_int(mnemonico_como_byte))
	return bytes

func obter_mnemonico() -> String:
	return self.operador.mnemonico

func atualizar_parametro(novo_parametro: String):
	if novo_parametro == "EXIT":
		self.parametro = Valor.novo_de_int(0x1200)
	self.parametro = Valor.novo_de_hex(novo_parametro)

static func instrucao_call_exit(instrucao : Instrucao):
	if not instrucao:
		return false
	return (instrucao.mnemonico == "CAL") and (instrucao.parametro.como_int() == 0x1200)
