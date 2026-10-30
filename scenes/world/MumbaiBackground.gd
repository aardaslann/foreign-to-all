extends Node2D

# Mumbai. Four districts, and the defining form is the CHAWL.
#
# A chawl is a multi-storey block where the circulation is on the outside: a
# continuous shared gallery runs the full width of every floor, and that gallery
# IS the facade. Everything happens on it - washing, cooking, sitting, arguing -
# so the front of the building is not a wall with windows in it, it is a stack
# of occupied corridors. Nothing else on the itinerary is built that way and it
# is the first thing to get right.
#
# Then: limewash gone blue-green with damp, timber balconies, monsoon staining
# down every wall, and hand-painted signage in more scripts than any other city
# on the list gets - which is the point, because India is here for code-mixing.
#
# BHULESHWAR is the wholesale lanes: narrow, temple-dense, and stacked.
# CHOR BAZAAR is Mutton Street - salvage, brass, and things off ships, and the
# street where a pod fragment would actually end up.
# BYCULLA is the old mill district with Bombay Gothic dropped into it.
# BANDRA is Art Deco and Portuguese-era village lanes with crosses at the corners.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "bhuleshwar"
# "bhuleshwar" | "chorbazaar" | "byculla" | "bandra" | "colaba"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Limewash that has been through thirty monsoons: the blue-green is algae and
# copper wash, and it is what stops the city reading as sandy.
const C_SKY_ZEN  := Color(0.086, 0.070, 0.118)
const C_SKY_MID  := Color(0.129, 0.102, 0.153)
const C_SKY_LOW  := Color(0.235, 0.161, 0.169)
const C_SKY_HAZE := Color(0.333, 0.212, 0.157)

const C_DAY_HI   := Color(0.510, 0.588, 0.663)
const C_DAY_MID  := Color(0.706, 0.706, 0.671)
const C_DAY_LOW  := Color(0.867, 0.804, 0.694)

const WASH := [
	Color(0.678, 0.741, 0.698),   # the blue-green
	Color(0.741, 0.694, 0.588),   # sand
	Color(0.639, 0.667, 0.702),   # grey-blue
	Color(0.769, 0.639, 0.502),   # ochre
	Color(0.596, 0.663, 0.616),   # deeper green
]

const C_TIMBER   := Color(0.310, 0.231, 0.169)
const C_TIMBER_L := Color(0.475, 0.361, 0.243)
const C_STONE    := Color(0.612, 0.573, 0.502)   # basalt, for the Gothic
const C_GLASS    := Color(0.161, 0.180, 0.196)
const C_SAFFRON  := Color(0.867, 0.494, 0.129)
const C_TEAL     := Color(0.137, 0.435, 0.427)
const C_TAXI_Y   := Color(0.918, 0.769, 0.169)
const C_DAMP     := Color(0.204, 0.290, 0.239)
const C_LAMP     := Color(1.0, 0.839, 0.573)
const C_JOINT    := Color(0.094, 0.078, 0.070, 0.30)

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
			C_SAFFRON, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_TEAL, Color(0.94, 0.91, 0.84), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	_draw_far_towers()
	match district:
		"chorbazaar": _draw_chorbazaar()
		"byculla":    _draw_byculla()
		"bandra":     _draw_bandra()
		"colaba":     _draw_colaba()
		_:            _draw_bhuleshwar()
	_draw_wires()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	# The arch on the water at the end of the Causeway, drawn after the
	# street so the arcade cannot bury it.
	if district == "colaba":
		_draw_gateway(760.0)
	CA.ground_floor(self, GROUND_Y, C_TIMBER.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 39)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.70, 0.56, 0.34), 0.05)
	CA.vignette(self, 0.27)


# ── The chawl ─────────────────────────────────────────────────────────────────
# The gallery is the facade. Doors open onto it, washing hangs off it, and it
# runs the full width of the block on every single floor.

