extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	inicializar_hex_grid()
	Memoria.memoria_foi_atualizada.connect(atualizar_celula)
	Memoria.grupo_da_memoria_foi_atualizado.connect(atualizar_grupo_de_celulas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func adicionar_label(texto: String, nome: String = ""):
	var label = Label.new()
	if nome:
		label.name = nome
	label.text = texto
	$HexGrid.add_child(label)

func inicializar_hex_grid():
	var current_linha = 0
	
	for celula in Memoria.dados:
		var endereco_celula = Utils.int_para_hex(current_linha, 3)
		if current_linha % 16 == 0:
			adicionar_label(endereco_celula)
			$HexGrid.add_child(VSeparator.new())
		
		adicionar_label(Utils.int_para_hex(celula, 2), endereco_celula)
		current_linha += 1

func atualizar_celula(posicao : int):
	var celula : Label = get_node("HexGrid").get_node(Utils.int_para_hex(posicao, 3))
	celula.text = Utils.int_para_hex(Memoria.dados[posicao], 2)

func atualizar_grupo_de_celulas(endereco, tamanho):
	var i = endereco
	while (i <= endereco + tamanho):
		atualizar_celula(i)
		i+=1
