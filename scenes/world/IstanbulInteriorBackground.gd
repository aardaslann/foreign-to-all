extends Node2D

# One script, eight rooms — Istanbul's counterpart to InteriorBackground.gd and
# LondonInteriorBackground.gd. Same box, same primitives, different city.
#
# Berlin's interiors hid their words. London's hid nothing and helped less.
# These rooms hide something else again: what you are being given, and what
# accepting it will mean. Every counter in Istanbul has a glass of tea on it
# that nobody will let you pay for.
#
# Signage rule: short stems the player is meant to learn (ÇIKIŞ, ACİL, DÖVİZ)
# are drawn as real letters, because they recur until they stick. Dense text is
# drawn with IA.sign(), which renders lettering as marks — the alien can see
# that writing is happening and not what it says. Turkish gives almost no
# cognates, so this city stays marks for far longer than the other two.

@export var room: String = "otel"

const IA := preload("res://scenes/world/InteriorArt.gd")

# Palette shared with IstanbulStreetBackground so inside and outside agree
const C_SHADOW   := Color(0.165, 0.122, 0.094)
const C_TIMB_DK  := Color(0.290, 0.212, 0.149)
const C_TIMBER   := Color(0.420, 0.310, 0.208)
const C_PLASTER  := Color(0.541, 0.435, 0.306)
const C_SUN      := Color(0.788, 0.659, 0.471)
const C_BLEACH   := Color(0.910, 0.835, 0.690)
const C_TERRA    := Color(0.710, 0.337, 0.235)
const C_CABLE    := Color(0.239, 0.227, 0.204)
const C_COBALT   := Color(0.110, 0.224, 0.659)
const C_TURQ     := Color(0.184, 0.643, 0.627)
const C_BOLE     := Color(0.784, 0.271, 0.227)
const C_EMERALD  := Color(0.122, 0.478, 0.353)
const C_TILE_W   := Color(0.941, 0.925, 0.878)
const C_INK      := Color(0.129, 0.106, 0.086)
const C_CRESCENT := Color(0.886, 0.114, 0.145)   # the red of the flag and the crescent

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-IA.EXT, -IA.EXT, IA.VW + IA.EXT * 2.0, IA.VH + IA.EXT * 2.0),
		IA.C_VOID)
	match room:
		"otel":       _dress_otel()
		"doviz":      _dress_doviz()
		"metro":      _dress_metro()
		"lokanta":    _dress_lokanta()
		"karakol":    _dress_karakol()
		"hastane":    _dress_hastane()
		"havalimani": _dress_havalimani()
		"yusuf":      _dress_yusuf()
		_:            _dress_otel()


# What the player cannot walk through. World-space, declared beside the code
# that draws it so the two cannot drift. Solids.gd turns these into bodies.
func solids() -> Array:
	match room:
		"otel":
			return [Rect2(500, 240, 400, 64), Rect2(950, 300, 92, 130),
				Rect2(380, 446, 40, 46)]
		"doviz":
			return [Rect2(500, 250, 400, 60)]
		"metro":
			return [Rect2(220, 420, 44, 120), Rect2(400, 420, 44, 120),
				Rect2(580, 420, 44, 120), Rect2(760, 420, 44, 120),
				Rect2(840, 300, 120, 96), Rect2(600, 256, 508, 50)]
		"lokanta":
			return [Rect2(300, 250, 620, 62),
				Rect2(160, 396, 190, 92), Rect2(490, 396, 190, 92),
				Rect2(820, 396, 190, 92)]
		"karakol":
			return [Rect2(500, 246, 400, 62), Rect2(150, 426, 184, 40),
				Rect2(940, 442, 40, 46)]
		"hastane":
			return [Rect2(160, 250, 340, 58),
				Rect2(600, 264, 160, 36), Rect2(800, 264, 160, 36),
				Rect2(130, 404, 230, 44), Rect2(640, 404, 230, 44),
				Rect2(560, 466, 40, 46)]
		"havalimani":
			return [Rect2(470, 252, 440, 58), Rect2(470, 308, 440, 30),
				Rect2(150, 446, 40, 46)]
		"yusuf":
			# The shelves are a wall of ceramic; the stools are not solid,
			# because sitting down is the entire point of the room.
			return [Rect2(80, 300, 460, 42), Rect2(140, 366, 96, 56)]
		_:
			return []


