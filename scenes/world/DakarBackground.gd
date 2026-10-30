extends Node2D

# Dakar. Four districts, on a headland, in a light nothing else on the itinerary
# gets: very high, very hard, and full of dust, so shadows are short and black
# and every pale surface goes to white by ten in the morning.
#
# THE MEDINA was laid out by colonial decree in 1914 as a segregation village -
# the indigenous population moved off the Plateau under cover of a plague
# scare. So it is a rigid grid of low courtyard houses, and that grid is not
# picturesque planning, it is what it was for. The plate does not editorialise;
# it just draws the grid honestly and lets the note say why it is straight.
#
# SANDAGA is the market hall of 1933: neo-Sudanese, modelled on the mud mosques
# of the Sahel, deliberately unlike every French building put around it. It is
# the most distinctive single structure on the whole itinerary.
#
# OUAKAM is the headland - basalt cliffs, and the sea behind the houses.
# YOFF is the fishing village: pirogues pulled up on the sand, painted like
# nothing else on earth.
#
# Senegal is here for the greeting sequence. The plate is open, warm, and slow.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "medina"
# "medina" | "sandaga" | "ouakam" | "yoff" | "plateau"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.086, 0.070, 0.118)
const C_SKY_MID  := Color(0.137, 0.106, 0.153)
const C_SKY_LOW  := Color(0.239, 0.161, 0.161)
const C_SKY_HAZE := Color(0.341, 0.216, 0.149)

const C_DAY_HI   := Color(0.404, 0.573, 0.729)
const C_DAY_MID  := Color(0.694, 0.729, 0.729)
const C_DAY_LOW  := Color(0.929, 0.867, 0.729)

const WASH := [
	Color(0.918, 0.878, 0.804),   # limewash, going to white in the sun
	Color(0.859, 0.780, 0.639),   # sand
	Color(0.769, 0.816, 0.788),   # pale green
	Color(0.831, 0.741, 0.686),   # pale rose
	Color(0.741, 0.796, 0.827),   # pale blue
]

const C_EARTH    := Color(0.706, 0.541, 0.376)   # the Sandaga hall
const C_EARTH_D  := Color(0.588, 0.435, 0.298)
const C_TILE     := Color(0.667, 0.353, 0.263)   # colonial roof tile
const C_SHUTTER  := Color(0.106, 0.427, 0.416)   # the teal, and it is everywhere
const C_TIMBER   := Color(0.361, 0.271, 0.196)
const C_GLASS    := Color(0.180, 0.192, 0.204)
const C_SAND     := Color(0.816, 0.729, 0.573)
const C_WAX      := [
	Color(0.878, 0.588, 0.129), Color(0.153, 0.451, 0.404),
	Color(0.769, 0.196, 0.243), Color(0.259, 0.376, 0.671),
	Color(0.929, 0.851, 0.302),
]
const C_SEA      := Color(0.129, 0.361, 0.435)
const C_BAOBAB   := Color(0.573, 0.502, 0.427)
const C_LAMP     := Color(1.0, 0.847, 0.588)
const C_JOINT    := Color(0.098, 0.078, 0.063, 0.26)

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
			WASH[0], Color(0.22, 0.16, 0.11), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.03))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	_draw_far_towers()
	match district:
		"sandaga": _draw_sandaga()
		"ouakam":  _draw_ouakam()
		"yoff":    _draw_yoff()
		"plateau": _draw_plateau()
		_:         _draw_medina()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	# The monument stands on the hill above Ouakam and the whole of that
	# side of the city can see it, which was the point of it.
	if district == "ouakam":
		_draw_renaissance(742.0)
	CA.ground_floor(self, GROUND_Y, C_TILE.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 3)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	# Harmattan dust. It is in the air most of the year and it is why the light
	# here goes orange rather than white at the horizon.
	CA.air(self, Color(0.86, 0.66, 0.36), 0.055)
	CA.motes(self, 18, Color(0.90, 0.82, 0.62, 0.10), _t, 9.0, 46.0, 2.0)
	CA.vignette(self, 0.24)


# ── The courtyard house ───────────────────────────────────────────────────────
# One or two storeys, flat roof, a parapet, and a doorway straight onto the
# street that leads to a courtyard you cannot see. Big shuttered openings,
# because the shutter does the work the glass does further north.

