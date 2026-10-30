extends Node2D

# São Paulo. Liberdade and Bixiga.
#
# The mechanic this city owns is proximity: the response you give is where you
# stand. So the plate is built to make standing somewhere feel like a decision.
# The pavement is the widest and most detailed surface in the game, because it
# is the thing the player will be looking at while they work out how close is
# close enough.
#
# That pavement is CALCADA PORTUGUESA: small cubes of black basalt and white
# limestone laid by hand into a pattern, inherited from Portugal and still laid
# the same way. It is the single most recognisable ground surface on the whole
# itinerary and no other city on the list has anything like it. Liberdade gets
# the wave; Bixiga gets a plainer chequer, because it was laid later and by
# people in more of a hurry.
#
# LIBERDADE is the largest Japanese community outside Japan. The street lamps
# are red steel arches carrying white lanterns - the suzuran - and the shop
# fascias carry Japanese characters over Brazilian concrete. A player arriving
# here two cities after Tokyo will recognise the script and nothing else, which
# is the point of putting it here.
#
# BIXIGA is the old Italian quarter: lower, older, brick and render.
#
# Over both: cables. Not tidy ones - bundles, knotted at every pole. And
# pixacao, the angular black tagging that runs up the highest reachable point
# of any wall in this city and is unlike graffiti anywhere else on earth.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "liberdade"
# "liberdade" | "bixiga" | "mercadao" | "vilamadalena" | "paulista"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Tropical grey. The sky here is high and heavy and the concrete under it has
# gone green-black with rain, which is what stops the city reading as European.
const C_SKY_ZEN  := Color(0.070, 0.070, 0.129)
const C_SKY_MID  := Color(0.106, 0.106, 0.176)
const C_SKY_LOW  := Color(0.180, 0.161, 0.204)
const C_SKY_HAZE := Color(0.267, 0.208, 0.196)

const C_DAY_HI   := Color(0.545, 0.573, 0.612)
const C_DAY_MID  := Color(0.671, 0.686, 0.694)
const C_DAY_LOW  := Color(0.780, 0.769, 0.741)

const C_CONC     := Color(0.616, 0.612, 0.588)
const C_CONC_DK  := Color(0.478, 0.482, 0.463)
const C_CONC_WET := Color(0.396, 0.427, 0.404)   # the green-black staining
const C_RENDER   := Color(0.702, 0.647, 0.573)
const C_BRICK    := Color(0.545, 0.361, 0.290)
const C_GRILLE   := Color(0.286, 0.298, 0.294)
const C_GLASS    := Color(0.169, 0.184, 0.196)

const C_RED      := Color(0.780, 0.192, 0.180)   # the suzuran lamp arches
const C_LANTERN  := Color(0.965, 0.933, 0.855)
const C_GREEN    := Color(0.176, 0.478, 0.302)
const C_YELLOW   := Color(0.918, 0.769, 0.169)

const C_STONE_W  := Color(0.839, 0.827, 0.788)   # calcada, white limestone
const C_STONE_B  := Color(0.196, 0.196, 0.212)   # calcada, black basalt

const GROUND_Y := 236.0


func _ready() -> void:
	_collect_doors()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _collect_doors() -> void:
	_doors.clear()
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		var label: Variant = child.get("sign_text")
		if label == null or String(label).is_empty():
			continue
		if not (child is Node2D):
			continue
		var kind: Variant = child.get("frontage")
		_doors.append({
			"x": (child as Node2D).position.x,
			"label": String(label),
			"kind": String(kind) if kind != null else "shop",
		})


func _draw_doors() -> void:
	for d in _doors:
		var x: float = float(d["x"])
		InteriorArt.frontage(self, x, GROUND_Y, CA.PAVE_TOP, String(d["kind"]),
			C_RED if district == "liberdade" else C_GREEN, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			Color(0.878, 0.867, 0.831), Color(0.129, 0.118, 0.110),
			not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	CA.far_mass(self, 96.0,
		C_CONC_DK.darkened(0.40) if GameState.is_morning()
		else C_CONC_DK.darkened(0.66),
		Color(0.78, 0.80, 0.82, 0.30), 40, 5)
	_draw_far_towers()
	match district:
		"bixiga":        _draw_bixiga()
		"mercadao":      _draw_mercadao()
		"vilamadalena":  _draw_vilamadalena()
		"paulista":      _draw_paulista()
		_:               _draw_liberdade()
	_draw_cables()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	# The museum on its four red legs, drawn after the avenue so nothing on
	# the street can stand in front of it.
	if district == "paulista":
		_draw_masp(566.0)
	CA.ground_floor(self, GROUND_Y, C_RENDER.darkened(0.24), C_GLASS, Color(1.0, 0.855, 0.612),
		not GameState.is_morning(), 63)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.30, 0.34, 0.32), 0.05)
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Liberdade ─────────────────────────────────────────────────────────────────
# Post-war concrete commercial blocks, four to six storeys, with security
# grilles over every opening below the third floor and shop fascias in two
# scripts. The bones are Brazilian; only the lettering and the lamps are not.

