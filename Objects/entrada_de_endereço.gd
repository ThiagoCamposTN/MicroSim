extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_focus_exited():
	self.reformatar_endereco()

func obter_endereco():
	self.reformatar_endereco()
	var numero_endereco : int = Utils.de_hex_string_para_inteiro(self.text)
	return numero_endereco

func reformatar_endereco():
	var endereço : String = Utils.formatar_hex_como_endereco(self.text)
	self.text = endereço
