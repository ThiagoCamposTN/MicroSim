extends VBoxContainer

# TODO: talvez criar apenas uma função que passa o registrador atualizado como parâmetro

# Called when the node enters the scene tree for the first time.
func _ready():
	CPU.registrador_a_foi_atualizado.connect(atualizar_registrador_a)
	CPU.registrador_b_foi_atualizado.connect(atualizar_registrador_b)
	CPU.registrador_don_foi_atualizado.connect(atualizar_registrador_don)
	CPU.registrador_co_foi_atualizado.connect(atualizar_registrador_co)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_registrador_a():
	$HBoxContainer2/ValorRegistradorA.text = str(CPU.registrador_a)

func atualizar_registrador_b():
	$HBoxContainer3/ValorRegistradorB.text = str(CPU.registrador_b)
	
func atualizar_registrador_don():
	$HBoxContainer12/ValorRegistradorDON.text = str(CPU.registrador_don)
	
func atualizar_registrador_co():
	$HBoxContainer13/ValorRegistradorCO.text = str(CPU.registrador_co)
