extends Control

## Minijuego de buscar y colocar letras (Drag & Drop / Toque) para Braille y Helen Keller.
## Modo "braille" (CASIMIRO) o "sordociegos" (ESTIBALIZ).

signal completado

@export var modo: String = "braille" # "braille" o "sordociegos"
@export var palabra_objetivo: String = "CASIMIRO" # "CASIMIRO" o "ESTIBALIZ"
@export var indice_reto: int = 0 # 0 para Braille (Escena 4), 2 para Helen Keller (Escena 6)

@onready var popup: Control = %Popup
@onready var fondo: Button = %Fondo
@onready var tarjeta: PanelContainer = %Tarjeta
@onready var titulo_label: Label = %Titulo
@onready var subtitulo_label: Label = %Subtitulo
@onready var contenedor_slots: HBoxContainer = %ContenedorSlots
@onready var grid_abecedario: GridContainer = %GridAbecedario
@onready var boton_cerrar: Button = %BotonCerrar
@onready var label_mensaje: Label = %LabelMensaje

const MAPA_BRAILLE: Dictionary = {
	"A": "⠁", "B": "⠃", "C": "⠉", "D": "⠙", "E": "⠑",
	"F": "⠋", "G": "⠛", "H": "⠓", "I": "⠊", "J": "⠚",
	"K": "⠅", "L": "⠇", "M": "⠍", "N": "⠝", "O": "⠕",
	"P": "⠏", "Q": "⠟", "R": "⠗", "S": "⠎", "T": "⠞",
	"U": "⠥", "V": "⠧", "W": "⠺", "X": "⠭", "Y": "⠽", "Z": "⠵"
}

var slots: Array[PanelContainer] = []
var letras_completadas: Array[bool] = []
var letra_seleccionada: String = ""
var tween_tarjeta: Tween


func _ready() -> void:
	show()
	popup.visible = false
	fondo.pressed.connect(cerrar_juego)
	if boton_cerrar:
		boton_cerrar.pressed.connect(cerrar_juego)
	inicializar(modo, palabra_objetivo, indice_reto)


func inicializar(nuevo_modo: String, nueva_palabra: String, nuevo_indice: int) -> void:
	modo = nuevo_modo
	palabra_objetivo = nueva_palabra.to_upper()
	indice_reto = nuevo_indice
	
	if titulo_label:
		if modo == "braille":
			titulo_label.text = "🎯 ¡ESCRIBE %s EN BRAILLE!" % palabra_objetivo
			subtitulo_label.text = "Toca o arrastra cada letra en Braille a su casilla para formar el nombre."
		else:
			titulo_label.text = "🎯 ¡DELETREA %s EN LAS MANOS!" % palabra_objetivo
			subtitulo_label.text = "Toca o arrastra cada mano del alfabeto sordociego a su casilla."
	
	_construir_slots()
	_construir_abecedario()


func abrir_juego() -> void:
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


