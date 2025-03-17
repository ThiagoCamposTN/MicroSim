extends TabBar


@onready var painel_instrucoes: Tree = %PainelInstrucoes
var painel_root: TreeItem

var iniciar_descompilação : bool = false
@onready var endereço_inicial: Valor = Valor.new(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	painel_instrucoes.set_column_title(0, "Endereço")
	painel_instrucoes.set_column_title(1, "Bytes")
	painel_instrucoes.set_column_title(2, "Instrução")
	self.limpar_arvore()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if iniciar_descompilação:
		if endereço_inicial.como_int() >= Memoria.celulas.size():
			iniciar_descompilação = false
			return
		
		if Simulador.modo_atual == Simulador.ModoExecucao.UNICA_INSTRUCAO:
			iniciar_descompilação = false
		
		var valor 			: Valor		= Memoria.ler_conteudo_no_endereco(endereço_inicial)
		var instrucao_atual : Instrucao = Compilador.descompilar(valor)
		var valor_em_hex 	: String 	= valor.como_hex(2)
		var endereco_em_hex	: String 	= endereço_inicial.como_hex(3)

		endereço_inicial.somar_int(1)
		
		# contemplando os casos em que a instrução não existe e se o parâmetro de uma instrução ultrapassar a área da memória
		if not instrucao_atual or \
		(endereço_inicial.como_int() + instrucao_atual.tamanho_do_dado) >= Memoria.celulas.size():
			adicionar_instrucao(endereco_em_hex, valor_em_hex, "??")
			return
		
		instrucao_atual.parametro 	= Compilador.buscar_parametro_na_memoria(endereço_inicial, instrucao_atual.tamanho_do_dado)
		instrucao_atual.opcode 		= valor_em_hex

		adicionar_instrucao(endereco_em_hex, valor_em_hex, instrucao_atual.instrucao_em_string())

		endereço_inicial.somar_int(instrucao_atual.tamanho_do_dado)

func execucao_iniciada(endereco: Valor):
	self.limpar_arvore()
	iniciar_descompilação = true
	endereço_inicial = Valor.novo_de_valor(endereco)

func _on_descompilar_button_pressed():
	execucao_iniciada(CPU.registrador_pc)

func adicionar_instrucao(posicao: String, bytes: String, instrucao: String):
	var tree_item = painel_instrucoes.create_item(painel_root)
	tree_item.set_text(0, posicao)
	tree_item.set_text(1, bytes)
	tree_item.set_text(2, instrucao)

func limpar_arvore():
	painel_instrucoes.clear()
	painel_root = painel_instrucoes.create_item()
