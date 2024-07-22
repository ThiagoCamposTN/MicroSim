extends Node

# na documentação, memória teria 65536 Kib,
# mas na prática a memória possui 4096 Kib
const TAMANHO_MEMORIA : int = 0x1000 # 4096
var dados : PackedByteArray

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: no futuro, permitir alterar o tamanho de memória
	dados.resize(TAMANHO_MEMORIA)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_dado_no_endereco(endereco : int, valor : int):
	dados.set(endereco, valor)

func sobrescrever_memoria(dados : PackedByteArray):
	if dados.size() != TAMANHO_MEMORIA:
		push_error("A quantidade de dados a serem escritos na memória (", dados.size(), ") é diferente de ", TAMANHO_MEMORIA , ".")
	self.dados = dados

func sobrescrever_parte_da_memoria(novos_dados: PackedByteArray, endereco_inicial: int):
	var dados_finais = PackedByteArray()
	dados_finais.append_array(dados.slice(0, endereco_inicial)) 								# Conteúdo antes dos dados sendo sobrescritos
	dados_finais.append_array(novos_dados) 														# Dados que estão sobrescrevendo
	dados_finais.append_array(dados.slice(endereco_inicial + novos_dados.size(), dados.size())) # Conteúdo após os dados sendo sobrescritos
	self.dados = dados_finais
