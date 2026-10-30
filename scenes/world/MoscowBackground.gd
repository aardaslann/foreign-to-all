extends Node2D

# Moscow. Four districts, and the light is the point.
#
# What makes a Moscow street look like Moscow is not the Kremlin. It is pastel
# neoclassical stucco - ochre, mint, dove - with WHITE pilasters, white window
# surrounds and a white cornice on top of it, and the fact that the white is
# always freshly painted and the pastel never quite is. Then a Soviet block
# dropped into the row with no attempt to match anything, and nobody minds.
#
# KITAY-GOROD is the old merchant quarter inside the walls: low, dense, and a
# church at the end of the street with domes on it.
# BASMANNY is the mix at its sharpest - eighteenth-century baroque with a
# nine-storey panel block against its flank.
# IZMAYLOVO is out past the ring: khrushchyovki in rows, birch between them,
# and the park behind.
# ZAMOSKVORECHYE is across the river, lower and quieter, with more churches per
# street than anywhere else in the city.
#
# Russia is on the itinerary for affect: the smile is personal, not social. So
# this plate is cold, extremely clean, and gives the alien nothing warm to read
# a face against. The one saturated colour anywhere is on a church.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "kitaygorod"
# "kitaygorod" | "basmanny" | "izmaylovo" | "zamoskvorechye" | "arbat"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.055, 0.058, 0.118)
const C_SKY_MID  := Color(0.082, 0.090, 0.153)
const C_SKY_LOW  := Color(0.133, 0.141, 0.184)
const C_SKY_HAZE := Color(0.196, 0.196, 0.212)

# Northern winter daylight: blue, low, and it never really gets bright.
const C_DAY_HI   := Color(0.408, 0.494, 0.612)
const C_DAY_MID  := Color(0.588, 0.639, 0.694)
const C_DAY_LOW  := Color(0.741, 0.757, 0.769)

const STUCCO := [
	Color(0.780, 0.788, 0.729),   # mint
	Color(0.788, 0.702, 0.549),   # ochre
	Color(0.749, 0.741, 0.749),   # dove
	Color(0.729, 0.647, 0.616),   # dusty rose
	Color(0.706, 0.741, 0.769),   # pale blue
]

const C_WHITE   := Color(0.933, 0.925, 0.902)   # every pilaster and surround
const C_PANEL   := Color(0.667, 0.659, 0.639)   # khrushchyovka concrete
const C_PANEL_D := Color(0.541, 0.537, 0.522)
const C_ROOF    := Color(0.325, 0.353, 0.376)
const C_GLASS   := Color(0.180, 0.204, 0.239)
const C_RED     := Color(0.639, 0.145, 0.145)   # the metro M, and nothing else
const C_DOME    := Color(0.804, 0.702, 0.294)   # gold leaf
const C_DOME_B  := Color(0.204, 0.353, 0.522)   # the blue ones, with stars
const C_BIRCH   := Color(0.867, 0.859, 0.827)
const C_SNOW    := Color(0.878, 0.898, 0.925)
const C_IRON    := Color(0.239, 0.243, 0.259)
const C_LAMP    := Color(0.98, 0.925, 0.816)

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
			C_RED, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_WHITE, Color(0.16, 0.16, 0.18), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	_draw_far_towers()
	match district:
		"basmanny":       _draw_basmanny()
		"izmaylovo":      _draw_izmaylovo()
		"zamoskvorechye": _draw_zamoskvorechye()
		"arbat":          _draw_arbat()
		_:                _draw_kitaygorod()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	# Saint Basil's stands at the end of Kitay-Gorod and you see the tops
	# of the domes over the roofs from most of the quarter.
	if district == "kitaygorod":
		_draw_basil(688.0)
	CA.ground_floor(self, GROUND_Y, C_PANEL.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 33)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	# Cold air, and snow in it. Nothing else on the itinerary is cold.
	CA.air(self, Color(0.42, 0.51, 0.68), 0.055)
	CA.motes(self, 34, Color(0.92, 0.94, 0.98, 0.34), _t, 26.0, 42.0, 2.0)
	CA.vignette(self, 0.28)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	# One of the Seven Sisters, a long way off. It is on the skyline from most
	# of the city and it is the only building here designed to be seen from
	# somewhere else.
	if district != "izmaylovo":
		_draw_sister(880.0)