func _draw_chawl(x: float, w: float, storeys: int, ci: int, seed_i: int) -> void:
	var body: Color = WASH[ci % WASH.size()]
	var timber: Color = C_TIMBER
	if not GameState.is_morning():
		body = body.darkened(0.46)
		timber = timber.darkened(0.28)
	var floor_h: float = 42.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body.darkened(0.30))

	for s in range(storeys):
		var fy: float = GROUND_Y - float(s + 1) * floor_h
		# The wall the doors are in, set BACK behind the gallery.
		draw_rect(Rect2(x + 6.0, fy + 6.0, w - 12.0, floor_h - 6.0), body)
		var doors: int = maxi(2, int(w / 44.0))
		var step: float = w / float(doors)
		for d in range(doors):
			var dx: float = x + step * (float(d) + 0.5)
			var open_door: bool = ((seed_i + d * 3 + s * 5) % 3) == 0
			draw_rect(Rect2(dx - 11.0, fy + 12.0, 22.0, 24.0),
				Color(0.98, 0.86, 0.62, 0.75) if (open_door
					and not GameState.is_morning())
				else timber)
			draw_rect(Rect2(dx - 12.0, fy + 10.0, 24.0, 3.0), timber.lightened(0.20))
		# The gallery slab, and the rail on the front of it. This is the line
		# that makes the whole building read as a chawl.
		draw_rect(Rect2(x - 3.0, fy + floor_h - 12.0, w + 6.0, 6.0),
			body.lightened(0.14))
		draw_rect(Rect2(x - 3.0, fy + floor_h - 6.0, w + 6.0, 4.0),
			Color(0, 0, 0, 0.34))
		_draw_rail(x - 2.0, fy + floor_h - 26.0, w + 4.0, timber)
		# Washing over the rail, on most floors. It is not decoration; there is
		# nowhere else for it to go.
		if ((seed_i + s) % 3) != 2:
			_draw_gallery_washing(x + 8.0, fy + floor_h - 24.0, w - 16.0, seed_i + s)

	# Monsoon staining, straight down from every gallery edge.
	for k in range(5):
		var sx: float = x + 8.0 + float((seed_i * 43 + k * 61) % int(maxf(w - 16.0, 8.0)))
		draw_rect(Rect2(sx, top + 10.0, 6.0, GROUND_Y - top - 20.0),
			Color(C_DAMP.r, C_DAMP.g, C_DAMP.b, 0.20))
	draw_rect(Rect2(x - 5.0, top - 8.0, w + 10.0, 9.0),
		body.lightened(0.10) if GameState.is_morning() else body.lightened(0.04))


func _draw_rail(x: float, y: float, w: float, col: Color) -> void:
	draw_rect(Rect2(x, y, w, 2.4), col)
	draw_rect(Rect2(x, y + 14.0, w, 2.4), col)
	for i in range(int(w / 9.0)):
		draw_rect(Rect2(x + float(i) * 9.0, y, 1.6, 16.0), col)


func _draw_gallery_washing(x: float, y: float, w: float, seed_i: int) -> void:
	var cloth := [Color(0.86, 0.31, 0.24), Color(0.24, 0.45, 0.67),
		Color(0.91, 0.82, 0.35), Color(0.87, 0.86, 0.82),
		Color(0.31, 0.55, 0.42), Color(0.78, 0.45, 0.62)]
	var n: int = int(w / 16.0)
	for i in range(n):
		var c: Color = cloth[(i + seed_i) % cloth.size()]
		if not GameState.is_morning():
			c = c.darkened(0.44)
		var sway: float = sin(_t * 0.8 + float(i) * 0.6) * 1.2
		var h: float = 14.0 + float((i * 17 + seed_i) % 8)
		draw_rect(Rect2(x + float(i) * 16.0 + sway, y, 12.0, h), c)
		draw_rect(Rect2(x + float(i) * 16.0 + sway, y, 12.0, 2.0), c.darkened(0.24))


# ── Bhuleshwar ────────────────────────────────────────────────────────────────
# The wholesale lanes. Narrow, stacked, and a temple gate every hundred metres.

