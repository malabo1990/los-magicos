extends Control

## Componente de Pregunta / Cuestión interactiva modal.
## Si acierta: cierra la pregunta y otorga el Premio existente (Premio.tscn).
## Si falla: abre el popup de Fallo (Fallo.tscn) con mensaje motivador y reintento.

signal acertado(indice: int)
signal fallado(indice: int)

@export_multiline var pregunta: String = "¿Dónde está la Universidad de Gallaudet?"
@export var opciones: Array[String] = [
	"A) España",
	"B) Polo Norte",
	"C) Estados Unidos (EEUU)"
]
@export var indice_correcto: int = 2
@export var indice_reto: int = 0
@export var escala_opciones: float = 1.0
@export var pista_fallo: String = "¡No pasa nada! Piensa un poquito y vuelve a probar. 😊"
@export var titulo_fallo: String = "¡Casi!"

@onready var popup: Control = %Popup
@onready var fondo: Button = %Fondo
@onready var tarjeta: PanelContainer = %Tarjeta
@onready var label_pregunta: Label = %LabelPregunta
@onready var contenedor_opciones: VBoxContainer = %ContenedorOpciones
@onready var boton_cerrar: Button = %BotonCerrar

var botones_opciones: Array[Button] = []
var ya_acertado := false
var tween_tarjeta: Tween


func _ready() -> void:
	show()
	popup.visible = false
	fondo.pressed.connect(cerrar)
	if boton_cerrar:
		boton_cerrar.pressed.connect(cerrar)
	configurar(pregunta, opciones, indice_correcto, pista_fallo)


func configurar(nueva_pregunta: String, nuevas_opciones: Array[String], nuevo_indice: int, nueva_pista: String = "") -> void:
	pregunta = nueva_pregunta
	opciones = nuevas_opciones
	indice_correcto = nuevo_indice
	if nueva_pista != "":
		pista_fallo = nueva_pista
	ya_acertado = false
	
	if label_pregunta:
		label_pregunta.text = pregunta
	
	_construir_botones()


func abrir() -> void:
	abrir_cuestion()


func abrir_cuestion() -> void:
	if ya_acertado:
		_abrir_premio_existente()
		return
	
	popup.visible = true
	tarjeta.pivot_offset = tarjeta.size / 2.0
	tarjeta.scale = Vector2(0.6, 0.6)
	
	if tween_tarjeta:
		tween_tarjeta.kill()
	
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func cerrar() -> void:
	if tween_tarjeta:
		tween_tarjeta.kill()
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2(0.7, 0.7), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_tarjeta.finished.connect(func():
		popup.visible = false
	)


func _construir_botones() -> void:
	if not contenedor_opciones:
		return
	
	for hijo in contenedor_opciones.get_children():
		hijo.queue_free()
	botones_opciones.clear()
	
	var font_fredoka = load("res://fonts/Fredoka.ttf")
	var escala: float = maxf(0.1, escala_opciones)
	var radio := int(round(16.0 * escala))
	
	for i in range(opciones.size()):
		var btn := Button.new()
		btn.text = opciones[i]
		btn.custom_minimum_size = Vector2(0, 52.0 * escala)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		
		if font_fredoka:
			btn.add_theme_font_override("font", font_fredoka)
		btn.add_theme_font_size_override("font_size", int(round(20.0 * escala)))
		btn.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.9, 0.45, 0.1, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.8, 0.35, 0.05, 1))
		
		var estilo_normal := StyleBoxFlat.new()
		estilo_normal.bg_color = Color(1, 1, 1, 0.95)
		estilo_normal.border_width_left = 3
		estilo_normal.border_width_top = 3
		estilo_normal.border_width_right = 3
		estilo_normal.border_width_bottom = 3
		estilo_normal.border_color = Color(0.92, 0.78, 0.65, 1)
		estilo_normal.corner_radius_top_left = radio
		estilo_normal.corner_radius_top_right = radio
		estilo_normal.corner_radius_bottom_right = radio
		estilo_normal.corner_radius_bottom_left = radio
		estilo_normal.content_margin_left = 20.0 * escala
		estilo_normal.content_margin_right = 20.0 * escala
		estilo_normal.content_margin_top = 10.0 * escala
		estilo_normal.content_margin_bottom = 10.0 * escala
		btn.add_theme_stylebox_override("normal", estilo_normal)
		
		var estilo_hover := estilo_normal.duplicate() as StyleBoxFlat
		estilo_hover.bg_color = Color(1, 0.97, 0.93, 1)
		estilo_hover.border_color = Color(0.96, 0.58, 0.25, 1)
		btn.add_theme_stylebox_override("hover", estilo_hover)
		
		var estilo_pressed := estilo_normal.duplicate() as StyleBoxFlat
		estilo_pressed.bg_color = Color(0.95, 0.9, 0.85, 1)
		btn.add_theme_stylebox_override("pressed", estilo_pressed)
		
		btn.pressed.connect(_on_opcion_pulsada.bind(i, btn))
		contenedor_opciones.add_child(btn)
		botones_opciones.append(btn)


