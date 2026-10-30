extends Control

## Minijuego del Implante Coclear (IC - Escena 11).
## 3 pasos / 3 partes de la oreja para entender cómo se procesa el sonido hasta el cerebro a través del caracol.

signal completado

@onready var popup: Control = %Popup
@onready var fondo: Button = %Fondo
@onready var tarjeta: PanelContainer = %Tarjeta
@onready var titulo_paso: Label = %TituloPaso
@onready var pregunta_label: Label = %PreguntaLabel
@onready var contenedor_opciones: VBoxContainer = %ContenedorOpciones
@onready var label_progreso_pasos: Label = %LabelProgresoPasos
@onready var diagrama_estado: Label = %DiagramaEstado
@onready var boton_cerrar: Button = %BotonCerrar

const DATOS_PASOS: Array[Dictionary] = [
	{
		"titulo": "PARTE 1: EXTERIOR (EL SONIDO)",
		"diagrama": "🦻 [1. Micrófono Exterior] ───▶ ⏳ [2. Imán] ───▶ ⏳ [3. Caracol & Cerebro]",
		"pregunta": "¿Qué parte recoge los sonidos del aire y las voces de la gente?",
		"opciones": [
			"A) El procesador y micrófono exterior detrás de la oreja 🦻",
			"B) Un megáfono de fútbol 📢",
			"C) Un paraguas para la lluvia ☂️"
		],
		"correcto": 0,
		"pista": "¡Casi! La primera parte es el procesador con micrófono que va colocado detrás de la oreja."
	},
	{
		"titulo": "PARTE 2: TRANSMISIÓN (CRUZAR LA PIEL)",
		"diagrama": "✅ [1. Micrófono] ───▶ 🧲⚡ [2. Imán & Antena] ───▶ ⏳ [3. Caracol & Cerebro]",
		"pregunta": "¿Cómo pasa la señal a través de la piel hasta el interior sin cables?",
		"opciones": [
			"A) Con cinta adhesiva de colores 🎀",
			"B) Con el imán y la antena que envían ondas invisibles 🧲⚡",
			"C) Con una goma elástica 🪢"
		],
		"correcto": 1,
		"pista": "¡Casi! El imán y la antena redonda envían las ondas a través de la piel gracias al magnetismo."
	},
	{
		"titulo": "PARTE 3: INTERIOR (EL CARACOL Y EL CEREBRO)",
		"diagrama": "✅ [1. Micrófono] ───▶ ✅ [2. Imán] ───▶ 🐚🧠 [3. Caracol & Cerebro]",
		"pregunta": "¿A dónde llega el sonido dentro del oído para mandar el mensaje directo al cerebro?",
		"opciones": [
			"A) A los dientes para masticar 🦷",
			"B) A los ojos para parpadear 👁️",
			"C) Al caracol (la cóclea) con electrodos que activan el nervio hasta el cerebro 🐚🧠"
		],
		"correcto": 2,
		"pista": "¡Casi! Dentro del oído está la cóclea, con forma de caracol, que envía los impulsos al cerebro."
	}
]

var paso_actual: int = 0
var tween_tarjeta: Tween


func _ready() -> void:
	show()
	popup.visible = false
	fondo.pressed.connect(cerrar_juego)
	if boton_cerrar:
		boton_cerrar.pressed.connect(cerrar_juego)
	_cargar_paso(0)


func abrir_juego() -> void:
	paso_actual = 0
	_cargar_paso(0)
	popup.visible = true
	tarjeta.pivot_offset = tarjeta.size / 2.0
	tarjeta.scale = Vector2(0.65, 0.65)
	
	if tween_tarjeta:
		tween_tarjeta.kill()
	
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func cerrar_juego() -> void:
	if tween_tarjeta:
		tween_tarjeta.kill()
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2(0.7, 0.7), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_tarjeta.finished.connect(func():
		popup.visible = false
	)


func _cargar_paso(num_paso: int) -> void:
	paso_actual = num_paso
	var datos: Dictionary = DATOS_PASOS[paso_actual]
	
	if titulo_paso:
		titulo_paso.text = datos["titulo"]
	if diagrama_estado:
		diagrama_estado.text = datos["diagrama"]
	if label_progreso_pasos:
		label_progreso_pasos.text = "Paso %d de 3" % (paso_actual + 1)
	if pregunta_label:
		pregunta_label.text = datos["pregunta"]
	
	_construir_botones_opciones(datos["opciones"], datos["correcto"])


