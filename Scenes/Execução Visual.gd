extends TabBar

var registradores_interagindo : Array[Button] = []
var tweens: Array[Tween]
var bolinha

# Called when the node enters the scene tree for the first time.
func _ready():
	SoftwareManager.microoperacao_executada.connect(atualizar_linha)
	pass # Replace with function body.


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
	var no : Line2D = self.get_node(caminho_linha)
	no.default_color = Color.CYAN

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
