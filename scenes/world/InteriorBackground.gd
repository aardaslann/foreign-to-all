extends Node2D

# One script, six rooms. `room` picks the dressing; the shell, floor and
# lighting come from InteriorArt so every interior in the game shares its
# architecture and only differs where it should.

@export var room: String = "exchange"

const IA := preload("res://scenes/world/InteriorArt.gd")

# Hoisted out of the draw calls. Subscripting an inline array literal —
# `var hue := [Color(...), ...][i]` — yields Variant, and ':=' cannot infer a
# type from it, so the scene refuses to compile. A named const fixes the type
# and reads better at the call site.
const BOTTLE_HUES := [
	Color(0.30, 0.50, 0.32), Color(0.52, 0.30, 0.26),
	Color(0.36, 0.32, 0.52), Color(0.60, 0.46, 0.20),
]
const UMBRELLA_HUES := [
	Color(0.28, 0.30, 0.44), Color(0.44, 0.24, 0.24),
	Color(0.24, 0.36, 0.30),
]

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	# Paint the void before anything else. IA.shell() does this too, but only
	# for rooms that remember to call it — and an interior that forgets shows
	# the bare window colour where its floor should be. Belt and braces.
	draw_rect(Rect2(-IA.EXT, -IA.EXT, IA.VW + IA.EXT * 2.0, IA.VH + IA.EXT * 2.0),
		IA.C_VOID)
	match room:
		"exchange":   _dress_exchange()
		"police":     _dress_police()
		"hospital":   _dress_hospital()
		"restaurant": _dress_restaurant()
		"ubahn":      _dress_ubahn()
		"airport":    _dress_airport()
		_:            _dress_exchange()


# ── Wechselstube — money exchange ────────────────────────────────────────────
# A booth barely wider than a corridor. Everything of value is behind glass.

func _dress_exchange() -> void:
	var wall  := Color(0.180, 0.140, 0.105)
	var trim  := Color(0.240, 0.180, 0.115)
	var warm  := Color(0.95, 0.78, 0.42)
	IA.shell(self, wall, trim, Color(0.22, 0.17, 0.12))
	IA.floor_tiles(self, WorldArt.TILE_WOOD)

	IA.ceiling_light(self, 380.0, warm, _t)
	IA.ceiling_light(self, 760.0, warm, _t)

	# Rate board — currencies you can read, numbers you cannot
	var bx := 604.0
	draw_rect(Rect2(bx - 6, 84, 396, 132), Color(0.10, 0.08, 0.06))
	draw_rect(Rect2(bx, 90, 384, 120), Color(0.055, 0.045, 0.040))
	var syms := ["€", "£", "₺"]
	for i in range(3):
		var ry := 104.0 + float(i) * 36.0
		draw_string(ThemeDB.fallback_font, Vector2(bx + 18, ry + 16), syms[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.92, 0.80, 0.42))
		# Flickering split-flap digits
		for d in range(5):
			var dx := bx + 96.0 + float(d) * 44.0
			var lit := ((i * 3 + d + int(_t * 0.8)) % 5) != 0
			draw_rect(Rect2(dx, ry, 32, 22),
				Color(0.86, 0.72, 0.30) if lit else Color(0.20, 0.17, 0.12))
			draw_rect(Rect2(dx, ry + 10, 32, 1), Color(0, 0, 0, 0.4))

	IA.window(self, 120, 96, 200, 128, Color(0.30, 0.22, 0.14))

	# Counter + security glass
	IA.counter(self, 470, 236, 480, 70,
		Color(0.30, 0.20, 0.12), Color(0.42, 0.30, 0.16))
	IA.glass_screen(self, 470, 120, 480, 116, Color(0.34, 0.28, 0.18))
	# Cash trays and a coin dish on the counter top
	draw_rect(Rect2(520, 214, 90, 14), Color(0.16, 0.13, 0.10))
	draw_rect(Rect2(524, 216, 82, 10), Color(0.24, 0.20, 0.14))
	draw_circle(Vector2(880, 222), 13.0, Color(0.20, 0.16, 0.11))
	draw_circle(Vector2(880, 221), 10.0, Color(0.55, 0.44, 0.20))

	IA.notice(self, 210, 250, 76, 46, Color(0.86, 0.82, 0.70), Color(0.25, 0.2, 0.15))
	IA.plant(self, 1046, 268, Color(0.42, 0.26, 0.16))
	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.26, 0.18, 0.11))


