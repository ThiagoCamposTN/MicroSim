extends TabBar

@onready var inspetor 			= %Inspetor
@onready var visualizador_hex 	= $HSplitContainer/VBoxContainer/HexView

# Called when the node enters the scene tree for the first time.
func _ready():
	visualizador_hex.hex_foi_selecionado.connect(inspetor.atualizar_tela)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
