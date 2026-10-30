extends Control

const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
var appearance: Dictionary = APPEARANCE.DEFAULT.duplicate()
var facing := 0
var walking := false
var _time := 0.0
var _texture: Texture2D
var _views: Array[Texture2D] = []
const DIRECTIONS := ["down", "left", "up", "right"]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	refresh()


func refresh() -> void:
	_texture = APPEARANCE.strip(("walk_" if walking else "idle_") + DIRECTIONS[facing], appearance)
	_views.clear()
	for direction: String in DIRECTIONS:
		_views.append(APPEARANCE.strip("idle_" + direction, appearance))
	queue_redraw()


func _process(delta: float) -> void:
	if SaveManager.motion() > 0.5:
		_time += delta
	queue_redraw()


func _draw() -> void:
	if _texture == null:
		return
	var cell := int(_time * (10.0 if walking else 5.0)) % (8 if walking else 6)
	var unit := 13.0
	var at := Vector2(size.x * 0.5, 470)
	draw_set_transform(at, 0, Vector2(1, 0.24))
	draw_circle(Vector2.ZERO, 105, Color(0.01, 0.005, 0.03, 0.5))
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(_texture, Rect2(at - Vector2(16, 28) * unit, Vector2.ONE * 32 * unit), Rect2(cell * 32, 0, 32, 32))
	for i in range(4):
		draw_texture_rect_region(_views[i], Rect2(104 + i * 112, 616, 80, 80), Rect2(0, 0, 32, 32))