func _construir_slots() -> void:
	if not contenedor_slots:
		return
	
	for h in contenedor_slots.get_children():
		h.queue_free()
	slots.clear()
	letras_completadas.clear()
	
	var font_fredoka = load("res://fonts/Fredoka.ttf")
	
	for i in range(palabra_objetivo.length()):
		letras_completadas.append(false)
		var letra := palabra_objetivo[i]
		
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(68, 100)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Script de drop de datos para Drag & Drop nativo
		panel.set_meta("indice_slot", i)
		panel.set_meta("letra_esperada", letra)
		
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(1, 1, 1, 0.95)
		estilo.border_width_left = 3
		estilo.border_width_top = 3
		estilo.border_width_right = 3
		estilo.border_width_bottom = 3
		estilo.border_color = Color(0.9, 0.6, 0.3, 1)
		estilo.corner_radius_top_left = 14
		estilo.corner_radius_top_right = 14
		estilo.corner_radius_bottom_right = 14
		estilo.corner_radius_bottom_left = 14
		panel.add_theme_stylebox_override("panel", estilo)
		
		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 2)
		panel.add_child(vb)
		
		# Letra en tinta
		var lbl_tinta := Label.new()
		lbl_tinta.text = letra
		lbl_tinta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font_fredoka:
			lbl_tinta.add_theme_font_override("font", font_fredoka)
		lbl_tinta.add_theme_font_size_override("font_size", 28)
		lbl_tinta.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18, 1))
		vb.add_child(lbl_tinta)
		
		# Espacio para el glifo o imagen
		if modo == "braille":
			var lbl_glifo := Label.new()
			lbl_glifo.name = "GlifoBraille"
			lbl_glifo.text = "·"
			lbl_glifo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			if font_fredoka:
				lbl_glifo.add_theme_font_override("font", font_fredoka)
			lbl_glifo.add_theme_font_size_override("font_size", 36)
			lbl_glifo.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
			vb.add_child(lbl_glifo)
		else:
			var tex_rect := TextureRect.new()
			tex_rect.name = "TexturaMano"
			tex_rect.custom_minimum_size = Vector2(46, 46)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			vb.add_child(tex_rect)
		
		# Permitir también hacer clic en el slot para colocar la letra seleccionada
		var btn_slot := Button.new()
		btn_slot.flat = true
		btn_slot.custom_minimum_size = Vector2(68, 100)
		btn_slot.pressed.connect(_on_slot_pulsado.bind(i))
		panel.add_child(btn_slot)
		
		contenedor_slots.add_child(panel)
		slots.append(panel)


func _construir_abecedario() -> void:
	if not grid_abecedario:
		return
	
	for h in grid_abecedario.get_children():
		h.queue_free()
	
	var font_fredoka = load("res://fonts/Fredoka.ttf")
	var abecedario := ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
	
	for letra in abecedario:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(48, 92)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_constant_override("outline_size", 0)
		
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(1, 1, 1, 0.95)
		estilo.border_width_left = 2
		estilo.border_width_top = 2
		estilo.border_width_right = 2
		estilo.border_width_bottom = 2
		estilo.border_color = Color(0.85, 0.85, 0.85, 1)
		estilo.corner_radius_top_left = 10
		estilo.corner_radius_top_right = 10
		estilo.corner_radius_bottom_right = 10
		estilo.corner_radius_bottom_left = 10
		btn.add_theme_stylebox_override("normal", estilo)
		
		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vb.add_theme_constant_override("separation", 0)
		btn.add_child(vb)
		vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		var lbl_l := Label.new()
		lbl_l.text = letra
		lbl_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font_fredoka:
			lbl_l.add_theme_font_override("font", font_fredoka)
		lbl_l.add_theme_font_size_override("font_size", 30)
		lbl_l.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		vb.add_child(lbl_l)
		
		if modo == "braille":
			var glifo: String = MAPA_BRAILLE.get(letra, "")
			var lbl_g := Label.new()
			lbl_g.text = glifo
			lbl_g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			if font_fredoka:
				lbl_g.add_theme_font_override("font", font_fredoka)
			lbl_g.add_theme_font_size_override("font_size", 38)
			lbl_g.add_theme_color_override("font_color", Color(0.9, 0.45, 0.1, 1))
			vb.add_child(lbl_g)
		else:
			var ruta_img := "res://6/sordociegos/%s.png" % letra.to_lower()
			if ResourceLoader.exists(ruta_img):
				var tex := TextureRect.new()
				tex.texture = load(ruta_img)
				tex.custom_minimum_size = Vector2(32, 32)
				tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				vb.add_child(tex)
		
		btn.pressed.connect(_on_letra_abecedario_pulsada.bind(letra, btn))
		grid_abecedario.add_child(btn)


