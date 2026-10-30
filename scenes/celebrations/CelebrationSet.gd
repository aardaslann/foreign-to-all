extends Node2D

@export var background: Texture2D
@export var city: String = ""

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func floor_y() -> float:
	return 440.0

func _draw() -> void:
	if background != null:
		draw_texture_rect(background, Rect2(0, 0, 1152, 648), false)
