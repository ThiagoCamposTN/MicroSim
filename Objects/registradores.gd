extends VBoxContainer

# TODO: talvez criar apenas uma função que passa o registrador atualizado como parâmetro
@onready var grid_container : Container = $RegistradorGrid

var registradores = [
	{"nome": "A", 	"propriedade": "registrador_a", "sinal": CPU.registrador_a_foi_atualizado,
		"bytes": 1, "tooltip": "Registrador A para armazenamento de dados."},
	{"nome": "B", 	"propriedade": "registrador_b", "sinal": CPU.registrador_b_foi_atualizado,
		"bytes": 1, "tooltip": "Registrador B para armazenamento de dados."},
	{"nome": "PC", 	"propriedade": "registrador_pc", "sinal": CPU.registrador_pc_foi_atualizado,
		"bytes": 2, "tooltip": "Registrador PC (Program Counter), que armazena o ponteiro de aonde o programa está executando na memória."},
	{"nome": "IX", 	"propriedade": "registrador_ix", "sinal": CPU.registrador_ix_foi_atualizado,
		"bytes": 2, "tooltip": "Registrador IX."},
	{"nome": "PP", 	"propriedade": "registrador_pp", "sinal": CPU.registrador_pp_foi_atualizado,
		"bytes": 2, "tooltip": "Registrador PP."},
	{"nome": "MBR", "propriedade": "registrador_mbr", "sinal": CPU.registrador_mbr_foi_atualizado,
		"bytes": 1, "tooltip": "Registrador MBR, que guarda bytes vindo da memória."},
	{"nome": "AUX", 	"propriedade": "registrador_aux", "sinal": CPU.registrador_aux_foi_atualizado,
		"bytes": 1, "tooltip": "Registrador AUX."},
	{"nome": "MAR", 	"propriedade": "registrador_mar", "sinal": CPU.registrador_mar_foi_atualizado,
		"bytes": 2, "tooltip": "Registrador MAR."},
	{"nome": "IR", 	"propriedade": "registrador_ir", "sinal": CPU.registrador_ir_foi_atualizado,
		"bytes": 1, "tooltip": "Registrador IR."},
]

# Called when the node enters the scene tree for the first time.
func _ready():
	for registrador in registradores:
		var valor_registrador = Valor.new(CPU.get(registrador["propriedade"]))
		var valor_convertido: String = valor_registrador.como_hex(registrador["bytes"] * 2)

		var label := Label.new()
		label.text = registrador["nome"]
		label.tooltip_text = registrador["tooltip"]
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var text := Button.new()
		text.disabled = true
		text.text = valor_convertido.to_upper()
		
		grid_container.add_child(label)
		grid_container.add_child(text)
		
		registrador["sinal"].connect(atualizar_registrador.bind(text, registrador["propriedade"], registrador["bytes"] * 2))
	
	CPU.flag_z_foi_atualizada.connect(atualizar_registrador.bind(%ZFlag, "flag_z", 1))
	CPU.flag_n_foi_atualizada.connect(atualizar_registrador.bind(%NFlag, "flag_n", 1))
	CPU.flag_c_foi_atualizada.connect(atualizar_registrador.bind(%CFlag, "flag_c", 1))
	CPU.flag_o_foi_atualizada.connect(atualizar_registrador.bind(%OFlag, "flag_o", 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_registrador(node: Button, propriedade: String, digitos: int) -> void:
	var novo_valor: Valor = Valor.new(CPU.get(propriedade))
	node.text = novo_valor.como_hex(digitos).to_upper()
