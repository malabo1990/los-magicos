extends CanvasLayer

## Modal que muestra la tabla de 2 filas x 4 columnas (8 retos) con "V" y "X",
## y los puntos totales de premios.

@onready var popup: Control = %Popup
@onready var fondo: Button = %Fondo
@onready var tarjeta: PanelContainer = %Tarjeta
@onready var grid: GridContainer = %GridRetos
@onready var label_puntos: Label = %LabelPuntosTotales
@onready var boton_cerrar: Button = %BotonCerrar

var celdas: Array[PanelContainer] = []
var tween_tarjeta: Tween


func _ready() -> void:
	show()
	popup.visible = false
	fondo.pressed.connect(cerrar_tabla)
	if boton_cerrar:
		boton_cerrar.pressed.connect(cerrar_tabla)
	
	_crear_celdas_grid()
	
	if has_node("/root/EstadoJuego"):
		var estado = get_node("/root/EstadoJuego")
		estado.puntos_actualizados.connect(func(_p): actualizar_datos())
		estado.reto_actualizado.connect(func(_i, _e): actualizar_datos())


func abrir_tabla() -> void:
	actualizar_datos()
	popup.visible = true
	tarjeta.pivot_offset = tarjeta.size / 2.0
	tarjeta.scale = Vector2(0.65, 0.65)
	
	if tween_tarjeta:
		tween_tarjeta.kill()
	
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func cerrar_tabla() -> void:
	if tween_tarjeta:
		tween_tarjeta.kill()
	tween_tarjeta = create_tween()
	tween_tarjeta.tween_property(tarjeta, "scale", Vector2(0.7, 0.7), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween_tarjeta.finished.connect(func():
		popup.visible = false
	)


func _crear_celdas_grid() -> void:
	if not grid:
		return
	
	for h in grid.get_children():
		h.queue_free()
	celdas.clear()
	
	var font_fredoka = load("res://fonts/Fredoka.ttf")
	var font_nunito = load("res://fonts/Nunito.ttf")
	
	for i in range(8):
		var p := PanelContainer.new()
		p.custom_minimum_size = Vector2(125, 95)
		
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 8)
		m.add_theme_constant_override("margin_top", 8)
		m.add_theme_constant_override("margin_right", 8)
		m.add_theme_constant_override("margin_bottom", 8)
		p.add_child(m)
		
		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		m.add_child(vbox)
		
		# Título del reto (número y nombre)
		var lbl_nombre := Label.new()
		lbl_nombre.name = "LabelNombre"
		lbl_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font_fredoka:
			lbl_nombre.add_theme_font_override("font", font_fredoka)
		lbl_nombre.add_theme_font_size_override("font_size", 14)
		lbl_nombre.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25, 1))
		vbox.add_child(lbl_nombre)
		
		# Letra grande "V" o "X"
		var lbl_estado := Label.new()
		lbl_estado.name = "LabelEstado"
		lbl_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font_fredoka:
			lbl_estado.add_theme_font_override("font", font_fredoka)
		lbl_estado.add_theme_font_size_override("font_size", 30)
		vbox.add_child(lbl_estado)
		
		# Puntos de la celda
		var lbl_pts := Label.new()
		lbl_pts.name = "LabelPts"
		lbl_pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font_nunito:
			lbl_pts.add_theme_font_override("font", font_nunito)
		lbl_pts.add_theme_font_size_override("font_size", 13)
		vbox.add_child(lbl_pts)
		
		grid.add_child(p)
		celdas.append(p)
	
	actualizar_datos()


func actualizar_datos() -> void:
	if not has_node("/root/EstadoJuego"):
		return
	
	var estado = get_node("/root/EstadoJuego")
	var puntos: int = estado.obtener_puntos_totales()
	var max_puntos: int = estado.obtener_maximo_puntos()
	
	if label_puntos:
		label_puntos.text = "Puntos de premios: %d / %d ⭐" % [puntos, max_puntos]
	
	for i in range(mini(celdas.size(), 8)):
		var celda := celdas[i]
		var est: int = estado.obtener_estado(i)
		var nombre_reto: String = estado.NOMBRES_RETOS[i] if i < estado.NOMBRES_RETOS.size() else "Reto %d" % (i + 1)
		
		var lbl_nom: Label = celda.find_child("LabelNombre", true, false)
		var lbl_est: Label = celda.find_child("LabelEstado", true, false)
		var lbl_pts: Label = celda.find_child("LabelPts", true, false)
		
		if lbl_nom:
			lbl_nom.text = "%d. %s" % [i + 4, nombre_reto]
		
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 14
		style.corner_radius_top_right = 14
		style.corner_radius_bottom_right = 14
		style.corner_radius_bottom_left = 14
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		
		match est:
			1: # ACIERTO ("V")
				style.bg_color = Color(0.9, 0.98, 0.9, 1)
				style.border_color = Color(0.25, 0.75, 0.3, 1)
				if lbl_est:
					lbl_est.text = "V"
					lbl_est.add_theme_color_override("font_color", Color(0.18, 0.65, 0.22, 1))
				if lbl_pts:
					lbl_pts.text = "+5 pts"
					lbl_pts.add_theme_color_override("font_color", Color(0.18, 0.65, 0.22, 1))
			2: # FALLO ("X")
				style.bg_color = Color(1, 0.92, 0.92, 1)
				style.border_color = Color(0.9, 0.35, 0.3, 1)
				if lbl_est:
					lbl_est.text = "X"
					lbl_est.add_theme_color_override("font_color", Color(0.85, 0.25, 0.2, 1))
				if lbl_pts:
					lbl_pts.text = "0 pts"
					lbl_pts.add_theme_color_override("font_color", Color(0.85, 0.25, 0.2, 1))
			_: # PENDIENTE
				style.bg_color = Color(0.96, 0.96, 0.96, 1)
				style.border_color = Color(0.82, 0.82, 0.82, 1)
				if lbl_est:
					lbl_est.text = "—"
					lbl_est.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
				if lbl_pts:
					lbl_pts.text = "0 pts"
					lbl_pts.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		
		celda.add_theme_stylebox_override("panel", style)
