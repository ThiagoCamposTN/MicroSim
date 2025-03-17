extends MenuBar

enum Abrir 			{ PROGRAMA, MEMORIA, ESTADO }
enum Executar 		{ TESTE, TODOS_OS_TESTES }
enum Configuracoes 	{ DESATIVAR_VISUAL }

var operacao_atual : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_arquivo_id_pressed(id):
	self.operacao_atual = id
	%DialogoDeArquivo.clear_filters()

	match id:
		Abrir.PROGRAMA:
			%DialogoDeArquivo.add_filter("*.prg")
		Abrir.MEMORIA:
			%DialogoDeArquivo.add_filter("*.MEM")
		Abrir.ESTADO:
			%DialogoDeArquivo.add_filter("*.sta")
	
	%DialogoDeArquivo.current_dir = "res://"
	%DialogoDeArquivo.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	%DialogoDeArquivo.visible = true

func _on_executar_id_pressed(id):
	self.operacao_atual = id
	%DialogoDeExecutar.clear_filters()

	match self.operacao_atual:
		Executar.TESTE:
			%DialogoDeExecutar.current_dir = "res://Testes/"
			%DialogoDeExecutar.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			%DialogoDeExecutar.add_filter("*.sta")
		Executar.TODOS_OS_TESTES:
			%DialogoDeExecutar.current_dir = "res://"
			%DialogoDeExecutar.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	%DialogoDeExecutar.visible = true

func _on_dialogo_abrir_arquivo_file_selected(caminho):
	%DialogoDeArquivo.visible = false
	match self.operacao_atual:
		Abrir.PROGRAMA:
			Programa.carregar_programa(caminho)
		Abrir.MEMORIA:
			Memoria.carregar_arquivo_de_memoria(caminho)
		Abrir.ESTADO:
			Estado.carregar_estado(caminho)


func _on_dialogo_de_executar_file_selected(path):
	%DialogoDeExecutar.visible = false
	match self.operacao_atual:
		Executar.TESTE:
			Teste.realizar_um_teste(path)


func _on_dialogo_de_executar_dir_selected(dir):
	%DialogoDeExecutar.visible = false
	
	match self.operacao_atual:
		Executar.TODOS_OS_TESTES:
			var pasta = DirAccess.open(dir)
			Teste.realizar_multiplos_testes(dir, pasta.get_files())


func _on_configurações_id_pressed(id):
	match id:
		Configuracoes.DESATIVAR_VISUAL:
			$Configurações.toggle_item_checked(id)
			Simulador.atualizacao_visual_ativa = not $Configurações.is_item_checked(id)