# ── Polizeiwache — police station ────────────────────────────────────────────
# Cool, orderly, and entirely indifferent to how long you have been standing
# there. Found property lives behind the desk.

func _dress_police() -> void:
	var wall := Color(0.135, 0.145, 0.180)
	var trim := Color(0.180, 0.195, 0.240)
	var cool := Color(0.72, 0.82, 0.95)
	IA.shell(self, wall, trim, Color(0.16, 0.18, 0.23))
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.7, 0.8, 0.95))

	IA.strip_light(self, 180, 260, cool, _t)
	IA.strip_light(self, 620, 300, cool, _t)

	# The Zelle. You are not in it, and you can see how easily you could be.
	IA.cell_bars(self, 930, 156, 168, 150, Color(0.33, 0.34, 0.38))

	# Wall crest — a shield in police green and white
	var cx := 300.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 34, 76), Vector2(cx + 34, 76),
		Vector2(cx + 30, 140), Vector2(cx, 162), Vector2(cx - 30, 140),
	]), Color(0.10, 0.28, 0.18))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 26, 84), Vector2(cx + 26, 84),
		Vector2(cx + 23, 136), Vector2(cx, 152), Vector2(cx - 23, 136),
	]), Color(0.14, 0.42, 0.26))
	draw_rect(Rect2(cx - 12, 100, 24, 26), Color(0.88, 0.90, 0.86))

	# Notice board of things you cannot read
	draw_rect(Rect2(676, 74, 300, 150), Color(0.14, 0.11, 0.08))
	draw_rect(Rect2(682, 80, 288, 138), Color(0.20, 0.16, 0.11))
	IA.notice(self, 696, 92, 78, 54, Color(0.88, 0.85, 0.76), Color(0.2, 0.2, 0.3))
	IA.notice(self, 790, 92, 78, 54, Color(0.84, 0.80, 0.72), Color(0.2, 0.2, 0.3))
	IA.notice(self, 884, 92, 72, 54, Color(0.90, 0.86, 0.78), Color(0.2, 0.2, 0.3))
	IA.notice(self, 700, 158, 110, 46, Color(0.86, 0.83, 0.74), Color(0.2, 0.2, 0.3))
	IA.notice(self, 826, 158, 130, 46, Color(0.88, 0.84, 0.75), Color(0.2, 0.2, 0.3))

	# High duty counter with a screen and a numbered-ticket dispenser
	IA.counter(self, 420, 232, 470, 74,
		Color(0.20, 0.22, 0.28), Color(0.30, 0.33, 0.40))
	IA.glass_screen(self, 420, 132, 470, 100, Color(0.26, 0.30, 0.38))
	draw_rect(Rect2(452, 206, 54, 22), Color(0.10, 0.12, 0.16))
	draw_rect(Rect2(456, 210, 46, 14), Color(0.30, 0.62, 0.52, 0.8))
	# Evidence shelf behind the glass
	draw_rect(Rect2(940, 150, 150, 156), Color(0.12, 0.13, 0.17))
	for r in range(3):
		draw_rect(Rect2(944, 158.0 + float(r) * 50.0, 142, 6), Color(0.20, 0.22, 0.28))
		for b in range(3):
			draw_rect(Rect2(952.0 + float(b) * 44.0, 168.0 + float(r) * 50.0, 34, 32),
				Color(0.30, 0.32, 0.30, 0.65))

	IA.bench_run(self, 150, 430, 3, Color(0.24, 0.26, 0.32), Color(0.20, 0.30, 0.42))
	IA.plant(self, 1040, 300, Color(0.26, 0.30, 0.36))
	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.22, 0.26, 0.32))


# ── Klinikum — hospital ──────────────────────────────────────────────────────
# Pale, clean, faintly humming. The one place that will touch you without
# asking you to explain yourself first.

