extends Node

@onready var config_teste : ConfigFile = ConfigFile.new()
var teste_em_execucao: bool = false
var lista_de_testes: Array[String] = []
var teste_atual


func _ready():
	SoftwareManager.execucao_finalizada.connect(fim_da_execucao)

func fim_da_execucao():
	if not self.teste_em_execucao:
		return

func preparar_teste(arquivo_de_teste : String):
	print("###### ", arquivo_de_teste, " ######")
	Estado.carregar_estado(arquivo_de_teste)
	self.teste_em_execucao = true