const BLOCKS := [
	# x, width, storeys, render (0 concrete, 1 render)
	[-14.0, 148.0, 5, 0], [134.0, 116.0, 4, 1], [250.0, 132.0, 6, 0],
	[382.0, 104.0, 4, 0], [486.0, 142.0, 5, 1], [628.0, 118.0, 6, 0],
	[746.0, 126.0, 4, 1], [872.0, 110.0, 5, 0], [982.0, 184.0, 6, 0],
]


func _draw_liberdade() -> void:
	for i in range(BLOCKS.size()):
		var b: Array = BLOCKS[i]
		_draw_block(float(b[0]), float(b[1]), int(b[2]), int(b[3]), i, false)


func _draw_bixiga() -> void:
	for i in range(BLOCKS.size()):
		var b: Array = BLOCKS[i]
		_draw_block(float(b[0]), float(b[1]), maxi(2, int(b[2]) - 2),
			1 if (i % 2) == 0 else 2, i, true)


func _draw_block(x: float, w: float, storeys: int, kind: int, seed_i: int,
		old: bool) -> void:
	var body: Color = [C_CONC, C_RENDER, C_BRICK][kind]
	if not GameState.is_morning():
		body = body.darkened(0.48)
	var floor_h: float = 34.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.20))

	# The staining. Concrete in this climate weathers downward from every sill
	# and every parapet, and it goes green rather than black.
	var wet: Color = Color(C_CONC_WET.r, C_CONC_WET.g, C_CONC_WET.b, 0.26)
	for k in range(4):
		var sx: float = x + 10.0 + float((seed_i * 53 + k * 71) % int(w - 20.0))
		draw_rect(Rect2(sx, top + 8.0, 5.0, GROUND_Y - top - 20.0), wet)
	draw_rect(Rect2(x, top, w, 5.0), body.lightened(0.14))

	if old:
		CA.roof(self, x, w, top + 3.0, 16.0,
			Color(0.494, 0.318, 0.267) if GameState.is_morning()
			else Color(0.494, 0.318, 0.267).darkened(0.44))

	for s in range(storeys - 1):
		var wy: float = top + 20.0 + float(s) * floor_h
		var bays: int = maxi(2, int(w / 40.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 29 + s * 13) % (1 << bays)
		CA.window_row(self, x, w, wy, bays, 24.0, 24.0, C_GLASS,
			body.darkened(0.34), lit)
		var step: float = w / float(bays)
		# Security grilles, on the lower floors only. Everybody has them and
		# nobody remarks on them, which is its own piece of information.
		if s >= storeys - 4:
			for b in range(bays):
				_draw_grille(x + step * (float(b) + 0.5) - 12.0, wy, 24.0, 24.0)
		# A washing line off a back balcony, on the older blocks.
		if old and s == 0 and (seed_i % 2) == 0:
			CA.balcony(self, x + w * 0.5 - 26.0, wy + 24.0, 52.0,
				C_GRILLE if GameState.is_morning() else C_GRILLE.darkened(0.35))

	# Pixacao. Angular, vertical, black, and always as high as somebody could
	# physically get. It is not decoration and it is not a mural; it is a name
	# written where a name should not be reachable.
	if (seed_i % 2) == 0:
		_draw_pixacao(x + 12.0, top + 14.0, minf(w - 24.0, 110.0), seed_i)


func _draw_grille(x: float, y: float, w: float, h: float) -> void:
	var g: Color = C_GRILLE if GameState.is_morning() else C_GRILLE.darkened(0.40)
	for i in range(int(w / 5.0)):
		draw_rect(Rect2(x + float(i) * 5.0, y, 1.4, h), g)
	draw_rect(Rect2(x, y, w, 1.4), g)
	draw_rect(Rect2(x, y + h - 1.4, w, 1.4), g)


func _draw_pixacao(x: float, y: float, w: float, seed_i: int) -> void:
	var ink := Color(0.086, 0.082, 0.086, 0.86)
	var n: int = int(w / 13.0)
	for i in range(n):
		var gx: float = x + float(i) * 13.0
		var tall: float = 20.0 + float((seed_i * 17 + i * 29) % 3) * 5.0
		# Straight strokes only, tall and narrow, with one crossbar. Pixacao
		# is a runic alphabet built out of vertical lines and that is exactly
		# what makes it read at any distance.
		draw_rect(Rect2(gx, y, 3.0, tall), ink)
		draw_rect(Rect2(gx + 6.0, y, 3.0, tall), ink)
		var bar: float = y + 4.0 + float((seed_i * 11 + i * 7) % 3) * 6.0
		draw_rect(Rect2(gx, bar, 9.0, 3.0), ink)
		if (i % 3) == 0:
			draw_rect(Rect2(gx, y + tall - 3.0, 9.0, 3.0), ink)


# ── Mercadao ──────────────────────────────────────────────────────────────────
# The Mercado Municipal of 1933 and the wholesale streets around it. The hall is
# neo-baroque with stained glass in the clerestory - a cathedral built for fruit
# - and outside it, 25 de Marco, which is the loudest commercial street in South
# America and is nothing but goods stacked to head height on the pavement.

func _draw_mercadao() -> void:
	CA.far_mass(self, 118.0,
		C_CONC_DK.darkened(0.36) if GameState.is_morning()
		else C_CONC_DK.darkened(0.64),
		Color(0.80, 0.82, 0.84, 0.26), 44, 13)
	_draw_market_hall(560.0)
	_draw_block(-16.0, 142.0, 5, 0, 2, false)
	_draw_block(126.0, 118.0, 4, 1, 5, false)
	_draw_block(956.0, 210.0, 5, 0, 8, false)
	# The overflow. Sacks, boxes and rolls, up the front of everything.
	for i in range(6):
		CA.crates(self, 240.0 + float(i) * 118.0, CA.PAVE_TOP + 42.0, 2, 2,
			Color(0.588, 0.494, 0.353))
	for i in range(4):
		CA.stall(self, 250.0 + float(i) * 168.0, CA.FAR_TOP - 32.0, 140.0,
			Color(0.180, 0.482, 0.310),
			[Color(0.90, 0.72, 0.18), Color(0.86, 0.28, 0.22),
			 Color(0.24, 0.53, 0.31), Color(0.75, 0.35, 0.62)])


func _draw_market_hall(x: float) -> void:
	var stone: Color = Color(0.749, 0.718, 0.667)
	var trim: Color = Color(0.612, 0.435, 0.322)
	if not GameState.is_morning():
		stone = stone.darkened(0.48)
		trim = trim.darkened(0.48)
	var w: float = 620.0
	draw_rect(Rect2(x - w * 0.5, 156.0, w, GROUND_Y - 156.0), stone)
	draw_rect(Rect2(x - w * 0.5 - 8.0, 148.0, w + 16.0, 11.0), stone.lightened(0.16))
	# The clerestory: tall arched windows with coloured glass in them, which is
	# the one thing that makes a market hall read as a cathedral.
	for i in range(9):
		var ax: float = x - w * 0.5 + 34.0 + float(i) * ((w - 68.0) / 9.0)
		var aw: float = (w - 68.0) / 9.0 - 14.0
		draw_rect(Rect2(ax, 176.0, aw, 54.0), trim.darkened(0.30))
		for k in range(9):
			var u: float = float(k) / 8.0
			var dy: float = sin(u * PI) * 18.0
			draw_rect(Rect2(ax + u * aw - 2.0, 176.0 - dy, 5.0, dy + 3.0),
				trim.darkened(0.30))
		var glass: Color = [Color(0.741, 0.243, 0.220), Color(0.196, 0.404, 0.612),
			Color(0.212, 0.502, 0.333), Color(0.847, 0.671, 0.196)][i % 4]
		if not GameState.is_morning():
			glass = glass.lightened(0.18)
		draw_rect(Rect2(ax + 4.0, 182.0, aw - 8.0, 44.0), glass)
		draw_rect(Rect2(ax + aw * 0.5 - 1.0, 182.0, 2.0, 44.0), trim.darkened(0.20))
	# The dome over the crossing, and the lantern on it.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 62.0, 148.0), Vector2(x - 44.0, 104.0), Vector2(x, 88.0),
		Vector2(x + 44.0, 104.0), Vector2(x + 62.0, 148.0),
	]), trim)
	draw_rect(Rect2(x - 12.0, 72.0, 24.0, 20.0), stone)
	draw_rect(Rect2(x - 2.0, 58.0, 4.0, 16.0), trim.lightened(0.20))
	for i in range(6):
		draw_rect(Rect2(x - w * 0.5 + 40.0 + float(i) * 108.0, GROUND_Y - 66.0,
			62.0, 66.0), Color(0.098, 0.086, 0.086))


