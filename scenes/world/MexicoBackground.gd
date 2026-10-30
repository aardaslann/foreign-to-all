extends Node2D

# Mexico City. Four districts, and one stone holds them together.
#
# TEZONTLE: a porous, deep iron-red volcanic scoria the valley has been built
# with since before the Spanish arrived, and which the Spanish then kept using
# because there was nothing better to hand. It is set against grey chiluca
# sandstone for the door surrounds and the quoins, and that red-against-grey is
# the single most identifying pairing in the city.
#
# LA MERCED is the market: a barrel-vaulted hall and four blocks of overflow
# stacked on the pavement outside it.
# JUAREZ is Second Empire - French mansions with mansard roofs, tall iron-gated
# windows and mascarons over the doors, on streets named after European capitals.
# COYOACAN is colonial, low, and painted: ochre, cobalt, and a wall of
# bougainvillea over everything.
# ROMA is Art Nouveau and Deco under jacarandas.
#
# Mexico is Moscow inverted, and must be played straight after it: here a flat
# face and a direct ask read as hostility. So this plate is the warmest on the
# whole itinerary - the light is high and yellow and everything is painted.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "merced"
# "merced" | "juarez" | "coyoacan" | "roma" | "condesa"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.075, 0.062, 0.118)
const C_SKY_MID  := Color(0.118, 0.090, 0.157)
const C_SKY_LOW  := Color(0.220, 0.145, 0.169)
const C_SKY_HAZE := Color(0.318, 0.196, 0.157)

# Two thousand two hundred metres up, and the light shows it: hard, high, and
# very yellow late in the day.
const C_DAY_HI   := Color(0.353, 0.529, 0.706)
const C_DAY_MID  := Color(0.612, 0.667, 0.702)
const C_DAY_LOW  := Color(0.878, 0.796, 0.639)

const C_TEZONTLE   := Color(0.502, 0.243, 0.204)
const C_TEZONTLE_D := Color(0.400, 0.192, 0.169)
const C_CHILUCA    := Color(0.769, 0.749, 0.706)   # the grey trim
const C_LIME       := Color(0.878, 0.808, 0.694)   # painted render
const COLOURS := [
	Color(0.859, 0.694, 0.310),   # ochre
	Color(0.129, 0.310, 0.549),   # cobalt
	Color(0.749, 0.318, 0.243),   # brick red
	Color(0.545, 0.639, 0.451),   # sage
	Color(0.878, 0.808, 0.694),   # lime white
]

const C_MANSARD  := Color(0.302, 0.286, 0.294)
const C_IRON     := Color(0.204, 0.196, 0.192)
const C_GLASS    := Color(0.176, 0.192, 0.216)
const C_BOUGAIN  := Color(0.831, 0.208, 0.478)   # magenta, and it is that loud
const C_JACARANDA:= Color(0.510, 0.427, 0.749)
const C_TALAVERA := Color(0.176, 0.396, 0.639)
const C_LAMP     := Color(1.0, 0.859, 0.612)
const C_JOINT    := Color(0.078, 0.063, 0.075, 0.34)

const GROUND_Y := 236.0

const COYOACAN_ROW := [
	[-14.0, 118.0], [104.0, 96.0], [200.0, 128.0], [328.0, 104.0],
	[432.0, 122.0], [554.0, 98.0], [652.0, 134.0], [786.0, 110.0],
	[896.0, 270.0],
]


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
			C_TALAVERA, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_LIME, Color(0.24, 0.13, 0.11), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	_draw_far_towers()
	match district:
		"juarez":   _draw_juarez()
		"coyoacan": _draw_coyoacan()
		"roma":     _draw_roma()
		"condesa":  _draw_condesa()
		_:          _draw_merced()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_LIME.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 27)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.78, 0.58, 0.30), 0.045)
	CA.vignette(self, 0.26)


# ── Building types ────────────────────────────────────────────────────────────

