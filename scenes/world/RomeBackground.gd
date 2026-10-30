extends Node2D

# Rome. Four districts, and the ground is the same in all of them.
#
# SAMPIETRINI: twelve-centimetre cubes of black basalt, set in rows or in fans,
# on sand. They are the most photographed surface in the city and the most
# complained-about, and they are the first thing this plate draws. Travertine
# kerbs, because the kerbs here are the same stone as the Colosseum and nobody
# finds that remarkable.
#
# TESTACCIO is the old slaughterhouse quarter: the market, and Monte dei Cocci,
# a fifty-metre hill made entirely of smashed Roman amphorae.
# ESQUILINO is Piazza Vittorio - long arcades on all four sides and the most
# mixed market in the city under them.
# TRASTEVERE is the narrow ochre lane with ivy down it and washing across it.
# MONTI is small squares, and Roman brickwork surfacing in the middle of a wall
# that somebody rendered over in 1890 and has been falling off since.
#
# Italy is on the itinerary for turn-taking: overlap is affiliation and waiting
# your turn is how you never speak. That is a dialogue mechanic and this file
# does not try to draw it - but the market plates are built dense and close so
# that being in a crowd of voices is the default state.
#
# NOTHING in this file draws anyone shouting. The mechanic is when you speak.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "testaccio"
# "testaccio" | "esquilino" | "trastevere" | "monti" | "garbatella"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Roman ochre is not one colour. It is a range from sand through apricot to a
# deep burnt sienna, all of it limewash over render, all of it patchy.
const C_SKY_ZEN  := Color(0.070, 0.062, 0.125)
const C_SKY_MID  := Color(0.110, 0.094, 0.161)
const C_SKY_LOW  := Color(0.208, 0.153, 0.176)
const C_SKY_HAZE := Color(0.302, 0.204, 0.161)

const C_DAY_HI   := Color(0.427, 0.573, 0.706)
const C_DAY_MID  := Color(0.667, 0.702, 0.694)
const C_DAY_LOW  := Color(0.839, 0.784, 0.678)

const OCHRE := [
	Color(0.831, 0.702, 0.510),   # sand
	Color(0.769, 0.573, 0.400),   # apricot
	Color(0.686, 0.451, 0.322),   # sienna
	Color(0.788, 0.647, 0.478),   # pale ochre
	Color(0.612, 0.400, 0.310),   # burnt
]

const C_TRAVERTINE := Color(0.792, 0.769, 0.706)
const C_SHUTTER    := Color(0.192, 0.322, 0.243)   # the green, and it is dark
const C_ROOFTILE   := Color(0.643, 0.400, 0.286)   # coppi, orange-red
const C_BASALT     := Color(0.157, 0.153, 0.169)
const C_ROMANBRICK := Color(0.667, 0.443, 0.353)
const C_IVY        := Color(0.184, 0.353, 0.243)
const C_PINE       := Color(0.161, 0.318, 0.243)
const C_GLASS      := Color(0.169, 0.180, 0.204)
const C_IRON       := Color(0.259, 0.251, 0.239)
const C_LAMP       := Color(1.0, 0.867, 0.616)
const C_JOINT      := Color(0.063, 0.059, 0.075, 0.40)

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
			C_SHUTTER, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_TRAVERTINE, Color(0.20, 0.16, 0.13), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"esquilino":  _draw_esquilino()
		"trastevere": _draw_trastevere()
		"monti":      _draw_monti()
		"garbatella": _draw_garbatella()
		_:            _draw_testaccio()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_TRAVERTINE.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 57)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.62, 0.48, 0.32), 0.035)
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	# Umbrella pines. Flat-topped, on a bare trunk, and the one tree silhouette
	# that says Rome from any distance at all.
	if district != "trastevere":
		_draw_pine(120.0, 0.9)
		_draw_pine(1000.0, 1.1)


