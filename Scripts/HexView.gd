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
	var current_linha : int = 0
	
	for celula in Memoria.celulas:
		var endereco_celula = Utils.int_para_hex(current_linha, 3)
		if current_linha % 16 == 0:
			adicionar_label(endereco_celula)
			elementos_viewer.append(VSeparator.new())
		adicionar_label(Utils.int_para_hex(celula, 2), endereco_celula)
		current_linha += 1
	
	for label in elementos_viewer:
		%HexGrid.add_child(label)
	
func atualizar_celula(posicao : int):
	var celula : Button = %HexGrid.get_node(Utils.int_para_hex(posicao, 3))
	var conteudo : int = Memoria.ler_conteudo_no_endereco(posicao)
	celula.text = Utils.int_para_hex(conteudo, 2)

func atualizar_grupo_de_celulas(endereco, tamanho):
	var i = endereco
	while (i <= endereco + tamanho):
		atualizar_celula(i)
		i+=1

func ao_clicar_elemento(elemento: Button):
	var opcode = "???"
	var valor_em_int 	= Utils.de_hex_string_para_inteiro(elemento.text)
	var instrucao 		= Compilador.descompilar(valor_em_int)
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
	
	get_node("HSplitContainer/Inspetor/Label").text = text