# ── Vila Madalena ─────────────────────────────────────────────────────────────
# Up the hill, low, and painted. The street art here is commissioned and signed
# rather than thrown up, and it covers whole walls end to end - which is the
# exact opposite of the pixacao two districts back, and the contrast is why both
# are in the game.

func _draw_vilamadalena() -> void:
	CA.far_mass(self, 172.0,
		Color(0.353, 0.400, 0.353) if GameState.is_morning()
		else Color(0.353, 0.400, 0.353).darkened(0.58),
		Color(0.86, 0.84, 0.76, 0.18), 18, 4)
	for i in range(VILA_ROW.size()):
		var spec: Array = VILA_ROW[i]
		_draw_low_house(float(spec[0]), float(spec[1]), int(spec[2]), i)
	_draw_mural_wall(300.0, 190.0)
	_draw_mural_wall(720.0, 160.0)
	CA.tree(self, 560.0, CA.FAR_TOP + 20.0, 66.0, Color(0.267, 0.220, 0.180),
		Color(0.204, 0.396, 0.271), 1.3)


const VILA_ROW := [
	[-14.0, 128.0, 2], [116.0, 104.0, 2], [220.0, 136.0, 3], [356.0, 110.0, 2],
	[466.0, 130.0, 2], [596.0, 106.0, 3], [702.0, 134.0, 2], [836.0, 112.0, 2],
	[948.0, 138.0, 3], [1086.0, 96.0, 2],
]


