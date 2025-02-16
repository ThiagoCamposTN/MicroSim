extends MenuBar


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_arquivo_id_pressed(id):
	match id:
		0:
			# abrir programa
			pass
		1:
			# abrir teste
			Programa.abrir_programa("res://Programas/programa1.tst.prg")
		2:
			# abrir memória
			pass