func _draw_house(x: float, w: float, storeys: int, ci: int, seed_i: int,
		tiled: bool) -> void:
	var body: Color = WASH[ci % WASH.size()]
	var shut: Color = C_SHUTTER
	if not GameState.is_morning():
		body = body.darkened(0.44)
		shut = shut.darkened(0.40)
	var floor_h: float = 46.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.16))
	if tiled:
		CA.roof(self, x, w, top + 2.0, 14.0,
			C_TILE if GameState.is_morning() else C_TILE.darkened(0.46))
	else:
		# A flat roof with a parapet, and the water tank on top of it.
		draw_rect(Rect2(x - 4.0, top - 10.0, w + 8.0, 11.0), body.lightened(0.14))
		draw_rect(Rect2(x - 4.0, top - 13.0, w + 8.0, 4.0), body.lightened(0.24))
		draw_rect(Rect2(x + w * 0.5 - 14.0, top - 30.0, 28.0, 18.0),
			Color(0.286, 0.427, 0.478) if GameState.is_morning()
			else Color(0.286, 0.427, 0.478).darkened(0.44))
	var bays: int = maxi(1, int(w / 54.0))
	var step: float = w / float(bays)
	for s in range(storeys):
		var wy: float = top + 16.0 + float(s) * floor_h
		if s == storeys - 1:
			continue
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 37 + s * 11) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 26.0, 32.0, C_GLASS,
			body.darkened(0.26), lit)
		for b in range(bays):
			CA.shutters(self, x + step * (float(b) + 0.5) - 13.0, wy, 26.0, 32.0,
				shut)
	# The doorway. Deep, dark, and it goes somewhere the street cannot see.
	var dx: float = x + w * 0.5
	draw_rect(Rect2(dx - 17.0, GROUND_Y - 52.0, 34.0, 52.0),
		Color(0.106, 0.086, 0.075))
	draw_rect(Rect2(dx - 20.0, GROUND_Y - 56.0, 40.0, 6.0), body.lightened(0.18))
	# A hanging cloth across it, in wax print, which is the actual door.
	var cloth: Color = C_WAX[seed_i % C_WAX.size()]
	if not GameState.is_morning():
		cloth = cloth.darkened(0.42)
	draw_rect(Rect2(dx - 15.0, GROUND_Y - 50.0, 30.0, 30.0), cloth)
	for k in range(3):
		draw_rect(Rect2(dx - 15.0, GROUND_Y - 44.0 + float(k) * 8.0, 30.0, 3.0),
			cloth.darkened(0.26))
	# Street art. The Medina is covered in it and it is signed work, not tags.
	if (seed_i % 3) == 0:
		_draw_mural(x + 8.0, top + 22.0, minf(w - 16.0, 96.0), seed_i)


func _draw_mural(x: float, y: float, w: float, seed_i: int) -> void:
	for i in range(4):
		var c: Color = C_WAX[(seed_i + i) % C_WAX.size()]
		if not GameState.is_morning():
			c = c.darkened(0.46)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + float(i) * (w / 4.0), y + 30.0),
			Vector2(x + float(i) * (w / 4.0) + 8.0, y),
			Vector2(x + float(i) * (w / 4.0) + w / 4.0, y + 6.0),
			Vector2(x + float(i) * (w / 4.0) + w / 4.0 - 6.0, y + 34.0),
		]), Color(c.r, c.g, c.b, 0.72))


# ── The Medina ────────────────────────────────────────────────────────────────
# A grid, laid out in 1914, of single-storey courtyard houses. Goods sold
# straight off the sand outside the door.

func _draw_medina() -> void:
	CA.far_mass(self, 200.0,
		WASH[1].darkened(0.28) if GameState.is_morning()
		else WASH[1].darkened(0.60),
		Color(0.94, 0.88, 0.72, 0.24), 26, 4)
	for i in range(9):
		var spec: Array = MEDINA_ROW[i]
		_draw_house(float(spec[0]), float(spec[1]), int(spec[2]), i, i, false)
	_draw_baobab(560.0)


const MEDINA_ROW := [
	[-16.0, 126.0, 2], [110.0, 104.0, 1], [214.0, 132.0, 2], [346.0, 108.0, 1],
	[454.0, 122.0, 2], [676.0, 116.0, 1], [792.0, 138.0, 2], [930.0, 110.0, 1],
	[1040.0, 128.0, 2],
]


