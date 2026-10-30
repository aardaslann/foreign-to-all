class_name InteriorArt
extends Object

# Shared drawing primitives for building interiors. Every room in the game is
# the same box — ceiling, back wall, side walls, floor, near wall — so the
# architecture lives here and each building only draws its own furniture.
#
# Geometry (world px, matching the hotel interiors):
#   ceiling  0 .. 46      back wall 46 .. 305
#   floor  305 .. 606     near wall 606 .. 648
#   side walls x 0..44 and 1108..1152

const VW    := 1152.0
const VH    := 648.0
const CEIL  := 46.0
const WALL  := 305.0
const NEAR  := 606.0
const SIDE  := 44.0

const EXT   := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)


# ── Shell ─────────────────────────────────────────────────────────────────────

# wall: main wall colour · trim: skirting//cornice · accent: panel tint
static func shell(ci: CanvasItem, wall: Color, trim: Color, accent: Color) -> void:
	# Void beyond the room
	ci.draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)

	# Ceiling
	ci.draw_rect(Rect2(0, 0, VW, CEIL), wall.darkened(0.45))
	ci.draw_rect(Rect2(0, CEIL - 3, VW, 3), trim.darkened(0.2))

	# Back wall with a faint vertical panel rhythm
	ci.draw_rect(Rect2(0, CEIL, VW, WALL - CEIL), wall)
	for i in range(int(VW / 96.0) + 1):
		ci.draw_rect(Rect2(float(i) * 96.0, CEIL, 46, WALL - CEIL),
			Color(accent.r, accent.g, accent.b, 0.35))
	# Cornice + dado rail
	ci.draw_rect(Rect2(0, CEIL, VW, 4), trim.lightened(0.10))
	ci.draw_rect(Rect2(0, WALL - 74, VW, 5), trim)
	ci.draw_rect(Rect2(0, WALL - 69, VW, 64), wall.darkened(0.18))
	# Skirting where wall meets floor
	ci.draw_rect(Rect2(0, WALL - 10, VW, 10), trim.darkened(0.25))


static func side_walls(ci: CanvasItem, wall: Color, trim: Color) -> void:
	var side := wall.darkened(0.28)
	ci.draw_rect(Rect2(0, CEIL - 10, SIDE, VH - CEIL), side)
	ci.draw_rect(Rect2(SIDE - 4, CEIL - 10, 4, VH - CEIL), trim.darkened(0.45))
	ci.draw_rect(Rect2(VW - SIDE, CEIL - 10, SIDE, VH - CEIL), side)
	ci.draw_rect(Rect2(VW - SIDE, CEIL - 10, 4, VH - CEIL), trim.darkened(0.45))
	# Near wall, seen from above
	ci.draw_rect(Rect2(0, NEAR, VW, VH - NEAR), wall.darkened(0.38))
	ci.draw_rect(Rect2(0, NEAR, VW, 4), trim.darkened(0.1))


static func floor_tiles(ci: CanvasItem, tile: int) -> void:
	WorldArt.draw_tiles(ci, tile, Rect2(SIDE, WALL, VW - SIDE * 2, NEAR - WALL + 4))
	# Contact shadow along the back wall — grounds the room
	ci.draw_rect(Rect2(SIDE, WALL, VW - SIDE * 2, 10), Color(0, 0, 0, 0.22))
	ci.draw_rect(Rect2(SIDE, WALL, VW - SIDE * 2, 4), Color(0, 0, 0, 0.14))


# Glossy institutional floor: a pale sheen band, good for clinics and airports
static func floor_sheen(ci: CanvasItem, col: Color) -> void:
	for i in range(6):
		var x := 120.0 + float(i) * 180.0
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(x, WALL + 12), Vector2(x + 46, WALL + 12),
			Vector2(x - 30, NEAR), Vector2(x - 76, NEAR),
		]), Color(col.r, col.g, col.b, 0.05))


# ── Openings ──────────────────────────────────────────────────────────────────

