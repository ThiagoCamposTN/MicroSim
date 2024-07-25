extends TabBar


# Called when the node enters the scene tree for the first time.
func _ready():
	SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	SoftwareManager.alterar_caminho_memoria(%MemoriaLineEdit.text)