# Tezontle over a stone base with chiluca surrounds. The red stone is porous,
# so it is drawn with holes in it - that pitting is why it reads as volcanic
# rather than as brick.
func _draw_tezontle(x: float, w: float, storeys: int, seed_i: int) -> void:
	var stone: Color = C_TEZONTLE
	var grey: Color = C_CHILUCA
	if not GameState.is_morning():
		stone = stone.darkened(0.46)
		grey = grey.darkened(0.44)
	var floor_h: float = 42.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, stone, C_TEZONTLE_D)
	for i in range(int(w * float(storeys) / 9.0)):
		var px: float = x + float((seed_i * 37 + i * 53) % int(maxf(w - 6.0, 4.0)))
		var py: float = top + float((seed_i * 29 + i * 71) % int(GROUND_Y - top - 4.0))
		draw_rect(Rect2(px, py, 2.5, 2.5), C_TEZONTLE_D.darkened(0.24))
	# Chiluca: the quoins, the cornice, and a surround on every opening.
	draw_rect(Rect2(x - 5.0, top - 9.0, w + 10.0, 10.0), grey)
	draw_rect(Rect2(x, top, 11.0, GROUND_Y - top), grey)
	draw_rect(Rect2(x + w - 11.0, top, 11.0, GROUND_Y - top), grey)
	var bays: int = maxi(2, int(w / 50.0))
	var step: float = w / float(bays)
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 41 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 30.0, C_GLASS, grey, lit)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			draw_rect(Rect2(bx - 18.0, wy - 7.0, 36.0, 6.0), grey)
			draw_rect(Rect2(bx - 17.0, wy + 30.0, 34.0, 5.0), grey)
			# An iron grille over the ground-floor windows, on brackets.
			if s == storeys - 2:
				_draw_reja(bx, wy)


# The reja: a wrought-iron grille that bellies OUT from the wall. That bulge is
# the whole silhouette and a flat grille here would look like anywhere else.
func _draw_reja(x: float, y: float) -> void:
	var iron: Color = C_IRON if GameState.is_morning() else C_IRON.darkened(0.24)
	for i in range(7):
		var u: float = float(i) / 6.0
		var bulge: float = sin(u * PI) * 5.0
		draw_rect(Rect2(x - 13.0 + u * 26.0, y - 2.0 + bulge * 0.2, 1.8, 34.0), iron)
	draw_rect(Rect2(x - 15.0, y - 3.0, 30.0, 2.0), iron)
	draw_rect(Rect2(x - 17.0, y + 30.0, 34.0, 2.4), iron)
	draw_rect(Rect2(x - 17.0, y + 32.0, 3.0, 5.0), iron)
	draw_rect(Rect2(x + 14.0, y + 32.0, 3.0, 5.0), iron)


# A painted colonial house: one flat colour, a heavy timber door, and a tiled
# roof edge. Coyoacan is nothing but these.
func _draw_painted(x: float, w: float, ci: int, seed_i: int) -> void:
	var body: Color = COLOURS[ci % COLOURS.size()]
	if not GameState.is_morning():
		body = body.darkened(0.44)
	var top: float = GROUND_Y - 84.0
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	draw_rect(Rect2(x, top, w, 5.0), body.lightened(0.16))
	draw_rect(Rect2(x + w - 8.0, top, 8.0, GROUND_Y - top), body.darkened(0.18))
	# A band of talavera tile at waist height, which is where it always is.
	if (seed_i % 2) == 0:
		var tile: Color = C_TALAVERA if GameState.is_morning() \
			else C_TALAVERA.darkened(0.40)
		for i in range(int(w / 14.0)):
			draw_rect(Rect2(x + 3.0 + float(i) * 14.0, GROUND_Y - 34.0, 12.0, 12.0),
				tile if (i % 2) == 0 else C_LIME.darkened(0.06))
	CA.roof(self, x, w, top + 2.0, 12.0,
		Color(0.612, 0.376, 0.290) if GameState.is_morning()
		else Color(0.612, 0.376, 0.290).darkened(0.46))
	var bays: int = maxi(1, int(w / 56.0))
	var lit: int = 0
	if not GameState.is_morning():
		lit = (seed_i * 23) % (1 << mini(bays, 20))
	CA.window_row(self, x, w, top + 22.0, bays, 26.0, 30.0, C_GLASS,
		C_LIME.darkened(0.20), lit)
	var step: float = w / float(bays)
	for b in range(bays):
		_draw_reja(x + step * (float(b) + 0.5), top + 22.0)


