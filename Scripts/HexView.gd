extends Control


var HexViewByte = preload("res://Scenes/HexViewByte.tscn")
var elementos_viewer : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	inicializar_hex_grid()
	Memoria.memoria_foi_atualizada.connect(atualizar_celula)
	Memoria.grupo_da_memoria_foi_atualizado.connect(atualizar_grupo_de_celulas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func adicionar_label(texto: String, nome: String = ""):
	var hex_view_byte : Button = HexViewByte.instantiate()
	if nome:
		hex_view_byte.name = nome
		hex_view_byte.focus_entered.connect(ao_clicar_elemento.bind(hex_view_byte))
	else:
		hex_view_byte.disabled = true
		hex_view_byte.focus_mode = FOCUS_NONE
	hex_view_byte.text = texto
	elementos_viewer.append(hex_view_byte)

func inicializar_hex_grid():
	var current_linha = 0
	
	for celula in Memoria.dados:
		var endereco_celula = Utils.int_para_hex(current_linha, 3)
		if current_linha % 16 == 0:
			adicionar_label(endereco_celula)
			elementos_viewer
			elementos_viewer.append(VSeparator.new())
		adicionar_label(Utils.int_para_hex(celula, 2), endereco_celula)
		current_linha += 1

	for label in elementos_viewer:
		%HexGrid.add_child(elementos_viewer.pop_front())

func atualizar_celula(posicao : int):
	var celula : Button = %HexGrid.get_node(Utils.int_para_hex(posicao, 3))
	celula.text = Utils.int_para_hex(Memoria.dados[posicao], 2)

func atualizar_grupo_de_celulas(endereco, tamanho):
	var i = endereco
	while (i <= endereco + tamanho):
		atualizar_celula(i)
		i+=1

func ao_clicar_elemento(elemento: Button):
	var opcode = "???"
	var instrucao = CODEC.decodificar(Utils.de_hex_string_para_inteiro(elemento.text))
	
	if instrucao:
		opcode = "{mnemonico} (endereçamento {tipo})".format({
				"mnemonico": instrucao.mnemonico, 
				"tipo": instrucao.tipo_como_string()
			})
	
	var text = """
	Endereço ([color=gray]{end_hex}[/color]):
		* Hex: [b]{end_hex}[/b]
		* Dec: [b]{end_dec}[/b]
		
	Valor ([color=gray]{valor}[/color]):
		* Hex: [b]{valor}[/b]
		* Dec: [b]{decimal}[/b]
		* Como mnemônico: [b]{opcode}[/b]
	""".format({"end_hex": elemento.name, "end_dec": Utils.de_hex_string_para_inteiro(elemento.name), "valor": elemento.text,
		"decimal": Utils.de_hex_string_para_inteiro(elemento.text), "opcode": opcode})
	
	get_node("Inspetor/Label").text = text
