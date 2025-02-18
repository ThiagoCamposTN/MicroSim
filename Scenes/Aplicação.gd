extends Control


@onready var valor_PC : LineEdit = %PCLineEdit

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
	var valor_atual_PC : int = Utils.de_hex_string_para_inteiro(valor_PC.text)
	SoftwareManager.executar_programa(valor_atual_PC)

func atualizar_valor_PC():
	var valor_hex = Utils.int_para_hex(CPU.registrador_pc, 4)
	var endereco : String = Utils.formatar_hex_como_endereco(valor_hex)
	valor_PC.text = endereco

func _on_pc_line_edit_text_changed(new_text):
	pass

func _on_pc_line_edit_focus_exited():
	SoftwareManager.fila_instrucoes.clear()
	var valor_atual_PC : int = Utils.de_hex_string_para_inteiro(valor_PC.text)
	CPU.iniciar_registrador_pc(Utils.limitar_para_endereco(valor_atual_PC))