# The baobab. Enormously thick trunk, almost no canopy, and branches like roots.
# It is the national tree and it does not look like any other tree in the game.
func _draw_baobab(x: float) -> void:
	var bark: Color = C_BAOBAB
	var leaf: Color = Color(0.361, 0.435, 0.286)
	if not GameState.is_morning():
		bark = bark.darkened(0.48)
		leaf = leaf.darkened(0.54)
	var base: float = CA.PAVE_TOP + 34.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 34.0, base), Vector2(x - 22.0, base - 96.0),
		Vector2(x + 22.0, base - 96.0), Vector2(x + 34.0, base),
	]), bark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 34.0, base), Vector2(x - 26.0, base - 60.0),
		Vector2(x - 16.0, base - 60.0), Vector2(x - 14.0, base),
	]), bark.lightened(0.10))
	# The branches: thin, bare, and going out sideways and up, like roots.
	for i in range(6):
		var a: float = -2.5 + float(i) * 0.42
		var ex: float = x + cos(a) * 62.0
		var ey: float = base - 96.0 + sin(a) * 34.0
		draw_line(Vector2(x, base - 92.0), Vector2(ex, ey), bark.darkened(0.10), 5.0)
		draw_line(Vector2(ex, ey), Vector2(ex + cos(a) * 24.0, ey - 16.0),
			bark.darkened(0.16), 2.6)
		draw_circle(Vector2(ex + cos(a) * 20.0, ey - 14.0), 11.0,
			Color(leaf.r, leaf.g, leaf.b, 0.60))
	draw_rect(Rect2(x - 40.0, base - 3.0, 80.0, 5.0), Color(0, 0, 0, 0.22))


# ── Sandaga ───────────────────────────────────────────────────────────────────
# The 1933 hall. Neo-Sudanese: battered walls, buttress piers running past the
# parapet into pinnacles, and the projecting timbers - toron - of a Sahel mud
# mosque, executed in concrete because it was 1933 and concrete was the point.

func _draw_sandaga() -> void:
	CA.far_mass(self, 196.0,
		WASH[1].darkened(0.30) if GameState.is_morning()
		else WASH[1].darkened(0.60),
		Color(0.94, 0.88, 0.72, 0.22), 22, 7)
	_draw_house(-16.0, 128.0, 2, 0, 1, true)
	_draw_house(112.0, 104.0, 2, 3, 4, true)
	_draw_hall(576.0)
	_draw_house(968.0, 118.0, 2, 2, 6, true)
	_draw_house(1086.0, 96.0, 2, 4, 8, true)


func _draw_hall(x: float) -> void:
	var wall: Color = C_EARTH
	var dark: Color = C_EARTH_D
	if not GameState.is_morning():
		wall = wall.darkened(0.46)
		dark = dark.darkened(0.46)
	var w: float = 620.0
	var top: float = 128.0
	# The mass, battered: wider at the bottom than the top.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - w * 0.5 - 12.0, GROUND_Y), Vector2(x - w * 0.5, top),
		Vector2(x + w * 0.5, top), Vector2(x + w * 0.5 + 12.0, GROUND_Y),
	]), wall)
	# The piers. They run the full height and keep going past the parapet, and
	# that overshoot is the entire silhouette of a Sahel mosque.
	for i in range(9):
		var px: float = x - w * 0.5 + 26.0 + float(i) * ((w - 52.0) / 8.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 15.0, GROUND_Y), Vector2(px - 10.0, top - 26.0),
			Vector2(px + 10.0, top - 26.0), Vector2(px + 15.0, GROUND_Y),
		]), wall.lightened(0.10))
		# The pinnacle on top, tapering to a point.
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 10.0, top - 26.0), Vector2(px, top - 54.0),
			Vector2(px + 10.0, top - 26.0),
		]), wall.lightened(0.16))
		draw_rect(Rect2(px - 2.0, top - 62.0, 4.0, 10.0), dark)
	# The toron: short beam ends projecting from the wall in regular rows.
	for r in range(3):
		var ty: float = top + 18.0 + float(r) * 34.0
		for c in range(22):
			draw_rect(Rect2(x - w * 0.5 + 12.0 + float(c) * 28.0, ty, 9.0, 5.0),
				dark)
			draw_rect(Rect2(x - w * 0.5 + 12.0 + float(c) * 28.0, ty + 5.0, 9.0, 2.0),
				Color(0, 0, 0, 0.28))
	# The openings: tall, narrow, and pointed, between every pair of piers.
	for i in range(8):
		var ox: float = x - w * 0.5 + 26.0 + float(i) * ((w - 52.0) / 8.0) + 34.0
		draw_rect(Rect2(ox, GROUND_Y - 74.0, 26.0, 74.0),
			Color(0.098, 0.078, 0.063))
		for k in range(9):
			var u: float = float(k) / 8.0
			var dy: float = (1.0 - absf(u - 0.5) * 2.0) * 18.0
			draw_rect(Rect2(ox + u * 26.0 - 2.0, GROUND_Y - 74.0 - dy, 5.0, dy + 3.0),
				Color(0.098, 0.078, 0.063))
	draw_rect(Rect2(x - w * 0.5 - 14.0, GROUND_Y - 5.0, w + 28.0, 7.0),
		dark.darkened(0.20))