# Window onto the street, tinted by time of day
static func window(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void:
	ci.draw_rect(Rect2(x - 6, y - 6, w + 12, h + 12), frame.darkened(0.35))
	ci.draw_rect(Rect2(x, y, w, h), frame.darkened(0.6))
	var morning := GameState.is_morning()
	if morning:
		ci.draw_rect(Rect2(x + 4, y + 4, w - 8, h * 0.62), Color(0.42, 0.58, 0.74))
		ci.draw_rect(Rect2(x + 4, y + 4 + h * 0.62, w - 8, h * 0.20), Color(0.72, 0.72, 0.62, 0.9))
		ci.draw_rect(Rect2(x + 4, y + 4 + h * 0.82, w - 8, h * 0.18 - 8), Color(0.30, 0.44, 0.26))
	else:
		ci.draw_rect(Rect2(x + 4, y + 4, w - 8, h * 0.50), Color(0.072, 0.058, 0.148))
		ci.draw_rect(Rect2(x + 4, y + 4 + h * 0.50, w - 8, h * 0.22), Color(0.160, 0.090, 0.182))
		ci.draw_rect(Rect2(x + 4, y + 4 + h * 0.72, w - 8, h * 0.14), Color(0.380, 0.200, 0.158, 0.85))
		ci.draw_rect(Rect2(x + 4, y + 4 + h * 0.86, w - 8, h * 0.14 - 8), Color(0.046, 0.042, 0.088))
	# Mullions
	ci.draw_rect(Rect2(x + w * 0.5 - 2, y, 4, h), frame.darkened(0.35))
	ci.draw_rect(Rect2(x, y + h * 0.46, w, 4), frame.darkened(0.35))


# Doorway back to the street (drawn on the left side wall)
static func exit_door(ci: CanvasItem, x: float, wood: Color) -> void:
	ci.draw_rect(Rect2(x - 6, 120, 96, WALL - 120 + 2), wood.darkened(0.55))
	ci.draw_rect(Rect2(x, 126, 84, WALL - 128), wood)
	ci.draw_rect(Rect2(x + 8, 136, 68, 62), wood.darkened(0.28))
	ci.draw_rect(Rect2(x + 8, 208, 68, 70), wood.darkened(0.28))
	ci.draw_circle(Vector2(x + 72, 226), 4.0, Color(0.62, 0.52, 0.26))
	# Daylight leaking under the door
	ci.draw_rect(Rect2(x, WALL - 6, 84, 6), Color(0.9, 0.8, 0.5, 0.10))


# ── Fittings ──────────────────────────────────────────────────────────────────

# A service counter: top slab, panelled front, contact shadow
static func counter(ci: CanvasItem, x: float, y: float, w: float, h: float,
		body: Color, top: Color) -> void:
	ci.draw_rect(Rect2(x - 4, y + h - 6, w + 8, 14), Color(0, 0, 0, 0.22))
	ci.draw_rect(Rect2(x, y, w, h), body.darkened(0.4))
	ci.draw_rect(Rect2(x + 3, y + 3, w - 6, h - 6), body)
	var panels := int(w / 88.0)
	for i in range(panels):
		ci.draw_rect(Rect2(x + 12 + float(i) * 88.0, y + 14, 64, h - 28), body.darkened(0.22))
	# Top slab, slightly overhanging
	ci.draw_rect(Rect2(x - 8, y - 14, w + 16, 16), top.darkened(0.35))
	ci.draw_rect(Rect2(x - 8, y - 14, w + 16, 4), top)


# Glass partition above a counter — the universal sign of officialdom
static func glass_screen(ci: CanvasItem, x: float, y: float, w: float, h: float,
		frame: Color) -> void:
	ci.draw_rect(Rect2(x, y, w, h), Color(0.62, 0.78, 0.86, 0.10))
	ci.draw_rect(Rect2(x, y, w, 4), frame)
	ci.draw_rect(Rect2(x, y + h - 4, w, 4), frame)
	ci.draw_rect(Rect2(x, y, 4, h), frame)
	ci.draw_rect(Rect2(x + w - 4, y, 4, h), frame)
	# Speaking grille + a slot to pass things through
	ci.draw_circle(Vector2(x + w * 0.5, y + h * 0.46), 13.0, Color(0.10, 0.11, 0.15, 0.55))
	for i in range(4):
		ci.draw_rect(Rect2(x + w * 0.5 - 9, y + h * 0.46 - 6 + float(i) * 4.0, 18, 2),
			Color(0.04, 0.05, 0.07, 0.7))
	ci.draw_rect(Rect2(x + w * 0.5 - 26, y + h - 16, 52, 6), Color(0.05, 0.06, 0.09, 0.8))
	# Reflection streak
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x + 14, y + h), Vector2(x + 44, y + h),
		Vector2(x + 78, y + 4), Vector2(x + 48, y + 4),
	]), Color(1, 1, 1, 0.045))


# Wall sign board with unreadable lettering (the alien can't read yet)
static func sign(ci: CanvasItem, x: float, y: float, w: float, h: float,
		board: Color, ink: Color, marks: int = 5) -> void:
	ci.draw_rect(Rect2(x - 3, y - 3, w + 6, h + 6), board.darkened(0.45))
	ci.draw_rect(Rect2(x, y, w, h), board)
	var step := w / float(marks + 1)
	for i in range(marks):
		var lx := x + step * (float(i) + 0.5)
		ci.draw_line(Vector2(lx, y + h * 0.34), Vector2(lx + step * 0.55, y + h * 0.66),
			ink, 3.0)


# Framed notice / poster
static func notice(ci: CanvasItem, x: float, y: float, w: float, h: float,
		paper: Color, ink: Color) -> void:
	ci.draw_rect(Rect2(x - 2, y - 2, w + 4, h + 4), Color(0.18, 0.15, 0.12))
	ci.draw_rect(Rect2(x, y, w, h), paper)
	for i in range(int(h / 9.0) - 1):
		var lw := w - 12.0 - float((i * 7) % 20)
		ci.draw_rect(Rect2(x + 6, y + 8 + float(i) * 9.0, lw, 2), Color(ink.r, ink.g, ink.b, 0.5))


