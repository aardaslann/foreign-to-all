extends Node2D

# Tbilisi. Four districts, and the signature is a balcony.
#
# The BARAKONI is a carved wooden balcony bolted to the front of an unplastered
# brick house, and old Tiflis is nothing but them: fretwork panels, turned
# posts, and a roof over the whole thing, hanging out over the street on
# brackets. They are structurally alarming and nobody has fixed one since 1910.
#
# Around them: European Art Nouveau and neoclassicism mixed with local
# decoration by architects who had pattern books from Paris and grapevines in
# the garden. Iron balustrades. Tiles from Vienna. And the render coming off in
# sheets, because none of it has been maintained and the city has decided that
# is part of the character rather than a problem.
#
# SOLOLAKI is that, at its densest.
# DEZERTER is the bazaar by the station - concrete, tarpaulin, and produce.
# AVLABARI is across the river under the cliffs, with Metekhi on top of them.
# SABURTALO is Soviet modernism, and the only district here with straight lines.
#
# Georgia is on the itinerary for ritual oratory: it is your turn, and there is
# a correct shape. So the plate is warm, worn, and full of places to sit down.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "sololaki"
# "sololaki" | "dezerter" | "avlabari" | "saburtalo" | "chugureti"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.070, 0.058, 0.110)
const C_SKY_MID  := Color(0.110, 0.086, 0.145)
const C_SKY_LOW  := Color(0.204, 0.145, 0.161)
const C_SKY_HAZE := Color(0.294, 0.196, 0.153)

const C_DAY_HI   := Color(0.463, 0.573, 0.667)
const C_DAY_MID  := Color(0.671, 0.678, 0.647)
const C_DAY_LOW  := Color(0.827, 0.780, 0.686)

const C_BRICK    := Color(0.671, 0.545, 0.463)
const C_BRICK_D  := Color(0.545, 0.427, 0.361)
const C_RENDER   := Color(0.784, 0.741, 0.671)   # what is left of the plaster
const C_WOOD     := Color(0.502, 0.396, 0.298)   # the balconies, unpainted
const C_WOOD_P   := Color(0.596, 0.588, 0.522)   # the ones somebody painted
const C_IRON     := Color(0.235, 0.235, 0.243)
const C_TILE     := Color(0.643, 0.400, 0.302)
const C_GLASS    := Color(0.176, 0.184, 0.204)
const C_VINE     := Color(0.259, 0.396, 0.239)
const C_WINE     := Color(0.451, 0.129, 0.192)
const C_SULPHUR  := Color(0.545, 0.463, 0.376)   # the bath domes
const C_CONC     := Color(0.647, 0.639, 0.616)
const C_LAMP     := Color(1.0, 0.867, 0.639)
const C_JOINT    := Color(0.086, 0.070, 0.075, 0.36)

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
			C_WINE, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_RENDER, Color(0.20, 0.16, 0.13), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	_draw_far_towers()
	match district:
		"dezerter":  _draw_dezerter()
		"avlabari":  _draw_avlabari()
		"saburtalo": _draw_saburtalo()
		"chugureti": _draw_chugureti()
		_:           _draw_sololaki()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	# Sameba, on the hill in Avlabari. Eighty-four metres, finished in
	# 2004, and visible from most of the city.
	if district == "avlabari":
		_draw_sameba(806.0)
	CA.ground_floor(self, GROUND_Y, C_RENDER.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 81)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.66, 0.52, 0.34), 0.04)
	CA.vignette(self, 0.27)


# ── The house ─────────────────────────────────────────────────────────────────
# Unplastered brick where the render has gone, render where it has not, and a
# carved wooden balcony hanging off the front of it on brackets.

