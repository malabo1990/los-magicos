extends Node

## En la versión web, Godot no puede reproducir vídeo: el único formato del
## núcleo es Ogg Theora y los navegadores no lo decodifican (WebM se eliminó
## en Godot 4.0). Para que la pantalla del móvil no quede en negro, cada
## VideoStreamPlayer se sustituye por un fotograma fijo (póster).

const POSTER: Texture2D = preload("res://Videos/poster_video.png")


func _ready() -> void:
	if not OS.has_feature("web"):
		return
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(nodo: Node) -> void:
	if nodo is VideoStreamPlayer:
		_sustituir.call_deferred(nodo)


func _sustituir(video: VideoStreamPlayer) -> void:
	if not is_instance_valid(video) or video.has_meta("poster_web"):
		return
	video.set_meta("poster_web", true)
	video.stream_paused = true

	var poster := TextureRect.new()
	poster.name = "PosterWeb"
	poster.texture = POSTER
	poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	poster.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.add_child(poster)