func _draw_pine(x: float, s: float) -> void:
	var trunk: Color = Color(0.325, 0.271, 0.235)
	var canopy: Color = C_PINE
	if not GameState.is_morning():
		trunk = trunk.darkened(0.48)
		canopy = canopy.darkened(0.52)
	var base: float = 214.0
	draw_rect(Rect2(x - 4.0 * s, base - 110.0 * s, 8.0 * s, 110.0 * s), trunk)
	# The canopy is wide, shallow and FLAT on the bottom. That flat underside is
	# the whole silhouette; a round tree here would read as anywhere else.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 62.0 * s, base - 108.0 * s),
		Vector2(x - 34.0 * s, base - 134.0 * s),
		Vector2(x + 34.0 * s, base - 134.0 * s),
		Vector2(x + 62.0 * s, base - 108.0 * s),
	]), canopy)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 44.0 * s, base - 126.0 * s),
		Vector2(x, base - 144.0 * s),
		Vector2(x + 44.0 * s, base - 126.0 * s),
	]), canopy.lightened(0.08))


# ── The block ─────────────────────────────────────────────────────────────────
# A Roman palazzina: render over rubble, four or five floors, green louvred
# shutters, a cornice, coppi on top, and a stain wherever a downpipe leaks.

func _draw_palazzo(x: float, w: float, storeys: int, ci: int, seed_i: int,
		shutters_open: bool) -> void:
	var body: Color = OCHRE[ci % OCHRE.size()]
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var floor_h: float = 38.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	# Patchy limewash. Roman render is never one tone across a whole facade,
	# and the patches are where it has been repaired at different dates.
	for k in range(4):
		var px: float = x + float((seed_i * 41 + k * 67) % int(maxf(w - 40.0, 10.0)))
		var py: float = top + 12.0 + float((seed_i * 23 + k * 31) % 90)
		draw_rect(Rect2(px, py, 38.0, 30.0),
			body.lightened(0.06) if (k % 2) else body.darkened(0.06))
	# Downpipe stains.
	for k in range(2):
		var sx: float = x + 12.0 + float((seed_i * 53 + k * 79) % int(maxf(w - 24.0, 8.0)))
		draw_rect(Rect2(sx, top + 10.0, 5.0, GROUND_Y - top - 22.0),
			Color(0.24, 0.22, 0.18, 0.16))

	var tile: Color = C_ROOFTILE if GameState.is_morning() \
		else C_ROOFTILE.darkened(0.46)
	CA.band(self, x - 4.0, w + 8.0, top - 7.0, 8.0, C_TRAVERTINE
		if GameState.is_morning() else C_TRAVERTINE.darkened(0.44))
	CA.roof(self, x, w, top - 7.0, 13.0, tile)

	var bays: int = maxi(2, int(w / 44.0))
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 29 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 26.0, C_GLASS,
			C_TRAVERTINE.darkened(0.30), lit)
		var step: float = w / float(bays)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			var sh: Color = C_SHUTTER if GameState.is_morning() \
				else C_SHUTTER.darkened(0.42)
			if shutters_open or ((seed_i + b + s) % 3) != 0:
				CA.shutters(self, bx - 12.0, wy, 24.0, 26.0, sh)
			else:
				# Closed. Half the windows in Rome are, at any hour.
				draw_rect(Rect2(bx - 13.0, wy - 1.0, 26.0, 28.0), sh)
				for k in range(6):
					draw_rect(Rect2(bx - 13.0, wy + float(k) * 4.5, 26.0, 1.2),
						Color(0, 0, 0, 0.26))
			# A sill, in travertine, on every one.
			draw_rect(Rect2(bx - 15.0, wy + 26.0, 30.0, 3.0),
				C_TRAVERTINE if GameState.is_morning()
				else C_TRAVERTINE.darkened(0.44))


# ── Testaccio ─────────────────────────────────────────────────────────────────
# The market quarter. Behind it, Monte dei Cocci: a hill fifty metres high made
# entirely of deliberately smashed amphorae, stacked by the Roman state over
# two centuries. It is the only rubbish tip in the world that is a monument.

