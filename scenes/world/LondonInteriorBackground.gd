extends Node2D

# One script, seven rooms — the London counterpart to InteriorBackground.gd.
# `room` picks the dressing; the shell, floor and lighting come from InteriorArt,
# so a London interior is architecturally the same box as a Berlin one and
# differs only where it should.
#
# What it differs in is the point. Berlin's rooms hid their words. These rooms
# hide nothing: every sign is legible, correctly spelled, and no help at all.
# The alien can read BREAKFAST 7-9.30 and still not know whether it can eat.

@export var room: String = "hotel"

const IA := preload("res://scenes/world/InteriorArt.gd")

# London palette, shared with LondonStreetBackground so inside and outside agree
const C_STOCK   := Color(0.361, 0.318, 0.251)
const C_SLATE   := Color(0.180, 0.192, 0.220)
const C_STUCCO  := Color(0.769, 0.741, 0.675)
const C_SASH    := Color(0.910, 0.886, 0.831)
const C_GLASS   := Color(0.102, 0.114, 0.141)
const C_WARM    := Color(0.941, 0.843, 0.604)
const C_INK     := Color(0.098, 0.098, 0.110)
const C_TFL_RED := Color(0.882, 0.145, 0.106)
const C_TFL_BLU := Color(0.000, 0.098, 0.659)
const C_NHS     := Color(0.000, 0.369, 0.722)
const C_OXBLOOD := Color(0.353, 0.129, 0.114)

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	# The void first, unconditionally — a room that forgets its shell must not
	# be able to show the bare window colour where its floor should be.
	draw_rect(Rect2(-IA.EXT, -IA.EXT, IA.VW + IA.EXT * 2.0, IA.VH + IA.EXT * 2.0),
		IA.C_VOID)
	match room:
		"hotel":       _dress_hotel()
		"exchange":    _dress_exchange()
		"underground": _dress_underground()
		"caff":        _dress_caff()
		"police":      _dress_police()
		"hospital":    _dress_hospital()
		"airport":     _dress_airport()
		_:             _dress_hotel()


# What the player cannot walk through. World-space, declared beside the code
# that draws it so the two cannot drift. Solids.gd turns these into bodies.
func solids() -> Array:
	match room:
		"hotel":
			return [Rect2(520, 240, 400, 66), Rect2(950, 300, 92, 130)]
		"exchange":
			return [Rect2(500, 244, 420, 62)]
		"underground":
			return [Rect2(210, 430, 40, 118), Rect2(400, 430, 40, 118),
				Rect2(590, 430, 40, 118), Rect2(620, 250, 488, 56)]
		"caff":
			return [Rect2(500, 250, 420, 58),
				Rect2(180, 396, 176, 78), Rect2(480, 396, 176, 78),
				Rect2(780, 396, 176, 78)]
		"police":
			return [Rect2(520, 246, 400, 60), Rect2(140, 444, 138, 40)]
		"hospital":
			return [Rect2(150, 246, 330, 58), Rect2(610, 264, 160, 36),
				Rect2(130, 398, 230, 44), Rect2(640, 398, 230, 44),
				Rect2(1020, 380, 42, 128)]
		"airport":
			return [Rect2(480, 250, 440, 60), Rect2(480, 306, 440, 30)]
		_:
			return []


