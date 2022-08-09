extends HBoxContainer

onready var identificador : Label = $Endereco/Identificador

onready var h0 : Label = $Hexadecimal/H0
onready var h1 : Label = $Hexadecimal/H1
onready var h2 : Label = $Hexadecimal/H2
onready var h3 : Label = $Hexadecimal/H3
onready var h4 : Label = $Hexadecimal/H4
onready var h5 : Label = $Hexadecimal/H5
onready var h6 : Label = $Hexadecimal/H6
onready var h7 : Label = $Hexadecimal/H7
onready var h8 : Label = $Hexadecimal/H8
onready var h9 : Label = $Hexadecimal/H9
onready var hA : Label = $Hexadecimal/HA
onready var hB : Label = $Hexadecimal/HB
onready var hC : Label = $Hexadecimal/HC
onready var hD : Label = $Hexadecimal/HD
onready var hE : Label = $Hexadecimal/HE
onready var hF : Label = $Hexadecimal/HF

var line_number = 0
var hex_values = []

# Called when the node enters the scene tree for the first time.
func _ready():
	identificador.text = "number"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.identificador.text = "%03X" % self.line_number
	
	self.h0.text = "%02X" % hex_values[0]
	self.h1.text = "%02X" % hex_values[1]
	self.h2.text = "%02X" % hex_values[2]
	self.h3.text = "%02X" % hex_values[3]
	self.h4.text = "%02X" % hex_values[4]
	self.h5.text = "%02X" % hex_values[5]
	self.h6.text = "%02X" % hex_values[6]
	self.h7.text = "%02X" % hex_values[7]
	self.h8.text = "%02X" % hex_values[8]
	self.h9.text = "%02X" % hex_values[9]
	self.hA.text = "%02X" % hex_values[10]
	self.hB.text = "%02X" % hex_values[11]
	self.hC.text = "%02X" % hex_values[12]
	self.hD.text = "%02X" % hex_values[13]
	self.hE.text = "%02X" % hex_values[14]
	self.hF.text = "%02X" % hex_values[15]


func set_line_number(number):
	self.line_number = number

func set_values(number_list):
	self.hex_values = number_list
