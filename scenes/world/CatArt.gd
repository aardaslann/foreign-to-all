extends Object

# The cats.
#
# They are on the steps, the wall, the stool, the car roof. They are the only
# inhabitants completely at ease, and the alien notices that before it notices
# anything else about a city.
#
# This drawing was written for Istanbul, where the cats are the point, and the
# other fourteen cities that have one were making do with a much cruder shape
# in CityArt. Two renderers for one animal is exactly the parallel version this
# project forbids, so the good one won and CityArt.cat is gone. Every cat in
# the game is drawn here and every one of them can be sat down next to.
#
# Two poses, because a street with three identical cats reads as wallpaper:
#   0 - loaf. Paws folded under, tail wrapped round, eyes shut to a line.
#   1 - sitting upright, tail laid out flat, watching you and not caring.
# Both breathe. The loaf blinks. Neither moves out of the way.
#
# `purr` is 0 while nobody is touching it and rises to 1 while somebody is:
# the breathing goes quick and shallow, the tail sweeps instead of flicking,
# and a sitting cat shuts its eyes, which a sitting cat only does for you.

const COATS := [
	Color(0.278, 0.235, 0.196),   # brown tabby, the default street cat
	Color(0.376, 0.353, 0.325),   # grey tabby
	Color(0.847, 0.788, 0.678),   # ginger-cream
]


static func coat(i: int) -> Color:
	return COATS[posmod(i, COATS.size())]


static func draw_cat(ci: CanvasItem, x: float, y: float, pose: int = 0,
		coat_i: int = 0, t: float = 0.0, purr: float = 0.0) -> void:
	var fur: Color = coat(coat_i)
	var dark: Color = fur.darkened(0.32)
	var pale: Color = fur.lightened(0.22)
	# A cat being stroked breathes about three times as fast, and deeper.
	var rate: float = 1.05 + purr * 2.6
	var breathe: float = sin(t * rate + x * 0.03) * (0.9 + purr * 0.7)

	# Contact shadow - without it a cat floats
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 24, y + 1), Vector2(x + 22, y + 1),
		Vector2(x + 18, y + 5), Vector2(x - 20, y + 5),
	]), Color(0, 0, 0, 0.20))

	if pose == 1:
		_draw_cat_sitting(ci, x, y, fur, dark, pale, breathe, t, purr)
		return
	_draw_cat_loaf(ci, x, y, fur, dark, pale, breathe, t, purr)


static func _draw_cat_loaf(ci: CanvasItem, x: float, y: float, fur: Color,
		dark: Color, pale: Color, breathe: float, t: float, purr: float) -> void:
	# Tail comes round the front and stops exactly at the paws. Being stroked
	# lifts the tip and waves it, which is the only part of a loaf that moves.
	var tip: float = sin(t * 5.2 + x * 0.04) * 5.0 * purr
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 21, y), Vector2(x - 24, y - 5), Vector2(x - 16, y - 7),
		Vector2(x + 6, y - 4 - tip), Vector2(x + 7, y - tip), Vector2(x - 12, y - 2),
	]), dark)
	# Body: a loaf is a dome, not a box
	var b: float = breathe
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 22, y), Vector2(x - 21, y - 9 - b), Vector2(x - 14, y - 15 - b),
		Vector2(x - 2, y - 17 - b), Vector2(x + 10, y - 15 - b),
		Vector2(x + 17, y - 10 - b), Vector2(x + 18, y),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 14, y - 15 - b), Vector2(x - 2, y - 17 - b), Vector2(x + 2, y - 12),
		Vector2(x - 12, y - 10),
	]), pale)
	for s in range(3):
		var sx: float = x - 12.0 + float(s) * 9.0
		ci.draw_rect(Rect2(sx, y - 14.0 - b, 2.0, 9.0), dark)
	# Head, tucked down into the shoulders the way a loafing cat holds it
	var hx: float = x + 15.0
	var hy: float = y - 19.0 - b * 0.5
	ci.draw_circle(Vector2(hx, hy), 8.5, fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx - 8, hy - 4), Vector2(hx - 5, hy - 13), Vector2(hx - 1, hy - 6),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx - 8, hy - 5), Vector2(hx - 6, hy - 11), Vector2(hx - 3, hy - 6),
	]), Color(0.62, 0.42, 0.44))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx + 2, hy - 6), Vector2(hx + 6, hy - 13), Vector2(hx + 8, hy - 4),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx + 3, hy - 6), Vector2(hx + 6, hy - 11), Vector2(hx + 7, hy - 5),
	]), Color(0.62, 0.42, 0.44))
	# Eyes shut to a line, opening for a moment now and then
	var blink: float = sin(t * 0.42 + x * 0.05)
	if blink > 0.93 and purr <= 0.01:
		ci.draw_circle(Vector2(hx - 3.0, hy - 1.0), 1.8, Color(0.78, 0.82, 0.42))
		ci.draw_circle(Vector2(hx + 4.0, hy - 1.0), 1.8, Color(0.78, 0.82, 0.42))
	else:
		ci.draw_rect(Rect2(hx - 5.0, hy - 1.5, 4.0, 1.4), dark)
		ci.draw_rect(Rect2(hx + 2.0, hy - 1.5, 4.0, 1.4), dark)
	ci.draw_rect(Rect2(hx + 6.0, hy + 2.0, 3.0, 1.2), Color(0.72, 0.52, 0.52))



