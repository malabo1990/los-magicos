extends Button

@export var panel_objetivo: NodePath
@export var texto_cerrado: String = "+"
@export var texto_abierto: String = "-"

func _ready() -> void:
	text = texto_cerrado
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var panel := get_node(panel_objetivo) as CanvasItem
	panel.visible = not panel.visible
	text = texto_abierto if panel.visible else texto_cerrado