func _dress_hospital() -> void:
	var wall := Color(0.150, 0.185, 0.180)
	var trim := Color(0.205, 0.245, 0.235)
	var cool := Color(0.80, 0.94, 0.90)
	IA.shell(self, wall, trim, Color(0.17, 0.21, 0.20))
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK_B)
	IA.floor_sheen(self, Color(0.85, 0.95, 0.92))

	IA.strip_light(self, 120, 300, cool, _t)
	IA.strip_light(self, 520, 300, cool, _t)
	IA.strip_light(self, 900, 200, cool, _t)

	# Two bays with the curtains half drawn. A Klinik is not a counter in a
	# room — it is beds you can see the shape of somebody in.
	IA.hospital_bay(self, 620, 300, Color(0.28, 0.44, 0.42), Color(0.90, 0.93, 0.92))
	IA.hospital_bay(self, 820, 300, Color(0.28, 0.44, 0.42), Color(0.90, 0.93, 0.92))

	# Wall tiling to dado height
	for i in range(int(1152.0 / 48.0)):
		for r in range(3):
			draw_rect(Rect2(float(i) * 48.0 + 2, 176.0 + float(r) * 40.0, 44, 36),
				Color(0.185, 0.225, 0.220))

	# Green cross
	draw_rect(Rect2(560, 74, 30, 82), Color(0.20, 0.72, 0.42))
	draw_rect(Rect2(534, 100, 82, 30), Color(0.20, 0.72, 0.42))
	draw_rect(Rect2(566, 80, 8, 70), Color(0.40, 0.86, 0.58, 0.6))

	# Reception with a computer and a hand-sanitiser column
	IA.counter(self, 640, 240, 400, 66,
		Color(0.22, 0.30, 0.30), Color(0.34, 0.44, 0.42))
	draw_rect(Rect2(676, 200, 60, 30), Color(0.10, 0.13, 0.14))
	draw_rect(Rect2(680, 204, 52, 22), Color(0.36, 0.70, 0.62, 0.75))
	draw_rect(Rect2(1000, 196, 16, 34), Color(0.26, 0.34, 0.34))
	draw_rect(Rect2(996, 190, 24, 8), Color(0.36, 0.46, 0.46))

	# Curtained treatment bays — the curtains are the only warm thing here
	for i in range(2):
		var bx := 96.0 + float(i) * 210.0
		draw_rect(Rect2(bx, 150, 180, 6), Color(0.30, 0.34, 0.34))
		for f in range(9):
			var fx := bx + 4.0 + float(f) * 19.0
			var shade := 0.86 if f % 2 == 0 else 1.0
			draw_rect(Rect2(fx, 156, 17, 148),
				Color(0.30 * shade, 0.52 * shade, 0.50 * shade))
		draw_rect(Rect2(bx, 150, 180, 4), Color(0.38, 0.44, 0.44))

	IA.bench_run(self, 300, 448, 4, Color(0.26, 0.32, 0.32), Color(0.30, 0.52, 0.50))
	IA.plant(self, 1058, 300, Color(0.30, 0.38, 0.36))
	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.26, 0.34, 0.33))


# ── Gaststätte — restaurant ──────────────────────────────────────────────────
# Dark wood, brass, and the smell of something you have no word for.