# Ceiling lamp with a glow and a pool of light on the floor
static func ceiling_light(ci: CanvasItem, x: float, warm: Color, t: float,
		drop: float = 34.0) -> void:
	var gl := 0.9 + 0.1 * sin(t * 2.2 + x * 0.01)
	ci.draw_rect(Rect2(x - 2, 0, 4, drop), Color(0.10, 0.09, 0.11))
	ci.draw_rect(Rect2(x - 26, drop, 52, 8), Color(0.14, 0.13, 0.16))
	ci.draw_rect(Rect2(x - 22, drop + 8, 44, 5), Color(warm.r, warm.g, warm.b, 0.85 * gl))
	ci.draw_circle(Vector2(x, drop + 10), 30.0, Color(warm.r, warm.g, warm.b, 0.07 * gl))
	_pool(ci, Vector2(x, 470), 150.0, 46.0, Color(warm.r, warm.g, warm.b, 0.045 * gl))


# Long fluorescent batten — clinics, offices, stations
static func strip_light(ci: CanvasItem, x: float, w: float, cool: Color, t: float) -> void:
	var flick := 1.0 if fmod(t * 0.7 + x, 9.0) > 0.08 else 0.55
	ci.draw_rect(Rect2(x, 16, w, 10), Color(0.16, 0.17, 0.20))
	ci.draw_rect(Rect2(x + 3, 26, w - 6, 5), Color(cool.r, cool.g, cool.b, 0.9 * flick))
	ci.draw_rect(Rect2(x, 31, w, 16), Color(cool.r, cool.g, cool.b, 0.06 * flick))
	_pool(ci, Vector2(x + w * 0.5, 450), w * 0.8, 54.0,
		Color(cool.r, cool.g, cool.b, 0.035 * flick))