func _label(x: float, y: float, text: String, size: int, col: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var w: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	draw_string(font, Vector2(x - w.x * 0.5, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _text(x: float, y: float, text: String, size: int, col: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


# A glass of tea. Tulip-shaped, on a saucer, with two lumps beside it. It is
# in almost every room in this city and it is never for sale.
func _cay(x: float, y: float) -> void:
	draw_rect(Rect2(x - 11.0, y + 12.0, 22, 3), C_TILE_W.darkened(0.15))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 7, y - 16), Vector2(x + 7, y - 16),
		Vector2(x + 5, y - 2), Vector2(x + 8, y + 11),
		Vector2(x - 8, y + 11), Vector2(x - 5, y - 2),
	]), Color(0.98, 0.96, 0.92, 0.55))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 6, y - 8), Vector2(x + 6, y - 8),
		Vector2(x + 7, y + 9), Vector2(x - 7, y + 9),
	]), Color(0.596, 0.208, 0.098, 0.88))
	draw_rect(Rect2(x + 12.0, y + 8.0, 5, 5), C_TILE_W)
	draw_rect(Rect2(x + 18.0, y + 8.0, 5, 5), C_TILE_W)


# An İznik panel — the one place saturation is allowed indoors, because it is
# tile and tile is where these colours actually live.
func _iznik_panel(x: float, y: float, w: float, h: float) -> void:
	draw_rect(Rect2(x - 4.0, y - 4.0, w + 8.0, h + 8.0), C_BLEACH.darkened(0.20))
	var cols: int = int(w / 44.0)
	var rows: int = int(h / 44.0)
	for r in range(rows):
		for c in range(cols):
			var tx: float = x + float(c) * 44.0
			var ty: float = y + float(r) * 44.0
			draw_rect(Rect2(tx, ty, 42, 42), C_TILE_W)
			var motif: int = (r * cols + c) % 3
			if motif == 0:
				draw_circle(Vector2(tx + 21.0, ty + 21.0), 12.0, C_COBALT)
				draw_circle(Vector2(tx + 21.0, ty + 21.0), 6.0, C_TURQ)
			elif motif == 1:
				draw_colored_polygon(PackedVector2Array([
					Vector2(tx + 21, ty + 5), Vector2(tx + 34, ty + 21),
					Vector2(tx + 21, ty + 37), Vector2(tx + 8, ty + 21),
				]), C_TURQ)
				draw_circle(Vector2(tx + 21.0, ty + 21.0), 5.0, C_BOLE)
			else:
				draw_colored_polygon(PackedVector2Array([
					Vector2(tx + 21, ty + 6), Vector2(tx + 30, ty + 20),
					Vector2(tx + 21, ty + 36), Vector2(tx + 12, ty + 20),
				]), C_EMERALD)


# ── OTEL ──────────────────────────────────────────────────────────────────────
# Family-run. There is a fridge on the landing and a television nobody watches.

