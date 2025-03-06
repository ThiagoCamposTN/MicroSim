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

	SoftwareManager.mudanca_de_fase.connect(fase_foi_alterada)

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
	
	remover_fluxos()
	match SoftwareManager.fila_instrucoes[0]:
		"mover_pc_para_mar":
			registradores_interagindo.append(registradores_nos["PC"])
			registradores_interagindo.append(registradores_nos["MAR"])
		"mover_mar_ao_endereco_de_memoria":
			registradores_interagindo.append(registradores_nos["MAR"])
			registradores_interagindo.append(registradores_nos["MemoriaEndereco"])
		"mover_valor_da_memoria_ao_mbr":
			var valores = obter_info_memorias()
			remover_fluxos()
			# Resolvendo animação de leitura da memória
			var caminho_fluxo_linha = %Linhas.get_node("fluxo_end_selec")
			caminho_fluxo_linha.visible = true
			await get_tree().create_timer(1).timeout
			caminho_fluxo_linha.visible = false
			
			%MemoriaEnderecoAnteriorLabel.text = valores[0]
			%MemoriaEnderecoButton.text = valores[1]
			%MemoriaEnderecoPosteriorLabel.text = valores[2]
			
			caminho_fluxo_linha = %Linhas.get_node("fluxo_leimem")
			caminho_fluxo_linha.visible = true
			await get_tree().create_timer(1).timeout
			caminho_fluxo_linha.visible = false
			
			%MemoriaValorAnteriorLabel.text = valores[3]
			%MemoriaValorButton.text = valores[4]
			%MemoriaValorPosteriorLabel.text = valores[5]
			
			await get_tree().create_timer(1).timeout
			
			registradores_interagindo.append(registradores_nos["MemoriaValor"])
			registradores_interagindo.append(registradores_nos["MBR"])
		"transferir_mbr_para_ir":
			registradores_interagindo.append(registradores_nos["MBR"])
			registradores_interagindo.append(registradores_nos["IR"])
		"incrementar_registrador_pc":
			registradores_interagindo.append(registradores_nos["PC"])

	acender_registradores_interagindo()
	
	# Resolvendo linhas
	if SoftwareManager.fila_instrucoes.size() > 0:
		var caminho_linha = %Linhas.get_node(SoftwareManager.fila_instrucoes[0])
		var caminho_fluxo_linha = %Linhas.get_node("fluxo_" + SoftwareManager.fila_instrucoes[0])
		
		if not caminho_linha:
			return
	
		caminhar_fluxo(caminho_fluxo_linha)

func acender_registradores_interagindo() -> void:
	for reg in registradores_interagindo:
		var tw = create_tween()
		tw.tween_property(reg, "modulate", Color.DARK_RED, 0.5).set_trans(Tween.TRANS_LINEAR)
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
			registradores_nos["A"].text = CPU.registrador_a.como_hex(2)
		"B":
			registradores_nos["B"].text = CPU.registrador_b.como_hex(2)
		"PC":
			registradores_nos["PC"].text = CPU.registrador_pc.como_hex(4)
		"IX":
			registradores_nos["IX"].text = CPU.registrador_ix.como_hex(4)
		"MAR":
			registradores_nos["MAR"].text = CPU.registrador_mar.como_hex(4)
		"PP":
			registradores_nos["PP"].text = CPU.registrador_pp.como_hex(4)
		"MBR":
			registradores_nos["MBR"].text = CPU.registrador_mbr.como_hex(2)
		"Z":
			registradores_nos["Z"].text = CPU.flag_z.como_hex(1)
		"N":
			registradores_nos["N"].text = CPU.flag_n.como_hex(1)
		"C":
			registradores_nos["C"].text = CPU.flag_c.como_hex(1)
		"O":
			registradores_nos["O"].text = CPU.flag_o.como_hex(1)
		"IR":
			registradores_nos["IR"].text = CPU.registrador_ir.como_hex(2)

func caminhar_fluxo(linha_fluxo: Line2D):
	if not linha_fluxo:
		return
	
	linha_fluxo.visible = true
	fluxo_ligado = linha_fluxo

func remover_fluxos():
	if fluxo_ligado:
		fluxo_ligado.visible = false

func obter_info_memorias():
	var valor = Memoria.endereco_selecionado.como_hex(4)
	var valor_conteudo = Memoria.ler_conteudo_no_endereco_selecionado().como_hex(2)
	
	var dois_antes: Valor = Valor.new(0)
	var um_antes: Valor = Valor.new(0)
	var um_depois: Valor = Valor.new(0)
	var dois_depois: Valor = Valor.new(0)
	
	if Memoria.endereco_selecionado.como_int() - 1 >= 0:
		um_antes = Valor.novo_de_int(Memoria.endereco_selecionado.como_int() - 1)
	
	if Memoria.endereco_selecionado.como_int() - 2 >= 0:
		dois_antes = Valor.novo_de_int(Memoria.endereco_selecionado.como_int() - 2)
	
	if Memoria.endereco_selecionado.como_int() + 1 <= Memoria.TAMANHO_MEMORIA - 1:
		um_depois = Valor.novo_de_int(Memoria.endereco_selecionado.como_int() + 1)
	
	if Memoria.endereco_selecionado.como_int() + 2 <= Memoria.TAMANHO_MEMORIA - 1:
		dois_depois = Valor.novo_de_int(Memoria.endereco_selecionado.como_int() + 2)
	
	var texto_antes = dois_antes.como_hex(4) + "\n" + um_antes.como_hex(4)
	var texto_depois = um_depois.como_hex(4) + "\n" + dois_depois.como_hex(4)
	
	var texto_conteudo_antes = Memoria.ler_conteudo_no_endereco(dois_antes).como_hex() + "\n" + Memoria.ler_conteudo_no_endereco(um_antes).como_hex()
	var texto_conteudo_depois = Memoria.ler_conteudo_no_endereco(um_depois).como_hex() + "\n" + Memoria.ler_conteudo_no_endereco(dois_depois).como_hex()
	
	return [texto_antes, valor, texto_depois, texto_conteudo_antes, valor_conteudo, texto_conteudo_depois]

func fase_foi_alterada(fase : SoftwareManager.Fase):
	match fase:
		SoftwareManager.Fase.BUSCA:
			print("Fase atual: busca")
		SoftwareManager.Fase.DECODIFICACAO:
			print("Fase atual: decodificacao")
		SoftwareManager.Fase.EXECUCAO:
			print("Fase atual: execucao")	