func _draw_sister(x: float) -> void:
	var stone: Color = Color(0.404, 0.412, 0.443)
	if not GameState.is_morning():
		stone = stone.darkened(0.54)
	# Stepped setbacks, each narrower than the last, then a spire and a star.
	var w: float = 128.0
	var y: float = 214.0
	for i in range(5):
		draw_rect(Rect2(x - w * 0.5, y - 34.0, w, 36.0), stone)
		draw_rect(Rect2(x - w * 0.5, y - 34.0, w, 3.0), stone.lightened(0.16))
		for k in range(int(w / 14.0)):
			draw_rect(Rect2(x - w * 0.5 + 4.0 + float(k) * 14.0, y - 28.0, 5.0, 22.0),
				stone.darkened(0.22))
		y -= 34.0
		w *= 0.72
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 16.0, y), Vector2(x, y - 54.0), Vector2(x + 16.0, y),
	]), stone.lightened(0.10))
	var star: Color = C_DOME if GameState.is_morning() else C_DOME.darkened(0.30)
	draw_rect(Rect2(x - 4.0, y - 62.0, 8.0, 8.0), star)
	draw_rect(Rect2(x - 7.0, y - 59.0, 14.0, 2.5), star)


# ── The block ─────────────────────────────────────────────────────────────────
# Pastel stucco with white on every edge of it. The white is what makes the
# pastel read as architecture rather than as paint.

func _draw_stucco(x: float, w: float, storeys: int, ci: int, seed_i: int) -> void:
	var body: Color = STUCCO[ci % STUCCO.size()]
	var white: Color = C_WHITE
	if not GameState.is_morning():
		body = body.darkened(0.50)
		white = white.darkened(0.42)
	var floor_h: float = 40.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.16))
	# The cornice, heavy, and a string course at every floor.
	draw_rect(Rect2(x - 6.0, top - 10.0, w + 12.0, 11.0), white)
	draw_rect(Rect2(x - 8.0, top - 13.0, w + 16.0, 4.0), white.lightened(0.10))
	for s in range(1, storeys):
		draw_rect(Rect2(x, GROUND_Y - float(s) * floor_h, w, 4.0), white)
	# Pilasters: flat white strips running the full height, evenly.
	var bays: int = maxi(2, int(w / 48.0))
	var step: float = w / float(bays)
	for b in range(bays + 1):
		draw_rect(Rect2(x + float(b) * step - 4.0, top, 8.0, GROUND_Y - top), white)
		draw_rect(Rect2(x + float(b) * step - 4.0, top, 2.0, GROUND_Y - top),
			white.lightened(0.12))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 31 + s * 17) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 22.0, 26.0, C_GLASS,
			white.darkened(0.14), lit)
		# A moulded surround over every one, which is the whole style.
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			draw_rect(Rect2(bx - 16.0, wy - 8.0, 32.0, 5.0), white)
			draw_rect(Rect2(bx - 15.0, wy + 26.0, 30.0, 4.0), white)
	# Snow on the cornice and every sill. It is the cheapest possible way to
	# make a facade read as cold and it is completely convincing.
	draw_rect(Rect2(x - 8.0, top - 16.0, w + 16.0, 4.0), C_SNOW)


