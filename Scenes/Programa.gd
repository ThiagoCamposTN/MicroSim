extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_avancar_microcodigo_button_pressed():
	var numero_endereco : int = CPU.registrador_pc
	SoftwareManager.unica_instrucao = true
	SoftwareManager.executar_programa(numero_endereco)
	#clicou_em_executar.emit(numero_endereco)


func _on_avancar_instrucao_button_pressed():
	pass # Replace with function body.
