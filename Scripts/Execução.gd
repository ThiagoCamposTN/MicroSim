extends TabBar

#@onready var registradores 		= $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/Registradores
#@onready var inspetor 			= $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/Inspetor
#@onready var visualizador_hex 	= $MarginContainer/HSplitContainer/VBoxContainer/HexView

#@onready var executor = $MarginContainer/HSplitContainer/VBoxContainer2/Executor
@onready var descompilador = $MarginContainer/HSplitContainer/VBoxContainer2/Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	#if %MemoriaLineEdit:
		#SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)
	
	#visualizador_hex.hex_foi_selecionado.connect(inspetor.atualizar_tela)
	
	#executor.clicou_em_executar.connect(execucao_iniciada)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)

func execucao_iniciada(endereco : int):
	descompilador.descompilar_a_partir_do_endereco(endereco)


func _on_decodificar_button_pressed():
	execucao_iniciada(CPU.registrador_pc)


func _on_descompilar_button_pressed():
	execucao_iniciada(CPU.registrador_pc)