func _dress_otel() -> void:
	var wall := Color(0.310, 0.245, 0.180)
	var trim := Color(0.400, 0.310, 0.212)
	IA.shell(self, wall, trim, Color(0.345, 0.270, 0.196))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_RUNNER)
	IA.ceiling_light(self, 640.0, Color(0.98, 0.86, 0.60), _t)

	_iznik_panel(120.0, 150.0, 176.0, 132.0)
	_label(576, 82, "OTEL", 24, C_TILE_W)
	draw_rect(Rect2(486, 92, 180, 3), C_TURQ)

	# Keys on wooden fobs, big enough that you cannot walk off with one
	draw_rect(Rect2(600, 128, 260, 92), C_TIMB_DK)
	draw_rect(Rect2(606, 134, 248, 80), C_TIMBER)
	for i in range(10):
		var kx: float = 620.0 + float(i % 5) * 46.0
		var ky: float = 152.0 + float(i / 5) * 36.0
		draw_rect(Rect2(kx, ky - 8.0, 2, 8), C_CABLE)
		draw_rect(Rect2(kx - 7.0, ky, 16, 22), C_TERRA.darkened(0.20))
		draw_rect(Rect2(kx - 4.0, ky + 4.0, 10, 3), C_BLEACH)

	IA.counter(self, 500, 240, 400, 64, Color(0.235, 0.176, 0.125),
		Color(0.470, 0.365, 0.243))
	# A doily under it, because someone's mother put it there
	draw_rect(Rect2(676, 232, 90, 10), C_TILE_W)
	_cay(730.0, 226.0)

	# The fridge on the landing, humming, containing four things
	draw_rect(Rect2(950, 300, 92, 130), C_TILE_W.darkened(0.10))
	draw_rect(Rect2(956, 306, 80, 54), C_TILE_W.darkened(0.04))
	draw_rect(Rect2(1030, 330, 6, 24), C_CABLE)
	# A television on a bracket, on, ignored
	draw_rect(Rect2(150, 300, 130, 84), Color(0.10, 0.10, 0.11))
	var flick: float = 0.4 + 0.25 * sin(_t * 7.3)
	draw_rect(Rect2(156, 306, 118, 72), Color(0.42, 0.48, 0.52, flick))
	IA.sign(self, 330, 250, 140, 44, C_TILE_W, C_INK, 4)
	IA.plant(self, 380, 470, C_TERRA.darkened(0.15))
	IA.exit_door(self, 56, C_TIMB_DK)


# ── DÖVİZ ─────────────────────────────────────────────────────────────────────
# A booth with a live rate board. No haggling here — and haggling everywhere
# else. Nothing tells the alien which rooms are which.

func _dress_doviz() -> void:
	var wall := Color(0.215, 0.200, 0.180)
	var trim := Color(0.290, 0.268, 0.235)
	IA.shell(self, wall, trim, Color(0.240, 0.222, 0.198))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.strip_light(self, 320.0, 520.0, Color(0.86, 0.90, 0.94), _t)

	_label(576, 78, "DÖVİZ", 22, C_EMERALD.lightened(0.30))

	# The board is alive — the last digit moves, which is the point of it
	draw_rect(Rect2(520, 96, 420, 152), Color(0.055, 0.055, 0.050))
	var codes := ["USD", "EUR", "GBP", "CHF"]
	for i in range(codes.size()):
		var ry: float = 132.0 + float(i) * 30.0
		_text(544, ry, String(codes[i]), 14, Color(0.92, 0.86, 0.42))
		_text(660, ry, "ALIŞ", 10, Color(0.52, 0.56, 0.52))
		_text(800, ry, "SATIŞ", 10, Color(0.52, 0.56, 0.52))
		var jitter: int = int(fmod(_t * 0.7 + float(i), 9.0))
		_text(704, ry, "3" + str(i + 2) + "." + str(jitter) + "0", 14,
			Color(0.42, 0.90, 0.52))
		_text(852, ry, "3" + str(i + 3) + "." + str((jitter + 4) % 9) + "0", 14,
			Color(0.94, 0.44, 0.38))

	IA.counter(self, 500, 250, 400, 60, Color(0.180, 0.168, 0.150),
		Color(0.380, 0.355, 0.315))
	IA.glass_screen(self, 500, 138, 400, 112, Color(0.32, 0.30, 0.26))
	draw_rect(Rect2(672, 254, 96, 12), Color(0.140, 0.130, 0.115))
	_cay(430.0, 232.0)
	IA.sign(self, 150, 190, 150, 60, C_TILE_W, C_INK, 5)
	IA.exit_door(self, 56, C_TIMB_DK)


# ── METRO ─────────────────────────────────────────────────────────────────────
# A jeton is not change. It is a token, it buys one journey, and it cannot be
# spent on anything else — which the alien will discover by trying.