func _on_opcion_pulsada(indice: int, boton: Button) -> void:
	if ya_acertado:
		_abrir_premio_existente()
		return
	
	if indice == indice_correcto:
		_procesar_acierto(boton, indice)
	else:
		_procesar_fallo(boton, indice)


func _procesar_acierto(boton: Button, indice: int) -> void:
	ya_acertado = true
	
	# Estilo verde de celebración
	var estilo_exito := StyleBoxFlat.new()
	estilo_exito.bg_color = Color(0.88, 0.98, 0.88, 1)
	estilo_exito.border_width_left = 3
	estilo_exito.border_width_top = 3
	estilo_exito.border_width_right = 3
	estilo_exito.border_width_bottom = 3
	estilo_exito.border_color = Color(0.2, 0.75, 0.3, 1)
	estilo_exito.corner_radius_top_left = 16
	estilo_exito.corner_radius_top_right = 16
	estilo_exito.corner_radius_bottom_right = 16
	estilo_exito.corner_radius_bottom_left = 16
	estilo_exito.content_margin_left = 20
	estilo_exito.content_margin_right = 20
	estilo_exito.content_margin_top = 10
	estilo_exito.content_margin_bottom = 10
	boton.add_theme_stylebox_override("normal", estilo_exito)
	boton.add_theme_color_override("font_color", Color(0.1, 0.55, 0.15, 1))
	boton.text = "⭐ " + opciones[indice]
	
	boton.pivot_offset = boton.size / 2.0
	var tw := create_tween()
	tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_BACK)
	tw.tween_property(boton, "scale", Vector2.ONE, 0.1)
	
	acertado.emit(indice)
	if has_node("/root/EstadoJuego"):
		get_node("/root/EstadoJuego").registrar_acierto(indice_reto)
	
	# Cerrar cuestión y abrir el premio existente
	tw.chain().tween_interval(0.3)
	tw.tween_callback(func():
		popup.visible = false
		_abrir_premio_existente()
	)


func _procesar_fallo(boton: Button, indice: int) -> void:
	boton.pivot_offset = boton.size / 2.0
	var tw := create_tween()
	tw.tween_property(boton, "rotation_degrees", -3.0, 0.05)
	tw.tween_property(boton, "rotation_degrees", 3.0, 0.05)
	tw.tween_property(boton, "rotation_degrees", 0.0, 0.05)
	
	fallado.emit(indice)
	if has_node("/root/EstadoJuego"):
		get_node("/root/EstadoJuego").registrar_fallo(indice_reto)
	
	# Abrir el popup de fallo existente
	_abrir_fallo_existente()


func _abrir_premio_existente() -> void:
	var premio := _obtener_premio()
	if premio and premio.has_method("abrir_premio"):
		premio.abrir_premio()
	elif premio and premio.has_method("_abrir_premio"):
		premio._abrir_premio()


func _abrir_fallo_existente() -> void:
	var fallo := _obtener_o_crear_fallo()
	if fallo and fallo.has_method("mostrar_fallo"):
		fallo.mostrar_fallo(pista_fallo, titulo_fallo)


func _obtener_premio() -> Node:
	var p := get_node_or_null("../Premio")
	if not p and owner:
		p = owner.get_node_or_null("Premio")
	if not p:
		p = get_tree().current_scene.get_node_or_null("Premio")
	return p


func _obtener_o_crear_fallo() -> Node:
	var f := get_node_or_null("../Fallo")
	if not f and owner:
		f = owner.get_node_or_null("Fallo")
	if not f:
		f = get_tree().current_scene.get_node_or_null("Fallo")
	
	if not f:
		var escena_fallo := load("res://Fallo.tscn") as PackedScene
		if escena_fallo:
			f = escena_fallo.instantiate()
			if owner:
				owner.add_child(f)
			else:
				get_tree().current_scene.add_child(f)
	return f