# ── La Merced ─────────────────────────────────────────────────────────────────
# A barrel-vaulted market hall, and four blocks of overflow stacked outside it
# because the hall has not been big enough since the day it opened.

func _draw_merced() -> void:
	CA.far_mass(self, 186.0,
		C_TEZONTLE_D.darkened(0.30) if GameState.is_morning()
		else C_TEZONTLE_D.darkened(0.60),
		Color(0.88, 0.80, 0.62, 0.24), 32, 4)
	_draw_market_hall(560.0)
	_draw_tezontle(-16.0, 148.0, 3, 2)
	_draw_tezontle(132.0, 126.0, 3, 5)
	_draw_tezontle(960.0, 206.0, 3, 8)
	# The overflow: goods stacked up the outside of the hall in sacks and crates.
	for i in range(5):
		CA.crates(self, 292.0 + float(i) * 108.0, CA.PAVE_TOP + 42.0, 2, 2,
			Color(0.588, 0.478, 0.322))
	for i in range(4):
		CA.stall(self, 300.0 + float(i) * 138.0, CA.FAR_TOP - 30.0, 122.0,
			Color(0.129, 0.310, 0.549),
			[Color(0.87, 0.29, 0.22), Color(0.92, 0.75, 0.18),
			 Color(0.24, 0.51, 0.28), Color(0.83, 0.21, 0.48)])


func _draw_market_hall(x: float) -> void:
	var conc: Color = Color(0.667, 0.639, 0.588)
	if not GameState.is_morning():
		conc = conc.darkened(0.46)
	var w: float = 640.0
	draw_rect(Rect2(x - w * 0.5, 168.0, w, GROUND_Y - 168.0), conc)
	# The vaults. Five shallow barrels in a row, and it is the only roof shape
	# in the game that is drawn as a curve.
	for v in range(5):
		var vx: float = x - w * 0.5 + 20.0 + float(v) * ((w - 40.0) / 5.0)
		var vw: float = (w - 40.0) / 5.0 - 8.0
		for k in range(16):
			var u: float = float(k) / 15.0
			var dy: float = sin(u * PI) * 46.0
			draw_rect(Rect2(vx + u * vw - 3.0, 168.0 - dy, 7.0, dy + 4.0),
				conc.lightened(0.06) if (k % 4) else conc)
		draw_rect(Rect2(vx, 166.0, vw, 5.0), conc.darkened(0.20))
	draw_rect(Rect2(x - w * 0.5 - 6.0, 162.0, w + 12.0, 8.0), conc.lightened(0.14))
	# The openings along the base. No doors; markets do not have doors.
	for i in range(7):
		draw_rect(Rect2(x - w * 0.5 + 24.0 + float(i) * 88.0, GROUND_Y - 62.0,
			58.0, 62.0), Color(0.098, 0.078, 0.075))


# ── Juarez ────────────────────────────────────────────────────────────────────
# French mansions on streets named Hamburgo, Praga, Berna, Londres. Mansard
# roofs, mascarons over the doors, and jacarandas down the middle.

# The opening on Reforma the monument stands in.
const ANGEL_L := 748.0
const ANGEL_R := 944.0