func _draw_testaccio() -> void:
	_draw_cocci(830.0)
	for spec in [[-16.0, 148.0, 4, 0], [132.0, 122.0, 5, 2], [254.0, 140.0, 4, 3],
			[394.0, 116.0, 5, 1], [510.0, 152.0, 4, 4], [662.0, 128.0, 5, 0],
			[790.0, 144.0, 4, 2], [934.0, 232.0, 5, 3]]:
		_draw_palazzo(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 7, true)
	# The market stalls, right along the near pavement.
	for i in range(4):
		CA.stall(self, 120.0 + float(i) * 220.0, CA.FAR_TOP - 34.0, 150.0,
			Color(0.588, 0.176, 0.161),
			[Color(0.85, 0.24, 0.20), Color(0.90, 0.72, 0.18),
			 Color(0.29, 0.51, 0.24)])


func _draw_cocci(x: float) -> void:
	var shard: Color = Color(0.639, 0.451, 0.353)
	if not GameState.is_morning():
		shard = shard.darkened(0.52)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 210.0, 214.0), Vector2(x - 120.0, 128.0),
		Vector2(x + 40.0, 116.0), Vector2(x + 190.0, 214.0),
	]), shard)
	# Every one of those is a broken pot. At this scale that is a texture of
	# little curved marks, and it is the only hill in the game made of objects.
	for i in range(90):
		var u: float = float((i * 37) % 100) / 100.0
		var px: float = lerpf(x - 200.0, x + 180.0, u)
		var py: float = 214.0 - float((i * 53) % 80) * (1.0 - absf(u - 0.5))
		draw_rect(Rect2(px, py, 5.0, 3.0),
			shard.lightened(0.14) if (i % 3) else shard.darkened(0.18))
	draw_rect(Rect2(x - 210.0, 212.0, 400.0, 4.0), shard.darkened(0.30))


# ── Esquilino ─────────────────────────────────────────────────────────────────
# Piazza Vittorio: a long arcade on every side, and the most mixed market in
# the city under it. The arcade is the whole plate.

func _draw_esquilino() -> void:
	var body: Color = OCHRE[3]
	if not GameState.is_morning():
		body = body.darkened(0.46)
	draw_rect(Rect2(-20.0, 96.0, CA.VW + 40.0, GROUND_Y - 96.0), body)
	CA.band(self, -20.0, CA.VW + 40.0, 90.0, 8.0,
		C_TRAVERTINE if GameState.is_morning() else C_TRAVERTINE.darkened(0.44))
	for s in range(3):
		var wy: float = 108.0 + float(s) * 44.0
		var lit: int = 0
		if not GameState.is_morning():
			lit = (s * 37 + 11) % 65535
		CA.window_row(self, -20.0, CA.VW + 40.0, wy, 14, 26.0, 28.0, C_GLASS,
			C_TRAVERTINE.darkened(0.30), lit)
		for b in range(14):
			var bx: float = -20.0 + (CA.VW + 40.0) / 14.0 * (float(b) + 0.5)
			CA.shutters(self, bx - 13.0, wy, 26.0, 28.0,
				C_SHUTTER if GameState.is_morning() else C_SHUTTER.darkened(0.42))
	# The arcade itself: round arches on square piers, and deep shade behind.
	var pier: Color = C_TRAVERTINE if GameState.is_morning() \
		else C_TRAVERTINE.darkened(0.40)
	draw_rect(Rect2(-20.0, GROUND_Y - 96.0, CA.VW + 40.0, 96.0),
		Color(0.086, 0.070, 0.063))
	for i in range(9):
		var px: float = -30.0 + float(i) * 140.0
		draw_rect(Rect2(px, GROUND_Y - 96.0, 34.0, 96.0), pier)
		draw_rect(Rect2(px, GROUND_Y - 96.0, 10.0, 96.0), pier.lightened(0.14))
		# The arch springing from it.
		for k in range(10):
			var u: float = float(k) / 9.0
			var dy: float = sin(u * PI) * 26.0
			draw_rect(Rect2(px + 34.0 + u * 106.0 - 5.0, GROUND_Y - 96.0 - dy,
				11.0, dy + 5.0), pier)
	draw_rect(Rect2(-20.0, GROUND_Y - 4.0, CA.VW + 40.0, 6.0), pier.darkened(0.24))


