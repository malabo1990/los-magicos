extends VBoxContainer

## Muestra en la imagen grande la letra cuyo botón se pulsa.
## El aspecto de las miniaturas (icono, tamaño y ausencia de texto)
## está definido en Escena6.tscn; este script solo gestiona la selección.

@onready var vista: TextureRect = $ImagenGrande
@onready var rejilla: GridContainer = $Rejilla


func _ready() -> void:
	for hijo in rejilla.get_children():
		if hijo is Button:
			hijo.pressed.connect(_mostrar.bind(_letra_de(hijo)))
	_mostrar("a")


func _letra_de(boton: Button) -> String:
	if boton.name == "Boton_Enye":
		return "ñ"
	return String(boton.name).trim_prefix("Boton_").to_lower()


func _mostrar(letra: String) -> void:
	var ruta := "res://6/sordociegos/%s.png" % letra
	if ResourceLoader.exists(ruta):
		vista.texture = load(ruta) as Texture2D
