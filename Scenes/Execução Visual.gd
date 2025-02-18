extends TabBar

var registradores_interagindo 	: Array[Button] = []
var tweens						: Array[Tween]

@export var fluxo 				: ColorRect
var fluxo_tween					: Tween
@export var tempo_fluxo			: float = 1

@onready var registradores_nos = {
	"A": get_node("Registradores/RegistradorAButton"),
	"B": get_node("Registradores/RegistradorBButton"),
	"PC": get_node("Registradores/RegistradorPCButton"),
	"IX": get_node("Registradores/RegistradorIXButton"),
	"MAR": get_node("Registradores/RegistradorMARButton"),
	"PP": get_node("Registradores/RegistradorPPButton"),
	"MBR": get_node("Registradores/RegistradorMBRButton"),
	"Z": get_node("Registradores/RegistradorZButton"),
	"N": get_node("Registradores/RegistradorNButton"),
	"C": get_node("Registradores/RegistradorCButton"),
	"O": get_node("Registradores/RegistradorOButton"),
	"IR": get_node("Registradores/RegistradorIRButton"),
	"MemoriaEndereco": get_node("Registradores/MemoriaEnderecoButton"),
	"MemoriaValor": get_node("Registradores/MemoriaValorButton")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	SoftwareManager.microoperacao_executada.connect(atualizar_linha)
	
	CPU.registrador_a_foi_atualizado.connect(atualizar_registrador.bind("A"))
	CPU.registrador_b_foi_atualizado.connect(atualizar_registrador.bind("B"))
	CPU.registrador_pc_foi_atualizado.connect(atualizar_registrador.bind("PC"))
	CPU.registrador_ix_foi_atualizado.connect(atualizar_registrador.bind("IX"))
	CPU.registrador_mar_foi_atualizado.connect(atualizar_registrador.bind("MAR"))
	CPU.registrador_pp_foi_atualizado.connect(atualizar_registrador.bind("PP"))
	CPU.registrador_mbr_foi_atualizado.connect(atualizar_registrador.bind("MBR"))
	CPU.flag_z_foi_atualizada.connect(atualizar_registrador.bind("Z"))
	CPU.flag_n_foi_atualizada.connect(atualizar_registrador.bind("N"))
	CPU.flag_c_foi_atualizada.connect(atualizar_registrador.bind("C"))
	CPU.flag_o_foi_atualizada.connect(atualizar_registrador.bind("O"))
	CPU.registrador_ir_foi_atualizado.connect(atualizar_registrador.bind("IR"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_linha():
	# Resolvendo caixas
	apagar_tweens()
	
	if SoftwareManager.fila_instrucoes.size() == 0:
		return
	if not SoftwareManager.fila_instrucoes[0]:
		return
	
	if not CPU.has_method(SoftwareManager.fila_instrucoes[0]):
		return
	
	match SoftwareManager.fila_instrucoes[0]:
		"mover_pc_para_mar":
			registradores_interagindo.append(registradores_nos["PC"])
			registradores_interagindo.append(registradores_nos["MAR"])
		"mover_mar_ao_endereco_de_memoria":
			registradores_interagindo.append(registradores_nos["MAR"])
			registradores_interagindo.append(registradores_nos["MemoriaEndereco"])
		"mover_valor_da_memoria_ao_mbr":
			registradores_interagindo.append(registradores_nos["MemoriaValor"])
			registradores_interagindo.append(registradores_nos["MBR"])
		"transferir_mbr_para_ir":
			registradores_interagindo.append(registradores_nos["MBR"])
			registradores_interagindo.append(registradores_nos["IR"])
		"incrementar_registrador_pc":
			registradores_interagindo.append(registradores_nos["PC"])
	
	acender_registradores_interagindo()
	
	# Resolvendo linhas
	var caminho_linha = "Linhas/" + SoftwareManager.fila_instrucoes[0]
	
	if not self.has_node(caminho_linha):
		return
	
	resetar_linhas()
	#var no : Line2D = self.get_node(caminho_linha)
	#no.default_color = Color.CYAN
	caminhar_fluxo(get_node(caminho_linha))

func acender_registradores_interagindo() -> void:
	for reg in registradores_interagindo:
		var tw = create_tween()
		tw.tween_property(reg, "modulate", Color.RED, 0.5).set_trans(Tween.TRANS_LINEAR)
		tw.tween_property(reg, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_LINEAR)
		tw.set_loops()
		tweens.append(tw)

func apagar_tweens():
	for tween in tweens:
		tween.kill()
	
	if tweens:
		for reg in registradores_interagindo:
			reg.modulate = Color.WHITE
		registradores_interagindo.clear()
	
	if fluxo_tween:
		fluxo_tween.kill()
		fluxo.visible = false
		

func resetar_linhas():
	for no : Line2D in self.get_node("Linhas").get_children():
		no.default_color = Color.WHITE
		no.default_color.a = 0.5

func atualizar_registrador(registrador: String):
	match registrador:
		"A":
			registradores_nos["A"].text = Utils.int_para_hex(CPU.registrador_a, 2)
		"B":
			registradores_nos["B"].text = Utils.int_para_hex(CPU.registrador_b, 2)
		"PC":
			registradores_nos["PC"].text = Utils.int_para_hex(CPU.registrador_pc, 4)
		"IX":
			registradores_nos["IX"].text = Utils.int_para_hex(CPU.registrador_ix, 4)
		"MAR":
			registradores_nos["MAR"].text = Utils.int_para_hex(CPU.registrador_mar, 4)
		"PP":
			registradores_nos["PP"].text = Utils.int_para_hex(CPU.registrador_pp, 4)
		"MBR":
			registradores_nos["MBR"].text = Utils.int_para_hex(CPU.registrador_mbr, 2)
		"Z":
			registradores_nos["Z"].text = Utils.int_para_hex(CPU.flag_z, 1)
		"N":
			registradores_nos["N"].text = Utils.int_para_hex(CPU.flag_n, 1)
		"C":
			registradores_nos["C"].text = Utils.int_para_hex(CPU.flag_c, 1)
		"O":
			registradores_nos["O"].text = Utils.int_para_hex(CPU.flag_o, 1)
		"IR":
			registradores_nos["IR"].text = Utils.int_para_hex(CPU.registrador_ir, 2)

func caminhar_fluxo(caminho: Line2D):
	fluxo.visible = true
	var distancia_total = 0
	for i in range(0, caminho.points.size()):
		if i == 0:
			continue
		else:
			distancia_total += caminho.points[i].distance_to(caminho.points[i-1])
	
	var tempo_por_distancia = tempo_fluxo/distancia_total
	
	fluxo_tween = create_tween()
	for i in range(0, caminho.points.size()):
		if i == 0:
			fluxo_tween.tween_property(fluxo, "position", caminho.points[i], 0.5).set_trans(Tween.TRANS_LINEAR).from(caminho.points[0])
		else:
			var distancia = caminho.points[i].distance_to(caminho.points[i-1])
			fluxo_tween.tween_property(fluxo, "position", caminho.points[i], distancia*tempo_por_distancia).set_trans(Tween.TRANS_LINEAR)
	fluxo_tween.tween_interval(0.3)
	fluxo_tween.set_loops()
