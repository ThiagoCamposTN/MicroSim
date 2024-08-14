extends HBoxContainer

signal memoria_carregada


# Called when the node enters the scene tree for the first time.
func _ready():
	memoria_carregada.connect(SoftwareManager.alterar_caminho_memoria)
	
	# para teste
	self.carregar_memoria()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func carregar_memoria():
	var arquivo : String = $MemoriaLineEdit.text
	memoria_carregada.emit(arquivo)


func _on_button_pressed():
	self.carregar_memoria()