func _draw_juarez() -> void:
	CA.far_mass(self, 194.0,
		Color(0.451, 0.427, 0.416) if GameState.is_morning()
		else Color(0.451, 0.427, 0.416).darkened(0.58),
		Color(0.88, 0.82, 0.68, 0.22), 24, 6)
	# The avenue opens at the glorieta. Any mansion that OVERLAPS the opening
	# is skipped, not merely one that starts in it - two of them were standing
	# in front of the monument.
	for spec in [[-16.0, 156.0, 0], [148.0, 138.0, 4], [294.0, 162.0, 2],
			[464.0, 142.0, 0], [614.0, 158.0, 4], [780.0, 146.0, 2],
			[934.0, 232.0, 0]]:
		if float(spec[0]) + float(spec[1]) > ANGEL_L 			and float(spec[0]) < ANGEL_R:
			continue
		_draw_mansion(float(spec[0]), float(spec[1]), int(spec[2]))
	# Drawn after the terrace so nothing can get in front of it.
	_draw_angel(846.0)
	for jx in [230.0, 560.0, 1010.0]:
		_draw_jacaranda(float(jx))


func _draw_mansion(x: float, w: float, ci: int) -> void:
	var body: Color = COLOURS[ci % COLOURS.size()].lightened(0.18)
	var grey: Color = C_CHILUCA
	var mans: Color = C_MANSARD
	if not GameState.is_morning():
		body = body.darkened(0.46)
		grey = grey.darkened(0.44)
		mans = mans.darkened(0.44)
	var top: float = GROUND_Y - 3.0 * 44.0
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	draw_rect(Rect2(x - 6.0, top - 10.0, w + 12.0, 11.0), grey)
	# The mansard: a steep slated slope with dormers punched through it.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 6.0, top - 10.0), Vector2(x + 10.0, top - 54.0),
		Vector2(x + w - 10.0, top - 54.0), Vector2(x + w + 6.0, top - 10.0),
	]), mans)
	for i in range(int(w / 11.0)):
		draw_rect(Rect2(x + 2.0 + float(i) * 11.0, top - 52.0, 1.4, 42.0),
			Color(0, 0, 0, 0.18))
	var dormers: int = maxi(1, int(w / 62.0))
	for d in range(dormers):
		var dx: float = x + w / float(dormers) * (float(d) + 0.5)
		draw_rect(Rect2(dx - 13.0, top - 46.0, 26.0, 30.0), body.lightened(0.06))
		draw_rect(Rect2(dx - 15.0, top - 50.0, 30.0, 6.0), grey)
		draw_rect(Rect2(dx - 8.0, top - 40.0, 16.0, 20.0),
			C_GLASS if GameState.is_morning() else Color(0.98, 0.90, 0.70, 0.85))
	var bays: int = maxi(2, int(w / 52.0))
	var step: float = w / float(bays)
	for s in range(2):
		var wy: float = top + 18.0 + float(s) * 44.0
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 19 + s * 7) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 32.0, C_GLASS, grey, lit)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			CA.balcony(self, bx - 18.0, wy + 32.0, 36.0, C_IRON
				if GameState.is_morning() else C_IRON.lightened(0.14))
			# The mascaron: a carved face over the opening. Two dots and a
			# curve is enough at this size, and it is unmistakable.
			draw_rect(Rect2(bx - 9.0, wy - 12.0, 18.0, 9.0), grey.lightened(0.10))
			draw_rect(Rect2(bx - 4.0, wy - 9.0, 2.0, 2.0), grey.darkened(0.40))
			draw_rect(Rect2(bx + 2.0, wy - 9.0, 2.0, 2.0), grey.darkened(0.40))
			draw_rect(Rect2(bx - 3.0, wy - 5.0, 6.0, 1.6), grey.darkened(0.40))


