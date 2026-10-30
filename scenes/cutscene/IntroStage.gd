extends Node2D

const ORBIT := preload("res://art/cutscene/intro/orbit.png")
const ROOFTOPS := preload("res://art/cutscene/intro/berlin-rooftops.png")
const POD := preload("res://art/cutscene/intro/pod-flight.png")
const KIEZ := preload("res://art/environments/scenes/Kiez-refined.png")
const SMOKE := preload("res://art/world/props/smoke.png")
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")
const FRAME := Vector2(1152, 648)
const INK := Color8(5, 9, 12)
const PAPER := Color8(235, 234, 213)
const DAWN := Color8(116, 126, 164)

var elapsed := 0.0
var reduced_motion := false
var _alien: Dictionary = {}
var _lukas: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_alien = CHAR.alien_look()
	_lukas = ROSTER.look("lukas", "berlin")


func _ramp(a: float, b: float, t: float) -> float:
	return smoothstep(a, b, t)


func _window(a: float, b: float, c: float, d: float) -> float:
	return _ramp(a, b, elapsed) * (1.0 - _ramp(c, d, elapsed))


func _plate(texture: Texture2D, zoom: float, focus: Vector2, tint: Color = Color.WHITE) -> void:
	draw_texture_rect(texture, Rect2(FRAME * 0.5 - focus * zoom, FRAME * zoom), false, tint)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, FRAME), INK)
	if elapsed < 7.0:
		_orbit()
	elif elapsed < 12.15:
		_descent()
	else:
		_ground()
	# Short dips into darkness connect the change in scale without a flash.
	var darkness := 1.0 - _ramp(0.0, 1.2, elapsed)
	for cut: float in [7.0, 12.15]:
		darkness = maxf(darkness, 1.0 - smoothstep(0.0, 0.42, absf(elapsed - cut)))
	if darkness > 0.0:
		draw_rect(Rect2(Vector2.ZERO, FRAME), Color(INK, darkness))
	_titles()


func _orbit() -> void:
	var progress := _ramp(0.0, 7.0, elapsed)
	var zoom := 1.035 if reduced_motion else lerpf(1.02, 1.11, progress)
	_plate(ORBIT, zoom, Vector2(570, 332))
	var travel := _ramp(0.6, 7.1, elapsed)
	var at := Vector2(954, 163).lerp(Vector2(433, 412), travel)
	var width := lerpf(132.0, 52.0, travel)
	if elapsed > 3.8:
		_trail(at, Vector2(0.9, -0.43), _ramp(3.8, 6.5, elapsed), 110.0)
	_flying_pod(at, width, -0.12 + travel * 0.16)


func _flying_pod(at: Vector2, width: float, angle: float) -> void:
	draw_set_transform(at.round(), angle)
	var dimensions := Vector2(width, width * float(POD.get_height()) / float(POD.get_width()))
	draw_texture_rect(POD, Rect2(-dimensions * 0.5, dimensions), false)
	draw_set_transform(Vector2.ZERO)


func _trail(at: Vector2, direction: Vector2, strength: float, length_px: float) -> void:
	for i in range(36, -1, -1):
		var f := float(i) / 36.0
		var jitter := 0.0 if reduced_motion else sin(float(i) * 4.3 + elapsed * 13.0) * f * 4.0
		var p := at + direction * f * length_px + Vector2(jitter, jitter)
		var width := lerpf(8.0, 1.0, f) * strength
		var color := Color8(238, 136, 71).lerp(Color8(255, 241, 199), 1.0 - f)
		color.a = (1.0 - f) * strength
		draw_rect(Rect2(p.round(), Vector2(maxf(width, 1.0), maxf(width * 0.65, 1.0))), color)


func _descent() -> void:
	var local := elapsed - 7.0
	var pan := 0.0 if reduced_motion else _ramp(0.0, 5.0, local) * 12.0
	_plate(ROOFTOPS, 1.04, Vector2(576 - pan, 324), Color8(180, 196, 210))
	var travel := clampf((local - 0.65) / 3.45, 0.0, 1.0)
	var at := Vector2(1080, 100).lerp(Vector2(235, 538), pow(travel, 1.4))
	if local >= 0.65 and local < 4.10:
		_trail(at, Vector2(0.887, -0.46), 0.95, 185.0)
		_flying_pod(at, lerpf(27.0, 12.0, travel), -0.12)
	# The falling object disappears behind the railway, not over the foreground.
	var source := Rect2(0, ROOFTOPS.get_height() * 0.70, ROOFTOPS.get_width(), ROOFTOPS.get_height() * 0.30)
	var target := Rect2(FRAME * 0.5 - Vector2(576 - pan, 324) * 1.04 + Vector2(0, FRAME.y * 0.70 * 1.04), Vector2(FRAME.x, FRAME.y * 0.30) * 1.04)
	draw_texture_rect_region(ROOFTOPS, target, source, Color8(180, 196, 210))
	if local >= 4.1:
		var settling := local - 4.1
		for i in range(13):
			var spread := float(i - 6)
			var p := Vector2(235 + spread * settling * 17, 523 - sin(float(i) * 1.7) * 8 - settling * 25)
			draw_rect(Rect2(p.round(), Vector2(3, 3)), Color(0.93, 0.66, 0.38, maxf(0.0, 0.5 - settling)))