func _draw_bhuleshwar() -> void:
	for spec in [[-16.0, 118.0, 4, 0], [104.0, 96.0, 5, 2], [202.0, 124.0, 4, 1],
			[328.0, 102.0, 5, 4], [432.0, 130.0, 4, 3], [564.0, 98.0, 5, 0],
			[664.0, 120.0, 4, 2], [786.0, 106.0, 5, 1], [894.0, 128.0, 4, 4],
			[1024.0, 142.0, 5, 3]]:
		_draw_chawl(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 11)
	_draw_shikhara(482.0)
	for i in range(6):
		CA.sign_stack(self, 40.0 + float(i) * 190.0, GROUND_Y - 74.0, 96.0, 2,
			[C_SAFFRON, C_TEAL, Color(0.78, 0.18, 0.20)][i % 3],
			Color(0.95, 0.93, 0.88), i)


# A temple spire between the buildings. Tiered, tapering, and painted, which is
# what the small street shrines here actually look like.
func _draw_shikhara(x: float) -> void:
	var body: Color = Color(0.898, 0.867, 0.816)
	var trim: Color = C_SAFFRON
	if not GameState.is_morning():
		body = body.darkened(0.44)
		trim = trim.darkened(0.36)
	var y: float = GROUND_Y - 44.0
	var w: float = 76.0
	for i in range(6):
		draw_rect(Rect2(x - w * 0.5, y - 22.0, w, 24.0), body)
		draw_rect(Rect2(x - w * 0.5, y - 22.0, w, 4.0), trim)
		for k in range(int(w / 13.0)):
			draw_rect(Rect2(x - w * 0.5 + 3.0 + float(k) * 13.0, y - 17.0, 7.0, 12.0),
				body.darkened(0.14))
		y -= 22.0
		w *= 0.82
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 12.0, y), Vector2(x, y - 22.0), Vector2(x + 12.0, y),
	]), trim)
	draw_rect(Rect2(x - 2.0, y - 34.0, 4.0, 14.0), trim.lightened(0.20))


# ── Chor Bazaar ───────────────────────────────────────────────────────────────
# Mutton Street. Everything that ever came off a ship, stacked on the pavement
# and sold again. This is where the fragment ends up, and the plate is built so
# that a small dark object in a heap of small dark objects is believable.

func _draw_chorbazaar() -> void:
	for spec in [[-16.0, 126.0, 3, 1], [110.0, 108.0, 4, 3], [218.0, 134.0, 3, 0],
			[352.0, 112.0, 4, 2], [464.0, 140.0, 3, 4], [604.0, 116.0, 4, 1],
			[720.0, 132.0, 3, 3], [852.0, 110.0, 4, 0], [962.0, 204.0, 3, 2]]:
		_draw_chawl(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 11)
	# The goods, out on the pavement, in the quantity that gives the street its
	# name. Brass, clocks, doorknobs, and a lot of things nobody can identify.
	for i in range(7):
		_draw_junk_heap(90.0 + float(i) * 160.0, int(i))


func _draw_junk_heap(x: float, seed_i: int) -> void:
	var brass: Color = Color(0.729, 0.596, 0.286)
	var iron: Color = Color(0.353, 0.341, 0.325)
	var chrome: Color = Color(0.639, 0.651, 0.663)
	if not GameState.is_morning():
		brass = brass.darkened(0.42)
		iron = iron.darkened(0.40)
		chrome = chrome.darkened(0.42)
	var y: float = CA.PAVE_TOP + 40.0
	draw_rect(Rect2(x - 42.0, y - 12.0, 84.0, 14.0), Color(0.28, 0.24, 0.20))
	for i in range(16):
		var px: float = x - 38.0 + float((seed_i * 31 + i * 47) % 76)
		var py: float = y - 16.0 - float((seed_i * 17 + i * 29) % 26)
		var c: Color = [brass, iron, chrome][(seed_i + i) % 3]
		var kind: int = (seed_i * 3 + i) % 4
		if kind == 0:
			draw_circle(Vector2(px, py), 5.0, c)
			draw_circle(Vector2(px, py), 2.5, c.darkened(0.30))
		elif kind == 1:
			draw_rect(Rect2(px - 5.0, py - 4.0, 10.0, 8.0), c)
		elif kind == 2:
			draw_rect(Rect2(px - 2.0, py - 7.0, 4.0, 14.0), c)
		else:
			draw_rect(Rect2(px - 6.0, py - 2.0, 12.0, 4.0), c)
			draw_rect(Rect2(px - 1.0, py - 6.0, 2.0, 5.0), c)