# Centre a line of text on x. Every room does this, so it lives here once.
func _label(x: float, y: float, text: String, size: int, col: Color) -> void:
	var font: Font = ThemeDB.fallback_font
	var w: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	draw_string(font, Vector2(x - w.x * 0.5, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _text(x: float, y: float, text: String, size: int, col: Color) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x, y), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


# ── Hotel ─────────────────────────────────────────────────────────────────────

func _dress_hotel() -> void:
	# a converted terrace with a desk in its front room. berlin's hotel had
	# faded grandeur; this one never had any to fade.
	var wall := Color(0.168, 0.152, 0.130)        # magnolia over woodchip
	var trim := Color(0.228, 0.204, 0.168)
	var warm := Color(0.941, 0.843, 0.604)        # window lit — milkier than berlin's
	var lam  := Color(0.404, 0.376, 0.318)        # laminate, sold to the owner as beech
	var ink  := Color(0.180, 0.168, 0.150)
	var post := Color(0.635, 0.231, 0.235)        # post office red BS381C-538
	var font: Font = ThemeDB.fallback_font
	var night: bool = not GameState.is_morning()
	IA.shell(self, wall, trim, Color(0.190, 0.170, 0.142))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_CARPET)

	# the pattern was chosen to hide wear. it does. that is how you know how
	# much wear there is.
	for r in range(7):
		var cy := 320.0 + float(r) * 42.0
		for c in range(13):
			var cx := 74.0 + float(c) * 78.0 + (39.0 if r % 2 == 1 else 0.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(cx, cy - 13), Vector2(cx + 21, cy),
				Vector2(cx, cy + 13), Vector2(cx - 21, cy),
			]), Color(0.180, 0.145, 0.098, 0.55))
			draw_circle(Vector2(cx, cy), 4.0, Color(0.130, 0.150, 0.110, 0.50))
	# the walked line from the door to the desk, where the pile gave up
	draw_colored_polygon(PackedVector2Array([
		Vector2(150, 524), Vector2(272, 452), Vector2(700, 388),
		Vector2(776, 404), Vector2(322, 496), Vector2(208, 558),
	]), Color(0.74, 0.70, 0.60, 0.055))
	draw_rect(Rect2(44, 602, 1064, 4), Color(0.38, 0.32, 0.19))   # gripper at the threshold
	draw_rect(Rect2(44, 606, 1064, 4), trim.darkened(0.10))       # near wall, closed back over

	IA.ceiling_light(self, 700.0, warm, _t, 26.0)

	# net curtain. not for privacy — so the street cannot see how little
	# there is to see.
	IA.window(self, 96, 92, 196, 118, Color(0.46, 0.43, 0.37))
	draw_rect(Rect2(100, 96, 188, 106), Color(0.78, 0.76, 0.70, 0.13))

	# the box sign faces the street. from in here every letter is legible and
	# the order is not. it is also the only saturated thing in the room, and
	# it is turned away from you.
	draw_rect(Rect2(136, 112, 150, 46), Color(0.10, 0.09, 0.08))
	draw_rect(Rect2(140, 116, 142, 38), Color(0.80, 0.78, 0.72, 0.92))
	draw_string(font, Vector2(144, 143), "SEICNACAV", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, post)
	# the hinged flap that turns VACANCIES into NO VACANCIES. it has not been
	# lifted since march.
	draw_colored_polygon(PackedVector2Array([
		Vector2(226, 114), Vector2(282, 117), Vector2(281, 148), Vector2(225, 145),
	]), Color(0.74, 0.72, 0.66, 0.95))
	draw_string(font, Vector2(234, 140), "ON", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, post)

	# it ticks. the ticking is not information. the alien will listen to it
	# for an hour anyway.
	var tick := 0.5 + 0.5 * sin(_t * 0.9)
	draw_rect(Rect2(96, 246, 192, 54), Color(0.215, 0.200, 0.172))
	for i in range(12):
		var fx := 100.0 + float(i) * 16.0
		draw_rect(Rect2(fx, 250, 11, 48), Color(0.245, 0.228, 0.196))
		draw_rect(Rect2(fx, 250, 11, 3), Color(0.285, 0.266, 0.228))
	draw_rect(Rect2(282, 288, 14, 16), Color(0.30, 0.26, 0.16))
	draw_rect(Rect2(96, 300, 192, 8), Color(warm.r, warm.g, warm.b, 0.03 + 0.02 * tick))

	# a framed photograph of a bridge twenty minutes away, hung for people who
	# came a long way to see it
	draw_rect(Rect2(330, 96, 132, 96), Color(0.16, 0.13, 0.10))
	draw_rect(Rect2(336, 102, 120, 84), Color(0.20, 0.22, 0.26))
	draw_rect(Rect2(336, 156, 120, 30), Color(0.13, 0.15, 0.19))
	draw_rect(Rect2(352, 118, 8, 46), Color(0.26, 0.26, 0.28))
	draw_rect(Rect2(432, 118, 8, 46), Color(0.26, 0.26, 0.28))

	# laminated so it can be wiped, which implies a history
	draw_rect(Rect2(330, 244, 150, 44), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(333, 247, 144, 38), Color(0.83, 0.81, 0.75))
	draw_string(font, Vector2(340, 263), "BREAKFAST", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ink)
	draw_string(font, Vector2(340, 279), "7 - 9.30", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ink)
	# and in biro, on the corner of the same card. both are true. nothing on
	# the card says which one wins.
	draw_string(font, Vector2(396, 279), "not sundays", HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
		Color(0.22, 0.26, 0.42))

	# berlin's IA.sign() draws lettering as marks, because there the alien
	# could not read. here the words are real and that changes nothing.
	draw_rect(Rect2(596, 58, 224, 34), Color(0.09, 0.10, 0.13))
	draw_rect(Rect2(596, 58, 224, 3), Color(0.20, 0.21, 0.25))
	var lw: Vector2 = font.get_string_size("RECEPTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
	draw_string(font, Vector2(708.0 - lw.x * 0.5, 83), "RECEPTION",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.86, 0.84, 0.78))

	# fourteen hooks, fifteen rooms. thirteen is missing and the board does
	# not say why. the alien can read every number on it.
	draw_rect(Rect2(560, 132, 300, 84), Color(0.13, 0.11, 0.09))
	draw_rect(Rect2(566, 138, 288, 72), Color(0.185, 0.155, 0.120))
	for i in range(14):
		var kx := 578.0 + float(i % 7) * 40.0
		var ky := 152.0 + float(i / 7) * 34.0
		var n: int = i + 1 if i < 12 else i + 2
		draw_rect(Rect2(kx, ky - 8, 3, 8), Color(0.42, 0.38, 0.22))
		draw_string(font, Vector2(kx - 5, ky - 11), str(n), HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
			Color(0.62, 0.58, 0.48))
		if i != 3:      # four is out. its key is upstairs with whoever has it.
			draw_rect(Rect2(kx - 5, ky, 13, 18), Color(0.30, 0.26, 0.18))
			draw_rect(Rect2(kx - 2, ky + 4, 7, 3), Color(0.52, 0.46, 0.26))

	# the chip in the front edge has been there so long it has stopped being
	# damage and become the counter
	IA.counter(self, 520, 240, 400, 66, Color(0.150, 0.120, 0.092), lam)
	draw_rect(Rect2(700, 226, 26, 5), lam.darkened(0.45))

	if night:
		# after eleven the keys go behind glass too, and the conversation
		# happens through a hole the size of a coin.
		IA.glass_screen(self, 520, 132, 400, 108, Color(0.26, 0.22, 0.17))
		draw_rect(Rect2(636, 252, 104, 26), Color(0.80, 0.78, 0.72))
		draw_string(font, Vector2(643, 270), "NIGHT BELL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, ink)
	else:
		draw_circle(Vector2(880, 222), 12.0, Color(0.34, 0.30, 0.18))
		draw_circle(Vector2(880, 219), 9.0, Color(0.50, 0.45, 0.26))
		draw_rect(Rect2(878, 208, 4, 7), Color(0.56, 0.50, 0.30))
		draw_rect(Rect2(824, 196, 106, 30), Color(0.80, 0.78, 0.72))
		draw_string(font, Vector2(830, 210), "PLEASE RING", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, ink)
		draw_string(font, Vector2(830, 222), "FOR ATTENTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, ink)

	# no lift. a victorian terrace has never had one, and deleting berlin's
	# ElevatorPanel says more about this building than any sign does.
	draw_rect(Rect2(944, 120, 160, 186), Color(0.055, 0.050, 0.045))
	for i in range(8):
		var sy := 290.0 - float(i) * 21.0
		var sw := 152.0 - float(i) * 13.0
		draw_rect(Rect2(948, sy, sw, 13), Color(0.150 + float(i) * 0.008, 0.130, 0.108))
		draw_rect(Rect2(948, sy, sw, 3), Color(0.200, 0.176, 0.140))
		draw_rect(Rect2(972, sy, maxf(sw - 48.0, 8.0), 13), Color(0.190, 0.120, 0.098))
		draw_rect(Rect2(992, sy, maxf(sw - 88.0, 4.0), 6), Color(0.235, 0.190, 0.150))
	draw_rect(Rect2(936, 236, 12, 70), Color(0.115, 0.098, 0.080))
	draw_rect(Rect2(934, 228, 16, 10), Color(0.165, 0.140, 0.112))
	draw_line(Vector2(946, 236), Vector2(1096, 128), Color(0.175, 0.148, 0.118), 5.0)

	# berlin taught it to count storeys. london moves the zero and mentions
	# nothing. the first floor is one flight above the floor you are on.
	draw_rect(Rect2(944, 76, 160, 40), Color(0.10, 0.10, 0.12))
	draw_string(font, Vector2(952, 93), "ROOMS 1-6", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(0.84, 0.82, 0.76))
	draw_string(font, Vector2(952, 109), "FIRST FLOOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(0.84, 0.82, 0.76))
	draw_colored_polygon(PackedVector2Array([
		Vector2(1078, 84), Vector2(1090, 106), Vector2(1066, 106),
	]), Color(0.84, 0.82, 0.76))

	# one chair. nobody has sat in it. it is here so the listing can say lounge.
	draw_rect(Rect2(178, 496, 118, 14), Color(0, 0, 0, 0.22))
	draw_rect(Rect2(182, 428, 110, 72), Color(0.135, 0.115, 0.100))
	draw_rect(Rect2(188, 434, 98, 60), Color(0.180, 0.150, 0.128))
	draw_rect(Rect2(176, 452, 14, 46), Color(0.150, 0.126, 0.106))
	draw_rect(Rect2(288, 452, 14, 46), Color(0.150, 0.126, 0.106))
	# leaflets for places whose names the alien can read and cannot reach
	draw_rect(Rect2(344, 444, 112, 30), Color(0.130, 0.112, 0.094))
	draw_rect(Rect2(348, 448, 104, 22), Color(0.170, 0.145, 0.120))
	IA.notice(self, 360, 418, 34, 30, Color(0.78, 0.76, 0.70), Color(0.25, 0.22, 0.18))
	IA.plant(self, 890, 452, Color(0.155, 0.130, 0.108))

	# nobody put these anywhere. that is what they are for.
	draw_rect(Rect2(120, 540, 74, 22), Color(0.115, 0.100, 0.086))
	draw_rect(Rect2(1042, 448, 30, 58), Color(0.125, 0.118, 0.110))
	IA.exit_door(self, 56, Color(0.180, 0.140, 0.105))


# ── Bureau de change ──────────────────────────────────────────────────────────
# A booth wedged into a shopfront. The rates board is the trap: two numbers per
# currency, and the alien reads the one it likes.

func _dress_exchange() -> void:
	var wall := Color(0.150, 0.145, 0.135)
	var trim := Color(0.205, 0.196, 0.178)
	IA.shell(self, wall, trim, Color(0.170, 0.162, 0.148))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_WOOD)
	IA.strip_light(self, 300.0, 560.0, Color(0.82, 0.88, 0.92), _t)

	# The board. WE BUY and WE SELL, and nothing anywhere explains which one
	# applies to you — that is not an oversight, it is the business model.
	draw_rect(Rect2(560, 70, 420, 172), Color(0.055, 0.055, 0.062))
	draw_rect(Rect2(566, 76, 408, 160), Color(0.085, 0.085, 0.096))
	_text(578, 100, "WE BUY", 12, Color(0.62, 0.66, 0.72))
	_text(840, 100, "WE SELL", 12, Color(0.62, 0.66, 0.72))
	var codes := ["EUR", "USD", "TRY", "CHF"]
	var buys  := ["1.09", "1.21", "38.4", "1.14"]
	var sells := ["1.24", "1.36", "44.9", "1.29"]
	for i in range(codes.size()):
		var ry: float = 130.0 + float(i) * 26.0
		_text(578, ry, String(codes[i]), 13, Color(0.86, 0.84, 0.78))
		_text(672, ry, String(buys[i]), 13, Color(0.52, 0.80, 0.58))
		_text(858, ry, String(sells[i]), 13, Color(0.86, 0.46, 0.42))
		draw_rect(Rect2(572, ry + 6, 396, 1), Color(1, 1, 1, 0.05))

	# "NO COMMISSION*" — and the asterisk is four point type, two metres up
	draw_rect(Rect2(160, 96, 250, 54), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(164, 100, 242, 46), Color(0.83, 0.81, 0.75))
	_text(174, 130, "NO COMMISSION*", 16, C_INK)
	_text(174, 160, "*on selected currencies. min £3.50", 8, Color(0.42, 0.40, 0.38))
	_label(576, 60, "BUREAU DE CHANGE", 15, Color(0.80, 0.78, 0.72))

	# The screen, the scooped tray, and the hole you speak through
	IA.counter(self, 500, 244, 420, 62, Color(0.130, 0.120, 0.100),
		Color(0.330, 0.310, 0.270))
	IA.glass_screen(self, 500, 132, 420, 112, Color(0.24, 0.23, 0.20))
	draw_rect(Rect2(672, 250, 96, 12), Color(0.180, 0.170, 0.150))
	draw_rect(Rect2(676, 252, 88, 8), Color(0.070, 0.066, 0.060))
	draw_circle(Vector2(720, 196), 13.0, Color(0.06, 0.06, 0.07))
	for i in range(6):
		var a: float = float(i) * TAU / 6.0
		draw_circle(Vector2(720 + cos(a) * 6.0, 196 + sin(a) * 6.0), 1.6,
			Color(0.30, 0.30, 0.32))

	IA.notice(self, 268, 250, 44, 34, Color(0.80, 0.78, 0.72), Color(0.28, 0.26, 0.22))
	draw_rect(Rect2(1024, 452, 34, 62), Color(0.120, 0.114, 0.104))
	IA.exit_door(self, 56, Color(0.170, 0.150, 0.120))


# ── The Underground ───────────────────────────────────────────────────────────
# The roundel is this room's one saturated thing. Everything else is oxblood
# tile, cream frieze and the draught coming up the tunnel.

func _dress_underground() -> void:
	var wall := Color(0.128, 0.120, 0.118)
	var trim := Color(0.186, 0.172, 0.164)
	IA.shell(self, wall, trim, Color(0.145, 0.134, 0.130))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.strip_light(self, 180.0, 800.0, Color(0.86, 0.90, 0.94), _t)

	# Oxblood glazed tile up to the dado, cream above — the standard section
	for c in range(28):
		for r in range(4):
			draw_rect(Rect2(44.0 + float(c) * 40.0, 176.0 + float(r) * 32.0, 38, 30),
				C_OXBLOOD.darkened(0.06 if (c + r) % 2 == 0 else 0.0))
	draw_rect(Rect2(44, 168, 1064, 6), Color(0.50, 0.48, 0.42))
	draw_rect(Rect2(44, 296, 1064, 8), Color(0.50, 0.48, 0.42))

	# The name frieze. A real one, in a real typeface, and it tells the alien
	# only where it already is.
	draw_rect(Rect2(120, 196, 340, 64), Color(0.88, 0.86, 0.80))
	_label(290, 240, "ALDGATE EAST", 22, Color(0.10, 0.10, 0.12))

	_draw_roundel(820.0, 220.0, 74.0)

	# A train standing at the platform with its doors open. Without this the
	# room is a tiled corridor; with it there is no mistaking what it is.
	IA.train_at_platform(self, 620, 300, 488, C_TFL_RED, _t)

	# MIND THE GAP, painted on the platform edge, where it is too late to read
	draw_rect(Rect2(44, 306, 1064, 26), Color(0.86, 0.80, 0.30))
	for i in range(46):
		draw_rect(Rect2(48.0 + float(i) * 23.0, 306, 11, 26), Color(0.10, 0.10, 0.10))
	_text(360, 356, "MIND THE GAP", 15, Color(0.84, 0.82, 0.76))

	# Barriers and the reader everyone taps without looking
	for i in range(3):
		var bx: float = 210.0 + float(i) * 190.0
		draw_rect(Rect2(bx, 430, 40, 118), Color(0.155, 0.150, 0.145))
		draw_rect(Rect2(bx, 424, 40, 8), Color(0.28, 0.27, 0.26))
		draw_circle(Vector2(bx + 20.0, 452.0), 9.0, C_TFL_BLU.lightened(0.25))
	_label(576, 596, "WAY OUT", 13, Color(0.80, 0.78, 0.72))
	IA.exit_door(self, 56, Color(0.160, 0.145, 0.120))


# The roundel: red ring, blue bar, and the bar always wins the middle
func _draw_roundel(x: float, y: float, r: float) -> void:
	draw_circle(Vector2(x, y), r, C_TFL_RED)
	draw_circle(Vector2(x, y), r - 15.0, Color(0.10, 0.10, 0.12))
	draw_rect(Rect2(x - r - 16.0, y - 15.0, (r + 16.0) * 2.0, 30.0), C_TFL_BLU)
	_label(x, y + 7.0, "UNDERGROUND", 12, Color(0.94, 0.94, 0.96))


# ── The caff ──────────────────────────────────────────────────────────────────
# Not a coffee shop. The warmest room in London, and the only one that feeds you.

func _dress_caff() -> void:
	var wall := Color(0.196, 0.166, 0.128)
	var trim := Color(0.262, 0.216, 0.156)
	IA.shell(self, wall, trim, Color(0.216, 0.180, 0.136))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_CARPET)
	IA.ceiling_light(self, 400.0, C_WARM, _t)
	IA.ceiling_light(self, 800.0, C_WARM, _t)

	# Condensation. The window is the only one in London you cannot see out of,
	# which is exactly why people sit here.
	IA.window(self, 120, 92, 260, 122, Color(0.42, 0.36, 0.28))
	draw_rect(Rect2(126, 98, 248, 110), Color(0.80, 0.84, 0.86, 0.20))
	for i in range(9):
		var dx: float = 138.0 + float(i) * 26.0
		var dl: float = 16.0 + float((i * 7) % 5) * 9.0
		draw_rect(Rect2(dx, 150, 2, dl), Color(0.86, 0.90, 0.92, 0.26))

	# The menu: 47 items, all legible, and no way to tell which are today's
	draw_rect(Rect2(560, 70, 420, 150), Color(0.10, 0.09, 0.08))
	draw_rect(Rect2(566, 76, 408, 138), Color(0.86, 0.84, 0.78))
	_text(578, 100, "FULL ENGLISH .......... 6.50", 12, C_INK)
	_text(578, 120, "EGG & CHIPS ........... 4.20", 12, C_INK)
	_text(578, 140, "BEANS ON TOAST ........ 3.10", 12, C_INK)
	_text(578, 160, "TEA ................... 1.20", 12, C_INK)
	_text(578, 180, "COFFEE ................ 1.40", 12, C_INK)
	_text(578, 202, "ALL DAY BREAKFAST — served all day", 9, Color(0.40, 0.38, 0.34))
	# The specials board, in chalk, in a hand nobody taught to be legible
	draw_rect(Rect2(240, 244, 190, 58), Color(0.070, 0.072, 0.066))
	for i in range(3):
		draw_rect(Rect2(250.0, 256.0 + float(i) * 16.0,
			120.0 - float((i * 31) % 40), 3.0), Color(0.80, 0.82, 0.76, 0.72))

	# Formica, and the tomato that is not a tomato
	for i in range(3):
		var tx: float = 180.0 + float(i) * 300.0
		draw_rect(Rect2(tx, 396, 176, 78), Color(0.325, 0.290, 0.235))
		draw_rect(Rect2(tx, 396, 176, 6), Color(0.44, 0.40, 0.33))
		draw_rect(Rect2(tx + 14.0, 474, 12, 54), Color(0.145, 0.130, 0.110))
		draw_rect(Rect2(tx + 150.0, 474, 12, 54), Color(0.145, 0.130, 0.110))
		draw_circle(Vector2(tx + 88.0, 414.0), 11.0, Color(0.72, 0.16, 0.12))
		draw_rect(Rect2(tx + 85.0, 400, 6, 6), Color(0.20, 0.42, 0.18))

	# The urn. It is always on, and it is the actual heart of the room.
	IA.counter(self, 500, 250, 420, 58, Color(0.190, 0.150, 0.110),
		Color(0.400, 0.350, 0.270))
	draw_rect(Rect2(840, 178, 66, 76), Color(0.62, 0.60, 0.56))
	draw_rect(Rect2(846, 184, 54, 42), Color(0.74, 0.72, 0.68))
	draw_rect(Rect2(864, 254, 18, 10), Color(0.40, 0.38, 0.34))
	var steam: float = 0.4 + 0.3 * sin(_t * 1.3)
	draw_circle(Vector2(873, 168), 16.0, Color(0.90, 0.90, 0.88, 0.05 * steam))
	IA.exit_door(self, 56, Color(0.200, 0.150, 0.105))


# ── Police front counter ──────────────────────────────────────────────────────
# Nobody here will ever say no. They will say it might be difficult.

func _dress_police() -> void:
	var wall := Color(0.132, 0.140, 0.156)
	var trim := Color(0.180, 0.190, 0.210)
	IA.shell(self, wall, trim, Color(0.146, 0.155, 0.172))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.strip_light(self, 260.0, 640.0, Color(0.80, 0.86, 0.92), _t)

	draw_rect(Rect2(452, 58, 250, 38), C_TFL_BLU.darkened(0.35))
	_label(576, 84, "POLICE", 19, Color(0.90, 0.92, 0.96))
	# The lamp. Blue, and the only colour in the room.
	var pulse: float = 0.62 + 0.38 * sin(_t * 1.5)
	draw_rect(Rect2(556, 100, 40, 22), Color(0.10, 0.13, 0.22))
	draw_circle(Vector2(576, 112), 22.0, Color(0.30, 0.52, 0.95, 0.13 * pulse))
	draw_circle(Vector2(576, 110), 8.0, Color(0.58, 0.74, 1.00, 0.86 * pulse))

	# A wall of posters about things that have already happened to other people
	for i in range(4):
		IA.notice(self, 128.0 + float(i) * 82.0, 150, 64, 88,
			Color(0.80, 0.79, 0.74), Color(0.26, 0.26, 0.28))
	_text(130, 262, "FRONT COUNTER OPEN 9 - 5", 10, Color(0.66, 0.68, 0.72))
	_text(130, 278, "LOST PROPERTY — BY APPOINTMENT", 10, Color(0.66, 0.68, 0.72))

	# Reinforced glass, and a counter you cannot lean on
	IA.counter(self, 520, 246, 400, 60, Color(0.115, 0.120, 0.132),
		Color(0.290, 0.300, 0.320))
	IA.glass_screen(self, 520, 130, 400, 116, Color(0.22, 0.24, 0.27))
	draw_rect(Rect2(694, 252, 92, 10), Color(0.16, 0.17, 0.19))

	# A cell, visible past the counter. You are not in it and could be.
	IA.cell_bars(self, 940, 150, 150, 156, Color(0.34, 0.35, 0.38))
	_label(1015, 140, "CUSTODY", 10, Color(0.62, 0.64, 0.70))

	# The line on the floor. Nobody explains it. Everybody obeys it.
	draw_rect(Rect2(300, 452, 560, 4), Color(0.86, 0.80, 0.30, 0.65))
	_label(576, 478, "PLEASE WAIT HERE", 12, Color(0.70, 0.72, 0.76))
	IA.queue_posts(self, 340, 500, 3)
	IA.bench_run(self, 140, 470, 3, Color(0.150, 0.158, 0.170),
		Color(0.190, 0.200, 0.215))
	IA.exit_door(self, 56, Color(0.150, 0.150, 0.150))


# ── A&E ───────────────────────────────────────────────────────────────────────
# "We'll be with you shortly." The screen says four hours. Both are true.

func _dress_hospital() -> void:
	var wall := Color(0.170, 0.180, 0.192)
	var trim := Color(0.235, 0.248, 0.262)
	IA.shell(self, wall, trim, Color(0.186, 0.196, 0.210))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.86, 0.90, 0.94))
	IA.strip_light(self, 150.0, 380.0, Color(0.88, 0.93, 0.97), _t)
	IA.strip_light(self, 640.0, 380.0, Color(0.88, 0.93, 0.97), _t)

	# NHS blue, and a white H. Never Berlin's yellow — that is a Berlin colour.
	draw_rect(Rect2(432, 56, 290, 62), C_NHS)
	draw_rect(Rect2(452, 68, 14, 38), Color(0.96, 0.97, 0.99))
	draw_rect(Rect2(486, 68, 14, 38), Color(0.96, 0.97, 0.99))
	draw_rect(Rect2(452, 82, 48, 12), Color(0.96, 0.97, 0.99))
	_text(520, 96, "A&E", 24, Color(0.96, 0.97, 0.99))
	_label(576, 138, "ACCIDENT & EMERGENCY", 13, Color(0.72, 0.80, 0.88))

	# The screen. It is honest, and being honest does not help.
	draw_rect(Rect2(760, 150, 300, 96), Color(0.055, 0.060, 0.070))
	draw_rect(Rect2(766, 156, 288, 84), Color(0.075, 0.085, 0.100))
	_text(778, 184, "CURRENT WAIT", 12, Color(0.56, 0.68, 0.80))
	var hrs: int = 4 + int(fmod(_t * 0.05, 2.0))
	_text(778, 216, str(hrs) + " HRS 20 MINS", 18, Color(0.42, 0.86, 0.70))

	# Two bays down the far wall. This is what makes it a hospital and not a
	# waiting room with a blue sign: a bed, a rail, a half-drawn curtain.
	IA.hospital_bay(self, 610, 300, Color(0.36, 0.52, 0.44), Color(0.92, 0.93, 0.95))
	# Triage window — the first person who will actually look at you
	IA.counter(self, 150, 246, 330, 58, Color(0.150, 0.160, 0.172),
		Color(0.300, 0.320, 0.340))
	IA.glass_screen(self, 150, 142, 330, 104, Color(0.26, 0.29, 0.32))
	_label(315, 132, "TRIAGE", 13, Color(0.74, 0.82, 0.90))

	# Bolted down, because of what waiting for four hours does to people
	IA.bench_run(self, 130, 424, 5, Color(0.170, 0.180, 0.196),
		Color(0.210, 0.225, 0.245))
	IA.bench_run(self, 640, 424, 5, Color(0.170, 0.180, 0.196),
		Color(0.210, 0.225, 0.245))
	draw_rect(Rect2(1020, 380, 42, 128), Color(0.130, 0.140, 0.155))
	draw_rect(Rect2(1026, 392, 30, 68), Color(0.20, 0.24, 0.28))
	draw_rect(Rect2(982, 356, 24, 44), Color(0.86, 0.90, 0.92))   # hand gel
	IA.plant(self, 900, 470, Color(0.170, 0.180, 0.190))
	IA.exit_door(self, 56, Color(0.180, 0.190, 0.200))


