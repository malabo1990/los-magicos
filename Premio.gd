extends Control

@onready var boton_regalo: TextureButton = %BotonRegalo
@onready var popup: Control = %Popup
@onready var premio_textura: TextureRect = %PremioTextura
@onready var icono_premio: TextureRect = %IconoPremio
@onready var estrellas: CPUParticles2D = %Estrellas
@onready var destellos: CPUParticles2D = %Destellos
@onready var chispas: CPUParticles2D = %Chispas
@onready var resplandor: TextureRect = %Resplandor
@onready var rayos: TextureRect = %Rayos
@onready var fondo: Button = %Fondo
@onready var boton_anterior: Button = %BotonAnteriorPremio
@onready var boton_siguiente: Button = %BotonSiguientePremio

@export var requiere_cuestion: bool = true
@export var textura_premio: Texture2D
@export var escala_premio: float = 1.0
var cuestion_superada: bool = false

var tween_regalo: Tween
var tween_brillo: Tween
var tiempo_rayos := 0.0

func _ready() -> void:
	show()
	popup.visible = false
	premio_textura.scale = Vector2.ZERO
	if icono_premio:
		icono_premio.visible = textura_premio != null
		if textura_premio:
			icono_premio.texture = textura_premio
		icono_premio.scale = Vector2(escala_premio, escala_premio)
	boton_regalo.pressed.connect(_on_boton_regalo_pulsado)
	fondo.pressed.connect(_cerrar_premio)
	boton_anterior.pressed.connect(_ir_anterior)
	boton_siguiente.pressed.connect(_ir_siguiente)
	_iniciar_animacion_regalo()

func _on_boton_regalo_pulsado() -> void:
	if requiere_cuestion and not cuestion_superada:
		# 1. Comprobar JuegoArrastrarLetras (Escena 4 Braille / Escena 6 Sordociegos)
		var juego_letras := get_node_or_null("../JuegoArrastrarLetras")
		if not juego_letras and owner:
			juego_letras = owner.get_node_or_null("JuegoArrastrarLetras")
		if juego_letras and juego_letras.has_method("abrir_juego"):
			juego_letras.abrir_juego()
			return
		
		# 2. Comprobar MinijuegoIC (Escena 11 Implantes Cocleares)
		var juego_ic := get_node_or_null("../MinijuegoIC")
		if not juego_ic and owner:
			juego_ic = owner.get_node_or_null("MinijuegoIC")
		if juego_ic and juego_ic.has_method("abrir_juego"):
			juego_ic.abrir_juego()
			return
		
		# 3. Comprobar Cuestion (Escenas 5, 7, 8, 9, 10...)
		var cuestion := get_node_or_null("../Cuestion")
		if not cuestion and owner:
			cuestion = owner.get_node_or_null("Cuestion")
		if cuestion and cuestion.has_method("abrir_cuestion"):
			cuestion.abrir_cuestion()
			return
	_abrir_premio()

func _process(delta: float) -> void:
	if not popup.visible:
		return
	tiempo_rayos += delta
	rayos.rotation += TAU / 16.0 * delta
	var s := 0.5 + 0.5 * sin(tiempo_rayos * TAU / 2.8)
	rayos.modulate.a = 0.55 + 0.40 * s
	var e := 1.0 + 0.08 * s
	rayos.scale = Vector2(e, e)

func _iniciar_animacion_regalo() -> void:
	if tween_regalo:
		tween_regalo.kill()
	boton_regalo.pivot_offset = boton_regalo.size / 2.0
	tween_regalo = create_tween().set_loops()
	
	# Pausa de espera entre timbrazos
	tween_regalo.tween_interval(1.2)
	
	# Animación rápida estilo "riiing rrring" con rotación y escala
	tween_regalo.parallel().tween_property(boton_regalo, "scale", Vector2(1.18, 1.18), 0.08)
	tween_regalo.parallel().tween_property(boton_regalo, "rotation_degrees", -14.0, 0.06)
	tween_regalo.tween_property(boton_regalo, "rotation_degrees", 14.0, 0.07)
	tween_regalo.tween_property(boton_regalo, "rotation_degrees", -12.0, 0.07)
	tween_regalo.tween_property(boton_regalo, "rotation_degrees", 12.0, 0.07)
	tween_regalo.tween_property(boton_regalo, "rotation_degrees", -8.0, 0.06)
	tween_regalo.tween_property(boton_regalo, "rotation_degrees", 8.0, 0.06)
	
	# Vuelta al estado de reposo
	tween_regalo.parallel().tween_property(boton_regalo, "rotation_degrees", 0.0, 0.1)
	tween_regalo.parallel().tween_property(boton_regalo, "scale", Vector2.ONE, 0.1)

func abrir_premio() -> void:
	_abrir_premio()

func abrir() -> void:
	_abrir_premio()

func _abrir_premio() -> void:
	cuestion_superada = true
	if tween_regalo:
		tween_regalo.pause()
	boton_regalo.rotation_degrees = 0.0
	boton_regalo.scale = Vector2.ONE
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
	premio_textura.scale = Vector2.ZERO
	particulas_restart_centradas()
	_mostrar_brillo()
	_arrancar_rayos()
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(premio_textura, "scale", Vector2.ONE, 0.5)

func particulas_restart_centradas() -> void:
	estrellas.restart()
	estrellas.emitting = true
	destellos.restart()
	destellos.emitting = true
	chispas.restart()
	chispas.emitting = true

func _mostrar_brillo() -> void:
	if tween_brillo:
		tween_brillo.kill()
	resplandor.modulate.a = 0.0
	resplandor.scale = Vector2(0.35, 0.35)
	tween_brillo = create_tween().set_parallel()
	tween_brillo.tween_property(resplandor, "modulate:a", 0.9, 0.12)
	tween_brillo.tween_property(resplandor, "scale", Vector2(1.1, 1.1), 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_brillo.chain().tween_property(resplandor, "modulate:a", 0.0, 0.55).set_delay(0.55)

func _arrancar_rayos() -> void:
	tiempo_rayos = 0.0
	rayos.rotation = 0.0
	rayos.scale = Vector2.ONE
	rayos.modulate.a = 0.55

func _parar_rayos() -> void:
	rayos.modulate.a = 0.0

func _cerrar_premio() -> void:
	popup.visible = false
	_parar_rayos()
	chispas.emitting = false
	if tween_regalo:
		tween_regalo.play()

func _ir_anterior() -> void:
	var padre := get_parent()
	if padre.has_method("_on_anterior_pressed"):
		padre._on_anterior_pressed()

func _ir_siguiente() -> void:
	var padre := get_parent()
	if padre.has_method("_on_siguiente_pressed"):
		padre._on_siguiente_pressed()