# ── Trastevere ────────────────────────────────────────────────────────────────
# Narrow, ochre, ivy down one side and washing across the top. No pines, no
# sky: the lane is too tight for either.

func _draw_trastevere() -> void:
	for spec in [[-14.0, 88.0, 5, 2], [76.0, 72.0, 5, 0], [150.0, 94.0, 4, 4],
			[246.0, 78.0, 5, 1], [326.0, 86.0, 5, 3], [414.0, 70.0, 4, 2],
			[486.0, 98.0, 5, 0], [586.0, 76.0, 5, 4], [664.0, 90.0, 4, 1],
			[756.0, 82.0, 5, 3], [840.0, 96.0, 5, 2], [938.0, 74.0, 4, 0],
			[1014.0, 152.0, 5, 1]]:
		_draw_palazzo(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 7, false)
	_draw_ivy(300.0, 130.0)
	_draw_ivy(760.0, 96.0)
	# Washing, strung across the lane. It is not picturesque; there is nowhere
	# else to put it.
	for i in range(3):
		_draw_washing(180.0 + float(i) * 340.0, 152.0 + float(i % 2) * 14.0)


func _draw_ivy(x: float, w: float) -> void:
	var leaf: Color = C_IVY if GameState.is_morning() else C_IVY.darkened(0.50)
	for i in range(int(w / 7.0)):
		var lx: float = x + float(i) * 7.0
		var drop: float = 34.0 + float((i * 29) % 70)
		draw_rect(Rect2(lx, 120.0, 3.0, drop), leaf.darkened(0.24))
		for k in range(int(drop / 9.0)):
			draw_circle(Vector2(lx + 1.5 + float((i + k) % 3) - 1.0,
				126.0 + float(k) * 9.0), 4.0, leaf)


func _draw_washing(x: float, y: float) -> void:
	var line := Color(0.20, 0.19, 0.18, 0.75)
	draw_line(Vector2(x - 120.0, y), Vector2(x + 120.0, y + 8.0), line, 1.2)
	var cloth := [Color(0.86, 0.84, 0.80), Color(0.55, 0.62, 0.71),
		Color(0.78, 0.63, 0.55), Color(0.86, 0.84, 0.80)]
	for i in range(6):
		var u: float = (float(i) + 0.5) / 6.0
		var cx: float = lerpf(x - 120.0, x + 120.0, u)
		var cy: float = lerpf(y, y + 8.0, u)
		var c: Color = cloth[i % cloth.size()]
		if not GameState.is_morning():
			c = c.darkened(0.46)
		var sway: float = sin(_t * 0.7 + float(i)) * 1.6
		draw_rect(Rect2(cx - 9.0 + sway, cy + 2.0, 18.0, 26.0), c)
		draw_rect(Rect2(cx - 9.0 + sway, cy + 2.0, 18.0, 2.0), c.darkened(0.20))


# ── Monti ─────────────────────────────────────────────────────────────────────
# Small squares, and Roman brick coming through the render where the plaster
# has fallen off. Nobody has fixed it because it is two thousand years old and
# fixing it would be worse.

func _draw_monti() -> void:
	# The terrace opens for one street. Every second lane in this rione runs
	# downhill and stops at the same object, and drawing the terrace solid
	# hides the only building in Rome anybody could name.
	_draw_colosseum(636.0)
	for spec in [[-16.0, 132.0, 4, 1], [116.0, 108.0, 5, 3], [224.0, 126.0, 4, 0],
			[832.0, 130.0, 4, 3], [962.0, 112.0, 5, 0],
			[1074.0, 202.0, 4, 2]]:
		_draw_palazzo(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 7, true)
	_draw_exposed_brick(268.0, 96.0)
	_draw_exposed_brick(978.0, 74.0)
	# A fragment of wall that predates every building touching it.
	_draw_ruin(360.0)


