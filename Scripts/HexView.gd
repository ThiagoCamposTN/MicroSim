extends Control

signal hex_foi_selecionado

@export var hex_view_byte_scene : PackedScene
var elementos_viewer : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Memoria.endereço_de_memoria_foi_atualizado.connect(atualizar_celula)
	Memoria.grupo_da_memoria_foi_atualizado.connect(atualizar_grupo_de_celulas)
	Memoria.memoria_foi_recarregada.connect(reinicializar_hex_grid)
	
	self.inicializar_hex_grid()

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

func reinicializar_hex_grid():
	if not SoftwareManager.atualizacao_visual_ativa:
		return
	
	self.inicializar_hex_grid()
	
func inicializar_hex_grid():
	# esvazia o HexGrid
	for i in %HexGrid.get_children():
		%HexGrid.remove_child(i)
	elementos_viewer = []
	
	var current_linha: Valor = Valor.new(0)
	for celula: int in Memoria.celulas:
		var valor: Valor = Valor.new(celula)
		if current_linha.como_int() % 16 == 0:
			adicionar_label(current_linha.como_hex(3))
			elementos_viewer.append(VSeparator.new())
		adicionar_label(valor.como_hex(2), current_linha.como_hex(3))
		current_linha.somar_int(1)
	
	for label in elementos_viewer:
		%HexGrid.add_child(label)
	
func atualizar_celula(endereço: Valor):
	var celula : Button = %HexGrid.get_node(endereço.como_hex(3))
	celula.text = Memoria.ler_conteudo_no_endereco(endereço).como_hex(2)
	celula.add_theme_color_override("font_color", Color.CYAN)

func atualizar_grupo_de_celulas(endereco: Valor, tamanho: int):
	var endereco_int = endereco.como_int()
	for i: int in range(endereco_int, endereco_int + tamanho):
		atualizar_celula(Valor.new(i))

func ao_clicar_elemento(elemento: Button):
	hex_foi_selecionado.emit(elemento)
