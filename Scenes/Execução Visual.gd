extends TabBar

var registradores_interagindo 	: Array[Button] = []
var tweens						: Array[Tween]

@export var fluxo 				: ColorRect
var fluxo_tween					: Tween
@export var tempo_fluxo			: float = 1

var fluxo_ligado : Node2D

@onready var registradores_nos = {
	"A": %RegistradorAButton,
	"B": %RegistradorBButton,
	"PC": %RegistradorPCButton,
	"IX": %RegistradorIXButton,
	"MAR": %RegistradorMARButton,
	"PP": %RegistradorPPButton,
	"MBR": %RegistradorMBRButton,
	"Z": %RegistradorZButton,
	"N": %RegistradorNButton,
	"C": %RegistradorCButton,
	"O": %RegistradorOButton,
	"IR": %RegistradorIRButton,
	"MemoriaEndereco": %MemoriaEnderecoButton,
	"MemoriaValor": %MemoriaValorButton
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
			var valores = obter_info_memorias()

			%MemoriaEnderecoAnteriorLabel.text = valores[0]
			%MemoriaEnderecoButton.text = valores[1]
			%MemoriaEnderecoPosteriorLabel.text = valores[2]
			
			%MemoriaValorAnteriorLabel.text = valores[3]
			%MemoriaValorButton.text = valores[4]
			%MemoriaValorPosteriorLabel.text = valores[5]
			
			registradores_interagindo.append(registradores_nos["MemoriaValor"])
			registradores_interagindo.append(registradores_nos["MBR"])
		"transferir_mbr_para_ir":
			registradores_interagindo.append(registradores_nos["MBR"])
			registradores_interagindo.append(registradores_nos["IR"])
		"incrementar_registrador_pc":
			registradores_interagindo.append(registradores_nos["PC"])

	acender_registradores_interagindo()
	
	# Resolvendo linhas
	var caminho_linha = %Linhas.get_node(SoftwareManager.fila_instrucoes[0])
	var caminho_fluxo_linha = %Linhas.get_node("fluxo_" + SoftwareManager.fila_instrucoes[0])
	
	if not caminho_linha:
		return
	
	caminhar_fluxo(caminho_fluxo_linha)

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

func caminhar_fluxo(linha_fluxo: Line2D):
	if fluxo_ligado:
		fluxo_ligado.visible = false

	if not linha_fluxo:
		return
	
	linha_fluxo.visible = true
	fluxo_ligado = linha_fluxo

func obter_info_memorias():
	var valor = Utils.int_para_hex(Memoria.endereco_selecionado, 4)
	var valor_conteudo = Utils.int_para_hex(Memoria.ler_conteudo_no_endereco_selecionado(), 2)
	
	var dois_antes: int
	var um_antes: int
	var um_depois: int
	var dois_depois: int
	
	if Memoria.endereco_selecionado - 1 >= 0:
		um_antes = Memoria.endereco_selecionado - 1
	
	if Memoria.endereco_selecionado - 2 >= 0:
		dois_antes = Memoria.endereco_selecionado - 2
	
	if Memoria.endereco_selecionado + 1 <= 4095:
		um_depois = Memoria.endereco_selecionado + 1
	
	if Memoria.endereco_selecionado + 2 <= 4095:
		dois_depois = Memoria.endereco_selecionado + 2
	
	var texto_antes = Utils.int_para_hex(dois_antes, 4) + "\n" + Utils.int_para_hex(um_antes, 4)
	var texto_depois = Utils.int_para_hex(um_depois, 4) + "\n" + Utils.int_para_hex(dois_depois, 4)
	
	var texto_conteudo_antes = Memoria.ler_hex_no_endereco(dois_antes) + "\n" + Memoria.ler_hex_no_endereco(um_antes)
	var texto_conteudo_depois = Memoria.ler_hex_no_endereco(um_depois) + "\n" + Memoria.ler_hex_no_endereco(dois_depois)
	
	return [texto_antes, valor, texto_depois, texto_conteudo_antes, valor_conteudo, texto_conteudo_depois]
