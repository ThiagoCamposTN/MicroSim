extends TabBar


@onready var painel_instrucoes : Tree = %PainelInstrucoes
var painel_root

var iniciar_descompilação : bool = false
@onready var endereço_inicial: Valor = Valor.new(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	painel_instrucoes.set_column_title(0, "Endereço")
	painel_instrucoes.set_column_title(1, "Bytes")
	painel_instrucoes.set_column_title(2, "Instrução")
	painel_root = painel_instrucoes.create_item()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if iniciar_descompilação:
		var valor 			: Valor		= Memoria.ler_conteudo_no_endereco(endereço_inicial)
		var instrucao_atual : Instrucao = Compilador.descompilar(valor)
		var valor_em_hex 	: String 	= valor.como_hex(2)
		
		if instrucao_atual:
			instrucao_atual.opcode 		= valor_em_hex
			instrucao_atual.parametros 	= Compilador.buscar_parametros_na_memoria(endereço_inicial, instrucao_atual.enderecamento)
		
		# Parte do endereço
		var valor_endereco: Valor = endereço_inicial
		
		# Parte dos bytes
		var valor_bytes = valor_em_hex
		endereço_inicial.somar_int(1)
		
		if instrucao_atual and instrucao_atual.parametros.size():
			valor_bytes += " " + " ".join(instrucao_atual.parametros)
			endereço_inicial.somar_int(instrucao_atual.parametros.size())
		
		# Parte da instrução
		var valor_instrucao
		if instrucao_atual:
			valor_instrucao = instrucao_atual.instrucao_em_string()
		else:
			valor_instrucao = "??"
		
		adicionar_instrucao(valor_endereco.como_hex(3), valor_bytes, valor_instrucao)

		if SoftwareManager.unica_instrucao:
			iniciar_descompilação = false
		
		if endereço_inicial.como_int() >= Memoria.celulas.size():
			iniciar_descompilação = false

func execucao_iniciada(endereco: Valor):
	iniciar_descompilação = true
	endereço_inicial = endereco

func _on_descompilar_button_pressed():
	execucao_iniciada(CPU.registrador_pc)

func adicionar_instrucao(posicao: String, bytes: String, instrucao: String):
	var tree_item = painel_instrucoes.create_item(painel_root)
	tree_item.set_text(0, posicao)
	tree_item.set_text(1, bytes)
	tree_item.set_text(2, instrucao)