static func _pool(ci: CanvasItem, c: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for s in range(22):
		var a := float(s) / 22.0 * TAU
		pts.append(Vector2(c.x + cos(a) * rx, c.y + sin(a) * ry))
	ci.draw_colored_polygon(pts, col)


# Waiting-room seating: a run of linked chairs
static func bench_run(ci: CanvasItem, x: float, y: float, seats: int,
		frame: Color, seat: Color) -> void:
	var w := float(seats) * 46.0
	ci.draw_rect(Rect2(x - 4, y + 30, w + 8, 10), Color(0, 0, 0, 0.20))
	ci.draw_rect(Rect2(x, y, w, 8), frame)                      # rail
	for i in range(seats):
		var sx := x + float(i) * 46.0 + 3.0
		ci.draw_rect(Rect2(sx, y - 26, 40, 26), seat.darkened(0.3))   # back
		ci.draw_rect(Rect2(sx + 2, y - 24, 36, 22), seat)
		ci.draw_rect(Rect2(sx, y + 4, 40, 12), seat.darkened(0.15))   # cushion
		ci.draw_rect(Rect2(sx + 4, y + 16, 5, 22), frame)             # legs
		ci.draw_rect(Rect2(sx + 31, y + 16, 5, 22), frame)


# ── Frontages ─────────────────────────────────────────────────────────────────
# What a building looks like from the street, by trade. Drawn at the door's own
# x so the sign, the frontage and the building behind the door are the same
# building — they used to be placed independently and disagreed.
#
# `kind`: shop | food | pharmacy | civic | transit | lodging | medical | money

static func frontage(ci: CanvasItem, x: float, ground_y: float, base_y: float,
		kind: String, accent: Color, glass: Color, t: float) -> void:
	var w: float = 150.0
	var h: float = base_y - ground_y
	# Glazing common to every trade, then the details that name it
	ci.draw_rect(Rect2(x - w * 0.5, ground_y, w, h), glass.darkened(0.35))
	ci.draw_rect(Rect2(x - w * 0.5 + 6.0, ground_y + 6.0, w - 12.0, h - 12.0), glass)

	match kind:
		"pharmacy":
			# A lit cross and a window of nothing but boxes
			ci.draw_rect(Rect2(x - 13.0, ground_y - 44.0, 26.0, 26.0),
				Color(0.06, 0.09, 0.07))
			var pulse: float = 0.75 + 0.25 * sin(t * 1.4)
			ci.draw_rect(Rect2(x - 9.0, ground_y - 35.0, 18.0, 6.0),
				Color(accent.r, accent.g, accent.b, pulse))
			ci.draw_rect(Rect2(x - 3.0, ground_y - 41.0, 6.0, 18.0),
				Color(accent.r, accent.g, accent.b, pulse))
			for i in range(10):
				ci.draw_rect(Rect2(x - 62.0 + float(i) * 13.0, ground_y + h - 34.0,
					9.0, 22.0), Color(0.86, 0.84, 0.78, 0.55))
		"food":
			# Steam, a menu card, and something turning behind the glass
			for i in range(3):
				ci.draw_rect(Rect2(x - 50.0 + float(i) * 36.0, ground_y + 18.0,
					28.0, 34.0), accent.darkened(0.20))
			ci.draw_rect(Rect2(x + 26.0, ground_y + 14.0, 40.0, 52.0),
				Color(0.94, 0.92, 0.86, 0.85))
			var s: float = 0.3 + 0.25 * sin(t * 1.2)
			ci.draw_circle(Vector2(x - 30.0, ground_y + 8.0), 18.0,
				Color(0.95, 0.94, 0.90, 0.05 * s))
		"money":
			# A rate board, and bars on the glass
			ci.draw_rect(Rect2(x - 58.0, ground_y + 12.0, 116.0, 46.0),
				Color(0.055, 0.055, 0.050))
			for r in range(3):
				ci.draw_rect(Rect2(x - 52.0, ground_y + 18.0 + float(r) * 13.0,
					38.0, 4.0), Color(0.42, 0.88, 0.52, 0.85))
				ci.draw_rect(Rect2(x + 8.0, ground_y + 18.0 + float(r) * 13.0,
					38.0, 4.0), Color(0.90, 0.44, 0.38, 0.85))
			for b in range(7):
				ci.draw_rect(Rect2(x - 54.0 + float(b) * 18.0, ground_y + 6.0,
					3.0, h - 12.0), Color(0.30, 0.30, 0.32))
		"civic":
			# Blue lamp, a crest, and a door that is heavier than the others
			ci.draw_rect(Rect2(x - 14.0, ground_y - 30.0, 28.0, 16.0),
				Color(0.10, 0.14, 0.24))
			var blink: float = 0.6 + 0.4 * sin(t * 1.6)
			ci.draw_circle(Vector2(x, ground_y - 22.0), 15.0,
				Color(0.30, 0.52, 0.95, 0.14 * blink))
			ci.draw_circle(Vector2(x, ground_y - 22.0), 6.0,
				Color(0.58, 0.74, 1.00, 0.85 * blink))
			ci.draw_rect(Rect2(x - 26.0, ground_y + 10.0, 52.0, h - 20.0),
				accent.darkened(0.30))
		"medical":
			# A&E / ACİL: an illuminated box and an ambulance bay marking
			ci.draw_rect(Rect2(x - 52.0, ground_y - 40.0, 104.0, 30.0), accent)
			ci.draw_rect(Rect2(x - 12.0, ground_y - 34.0, 8.0, 18.0),
				Color(0.96, 0.97, 0.99))
			ci.draw_rect(Rect2(x + 2.0, ground_y - 34.0, 8.0, 18.0),
				Color(0.96, 0.97, 0.99))
			ci.draw_rect(Rect2(x - 12.0, ground_y - 27.0, 22.0, 5.0),
				Color(0.96, 0.97, 0.99))
			ci.draw_rect(Rect2(x - 66.0, base_y - 6.0, 132.0, 5.0),
				Color(0.90, 0.78, 0.20, 0.65))
		"transit":
			# A mouth in the ground with steps going down into it
			ci.draw_rect(Rect2(x - 54.0, ground_y + 4.0, 108.0, h - 4.0),
				Color(0.035, 0.035, 0.045))
			for st in range(4):
				ci.draw_rect(Rect2(x - 48.0 + float(st) * 4.0,
					ground_y + 12.0 + float(st) * 11.0,
					96.0 - float(st) * 8.0, 4.0), Color(0.34, 0.34, 0.38))
			ci.draw_rect(Rect2(x - 58.0, ground_y, 116.0, 7.0), accent)
		"lodging":
			# Lit rooms above, and a canopy over the door
			ci.draw_rect(Rect2(x - 62.0, ground_y - 18.0, 124.0, 14.0),
				accent.darkened(0.25))
			ci.draw_rect(Rect2(x - 62.0, ground_y - 18.0, 124.0, 4.0), accent)
			for i in range(3):
				ci.draw_rect(Rect2(x - 44.0 + float(i) * 34.0, ground_y + 16.0,
					22.0, 30.0), Color(0.96, 0.86, 0.60, 0.70))
		_:
			# Generic shop: a stallriser and a door with a bell on it
			ci.draw_rect(Rect2(x - w * 0.5 + 6.0, base_y - 20.0, w - 12.0, 20.0),
				accent.darkened(0.40))
			ci.draw_rect(Rect2(x + 30.0, ground_y + 10.0, 34.0, h - 30.0),
				accent.darkened(0.20))

	# Mullions last, over whatever the trade drew, so it reads as behind glass
	for g in range(4):
		ci.draw_rect(Rect2(x - w * 0.5 + 6.0 + float(g) * ((w - 12.0) / 4.0),
			ground_y + 6.0, 3.0, h - 12.0), Color(0.62, 0.63, 0.62, 0.55))


# The sign over a door, painted from the door's own sign_text.
static func fascia(ci: CanvasItem, x: float, y: float, label: String,
		board: Color, ink: Color, lit: bool) -> void:
	var font: Font = ThemeDB.fallback_font
	var sz: Vector2 = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	var w: float = maxf(sz.x + 40.0, 120.0)
	ci.draw_rect(Rect2(x - w * 0.5 - 3.0, y - 3.0, w + 6.0, 38.0), ink.darkened(0.5))
	ci.draw_rect(Rect2(x - w * 0.5, y, w, 32.0), board)
	ci.draw_string(font, Vector2(x - sz.x * 0.5, y + 23.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink)
	if lit:
		ci.draw_rect(Rect2(x - w * 0.5 - 5.0, y - 5.0, w + 10.0, 42.0),
			Color(1.0, 0.96, 0.86, 0.05))


# ── What a building is FOR ────────────────────────────────────────────────────
# A counter in a room tells you nothing. These are the objects that make a
# space unmistakably a hospital, a police station, an airport or a station —
# the thing you would name if someone showed you one frame of it.

# Hospital bay: bed, rail, half-drawn curtain, drip stand. The curtain being
# half-drawn is the whole point — you can see there is a person and not who.
static func hospital_bay(ci: CanvasItem, x: float, y: float, curtain: Color,
		linen: Color) -> void:
	ci.draw_rect(Rect2(x, y - 96, 4, 96), Color(0.62, 0.64, 0.66))     # rail posts
	ci.draw_rect(Rect2(x + 150, y - 96, 4, 96), Color(0.62, 0.64, 0.66))
	ci.draw_rect(Rect2(x - 4, y - 100, 162, 5), Color(0.70, 0.72, 0.74))
	# Bed: frame, mattress, folded sheet, pillow
	ci.draw_rect(Rect2(x + 14, y - 34, 124, 34), Color(0.42, 0.44, 0.47))
	ci.draw_rect(Rect2(x + 14, y - 40, 124, 10), linen)
	ci.draw_rect(Rect2(x + 18, y - 38, 40, 7), linen.lightened(0.25))  # pillow
	ci.draw_rect(Rect2(x + 10, y - 46, 10, 46), Color(0.55, 0.57, 0.60))
	ci.draw_rect(Rect2(x + 132, y - 30, 10, 30), Color(0.55, 0.57, 0.60))
	for w in range(2):
		ci.draw_circle(Vector2(x + 24 + float(w) * 104, y + 2), 5.0,
			Color(0.16, 0.16, 0.18))
	# Curtain, drawn across two thirds of the bay
	ci.draw_rect(Rect2(x + 96, y - 96, 60, 96), curtain)
	for f in range(6):
		ci.draw_rect(Rect2(x + 98 + float(f) * 10, y - 96, 3, 96),
			curtain.darkened(0.18))
	# Drip stand — the object that says "medicine" faster than any sign
	ci.draw_rect(Rect2(x + 4, y - 116, 3, 116), Color(0.72, 0.74, 0.76))
	ci.draw_rect(Rect2(x - 6, y - 128, 24, 14), Color(0.86, 0.90, 0.88, 0.75))
	ci.draw_rect(Rect2(x + 4, y - 114, 2, 30), Color(0.78, 0.86, 0.82, 0.6))
	ci.draw_rect(Rect2(x - 8, y - 4, 24, 4), Color(0.62, 0.64, 0.66))


# A cell. Bars, a bench, and a dark you cannot see the back of.
static func cell_bars(ci: CanvasItem, x: float, y: float, w: float, h: float,
		bar: Color) -> void:
	ci.draw_rect(Rect2(x, y, w, h), Color(0.035, 0.035, 0.042))
	ci.draw_rect(Rect2(x + 10, y + h - 44, w - 20, 12), Color(0.14, 0.14, 0.16))
	ci.draw_rect(Rect2(x + 14, y + h - 32, 8, 32), Color(0.11, 0.11, 0.13))
	ci.draw_rect(Rect2(x + w - 22, y + h - 32, 8, 32), Color(0.11, 0.11, 0.13))
	var n: int = int(w / 22.0)
	for i in range(n):
		ci.draw_rect(Rect2(x + 6.0 + float(i) * 22.0, y, 5, h), bar)
	ci.draw_rect(Rect2(x, y, w, 7), bar.darkened(0.2))
	ci.draw_rect(Rect2(x, y + h - 7, w, 7), bar.darkened(0.2))
	# The lock plate, at the height a hand would be
	ci.draw_rect(Rect2(x + w * 0.5 - 12, y + h * 0.5, 24, 18), bar.lightened(0.15))


# The window onto the apron, with an aircraft standing at the gate behind it.
#
# The first version drew the fuselage twenty pixels past the glass on both
# sides "because it does not fit", with nothing but two thin bars for a frame -
# so the aeroplane came out painted on the terminal wall. It fits inside the
# opening now, and the frame and its mullions are drawn OVER the glass, which
# is both the fix and the thing that makes it read as a window at all: you
# believe a pane because something crosses in front of it.
# What is out of the window beyond the apron. Every airport on Earth looks the
# same inside, and the only thing that tells a traveller where they have landed
# is the shape on the horizon past the aircraft - which is exactly the alien's
# problem stated as a picture. Without this all twenty terminals were one
# terminal with a different tail fin on it.
#
# kind: "peaks" · "towers" · "low" · "palms" · "crater" · "domes" · "hills"
const HORIZON := {
	"zurich":   ["peaks",  0.62], "lapaz":    ["peaks",  0.78],
	"tbilisi":  ["hills",  0.54], "seoul":    ["hills",  0.44],
	"newyork":  ["towers", 0.72], "toronto":  ["towers", 0.60],
	"saopaulo": ["towers", 0.80], "tokyo":    ["towers", 0.52],
	"mumbai":   ["towers", 0.46], "moscow":   ["low",    0.34],
	"london":   ["low",    0.30], "berlin":   ["low",    0.32],
	"paris":    ["low",    0.34], "rome":     ["low",    0.30],
	"mexico":   ["hills",  0.48], "istanbul": ["domes",  0.40],
	"dakar":    ["palms",  0.36], "hanoi":    ["palms",  0.34],
	"honolulu": ["crater", 0.50], "sydney":   ["low",    0.36],
}


static func horizon(ci: CanvasItem, x: float, y: float, w: float, h: float,
		city: String) -> void:
	var spec: Array = HORIZON.get(city, ["low", 0.32])
	var kind: String = String(spec[0])
	var amt: float = float(spec[1])
	var base: float = y + h * 0.62
	var far := Color(0.400, 0.475, 0.573, 0.85)
	var near := Color(0.318, 0.384, 0.482, 0.92)
	match kind:
		"peaks":
			for i in range(5):
				var px: float = x + w * (0.18 + 0.16 * float(i))
				var ph: float = h * amt * (0.62 + 0.38 * float((i * 7) % 3) / 2.0)
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(px - w * 0.14, base), Vector2(px, base - ph),
					Vector2(px + w * 0.14, base),
				]), far if (i % 2) else near)
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(px - w * 0.055, base - ph * 0.66),
					Vector2(px, base - ph), Vector2(px + w * 0.055,
					base - ph * 0.66),
				]), Color(0.827, 0.867, 0.902, 0.95))
		"hills":
			for i in range(6):
				var hx: float = x + w * (0.14 + 0.144 * float(i))
				var hh: float = h * amt * (0.5 + 0.5 * float((i * 5) % 4) / 3.0)
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(hx - w * 0.13, base), Vector2(hx - w * 0.06,
					base - hh), Vector2(hx + w * 0.06, base - hh),
					Vector2(hx + w * 0.13, base),
				]), far if (i % 2) else near)
		"towers":
			for i in range(11):
				var tx: float = x + w * (0.015 + 0.0875 * float(i))
				var th: float = h * amt * (0.34 + 0.66 * float((i * 11) % 7) / 6.0)
				var tw: float = w * (0.040 + 0.016 * float((i * 3) % 3))
				ci.draw_rect(Rect2(tx, base - th, tw, th),
					far if (i % 2) else near)
		"low":
			for i in range(14):
				var lx: float = x + w * (0.008 + 0.0695 * float(i))
				var lh: float = h * amt * (0.4 + 0.6 * float((i * 13) % 5) / 4.0)
				ci.draw_rect(Rect2(lx, base - lh, w * 0.064, lh),
					far if (i % 2) else near)
		"palms":
			ci.draw_rect(Rect2(x, base - h * amt * 0.42, w, h * amt * 0.42), far)
			for i in range(5):
				var mx: float = x + w * (0.12 + 0.19 * float(i))
				var mh: float = h * amt * (0.8 + 0.4 * float((i * 3) % 2))
				ci.draw_rect(Rect2(mx - 2.0, base - mh, 4.0, mh), near)
				for f in range(5):
					var a: float = -PI + PI * (float(f) + 0.5) / 5.0
					ci.draw_line(Vector2(mx, base - mh),
						Vector2(mx + cos(a) * w * 0.045,
						base - mh + sin(a) * h * 0.055), near, 2.5)
		"crater":
			ci.draw_colored_polygon(PackedVector2Array([
				Vector2(x + w * 0.42, base), Vector2(x + w * 0.56,
				base - h * amt * 0.82), Vector2(x + w * 0.76,
				base - h * amt * 0.96), Vector2(x + w * 0.98, base),
			]), near)
			ci.draw_rect(Rect2(x, base - h * amt * 0.20, w * 0.44,
				h * amt * 0.20), far)
		"domes":
			ci.draw_rect(Rect2(x, base - h * amt * 0.44, w, h * amt * 0.44), far)
			for i in range(3):
				var dx: float = x + w * (0.20 + 0.27 * float(i))
				var dr: float = w * 0.052
				ci.draw_circle(Vector2(dx, base - h * amt * 0.62), dr, near)
				ci.draw_rect(Rect2(dx - dr, base - h * amt * 0.62, dr * 2.0,
					h * amt * 0.62), near)
				ci.draw_rect(Rect2(dx + dr * 1.5, base - h * amt * 1.10, 4.0,
					h * amt * 1.10), near)


