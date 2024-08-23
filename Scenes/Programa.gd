extends Control


@onready var valor_PC : LineEdit = %PCLineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	CPU.registrador_pc_foi_atualizado.connect(atualizar_valor_PC)
	pass # Replace with function body.


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
	CPU.iniciar_registrador_pc(valor_atual_PC)
	
	var numero_endereco : int = CPU.registrador_pc
	SoftwareManager.executar_programa(numero_endereco)

func atualizar_valor_PC():
	valor_PC.text = Utils.int_para_hex(CPU.registrador_pc, 4)


func _on_pc_line_edit_text_changed(new_text):
	SoftwareManager.fila_instrucoes.clear()