func _draw_jacaranda(x: float) -> void:
	var trunk: Color = Color(0.318, 0.263, 0.220)
	var bloom: Color = C_JACARANDA
	if not GameState.is_morning():
		trunk = trunk.darkened(0.46)
		bloom = bloom.darkened(0.50)
	var base: float = CA.FAR_TOP + 20.0
	draw_rect(Rect2(x - 5.0, base - 96.0, 10.0, 96.0), trunk)
	for i in range(3):
		draw_line(Vector2(x, base - 84.0), Vector2(x + (-30.0 + float(i) * 30.0),
			base - 112.0), trunk, 3.0)
	for i in range(9):
		var bx: float = x - 46.0 + float((i * 37) % 92)
		var by: float = base - 104.0 - float((i * 23) % 34)
		draw_circle(Vector2(bx, by), 17.0, Color(bloom.r, bloom.g, bloom.b, 0.80))
	# The fallen petals. Every jacaranda street has a purple floor under it and
	# nobody sweeps them because they come back the next morning.
	for i in range(16):
		draw_rect(Rect2(x - 56.0 + float((i * 41) % 112), base + float((i * 13) % 22),
			4.0, 2.5), Color(bloom.r, bloom.g, bloom.b, 0.55))


# ── Coyoacan ──────────────────────────────────────────────────────────────────
# Low, colonial, and painted. One flat colour per house, cobbles, and
# bougainvillea coming over the top of every wall it can reach.

func _draw_coyoacan() -> void:
	CA.far_mass(self, 206.0,
		Color(0.353, 0.408, 0.322) if GameState.is_morning()
		else Color(0.353, 0.408, 0.322).darkened(0.56),
		Color(0.86, 0.82, 0.68, 0.18), 16, 3)
	for i in range(COYOACAN_ROW.size()):
		var spec: Array = COYOACAN_ROW[i]
		_draw_painted(float(spec[0]), float(spec[1]), i, i)
	_draw_bougainvillea(240.0, 150.0)
	_draw_bougainvillea(680.0, 120.0)
	CA.tree(self, 470.0, CA.FAR_TOP + 24.0, 62.0, Color(0.298, 0.243, 0.196),
		Color(0.220, 0.396, 0.263), 1.2)


func _draw_bougainvillea(x: float, w: float) -> void:
	var flower: Color = C_BOUGAIN
	var leaf: Color = Color(0.188, 0.353, 0.235)
	if not GameState.is_morning():
		flower = flower.darkened(0.44)
		leaf = leaf.darkened(0.52)
	var top: float = GROUND_Y - 88.0
	for i in range(int(w / 6.0)):
		var lx: float = x + float(i) * 6.0
		var drop: float = 30.0 + float((i * 31) % 56)
		draw_rect(Rect2(lx, top, 2.4, drop), leaf.darkened(0.20))
		for k in range(int(drop / 8.0)):
			var c: Color = flower if ((i + k) % 3) else leaf
			draw_circle(Vector2(lx + 1.0 + float((i + k) % 3) - 1.0,
				top + 5.0 + float(k) * 8.0), 4.4, c)


# ── Roma ──────────────────────────────────────────────────────────────────────
# Art Nouveau and Deco apartment blocks under jacarandas, on a boulevard wide
# enough that you can see the sky. The calmest street in the city.

func _draw_roma() -> void:
	CA.far_mass(self, 190.0,
		Color(0.451, 0.443, 0.427) if GameState.is_morning()
		else Color(0.451, 0.443, 0.427).darkened(0.58),
		Color(0.88, 0.82, 0.68, 0.22), 22, 7)
	for spec in [[-16.0, 152.0, 4], [136.0, 130.0, 0], [266.0, 148.0, 3],
			[414.0, 136.0, 4], [550.0, 156.0, 0], [706.0, 142.0, 3],
			[848.0, 160.0, 4], [1008.0, 158.0, 0]]:
		_draw_deco(float(spec[0]), float(spec[1]), int(spec[2]))
	for jx in [190.0, 620.0, 1000.0]:
		_draw_jacaranda(float(jx))


