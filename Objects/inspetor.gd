extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_tela(elemento: Button):
	var opcode = "???"
	var instrucao 		= Compilador.descompilar(elemento.text)
	var valor_em_int 	= Utils.de_hex_string_para_inteiro(elemento.text)
	var endereco_em_int = Utils.de_hex_string_para_inteiro(elemento.name)
	
	if instrucao:
		opcode = "{mnemonico} (endereçamento {enderecamento})".format({
				"mnemonico": instrucao.mnemonico, 
				"enderecamento": instrucao.enderecamento_como_string()
			})
	
	var text = """
	Endereço ([color=gray]{end_hex}[/color]):
		* Hex: [b]{end_hex}[/b]
		* Bin: [b]{end_bin}[/b]
		
	Valor ([color=gray]{valor}[/color]):
		* Hex: [b]{valor}[/b]
		* Bin: [b]{binario}[/b]
		* Como mnemônico: [b]{opcode}[/b]
	""".format({"end_hex": elemento.name, "end_bin": Utils.int_para_bin(endereco_em_int) , "valor": elemento.text,
		"binario": Utils.int_para_bin(valor_em_int), "opcode": opcode})
	
	$Label.text = text