# Opus latericium: thin flat Roman brick in very regular courses, showing where
# the nineteenth-century render came away.
func _draw_exposed_brick(x: float, w: float) -> void:
	var brick: Color = C_ROMANBRICK
	if not GameState.is_morning():
		brick = brick.darkened(0.48)
	var top: float = 140.0
	var h: float = 84.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, top + 8.0), Vector2(x + 14.0, top), Vector2(x + w - 10.0, top + 6.0),
		Vector2(x + w, top + h - 12.0), Vector2(x + w - 20.0, top + h),
		Vector2(x + 6.0, top + h - 6.0),
	]), brick)
	for r in range(int(h / 5.0)):
		draw_rect(Rect2(x + 4.0, top + 6.0 + float(r) * 5.0, w - 12.0, 1.0),
			Color(0.85, 0.82, 0.76, 0.34))
		var off: float = 8.0 if (r % 2) else 0.0
		for c in range(int(w / 16.0)):
			draw_rect(Rect2(x + 6.0 + off + float(c) * 16.0,
				top + 6.0 + float(r) * 5.0, 1.0, 5.0), Color(0.85, 0.82, 0.76, 0.26))


func _draw_ruin(x: float) -> void:
	var stone: Color = C_TRAVERTINE.darkened(0.18)
	if not GameState.is_morning():
		stone = stone.darkened(0.48)
	draw_rect(Rect2(x - 60.0, CA.PAVE_TOP - 66.0, 120.0, 66.0), stone)
	draw_rect(Rect2(x - 60.0, CA.PAVE_TOP - 66.0, 120.0, 5.0), stone.lightened(0.18))
	for r in range(5):
		draw_rect(Rect2(x - 60.0, CA.PAVE_TOP - 60.0 + float(r) * 12.0, 120.0, 1.4),
			Color(0, 0, 0, 0.24))
	# The top is broken, not built. That jagged edge is the whole point.
	for i in range(7):
		var bx: float = x - 58.0 + float(i) * 17.0
		draw_rect(Rect2(bx, CA.PAVE_TOP - 66.0 - float((i * 13) % 3) * 5.0,
			15.0, 8.0), stone)
	draw_rect(Rect2(x - 66.0, CA.PAVE_TOP - 4.0, 132.0, 6.0), stone.darkened(0.26))


# ── Garbatella ────────────────────────────────────────────────────────────────
# The 1920s garden suburb. It is built as lotti - numbered courtyard blocks, low
# and ochre, with an arched entry through the middle of each one and a shared
# court behind it that you can see straight into from the street.
#
# It is the only place in Rome that was planned all at once by somebody who
# thought about where people would sit, and it is the quietest plate in Italy.

func _draw_garbatella() -> void:
	CA.far_mass(self, 208.0,
		Color(0.353, 0.400, 0.322) if GameState.is_morning()
		else Color(0.353, 0.400, 0.322).darkened(0.56),
		Color(0.88, 0.82, 0.68, 0.16), 12, 3)
	for i in range(4):
		_draw_lotto(-20.0 + float(i) * 300.0, i)
	for tx in [270.0, 870.0]:
		CA.tree(self, float(tx), CA.PAVE_TOP + 34.0, 52.0,
			Color(0.310, 0.259, 0.212), C_PINE.lightened(0.10), 1.1)


