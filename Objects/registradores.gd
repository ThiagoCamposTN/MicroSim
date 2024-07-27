extends VBoxContainer

# TODO: talvez criar apenas uma função que passa o registrador atualizado como parâmetro

# Called when the node enters the scene tree for the first time.
func _ready():
	CPU.registrador_a_foi_atualizado.connect(atualizar_registrador_a)
	CPU.registrador_b_foi_atualizado.connect(atualizar_registrador_b)
	CPU.registrador_mbr_foi_atualizado.connect(atualizar_registrador_mbr)
	CPU.registrador_pc_foi_atualizado.connect(atualizar_registrador_pc)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_registrador_a():
	$HBoxContainer2/ValorRegistradorA.text = str(Utils.int_para_hex(CPU.registrador_a, 2))

func atualizar_registrador_b():
	$HBoxContainer3/ValorRegistradorB.text = str(Utils.int_para_hex(CPU.registrador_b, 2))
	
func atualizar_registrador_mbr():
	$HBoxContainer12/ValorRegistradorMBR.text = str(Utils.int_para_hex(CPU.registrador_mbr, 2))
	
func atualizar_registrador_pc():
	$HBoxContainer6/ValorRegistradorPC.text = str(Utils.int_para_hex(CPU.registrador_pc, 2))
