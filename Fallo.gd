extends Control

## Popup amigable para respuestas incorrectas / reintentar.
## Diseñado para niños: sin castigo, con mensaje motivador y botón de reintentar.

signal reintentado

@onready var popup: Control = %Popup
@onready var fondo: Button = %Fondo
@onready var tarjeta: PanelContainer = %Tarjeta
@onready var titulo_label: Label = %Titulo
@onready var mensaje_label: Label = %Mensaje
@onready var boton_reintentar: Button = %BotonReintentar
@onready var boton_anterior: Button = %BotonAnteriorFallo
@onready var boton_siguiente: Button = %BotonSiguienteFallo

var tween_tarjeta: Tween


func _ready() -> void:
	show()
	popup.visible = false
	fondo.pressed.connect(_cerrar_fallo)
	boton_reintentar.pressed.connect(_cerrar_fallo)
	if boton_anterior:
		boton_anterior.pressed.connect(_ir_anterior)
	if boton_siguiente:
		boton_siguiente.pressed.connect(_ir_siguiente)


func mostrar_fallo(mensaje: String = "", titulo: String = "¡Casi!") -> void:
	if titulo != "":
		titulo_label.text = titulo
	if mensaje != "":
		mensaje_label.text = mensaje
	else:
		mensaje_label.text = "¡No pasa nada! Piensa un poquito más y vuelve a probar. 😊"
	
	popup.visible = true
	var padre := get_parent()
	if padre:
		if "escena_anterior" in padre and padre.escena_anterior == "":
			boton_anterior.visible = false
		else:
			boton_anterior.visible = true
		if "escena_siguiente" in padre and padre.escena_siguiente == "":
			boton_siguiente.visible = false
		else:
			boton_siguiente.visible = true
	
	tarjeta.pivot_offset = tarjeta.size / 2.0
	tarjeta.scale = Vector2(0.5, 0.5)
	tarjeta.rotation_degrees = 0.0
	
	if tween_tarjeta:
		tween_tarjeta.kill()
	
	tween_tarjeta = create_tween()
	# Efecto de aparición elástica suave
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Suave "no" o balanceo amigable
	tween_tarjeta.chain().tween_property(tarjeta, "rotation_degrees", -4.0, 0.07)
	tween_tarjeta.tween_property(tarjeta, "rotation_degrees", 4.0, 0.07)
	tween_tarjeta.tween_property(tarjeta, "rotation_degrees", -2.0, 0.06)
	tween_tarjeta.tween_property(tarjeta, "rotation_degrees", 2.0, 0.06)
	tween_tarjeta.tween_property(tarjeta, "rotation_degrees", 0.0, 0.05)


func abrir_fallo(mensaje: String = "", titulo: String = "¡Casi!") -> void:
	mostrar_fallo(mensaje, titulo)


func abrir() -> void:
	mostrar_fallo()


func _cerrar_fallo() -> void:
	if tween_tarjeta:
		tween_tarjeta.kill()
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2(0.7, 0.7), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_tarjeta.finished.connect(func():
		popup.visible = false
		reintentado.emit()
	)


func _ir_anterior() -> void:
	var padre := get_parent()
	if padre and padre.has_method("_on_anterior_pressed"):
		padre._on_anterior_pressed()


func _ir_siguiente() -> void:
	var padre := get_parent()
	if padre and padre.has_method("_on_siguiente_pressed"):
		padre._on_siguiente_pressed()