# ── Ouakam ────────────────────────────────────────────────────────────────────
# The headland. Basalt cliffs behind the houses, and the Atlantic behind those.

func _draw_ouakam() -> void:
	var sea: Color = C_SEA
	if not GameState.is_morning():
		sea = sea.darkened(0.52)
	draw_rect(Rect2(0, 150.0, CA.VW, 62.0), sea)
	for i in range(7):
		var y: float = 158.0 + float(i) * 8.0
		var a: float = 0.10 + 0.06 * sin(_t * 0.5 + float(i))
		draw_rect(Rect2(0, y, CA.VW, 2.5), Color(0.78, 0.86, 0.88, a))
	# Basalt. Black, columnar, straight out of the water.
	var rock: Color = Color(0.235, 0.235, 0.255)
	if not GameState.is_morning():
		rock = rock.darkened(0.44)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40.0, 212.0), Vector2(-40.0, 168.0), Vector2(180.0, 176.0),
		Vector2(340.0, 208.0), Vector2(340.0, 212.0),
	]), rock)
	draw_colored_polygon(PackedVector2Array([
		Vector2(820.0, 212.0), Vector2(880.0, 182.0), Vector2(CA.VW + 40.0, 172.0),
		Vector2(CA.VW + 40.0, 212.0),
	]), rock)
	for i in range(22):
		draw_rect(Rect2(-30.0 + float(i) * 17.0, 180.0, 2.0, 32.0),
			Color(0, 0, 0, 0.24))
	for spec in [[300.0, 128.0, 2, 0], [434.0, 112.0, 1, 3], [552.0, 136.0, 2, 2],
			[694.0, 108.0, 1, 4]]:
		_draw_house(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 7, false)
	_draw_baobab(880.0)


# ── Yoff ──────────────────────────────────────────────────────────────────────
# The fishing village. Pirogues pulled up on the sand, painted in a way nothing
# else in the world is painted, and nets drying between them.

func _draw_yoff() -> void:
	var sea: Color = C_SEA
	if not GameState.is_morning():
		sea = sea.darkened(0.52)
	draw_rect(Rect2(0, 142.0, CA.VW, 74.0), sea)
	for i in range(9):
		var y: float = 150.0 + float(i) * 8.0
		var a: float = 0.10 + 0.07 * sin(_t * 0.45 + float(i) * 0.8)
		draw_rect(Rect2(0, y, CA.VW, 2.5), Color(0.80, 0.88, 0.90, a))
	draw_rect(Rect2(0, 210.0, CA.VW, 8.0), C_SAND.darkened(0.30))
	for spec in [[-16.0, 118.0, 1, 0], [104.0, 96.0, 1, 2], [886.0, 124.0, 1, 3],
			[1014.0, 132.0, 2, 1]]:
		_draw_house(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 7, false)
	for i in range(4):
		_draw_pirogue(280.0 + float(i) * 168.0, i)


