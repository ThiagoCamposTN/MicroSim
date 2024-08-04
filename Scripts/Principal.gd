extends TabBar

@onready var executor = $MarginContainer/HSplitContainer/VBoxContainer2/Executor
@onready var descompilador = $MarginContainer/HSplitContainer/VBoxContainer2/Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	if %MemoriaLineEdit:
		SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)
	
	executor.clicou_em_executar.connect(execucao_iniciada)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)

func execucao_iniciada(endereco : int):
	descompilador.descompilar_a_partir_do_endereco(endereco)