static func apron_view(ci: CanvasItem, x: float, y: float, w: float, h: float,
		livery: Color, city: String = "") -> void:
	# Sky, then the apron, then the ground markings on it.
	ci.draw_rect(Rect2(x, y, w, h), Color(0.44, 0.52, 0.62, 0.55))
	ci.draw_rect(Rect2(x, y, w, h * 0.34), Color(0.36, 0.44, 0.56, 0.55))
	# Whatever is past the fence, before the apron goes over the top of it.
	if not city.is_empty():
		horizon(ci, x, y, w, h, city)
	ci.draw_rect(Rect2(x, y + h * 0.62, w, h * 0.38), Color(0.24, 0.26, 0.29))
	for m in range(3):
		ci.draw_rect(Rect2(x + w * (0.12 + 0.30 * float(m)), y + h * 0.86,
			w * 0.16, 3.0), Color(0.86, 0.76, 0.30, 0.60))

	# The aircraft, inside the opening. Nose to the left, tail to the right.
	var fy: float = y + h * 0.42
	var fh: float = h * 0.20
	var nose: float = x + w * 0.04
	var tail: float = x + w * 0.96
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(nose, fy + fh * 0.55), Vector2(nose + w * 0.10, fy),
		Vector2(tail, fy), Vector2(tail, fy + fh),
		Vector2(nose + w * 0.10, fy + fh),
	]), Color(0.88, 0.89, 0.91))
	ci.draw_rect(Rect2(nose + w * 0.10, fy, tail - nose - w * 0.10, 3.0),
		Color(0.96, 0.97, 0.98))
	ci.draw_rect(Rect2(nose + w * 0.08, fy + fh * 0.62, tail - nose - w * 0.08,
		fh * 0.22), livery)
	# Windows along it, and the flight deck up at the nose.
	var ports: int = maxi(3, int(w / 30.0))
	for pnum in range(ports):
		ci.draw_rect(Rect2(nose + w * 0.16 + float(pnum) * (w * 0.72
			/ float(ports)), fy + fh * 0.22, w * 0.030, fh * 0.24),
			Color(0.12, 0.14, 0.18))
	ci.draw_rect(Rect2(nose + w * 0.05, fy + fh * 0.16, w * 0.055, fh * 0.26),
		Color(0.14, 0.16, 0.20))
	# Tail fin, raked back, in the livery.
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(tail - w * 0.16, fy), Vector2(tail - w * 0.05, y + h * 0.10),
		Vector2(tail, y + h * 0.10), Vector2(tail, fy),
	]), livery)
	# An engine slung under the wing, and the wing itself going away from you.
	ci.draw_rect(Rect2(x + w * 0.34, fy + fh, w * 0.16, fh * 0.46),
		Color(0.80, 0.82, 0.84))
	ci.draw_rect(Rect2(x + w * 0.34, fy + fh, w * 0.16, 3.0),
		Color(0.90, 0.91, 0.93))
	# The jet bridge, reaching in from the left to the forward door.
	ci.draw_rect(Rect2(x, fy - h * 0.16, w * 0.30, h * 0.17),
		Color(0.62, 0.64, 0.67))
	ci.draw_rect(Rect2(x, fy - h * 0.16, w * 0.30, 4.0),
		Color(0.74, 0.76, 0.79))

	# The frame. Over everything, which is what sells the glass.
	var fr := Color(0.34, 0.36, 0.40)
	ci.draw_rect(Rect2(x - 7.0, y - 7.0, w + 14.0, 9.0), fr)
	ci.draw_rect(Rect2(x - 7.0, y + h - 2.0, w + 14.0, 11.0), fr)
	ci.draw_rect(Rect2(x - 7.0, y - 7.0, 9.0, h + 16.0), fr)
	ci.draw_rect(Rect2(x + w - 2.0, y - 7.0, 9.0, h + 16.0), fr)
	var bays: int = maxi(2, int(w / 110.0))
	for b in range(1, bays):
		ci.draw_rect(Rect2(x + w * float(b) / float(bays) - 3.0, y, 6.0, h), fr)
	ci.draw_rect(Rect2(x, y + h * 0.5 - 2.5, w, 5.0), fr.darkened(0.10))
	# A sill, and the reflection lying along it.
	ci.draw_rect(Rect2(x - 11.0, y + h + 9.0, w + 22.0, 6.0), fr.lightened(0.18))
	ci.draw_rect(Rect2(x + 4.0, y + 4.0, w * 0.34, h * 0.10),
		Color(1.0, 1.0, 1.0, 0.07))