# A khrushchyovka. Five storeys, precast panels, no lift, and the panel joints
# are the only ornament it will ever have.
func _draw_panel_block(x: float, w: float, storeys: int, seed_i: int) -> void:
	var body: Color = C_PANEL
	var dark: Color = C_PANEL_D
	if not GameState.is_morning():
		body = body.darkened(0.50)
		dark = dark.darkened(0.50)
	var floor_h: float = 34.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, dark)
	# The panel grid. Every joint is visible and every one has run.
	for s in range(storeys + 1):
		draw_rect(Rect2(x, GROUND_Y - float(s) * floor_h, w, 2.4), dark)
	for c in range(int(w / 58.0) + 1):
		draw_rect(Rect2(x + float(c) * 58.0, top, 2.4, GROUND_Y - top), dark)
		draw_rect(Rect2(x + float(c) * 58.0, top, 2.4, GROUND_Y - top),
			Color(0.16, 0.15, 0.14, 0.18))
	for s in range(storeys):
		var wy: float = top + 10.0 + float(s) * floor_h
		var bays: int = maxi(2, int(w / 58.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 43 + s * 19) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 30.0, 20.0, C_GLASS,
			dark.darkened(0.20), lit)
		# The glazed-in balcony. Everybody did it, none of them match, and it
		# is the single most recognisable thing about a block like this.
		var step: float = w / float(bays)
		for b in range(bays):
			if ((seed_i + b * 3 + s * 5) % 3) != 0:
				continue
			var bx: float = x + step * (float(b) + 0.5)
			draw_rect(Rect2(bx - 17.0, wy + 20.0, 34.0, 13.0), body.lightened(0.06))
			draw_rect(Rect2(bx - 17.0, wy + 20.0, 34.0, 2.0), C_SNOW)
			for g in range(3):
				draw_rect(Rect2(bx - 14.0 + float(g) * 10.0, wy + 23.0, 7.0, 8.0),
					C_GLASS.lightened(0.10))
	draw_rect(Rect2(x - 4.0, top - 6.0, w + 8.0, 7.0), dark.lightened(0.10))
	draw_rect(Rect2(x - 4.0, top - 10.0, w + 8.0, 5.0), C_SNOW)


# A church. Domes, a drum under each, and a cross. It is the only saturated
# colour in the whole city and that is exactly how it reads on the street.
func _draw_church(x: float) -> void:
	var wall: Color = Color(0.902, 0.882, 0.847)
	var gold: Color = C_DOME
	var blue: Color = C_DOME_B
	if not GameState.is_morning():
		wall = wall.darkened(0.44)
		gold = gold.darkened(0.28)
		blue = blue.darkened(0.34)
	draw_rect(Rect2(x - 76.0, 148.0, 152.0, GROUND_Y - 148.0), wall)
	draw_rect(Rect2(x - 82.0, 142.0, 164.0, 9.0), wall.lightened(0.10))
	# Three domes: a big gold one, two small blue.
	_draw_dome(x, 106.0, 30.0, gold)
	_draw_dome(x - 52.0, 132.0, 18.0, blue)
	_draw_dome(x + 52.0, 132.0, 18.0, blue)
	for k in range(3):
		draw_rect(Rect2(x - 60.0 + float(k) * 60.0, 168.0, 26.0, 40.0),
			wall.darkened(0.14))
		for a in range(8):
			var u: float = float(a) / 7.0
			var dy: float = sin(u * PI) * 9.0
			draw_rect(Rect2(x - 60.0 + float(k) * 60.0 + u * 26.0 - 2.0,
				168.0 - dy, 5.0, dy + 3.0), wall.darkened(0.14))


func _draw_dome(x: float, y: float, r: float, col: Color) -> void:
	# The drum.
	draw_rect(Rect2(x - r * 0.6, y + r * 0.5, r * 1.2, 30.0), col.darkened(0.42))
	# The onion. Wider than the drum, and it comes to a point.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - r * 0.6, y + r * 0.6), Vector2(x - r, y),
		Vector2(x - r * 0.5, y - r * 0.7), Vector2(x, y - r * 1.1),
		Vector2(x + r * 0.5, y - r * 0.7), Vector2(x + r, y),
		Vector2(x + r * 0.6, y + r * 0.6),
	]), col)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - r * 0.5, y), Vector2(x - r * 0.2, y - r * 0.8),
		Vector2(x, y - r * 1.05), Vector2(x - r * 0.1, y + r * 0.4),
	]), col.lightened(0.22))
	draw_rect(Rect2(x - 1.5, y - r * 1.5, 3.0, r * 0.45), col.lightened(0.14))
	draw_rect(Rect2(x - 6.0, y - r * 1.36, 13.0, 2.6), col.lightened(0.14))