func _screen(p: Vector2, focus: Vector2, zoom: float) -> Vector2:
	return (FRAME * 0.5 + (p - focus) * zoom).round()


func _ground() -> void:
	var t := elapsed - 12.15
	var reveal := _ramp(0.0, 6.8, t)
	var zoom := 1.45 if reduced_motion else lerpf(1.8, 1.45, reveal)
	var focus := Vector2(540, 420) if reduced_motion else Vector2(340, 425).lerp(Vector2(540, 420), reveal)
	_plate(KIEZ, zoom, focus, DAWN)
	_smoke(focus, zoom, t)
	# Blocking follows the open grass below the pod and along the market front.
	var emerge := _ramp(1.5, 4.6, t)
	var alien_at := Vector2(435, 530).lerp(Vector2(405, 598), emerge)
	var alien_act := "look" if t < 1.5 else ("walk" if t < 4.6 else "watch")
	var approach := _ramp(4.0, 7.7, t)
	var lukas_at := Vector2(855, 572).lerp(Vector2(620, 592), approach)
	var lukas_act := "watch" if t < 4.0 else ("walk" if t < 7.7 else "wave")
	if t > 9.4:
		lukas_act = "point"
	if t > 11.6:
		lukas_at = Vector2(620, 592).lerp(Vector2(855, 572), _ramp(11.6, 15.7, t))
		lukas_act = "walk"
		alien_act = "look"
	var figure_time := 0.0 if reduced_motion else t
	CHAR.draw_figure(self, _screen(lukas_at, focus, zoom), 4.0 * zoom, _lukas, lukas_act, figure_time, 3)
	CHAR.draw_figure(self, _screen(alien_at, focus, zoom), 4.0 * zoom, _alien, alien_act, figure_time)
	# Atmospheric depth stays attached to the wreck, well behind the people.
	for i in range(10):
		var age := fposmod(t * 0.36 + float(i) * 0.37, 2.3)
		var ember := Vector2(210 + float(i) * 18, 473 - age * 9)
		var alpha := (1.0 - age / 2.3) * (1.0 - _ramp(0.0, 10.0, t)) * 0.8
		draw_rect(Rect2(_screen(ember, focus, zoom), Vector2(2, 2) * zoom), Color(0.98, 0.70, 0.36, alpha))


func _smoke(focus: Vector2, zoom: float, t: float) -> void:
	for i in range(9):
		var age := fposmod((0.8 if reduced_motion else t) * 0.20 + float(i) * 0.29, 2.8)
		var at := Vector2(290 + sin(float(i) * 2.1) * 37 + age * 17, 343 - age * 36)
		var width := (23.0 + age * 14.0) * zoom
		var alpha := (1.0 - age / 2.8) * 0.28 * (1.0 - _ramp(9.0, 16.0, t))
		draw_texture_rect_region(SMOKE, Rect2(_screen(at, focus, zoom) - Vector2.ONE * width * 0.5, Vector2.ONE * width), Rect2((i % 3) * 22, 0, 22, 22), Color(0.7, 0.8, 0.83, alpha))


func _text(line: String, at: Vector2, font_size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, at + Vector2(1, 2), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.01, 0.025, 0.03, color.a * 0.9))
	draw_string(font, at, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _titles() -> void:
	var location := _window(7.7, 8.5, 10.4, 11.0)
	if location > 0.0:
		_text("Berlin", Vector2(54, 83), 32, Color(PAPER, location))
		_text("04:12", Vector2(56, 109), 16, Color(0.73, 0.82, 0.82, location))
	var connection := _window(20.0, 21.0, 22.7, 23.5)
	if connection > 0.0:
		_text("you are not alone", Vector2(58, 564), 24, Color(PAPER, connection))
	var chapter := _window(24.0, 25.0, 27.5, 28.0)
	if chapter > 0.0:
		_text("CHAPTER I", Vector2(58, 508), 14, Color(0.68, 0.84, 0.8, chapter))
		_text("Berlin, Germany", Vector2(54, 553), 38, Color(PAPER, chapter))
