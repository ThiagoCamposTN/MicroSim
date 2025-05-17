extends Node

signal programa_carregado
signal status_atualizado


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

static func obter_programa() -> PackedStringArray:
	var programa: PackedStringArray = Estado.config_padrao.get_value("inicio", "instrucoes", [])

	if typeof(programa) != TYPE_PACKED_STRING_ARRAY:
		push_error("\"instrucoes\" tem um tipo inválido")
		return []

	return programa

func carregar_programa(caminho):
	var arquivo : FileAccess 		= FileAccess.open(caminho, FileAccess.READ)
	var dados 	: PackedStringArray	= arquivo.get_as_text().split('\n')
	arquivo.close()
	self.programa_carregado.emit(dados)
