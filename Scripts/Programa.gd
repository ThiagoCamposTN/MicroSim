extends Node


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
