extends Resource
class_name Operador

@export var nome 		    : String
@export var mnemônico 	    : String
@export var descrição 	    : String
@export var tamanho_do_dado : int = 2

@export var microoperacoes 	: Array

@export_category("Bytecodes")
@export var direto : String
@export var imediato : String
@export var indexado : String
@export var indireto : String
@export var pos_indexado : String
@export var pre_indexado : String
@export var implicito : String