func _construir_botones_opciones(opciones: Array, indice_correcto: int) -> void:
	if not contenedor_opciones:
		return
	
	for h in contenedor_opciones.get_children():
		h.queue_free()
	
	var font_fredoka = load("res://fonts/Fredoka.ttf")
	
	for i in range(opciones.size()):
		var btn := Button.new()
		btn.text = opciones[i]
		btn.custom_minimum_size = Vector2(0, 84)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if font_fredoka:
			btn.add_theme_font_override("font", font_fredoka)
		btn.add_theme_font_size_override("font_size", 26)
		btn.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18, 1))
		
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(1, 1, 1, 0.95)
		estilo.border_width_left = 3
		estilo.border_width_top = 3
		estilo.border_width_right = 3
		estilo.border_width_bottom = 3
		estilo.border_color = Color(0.9, 0.75, 0.6, 1)
		estilo.corner_radius_top_left = 14
		estilo.corner_radius_top_right = 14
		estilo.corner_radius_bottom_right = 14
		estilo.corner_radius_bottom_left = 14
		estilo.content_margin_left = 28
		estilo.content_margin_right = 28
		estilo.content_margin_top = 14
		estilo.content_margin_bottom = 14
		btn.add_theme_stylebox_override("normal", estilo)
		
		var estilo_hover := estilo.duplicate() as StyleBoxFlat
		estilo_hover.border_color = Color(0.95, 0.55, 0.2, 1)
		estilo_hover.bg_color = Color(1, 0.97, 0.92, 1)
		btn.add_theme_stylebox_override("hover", estilo_hover)
		
		btn.pressed.connect(_on_opcion_elegida.bind(i, indice_correcto, btn))
		contenedor_opciones.add_child(btn)


func _on_opcion_elegida(indice_elegido: int, indice_correcto: int, boton: Button) -> void:
	if indice_elegido == indice_correcto:
		# ¡Acierto en este paso!
		var estilo_ok := StyleBoxFlat.new()
		estilo_ok.bg_color = Color(0.88, 0.98, 0.88, 1)
		estilo_ok.border_width_left = 3
		estilo_ok.border_width_top = 3
		estilo_ok.border_width_right = 3
		estilo_ok.border_width_bottom = 3
		estilo_ok.border_color = Color(0.2, 0.75, 0.3, 1)
		estilo_ok.corner_radius_top_left = 14
		estilo_ok.corner_radius_top_right = 14
		estilo_ok.corner_radius_bottom_right = 14
		estilo_ok.corner_radius_bottom_left = 14
		estilo_ok.content_margin_left = 18
		estilo_ok.content_margin_right = 18
		boton.add_theme_stylebox_override("normal", estilo_ok)
		boton.add_theme_color_override("font_color", Color(0.1, 0.55, 0.15, 1))
		boton.text = "⭐ " + DATOS_PASOS[paso_actual]["opciones"][indice_elegido]
		
		boton.pivot_offset = boton.size / 2.0
		var tw := create_tween()
		tw.tween_property(boton, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(boton, "scale", Vector2.ONE, 0.1)
		
		tw.chain().tween_interval(0.4)
		tw.tween_callback(func():
			if paso_actual < 2:
				_cargar_paso(paso_actual + 1)
			else:
				_victoria_completa()
		)
	else:
		# Fallo en este paso
		boton.pivot_offset = boton.size / 2.0
		var tw := create_tween()
		tw.tween_property(boton, "rotation_degrees", -3.0, 0.05)
		tw.tween_property(boton, "rotation_degrees", 3.0, 0.05)
		tw.tween_property(boton, "rotation_degrees", 0.0, 0.05)
		
		var fallo := get_node_or_null("../Fallo")
		if not fallo and owner:
			fallo = owner.get_node_or_null("Fallo")
		if fallo and fallo.has_method("mostrar_fallo"):
			fallo.mostrar_fallo(DATOS_PASOS[paso_actual]["pista"], "¡Casi!")


func _victoria_completa() -> void:
	if diagrama_estado:
		diagrama_estado.text = "🎉 ¡BOOM! ✅ [1. Micrófono] ──▶ ✅ [2. Imán] ──▶ ✅ [3. Caracol] ──▶ 🧠 ¡SONIDO RECIBIDO!"
	if pregunta_label:
		pregunta_label.text = "¡ENHORABUENA! ¡Has conectado el Implante Coclear hasta el cerebro! (+5 puntos ⭐)"
	
	if has_node("/root/EstadoJuego"):
		get_node("/root/EstadoJuego").registrar_acierto(7)
	
	completado.emit()
	
	var tw := create_tween()
	tw.tween_interval(1.2)
	tw.tween_callback(func():
		popup.visible = false
		var premio := get_node_or_null("../Premio")
		if not premio and owner:
			premio = owner.get_node_or_null("Premio")
		if premio and premio.has_method("abrir_premio"):
			premio.abrir_premio()
	)