# ── Byculla ───────────────────────────────────────────────────────────────────
# The mill district, with Bombay Gothic dropped into the middle of it: basalt,
# pointed arches, and a clock nobody has wound since the mills shut.

func _draw_byculla() -> void:
	CA.far_mass(self, 176.0,
		Color(0.353, 0.333, 0.318) if GameState.is_morning()
		else Color(0.353, 0.333, 0.318).darkened(0.58),
		Color(0.86, 0.80, 0.66, 0.22), 26, 5)
	_draw_mill_chimney(150.0)
	_draw_mill_chimney(1010.0)
	_draw_gothic(520.0)
	_draw_chawl(-16.0, 132.0, 4, 0, 3)
	_draw_chawl(118.0, 110.0, 4, 2, 6)
	_draw_chawl(788.0, 126.0, 4, 1, 9)
	_draw_chawl(916.0, 250.0, 4, 4, 2)


func _draw_mill_chimney(x: float) -> void:
	var brick: Color = Color(0.545, 0.361, 0.290)
	if not GameState.is_morning():
		brick = brick.darkened(0.52)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 15.0, 214.0), Vector2(x - 9.0, 30.0),
		Vector2(x + 9.0, 30.0), Vector2(x + 15.0, 214.0),
	]), brick)
	draw_rect(Rect2(x - 13.0, 26.0, 26.0, 9.0), brick.lightened(0.16))
	for i in range(11):
		draw_rect(Rect2(x - 14.0, 46.0 + float(i) * 16.0, 28.0, 2.0),
			Color(0, 0, 0, 0.18))


func _draw_gothic(x: float) -> void:
	var stone: Color = C_STONE
	if not GameState.is_morning():
		stone = stone.darkened(0.50)
	var w: float = 240.0
	draw_rect(Rect2(x - w * 0.5, 132.0, w, GROUND_Y - 132.0), stone)
	draw_rect(Rect2(x - w * 0.5 - 6.0, 126.0, w + 12.0, 9.0), stone.lightened(0.16))
	# Pointed arches, in two ranks. The point is the whole style.
	for rank in range(2):
		var ay: float = 168.0 + float(rank) * 46.0
		for i in range(5):
			var ax: float = x - w * 0.5 + 22.0 + float(i) * 44.0
			draw_rect(Rect2(ax, ay, 30.0, 38.0), Color(0.098, 0.086, 0.082))
			for k in range(9):
				var u: float = float(k) / 8.0
				var dy: float = (1.0 - absf(u - 0.5) * 2.0) * 20.0
				draw_rect(Rect2(ax + u * 30.0 - 2.5, ay - dy, 6.0, dy + 3.0),
					Color(0.098, 0.086, 0.082))
			draw_rect(Rect2(ax - 3.0, ay - 22.0, 36.0, 3.0), stone.lightened(0.10))
	# The clock tower, and it is stopped.
	draw_rect(Rect2(x - 26.0, 62.0, 52.0, 72.0), stone)
	draw_rect(Rect2(x - 30.0, 56.0, 60.0, 9.0), stone.lightened(0.16))
	draw_circle(Vector2(x, 96.0), 17.0, stone.darkened(0.24))
	draw_circle(Vector2(x, 96.0), 14.0, Color(0.878, 0.855, 0.796)
		if GameState.is_morning() else Color(0.541, 0.529, 0.494))
	draw_rect(Rect2(x - 1.5, 86.0, 3.0, 11.0), stone.darkened(0.50))
	draw_rect(Rect2(x, 95.0, 9.0, 3.0), stone.darkened(0.50))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 30.0, 62.0), Vector2(x, 20.0), Vector2(x + 30.0, 62.0),
	]), stone.darkened(0.14))


