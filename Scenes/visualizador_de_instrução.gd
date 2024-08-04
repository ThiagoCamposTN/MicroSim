extends Panel

# baseado em ghidra e em cheat engine

@onready var container_grade : ScrollContainer = $VBoxContainer/ScrollContainer
var grade : GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	# no futuro, talvez seja viável criar tudo no começo
	# e só ocultar o que não estaria visível no momento
	grade = GridContainer.new()
	grade.set_columns(3)
	container_grade.add_child(grade)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func descompilar_a_partir_do_endereco(endereco : int):
	grade.queue_free()
	
	grade = GridContainer.new()
	grade.set_columns(3)
	container_grade.add_child(grade)
	
	var valor 			: String
	var instrucao_atual : Instrucao
	
	while endereco < Memoria.celulas.size():
		valor 			= Memoria.ler_hex_no_endereco(endereco)
		instrucao_atual = Compilador.descompilar(valor)
		
		if instrucao_atual:
			instrucao_atual.opcode 		= valor
			instrucao_atual.parametros 	= Compilador.buscar_parametros_na_memoria(endereco, instrucao_atual.enderecamento)
		
		# Parte do endereço
		
		var label_endereco := Label.new()
		label_endereco.text = Utils.int_para_hex(endereco, 3)
		grade.add_child(label_endereco)
		
		# Parte dos bytes
		
		var label_bytes := Label.new()
		label_bytes.text = valor
		endereco += 1
		
		if instrucao_atual and instrucao_atual.parametros.size():
			label_bytes.text += " " + " ".join(instrucao_atual.parametros)
			endereco += instrucao_atual.parametros.size()
		
		grade.add_child(label_bytes)
		
		# Parte da instrução
		
		var label_instrucao := Label.new()
		
		if instrucao_atual:
			label_instrucao.text = instrucao_atual.instrucao_em_string()
		else:
			label_instrucao.text = "??"
		
		grade.add_child(label_instrucao)