func _draw_deco(x: float, w: float, ci: int) -> void:
	var body: Color = COLOURS[ci % COLOURS.size()].lightened(0.24)
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var storeys: int = 4
	var floor_h: float = 38.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	# The stepped parapet, which is the whole Deco signature.
	draw_rect(Rect2(x - 4.0, top - 8.0, w + 8.0, 9.0), body.lightened(0.14))
	draw_rect(Rect2(x + w * 0.5 - 34.0, top - 18.0, 68.0, 11.0), body.lightened(0.20))
	draw_rect(Rect2(x + w * 0.5 - 16.0, top - 26.0, 32.0, 9.0), body.lightened(0.26))
	# Vertical fluting between the bays: three grooves, floor to parapet.
	var bays: int = maxi(2, int(w / 50.0))
	var step: float = w / float(bays)
	for b in range(bays + 1):
		for g in range(3):
			draw_rect(Rect2(x + float(b) * step - 5.0 + float(g) * 4.0, top,
				1.6, GROUND_Y - top), body.darkened(0.14))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 23 + s * 11) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 28.0, 26.0, C_GLASS,
			body.darkened(0.30), lit)
		for b in range(bays):
			CA.balcony(self, x + step * (float(b) + 0.5) - 18.0, wy + 26.0, 36.0,
				C_IRON if GameState.is_morning() else C_IRON.lightened(0.14), true)


# ── Condesa ───────────────────────────────────────────────────────────────────
# Deco apartment blocks around a park, on streets laid out on the oval of a
# racetrack that closed in 1924 - which is why nothing here is straight and
# every corner is a curve.
#
# The trees meet over the road. It is the only plate in the game where the
# canopy closes, and after four thousand kilometres of hard high light that
# shade is the whole point of the district.

func _draw_condesa() -> void:
	CA.far_mass(self, 200.0,
		Color(0.310, 0.376, 0.310) if GameState.is_morning()
		else Color(0.310, 0.376, 0.310).darkened(0.56),
		Color(0.86, 0.82, 0.68, 0.16), 12, 9)
	for spec in [[-16.0, 158.0, 2], [148.0, 138.0, 4], [292.0, 152.0, 0],
			[452.0, 142.0, 3], [600.0, 156.0, 1], [762.0, 146.0, 2],
			[914.0, 254.0, 4]]:
		_draw_deco(float(spec[0]), float(spec[1]), int(spec[2]))
	# The canopy. Drawn AFTER the buildings and across the whole plate, so the
	# street reads as being under something rather than beside it.
	var leaf: Color = Color(0.216, 0.396, 0.263)
	if not GameState.is_morning():
		leaf = leaf.darkened(0.54)
	for i in range(9):
		var tx: float = -40.0 + float(i) * 156.0
		draw_rect(Rect2(tx - 6.0, CA.FAR_TOP - 86.0, 12.0, 86.0),
			Color(0.298, 0.243, 0.196) if GameState.is_morning()
			else Color(0.298, 0.243, 0.196).darkened(0.50))
		for k in range(5):
			draw_circle(Vector2(tx - 56.0 + float(k) * 28.0,
				CA.FAR_TOP - 104.0 - float((i * 7 + k * 11) % 20)), 34.0,
				Color(leaf.r, leaf.g, leaf.b, 0.90))
	# The shade it throws, which is the reason anybody walks here.
	draw_rect(Rect2(0, CA.PAVE_TOP, CA.VW, CA.VH - CA.PAVE_TOP),
		Color(0.08, 0.14, 0.09, 0.14))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.588, 0.549, 0.494)
	var road: Color = Color(0.278, 0.267, 0.259)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.08))
	if district == "coyoacan":
		# Cobbles, and they are uneven enough to be a complaint.
		CA.setts(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 14.0, C_JOINT)
	else:
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 44.0, 32.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 44.0, 32.0, C_JOINT)
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.20))
		for i in range(10):
			draw_rect(Rect2(float(i) * 118.0, 442.0, 56.0, 5.0),
				Color(0.90, 0.84, 0.62, 0.30))
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.76, 0.66, 0.48), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [160.0, 620.0, 1050.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 80.0, C_IRON, C_LAMP, lit)
	CA.bin(self, 350.0, CA.PAVE_TOP + 40.0, Color(0.239, 0.353, 0.278))
	if district == "merced":
		_draw_diablito(760.0)
	else:
		# The organ grinder, in a beige uniform, on every corner downtown. He
		# is a fixture, not a busker, and there are hundreds of him.
		_draw_organ(700.0)