# ── Bandra ────────────────────────────────────────────────────────────────────
# Art Deco on the main road, and behind it the Portuguese-era village lanes with
# a painted cross at every corner and a bougainvillea over every gate.

func _draw_bandra() -> void:
	CA.far_mass(self, 198.0,
		Color(0.392, 0.427, 0.388) if GameState.is_morning()
		else Color(0.392, 0.427, 0.388).darkened(0.56),
		Color(0.88, 0.82, 0.68, 0.20), 20, 8)
	for spec in [[-16.0, 158.0, 0], [148.0, 136.0, 2], [292.0, 152.0, 4],
			[452.0, 140.0, 1], [600.0, 160.0, 3], [768.0, 144.0, 0],
			[920.0, 248.0, 2]]:
		_draw_deco(float(spec[0]), float(spec[1]), int(spec[2]))
	_draw_cross(380.0)
	CA.tree(self, 700.0, CA.FAR_TOP + 22.0, 64.0, Color(0.298, 0.243, 0.196),
		Color(0.208, 0.373, 0.263), 1.25)


func _draw_deco(x: float, w: float, ci: int) -> void:
	var body: Color = WASH[ci % WASH.size()].lightened(0.22)
	if not GameState.is_morning():
		body = body.darkened(0.44)
	var storeys: int = 3
	var floor_h: float = 42.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	# Bombay Deco: rounded corners and three eyebrow bands over the windows.
	draw_rect(Rect2(x - 4.0, top - 9.0, w + 8.0, 10.0), body.lightened(0.18))
	draw_rect(Rect2(x + w * 0.5 - 30.0, top - 20.0, 60.0, 12.0), body.lightened(0.24))
	var bays: int = maxi(2, int(w / 54.0))
	var step: float = w / float(bays)
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 29 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 30.0, 28.0, C_GLASS,
			body.darkened(0.28), lit)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			for e in range(3):
				draw_rect(Rect2(bx - 22.0 + float(e) * 2.0, wy - 9.0 + float(e) * 2.5,
					44.0 - float(e) * 4.0, 2.0), body.lightened(0.20))
			CA.balcony(self, bx - 20.0, wy + 28.0, 40.0,
				body.darkened(0.34), true)


func _draw_cross(x: float) -> void:
	var white: Color = Color(0.918, 0.906, 0.878)
	var blue: Color = Color(0.216, 0.404, 0.639)
	if not GameState.is_morning():
		white = white.darkened(0.42)
		blue = blue.darkened(0.44)
	var base: float = CA.PAVE_TOP + 40.0
	draw_rect(Rect2(x - 26.0, base - 18.0, 52.0, 18.0), white)
	draw_rect(Rect2(x - 22.0, base - 78.0, 44.0, 62.0), white)
	draw_rect(Rect2(x - 22.0, base - 78.0, 44.0, 5.0), blue)
	draw_rect(Rect2(x - 5.0, base - 116.0, 10.0, 40.0), white)
	draw_rect(Rect2(x - 19.0, base - 104.0, 38.0, 10.0), white)
	draw_rect(Rect2(x - 16.0, base - 66.0, 32.0, 34.0), blue.darkened(0.24))
	if GameState.is_morning():
		return
	for k in range(3):
		draw_circle(Vector2(x, base - 50.0), 30.0 + float(k) * 16.0,
			Color(1.0, 0.90, 0.72, 0.024 - float(k) * 0.005))


# ── Colaba ────────────────────────────────────────────────────────────────────
# The Causeway. Basalt Gothic ground floors with a continuous arcade cut
# through them, so the pavement runs INSIDE the buildings for half a mile, and
# the stalls set up between the piers because that is where the shade is.
#
# It is the only street in the city where the shop, the pavement and the
# building are the same object, and it is why nobody here stands still.