func _draw_tiflis_house(x: float, w: float, storeys: int, seed_i: int,
		painted: bool) -> void:
	var brick: Color = C_BRICK if (seed_i % 2) else C_BRICK_D
	var render: Color = C_RENDER
	if not GameState.is_morning():
		brick = brick.darkened(0.46)
		render = render.darkened(0.46)
	var floor_h: float = 46.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), brick)
	for r in range(int((GROUND_Y - top) / 6.0)):
		var y: float = top + float(r) * 6.0
		draw_rect(Rect2(x, y, w, 1.0), Color(0.86, 0.83, 0.78, 0.22))
		var off: float = 8.0 if (r % 2) else 0.0
		for c in range(int(w / 16.0) + 1):
			draw_rect(Rect2(x + off + float(c) * 16.0, y, 1.0, 6.0),
				Color(0.86, 0.83, 0.78, 0.16))
	# The render, in the patches where it has survived. The EDGE of the patch
	# is the thing that reads - a clean wall would be somewhere else entirely.
	for k in range(3):
		var px: float = x + float((seed_i * 37 + k * 53) % int(maxf(w - 50.0, 10.0)))
		var py: float = top + 8.0 + float((seed_i * 19 + k * 41) % 90)
		draw_colored_polygon(PackedVector2Array([
			Vector2(px, py), Vector2(px + 48.0, py - 6.0),
			Vector2(px + 54.0, py + 40.0), Vector2(px + 8.0, py + 46.0),
		]), render)
	CA.roof(self, x, w, top + 2.0, 15.0,
		C_TILE if GameState.is_morning() else C_TILE.darkened(0.48))

	var bays: int = maxi(2, int(w / 46.0))
	for s in range(storeys - 1):
		var wy: float = top + 18.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 29 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 28.0, C_GLASS,
			render.darkened(0.30), lit)
		# The balcony. Full width, on brackets, with a roof over it on the top
		# floor. This is the entire reason the city looks the way it does.
		if s == 0 or (seed_i + s) % 2 == 0:
			_draw_barakoni(x - 5.0, wy + 30.0, w + 10.0, seed_i + s, painted)


# Fretwork panel, turned posts, and a bracket every two feet. It sags.
func _draw_barakoni(x: float, y: float, w: float, seed_i: int,
		painted: bool) -> void:
	var wood: Color = C_WOOD_P if painted else C_WOOD
	if not GameState.is_morning():
		wood = wood.darkened(0.42)
	# The brackets under it, which is what stops it reading as a shelf.
	for i in range(int(w / 34.0) + 1):
		var bx: float = x + float(i) * 34.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, y + 6.0), Vector2(bx + 13.0, y + 6.0),
			Vector2(bx, y + 22.0),
		]), wood.darkened(0.24))
	draw_rect(Rect2(x, y, w, 7.0), wood.darkened(0.14))
	draw_rect(Rect2(x, y, w, 2.0), wood.lightened(0.20))
	# The fretwork: a rail top and bottom, turned balusters between, and a
	# pierced panel under the rail.
	draw_rect(Rect2(x, y - 26.0, w, 3.0), wood)
	for i in range(int(w / 11.0)):
		var px: float = x + 3.0 + float(i) * 11.0
		draw_rect(Rect2(px, y - 24.0, 3.0, 24.0), wood)
		draw_rect(Rect2(px - 1.5, y - 19.0, 6.0, 4.0), wood.lightened(0.12))
		draw_rect(Rect2(px - 1.5, y - 9.0, 6.0, 4.0), wood.lightened(0.12))
	# A sag, because they all sag. One pixel of droop in the middle does it.
	draw_rect(Rect2(x + w * 0.35, y + 6.0, w * 0.3, 2.0), wood.darkened(0.30))
	# The roof over the top-floor one.
	if (seed_i % 3) == 0:
		draw_rect(Rect2(x - 4.0, y - 46.0, w + 8.0, 6.0), wood.darkened(0.20))
		for i in range(int(w / 9.0)):
			draw_rect(Rect2(x + float(i) * 9.0, y - 46.0, 1.4, 6.0),
				Color(0, 0, 0, 0.20))
		for i in range(int(w / 40.0) + 1):
			draw_rect(Rect2(x + float(i) * 40.0, y - 40.0, 3.0, 16.0), wood)


# ── Sololaki ──────────────────────────────────────────────────────────────────
# The densest of it. Balconies on every floor of every house, a vine over the
# street, and the sulphur bath domes just visible at the end.

