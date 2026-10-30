extends Control

@export var escena_anterior: String = ""
@export var escena_siguiente: String = ""
@export var texto_anterior: String = "Anterior"
@export var texto_siguiente: String = "Siguiente"

@onready var boton_anterior: Button = get_node_or_null("%BotonAnterior")
@onready var boton_siguiente: Button = get_node_or_null("%BotonSiguiente")

func _ready() -> void:
	if boton_anterior:
		boton_anterior.text = texto_anterior
		boton_anterior.visible = escena_anterior != ""
		boton_anterior.pressed.connect(_on_anterior_pressed)
	if boton_siguiente:
		boton_siguiente.text = texto_siguiente
		boton_siguiente.visible = escena_siguiente != ""
		boton_siguiente.pressed.connect(_on_siguiente_pressed)

func _on_anterior_pressed() -> void:
	if escena_anterior != "":
		get_tree().change_scene_to_file(escena_anterior)

func _on_siguiente_pressed() -> void:
	if escena_siguiente != "":
		get_tree().change_scene_to_file(escena_siguiente)