# A train standing at the platform, doors open, lit from inside.
static func train_at_platform(ci: CanvasItem, x: float, y: float, w: float,
		livery: Color, t: float) -> void:
	var h: float = 132.0
	ci.draw_rect(Rect2(x, y - h, w, h), Color(0.055, 0.055, 0.065))   # the tunnel dark
	ci.draw_rect(Rect2(x, y - h + 14, w, h - 26), Color(0.82, 0.84, 0.86))
	ci.draw_rect(Rect2(x, y - h + 14, w, 8), livery)
	ci.draw_rect(Rect2(x, y - 26, w, 10), livery)
	# Windows and open doors, warm inside against the cold platform
	var bays: int = int(w / 132.0)
	for b in range(bays):
		var bx: float = x + 16.0 + float(b) * 132.0
		ci.draw_rect(Rect2(bx, y - h + 34, 74, 44), Color(0.30, 0.36, 0.42))
		ci.draw_rect(Rect2(bx + 82, y - h + 30, 38, 76), Color(0.96, 0.90, 0.72, 0.85))
		ci.draw_rect(Rect2(bx + 82, y - h + 30, 3, 76), livery.darkened(0.25))
		ci.draw_rect(Rect2(bx + 117, y - h + 30, 3, 76), livery.darkened(0.25))
	# Bogies and the gap you are told to mind
	for g in range(int(w / 90.0)):
		ci.draw_rect(Rect2(x + 30.0 + float(g) * 90.0, y - 16, 46, 16),
			Color(0.10, 0.10, 0.12))
	var blink: float = 0.5 + 0.5 * sin(t * 4.0)
	ci.draw_rect(Rect2(x + w - 26, y - h + 20, 12, 6),
		Color(0.95, 0.35, 0.25, blink))


