extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	var ch = CodeHighlighter.new()
	for keyword in ["LDA", "LDB", "STA", "ABA", "CAL", "EXIT"]:
		ch.add_keyword_color(keyword, Color.SKY_BLUE)
	ch.add_color_region("{", "}", Color.MEDIUM_PURPLE)
	ch.number_color = Color.PALE_VIOLET_RED
	ch.symbol_color = Color.WHITE_SMOKE
	#$CodeEdit.syntax_highlighter = ch
	
	# SoftwareManager.inicialização_finalizada.connect(atualizar_codigo)
	Estado.sobrecarregar_programa.connect(atualizar_codigo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var numero_endereco 	: int 				= $HBoxContainer/LineEdit2.obter_endereco()
	var codigo 				: String 			= $CodeEdit.text
	var linhas				: PackedStringArray	= codigo.split("\n", false)

	SoftwareManager.salvar_codigo_em_memoria(linhas, numero_endereco)
	#print("Dado no endereço de memória [0000]: ", Memoria.ler_conteudo_no_endereco(0))

func atualizar_codigo(instrucoes: PackedStringArray):
	$CodeEdit.text = "\n".join(instrucoes)