func _draw_lotto(x: float, seed_i: int) -> void:
	var w: float = 280.0
	_draw_palazzo(x, w, 3, seed_i % OCHRE.size(), seed_i, true)
	# The arch through the middle, and the court behind it. The court is drawn
	# dark and small on purpose: you can see there is one, not what is in it.
	var ax: float = x + w * 0.5
	draw_rect(Rect2(ax - 34.0, GROUND_Y - 76.0, 68.0, 76.0),
		Color(0.098, 0.086, 0.078))
	for k in range(13):
		var u: float = float(k) / 12.0
		var dy: float = sin(u * PI) * 26.0
		draw_rect(Rect2(ax - 34.0 + u * 68.0 - 4.0, GROUND_Y - 76.0 - dy,
			9.0, dy + 4.0), Color(0.098, 0.086, 0.078))
	var lit: Color = Color(0.42, 0.46, 0.38) if GameState.is_morning() 		else Color(0.16, 0.17, 0.15)
	draw_rect(Rect2(ax - 26.0, GROUND_Y - 44.0, 52.0, 44.0), lit)
	if GameState.is_morning():
		draw_rect(Rect2(ax - 14.0, GROUND_Y - 30.0, 28.0, 30.0), lit.darkened(0.20))
	# The lotto number, on a stone plaque over the arch. Every block has one and
	# people still give directions by them.
	var stone: Color = C_TRAVERTINE if GameState.is_morning() 		else C_TRAVERTINE.darkened(0.44)
	draw_rect(Rect2(ax - 17.0, GROUND_Y - 96.0, 34.0, 17.0), stone)
	for d in range(2):
		draw_rect(Rect2(ax - 10.0 + float(d) * 11.0, GROUND_Y - 92.0, 6.0, 9.0),
			stone.darkened(0.44))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = C_TRAVERTINE.darkened(0.32)
	var road: Color = Color(0.259, 0.251, 0.251)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.44)
	if district == "trastevere":
		# One surface, wall to wall. The lane is too narrow for a pavement and
		# the sampietrini go straight up to the doorsteps.
		CA.ground(self, road, road, road)
		CA.setts(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 12.0, C_JOINT)
	else:
		CA.ground(self, pave, road, pave.darkened(0.08))
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 62.0, 40.0,
			Color(0, 0, 0, 0.14))
		CA.setts(self, CA.ROAD_TOP, CA.FAR_TOP - CA.ROAD_TOP, 12.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 62.0, 40.0,
			Color(0, 0, 0, 0.14))
		# Travertine kerbs. The same stone as the Colosseum, holding a gutter.
		CA.kerb(self, CA.ROAD_TOP, C_TRAVERTINE if GameState.is_morning()
			else C_TRAVERTINE.darkened(0.42))
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.72, 0.66, 0.56), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	# The nasone. A cast-iron post with a curved spout that runs constantly and
	# is never turned off. There are about two and a half thousand of them and
	# everybody drinks from them.
	_draw_nasone(388.0)
	if district != "trastevere":
		_draw_nasone(872.0)
	for x in [170.0, 640.0, 1060.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 78.0, C_IRON, C_LAMP, lit)
	if district == "trastevere" or district == "monti":
		# Tables out on the sampietrini, permanently, and never level.
		_draw_tables(560.0)
	CA.bin(self, 250.0, CA.PAVE_TOP + 40.0, Color(0.239, 0.290, 0.243))
	# A scooter, parked at an angle that would be illegal anywhere else.
	_draw_scooter(478.0)


func _draw_nasone(x: float) -> void:
	var iron: Color = C_IRON if GameState.is_morning() else C_IRON.darkened(0.34)
	var base: float = CA.PAVE_TOP + 42.0
	draw_rect(Rect2(x - 7.0, base - 62.0, 14.0, 62.0), iron)
	draw_rect(Rect2(x - 7.0, base - 62.0, 4.0, 62.0), iron.lightened(0.22))
	draw_rect(Rect2(x - 10.0, base - 68.0, 20.0, 7.0), iron.lightened(0.14))
	draw_rect(Rect2(x - 9.0, base - 2.0, 19.0, 4.0), iron.darkened(0.30))
	# The spout, and the water, which is always running.
	draw_rect(Rect2(x + 5.0, base - 48.0, 12.0, 4.0), iron)
	draw_rect(Rect2(x + 14.0, base - 46.0, 3.0, 10.0), iron)
	var jitter: float = sin(_t * 11.0) * 0.5
	draw_rect(Rect2(x + 15.0 + jitter, base - 36.0, 2.0, 36.0),
		Color(0.70, 0.84, 0.88, 0.55))
	draw_circle(Vector2(x + 16.0, base + 1.0), 6.0, Color(0.55, 0.68, 0.72, 0.24))