func _draw_low_house(x: float, w: float, storeys: int, seed_i: int) -> void:
	var body: Color = [C_RENDER, Color(0.792, 0.749, 0.686),
		Color(0.729, 0.769, 0.741), Color(0.812, 0.729, 0.643)][seed_i % 4]
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var floor_h: float = 40.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	CA.roof(self, x, w, top + 2.0, 13.0,
		Color(0.545, 0.361, 0.290) if GameState.is_morning()
		else Color(0.545, 0.361, 0.290).darkened(0.46))
	var bays: int = maxi(1, int(w / 52.0))
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 23 + s * 7) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 26.0, 26.0, C_GLASS,
			body.darkened(0.30), lit)
		var step: float = w / float(bays)
		for b in range(bays):
			_draw_grille(x + step * (float(b) + 0.5) - 13.0, wy, 26.0, 26.0)
	# The gate and the wall, because every house here has one.
	draw_rect(Rect2(x, CA.PAVE_TOP - 36.0, w, 36.0), body.darkened(0.10))
	draw_rect(Rect2(x, CA.PAVE_TOP - 40.0, w, 5.0), body.lightened(0.16))
	for i in range(int(w / 8.0)):
		draw_rect(Rect2(x + 4.0 + float(i) * 8.0, CA.PAVE_TOP - 32.0, 2.0, 30.0),
			C_GRILLE if GameState.is_morning() else C_GRILLE.darkened(0.34))