func _draw_sololaki() -> void:
	CA.far_mass(self, 178.0,
		C_BRICK_D.darkened(0.30) if GameState.is_morning()
		else C_BRICK_D.darkened(0.60),
		Color(0.90, 0.84, 0.72, 0.20), 22, 5)
	_draw_baths(880.0)
	for i in range(SOLOLAKI_ROW.size()):
		var spec: Array = SOLOLAKI_ROW[i]
		_draw_tiflis_house(float(spec[0]), float(spec[1]), int(spec[2]), i,
			(i % 3) == 0)
	_draw_vine(340.0)


const SOLOLAKI_ROW := [
	[-16.0, 124.0, 3], [108.0, 102.0, 4], [210.0, 130.0, 3], [340.0, 108.0, 4],
	[448.0, 126.0, 3], [574.0, 104.0, 4], [678.0, 132.0, 3], [810.0, 106.0, 4],
	[1000.0, 166.0, 3],
]


# The brick beehive domes of the sulphur baths, half sunk into the ground with
# the bathhouse itself underneath them.
func _draw_baths(x: float) -> void:
	var brick: Color = C_SULPHUR
	if not GameState.is_morning():
		brick = brick.darkened(0.50)
	for i in range(3):
		var dx: float = x + float(i) * 62.0
		var r: float = 30.0 - float(i) * 3.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(dx - r, 214.0), Vector2(dx - r * 0.8, 214.0 - r * 0.9),
			Vector2(dx, 214.0 - r * 1.25), Vector2(dx + r * 0.8, 214.0 - r * 0.9),
			Vector2(dx + r, 214.0),
		]), brick)
		for k in range(5):
			draw_rect(Rect2(dx - r * 0.9, 214.0 - float(k) * 7.0 - 5.0,
				r * 1.8, 1.4), Color(0, 0, 0, 0.20))
		# The glazed oculus in the top of every dome.
		draw_circle(Vector2(dx, 214.0 - r * 1.05), 4.0,
			Color(0.86, 0.90, 0.88, 0.70) if GameState.is_morning()
			else Color(0.98, 0.90, 0.68, 0.75))


func _draw_vine(x: float) -> void:
	var vine: Color = C_VINE
	if not GameState.is_morning():
		vine = vine.darkened(0.52)
	var pts := PackedVector2Array()
	for k in range(11):
		var u: float = float(k) / 10.0
		pts.append(Vector2(lerpf(x - 180.0, x + 300.0, u), 168.0 + sin(u * PI) * 18.0))
	draw_polyline(pts, Color(0.29, 0.24, 0.18, 0.85), 2.4, true)
	for i in range(22):
		var u: float = float(i) / 21.0
		var lx: float = lerpf(x - 180.0, x + 300.0, u)
		var ly: float = 168.0 + sin(u * PI) * 18.0
		draw_circle(Vector2(lx, ly + 7.0), 8.0, vine)
		if (i % 4) == 0:
			# A bunch. It is a wine country and the vine is over the street.
			for k in range(5):
				draw_circle(Vector2(lx - 4.0 + float(k % 3) * 4.0,
					ly + 18.0 + float(k / 3) * 5.0), 2.8,
					C_WINE if GameState.is_morning() else C_WINE.darkened(0.36))


# ── Dezerter ──────────────────────────────────────────────────────────────────
# The bazaar by the station. Concrete sheds, tarpaulin, and produce stacked as
# high as the person selling it.

