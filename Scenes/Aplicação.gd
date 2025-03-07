extends Control


@onready var valor_PC: LineEdit = %PCLineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	CPU.registrador_pc_foi_atualizado.connect(atualizar_valor_PC)
	# SoftwareManager.recarregar_memoria()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_avancar_microcodigo_button_pressed():
	executar(SoftwareManager.ModoExecucao.UNICO_MICROCODIGO)


func _on_avancar_instrucao_button_pressed():
	executar(SoftwareManager.ModoExecucao.UNICA_INSTRUCAO)


func _on_executar_tudo_button_pressed():
	executar(SoftwareManager.ModoExecucao.TUDO)

func executar(modo : SoftwareManager.ModoExecucao) -> void:
	var valor_atual_PC: Valor = Valor.novo_de_hex(valor_PC.text)
	SoftwareManager.executar_programa(valor_atual_PC, modo)

func atualizar_valor_PC():
	valor_PC.text = CPU.registrador_pc.como_hex(4)

func _on_pc_line_edit_text_changed(_new_text):
	pass

func _on_pc_line_edit_focus_exited():
	SoftwareManager.limpar_fila_de_instrucoes()
	var valor_atual_PC: Valor = Valor.novo_de_hex(valor_PC.text)
	valor_atual_PC.limitar_entre(0, Memoria.TAMANHO_MEMORIA - 1)
	CPU.iniciar_registrador_pc(valor_atual_PC)