func _dress_metro() -> void:
	var wall := Color(0.180, 0.192, 0.200)
	var trim := Color(0.255, 0.270, 0.280)
	IA.shell(self, wall, trim, Color(0.200, 0.212, 0.222))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.strip_light(self, 200.0, 760.0, Color(0.88, 0.92, 0.96), _t)

	# Tiled to the dado, and the tile is the good stuff
	for c in range(26):
		for r in range(3):
			draw_rect(Rect2(44.0 + float(c) * 42.0, 172.0 + float(r) * 40.0, 40, 38),
				C_TILE_W.darkened(0.04 * float((c + r) % 3)))
	_iznik_panel(430.0, 176.0, 264.0, 88.0)

	_label(576, 140, "METRO", 20, C_TURQ)
	_text(96, 150, "ÇIKIŞ →", 15, C_EMERALD.lightened(0.40))
	_text(940, 150, "← GİRİŞ", 15, C_EMERALD.lightened(0.40))

	# A Marmaray train standing with its doors open. Without it this is a
	# tiled corridor; with it there is no question what the room is.
	IA.train_at_platform(self, 600, 306, 508, C_TURQ, _t)

	# Turnstiles, and the reader that wants a card the alien does not have
	for i in range(4):
		var bx: float = 220.0 + float(i) * 180.0
		draw_rect(Rect2(bx, 420, 44, 120), Color(0.215, 0.225, 0.235))
		draw_rect(Rect2(bx, 414, 44, 8), Color(0.32, 0.33, 0.34))
		draw_circle(Vector2(bx + 22.0, 444.0), 10.0, C_TURQ.lightened(0.20))
		for a in range(3):
			var ang: float = float(a) * TAU / 3.0 + _t * 0.2
			draw_line(Vector2(bx + 22.0, 490.0),
				Vector2(bx + 22.0 + cos(ang) * 26.0, 490.0 + sin(ang) * 10.0),
				Color(0.40, 0.42, 0.44), 3.0)

	# The jeton machine. Round brass tokens in a slot, and a queue of nobody.
	draw_rect(Rect2(840, 300, 120, 96), Color(0.235, 0.225, 0.200))
	draw_rect(Rect2(848, 308, 104, 52), Color(0.10, 0.11, 0.12))
	for i in range(3):
		draw_circle(Vector2(868.0 + float(i) * 22.0, 378.0), 9.0,
			Color(0.760, 0.620, 0.290))
	IA.sign(self, 130, 300, 160, 70, C_TILE_W, C_INK, 6)
	IA.exit_door(self, 56, C_TIMB_DK)


# ── LOKANTA ───────────────────────────────────────────────────────────────────
# Esnaf lokantası. Steam trays behind glass. You point at food, not at words —
# which is the first time since the crash that not having language costs nothing.

func _dress_lokanta() -> void:
	var wall := Color(0.270, 0.225, 0.170)
	var trim := Color(0.355, 0.290, 0.205)
	IA.shell(self, wall, trim, Color(0.300, 0.248, 0.185))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_WOOD)
	IA.ceiling_light(self, 340.0, Color(0.99, 0.88, 0.62), _t)
	IA.ceiling_light(self, 800.0, Color(0.99, 0.88, 0.62), _t)

	_label(576, 78, "LOKANTA", 20, C_BLEACH)

	# The counter is the menu. Everything is visible and nothing is written.
	IA.counter(self, 300, 250, 620, 62, Color(0.215, 0.165, 0.115),
		Color(0.470, 0.380, 0.255))
	draw_rect(Rect2(300, 176, 620, 76), Color(0.86, 0.90, 0.92, 0.22))
	draw_rect(Rect2(300, 176, 620, 4), C_TILE_W.darkened(0.20))
	var pots := [C_BOLE, C_EMERALD, C_TERRA, Color(0.86, 0.72, 0.34),
		Color(0.545, 0.400, 0.235), C_EMERALD.darkened(0.20)]
	for i in range(pots.size()):
		var px: float = 330.0 + float(i) * 98.0
		draw_rect(Rect2(px, 206, 84, 44), Color(0.62, 0.60, 0.56))
		draw_rect(Rect2(px + 4.0, 210, 76, 34), pots[i])
		draw_rect(Rect2(px + 4.0, 210, 76, 6), Color(1, 1, 1, 0.14))
		# Steam, so the alien knows which trays are the real ones
		var s: float = 0.3 + 0.25 * sin(_t * 1.2 + float(i))
		draw_circle(Vector2(px + 42.0, 194.0), 20.0, Color(0.94, 0.94, 0.90, 0.035 * s))

	# Tables with paper cloths, and a water bottle on every one
	for i in range(3):
		var tx: float = 160.0 + float(i) * 330.0
		draw_rect(Rect2(tx, 404, 190, 84), Color(0.345, 0.280, 0.200))
		draw_rect(Rect2(tx + 6.0, 398, 178, 12), C_TILE_W.darkened(0.06))
		draw_rect(Rect2(tx + 16.0, 488, 14, 56), Color(0.215, 0.170, 0.120))
		draw_rect(Rect2(tx + 160.0, 488, 14, 56), Color(0.215, 0.170, 0.120))
		draw_rect(Rect2(tx + 86.0, 376, 16, 30), Color(0.62, 0.78, 0.80, 0.60))
		_cay(tx + 140.0, 388.0)
	IA.exit_door(self, 56, C_TIMB_DK)


