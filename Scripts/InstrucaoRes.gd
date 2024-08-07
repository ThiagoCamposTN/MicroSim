extends Resource
class_name InstrucaoRes

@export var nome 		: String
@export var mnemônico 	: String
@export var descrição 	: String

@export var instruções 	: Array[String]

@export_category("Bytecodes")
@export var direto : String
@export var imediato : String
@export var indexado : String
@export var indireto : String
@export var pos_indexado : String
@export var pre_indexado : String
@export var implicito : String