func _dress_restaurant() -> void:
	var wall := Color(0.155, 0.105, 0.085)
	var trim := Color(0.235, 0.160, 0.100)
	var warm := Color(0.96, 0.76, 0.40)
	IA.shell(self, wall, trim, Color(0.19, 0.13, 0.10))
	IA.floor_tiles(self, WorldArt.TILE_WOOD)

	IA.ceiling_light(self, 250.0, warm, _t, 44.0)
	IA.ceiling_light(self, 620.0, warm, _t, 44.0)
	IA.ceiling_light(self, 980.0, warm, _t, 44.0)

	IA.window(self, 92, 92, 180, 120, Color(0.28, 0.19, 0.12))

	# Bar back: bottle shelves, mirror strip, taps
	draw_rect(Rect2(560, 74, 470, 150), Color(0.115, 0.078, 0.058))
	draw_rect(Rect2(568, 82, 454, 134), Color(0.085, 0.058, 0.045))
	for r in range(3):
		var sy := 96.0 + float(r) * 44.0
		draw_rect(Rect2(576, sy + 30, 438, 5), Color(0.24, 0.17, 0.10))
		for b in range(14):
			var bx := 584.0 + float(b) * 31.0
			var hue: Color = BOTTLE_HUES[(b + r) % BOTTLE_HUES.size()]
			draw_rect(Rect2(bx, sy + 6, 9, 24), hue)
			draw_rect(Rect2(bx + 2, sy, 5, 8), hue.darkened(0.3))
	IA.counter(self, 560, 236, 470, 70,
		Color(0.26, 0.17, 0.10), Color(0.40, 0.27, 0.14))
	# Beer taps
	for i in range(3):
		var tx := 700.0 + float(i) * 46.0
		draw_rect(Rect2(tx, 198, 7, 32), Color(0.62, 0.52, 0.24))
		draw_rect(Rect2(tx - 5, 194, 17, 8), Color(0.72, 0.60, 0.28))

	# Chalkboard menu — glyph scrawl
	draw_rect(Rect2(310, 96, 190, 122), Color(0.14, 0.11, 0.08))
	draw_rect(Rect2(318, 104, 174, 106), Color(0.08, 0.09, 0.08))
	for i in range(5):
		var ly := 116.0 + float(i) * 19.0
		draw_rect(Rect2(328, ly, 100.0 - float((i * 13) % 40), 3),
			Color(0.80, 0.82, 0.74, 0.55))
		draw_rect(Rect2(448, ly, 26, 3), Color(0.82, 0.70, 0.34, 0.6))

	# Tables with cloths and a candle each
	for t_i in range(3):
		var tx := 190.0 + float(t_i) * 300.0
		var ty := 430.0 + float(t_i % 2) * 46.0
		draw_rect(Rect2(tx - 62, ty + 26, 128, 12), Color(0, 0, 0, 0.22))
		draw_rect(Rect2(tx - 58, ty - 26, 120, 62), Color(0.60, 0.24, 0.20))
		draw_rect(Rect2(tx - 52, ty - 20, 108, 50), Color(0.72, 0.32, 0.26))
		draw_rect(Rect2(tx - 46, ty - 14, 96, 38), Color(0.66, 0.28, 0.23))
		# Candle
		var fl := 0.8 + 0.2 * sin(_t * 6.0 + float(t_i))
		draw_rect(Rect2(tx - 4, ty - 14, 8, 14), Color(0.88, 0.84, 0.70))
		draw_circle(Vector2(tx, ty - 18), 9.0, Color(warm.r, warm.g, warm.b, 0.14 * fl))
		draw_circle(Vector2(tx, ty - 18), 3.0, Color(1.0, 0.88, 0.55, fl))
		# Chairs
		for s in [-1.0, 1.0]:
			draw_rect(Rect2(tx + s * 78.0 - 14, ty - 12, 28, 34), Color(0.22, 0.15, 0.09))
			draw_rect(Rect2(tx + s * 78.0 - 11, ty - 9, 22, 28), Color(0.32, 0.21, 0.12))

	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.30, 0.20, 0.12))


# ── U-Bahnhof — the platform ─────────────────────────────────────────────────
# Cream tiles, a black tunnel mouth, and a wind that arrives before the train.