func _on_letra_abecedario_pulsada(letra: String, boton: Button) -> void:
	letra_seleccionada = letra
	
	# Resaltar botón seleccionado
	boton.pivot_offset = boton.size / 2.0
	var tw := create_tween()
	tw.tween_property(boton, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_BACK)
	tw.tween_property(boton, "scale", Vector2.ONE, 0.1)
	
	if label_mensaje:
		label_mensaje.text = "Has seleccionado la letra: %s. ¡Ahora toca su casilla arriba!" % letra
	
	# Si solo queda una casilla libre que coincida con esta letra, la colocamos automáticamente
	for i in range(palabra_objetivo.length()):
		if not letras_completadas[i] and palabra_objetivo[i] == letra:
			_colocar_letra_en_slot(i, letra)
			return


func _on_slot_pulsado(indice: int) -> void:
	if letras_completadas[indice]:
		return
	
	if letra_seleccionada == "":
		if label_mensaje:
			label_mensaje.text = "Primero toca una letra del abecedario de abajo."
		return
	
	_colocar_letra_en_slot(indice, letra_seleccionada)


func _colocar_letra_en_slot(indice: int, letra: String) -> void:
	var letra_correcta := palabra_objetivo[indice]
	var panel := slots[indice]
	
	if letra == letra_correcta:
		# ¡Acierto en este slot!
		letras_completadas[indice] = true
		
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.9, 0.98, 0.9, 1)
		estilo.border_width_left = 3
		estilo.border_width_top = 3
		estilo.border_width_right = 3
		estilo.border_width_bottom = 3
		estilo.border_color = Color(0.2, 0.75, 0.3, 1)
		estilo.corner_radius_top_left = 14
		estilo.corner_radius_top_right = 14
		estilo.corner_radius_bottom_right = 14
		estilo.corner_radius_bottom_left = 14
		panel.add_theme_stylebox_override("panel", estilo)
		
		if modo == "braille":
			var lbl_glifo: Label = panel.find_child("GlifoBraille", true, false)
			if lbl_glifo:
				lbl_glifo.text = MAPA_BRAILLE.get(letra, "")
				lbl_glifo.add_theme_color_override("font_color", Color(0.15, 0.65, 0.2, 1))
		else:
			var tex_rect: TextureRect = panel.find_child("TexturaMano", true, false)
			if tex_rect:
				var ruta := "res://6/sordociegos/%s.png" % letra.to_lower()
				if ResourceLoader.exists(ruta):
					tex_rect.texture = load(ruta)
		
		# Pop elástico
		panel.pivot_offset = panel.size / 2.0
		var tw := create_tween()
		tw.tween_property(panel, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(panel, "scale", Vector2.ONE, 0.1)
		
		if label_mensaje:
			label_mensaje.text = "¡Muy bien! ¡Letra %s colocada!" % letra
		
		_comprobar_victoria()
	else:
		# Fallo en este slot
		panel.pivot_offset = panel.size / 2.0
		var tw := create_tween()
		tw.tween_property(panel, "rotation_degrees", -4.0, 0.05)
		tw.tween_property(panel, "rotation_degrees", 4.0, 0.05)
		tw.tween_property(panel, "rotation_degrees", 0.0, 0.05)
		
		if label_mensaje:
			label_mensaje.text = "¡Casi! Esa casilla necesita la letra %s, y has puesto la %s." % [letra_correcta, letra]


func _comprobar_victoria() -> void:
	for compl in letras_completadas:
		if not compl:
			return
	
	# ¡Todas las letras completadas!
	if label_mensaje:
		label_mensaje.text = "🎉 ¡EXCELENTE! ¡HAS FORMADO %s! (+5 puntos) 🎉" % palabra_objetivo
	
	if has_node("/root/EstadoJuego"):
		get_node("/root/EstadoJuego").registrar_acierto(indice_reto)
	
	completado.emit()
	
	# Esperar un segundo y abrir el premio
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func():
		popup.visible = false
		var premio := get_node_or_null("../Premio")
		if not premio and owner:
			premio = owner.get_node_or_null("Premio")
		if premio and premio.has_method("abrir_premio"):
			premio.abrir_premio()
	)
