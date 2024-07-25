extends HBoxContainer

#signal clicou_em_executar(endereco_inicial : String)


# Called when the node enters the scene tree for the first time.
func _ready():
	#self.clicou_em_executar.connect(SoftwareManager.executar_programa)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	# TODO: Colocar um erro se o campo de endereço inicial estiver vazio?
	var endereco_inicial 	: String 	= $LineEdit.text
	var numero_endereco 	: int 		= Utils.de_hex_string_para_inteiro(endereco_inicial)
	SoftwareManager.executar_programa(numero_endereco)
	#clicou_em_executar.emit(endereco_inicial)