func _dress_ubahn() -> void:
	var wall := Color(0.165, 0.155, 0.140)
	var trim := Color(0.215, 0.200, 0.175)
	var cool := Color(0.86, 0.88, 0.82)
	IA.shell(self, wall, trim, Color(0.19, 0.18, 0.16))

	# Signature station tiling across the back wall
	for c in range(int(1152.0 / 42.0) + 1):
		for r in range(6):
			var tint := 1.0 - float((c + r) % 3) * 0.06
			draw_rect(Rect2(float(c) * 42.0 + 2, 58.0 + float(r) * 34.0, 38, 30),
				Color(0.300 * tint, 0.278 * tint, 0.235 * tint))

	IA.strip_light(self, 90, 320, cool, _t)
	IA.strip_light(self, 520, 320, cool, _t)
	IA.strip_light(self, 940, 180, cool, _t)

	# A U-Bahn train standing with its doors open, in BVG yellow. Without it
	# the room is a tiled corridor.
	IA.train_at_platform(self, 560, 306, 548, Color(0.976, 0.812, 0.129), _t)

	# Station nameplate and the U roundel
	IA.sign(self, 420, 110, 300, 52, Color(0.10, 0.30, 0.62), Color(0.86, 0.90, 1.00), 7)
	draw_rect(Rect2(180, 104, 64, 64), Color(0.05, 0.18, 0.45))
	draw_string(ThemeDB.fallback_font, Vector2(198, 152), "U",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(0.95, 0.96, 1.0))

	# Line diagram: coloured runs with station dots
	draw_rect(Rect2(790, 96, 300, 84), Color(0.09, 0.09, 0.11))
	draw_rect(Rect2(796, 102, 288, 72), Color(0.94, 0.92, 0.86))
	var lines := [Color(0.20, 0.42, 0.78), Color(0.86, 0.42, 0.18), Color(0.24, 0.58, 0.34)]
	for i in range(3):
		var ly := 118.0 + float(i) * 22.0
		draw_rect(Rect2(808, ly, 264, 5), lines[i])
		for d in range(5):
			draw_circle(Vector2(818.0 + float(d) * 62.0, ly + 2.5), 5.0, Color(0.15, 0.15, 0.18))
			draw_circle(Vector2(818.0 + float(d) * 62.0, ly + 2.5), 3.0, Color(0.96, 0.95, 0.92))

	# Platform edge: warning strip, then the track pit and tunnel
	draw_rect(Rect2(0, 300, 1152, 6), Color(0.30, 0.28, 0.24))
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	# Yellow safety line along the platform edge
	draw_rect(Rect2(44, 318, 1064, 10), Color(0.86, 0.72, 0.18))
	for i in range(int(1064.0 / 26.0)):
		draw_rect(Rect2(48.0 + float(i) * 26.0, 318, 13, 10), Color(0.72, 0.60, 0.14))

	# Bench, bin, ticket machine cluster against the wall
	IA.bench_run(self, 220, 420, 3, Color(0.24, 0.22, 0.20), Color(0.34, 0.28, 0.18))
	draw_rect(Rect2(560, 386, 40, 60), Color(0.20, 0.20, 0.22))
	draw_rect(Rect2(556, 380, 48, 8), Color(0.28, 0.28, 0.30))
	# Fundbüro — a lit hatch in the wall, umbrellas visible behind the clerk
	draw_rect(Rect2(614, 158, 172, 148), Color(0.11, 0.10, 0.09))
	draw_rect(Rect2(622, 166, 156, 132), Color(0.175, 0.150, 0.115))
	draw_rect(Rect2(630, 174, 140, 66), Color(0.90, 0.80, 0.45, 0.16))
	for u in range(5):     # shelved umbrellas, the universal lost object
		var ux := 636.0 + float(u) * 27.0
		var uc: Color = UMBRELLA_HUES[u % UMBRELLA_HUES.size()]
		draw_rect(Rect2(ux, 186, 9, 44), uc)
		draw_rect(Rect2(ux - 2, 182, 13, 5), uc.darkened(0.3))
	draw_rect(Rect2(622, 240, 156, 6), Color(0.24, 0.20, 0.14))
	# Counter lip and the hatch opening
	draw_rect(Rect2(614, 246, 172, 16), Color(0.26, 0.21, 0.14))
	draw_rect(Rect2(614, 246, 172, 4), Color(0.36, 0.29, 0.18))
	IA.sign(self, 634, 128, 132, 24, Color(0.18, 0.32, 0.20), Color(0.86, 0.90, 0.82), 4)

	# Ticket machine
	draw_rect(Rect2(830, 352, 96, 128), Color(0.14, 0.15, 0.18))
	draw_rect(Rect2(836, 358, 84, 62), Color(0.26, 0.52, 0.46, 0.85))
	draw_rect(Rect2(842, 430, 72, 10), Color(0.30, 0.30, 0.34))
	for b in range(6):
		draw_rect(Rect2(844.0 + float(b % 3) * 26.0, 446.0 + float(b / 3) * 18.0, 20, 12),
			Color(0.34, 0.34, 0.38))

	IA.side_walls(self, wall, trim)
	# Stairs up to the street, drawn into the left wall
	draw_rect(Rect2(44, 150, 130, 156), Color(0.10, 0.10, 0.12))
	for i in range(7):
		draw_rect(Rect2(48, 160.0 + float(i) * 21.0, 122.0 - float(i) * 6.0, 12),
			Color(0.22 + float(i) * 0.012, 0.21, 0.19))


# ── Flughafen — airport departures ───────────────────────────────────────────
# Tall glass, cold light, and a board that keeps changing its mind.