# ── The districts ─────────────────────────────────────────────────────────────

func _draw_kitaygorod() -> void:
	CA.far_mass(self, 178.0,
		Color(0.412, 0.424, 0.451) if GameState.is_morning()
		else Color(0.412, 0.424, 0.451).darkened(0.58),
		Color(0.88, 0.90, 0.94, 0.24), 30, 4)
	_draw_church(300.0)
	for spec in [[-16.0, 136.0, 4, 1], [412.0, 128.0, 4, 0], [540.0, 148.0, 5, 2],
			[688.0, 120.0, 4, 3], [808.0, 140.0, 5, 1], [948.0, 210.0, 4, 4]]:
		_draw_stucco(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 9)


func _draw_basmanny() -> void:
	CA.far_mass(self, 190.0,
		Color(0.388, 0.400, 0.427) if GameState.is_morning()
		else Color(0.388, 0.400, 0.427).darkened(0.58),
		Color(0.88, 0.90, 0.94, 0.22), 26, 6)
	# The mix, at its sharpest: two eighteenth-century houses, a nine-storey
	# slab hard against them, then two more houses. Nobody matched anything.
	_draw_stucco(-16.0, 132.0, 3, 1, 2)
	_draw_stucco(116.0, 118.0, 3, 3, 5)
	_draw_panel_block(234.0, 300.0, 8, 3)
	_draw_stucco(534.0, 126.0, 3, 0, 8)
	_draw_stucco(660.0, 140.0, 4, 2, 1)
	_draw_panel_block(800.0, 260.0, 7, 6)
	_draw_stucco(1060.0, 108.0, 3, 4, 4)


func _draw_izmaylovo() -> void:
	# Out past the ring. Rows of blocks, birch between them, park behind.
	CA.far_mass(self, 200.0,
		Color(0.255, 0.290, 0.271) if GameState.is_morning()
		else Color(0.255, 0.290, 0.271).darkened(0.56),
		Color(0.84, 0.88, 0.92, 0.16), 18, 8)
	for spec in [[-20.0, 268.0, 5], [268.0, 246.0, 5], [534.0, 280.0, 5],
			[834.0, 262.0, 5]]:
		_draw_panel_block(float(spec[0]), float(spec[1]), int(spec[2]),
			int(spec[0]) % 7)
	for bx in [252.0, 520.0, 818.0]:
		_draw_birch(float(bx))


func _draw_zamoskvorechye() -> void:
	CA.far_mass(self, 184.0,
		Color(0.400, 0.412, 0.435) if GameState.is_morning()
		else Color(0.400, 0.412, 0.435).darkened(0.58),
		Color(0.88, 0.90, 0.94, 0.22), 24, 2)
	_draw_church(760.0)
	for spec in [[-16.0, 128.0, 3, 3], [112.0, 116.0, 3, 0], [228.0, 134.0, 4, 2],
			[362.0, 120.0, 3, 4], [482.0, 142.0, 3, 1], [880.0, 132.0, 3, 0],
			[1012.0, 156.0, 4, 3]]:
		_draw_stucco(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 9)


# White trunk, black scars, and almost nothing on it. The only tree that reads
# as northern at this resolution.
func _draw_birch(x: float) -> void:
	var bark: Color = C_BIRCH
	var leaf: Color = Color(0.365, 0.435, 0.318)
	if not GameState.is_morning():
		bark = bark.darkened(0.44)
		leaf = leaf.darkened(0.56)
	var base: float = CA.PAVE_TOP + 30.0
	draw_rect(Rect2(x - 4.0, base - 118.0, 8.0, 118.0), bark)
	for i in range(9):
		draw_rect(Rect2(x - 4.0, base - 108.0 + float(i * 12), 8.0, 3.0),
			Color(0.20, 0.19, 0.18, 0.70))
	for i in range(4):
		var by: float = base - 96.0 - float(i) * 18.0
		draw_line(Vector2(x, by), Vector2(x + (14.0 if (i % 2) else -14.0),
			by - 16.0), bark.darkened(0.10), 2.0)
	draw_circle(Vector2(x, base - 132.0), 22.0, Color(leaf.r, leaf.g, leaf.b, 0.72))
	draw_rect(Rect2(x - 14.0, base - 3.0, 28.0, 4.0), Color(0, 0, 0, 0.20))


