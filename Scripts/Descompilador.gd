extends TabBar

@onready var descompilador = $MarginContainer/HSplitContainer/VBoxContainer2/Panel

@onready var painel_instrucoes : Tree = %PainelInstrucoes
var painel_root

var iniciar_descompilação : bool = false
var endereço_inicial

# Called when the node enters the scene tree for the first time.
func _ready():
	painel_instrucoes.set_column_title(0, "Endereço")
	painel_instrucoes.set_column_title(1, "Bytes")
	painel_instrucoes.set_column_title(2, "Instrução")
	painel_root = painel_instrucoes.create_item()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if iniciar_descompilação:
		
		var valor 			: String	= Memoria.ler_hex_no_endereco(endereço_inicial)
		var instrucao_atual : Instrucao = Compilador.descompilar(valor)
		
		if instrucao_atual:
			instrucao_atual.opcode 		= valor
			instrucao_atual.parametros 	= Compilador.buscar_parametros_na_memoria(endereço_inicial, instrucao_atual.enderecamento)
		
		# Parte do endereço
		var valor_endereco = Utils.int_para_hex(endereço_inicial, 3)
		
		# Parte dos bytes
		var valor_bytes = valor
		endereço_inicial += 1
		
		if instrucao_atual and instrucao_atual.parametros.size():
			valor_bytes += " " + " ".join(instrucao_atual.parametros)
			endereço_inicial += instrucao_atual.parametros.size()
		
		# Parte da instrução
		var valor_instrucao
		if instrucao_atual:
			valor_instrucao = instrucao_atual.instrucao_em_string()
		else:
			valor_instrucao = "??"
		
		
		adicionar_instrucao(valor_endereco, valor_bytes, valor_instrucao)

		if SoftwareManager.unica_instrucao:
			iniciar_descompilação = false
		
		if endereço_inicial >= Memoria.celulas.size():
			iniciar_descompilação = false

func _on_button_pressed():
	SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)

func execucao_iniciada(endereco : int):
	iniciar_descompilação = true
	endereço_inicial = endereco

func _on_descompilar_button_pressed():
	execucao_iniciada(CPU.registrador_pc)

func adicionar_instrucao(posicao: String, bytes: String, instrucao: String):
	var tree_item = painel_instrucoes.create_item(painel_root)
	tree_item.set_text(0, posicao)
	tree_item.set_text(1, bytes)
	tree_item.set_text(2, instrucao)
