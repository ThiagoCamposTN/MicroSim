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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var numero_endereco 	: int 		= $HBoxContainer/LineEdit2.obter_endereco()
	var codigo 				: String 	= $CodeEdit.text
	SoftwareManager.salvar_codigo_em_memoria(codigo, numero_endereco)
	#print("Dado no endereço de memória [0000]: ", Memoria.ler_conteudo_no_endereco(0))