# ── Arbat ─────────────────────────────────────────────────────────────────────
# The pedestrian street. Painted merchant houses, no road at all, cast-iron
# lamps down the middle of it, and people selling portraits off easels in a
# temperature nobody should be standing still in.
#
# It is the one street in the city built for loitering, which makes it the one
# place the alien can stand and watch faces without being in the way.

func _draw_arbat() -> void:
	CA.far_mass(self, 186.0,
		Color(0.427, 0.435, 0.447) if GameState.is_morning()
		else Color(0.427, 0.435, 0.447).darkened(0.58),
		Color(0.88, 0.90, 0.94, 0.22), 22, 12)
	for spec in [[-16.0, 138.0, 3, 3], [122.0, 116.0, 4, 0], [238.0, 144.0, 3, 2],
			[382.0, 120.0, 4, 4], [502.0, 150.0, 3, 1], [652.0, 124.0, 4, 3],
			[776.0, 142.0, 3, 0], [918.0, 128.0, 4, 2], [1046.0, 132.0, 3, 4]]:
		_draw_stucco(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 9)
	# The easels, down the centre where a road would be.
	for i in range(5):
		_draw_easel(140.0 + float(i) * 210.0, i)


func _draw_easel(x: float, seed_i: int) -> void:
	var wood: Color = Color(0.478, 0.396, 0.310)
	var canvas: Color = Color(0.878, 0.859, 0.812)
	if not GameState.is_morning():
		wood = wood.darkened(0.44)
		canvas = canvas.darkened(0.44)
	var base: float = CA.ROAD_TOP + 46.0
	draw_rect(Rect2(x - 16.0, base - 8.0, 4.0, 8.0), wood)
	draw_rect(Rect2(x + 12.0, base - 8.0, 4.0, 8.0), wood)
	draw_rect(Rect2(x - 2.0, base - 62.0, 4.0, 56.0), wood)
	draw_rect(Rect2(x - 20.0, base - 62.0, 40.0, 4.0), wood)
	draw_rect(Rect2(x - 17.0, base - 100.0, 34.0, 40.0), canvas)
	draw_rect(Rect2(x - 17.0, base - 100.0, 34.0, 40.0), wood, false, 2.0)
	# A face on it, in two marks. It is a portrait pitch and that is all it
	# needs to be at this size.
	draw_circle(Vector2(x, base - 84.0), 8.0, canvas.darkened(0.16))
	draw_rect(Rect2(x - 10.0, base - 72.0, 20.0, 12.0), canvas.darkened(0.28))
	# Snow on the top edge, because nobody has moved it since it stopped.
	draw_rect(Rect2(x - 17.0, base - 103.0, 34.0, 3.0), C_SNOW)


# ── Ground ────────────────────────────────────────────────────────────────────
# Cleared, salted, and grey. The snow is at the edges because it has been
# pushed there, not because it fell there.