# A pirogue: long, narrow, high at both ends, and painted stem to stern. They
# are named, and the name goes on the bow.
func _draw_pirogue(x: float, seed_i: int) -> void:
	var hull: Color = C_WAX[seed_i % C_WAX.size()]
	var trim: Color = C_WAX[(seed_i + 2) % C_WAX.size()]
	if not GameState.is_morning():
		hull = hull.darkened(0.44)
		trim = trim.darkened(0.44)
	var y: float = 250.0 + float(seed_i % 2) * 16.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 78.0, y - 22.0), Vector2(x - 54.0, y + 2.0),
		Vector2(x + 54.0, y + 2.0), Vector2(x + 78.0, y - 22.0),
		Vector2(x + 66.0, y + 8.0), Vector2(x - 66.0, y + 8.0),
	]), hull)
	draw_rect(Rect2(x - 62.0, y - 4.0, 124.0, 4.0), trim)
	draw_rect(Rect2(x - 60.0, y + 2.0, 120.0, 3.0), Color(0.94, 0.92, 0.86))
	for i in range(10):
		draw_rect(Rect2(x - 54.0 + float(i) * 12.0, y - 12.0, 5.0, 7.0), trim)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 78.0, y - 22.0), Vector2(x - 72.0, y - 34.0),
		Vector2(x - 66.0, y - 20.0),
	]), trim)
	draw_rect(Rect2(x - 74.0, y + 8.0, 148.0, 4.0), Color(0, 0, 0, 0.22))


# ── Plateau ───────────────────────────────────────────────────────────────────
# The administrative core the Medina was invented to keep people out of. Wide
# streets, Art Deco ministries, colonnaded ground floors, and a lot of shade
# that was designed for the people who worked inside rather than the people
# who walk past.
#
# It is drawn cool and formal and slightly too quiet, because it is the one
# district in Senegal where nobody greets you.

func _draw_plateau() -> void:
	CA.far_mass(self, 188.0,
		WASH[0].darkened(0.34) if GameState.is_morning()
		else WASH[0].darkened(0.62),
		Color(0.94, 0.90, 0.78, 0.20), 20, 15)
	for spec in [[-20.0, 232.0], [222.0, 196.0], [428.0, 244.0], [682.0, 208.0],
			[900.0, 268.0]]:
		_draw_ministry(float(spec[0]), float(spec[1]))
	for tx in [190.0, 640.0, 1080.0]:
		CA.tree(self, float(tx), CA.PAVE_TOP + 30.0, 56.0,
			Color(0.310, 0.263, 0.212), Color(0.239, 0.396, 0.286), 1.15)


func _draw_ministry(x: float, w: float) -> void:
	var body: Color = WASH[0]
	var trim: Color = Color(0.847, 0.827, 0.788)
	if not GameState.is_morning():
		body = body.darkened(0.46)
		trim = trim.darkened(0.44)
	var top: float = GROUND_Y - 132.0
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.16))
	# Deco: a stepped parapet, vertical fluting, and no ornament that is not
	# structural. The colonial state built like this everywhere it went.
	draw_rect(Rect2(x - 5.0, top - 10.0, w + 10.0, 11.0), trim)
	draw_rect(Rect2(x + w * 0.5 - 40.0, top - 22.0, 80.0, 13.0), trim)
	draw_rect(Rect2(x + w * 0.5 - 18.0, top - 32.0, 36.0, 11.0), trim)
	for b in range(int(w / 46.0) + 1):
		for g in range(3):
			draw_rect(Rect2(x + float(b) * 46.0 + float(g) * 5.0, top, 2.0,
				GROUND_Y - top - 56.0), body.darkened(0.14))
	var bays: int = maxi(3, int(w / 46.0))
	for s in range(2):
		var wy: float = top + 16.0 + float(s) * 42.0
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 17 + s * 9) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 30.0, C_GLASS, trim, lit)
		var step: float = w / float(bays)
		for b in range(bays):
			CA.shutters(self, x + step * (float(b) + 0.5) - 12.0, wy, 24.0, 30.0,
				C_SHUTTER if GameState.is_morning() else C_SHUTTER.darkened(0.40))
	# The colonnade: square piers and deep shade behind them, the whole width.
	draw_rect(Rect2(x, GROUND_Y - 56.0, w, 56.0), Color(0.106, 0.086, 0.075))
	for b in range(int(w / 46.0) + 1):
		draw_rect(Rect2(x + float(b) * 46.0, GROUND_Y - 56.0, 18.0, 56.0), trim)


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = C_SAND
	var road: Color = C_SAND.darkened(0.24)
	if district == "sandaga":
		pave = Color(0.596, 0.561, 0.494)
		road = Color(0.365, 0.345, 0.318)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.06))
	if district == "yoff" or district == "medina":
		# Sand. No kerb, because there is no distinction to mark.
		for i in range(40):
			draw_rect(Rect2(float((i * 191) % 1152),
				CA.PAVE_TOP + float((i * 67) % 340), 14.0, 4.0), pave.lightened(0.10))
		for i in range(14):
			draw_rect(Rect2(float((i * 313) % 1152),
				CA.PAVE_TOP + 40.0 + float((i * 91) % 280), 30.0, 5.0),
				pave.darkened(0.12))
	else:
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 46.0, 34.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 46.0, 34.0, C_JOINT)
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.20))


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [180.0, 640.0, 1060.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 82.0, C_TIMBER, C_LAMP, lit)
	# The car rapide: a blue-and-yellow minibus, hand-painted, every one
	# different and every one signed. They are being phased out; everybody minds.
	if district != "yoff":
		_draw_car_rapide(760.0)
	_draw_fabric_rack(330.0)
	CA.stall(self, 520.0, CA.PAVE_TOP + 12.0, 126.0, C_SHUTTER,
		[C_WAX[0], C_WAX[2], C_WAX[4]])
	CA.bin(self, 220.0, CA.PAVE_TOP + 40.0, C_SHUTTER.darkened(0.24))