# A commissioned mural: flat blocks of saturated colour, end to end, signed.
func _draw_mural_wall(x: float, w: float) -> void:
	var pal := [Color(0.902, 0.271, 0.376), Color(0.180, 0.545, 0.694),
		Color(0.949, 0.741, 0.180), Color(0.180, 0.639, 0.478),
		Color(0.549, 0.294, 0.647)]
	var y: float = GROUND_Y - 96.0
	for i in range(7):
		var c: Color = pal[i % pal.size()]
		if not GameState.is_morning():
			c = c.darkened(0.42)
		var bw: float = w / 7.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + float(i) * bw, y + 96.0),
			Vector2(x + float(i) * bw + 10.0, y + float((i * 17) % 30)),
			Vector2(x + float(i) * bw + bw, y + float((i * 29) % 26)),
			Vector2(x + float(i) * bw + bw - 8.0, y + 96.0),
		]), c)
	# The signature, bottom right, in a corner of every one of them.
	draw_rect(Rect2(x + w - 34.0, y + 82.0, 24.0, 5.0),
		Color(0.10, 0.09, 0.10, 0.70))


# ── Paulista ──────────────────────────────────────────────────────────────────
# The avenue. Towers on both sides, a pavement wide enough to be a plaza, and
# no wires at all - they were buried here, which is the single most expensive
# thing this city has ever done to a street and the only place it shows.
#
# For the proximity mechanic this is the hard plate: there is so much room that
# standing close has to be a decision rather than a consequence.

func _draw_paulista() -> void:
	var glass: Color = Color(0.271, 0.322, 0.361)
	var conc: Color = C_CONC
	if not GameState.is_morning():
		glass = glass.darkened(0.50)
		conc = conc.darkened(0.50)
	CA.far_mass(self, 60.0, conc.darkened(0.42),
		Color(0.82, 0.86, 0.90, 0.28), 60, 17)
	for spec in [[-20.0, 176.0, 22.0], [166.0, 148.0, 46.0], [324.0, 190.0, 12.0],
			[524.0, 156.0, 38.0], [690.0, 182.0, 18.0], [882.0, 164.0, 42.0],
			[1056.0, 140.0, 26.0]]:
		_draw_tower(float(spec[0]), float(spec[1]), float(spec[2]), glass, conc)


func _draw_tower(x: float, w: float, top: float, glass: Color,
		conc: Color) -> void:
	draw_rect(Rect2(x, top, w, GROUND_Y - top), conc)
	draw_rect(Rect2(x + w - 12.0, top, 12.0, GROUND_Y - top), conc.darkened(0.24))
	draw_rect(Rect2(x, top, 7.0, GROUND_Y - top), Color(1, 1, 1, 0.06))
	# Spandrel, glass, spandrel, glass, all the way down. The repetition IS the
	# elevation; there is no cornice to measure it against.
	var rows: int = int((GROUND_Y - top) / 16.0)
	for r in range(rows):
		var fy: float = top + float(r) * 16.0
		draw_rect(Rect2(x + 4.0, fy, w - 8.0, 5.0), conc.lightened(0.10))
		var pane: Color = glass
		if not GameState.is_morning() and ((int(x) + r * 7) % 6) < 2:
			pane = Color(0.90, 0.92, 0.94, 0.34)
		draw_rect(Rect2(x + 4.0, fy + 5.0, w - 8.0, 10.0), pane)
	for b in range(int(w / 22.0) + 1):
		draw_rect(Rect2(x + 4.0 + float(b) * 22.0, top, 2.5, GROUND_Y - top),
			conc.lightened(0.18))
	if not GameState.is_morning():
		var blink: float = 0.35 + 0.65 * absf(sin(_t * 1.4 + float(int(x))))
		draw_circle(Vector2(x + w * 0.5, top - 5.0), 2.4,
			Color(0.92, 0.30, 0.28, blink))


# ── Cables ────────────────────────────────────────────────────────────────────
# Not tidy. Bundles, sagging between poles, knotted into a mess at every one.

func _draw_cables() -> void:
	var wire := Color(0.086, 0.082, 0.094, 0.80)
	var poles := [60.0, 336.0, 612.0, 888.0, 1140.0]
	for i in range(poles.size() - 1):
		CA.wires(self, float(poles[i]), 128.0, float(poles[i + 1]), 132.0,
			5, 22.0, wire)
	for p in poles:
		CA.pole(self, float(p), CA.PAVE_TOP + 40.0, 200.0,
			Color(0.365, 0.322, 0.278), 2)
		CA.wire_knot(self, float(p), 130.0, wire)


# ── Ground ────────────────────────────────────────────────────────────────────
# The calcada portuguesa. This is the surface the whole city is remembered for
# and the one the proximity mechanic is played on, so it gets real attention.