func _dress_airport() -> void:
	var wall := Color(0.130, 0.140, 0.170)
	var trim := Color(0.185, 0.200, 0.240)
	var cool := Color(0.82, 0.90, 1.00)
	IA.shell(self, wall, trim, Color(0.155, 0.170, 0.205))
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK_B)
	IA.floor_sheen(self, Color(0.80, 0.88, 1.00))

	IA.strip_light(self, 60, 340, cool, _t)
	IA.strip_light(self, 440, 340, cool, _t)
	IA.strip_light(self, 820, 280, cool, _t)

	# The belt that takes your things somewhere you cannot follow
	IA.baggage_belt(self, 300, 470, 560, _t)

	# Curtain wall of glass — the runway beyond
	var morning := GameState.is_morning()
	var sky := Color(0.44, 0.62, 0.78) if morning else Color(0.085, 0.070, 0.160)
	var ground := Color(0.28, 0.34, 0.28) if morning else Color(0.055, 0.070, 0.060)
	draw_rect(Rect2(58, 58, 486, 210), Color(0.09, 0.10, 0.13))
	draw_rect(Rect2(64, 64, 474, 198), sky)
	draw_rect(Rect2(64, 206, 474, 56), ground)
	# Distant aircraft and a taxiway light run
	draw_rect(Rect2(150, 186, 150, 12), Color(0.80, 0.82, 0.86))
	draw_colored_polygon(PackedVector2Array([
		Vector2(150, 192), Vector2(120, 198), Vector2(154, 198),
	]), Color(0.72, 0.74, 0.80))
	draw_colored_polygon(PackedVector2Array([
		Vector2(250, 186), Vector2(268, 160), Vector2(280, 160), Vector2(272, 186),
	]), Color(0.74, 0.76, 0.82))
	for i in range(9):
		var bl := 0.5 + 0.5 * sin(_t * 2.0 + float(i))
		draw_rect(Rect2(78.0 + float(i) * 52.0, 232, 5, 4),
			Color(0.90, 0.72, 0.30, 0.35 + 0.45 * bl))
	# Mullions
	for i in range(6):
		draw_rect(Rect2(64.0 + float(i) * 79.0, 64, 5, 198), Color(0.14, 0.15, 0.19))
	draw_rect(Rect2(64, 140, 474, 5), Color(0.14, 0.15, 0.19))

	IA.flap_board(self, 616, 74, 470, 5, _t)

	# Check-in desks with bag belts
	IA.counter(self, 600, 232, 480, 74,
		Color(0.20, 0.22, 0.28), Color(0.32, 0.36, 0.44))
	for i in range(2):
		var dx := 636.0 + float(i) * 240.0
		draw_rect(Rect2(dx, 196, 84, 34), Color(0.10, 0.12, 0.16))
		draw_rect(Rect2(dx + 5, 201, 74, 24), Color(0.34, 0.62, 0.72, 0.8))
		# Numbered desk sign hanging above
		draw_rect(Rect2(dx + 18, 150, 48, 30), Color(0.12, 0.14, 0.18))
		draw_rect(Rect2(dx + 22, 154, 40, 22), Color(0.30, 0.52, 0.68, 0.9))
	# Baggage belt lip in front of the desks
	draw_rect(Rect2(600, 300, 480, 10), Color(0.16, 0.17, 0.21))
	draw_rect(Rect2(600, 306, 480, 4), Color(0.10, 0.11, 0.14))

	IA.queue_posts(self, 660, 372, 4)
	IA.bench_run(self, 150, 440, 4, Color(0.24, 0.26, 0.32), Color(0.26, 0.34, 0.46))
	IA.plant(self, 1064, 320, Color(0.26, 0.30, 0.36))
	IA.side_walls(self, wall, trim)
	IA.exit_door(self, 56, Color(0.24, 0.28, 0.34))


# ── What you cannot walk through ──────────────────────────────────────────────
#
# This file had no solids() at all, so every counter in every Berlin interior
# was scenery: the exchange, the police desk, the hospital reception, the
# restaurant pass and the airport desk could all be walked straight through,
# and the player ended up standing inside the furniture with the clerk.
#
# Solids.gd clamps each rect to its bottom band, so these are the drawn boxes
# and you can still stand close enough to be served.
const COUNTERS := {
	"exchange":   Rect2(470.0, 236.0, 480.0, 70.0),
	"police":     Rect2(420.0, 232.0, 470.0, 74.0),
	"hospital":   Rect2(640.0, 240.0, 400.0, 66.0),
	"restaurant": Rect2(560.0, 236.0, 470.0, 70.0),
	"airport":    Rect2(600.0, 232.0, 480.0, 74.0),
}


func solids() -> Array:
	var out: Array = []
	if COUNTERS.has(room):
		out.append(COUNTERS[room])
	return out
