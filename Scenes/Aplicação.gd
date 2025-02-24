extends Control


@onready var valor_PC: LineEdit = %PCLineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	CPU.registrador_pc_foi_atualizado.connect(atualizar_valor_PC)
	# SoftwareManager.recarregar_memoria()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_avancar_microcodigo_button_pressed():
	SoftwareManager.unico_microcodigo = true
	executar()


func _on_avancar_instrucao_button_pressed():
	SoftwareManager.unica_instrucao = true
	executar()


func _on_executar_tudo_button_pressed():
	executar()

func executar() -> void:
	var valor_atual_PC: Valor = Valor.novo_de_hex(valor_PC.text)
	SoftwareManager.executar_programa(valor_atual_PC.como_int())

func atualizar_valor_PC():
	var valor: Valor = Valor.new(CPU.registrador_pc)
	var endereco: String = valor.como_hex(4)
	valor_PC.text = endereco

func _on_pc_line_edit_text_changed(new_text):
	pass

func _on_pc_line_edit_focus_exited():
	SoftwareManager.fila_instrucoes.clear()
	var valor_atual_PC: Valor = Valor.novo_de_hex(valor_PC.text)
	valor_atual_PC.limitar_entre(0, Memoria.TAMANHO_MEMORIA - 1)
	CPU.iniciar_registrador_pc(valor_atual_PC.como_int())