func _draw_ground() -> void:
	var road: Color = Color(0.267, 0.263, 0.259)
	var base: Color = C_STONE_W
	if not GameState.is_morning():
		road = road.darkened(0.44)
		base = base.darkened(0.46)
	CA.ground(self, base, road, base.darkened(0.06))
	if district == "liberdade":
		_draw_calcada_wave(CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP)
		_draw_calcada_wave(CA.FAR_TOP, CA.VH - CA.FAR_TOP)
	else:
		_draw_calcada_check(CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP)
		_draw_calcada_check(CA.FAR_TOP, CA.VH - CA.FAR_TOP)
	CA.kerb(self, CA.ROAD_TOP, base.darkened(0.22))
	for i in range(11):
		draw_rect(Rect2(float(i) * 108.0, 442.0, 56.0, 5.0),
			Color(0.86, 0.84, 0.78, 0.32))
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.66, 0.72, 0.74), _t)


# Black basalt laid in a wave against white limestone. Drawn as stacked bands
# whose offset follows a sine, which is how the pattern actually works.
func _draw_calcada_wave(top: float, height: float) -> void:
	var black: Color = C_STONE_B
	if not GameState.is_morning():
		black = black.darkened(0.30)
	var rows: int = int(height / 7.0)
	for r in range(rows):
		var y: float = top + float(r) * 7.0
		var phase: float = float(r) * 0.55
		for c in range(int(CA.VW / 7.0) + 1):
			var x: float = float(c) * 7.0
			var s: float = sin(x * 0.035 + phase)
			if s > 0.15:
				draw_rect(Rect2(x, y, 6.0, 6.0), black)
		draw_rect(Rect2(0, y + 6.0, CA.VW, 1.0), Color(0, 0, 0, 0.10))


func _draw_calcada_check(top: float, height: float) -> void:
	var black: Color = C_STONE_B
	if not GameState.is_morning():
		black = black.darkened(0.30)
	var rows: int = int(height / 8.0)
	for r in range(rows):
		var y: float = top + float(r) * 8.0
		for c in range(int(CA.VW / 8.0) + 1):
			if ((r + c) % 2) == 0:
				draw_rect(Rect2(float(c) * 8.0, y, 7.0, 7.0), black)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	if district == "liberdade":
		# The suzuran. Red steel arches over the street carrying paired white
		# lanterns, and the reason a photograph of this district is instantly
		# identifiable. Nothing else in the game looks like them.
		for x in [190.0, 530.0, 870.0]:
			_draw_suzuran(float(x), lit)
	else:
		for x in [150.0, 520.0, 900.0]:
			CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 84.0,
				Color(0.318, 0.310, 0.294), Color(1.0, 0.878, 0.671), lit)
		CA.tree(self, 700.0, CA.PAVE_TOP + 36.0, 48.0,
			Color(0.267, 0.220, 0.180), Color(0.220, 0.396, 0.278), 1.05)
	CA.bin(self, 380.0, CA.PAVE_TOP + 40.0, Color(0.235, 0.353, 0.278))
	CA.stall(self, 620.0, CA.PAVE_TOP + 14.0, 118.0,
		Color(0.788, 0.212, 0.204) if district == "liberdade"
		else Color(0.239, 0.443, 0.310),
		[C_YELLOW, C_GREEN, Color(0.902, 0.478, 0.169)])