func _draw_dezerter() -> void:
	var conc: Color = C_CONC
	if not GameState.is_morning():
		conc = conc.darkened(0.48)
	CA.far_mass(self, 190.0, conc.darkened(0.30),
		Color(0.88, 0.86, 0.80, 0.20), 24, 9)
	# The sheds: long, low, and roofed in corrugated sheet.
	for i in range(4):
		var sx: float = -30.0 + float(i) * 300.0
		draw_rect(Rect2(sx, 170.0, 288.0, GROUND_Y - 170.0), conc)
		draw_rect(Rect2(sx - 6.0, 162.0, 300.0, 10.0), conc.lightened(0.14))
		for k in range(int(300.0 / 9.0)):
			draw_rect(Rect2(sx - 6.0 + float(k) * 9.0, 162.0, 2.0, 10.0),
				Color(0, 0, 0, 0.18))
		for o in range(5):
			draw_rect(Rect2(sx + 18.0 + float(o) * 54.0, GROUND_Y - 58.0, 38.0, 58.0),
				Color(0.098, 0.086, 0.078))
		CA.awning(self, sx + 8.0, GROUND_Y - 76.0, 272.0,
			Color(0.196, 0.404, 0.353), Color(0.878, 0.855, 0.808))
	for i in range(5):
		CA.stall(self, 70.0 + float(i) * 220.0, CA.PAVE_TOP + 10.0, 150.0,
			Color(0.353, 0.278, 0.212),
			[Color(0.84, 0.24, 0.20), Color(0.90, 0.74, 0.18),
			 Color(0.31, 0.51, 0.27), Color(0.55, 0.24, 0.36)])


# ── Avlabari ──────────────────────────────────────────────────────────────────
# Across the river, under the cliffs, with Metekhi on the edge of them.

func _draw_avlabari() -> void:
	var rock: Color = Color(0.463, 0.400, 0.353)
	var water: Color = Color(0.212, 0.302, 0.310)
	if not GameState.is_morning():
		rock = rock.darkened(0.50)
		water = water.darkened(0.48)
	# The Mtkvari, and the cliff coming straight out of it.
	draw_rect(Rect2(0, 176.0, CA.VW, 40.0), water)
	for i in range(6):
		draw_rect(Rect2(0, 182.0 + float(i) * 6.0, CA.VW, 2.0),
			Color(0.68, 0.76, 0.78, 0.08 + 0.04 * sin(_t * 0.6 + float(i))))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40.0, 176.0), Vector2(-40.0, 96.0), Vector2(260.0, 88.0),
		Vector2(430.0, 122.0), Vector2(560.0, 176.0),
	]), rock)
	for i in range(16):
		draw_rect(Rect2(-30.0 + float(i) * 36.0, 110.0 + float((i * 23) % 40),
			3.0, 60.0), Color(0, 0, 0, 0.18))
	_draw_metekhi(240.0)
	for spec in [[600.0, 122.0, 3], [730.0, 104.0, 4], [840.0, 128.0, 3],
			[974.0, 110.0, 4], [1090.0, 96.0, 3]]:
		_draw_tiflis_house(float(spec[0]), float(spec[1]), int(spec[2]),
			int(spec[0]) % 7, false)


func _draw_metekhi(x: float) -> void:
	var stone: Color = Color(0.588, 0.522, 0.451)
	if not GameState.is_morning():
		stone = stone.darkened(0.50)
	draw_rect(Rect2(x - 44.0, 40.0, 88.0, 50.0), stone)
	# The Georgian dome: a conical roof on a tall drum, and it is a CONE, not
	# an onion. That is the whole difference from the city two stops back.
	draw_rect(Rect2(x - 16.0, 4.0, 32.0, 40.0), stone.lightened(0.06))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 22.0, 6.0), Vector2(x, -26.0), Vector2(x + 22.0, 6.0),
	]), stone.darkened(0.16))
	draw_rect(Rect2(x - 1.5, -40.0, 3.0, 16.0), stone.lightened(0.20))
	draw_rect(Rect2(x - 7.0, -34.0, 15.0, 2.6), stone.lightened(0.20))
	for k in range(4):
		draw_rect(Rect2(x - 12.0 + float(k) * 8.0, 14.0, 3.0, 20.0),
			stone.darkened(0.28))


# ── Saburtalo ─────────────────────────────────────────────────────────────────
# Soviet modernism. The only district in the city with a straight line in it.

func _draw_saburtalo() -> void:
	var conc: Color = C_CONC
	if not GameState.is_morning():
		conc = conc.darkened(0.50)
	CA.far_mass(self, 196.0, conc.darkened(0.34),
		Color(0.88, 0.88, 0.84, 0.20), 20, 11)
	for spec in [[-20.0, 300.0, 6], [290.0, 268.0, 6], [568.0, 312.0, 6],
			[890.0, 282.0, 6]]:
		_draw_slab(float(spec[0]), float(spec[1]), int(spec[2]))


