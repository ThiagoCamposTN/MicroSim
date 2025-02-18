extends MenuBar

enum Abrir { PROGRAMA, MEMORIA, TESTE }
enum Executar { PROGRAMA, TESTE, TODOS_OS_TESTES }
var operacao_atual : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_arquivo_id_pressed(id):
	self.operacao_atual = id
	match id:
		Abrir.PROGRAMA:
			%DialogoDeArquivo.add_filter("*.prg")
		Abrir.MEMORIA:
			%DialogoDeArquivo.add_filter("*.MEM")
		Abrir.TESTE:
			%DialogoDeArquivo.add_filter("*.sta")
	
	%DialogoDeArquivo.current_dir = "res://"
	%DialogoDeArquivo.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	%DialogoDeArquivo.visible = true

func _on_executar_id_pressed(id):
	self.operacao_atual = id
	match self.operacao_atual:
		Executar.PROGRAMA:
			%DialogoDeExecutar.current_dir = "res://"
			%DialogoDeArquivo.add_filter("*.prg")

		Executar.TESTE:
			%DialogoDeExecutar.current_dir = "res://Testes/"
			%DialogoDeExecutar.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			%DialogoDeExecutar.add_filter("*.sta")
		Executar.TODOS_OS_TESTES:
			%DialogoDeExecutar.current_dir = "res://"
			%DialogoDeExecutar.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	%DialogoDeExecutar.visible = true

func _on_dialogo_abrir_arquivo_file_selected(path):
	%DialogoDeArquivo.visible = false
	match self.operacao_atual:
		Abrir.PROGRAMA:
			pass
		Abrir.MEMORIA:
			pass
		Abrir.TESTE:
			Teste.adicionar_teste_a_fila(path)


func _on_dialogo_de_executar_file_selected(path):
	%DialogoDeExecutar.visible = false
	match self.operacao_atual:
		Executar.TESTE:
			Teste.inicializar_teste(path)


func _on_dialogo_de_executar_dir_selected(dir):
	%DialogoDeExecutar.visible = false
	
	match self.operacao_atual:
		Executar.TODOS_OS_TESTES:
			var pasta = DirAccess.open(dir)
			Teste.adicionar_multiplos_testes_a_fila(dir, pasta.get_files())