# ── KARAKOL ───────────────────────────────────────────────────────────────────
# There is tea here too. Refusing it in a police station is still a mistake,
# and that is the room's entire joke.

func _dress_karakol() -> void:
	var wall := Color(0.190, 0.196, 0.192)
	var trim := Color(0.260, 0.268, 0.262)
	IA.shell(self, wall, trim, Color(0.210, 0.216, 0.212))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.strip_light(self, 280.0, 600.0, Color(0.86, 0.90, 0.92), _t)

	_label(576, 80, "KARAKOL", 19, C_BLEACH)
	# The flag. Not decoration — it is the only thing on the wall that is new.
	draw_rect(Rect2(150, 120, 200, 132), C_CRESCENT)
	draw_circle(Vector2(232, 186), 34.0, C_TILE_W)
	draw_circle(Vector2(244, 186), 28.0, C_CRESCENT)
	draw_colored_polygon(PackedVector2Array([
		Vector2(276, 172), Vector2(284, 186), Vector2(298, 186),
		Vector2(287, 195), Vector2(292, 209), Vector2(276, 200),
		Vector2(260, 209), Vector2(265, 195), Vector2(254, 186),
		Vector2(268, 186),
	]), C_TILE_W)

	# A cell along the far wall, and tea being carried past it
	IA.cell_bars(self, 900, 160, 180, 146, Color(0.32, 0.33, 0.34))
	_label(990, 150, "NEZARETHANE", 9, Color(0.60, 0.64, 0.62))

	IA.counter(self, 500, 246, 400, 62, Color(0.170, 0.176, 0.172),
		Color(0.330, 0.340, 0.335))
	IA.glass_screen(self, 500, 132, 400, 114, Color(0.28, 0.29, 0.28))
	_cay(452.0, 228.0)
	IA.sign(self, 700, 150, 180, 76, C_TILE_W, C_INK, 7)
	IA.bench_run(self, 150, 452, 4, Color(0.200, 0.206, 0.202),
		Color(0.250, 0.258, 0.252))
	IA.plant(self, 940, 466, C_TERRA.darkened(0.20))
	IA.exit_door(self, 56, C_TIMB_DK)


# ── HASTANE ───────────────────────────────────────────────────────────────────
# Nobody is here alone. Every patient has three relatives standing over them,
# and the alien — which has been alone in three cities — is the anomaly.

