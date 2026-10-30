extends Slider

@export var ruta_texto: NodePath = ^"../Margen/HBoxContainer/TextoColumna/Texto"

@onready var texto: RichTextLabel = get_node(ruta_texto)

func _ready() -> void:
	value_changed.connect(_al_cambiar_tamano)
	_al_cambiar_tamano(value)

func _al_cambiar_tamano(valor: float) -> void:
	var tam := int(valor)
	texto.add_theme_font_size_override("normal_font_size", tam)
	texto.add_theme_font_size_override("bold_font_size", tam)