func _draw_car_rapide(x: float) -> void:
	var body: Color = Color(0.929, 0.812, 0.278)
	var band: Color = Color(0.157, 0.325, 0.596)
	if not GameState.is_morning():
		body = body.darkened(0.42)
		band = band.darkened(0.40)
	var y: float = CA.ROAD_TOP + 50.0
	draw_rect(Rect2(x - 58.0, y - 54.0, 116.0, 54.0), body)
	draw_rect(Rect2(x - 58.0, y - 54.0, 116.0, 8.0), band)
	draw_rect(Rect2(x - 58.0, y - 26.0, 116.0, 9.0), band)
	for i in range(5):
		var c: Color = C_WAX[i % C_WAX.size()]
		if not GameState.is_morning():
			c = c.darkened(0.42)
		draw_rect(Rect2(x - 50.0 + float(i) * 21.0, y - 44.0, 15.0, 15.0), c)
	draw_rect(Rect2(x - 50.0, y - 15.0, 100.0, 11.0), Color(0.28, 0.30, 0.34))
	draw_circle(Vector2(x - 34.0, y + 2.0), 10.0, Color(0.13, 0.12, 0.12))
	draw_circle(Vector2(x + 34.0, y + 2.0), 10.0, Color(0.13, 0.12, 0.12))
	# The open back, and the step somebody rides on.
	draw_rect(Rect2(x + 52.0, y - 44.0, 8.0, 34.0), Color(0.10, 0.09, 0.09))
	draw_rect(Rect2(x + 56.0, y - 8.0, 16.0, 4.0), band.darkened(0.20))


func _draw_fabric_rack(x: float) -> void:
	var pole: Color = C_TIMBER
	if not GameState.is_morning():
		pole = pole.darkened(0.40)
	var y: float = CA.PAVE_TOP + 40.0
	draw_rect(Rect2(x - 60.0, y - 78.0, 120.0, 4.0), pole)
	draw_rect(Rect2(x - 58.0, y - 78.0, 5.0, 78.0), pole)
	draw_rect(Rect2(x + 53.0, y - 78.0, 5.0, 78.0), pole)
	for i in range(5):
		var c: Color = C_WAX[i % C_WAX.size()]
		if not GameState.is_morning():
			c = c.darkened(0.42)
		var sway: float = sin(_t * 0.6 + float(i) * 0.7) * 1.4
		draw_rect(Rect2(x - 52.0 + float(i) * 22.0 + sway, y - 74.0, 18.0, 56.0), c)
		for k in range(4):
			draw_rect(Rect2(x - 52.0 + float(i) * 22.0 + sway,
				y - 66.0 + float(k) * 13.0, 18.0, 3.0), c.darkened(0.26))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(208.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(520.0, CA.PAVE_TOP + 12.0, 126.0, 30.0))      # stall
	out.append(Rect2(270.0, CA.PAVE_TOP + 16.0, 120.0, 26.0))      # fabric rack
	if district == "medina":
		out.append(Rect2(526.0, CA.PAVE_TOP + 8.0, 68.0, 30.0))    # baobab
	if district == "ouakam":
		out.append(Rect2(846.0, CA.PAVE_TOP + 8.0, 68.0, 30.0))    # baobab
	if district == "yoff":
		for i in range(4):
			out.append(Rect2(202.0 + float(i) * 168.0, 246.0, 156.0, 26.0))
	return out


