extends Control

## Marcador de puntos arriba a la derecha con botón para abrir la Tabla de Retos (2x4).

@onready var label_puntos: Label = %LabelPuntos
@onready var boton_tabla: Button = %BotonTabla
@onready var tabla_progreso: CanvasLayer = %TablaProgreso


func _ready() -> void:
	if boton_tabla:
		boton_tabla.pressed.connect(_on_boton_tabla_pulsado)
	
	if has_node("/root/EstadoJuego"):
		var estado = get_node("/root/EstadoJuego")
		estado.puntos_actualizados.connect(_actualizar_puntos)
		_actualizar_puntos(estado.obtener_puntos_totales())


func _actualizar_puntos(puntos: int) -> void:
	if label_puntos:
		label_puntos.text = "%d pts" % puntos
		# Pequeño pop visual al sumar puntos
		var tw := create_tween()
		tw.tween_property(label_puntos, "scale", Vector2(1.2, 1.2), 0.1)
		tw.tween_property(label_puntos, "scale", Vector2.ONE, 0.1)


func _on_boton_tabla_pulsado() -> void:
	if tabla_progreso and tabla_progreso.has_method("abrir_tabla"):
		tabla_progreso.abrir_tabla()