func _dress_hastane() -> void:
	var wall := Color(0.215, 0.230, 0.235)
	var trim := Color(0.290, 0.310, 0.315)
	IA.shell(self, wall, trim, Color(0.235, 0.252, 0.258))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.88, 0.92, 0.94))
	IA.strip_light(self, 140.0, 400.0, Color(0.90, 0.94, 0.97), _t)
	IA.strip_light(self, 620.0, 400.0, Color(0.90, 0.94, 0.97), _t)

	# ACİL, and the crescent that means here
	draw_rect(Rect2(430, 56, 292, 60), C_TILE_W)
	draw_circle(Vector2(486, 86), 22.0, C_CRESCENT)
	draw_circle(Vector2(496, 86), 18.0, C_TILE_W)
	_text(524, 96, "ACİL", 26, C_CRESCENT)
	_label(576, 138, "HASTANE", 13, Color(0.62, 0.70, 0.72))

	# Two bays, curtains half drawn. In Istanbul nobody waits alone, so the
	# benches are full and the bays are the only quiet in the room.
	IA.hospital_bay(self, 600, 300, C_TURQ.darkened(0.30), Color(0.94, 0.94, 0.92))
	IA.hospital_bay(self, 800, 300, C_TURQ.darkened(0.30), Color(0.94, 0.94, 0.92))

	IA.counter(self, 160, 250, 340, 58, Color(0.195, 0.208, 0.212),
		Color(0.345, 0.365, 0.372))
	IA.glass_screen(self, 160, 146, 340, 104, Color(0.30, 0.32, 0.33))
	_cay(540.0, 232.0)

	# A ticket machine with a number nobody is watching for
	draw_rect(Rect2(820, 168, 130, 92), Color(0.180, 0.192, 0.196))
	draw_rect(Rect2(828, 176, 114, 46), Color(0.08, 0.09, 0.10))
	_text(848, 210, "B-" + str(40 + int(fmod(_t * 0.2, 9.0))), 18,
		Color(0.42, 0.86, 0.66))

	# Benches, and the fact that they are full
	IA.bench_run(self, 130, 430, 5, Color(0.215, 0.228, 0.235),
		Color(0.260, 0.278, 0.285))
	IA.bench_run(self, 640, 430, 5, Color(0.215, 0.228, 0.235),
		Color(0.260, 0.278, 0.285))
	IA.sign(self, 980, 300, 130, 88, C_TILE_W, C_INK, 6)
	IA.plant(self, 560, 490, C_TERRA.darkened(0.25))
	IA.exit_door(self, 56, C_TIMB_DK)


# ── HAVALİMANI ────────────────────────────────────────────────────────────────
# The only cold room in Istanbul, and the way home.

func _dress_havalimani() -> void:
	var wall := Color(0.240, 0.252, 0.268)
	var trim := Color(0.320, 0.335, 0.352)
	IA.shell(self, wall, trim, Color(0.262, 0.275, 0.292))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.92, 0.95, 0.98))
	IA.strip_light(self, 110.0, 420.0, Color(0.94, 0.96, 0.99), _t)
	IA.strip_light(self, 640.0, 420.0, Color(0.94, 0.96, 0.99), _t)

	draw_rect(Rect2(44, 46, 1064, 76), Color(0.66, 0.74, 0.84, 0.16))
	for i in range(8):
		draw_rect(Rect2(44.0 + float(i) * 140.0, 46, 5, 76), Color(0.36, 0.38, 0.42))

	IA.flap_board(self, 320, 150, 520, 5, _t)
	_label(576, 140, "GİDİŞ  ·  DEPARTURES", 13, Color(0.84, 0.88, 0.92))

	# The aircraft, filling the glass
	IA.apron_view(self, 60, 148, 400, 172, C_CRESCENT, "istanbul")

	IA.counter(self, 470, 252, 440, 58, Color(0.205, 0.215, 0.230),
		Color(0.350, 0.368, 0.390))
	IA.baggage_belt(self, 470, 308, 440, _t)
	IA.queue_posts(self, 250, 428, 5)
	IA.queue_posts(self, 250, 508, 5)
	draw_rect(Rect2(246, 432, 460, 3), Color(0.56, 0.58, 0.62, 0.55))
	draw_rect(Rect2(246, 512, 460, 3), Color(0.56, 0.58, 0.62, 0.55))
	_text(842, 404, "ÇIKIŞ →", 15, C_EMERALD.lightened(0.40))
	IA.sign(self, 830, 424, 220, 56, C_TILE_W, C_INK, 6)
	IA.plant(self, 150, 470, C_TERRA.darkened(0.20))
	IA.exit_door(self, 56, C_TIMB_DK)


# ── Yusuf's shop ──────────────────────────────────────────────────────────────
# One room under the arcade, stacked to the ceiling with things that are for
# sale, and one thing that is not.
#
# The stool matters more than the shelves. He will not talk business standing
# up, and the player who treats sitting down as wasted time never gets the charm.