# Baggage belt: a moving rubber loop with cases on it.
static func baggage_belt(ci: CanvasItem, x: float, y: float, w: float,
		t: float) -> void:
	ci.draw_rect(Rect2(x, y, w, 30), Color(0.14, 0.14, 0.16))
	ci.draw_rect(Rect2(x, y, w, 5), Color(0.24, 0.24, 0.27))
	var off: float = fmod(t * 26.0, 44.0)
	for i in range(int(w / 44.0) + 1):
		ci.draw_rect(Rect2(x + fmod(float(i) * 44.0 - off, w), y + 8, 22, 3),
			Color(0.22, 0.22, 0.25))
	var cases := [Color(0.32, 0.16, 0.14), Color(0.16, 0.22, 0.32),
		Color(0.20, 0.20, 0.22)]
	for c in range(3):
		var cx: float = x + fmod(float(c) * 190.0 + t * 26.0, w - 60.0)
		ci.draw_rect(Rect2(cx, y - 30, 56, 32), cases[c % cases.size()])
		ci.draw_rect(Rect2(cx + 4, y - 26, 48, 4), Color(1, 1, 1, 0.10))
		ci.draw_rect(Rect2(cx + 20, y - 38, 16, 9), Color(0.12, 0.12, 0.14))


static func plant(ci: CanvasItem, x: float, y: float, pot: Color) -> void:
	ci.draw_rect(Rect2(x - 16, y + 24, 34, 8), Color(0, 0, 0, 0.20))
	ci.draw_rect(Rect2(x - 14, y, 28, 26), pot.darkened(0.3))
	ci.draw_rect(Rect2(x - 12, y + 2, 24, 22), pot)
	ci.draw_circle(Vector2(x, y - 18), 19.0, Color(0.075, 0.150, 0.095))
	ci.draw_circle(Vector2(x - 13, y - 6), 12.0, Color(0.090, 0.170, 0.110))
	ci.draw_circle(Vector2(x + 13, y - 8), 13.0, Color(0.065, 0.135, 0.085))
	ci.draw_circle(Vector2(x + 2, y - 32), 11.0, Color(0.085, 0.160, 0.105))