func _draw_slab(x: float, w: float, storeys: int) -> void:
	var body: Color = C_CONC
	var dark: Color = C_CONC.darkened(0.22)
	if not GameState.is_morning():
		body = body.darkened(0.50)
		dark = dark.darkened(0.50)
	var floor_h: float = 32.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, dark)
	for s in range(storeys + 1):
		draw_rect(Rect2(x, GROUND_Y - float(s) * floor_h, w, 2.4), dark)
	for s in range(storeys):
		var wy: float = top + 9.0 + float(s) * floor_h
		var bays: int = maxi(2, int(w / 54.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 31 + s * 17) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 28.0, 18.0, C_GLASS, dark, lit)
		# The glazed-in balconies, none of which match, which is the one thing
		# that stops a slab like this reading as a diagram.
		var step: float = w / float(bays)
		for b in range(bays):
			if ((int(x) + b * 3 + s * 7) % 3) != 0:
				continue
			var bx: float = x + step * (float(b) + 0.5)
			draw_rect(Rect2(bx - 16.0, wy + 18.0, 32.0, 12.0), body.lightened(0.08))
			for g in range(3):
				draw_rect(Rect2(bx - 13.0 + float(g) * 9.0, wy + 21.0, 6.0, 7.0),
					C_GLASS.lightened(0.12))
	draw_rect(Rect2(x - 4.0, top - 6.0, w + 8.0, 7.0), dark.lightened(0.12))


# ── Chugureti ─────────────────────────────────────────────────────────────────
# The other bank. German colonists laid it out in the 1810s and the grid is
# still theirs, so the balconies are the same barakoni as Sololaki but the
# street behind them is straight - which is the only place in this city those
# two facts are true at once.
#
# Agmashenebeli runs through it, half pedestrianised and restored on one side,
# untouched on the other, and the join is visible from the middle of the road.

func _draw_chugureti() -> void:
	CA.far_mass(self, 182.0,
		C_BRICK_D.darkened(0.28) if GameState.is_morning()
		else C_BRICK_D.darkened(0.58),
		Color(0.90, 0.84, 0.72, 0.20), 20, 13)
	# Restored half: rendered, repainted, and the balconies put back properly.
	for i in range(3):
		_draw_tiflis_house(-16.0 + float(i) * 132.0, 126.0, 3, i, true)
	# Untouched half: the same houses with nothing done to them.
	for i in range(4):
		_draw_tiflis_house(392.0 + float(i) * 138.0, 132.0, 4, i + 5, false)
	_draw_tiflis_house(946.0, 220.0, 3, 9, false)
	# The seam. A hoarding down the join, where the restoration stopped.
	var board: Color = Color(0.545, 0.529, 0.498)
	if not GameState.is_morning():
		board = board.darkened(0.46)
	draw_rect(Rect2(376.0, GROUND_Y - 92.0, 14.0, 92.0), board)
	draw_rect(Rect2(376.0, GROUND_Y - 92.0, 14.0, 4.0), board.lightened(0.18))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.545, 0.510, 0.463)
	var road: Color = Color(0.298, 0.282, 0.263)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.08))
	if district == "sololaki" or district == "avlabari":
		# Cobbles, laid a long time ago and never relaid.
		CA.setts(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 10.0, C_JOINT)
		# The gaps where several are simply missing.
		for i in range(9):
			draw_rect(Rect2(float((i * 227) % 1100), CA.ROAD_TOP + 20.0 +
				float((i * 53) % 100), 22.0, 12.0), road.darkened(0.24))
	else:
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 50.0, 36.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 50.0, 36.0, C_JOINT)
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.70, 0.64, 0.52), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [150.0, 600.0, 1040.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 78.0, C_IRON, C_LAMP, lit)
	CA.bin(self, 300.0, CA.PAVE_TOP + 40.0, Color(0.243, 0.290, 0.243))
	# The qvevri: a clay wine vessel the size of a person, buried up to its
	# neck. Aboveground they stand outside cellars, and there is no other
	# object like them on the itinerary.
	if district != "saburtalo":
		_draw_qvevri(720.0)
		_draw_qvevri(772.0)
	# The marshrutka: a shared minibus that stops wherever you shout.
	if district == "dezerter" or district == "saburtalo":
		_draw_marshrutka(480.0)
	# A table and stools outside the cellar, because the supra can start here.
	if district == "sololaki":
		_draw_table(860.0)