func _draw_colaba() -> void:
	var stone: Color = C_STONE
	if not GameState.is_morning():
		stone = stone.darkened(0.50)
	CA.far_mass(self, 158.0, stone.darkened(0.34),
		Color(0.88, 0.84, 0.74, 0.20), 26, 19)
	for i in range(4):
		_draw_causeway(-20.0 + float(i) * 300.0, stone, i)
	# Stalls between the piers, in the shade, selling to the pavement.
	for i in range(6):
		CA.stall(self, 70.0 + float(i) * 186.0, CA.PAVE_TOP + 8.0, 128.0,
			C_TEAL, [C_SAFFRON, Color(0.86, 0.30, 0.24), Color(0.24, 0.51, 0.33)])


func _draw_causeway(x: float, stone: Color, seed_i: int) -> void:
	var w: float = 282.0
	var top: float = 148.0
	draw_rect(Rect2(x, top, w, GROUND_Y - top), stone)
	for r in range(int((GROUND_Y - top) / 8.0)):
		draw_rect(Rect2(x, top + float(r) * 8.0, w, 1.2), Color(0, 0, 0, 0.15))
	draw_rect(Rect2(x - 5.0, top - 10.0, w + 10.0, 11.0), stone.lightened(0.16))
	# Two floors of pointed windows over the arcade.
	for s in range(2):
		var wy: float = top + 16.0 + float(s) * 44.0
		for b in range(5):
			var bx: float = x + 26.0 + float(b) * 54.0
			draw_rect(Rect2(bx, wy, 28.0, 32.0),
				Color(0.98, 0.90, 0.70, 0.80) if (not GameState.is_morning()
					and ((seed_i + b + s) % 3) == 0) else C_GLASS)
			for k in range(9):
				var u: float = float(k) / 8.0
				var dy: float = (1.0 - absf(u - 0.5) * 2.0) * 14.0
				draw_rect(Rect2(bx + u * 28.0 - 2.0, wy - dy, 5.0, dy + 3.0),
					stone.darkened(0.20))
			draw_rect(Rect2(bx - 3.0, wy + 32.0, 34.0, 4.0), stone.lightened(0.10))
	# The arcade. Deep shade, and square piers you walk between.
	draw_rect(Rect2(x, GROUND_Y - 78.0, w, 78.0), Color(0.086, 0.075, 0.070))
	for b in range(6):
		var px: float = x + float(b) * 54.0
		draw_rect(Rect2(px, GROUND_Y - 78.0, 22.0, 78.0), stone)
		draw_rect(Rect2(px, GROUND_Y - 78.0, 7.0, 78.0), stone.lightened(0.12))
		draw_rect(Rect2(px - 4.0, GROUND_Y - 82.0, 30.0, 6.0), stone.lightened(0.18))


# ── Wires and ground ──────────────────────────────────────────────────────────

func _draw_wires() -> void:
	var wire := Color(0.078, 0.070, 0.070, 0.80)
	var poles := [70.0, 340.0, 610.0, 880.0, 1130.0]
	for i in range(poles.size() - 1):
		CA.wires(self, float(poles[i]), 132.0, float(poles[i + 1]), 138.0,
			6, 26.0, wire)
	for p in poles:
		CA.pole(self, float(p), CA.PAVE_TOP + 40.0, 200.0, C_TIMBER_L, 2)
		CA.wire_knot(self, float(p), 134.0, wire)


func _draw_ground() -> void:
	var pave: Color = Color(0.510, 0.478, 0.435)
	var road: Color = Color(0.278, 0.267, 0.259)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.08))
	CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 40.0, 28.0, C_JOINT)
	CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 40.0, 28.0, C_JOINT)
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.16))
	# The kerb is painted black and white in stripes, everywhere, always.
	for i in range(int(CA.VW / 34.0) + 1):
		draw_rect(Rect2(float(i) * 34.0, CA.ROAD_TOP - 6.0, 17.0, 6.0),
			Color(0.90, 0.88, 0.84) if GameState.is_morning()
			else Color(0.60, 0.59, 0.56))
	# Standing water in the gutter. It is always there and it is never clean.
	CA.sheen(self, CA.ROAD_TOP, CA.FAR_TOP - CA.ROAD_TOP,
		Color(0.44, 0.50, 0.44), _t)


