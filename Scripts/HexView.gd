extends Control

signal hex_foi_selecionado

@export var hex_view_byte_scene : PackedScene
var elementos_viewer : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Memoria.endereço_de_memoria_foi_atualizado.connect(atualizar_celula)
	Memoria.grupo_da_memoria_foi_atualizado.connect(atualizar_grupo_de_celulas)
	Memoria.memoria_foi_recarregada.connect(inicializar_hex_grid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func adicionar_label(texto: String, nome: String = ""):
	var hex_view_byte : Button = hex_view_byte_scene.instantiate()
	if nome:
		hex_view_byte.name = nome
		hex_view_byte.focus_entered.connect(ao_clicar_elemento.bind(hex_view_byte))
	else:
		hex_view_byte.disabled = true
		hex_view_byte.focus_mode = FOCUS_NONE
	hex_view_byte.text = texto
	elementos_viewer.append(hex_view_byte)

func inicializar_hex_grid():
	# esvazia o HexGrid
	for i in %HexGrid.get_children():
		%HexGrid.remove_child(i)
	elementos_viewer = []
	
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
	celula.text = Memoria.ler_hex_no_endereco(posicao)
	celula.add_theme_color_override("font_color", Color.CYAN)

func atualizar_grupo_de_celulas(endereco, tamanho):
	var i = endereco
	while (i < endereco + tamanho):
		atualizar_celula(i)
		i+=1

func ao_clicar_elemento(elemento: Button):
	hex_foi_selecionado.emit(elemento)