func _draw_qvevri(x: float) -> void:
	var clay: Color = Color(0.502, 0.396, 0.322)
	if not GameState.is_morning():
		clay = clay.darkened(0.44)
	var y: float = CA.PAVE_TOP + 40.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 8.0, y), Vector2(x - 17.0, y - 26.0),
		Vector2(x - 13.0, y - 48.0), Vector2(x + 13.0, y - 48.0),
		Vector2(x + 17.0, y - 26.0), Vector2(x + 8.0, y),
	]), clay)
	draw_rect(Rect2(x - 15.0, y - 52.0, 30.0, 6.0), clay.lightened(0.14))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 15.0, y - 30.0), Vector2(x - 11.0, y - 46.0),
		Vector2(x - 7.0, y - 46.0), Vector2(x - 11.0, y - 28.0),
	]), clay.lightened(0.16))
	draw_rect(Rect2(x - 11.0, y, 23.0, 4.0), Color(0, 0, 0, 0.26))


func _draw_marshrutka(x: float) -> void:
	var body: Color = Color(0.859, 0.847, 0.827)
	var band: Color = C_WINE
	if not GameState.is_morning():
		body = body.darkened(0.44)
		band = band.darkened(0.40)
	var y: float = CA.ROAD_TOP + 48.0
	draw_rect(Rect2(x - 62.0, y - 50.0, 124.0, 50.0), body)
	draw_rect(Rect2(x - 62.0, y - 22.0, 124.0, 6.0), band)
	for i in range(5):
		draw_rect(Rect2(x - 54.0 + float(i) * 23.0, y - 44.0, 17.0, 16.0),
			Color(0.31, 0.38, 0.42))
	# The route number, taped in the windscreen on a piece of card.
	draw_rect(Rect2(x + 34.0, y - 44.0, 22.0, 12.0), Color(0.94, 0.92, 0.86))
	draw_rect(Rect2(x + 39.0, y - 41.0, 4.0, 7.0), Color(0.16, 0.15, 0.15))
	draw_rect(Rect2(x + 46.0, y - 41.0, 4.0, 7.0), Color(0.16, 0.15, 0.15))
	draw_circle(Vector2(x - 36.0, y + 2.0), 10.0, Color(0.13, 0.12, 0.12))
	draw_circle(Vector2(x + 38.0, y + 2.0), 10.0, Color(0.13, 0.12, 0.12))