func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [200.0, 620.0, 1040.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 78.0, C_TIMBER_L, C_LAMP, lit)
	CA.bin(self, 340.0, CA.PAVE_TOP + 40.0, C_TEAL.darkened(0.20))
	# The kaali-peeli. Black roof, yellow body, and it is the one vehicle that
	# means Bombay and nowhere else.
	_draw_taxi(830.0)
	if district == "bhuleshwar" or district == "chorbazaar":
		CA.stall(self, 560.0, CA.PAVE_TOP + 12.0, 128.0, C_SAFFRON,
			[Color(0.88, 0.32, 0.20), Color(0.94, 0.78, 0.22),
			 Color(0.24, 0.49, 0.31)])
	# The chai glass rack, set down on the pavement wherever it was needed.
	_draw_chai(470.0)


func _draw_taxi(x: float) -> void:
	var body: Color = C_TAXI_Y
	var roof: Color = Color(0.125, 0.118, 0.118)
	if not GameState.is_morning():
		body = body.darkened(0.40)
	var y: float = CA.ROAD_TOP + 46.0
	draw_rect(Rect2(x - 46.0, y - 22.0, 92.0, 22.0), body)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 30.0, y - 22.0), Vector2(x - 22.0, y - 40.0),
		Vector2(x + 22.0, y - 40.0), Vector2(x + 30.0, y - 22.0),
	]), roof)
	draw_rect(Rect2(x - 20.0, y - 37.0, 18.0, 14.0), Color(0.35, 0.42, 0.45))
	draw_rect(Rect2(x + 3.0, y - 37.0, 18.0, 14.0), Color(0.35, 0.42, 0.45))
	draw_rect(Rect2(x - 46.0, y - 8.0, 92.0, 5.0), body.darkened(0.30))
	draw_circle(Vector2(x - 28.0, y + 2.0), 9.0, roof)
	draw_circle(Vector2(x + 28.0, y + 2.0), 9.0, roof)
	draw_rect(Rect2(x - 8.0, y - 46.0, 16.0, 7.0), body.lightened(0.14))


func _draw_chai(x: float) -> void:
	var steel: Color = Color(0.639, 0.647, 0.647)
	var glass: Color = Color(0.769, 0.639, 0.443)
	if not GameState.is_morning():
		steel = steel.darkened(0.40)
		glass = glass.darkened(0.36)
	var y: float = CA.PAVE_TOP + 40.0
	draw_rect(Rect2(x - 20.0, y - 10.0, 40.0, 10.0), steel)
	draw_rect(Rect2(x - 20.0, y - 12.0, 40.0, 3.0), steel.lightened(0.18))
	for i in range(6):
		draw_rect(Rect2(x - 17.0 + float(i) * 6.0, y - 20.0, 4.0, 9.0), glass)
	draw_rect(Rect2(x - 16.0, y - 34.0, 32.0, 14.0), steel.darkened(0.16))
	draw_rect(Rect2(x + 14.0, y - 30.0, 7.0, 4.0), steel.darkened(0.24))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(328.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(450.0, CA.PAVE_TOP + 20.0, 40.0, 22.0))       # chai rack
	if district == "bhuleshwar" or district == "chorbazaar":
		out.append(Rect2(560.0, CA.PAVE_TOP + 12.0, 128.0, 30.0))  # stall
	if district == "chorbazaar":
		for i in range(7):
			out.append(Rect2(48.0 + float(i) * 160.0, CA.PAVE_TOP + 26.0, 84.0, 16.0))
	if district == "bandra":
		out.append(Rect2(354.0, CA.PAVE_TOP + 22.0, 52.0, 20.0))   # cross
		out.append(Rect2(686.0, CA.FAR_TOP + 2.0, 28.0, 22.0))     # tree
	for p in [70.0, 340.0, 610.0, 880.0, 1130.0]:
		out.append(Rect2(float(p) - 5.0, CA.PAVE_TOP + 14.0, 10.0, 28.0))
	return out