func _draw_suzuran(x: float, on: bool) -> void:
	var red: Color = C_RED if GameState.is_morning() else C_RED.darkened(0.28)
	var base_y: float = CA.PAVE_TOP + 42.0
	draw_rect(Rect2(x - 4.0, base_y - 176.0, 8.0, 176.0), red)
	draw_rect(Rect2(x - 4.0, base_y - 176.0, 3.0, 176.0), red.lightened(0.20))
	# The arch: two arms curving out over the street, drawn as stepped rects.
	for side in [-1.0, 1.0]:
		for i in range(5):
			var ax: float = x + side * (8.0 + float(i) * 11.0)
			var ay: float = base_y - 176.0 + float(i * i) * 1.6
			draw_rect(Rect2(ax - 5.0, ay, 11.0, 6.0), red)
	for side in [-1.0, 1.0]:
		var lx: float = x + side * 58.0
		var ly: float = base_y - 148.0
		draw_rect(Rect2(lx - 3.0, ly - 14.0, 6.0, 14.0), red.darkened(0.20))
		var lamp_col: Color = C_LANTERN if on \
			else C_LANTERN.darkened(0.45)
		draw_rect(Rect2(lx - 11.0, ly, 22.0, 26.0), lamp_col)
		draw_rect(Rect2(lx - 11.0, ly, 22.0, 3.0), red)
		draw_rect(Rect2(lx - 11.0, ly + 23.0, 22.0, 3.0), red)
		for k in range(3):
			draw_rect(Rect2(lx - 9.0, ly + 6.0 + float(k) * 6.0, 18.0, 1.2),
				Color(0, 0, 0, 0.14))
		if not on:
			continue
		for i in range(4):
			draw_circle(Vector2(lx, ly + 13.0), 20.0 + float(i) * 15.0,
				Color(1.0, 0.92, 0.78, 0.038 - float(i) * 0.007))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(368.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))        # bin
	out.append(Rect2(620.0, CA.PAVE_TOP + 14.0, 118.0, 30.0))       # stall
	for p in [60.0, 336.0, 612.0, 888.0, 1140.0]:
		out.append(Rect2(float(p) - 5.0, CA.PAVE_TOP + 14.0, 10.0, 28.0))
	if district == "liberdade":
		for x in [190.0, 530.0, 870.0]:
			out.append(Rect2(float(x) - 6.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))
	else:
		out.append(Rect2(686.0, CA.PAVE_TOP + 12.0, 28.0, 30.0))    # tree
	return out


# The towers, where this city actually has them.
# Avenida Paulista is the spine of the money in this country and the towers
	# stand on both sides of it.
func _draw_far_towers() -> void:
	if district != "paulista":
		return
	CA.skyline(self, 232.0, Color(0.278, 0.294, 0.353), Color(0.161, 0.196, 0.243),
		13, 29, not GameState.is_morning())


# ── MASP ──────────────────────────────────────────────────────────────────────
# Lina Bo Bardi, 1968. A concrete-and-glass box seventy metres long, hung
# between four bright red columns with a clear span underneath it, because the
# land was given to the city on condition the view through to the valley was
# never blocked. So she took the building off the ground and left the view.
#
# The space under it is the most used room in the city and it is not a room.
func _draw_masp(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var red := Color(0.812, 0.157, 0.129)
	var slab := Color(0.667, 0.659, 0.639)
	var glass := Color(0.153, 0.184, 0.220)
	var deck: float = 236.0
	var half: float = 268.0
	var box_top: float = 78.0

	# The four columns. They are the whole design and they are that red.
	for s in [-1.0, 1.0]:
		for inner in [0.42, 1.0]:
			var px: float = cx + s * half * float(inner)
			draw_rect(Rect2(px - 13.0, box_top, 26.0, deck - box_top), red)
			draw_rect(Rect2(px - 13.0, box_top, 8.0, deck - box_top),
				red.lightened(0.16))
	# The beams the box hangs from, spanning between the columns.
	draw_rect(Rect2(cx - half - 16.0, box_top - 14.0, (half + 16.0) * 2.0,
		16.0), red)
	draw_rect(Rect2(cx - half - 16.0, box_top - 14.0, (half + 16.0) * 2.0,
		5.0), red.lightened(0.20))
	# The box itself, slung under the beams and clear of the ground.
	draw_rect(Rect2(cx - half + 6.0, box_top + 2.0, (half - 6.0) * 2.0, 96.0),
		slab)
	draw_rect(Rect2(cx - half + 6.0, box_top + 2.0, (half - 6.0) * 2.0, 6.0),
		slab.lightened(0.14))
	# Two bands of glazing across the whole length.
	for band in range(2):
		var by: float = box_top + 20.0 + float(band) * 40.0
		draw_rect(Rect2(cx - half + 18.0, by, (half - 18.0) * 2.0, 26.0), glass)
		for m in range(17):
			draw_rect(Rect2(cx - half + 22.0 + float(m) * ((half - 22.0) * 2.0
				/ 17.0), by, 4.0, 26.0), slab.darkened(0.10))
	# And the light under it, because the void is lit all night and full.
	if not morning:
		draw_rect(Rect2(cx - half, deck - 26.0, half * 2.0, 26.0),
			Color(0.988, 0.855, 0.596, 0.10))


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	return [
		[Vector2(470.0, CA.PAVE_TOP + 6.0), 0, 1],
	]
