extends VBoxContainer

# baseado em ghidra e em cheat engine


# Called when the node enters the scene tree for the first time.
func _ready():
	descompilar_a_partir_do_endereco("000")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func descompilar_a_partir_do_endereco(endereco : String):
	var endereco_int 	: int 			= Utils.de_hex_string_para_inteiro(endereco)
	var valor 			: int 			= Memoria.ler_conteudo_no_endereco(endereco_int)
	var instrucao_atual : Instrucao
	
	while endereco_int < 0x1000:
		instrucao_atual = Compilador.descompilar(valor)
		
		if not instrucao_atual:
			endereco_int += 1
			continue
		
		var label_endereco := Label.new()
		label_endereco.text = Utils.int_para_hex(endereco_int, 3)
		$ScrollContainer/GridContainer.add_child(label_endereco)
		
		var label_bytes := Label.new()
		label_bytes.text = Utils.int_para_hex(valor, 2)
		endereco_int += 1
		
		if instrucao_atual:
			label_bytes.text += " ".join(instrucao_atual.parametros)
			endereco_int += instrucao_atual.parametros.size()
		
		$ScrollContainer/GridContainer.add_child(label_bytes)
		
		break
