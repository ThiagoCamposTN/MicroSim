extends Node

# na documentação, memória teria 65536 Kib,
# mas na prática a memória possui 4096 Kib
const TAMANHO_MEMORIA : int = 0x1000 # 4096
var celulas : PackedByteArray

signal memoria_foi_atualizada
signal grupo_da_memoria_foi_atualizado

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: no futuro, permitir alterar o tamanho de memória
	celulas.resize(TAMANHO_MEMORIA)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func atualizar_dado_no_endereco(endereco : int, valor : int):
	celulas.set(endereco, valor)
	print("endereco: ", endereco, " | valor: ", valor)
	memoria_foi_atualizada.emit(endereco)

func sobrescrever_memoria(celulas : PackedByteArray):
	if celulas.size() != TAMANHO_MEMORIA:
		push_error("A quantidade de dados a serem escritos na memória (", str(celulas.size()), ") é diferente de ", TAMANHO_MEMORIA , ".")
	
	self.celulas = celulas

func sobrescrever_parte_da_memoria(novos_dados: PackedByteArray, endereco_inicial: int):
	var dados_finais = PackedByteArray()
	dados_finais.append_array(celulas.slice(0, endereco_inicial)) # Conteúdo antes dos dados sendo sobrescritos
	dados_finais.append_array(novos_dados) # Dados que estão sobrescrevendo
	dados_finais.append_array(celulas.slice(endereco_inicial + novos_dados.size(), celulas.size())) # Conteúdo após os dados sendo sobrescritos
	self.celulas = dados_finais
	grupo_da_memoria_foi_atualizado.emit(endereco_inicial, novos_dados.size())

func ler_conteudo_no_endereco(endereco : int):
	return self.celulas[endereco]