static func _draw_cat_sitting(ci: CanvasItem, x: float, y: float, fur: Color,
		dark: Color, pale: Color, breathe: float, t: float, purr: float) -> void:
	# Tail laid out flat along the ground, tip flicking
	var flick: float = sin(t * (1.9 + purr * 3.4) + x) * (3.0 + purr * 5.0)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 8, y), Vector2(x - 26, y - 3), Vector2(x - 30, y - 5 + flick),
		Vector2(x - 29, y - 1 + flick), Vector2(x - 24, y + 1), Vector2(x - 8, y + 2),
	]), dark)
	# Haunch, then the upright chest
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 12, y), Vector2(x - 13, y - 12), Vector2(x - 4, y - 16),
		Vector2(x + 6, y - 13), Vector2(x + 8, y),
	]), fur)
	var b: float = breathe
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x + 1, y), Vector2(x + 2, y - 20 - b), Vector2(x + 8, y - 25 - b),
		Vector2(x + 14, y - 21 - b), Vector2(x + 13, y),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x + 4, y - 20 - b), Vector2(x + 11, y - 22 - b),
		Vector2(x + 11, y - 6), Vector2(x + 5, y - 6),
	]), pale)
	# Front legs, straight down, paws together
	ci.draw_rect(Rect2(x + 3.0, y - 8.0, 3.5, 8.0), fur)
	ci.draw_rect(Rect2(x + 9.0, y - 8.0, 3.5, 8.0), fur)
	# Head up, watching, entirely unbothered
	var hx: float = x + 8.0
	var hy: float = y - 31.0 - b
	ci.draw_circle(Vector2(hx, hy), 8.0, fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx - 8, hy - 3), Vector2(hx - 6, hy - 13), Vector2(hx - 1, hy - 6),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx + 1, hy - 6), Vector2(hx + 6, hy - 13), Vector2(hx + 8, hy - 3),
	]), fur)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx - 7, hy - 4), Vector2(hx - 5, hy - 11), Vector2(hx - 2, hy - 6),
	]), Color(0.62, 0.42, 0.44))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(hx + 2, hy - 6), Vector2(hx + 5, hy - 11), Vector2(hx + 7, hy - 4),
	]), Color(0.62, 0.42, 0.44))
	# Pupils narrow in the morning and open at dusk, like the real thing
	if purr > 0.01:
		# Shut. A sitting cat watches everything; it closes its eyes for you.
		ci.draw_rect(Rect2(hx - 5.5, hy - 1.6, 4.4, 1.5), dark)
		ci.draw_rect(Rect2(hx + 1.4, hy - 1.6, 4.4, 1.5), dark)
	else:
		var pw: float = 1.2 if GameState.is_morning() else 2.4
		ci.draw_circle(Vector2(hx - 3.5, hy - 1.0), 2.4, Color(0.82, 0.86, 0.44))
		ci.draw_circle(Vector2(hx + 3.5, hy - 1.0), 2.4, Color(0.82, 0.86, 0.44))
		ci.draw_rect(Rect2(hx - 3.5 - pw * 0.5, hy - 3.0, pw, 4.0),
			Color(0.06, 0.06, 0.07))
		ci.draw_rect(Rect2(hx + 3.5 - pw * 0.5, hy - 3.0, pw, 4.0),
			Color(0.06, 0.06, 0.07))
	ci.draw_rect(Rect2(hx - 1.5, hy + 2.0, 3.0, 1.4), Color(0.72, 0.52, 0.52))


# ══ The han ═══════════════════════════════════════════════════════════════════
# Through the gate. After the netted lane this must read as a change of
# pressure: a rectangle of open sky, and quiet.
