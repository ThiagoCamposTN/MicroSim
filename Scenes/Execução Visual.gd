extends TabBar

var registradores_interagindo : Array[Button] = []
var tweens			: Array[Tween]
@export var fluxo 	: ColorRect
var fluxo_tween		: Tween

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
	if SoftwareManager.fila_instrucoes.size() == 0:
		return
	if not SoftwareManager.ultima_operacao:
		return
	
	# Resolvendo caixas
	apagar_tweens()
	
	if not CPU.has_method(SoftwareManager.ultima_operacao):
		return
	
	match SoftwareManager.ultima_operacao:
		"mover_pc_para_mar":
			registradores_interagindo.append(self.get_node("Registradores/RegistradorPCButton"))
			registradores_interagindo.append(self.get_node("Registradores/RegistradorMARButton"))
		"mover_mar_ao_endereco_de_memoria":
			registradores_interagindo.append(self.get_node("Registradores/RegistradorMARButton"))
		"mover_valor_da_memoria_ao_mbr":
			registradores_interagindo.append(self.get_node("Registradores/RegistradorMBRButton"))
		"transferir_mbr_para_ir":
			registradores_interagindo.append(self.get_node("Registradores/RegistradorMBRButton"))
			registradores_interagindo.append(self.get_node("Registradores/RegistradorIRButton"))
		"incrementar_registrador_pc":
			registradores_interagindo.append(self.get_node("Registradores/RegistradorPCButton"))
	
	acender_registradores_interagindo()
	
	# Resolvendo linhas
	var caminho_linha = "Linhas/" + SoftwareManager.ultima_operacao
	
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

func resetar_linhas():
	for no : Line2D in self.get_node("Linhas").get_children():
		no.default_color = Color.WHITE
		no.default_color.a = 0.5

func atualizar_registrador(registrador: String):
	match registrador:
		"A":
			get_node("Registradores/RegistradorAButton").text = CPU.registrador_a.como_hex(2)
		"B":
			get_node("Registradores/RegistradorBButton").text = CPU.registrador_b.como_hex(2)
		"PC":
			get_node("Registradores/RegistradorPCButton").text = CPU.registrador_pc.como_hex(4)
		"IX":
			get_node("Registradores/RegistradorIXButton").text = CPU.registrador_ix.como_hex(4)
		"MAR":
			get_node("Registradores/RegistradorMARButton").text = CPU.registrador_mar.como_hex(4)
		"PP":
			get_node("Registradores/RegistradorPPButton").text = CPU.registrador_pp.como_hex(4)
		"MBR":
			get_node("Registradores/RegistradorMBRButton").text = CPU.registrador_mbr.como_hex(2)
		"Z":
			get_node("Registradores/RegistradorZButton").text = CPU.flag_z.como_hex(1)
		"N":
			get_node("Registradores/RegistradorNButton").text = CPU.flag_n.como_hex(1)
		"C":
			get_node("Registradores/RegistradorCButton").text = CPU.flag_c.como_hex(1)
		"O":
			get_node("Registradores/RegistradorOButton").text = CPU.flag_o.como_hex(1)
		"IR":
			get_node("Registradores/RegistradorIRButton").text = CPU.registrador_ir.como_hex(2)

func caminhar_fluxo(caminho: Line2D):
	var tempo_caminho = 1 # segundos
	if fluxo_tween:
		fluxo_tween.kill()
	
	var distancia_total = 0
	for i in range(0, caminho.points.size()):
		if i == 0:
			continue
		else:
			distancia_total += caminho.points[i].distance_to(caminho.points[i-1])
	
	var tempo_por_distancia = tempo_caminho/distancia_total
	
	fluxo_tween = create_tween()
	for i in range(0, caminho.points.size()):
		if i == 0:
			fluxo_tween.tween_property(fluxo, "position", caminho.points[i], 0.5).set_trans(Tween.TRANS_LINEAR).from(caminho.points[0])
		else:
			var distancia = caminho.points[i].distance_to(caminho.points[i-1])
			fluxo_tween.tween_property(fluxo, "position", caminho.points[i], distancia*tempo_por_distancia).set_trans(Tween.TRANS_LINEAR)
	fluxo_tween.set_loops()