func _dress_yusuf() -> void:
	var wall := Color(0.285, 0.222, 0.160)
	var trim := Color(0.375, 0.292, 0.196)
	IA.shell(self, wall, trim, Color(0.315, 0.246, 0.176))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_WOOD)
	IA.ceiling_light(self, 500.0, Color(0.99, 0.84, 0.55), _t, 22.0)

	# Shelves to the ceiling. Every piece is İznik, and this is the one room
	# where the saturation is allowed to take over, because it is all ceramic.
	for shelf in range(4):
		var sy: float = 96.0 + float(shelf) * 52.0
		draw_rect(Rect2(80, sy + 40.0, 460, 6), C_TIMB_DK)
		for i in range(11):
			var px: float = 92.0 + float(i) * 41.0
			var kind: int = (shelf * 11 + i) % 4
			if kind == 0:
				draw_circle(Vector2(px + 14.0, sy + 28.0), 14.0, C_COBALT)
				draw_circle(Vector2(px + 14.0, sy + 28.0), 8.0, C_TILE_W)
			elif kind == 1:
				draw_rect(Rect2(px + 2.0, sy + 14.0, 26, 28), C_TURQ)
				draw_rect(Rect2(px + 6.0, sy + 18.0, 18, 8), C_TILE_W)
			elif kind == 2:
				draw_colored_polygon(PackedVector2Array([
					Vector2(px + 15, sy + 10), Vector2(px + 29, sy + 30),
					Vector2(px + 15, sy + 42), Vector2(px + 1, sy + 30),
				]), C_BOLE)
			else:
				draw_rect(Rect2(px + 4.0, sy + 20.0, 22, 22), C_EMERALD)
				draw_rect(Rect2(px + 4.0, sy + 20.0, 22, 5), C_TILE_W)

	# The doorway, from the inside. The cord is out there, and the fragment on
	# it, and from in here you can only see it as a shape against the courtyard.
	draw_rect(Rect2(880, 150, 190, 250), Color(0.72, 0.66, 0.52))
	draw_rect(Rect2(880, 150, 190, 10), C_TIMB_DK)
	var sway: float = sin(_t * 0.8) * 2.0
	draw_line(Vector2(898, 178), Vector2(1052, 178), C_CABLE, 1.6)
	draw_circle(Vector2(936, 196), 10.0, Color(0.10, 0.10, 0.12))
	draw_circle(Vector2(1014, 196), 10.0, Color(0.10, 0.10, 0.12))
	draw_colored_polygon(PackedVector2Array([
		Vector2(975 + sway, 186), Vector2(985 + sway, 195),
		Vector2(981 + sway, 210), Vector2(969 + sway, 210),
		Vector2(965 + sway, 195),
	]), Color(0.12, 0.11, 0.10))

	# The stool. Low, plastic, and the most important object in the act.
	draw_rect(Rect2(410, 470, 74, 12), C_BOLE.darkened(0.15))
	for l in range(4):
		draw_rect(Rect2(416.0 + float(l % 2) * 60.0, 482, 7, 32),
			C_BOLE.darkened(0.35))
	# A second stool, already out, already facing the first one
	draw_rect(Rect2(560, 486, 74, 12), C_TURQ.darkened(0.25))
	for l2 in range(4):
		draw_rect(Rect2(566.0 + float(l2 % 2) * 60.0, 498, 7, 30),
			C_TURQ.darkened(0.45))
	# The tray, and two glasses on it, poured before anything was agreed
	draw_rect(Rect2(486, 440, 78, 8), Color(0.760, 0.620, 0.290))
	_cay(506.0, 428.0)
	_cay(544.0, 428.0)

	# Meryem's pot, on a ring burner at the back, which is why the room smells
	# of something the alien has no word for
	draw_rect(Rect2(140, 402, 96, 20), Color(0.180, 0.170, 0.155))
	draw_rect(Rect2(152, 366, 72, 40), Color(0.480, 0.455, 0.420))
	draw_rect(Rect2(146, 358, 84, 10), Color(0.560, 0.530, 0.490))
	var heat: float = 0.35 + 0.3 * sin(_t * 1.1)
	draw_circle(Vector2(188, 348), 24.0, Color(0.95, 0.92, 0.86, 0.04 * heat))
	IA.exit_door(self, 56, C_TIMB_DK)
