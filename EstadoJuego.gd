extends Node

## Gestor global de progreso y puntuación para Los Mágicos.
## Administra los 8 retos (escenas 4 a 11), puntos (5 por acierto) y tabla 2x4.

signal puntos_actualizados(puntos_totales: int)
signal reto_actualizado(indice_reto: int, estado: int)

enum EstadoReto {
	PENDIENTE = 0,
	ACIERTO = 1, # "V"
	FALLO = 2    # "X"
}

const PUNTOS_POR_ACIERTO := 5
const NUM_RETOS := 8
const RUTA_GUARDADO := "user://progreso_magicos.json"

const NOMBRES_RETOS: Array[String] = [
	"Braille",          # Escena 4
	"Gallaudet",        # Escena 5
	"Sordociegos",      # Escena 6
	"Edison",           # Escena 7
	"Historia LSE",     # Escena 8
	"Animales",         # Escena 9
	"Inventores",       # Escena 10
	"Implante (IC)"     # Escena 11
]

var estados_retos: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0]


func _ready() -> void:
	cargar_progreso()


func registrar_acierto(indice_reto: int) -> void:
	if indice_reto < 0 or indice_reto >= NUM_RETOS:
		return
	
	if estados_retos[indice_reto] != EstadoReto.ACIERTO:
		estados_retos[indice_reto] = EstadoReto.ACIERTO
		guardar_progreso()
		reto_actualizado.emit(indice_reto, EstadoReto.ACIERTO)
		puntos_actualizados.emit(obtener_puntos_totales())


func registrar_fallo(indice_reto: int) -> void:
	if indice_reto < 0 or indice_reto >= NUM_RETOS:
		return
	
	# Solo marcamos fallo si aún no había acertado
	if estados_retos[indice_reto] != EstadoReto.ACIERTO:
		estados_retos[indice_reto] = EstadoReto.FALLO
		guardar_progreso()
		reto_actualizado.emit(indice_reto, EstadoReto.FALLO)


func obtener_estado(indice_reto: int) -> int:
	if indice_reto < 0 or indice_reto >= NUM_RETOS:
		return EstadoReto.PENDIENTE
	return estados_retos[indice_reto]


func obtener_puntos_totales() -> int:
	var total := 0
	for estado in estados_retos:
		if estado == EstadoReto.ACIERTO:
			total += PUNTOS_POR_ACIERTO
	return total


func obtener_maximo_puntos() -> int:
	return NUM_RETOS * PUNTOS_POR_ACIERTO


func guardar_progreso() -> void:
	var datos := {
		"estados_retos": estados_retos
	}
	var f := FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(datos))
		f.close()


func cargar_progreso() -> void:
	if not FileAccess.file_exists(RUTA_GUARDADO):
		return
	var f := FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	if not f:
		return
	var texto := f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(texto) == OK and json.data is Dictionary:
		var d: Dictionary = json.data
		if d.has("estados_retos") and d["estados_retos"] is Array:
			var lista: Array = d["estados_retos"]
			for i in range(mini(lista.size(), NUM_RETOS)):
				estados_retos[i] = int(lista[i])


func reiniciar_progreso() -> void:
	for i in range(NUM_RETOS):
		estados_retos[i] = EstadoReto.PENDIENTE
	guardar_progreso()
	puntos_actualizados.emit(0)
	for i in range(NUM_RETOS):
		reto_actualizado.emit(i, EstadoReto.PENDIENTE)
