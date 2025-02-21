extends Node

# na documentação, memória teria 65536 Kib,
# mas na prática a memória possui 4096 Kib
const TAMANHO_MEMORIA 		: int = 0x1000 # 4096
var celulas 				: PackedByteArray
var endereco_selecionado 	: int

signal memoria_foi_recarregada
signal endereço_de_memoria_foi_atualizado
signal grupo_da_memoria_foi_atualizado


# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: no futuro, permitir alterar o tamanho de memória
	celulas.resize(TAMANHO_MEMORIA)

	Estado.sobrecarregar_memoria.connect(sobrescrever_toda_a_memoria)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_valor_no_endereco_selecionado(valor : int):
	celulas.set(self.endereco_selecionado, valor)

	# TODO: talvez o emit não leve parâmetro e a memória 
	# acesse o `self.endereco_selecionado` por padrão
	self.endereço_de_memoria_foi_atualizado.emit(self.endereco_selecionado)

func sobrescrever_toda_a_memoria(novas_celulas : PackedByteArray):
	if novas_celulas.size() != TAMANHO_MEMORIA:
		push_error("A quantidade de dados a serem escritos na memória (", str(novas_celulas.size()), ") é diferente de ", TAMANHO_MEMORIA , ".")
	self.celulas = novas_celulas
	self.memoria_foi_recarregada.emit()

func sobrescrever_parte_da_memoria(novos_dados: PackedByteArray, endereco_inicial: int):
	var dados_finais = PackedByteArray()
	dados_finais.append_array(celulas.slice(0, endereco_inicial)) # Conteúdo antes dos dados sendo sobrescritos
	dados_finais.append_array(novos_dados) # Dados que estão sobrescrevendo
	dados_finais.append_array(celulas.slice(endereco_inicial + novos_dados.size(), celulas.size())) # Conteúdo após os dados sendo sobrescritos
	self.celulas = dados_finais
	self.grupo_da_memoria_foi_atualizado.emit(endereco_inicial, novos_dados.size())

func sobrescrever_uma_celula(novo_dado: int, endereco: int):
	self.celulas.set(endereco, novo_dado)
	self.grupo_da_memoria_foi_atualizado.emit(endereco, 1)

func ler_conteudo_no_endereco_selecionado():
	return self.celulas[self.endereco_selecionado]

func ler_hex_no_endereco(endereco : int):
	return Utils.int_para_hex(self.celulas[endereco], 2)

func carregar_arquivo_de_memoria(caminho: String):
	var arquivo : FileAccess 		= FileAccess.open(caminho, FileAccess.READ)
	var valores : PackedByteArray	= arquivo.get_buffer(arquivo.get_length())
	arquivo.close()
	self.sobrescrever_toda_a_memoria(valores)
