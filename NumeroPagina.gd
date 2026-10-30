extends PanelContainer

@export var numero: int = 1:
	set(value):
		numero = value
		if is_inside_tree():
			_actualizar()

@onready var etiqueta: Label = %NumeroLabel

func _ready() -> void:
	_actualizar()

func _actualizar() -> void:
	etiqueta.text = "%02d" % numero