func _draw_tables(x: float) -> void:
	var wood: Color = Color(0.478, 0.373, 0.290)
	var cloth: Color = Color(0.831, 0.804, 0.745)
	if not GameState.is_morning():
		wood = wood.darkened(0.42)
		cloth = cloth.darkened(0.44)
	for i in range(3):
		var tx: float = x + float(i) * 92.0
		draw_rect(Rect2(tx - 26.0, CA.PAVE_TOP + 18.0, 52.0, 6.0), cloth)
		draw_rect(Rect2(tx - 3.0, CA.PAVE_TOP + 24.0, 6.0, 18.0), wood)
		draw_rect(Rect2(tx - 16.0, CA.PAVE_TOP + 40.0, 32.0, 3.0), wood.darkened(0.20))
		for s in [-34.0, 34.0]:
			draw_rect(Rect2(tx + s - 8.0, CA.PAVE_TOP + 22.0, 16.0, 4.0), wood)
			draw_rect(Rect2(tx + s - 8.0, CA.PAVE_TOP + 26.0, 3.0, 16.0), wood)
			draw_rect(Rect2(tx + s + 5.0, CA.PAVE_TOP + 26.0, 3.0, 16.0), wood)


func _draw_scooter(x: float) -> void:
	var body: Color = Color(0.812, 0.796, 0.769)
	if not GameState.is_morning():
		body = body.darkened(0.44)
	var y: float = CA.PAVE_TOP + 34.0
	draw_arc(Vector2(x - 16.0, y), 8.0, 0, TAU, 14, Color(0.14, 0.13, 0.13), 3.0)
	draw_arc(Vector2(x + 18.0, y), 8.0, 0, TAU, 14, Color(0.14, 0.13, 0.13), 3.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 20.0, y - 6.0), Vector2(x + 4.0, y - 10.0),
		Vector2(x + 22.0, y - 6.0), Vector2(x + 20.0, y + 1.0),
		Vector2(x - 18.0, y + 1.0),
	]), body)
	draw_rect(Rect2(x + 12.0, y - 30.0, 4.0, 22.0), body.darkened(0.24))
	draw_rect(Rect2(x + 4.0, y - 32.0, 20.0, 4.0), Color(0.16, 0.15, 0.15))
	draw_rect(Rect2(x - 16.0, y - 16.0, 20.0, 7.0), Color(0.13, 0.12, 0.12))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(238.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(381.0, CA.PAVE_TOP + 14.0, 14.0, 28.0))       # nasone
	out.append(Rect2(458.0, CA.PAVE_TOP + 20.0, 44.0, 22.0))       # scooter
	if district != "trastevere":
		out.append(Rect2(865.0, CA.PAVE_TOP + 14.0, 14.0, 28.0))   # nasone
	if district == "trastevere" or district == "monti":
		for i in range(3):
			out.append(Rect2(534.0 + float(i) * 92.0, CA.PAVE_TOP + 18.0, 52.0, 24.0))
	if district == "monti":
		out.append(Rect2(454.0, CA.PAVE_TOP - 20.0, 132.0, 24.0))  # the ruin
	if district == "esquilino":
		for i in range(9):
			out.append(Rect2(-30.0 + float(i) * 140.0, CA.PAVE_TOP - 20.0, 34.0, 24.0))
	return out