func _draw_ground() -> void:
	var pave: Color = Color(0.478, 0.486, 0.494)
	var road: Color = Color(0.271, 0.278, 0.294)
	if not GameState.is_morning():
		pave = pave.darkened(0.46)
		road = road.darkened(0.48)
	CA.ground(self, pave, road, pave.darkened(0.08))
	CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 56.0, 38.0,
		Color(0, 0, 0, 0.14))
	CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 56.0, 38.0,
		Color(0, 0, 0, 0.14))
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
	# Ploughed banks along both kerbs, greyed where the traffic has thrown salt
	# and grit at them. Clean white snow would be a lie about a working street.
	var snow: Color = C_SNOW if GameState.is_morning() else C_SNOW.darkened(0.42)
	for i in range(int(CA.VW / 40.0) + 1):
		var sx: float = float(i) * 40.0
		var h: float = 10.0 + float((i * 31) % 7)
		draw_rect(Rect2(sx, CA.ROAD_TOP - h - 6.0, 40.0, h), snow)
		draw_rect(Rect2(sx, CA.ROAD_TOP - h - 6.0, 40.0, 3.0), snow.lightened(0.10))
		draw_rect(Rect2(sx, CA.ROAD_TOP - 8.0, 40.0, 4.0),
			Color(0.38, 0.37, 0.36, 0.55))
		var h2: float = 9.0 + float((i * 47) % 6)
		draw_rect(Rect2(sx, CA.FAR_TOP - 2.0, 40.0, h2), snow)
	# Salt-white tide marks across the pavement.
	for i in range(9):
		draw_rect(Rect2(float(i) * 128.0, CA.PAVE_TOP + 30.0 + float((i * 19) % 40),
			84.0, 5.0), Color(0.86, 0.87, 0.89, 0.16))
	# Slush in the wheel tracks, which is the only wet thing in a frozen street.
	CA.sheen(self, CA.ROAD_TOP, CA.FAR_TOP - CA.ROAD_TOP,
		Color(0.58, 0.63, 0.72), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	# The metro M. Red, sans-serif, on a pole, and it is the one piece of
	# saturated colour at street level in the entire country.
	_draw_metro_m(240.0, lit)
	if district != "izmaylovo":
		_draw_metro_m(940.0, lit)
	for x in [120.0, 560.0, 1020.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 84.0, C_IRON, C_LAMP, lit)
	CA.bin(self, 420.0, CA.PAVE_TOP + 40.0, Color(0.271, 0.290, 0.286))
	# A kiosk. Glazed on three sides, lit from inside, selling everything.
	_draw_kiosk(680.0, lit)
	if district == "izmaylovo":
		_draw_bench_snow(400.0)
		_draw_bench_snow(880.0)


func _draw_metro_m(x: float, on: bool) -> void:
	var post: Color = C_IRON if GameState.is_morning() else C_IRON.darkened(0.30)
	var red: Color = C_RED if on else C_RED.darkened(0.34)
	var base: float = CA.PAVE_TOP + 42.0
	draw_rect(Rect2(x - 3.0, base - 92.0, 6.0, 92.0), post)
	draw_rect(Rect2(x - 26.0, base - 122.0, 52.0, 34.0), Color(0.94, 0.93, 0.91)
		if on else Color(0.60, 0.60, 0.60))
	draw_rect(Rect2(x - 26.0, base - 122.0, 52.0, 34.0), post, false, 2.0)
	# The letter, as three strokes. Nobody needs it spelled out.
	draw_rect(Rect2(x - 14.0, base - 116.0, 5.0, 22.0), red)
	draw_rect(Rect2(x + 9.0, base - 116.0, 5.0, 22.0), red)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 12.0, base - 116.0), Vector2(x, base - 100.0),
		Vector2(x + 12.0, base - 116.0), Vector2(x + 7.0, base - 116.0),
		Vector2(x, base - 108.0), Vector2(x - 7.0, base - 116.0),
	]), red)
	if not on:
		return
	for k in range(3):
		draw_circle(Vector2(x, base - 104.0), 34.0 + float(k) * 18.0,
			Color(1.0, 0.36, 0.32, 0.028 - float(k) * 0.006))


func _draw_kiosk(x: float, on: bool) -> void:
	var body: Color = Color(0.549, 0.561, 0.573)
	if not GameState.is_morning():
		body = body.darkened(0.44)
	var base: float = CA.PAVE_TOP + 40.0
	draw_rect(Rect2(x - 44.0, base - 74.0, 88.0, 74.0), body)
	draw_rect(Rect2(x - 48.0, base - 82.0, 96.0, 10.0), body.lightened(0.14))
	draw_rect(Rect2(x - 48.0, base - 86.0, 96.0, 5.0), C_SNOW)
	var glass: Color = Color(0.98, 0.92, 0.74, 0.86) if on \
		else Color(0.24, 0.27, 0.31)
	draw_rect(Rect2(x - 38.0, base - 66.0, 74.0, 40.0), glass)
	for i in range(4):
		draw_rect(Rect2(x - 38.0 + float(i) * 19.0, base - 66.0, 2.0, 40.0), body)
	# The hatch, which is the only way anybody talks to it.
	draw_rect(Rect2(x - 12.0, base - 28.0, 24.0, 12.0), Color(0.13, 0.13, 0.14))
	if not on:
		return
	for k in range(3):
		draw_circle(Vector2(x, base - 46.0), 44.0 + float(k) * 20.0,
			Color(1.0, 0.90, 0.70, 0.026 - float(k) * 0.005))