# The diablito: a two-wheeled sack truck, and the thing every load in the
# market moves on.
func _draw_diablito(x: float) -> void:
	var steel: Color = Color(0.451, 0.443, 0.435)
	if not GameState.is_morning():
		steel = steel.darkened(0.42)
	var y: float = CA.PAVE_TOP + 38.0
	draw_rect(Rect2(x - 4.0, y - 62.0, 5.0, 62.0), steel)
	draw_rect(Rect2(x + 12.0, y - 62.0, 5.0, 62.0), steel)
	for i in range(4):
		draw_rect(Rect2(x - 4.0, y - 54.0 + float(i) * 14.0, 21.0, 3.0), steel)
	draw_rect(Rect2(x - 10.0, y - 4.0, 33.0, 5.0), steel.lightened(0.14))
	draw_circle(Vector2(x - 6.0, y + 2.0), 7.0, Color(0.14, 0.13, 0.13))
	draw_circle(Vector2(x + 19.0, y + 2.0), 7.0, Color(0.14, 0.13, 0.13))
	CA.crates(self, x - 8.0, y - 4.0, 1, 2, Color(0.588, 0.478, 0.322))


func _draw_organ(x: float) -> void:
	var wood: Color = Color(0.482, 0.353, 0.259)
	var beige: Color = Color(0.741, 0.694, 0.588)
	if not GameState.is_morning():
		wood = wood.darkened(0.44)
		beige = beige.darkened(0.44)
	var y: float = CA.PAVE_TOP + 36.0
	draw_rect(Rect2(x - 3.0, y - 46.0, 6.0, 46.0), beige.darkened(0.30))
	draw_rect(Rect2(x - 26.0, y - 74.0, 52.0, 32.0), wood)
	draw_rect(Rect2(x - 26.0, y - 74.0, 52.0, 4.0), wood.lightened(0.20))
	for i in range(6):
		draw_rect(Rect2(x - 21.0 + float(i) * 8.0, y - 68.0, 5.0, 20.0),
			beige.lightened(0.10))
	draw_rect(Rect2(x + 26.0, y - 60.0, 4.0, 12.0), wood.darkened(0.24))
	draw_circle(Vector2(x + 32.0, y - 54.0), 5.0, wood.darkened(0.30))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(338.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))      # bin
	if district == "merced":
		out.append(Rect2(748.0, CA.PAVE_TOP + 14.0, 40.0, 28.0))  # diablito
		for i in range(5):
			out.append(Rect2(292.0 + float(i) * 108.0, CA.PAVE_TOP + 18.0,
				68.0, 24.0))
	else:
		out.append(Rect2(672.0, CA.PAVE_TOP + 12.0, 56.0, 30.0))  # organ
	if district == "coyoacan":
		out.append(Rect2(456.0, CA.FAR_TOP + 2.0, 28.0, 24.0))    # tree
	return out


# The towers, where this city actually has them.
# The Reforma towers, north of the park, on the one avenue the city let
	# them build up.
func _draw_far_towers() -> void:
	if district != "condesa":
		return
	CA.skyline(self, 218.0, Color(0.290, 0.286, 0.337), Color(0.169, 0.184, 0.227),
		8, 23, not GameState.is_morning())


