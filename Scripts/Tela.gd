extends TabBar

@onready var image	: Image
@export var largura	: int = 64
@export var altura	: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.image = Image.create(self.largura, self.altura, false, Image.FORMAT_RGB8)

	var texture_rect : TextureRect = $Panel/TextureRect
	texture_rect.texture = ImageTexture.create_from_image(image)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	Memoria.memoria_foi_recarregada.connect(self.atualizar_tela)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func atualizar_tela():
	var comeco: int = Memoria.celulas.size() - floori(largura * altura / 8.0)
	var valores = Memoria.celulas.slice(comeco, Memoria.celulas.size())

	var indice: int = 0  # Índice para rastrear a posição na array de bits

	for valor: int in valores:
		for i: int in range(8): # itera sobre os 8 bits do valor
			# TODO: provavelmente os bits estão invertidos, talvez precise desinvertê-los
			var bit = (valor >> i) & 1  # Extrai um bit for vez

			# Converte o índice linear em coordenadas (x, y)
			var x: int = indice % 64
			var y: int = floori(indice / 64.0)

			image.set_pixel(x, y, Color(255 & bit, 255 & bit, 255 & bit, 1))
			indice += 1
	
	$Panel/TextureRect.texture.update(self.image)