func _draw_bench_snow(x: float) -> void:
	var wood: Color = Color(0.435, 0.373, 0.310)
	if not GameState.is_morning():
		wood = wood.darkened(0.44)
	var y: float = CA.PAVE_TOP + 22.0
	draw_rect(Rect2(x - 46.0, y, 92.0, 7.0), wood)
	draw_rect(Rect2(x - 46.0, y - 4.0, 92.0, 4.0), C_SNOW)
	draw_rect(Rect2(x - 40.0, y + 7.0, 6.0, 18.0), wood.darkened(0.28))
	draw_rect(Rect2(x + 34.0, y + 7.0, 6.0, 18.0), wood.darkened(0.28))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(408.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(636.0, CA.PAVE_TOP - 34.0, 88.0, 40.0))       # kiosk
	out.append(Rect2(234.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))       # metro sign
	if district != "izmaylovo":
		out.append(Rect2(934.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))
	if district == "izmaylovo":
		out.append(Rect2(354.0, CA.PAVE_TOP + 18.0, 92.0, 24.0))   # bench
		out.append(Rect2(834.0, CA.PAVE_TOP + 18.0, 92.0, 24.0))   # bench
		for bx in [252.0, 520.0, 818.0]:
			out.append(Rect2(float(bx) - 6.0, CA.PAVE_TOP + 14.0, 12.0, 22.0))
	if district == "kitaygorod":
		out.append(Rect2(224.0, CA.PAVE_TOP - 30.0, 152.0, 34.0))  # church
	if district == "zamoskvorechye":
		out.append(Rect2(684.0, CA.PAVE_TOP - 30.0, 152.0, 34.0))  # church
	return out


# The towers, where this city actually has them.
# Moscow-City, a tight cluster of very tall glass a long way west, and
	# nothing between here and it above six storeys.
func _draw_far_towers() -> void:
	if district != "arbat":
		return
	CA.skyline(self, 204.0, Color(0.243, 0.267, 0.325), Color(0.145, 0.176, 0.231),
		6, 41, not GameState.is_morning())


# ── Saint Basil's ─────────────────────────────────────────────────────────────
# Ten churches on one foundation, and no two of the domes are alike: one is
# spiralled, one is faceted, one is ribbed, one is studded. They were not
# always coloured - for the first two hundred years the whole thing was white
# with gold tops, and the paint arrived in the 1680s.
#
# The nine chapels are arranged around the tenth, which is the tented tower in
# the middle, and the whole plan is a star. From a street in Kitay-Gorod you
# see the tops of them over the roofs.
const BASIL_DOMES := [
	[-118.0, 44.0, 26.0, 0], [-64.0, 12.0, 30.0, 1], [-4.0, -22.0, 34.0, 2],
	[58.0, 8.0, 29.0, 3], [116.0, 48.0, 25.0, 0],
]
const BASIL_HUES := [
	Color(0.208, 0.435, 0.286), Color(0.729, 0.259, 0.220),
	Color(0.392, 0.463, 0.702), Color(0.855, 0.686, 0.243),
]