# El Angel. A victory column on a roundabout in the middle of Reforma, and it
# is where this city goes when something has happened - a cup won, a verdict,
# a march. The gold is real gold leaf and it has been taken down and put back
# up twice after earthquakes.
func _draw_angel(cx: float) -> void:
	var stone: Color = C_CHILUCA if GameState.is_morning() else C_CHILUCA.darkened(0.22)
	var gold := Color(0.859, 0.706, 0.271)
	if not GameState.is_morning():
		# Floodlit from the roundabout. It is the brightest thing on Reforma
		# after dark and it should not go the colour of a shopfront.
		gold = gold.lightened(0.08)
	var base: float = 260.0

	# The plinth: stepped, with the seated bronzes at the corners.
	draw_rect(Rect2(cx - 74.0, base - 40.0, 148.0, 40.0), stone.darkened(0.14))
	draw_rect(Rect2(cx - 74.0, base - 40.0, 148.0, 5.0), stone.lightened(0.10))
	draw_rect(Rect2(cx - 58.0, base - 74.0, 116.0, 34.0), stone)
	draw_rect(Rect2(cx - 58.0, base - 74.0, 116.0, 5.0), stone.lightened(0.12))
	for s in [-1.0, 1.0]:
		draw_rect(Rect2(cx + s * 46.0 - 11.0, base - 66.0, 22.0, 26.0),
			stone.darkened(0.30))
		draw_circle(Vector2(cx + s * 46.0, base - 68.0), 8.0, stone.darkened(0.30))
	# The base of the column, and the pedestal it sits on.
	draw_rect(Rect2(cx - 34.0, base - 96.0, 68.0, 24.0), stone.darkened(0.06))

	# The column. Fluted, and taller than anything else on the avenue by a
	# factor of nearly three.
	# The wings have to fit above the capital. At 66 they went off the
	# top of the plate and Victoria lost both of them.
	var top: float = 100.0
	draw_rect(Rect2(cx - 21.0, top, 42.0, base - 96.0 - top), stone)
	draw_rect(Rect2(cx - 21.0, top, 8.0, base - 96.0 - top), stone.lightened(0.12))
	for f in range(6):
		draw_rect(Rect2(cx - 17.0 + float(f) * 7.0, top + 6.0, 2.0,
			base - 108.0 - top), stone.darkened(0.20))
	# Corinthian capital: a flare, then the abacus.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 21.0, top + 6.0), Vector2(cx + 21.0, top + 6.0),
		Vector2(cx + 30.0, top - 14.0), Vector2(cx - 30.0, top - 14.0),
	]), stone.lightened(0.06))
	draw_rect(Rect2(cx - 33.0, top - 22.0, 66.0, 9.0), stone.lightened(0.14))

	# Victoria Alada: wings out, a laurel crown up in one hand and the broken
	# chain of the three centuries in the other.
	var fy: float = top - 22.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 5.0, fy - 14.0), Vector2(cx - 62.0, fy - 62.0),
		Vector2(cx - 50.0, fy - 12.0), Vector2(cx - 30.0, fy - 4.0),
	]), gold)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx + 5.0, fy - 14.0), Vector2(cx + 62.0, fy - 62.0),
		Vector2(cx + 50.0, fy - 12.0), Vector2(cx + 30.0, fy - 4.0),
	]), gold)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 9.0, fy), Vector2(cx + 9.0, fy),
		Vector2(cx + 6.0, fy - 44.0), Vector2(cx - 6.0, fy - 44.0),
	]), gold)
	draw_circle(Vector2(cx, fy - 50.0), 9.0, gold)
	# The raised arm and the crown it holds.
	draw_line(Vector2(cx + 5.0, fy - 40.0), Vector2(cx + 28.0, fy - 66.0),
		gold, 5.0)
	draw_arc(Vector2(cx + 32.0, fy - 72.0), 11.0, 0.0, TAU, 18, gold, 4.0)
	draw_line(Vector2(cx - 5.0, fy - 38.0), Vector2(cx - 26.0, fy - 22.0),
		gold, 5.0)

	if not GameState.is_morning():
		for g in range(6):
			var t: float = float(g) / 5.0
			draw_rect(Rect2(cx - 46.0 + t * 22.0, base - 40.0 - t * (base - top),
				92.0 - t * 44.0, 40.0), Color(1.0, 0.855, 0.545, 0.045))


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	return [
		[Vector2(500.0, CA.PAVE_TOP + 6.0), 1, 1],
	]
