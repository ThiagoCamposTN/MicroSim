extends Panel

@onready var image: Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.image = Image.create(64, 32, false, Image.FORMAT_RGB8)
	
	# Define alguns pixels
	for x in range(self.image.get_width()):
		for y in range(self.image.get_height()):
			if x == y:
				image.set_pixel(x, y, Color(1, 0, 0, 1))  # Linha diagonal vermelha
			else:
				image.set_pixel(x, y, Color(0, 0, 0, 1))  # Fundo preto
	
	var texture_rect : TextureRect = $TextureRect
	
	texture_rect.texture = ImageTexture.create_from_image(image)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_rect.texture.update(image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