# The towers, where this city actually has them.
# Nariman Point across the bay: the towers are on the other side of the
	# water from the hawkers, which is the whole view from the Causeway.
func _draw_far_towers() -> void:
	if district != "colaba":
		return
	CA.skyline(self, 214.0, Color(0.271, 0.286, 0.337), Color(0.153, 0.184, 0.235),
		9, 17, not GameState.is_morning())


# ── The Gateway of India ─────────────────────────────────────────────────────
# Basalt, 1924, on the water at the end of the Causeway. Built to welcome a
# king who had already come and gone by the time it was finished, and the most
# famous thing that ever happened at it was the last British regiment marching
# out through it in the other direction, in 1948.
#
# Indo-Saracenic: a Gujarati arch on a Roman triumphal plan, with four turrets
# and the honeycomb stone screens they call jali.
func _draw_gateway(cx: float) -> void:
	# Yellow basalt, quarried on the island it stands on.
	var stone: Color = Color(0.694, 0.612, 0.471)
	if not GameState.is_morning():
		stone = stone.darkened(0.38)
	var dark: Color = Color(0.129, 0.110, 0.098)
	var base: float = 268.0
	# Low enough that the dome and the four turrets are inside the frame.
	# At the first sizing they were forty pixels above the top of it.
	var top: float = 118.0
	var half: float = 124.0

	draw_rect(Rect2(cx - half, top, half * 2.0, base - top), stone)
	draw_rect(Rect2(cx - half, top, 26.0, base - top), stone.lightened(0.10))
	# The great arch through the middle, pointed the Gujarati way.
	var aw: float = 56.0
	var ay: float = base - 148.0
	draw_rect(Rect2(cx - aw, ay, aw * 2.0, base - ay), dark)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - aw, ay), Vector2(cx, ay - 62.0), Vector2(cx + aw, ay),
	]), dark)
	# The band of jali screen either side of it.
	for s in [-1.0, 1.0]:
		for r in range(4):
			for c in range(3):
				draw_rect(Rect2(cx + s * (76.0 + float(c) * 17.0) - 6.0,
					base - 126.0 + float(r) * 22.0, 11.0, 15.0),
					dark.lightened(0.06))
	# The cornice, and the four turrets over the corners.
	draw_rect(Rect2(cx - half - 10.0, top - 12.0, (half + 10.0) * 2.0, 14.0),
		stone.lightened(0.14))
	for s2 in [-1.0, 1.0]:
		for inner in [0.46, 1.0]:
			var tx: float = cx + s2 * half * float(inner)
			draw_rect(Rect2(tx - 16.0, top - 46.0, 32.0, 36.0), stone)
			draw_rect(Rect2(tx - 19.0, top - 52.0, 38.0, 8.0),
				stone.lightened(0.16))
			# A small ribbed dome on each.
			draw_circle(Vector2(tx, top - 52.0), 17.0, stone.lightened(0.06))
			draw_rect(Rect2(tx - 17.0, top - 52.0, 34.0, 10.0),
				stone.lightened(0.06))
			draw_rect(Rect2(tx - 2.0, top - 80.0, 4.0, 14.0), stone)
	# The central dome, twenty-six metres up, on its drum.
	draw_rect(Rect2(cx - 46.0, top - 30.0, 92.0, 22.0), stone.lightened(0.08))
	draw_circle(Vector2(cx, top - 30.0), 46.0, stone.lightened(0.12))
	draw_rect(Rect2(cx - 46.0, top - 30.0, 92.0, 14.0), stone.lightened(0.12))
	for r2 in range(7):
		var a: float = PI + PI * float(r2) / 6.0
		draw_line(Vector2(cx, top - 30.0),
			Vector2(cx + cos(a) * 46.0, top - 30.0 + sin(a) * 46.0),
			stone.darkened(0.10), 1.6)
	draw_rect(Rect2(cx - 3.0, top - 92.0, 6.0, 18.0), stone)


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	return [
		[Vector2(690.0, CA.PAVE_TOP + 6.0), 0, 1],
	]