# The towers, where this city actually has them.
# The city stacks up in exactly one square and then stops. Ten minutes
	# away nothing is above three floors.
func _draw_far_towers() -> void:
	if district != "plateau":
		return
	CA.skyline(self, 222.0, Color(0.294, 0.290, 0.310), Color(0.176, 0.192, 0.216),
		6, 19, not GameState.is_morning())


# ── Le Monument de la Renaissance africaine ──────────────────────────────────
# Forty-nine metres of bronze on a hill at Ouakam, taller than the Statue of
# Liberty without her plinth. A man with a child on his arm, pointing out to
# sea, and a woman leaning back behind him.
#
# It cost the country a fortune, it was built by North Korean workmen, and
# people here argue about it constantly - which is a thing the plate should
# carry, so it is drawn as a silhouette against the sky rather than lit and
# admired.
func _draw_renaissance(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var bronze: Color = Color(0.404, 0.318, 0.180)
	var plinth: Color = Color(0.545, 0.478, 0.373)
	if not morning:
		# Floodlit from the foot of the hill. Darkening the bronze the way
		# a shopfront is darkened made it disappear into the sky.
		bronze = bronze.lightened(0.10)
		plinth = plinth.darkened(0.14)
	var base: float = 214.0

	# The hill it stands on, and the stair up the front of it.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 486.0, CA.PAVE_TOP), Vector2(cx - 243.0, base + 48.6),
		Vector2(cx + 243.0, base + 48.6), Vector2(cx + 486.0, CA.PAVE_TOP),
	]), plinth.darkened(0.24))
	for st in range(9):
		draw_rect(Rect2(cx - 74.5 - float(st) * 6.0, base + 55.1 + float(st) * 7.0,
			92.0 + float(st) * 12.0, 5.0), plinth.lightened(0.06))

	# The man: legs apart, one arm up and out, the other holding the child.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 35.6, base + 48.6), Vector2(cx - 9.7, base - 74.5),
		Vector2(cx + 16.2, base - 74.5), Vector2(cx + 38.9, base + 48.6),
		Vector2(cx + 9.7, base + 48.6), Vector2(cx + 3.2, base - 13.0),
		Vector2(cx - 6.5, base + 48.6),
	]), bronze)
	draw_rect(Rect2(cx - 25.9, base - 155.5, 30.0, 54.0), bronze)
	draw_circle(Vector2(cx - 1.6, base - 168.5), 13.0, bronze)
	# The raised arm, out to sea.
	draw_line(Vector2(cx + 16.2, base - 136.1), Vector2(cx + 100.4, base - 207.4),
		bronze, 11.0)
	# The child, sitting on the other arm, pointing the same way.
	draw_line(Vector2(cx - 22.7, base - 129.6), Vector2(cx - 68.0, base - 155.5),
		bronze, 10.0)
	draw_rect(Rect2(cx - 87.5, base - 207.4, 17.0, 30.0), bronze)
	draw_circle(Vector2(cx - 74.5, base - 213.8), 9.0, bronze)
	draw_line(Vector2(cx - 64.8, base - 204.1), Vector2(cx - 13.0, base - 246.2),
		bronze, 6.0)
	# The woman, leaning back behind him, hair out.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx + 32.4, base + 48.6), Vector2(cx + 55.1, base - 64.8),
		Vector2(cx + 84.2, base - 55.1), Vector2(cx + 71.3, base + 48.6),
	]), bronze.darkened(0.14))
	draw_rect(Rect2(cx + 51.8, base - 132.8, 22.0, 44.0), bronze.darkened(0.14))
	draw_circle(Vector2(cx + 71.3, base - 142.6), 12.0, bronze.darkened(0.14))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx + 84.2, base - 155.5), Vector2(cx + 136.1, base - 126.4),
		Vector2(cx + 90.7, base - 119.9),
	]), bronze.darkened(0.14))
	if not morning:
		for k in range(3):
			draw_circle(Vector2(cx, base - 129.6), 90.0 + float(k) * 40.0,
				Color(0.98, 0.86, 0.56, 0.075))
