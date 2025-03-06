extends Panel

@onready var imagem	: Image
@export var largura	: int = 64
@export var altura	: int = 32
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect

var buffer_de_tela: PackedByteArray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.imagem = Image.create(self.largura, self.altura, false, Image.FORMAT_RGB8)

	texture_rect.texture 			= ImageTexture.create_from_image(imagem)
	texture_rect.stretch_mode 		= TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter 	= CanvasItem.TEXTURE_FILTER_NEAREST

	#Memoria.memoria_foi_recarregada.connect(self.atualizar_tela)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func atualizar_buffer_de_tela():
	var comeco: int = Memoria.celulas.size() - floori(largura * altura / 8.0)
	self.buffer_de_tela = Memoria.celulas.slice(comeco, Memoria.celulas.size())

func atualizar_tela():
	var indice: int = 0  # Índice para rastrear a posição na array de bits

	for valor: int in self.buffer_de_tela:
		for i: int in range(8): # itera sobre os 8 bits do valor
			# Extrai os bits do valor, lendo de trás para frente
			var bit = (valor >> (7 - i)) & 1  # Extrai um bit for vez

			# Converte o índice linear em coordenadas (x, y)
			var x: int = indice % 64
			var y: int = floori(indice / 64.0)

			imagem.set_pixel(x, y, Color(255 & bit, 255 & bit, 255 & bit, 1))
			indice += 1
	
	texture_rect.texture.update(self.imagem)


func _on_button_pressed():
	self.atualizar_buffer_de_tela()
	self.atualizar_tela()
