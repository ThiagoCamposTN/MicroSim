extends VBoxContainer


signal clicou_em_executar(endereco_inicial : String, codigo : String)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.clicou_em_executar.connect(SoftwareManager.executar_codigo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var endereco_inicial 	: String = $HBoxContainer/LineEdit.text
	var codigo 				: String = $CodeEdit.text
	clicou_em_executar.emit(endereco_inicial, codigo)