func _draw_basil(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var wall := Color(0.816, 0.729, 0.639)
	var trim := Color(0.667, 0.325, 0.271)
	var gold := Color(0.898, 0.749, 0.310)
	if not morning:
		# Floodlit. Darkening it like a shopfront turned the most
		# recognisable roofline in Russia into a brown lump.
		wall = wall.darkened(0.20)
		trim = trim.darkened(0.12)
		gold = gold.darkened(0.06)
	var base: float = 262.0
	# Grown about its own footing, so every coordinate below still reads
	# as written. It was drawn at the height of the flats beside it.
	var s: float = 1.10
	draw_set_transform(Vector2(cx, base) * (1.0 - s), 0.0, Vector2(s, s))

	# The body: a mass of brick with the chapels stepping up to the middle.
	draw_rect(Rect2(cx - 160.0, 150.0, 320.0, base - 150.0), wall)
	draw_rect(Rect2(cx - 160.0, 150.0, 42.0, base - 150.0), wall.lightened(0.10))
	for k in range(5):
		draw_rect(Rect2(cx - 152.0 + float(k) * 62.0, 142.0, 46.0, 14.0), trim)

	# The tented centre, which is the tenth church and the tallest thing here.
	draw_rect(Rect2(cx - 34.0, 96.0, 68.0, 60.0), wall.lightened(0.06))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 40.0, 96.0), Vector2(cx + 40.0, 96.0), Vector2(cx, 22.0),
	]), trim.darkened(0.14))
	for r in range(5):
		var f: float = float(r + 1) / 6.0
		draw_line(Vector2(cx - 40.0 * (1.0 - f), 96.0 - 74.0 * f),
			Vector2(cx + 40.0 * (1.0 - f), 96.0 - 74.0 * f),
			trim.lightened(0.10), 1.4)

	# The domes. Every one on its own drum, and every one patterned differently
	# - which is the single thing that makes this building itself.
	for i in range(BASIL_DOMES.size()):
		var d: Array = BASIL_DOMES[i]
		var dx: float = cx + float(d[0])
		var dy: float = float(d[1])
		var r2: float = float(d[2])
		var hue: Color = BASIL_HUES[int(d[3])]
		if not morning:
			hue = hue.darkened(0.34)
		draw_rect(Rect2(dx - r2 * 0.62, dy + r2 * 0.4, r2 * 1.24, 58.0), wall)
		draw_rect(Rect2(dx - r2 * 0.72, dy + r2 * 0.34, r2 * 1.44, 9.0), trim)
		# The onion: wider than its drum and drawn back in at the bottom.
		var bulb := PackedVector2Array()
		for st in range(15):
			var a: float = PI + PI * float(st) / 14.0
			bulb.append(Vector2(dx + cos(a) * r2, dy + sin(a) * r2 * 0.96))
		bulb.append(Vector2(dx + r2 * 0.52, dy + r2 * 0.60))
		bulb.append(Vector2(dx - r2 * 0.52, dy + r2 * 0.60))
		draw_colored_polygon(bulb, hue)
		# The pattern on it: spiral, ribs or studs, by index.
		match int(d[3]):
			0:
				for k2 in range(5):
					draw_line(Vector2(dx - r2 + float(k2) * r2 * 0.4, dy + r2 * 0.5),
						Vector2(dx - r2 * 0.4 + float(k2) * r2 * 0.4, dy - r2 * 0.7),
						hue.lightened(0.28), 2.2)
			1:
				for k3 in range(5):
					var a2: float = PI + PI * (float(k3) + 0.5) / 5.0
					draw_line(Vector2(dx, dy - r2 * 0.9),
						Vector2(dx + cos(a2) * r2 * 0.92, dy + sin(a2) * r2 * 0.6),
						hue.darkened(0.26), 2.0)
			2:
				for k4 in range(7):
					draw_circle(Vector2(dx - r2 * 0.7 + float(k4) * r2 * 0.24,
						dy - r2 * 0.1), 2.6, hue.lightened(0.34))
			_:
				for k5 in range(4):
					draw_rect(Rect2(dx - r2 * 0.8 + float(k5) * r2 * 0.5,
						dy - r2 * 0.5, r2 * 0.22, r2 * 1.0), hue.darkened(0.22))
		# Cross on top, and the little gold ball under it.
		draw_circle(Vector2(dx, dy - r2 * 0.98), 4.0, gold)
		draw_rect(Rect2(dx - 1.5, dy - r2 - 22.0, 3.0, 22.0), gold)
		draw_rect(Rect2(dx - 7.0, dy - r2 - 16.0, 14.0, 3.0), gold)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
