extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var endereco_inicial 	: String = $HBoxContainer/LineEdit.text
	# TODO: Colocar um erro se o campo de endereço inicial estiver vazio?
	var codigo 				: String = $CodeEdit.text
	SoftwareManager.salvar_codigo_em_memoria(codigo, endereco_inicial)
	var numero_endereco : int = Utils.de_hex_string_para_inteiro(endereco_inicial)
	print("Dado no endereço de memória [0000]: ", Memoria.dados[0])
