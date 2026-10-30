extends Node2D

# The city, dressed for the day it invited you to.
#
# It goes up when the friendship completes and comes down when the walk
# through it is over - so the decorations appear because somebody asked you,
# not on a calendar you cannot see. Story.holiday_on() owns that.
#
# Attached to every street by the Interactables autoload, drawn just above
# the plate and below everything that stands on it, so it dresses the city
# rather than covering it.
#
# Every one of these is the real thing. Bavarian blue-and-white diamonds in
# Berlin, because Oktoberfest is Bavarian and that is the whole point of it;
# kusudama down Kappabashi; papel picado and a marigold path in Coyoacan.

const BUNT_Y := 268.0        # where a strung line sits on the plate
const PLATE_W := 1152.0


func _draw() -> void:
	var city: String = GameState.city
	if not Story.holiday_on(city):
		return
	match city:
		"berlin":   _bunting([Color8(255, 255, 255), Color8(58, 122, 196)], 46.0, true)
		"london":   _sparks()
		"paris":    _bunting([Color8(0, 85, 164), Color8(255, 255, 255),
			Color8(239, 65, 53)], 42.0, false)
		"moscow":   _ribbons()
		"istanbul": _lights()
		"mumbai":   _marigold_strings()
		"tokyo":    _kusudama()
		"mexico":   _papel_picado()
		_: pass


# A strung line with pennants on it. `diamond` gives Bavaria its lozenges
# instead of triangles, which is the difference between a Wiesn and a fete.
func _bunting(cols: Array, step: float, diamond: bool) -> void:
	var y: float = BUNT_Y
	draw_line(Vector2(0.0, y - 6.0), Vector2(PLATE_W, y + 2.0),
		Color(0.12, 0.10, 0.14, 0.7), 1.5)
	var i: int = 0
	var x: float = 10.0
	while x < PLATE_W:
		var sag: float = sin(x / PLATE_W * PI) * 8.0
		var c: Color = cols[i % cols.size()]
		var top: float = y - 6.0 + (x / PLATE_W) * 8.0 + sag
		if diamond:
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, top), Vector2(x + step * 0.34, top + 11.0),
				Vector2(x, top + 22.0), Vector2(x - step * 0.34, top + 11.0),
			]), c)
		else:
			draw_colored_polygon(PackedVector2Array([
				Vector2(x - step * 0.3, top), Vector2(x + step * 0.3, top),
				Vector2(x, top + 20.0),
			]), c)
		i += 1
		x += step


# Bonfire Night is not decorated. It is dark, and things go off over the
# rooftops two streets away all evening.
func _sparks() -> void:
	var t: float = float(Time.get_ticks_msec()) * 0.001
	for i in range(7):
		var seed_f: float = float(i) * 97.3
		var life: float = fposmod(t * 0.45 + seed_f, 1.0)
		if life > 0.55:
			continue
		var cx: float = fposmod(seed_f * 13.7, PLATE_W)
		var cy: float = 60.0 + fposmod(seed_f * 7.1, 130.0)
		var r: float = life * 78.0
		var a: float = (1.0 - life / 0.55) * 0.85
		var col: Color = [Color8(255, 196, 92), Color8(255, 120, 96),
			Color8(160, 220, 255)][i % 3]
		for k in range(14):
			var ang: float = TAU * float(k) / 14.0
			draw_circle(Vector2(cx + cos(ang) * r, cy + sin(ang) * r * 0.8),
				1.8, Color(col.r, col.g, col.b, a))


# Maslenitsa: ribbons tied to everything, in the colours of a printed shawl.
func _ribbons() -> void:
	var cols := [Color8(214, 62, 58), Color8(240, 196, 72),
		Color8(72, 132, 196), Color8(240, 240, 236)]
	var x: float = 24.0
	var i: int = 0
	while x < PLATE_W:
		var c: Color = cols[i % cols.size()]
		var h: float = 26.0 + float(i % 3) * 7.0
		draw_rect(Rect2(x, BUNT_Y - 4.0, 3.0, h), c)
		draw_rect(Rect2(x + 4.0, BUNT_Y - 4.0, 2.0, h * 0.8), c.darkened(0.25))
		i += 1
		x += 38.0