# ── Airport ───────────────────────────────────────────────────────────────────
# The biggest, coldest, brightest room in London, and the way out of it.

func _dress_airport() -> void:
	var wall := Color(0.205, 0.215, 0.232)
	var trim := Color(0.290, 0.305, 0.325)
	IA.shell(self, wall, trim, Color(0.225, 0.238, 0.256))
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, WorldArt.TILE_SIDEWALK)
	IA.floor_sheen(self, Color(0.90, 0.93, 0.97))
	IA.strip_light(self, 120.0, 400.0, Color(0.92, 0.95, 0.99), _t)
	IA.strip_light(self, 640.0, 400.0, Color(0.92, 0.95, 0.99), _t)

	# Real daylight. The only room in the city that admits any.
	draw_rect(Rect2(44, 46, 1064, 84), Color(0.62, 0.70, 0.80, 0.16))
	for i in range(9):
		draw_rect(Rect2(44.0 + float(i) * 124.0, 46, 5, 84), Color(0.34, 0.36, 0.40))

	# The board flaps. It is legible, current, and tells you nothing you need.
	IA.flap_board(self, 300, 146, 560, 5, _t)
	_label(576, 136, "DEPARTURES", 14, Color(0.82, 0.86, 0.92))

	# The aircraft through the glass — bigger than the window, which is the
	# only way an airport ever actually looks.
	IA.apron_view(self, 60, 146, 412, 176, Color(0.10, 0.22, 0.52), "london")

	# Bag drop, and the belt that takes your things somewhere you cannot follow
	IA.counter(self, 480, 250, 440, 60, Color(0.170, 0.180, 0.196),
		Color(0.320, 0.340, 0.365))
	IA.baggage_belt(self, 480, 306, 440, _t)
	_label(700, 236, "BAG DROP", 12, Color(0.78, 0.82, 0.88))

	# The queue is the architecture
	IA.queue_posts(self, 240, 430, 5)
	IA.queue_posts(self, 240, 512, 5)
	draw_rect(Rect2(244, 434, 470, 3), Color(0.55, 0.57, 0.60, 0.55))
	draw_rect(Rect2(244, 516, 470, 3), Color(0.55, 0.57, 0.60, 0.55))

	# Signage that is perfect and useless in equal measure
	draw_rect(Rect2(820, 380, 240, 44), Color(0.06, 0.30, 0.20))
	_text(834, 410, "GATES 1 - 24  →", 15, Color(0.90, 0.94, 0.92))
	draw_rect(Rect2(820, 434, 240, 34), Color(0.10, 0.11, 0.13))
	_text(834, 458, "SECURITY — 25 MIN", 11, Color(0.74, 0.78, 0.84))
	IA.plant(self, 150, 480, Color(0.190, 0.200, 0.215))
	IA.exit_door(self, 56, Color(0.200, 0.210, 0.225))
