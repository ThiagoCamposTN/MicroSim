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
	salvar_codigo_em_memoria(codigo)
	CPU.atualizar_registrador_a(54)
	CPU.atualizar_registrador_b(67)

func salvar_codigo_em_memoria(codigo: String):
	var parte_memoria = Array()
	var linhas = codigo.split("\n", false)
	print("Antes: ", Memoria.dados.slice(0,10))

	for linha in linhas:
		var valores = linha.split(" ", false)
		
		if valores[0] == "LDA":
			parte_memoria.push_back(0x20) # LDA
			parte_memoria.push_back(int(valores[1]))
		elif valores[0] == "ABA":
			parte_memoria.push_back(0x48) # ABA
		elif (valores[0] == "CAL" and valores[1] == "EXIT") or valores[0] == "CALEXIT":
			parte_memoria.push_back(0x58)
			parte_memoria.push_back(0x12)
			parte_memoria.push_back(0x00)
	print("Parte: ", PackedByteArray(parte_memoria))
	Memoria.sobrescrever_parte_da_memoria(parte_memoria, 0)
	print("Depois: ", Memoria.dados.slice(0,10))