# Bayram: strings of small lamps between the buildings, the way a mahya is
# strung between minarets, only lower and cheaper and everywhere.
func _lights() -> void:
	var y: float = BUNT_Y - 10.0
	var t: float = float(Time.get_ticks_msec()) * 0.001
	draw_line(Vector2(0.0, y), Vector2(PLATE_W, y + 6.0),
		Color(0.14, 0.12, 0.10, 0.65), 1.2)
	var x: float = 16.0
	var i: int = 0
	while x < PLATE_W:
		var yy: float = y + (x / PLATE_W) * 6.0
		var glow: float = 0.55 + 0.45 * sin(t * 2.2 + float(i) * 0.9)
		var c := Color(1.0, 0.86, 0.52, glow)
		draw_circle(Vector2(x, yy + 5.0), 3.4, Color(c.r, c.g, c.b, glow * 0.35))
		draw_circle(Vector2(x, yy + 5.0), 1.7, c)
		i += 1
		x += 26.0


# Ganesh Chaturthi: marigold ropes across the lane and the pandal's lights.
func _marigold_strings() -> void:
	for row in range(2):
		var y: float = BUNT_Y - 22.0 + float(row) * 16.0
		var x: float = 8.0
		var i: int = 0
		while x < PLATE_W:
			var sag: float = sin(x / PLATE_W * PI * 2.0) * 6.0
			var c: Color = Color8(240, 140, 34) if (i % 3) != 0 \
				else Color8(226, 60, 46)
			draw_circle(Vector2(x, y + sag), 3.2, c)
			draw_circle(Vector2(x, y + sag - 0.8), 1.6, c.lightened(0.30))
			i += 1
			x += 9.0
	# the pandal, glowing at the end of the lane
	var t: float = float(Time.get_ticks_msec()) * 0.001
	for k in range(5):
		var a: float = (0.16 - float(k) * 0.025) * (0.8 + 0.2 * sin(t * 1.6))
		draw_circle(Vector2(PLATE_W * 0.82, 250.0), 40.0 + float(k) * 22.0,
			Color(1.0, 0.78, 0.36, a))


# Tanabata: paper balls with streamers, end to end down Kappabashi.
func _kusudama() -> void:
	var cols := [Color8(226, 74, 96), Color8(240, 190, 70),
		Color8(86, 158, 210), Color8(120, 190, 130), Color8(238, 238, 232)]
	var t: float = float(Time.get_ticks_msec()) * 0.001
	var x: float = 44.0
	var i: int = 0
	while x < PLATE_W:
		var c: Color = cols[i % cols.size()]
		var sway: float = sin(t * 0.8 + float(i) * 1.3) * 2.5
		var top: float = BUNT_Y - 34.0
		draw_circle(Vector2(x + sway, top), 9.0, c)
		draw_circle(Vector2(x + sway - 2.5, top - 2.5), 3.5, c.lightened(0.30))
		# the streamers under it, which is most of what you actually see
		for s in range(5):
			var sx: float = x + sway - 7.0 + float(s) * 3.5
			draw_rect(Rect2(sx, top + 8.0, 2.0, 30.0 + float((i + s) % 3) * 8.0),
				c.darkened(0.10 + float(s) * 0.05))
		i += 1
		x += 58.0


# Dia de Muertos: papel picado over the street, and a path of cempasuchil
# petals laid along the pavement so they can find the way in.
func _papel_picado() -> void:
	var cols := [Color8(238, 96, 156), Color8(250, 176, 46),
		Color8(96, 190, 226), Color8(146, 206, 96), Color8(236, 82, 74)]
	var x: float = 0.0
	var i: int = 0
	while x < PLATE_W:
		var c: Color = cols[i % cols.size()]
		var sag: float = sin(x / PLATE_W * PI * 3.0) * 5.0
		var top: float = BUNT_Y - 28.0 + sag
		draw_rect(Rect2(x, top, 54.0, 34.0), c)
		# the cut-out pattern: punched holes, which is what makes it picado
		for r in range(3):
			for q in range(4):
				draw_rect(Rect2(x + 8.0 + float(q) * 11.0,
					top + 6.0 + float(r) * 9.0, 5.0, 5.0),
					Color(0.06, 0.05, 0.10, 0.55))
		i += 1
		x += 58.0
	# the petal path, laid from the doorway inward
	for k in range(90):
		var px: float = 40.0 + float(k) * 12.0
		if px > PLATE_W:
			break
		var py: float = 348.0 + sin(float(k) * 0.7) * 3.0
		draw_circle(Vector2(px, py), 2.4, Color8(244, 138, 26))
		draw_circle(Vector2(px + 5.0, py + 4.0), 1.8, Color8(226, 106, 20))
