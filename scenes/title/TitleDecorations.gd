extends Control

const BACKDROP := preload("res://art/title/berlin-night.png")
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
var _t := 0.0
var _alien: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_alien = APPEARANCE.strip("idle_up", APPEARANCE.current())


func _process(delta: float) -> void:
	if SaveManager.motion() >= 0.5:
		_t += delta
	queue_redraw()


func _draw() -> void:
	var art_size := Vector2(BACKDROP.get_size())
	var scale_factor := maxf(size.x / art_size.x, size.y / art_size.y)
	var dimensions := art_size * scale_factor
	var origin := (size - dimensions) * 0.5
	draw_texture_rect(BACKDROP, Rect2(origin, dimensions), false)
	# Quiet menu atmosphere without a framed panel over the city.
	for i in range(64):
		var strength := 0.35 * sin(float(i) / 63.0 * PI)
		var left := floorf(size.x * float(i) / 64.0)
		var right := floorf(size.x * float(i + 1) / 64.0)
		draw_rect(Rect2(left, 0, right - left, size.y), Color(0.028, 0.018, 0.06, strength))
	var at := origin + dimensions * Vector2(0.798, 0.928)
	var unit := dimensions.x / 576.0
	var cell := int(_t * 3.0) % 6
	draw_texture_rect_region(_alien, Rect2(at - Vector2(16, 28) * unit, Vector2.ONE * 32 * unit),
		Rect2(cell * 32, 0, 32, 32), Color8(192, 175, 214))
	for i in range(14):
		var p := Vector2(fposmod(float(i) * 0.137 + 0.48, 0.93), fposmod(float(i) * 0.093, 0.33)) * size
		var brightness := 0.18 + 0.16 * sin(_t * 0.55 + float(i) * 2.1)
		draw_rect(Rect2(p.round(), Vector2(2, 2)), Color(0.8, 0.74, 1.0, brightness))
	var meteor := fposmod(_t + 14.0, 22.0)
	if meteor < 1.7 and SaveManager.motion() >= 0.5:
		var head := Vector2(0.80, 0.08).lerp(Vector2(0.65, 0.29), meteor / 1.7) * size
		for i in range(24):
			var f := float(i) / 24.0
			var p := head + Vector2(75, -60) * f
			draw_rect(Rect2(p.round(), Vector2(2, 2)), Color(0.94, 0.82, 0.60, (1.0 - f) * 0.6))