# The Colosseum. It is at the bottom of this hill and you can see it from the
# end of half the streets in Monti, which is a fact people who live here stop
# noticing within about a fortnight.
#
# Two thirds of it is missing. The outer wall came down in an earthquake and
# was quarried for four hundred years to build churches, so what stands is the
# inner ring on one side and the full height on the other, and the step down
# between them is the shape everybody actually recognises.
func _draw_colosseum(cx: float) -> void:
	# Floodlit after dark, which is why it does not simply go grey with the
	# rest of the street. Drawn at a third of the plate's width: it was half
	# this size and read as a low wall behind a bus stop.
	var stone: Color = C_TRAVERTINE
	if not GameState.is_morning():
		stone = C_TRAVERTINE.darkened(0.18)
	var base: float = 286.0
	var full: float = 62.0            # top of the standing half
	var low: float = 158.0            # top of the quarried half
	var lw: float = 236.0             # standing half, width
	var rw: float = 188.0             # quarried half, width

	# The glow the floodlights throw up the face of it.
	if not GameState.is_morning():
		for g in range(5):
			var f: float = float(g) / 4.0
			draw_rect(Rect2(cx - lw - 26.0 + f * 20.0, full - 16.0 + f * 12.0,
				lw + rw + 52.0 - f * 40.0, base - full + 16.0),
				Color(1.0, 0.812, 0.545, 0.030))

	# The outer ends curve away from the viewer, which is the only thing
	# that stops two stacked rectangles reading as an office block.
	var lp := PackedVector2Array()
	for i in range(13):
		var f: float = float(i) / 12.0
		lp.append(Vector2(cx - lw + f * lw, full + pow(1.0 - f, 2.2) * 30.0))
	for j in range(13):
		var g: float = 1.0 - float(j) / 12.0
		lp.append(Vector2(cx - lw + g * lw, base - pow(1.0 - g, 2.2) * 22.0))
	draw_colored_polygon(lp, stone)
	var rp := PackedVector2Array()
	for i2 in range(13):
		var f2: float = float(i2) / 12.0
		rp.append(Vector2(cx + f2 * rw, low + pow(f2, 2.2) * 34.0))
	for j2 in range(13):
		var g2: float = 1.0 - float(j2) / 12.0
		rp.append(Vector2(cx + g2 * rw, base - pow(g2, 2.2) * 26.0))
	draw_colored_polygon(rp, stone.darkened(0.10))

	# Four orders on the standing half: three tiers of arcade and a solid
	# attic. The arches are openings, so they are cut dark into the face.
	var dark: Color = stone.darkened(0.52)
	for tier in range(3):
		var ty: float = full + 30.0 + float(tier) * 46.0
		if ty + 30.0 > base:
			break
		for a in range(11):
			var ax: float = cx - lw + 12.0 + float(a) * 21.0
			draw_rect(Rect2(ax, ty + 8.0, 14.0, 26.0), dark)
			draw_circle(Vector2(ax + 7.0, ty + 8.0), 7.0, dark)
			# The pier between the arches catches the light.
			draw_rect(Rect2(ax + 14.0, ty - 4.0, 7.0, 38.0), stone.lightened(0.08))
		draw_rect(Rect2(cx - lw, ty - 8.0, lw, 5.0), stone.lightened(0.14))
	# The attic storey: no arches, just pilasters and the small square windows.
	for k in range(11):
		draw_rect(Rect2(cx - lw + 16.0 + float(k) * 21.0, full + 10.0, 5.0, 16.0),
			stone.darkened(0.22))

	# The quarried half, cut down to the second order.
	for tier2 in range(2):
		var ty2: float = low + 26.0 + float(tier2) * 46.0
		if ty2 + 30.0 > base:
			break
		for a2 in range(9):
			var ax2: float = cx + 10.0 + float(a2) * 20.0
			draw_rect(Rect2(ax2, ty2 + 8.0, 13.0, 25.0), dark)
			draw_circle(Vector2(ax2 + 6.5, ty2 + 8.0), 6.5, dark)
		draw_rect(Rect2(cx, ty2 - 8.0, rw, 5.0), stone.lightened(0.10))

	draw_rect(Rect2(cx - lw, full, lw, 14.0), stone.lightened(0.16))
	draw_rect(Rect2(cx, low, rw, 12.0), stone.lightened(0.10))
	# The broken end is a diagonal, not a clean edge - that step down from
	# four orders to two is the whole silhouette.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 8.0, full), Vector2(cx, full),
		Vector2(cx + 14.0, low), Vector2(cx - 8.0, low),
	]), stone.darkened(0.24))


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	return [
		[Vector2(700.0, CA.PAVE_TOP + 6.0), 0, 2],
	]