func _draw_table(x: float) -> void:
	var wood: Color = C_WOOD
	if not GameState.is_morning():
		wood = wood.darkened(0.44)
	var y: float = CA.PAVE_TOP + 22.0
	draw_rect(Rect2(x - 40.0, y, 80.0, 6.0), wood.lightened(0.12))
	draw_rect(Rect2(x - 4.0, y + 6.0, 8.0, 18.0), wood)
	draw_rect(Rect2(x - 20.0, y + 24.0, 40.0, 4.0), wood.darkened(0.24))
	for s in [-52.0, 52.0]:
		draw_rect(Rect2(x + s - 9.0, y + 8.0, 18.0, 5.0), wood)
		draw_rect(Rect2(x + s - 8.0, y + 13.0, 4.0, 14.0), wood.darkened(0.20))
		draw_rect(Rect2(x + s + 4.0, y + 13.0, 4.0, 14.0), wood.darkened(0.20))
	# A jug and two glasses, and nobody has left yet.
	draw_rect(Rect2(x - 8.0, y - 16.0, 16.0, 17.0),
		C_WINE if GameState.is_morning() else C_WINE.darkened(0.30))
	draw_rect(Rect2(x + 14.0, y - 10.0, 6.0, 11.0), Color(0.80, 0.84, 0.82, 0.60))
	draw_rect(Rect2(x - 24.0, y - 10.0, 6.0, 11.0), Color(0.80, 0.84, 0.82, 0.60))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(288.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	if district != "saburtalo":
		out.append(Rect2(703.0, CA.PAVE_TOP + 14.0, 34.0, 28.0))   # qvevri
		out.append(Rect2(755.0, CA.PAVE_TOP + 14.0, 34.0, 28.0))   # qvevri
	if district == "sololaki":
		out.append(Rect2(820.0, CA.PAVE_TOP + 18.0, 80.0, 26.0))   # table
	if district == "dezerter":
		for i in range(5):
			out.append(Rect2(70.0 + float(i) * 220.0, CA.PAVE_TOP + 10.0,
				150.0, 30.0))
	return out


# The towers, where this city actually has them.
# A few new glass towers among the Soviet blocks, and they do not match
	# anything around them.
func _draw_far_towers() -> void:
	if district != "saburtalo":
		return
	CA.skyline(self, 220.0, Color(0.286, 0.278, 0.298), Color(0.176, 0.180, 0.208),
		5, 37, not GameState.is_morning())


# ── Sameba ───────────────────────────────────────────────────────────────────
# The Holy Trinity Cathedral, on the hill above Avlabari. Eighty-four metres,
# finished in 2004, and the largest church in the region by volume. It is
# built up in stepped tiers to a gold cone, which is why it reads at any size
# and from any direction - which was the intention.
func _draw_sameba(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var stone := Color(0.812, 0.741, 0.616)
	var gold := Color(0.855, 0.694, 0.278)
	if not morning:
		stone = stone.darkened(0.42)
		gold = gold.darkened(0.30)
	var base: float = 206.0

	# The stepped mass: four tiers, each narrower than the one under it.
	for k in range(4):
		var half: float = 122.0 - float(k) * 26.0
		var ty: float = base - float(k) * 34.0
		draw_rect(Rect2(cx - half, ty - 34.0, half * 2.0, 34.0), stone)
		draw_rect(Rect2(cx - half, ty - 34.0, half * 0.30, 34.0),
			stone.lightened(0.08))
		draw_rect(Rect2(cx - half - 5.0, ty - 38.0, (half + 5.0) * 2.0, 6.0),
			stone.lightened(0.16))
		# The blind arcading Georgian churches carry on every face.
		for a in range(int(half / 20.0)):
			var ax: float = cx - half + 12.0 + float(a) * 20.0
			draw_rect(Rect2(ax, ty - 26.0, 9.0, 18.0), stone.darkened(0.20))
			draw_circle(Vector2(ax + 4.5, ty - 26.0), 4.5, stone.darkened(0.20))

	# The drum, and the gold cone on it.
	var dy: float = base - 136.0
	draw_rect(Rect2(cx - 34.0, dy - 44.0, 68.0, 44.0), stone)
	for w in range(4):
		draw_rect(Rect2(cx - 26.0 + float(w) * 15.0, dy - 36.0, 7.0, 26.0),
			stone.darkened(0.34))
	draw_rect(Rect2(cx - 40.0, dy - 50.0, 80.0, 8.0), stone.lightened(0.14))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 40.0, dy - 50.0), Vector2(cx + 40.0, dy - 50.0),
		Vector2(cx, dy - 116.0),
	]), gold)
	for r in range(5):
		var f: float = float(r + 1) / 6.0
		draw_line(Vector2(cx - 40.0 * (1.0 - f), dy - 50.0 - 66.0 * f),
			Vector2(cx + 40.0 * (1.0 - f), dy - 50.0 - 66.0 * f),
			gold.darkened(0.18), 1.2)
	draw_rect(Rect2(cx - 2.0, dy - 142.0, 4.0, 28.0), gold)
	draw_rect(Rect2(cx - 9.0, dy - 134.0, 18.0, 4.0), gold)


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	return [
		[Vector2(420.0, CA.PAVE_TOP + 6.0), 0, 1],
	]