# Departure/arrival style split-flap board
static func flap_board(ci: CanvasItem, x: float, y: float, w: float, rows: int,
		t: float) -> void:
	var h := 18.0 + float(rows) * 20.0
	ci.draw_rect(Rect2(x - 5, y - 5, w + 10, h + 10), Color(0.10, 0.10, 0.13))
	ci.draw_rect(Rect2(x, y, w, h), Color(0.045, 0.048, 0.062))
	ci.draw_rect(Rect2(x, y, w, 14), Color(0.09, 0.10, 0.13))
	for r in range(rows):
		var ry := y + 18.0 + float(r) * 20.0
		# Flapping cells — one row shuffles at a time
		var live: bool = int(t * 1.5) % maxi(rows, 1) == r
		for c in range(int(w / 34.0)):
			var cx := x + 8.0 + float(c) * 34.0
			var lit := ((r * 5 + c * 3 + int(t * 1.5)) % 4 != 0)
			var col := Color(0.85, 0.72, 0.28) if lit else Color(0.16, 0.15, 0.13)
			if live and c % 3 == int(t * 8.0) % 3:
				col = Color(0.95, 0.88, 0.55)
			ci.draw_rect(Rect2(cx, ry, 26, 13), col)
			ci.draw_rect(Rect2(cx, ry + 6, 26, 1), Color(0, 0, 0, 0.35))


# Rope-and-post queue line
static func queue_posts(ci: CanvasItem, x: float, y: float, count: int) -> void:
	for i in range(count):
		var px := x + float(i) * 110.0
		ci.draw_rect(Rect2(px - 12, y + 40, 24, 6), Color(0, 0, 0, 0.22))
		ci.draw_rect(Rect2(px - 10, y + 36, 20, 6), Color(0.22, 0.20, 0.24))
		ci.draw_rect(Rect2(px - 3, y, 6, 38), Color(0.30, 0.28, 0.32))
		ci.draw_circle(Vector2(px, y - 2), 5.0, Color(0.55, 0.48, 0.26))
		if i < count - 1:
			ci.draw_line(Vector2(px + 4, y + 6), Vector2(px + 106, y + 6),
				Color(0.42, 0.18, 0.20), 3.0)
			ci.draw_line(Vector2(px + 4, y + 8), Vector2(px + 106, y + 8),
				Color(0.30, 0.12, 0.14), 2.0)
