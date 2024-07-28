extends HBoxContainer

#signal clicou_em_executar(endereco_inicial : String)


# Called when the node enters the scene tree for the first time.
func _ready():
	#self.clicou_em_executar.connect(SoftwareManager.executar_programa)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var numero_endereco : int = $LineEdit.obter_endereco()
	SoftwareManager.executar_programa(numero_endereco)
	#clicou_em_executar.emit(endereco_inicial)
