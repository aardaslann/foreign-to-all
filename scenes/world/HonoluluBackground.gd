extends Node2D

# Honolulu. Five districts on an island in the middle of the largest ocean on
# the planet, which is the fact the whole city is arranged around: everything
# here arrived by sea or by air, including almost everybody.
#
# WAIKIKI is the arrival. Three kilometres of hotel towers standing directly
# on a narrow strip of sand, with LĒʻAHI - Diamond Head - closing the east end
# of it. The crater is a tuff cone, 232 metres, and it is the shape the whole
# island is advertised with. Banyans on the strand, catamarans pulled up on
# the beach, surfboards stacked in racks by the hundred.
#
# CHINATOWN is the oldest in the United States and looks its age: two and
# three storey brick and stucco with recessed lānai balconies, painted signs
# fading through to older painted signs underneath, and lei stands where the
# whole front of the shop is open to the street.
#
# KAKAʻAKO was warehouses and is now the murals - whole gable ends painted
# floor to roof - with new glass towers going up in the gaps between them, so
# the district is corrugated iron and curtain wall on the same block.
#
# MĀNOA is the valley behind the city. It rains there most afternoons and
# then stops, and the houses are single-wall plantation timber with tin roofs
# under a great deal of green.
#
# THE NORTH SHORE is a low wooden town with false-front storefronts, food
# trucks, and in winter the largest rideable waves in the world an hour up
# the road.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "waikiki"
# "waikiki" | "chinatown" | "kakaako" | "manoa" | "northshore"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# The strongest daylight on the board. Volcanic earth is red-brown, the water
# is genuinely that colour, and the greens are wet greens.
const C_SKY_ZEN  := Color(0.055, 0.075, 0.157)
const C_SKY_MID  := Color(0.098, 0.129, 0.216)
const C_SKY_LOW  := Color(0.239, 0.184, 0.220)
const C_SKY_HAZE := Color(0.408, 0.259, 0.216)

const C_DAY_HI   := Color(0.286, 0.529, 0.780)
const C_DAY_MID  := Color(0.549, 0.729, 0.878)
const C_DAY_LOW  := Color(0.851, 0.882, 0.882)

const C_TUFF     := Color(0.451, 0.396, 0.322)    # the crater, dry side
const C_TUFF_G   := Color(0.322, 0.376, 0.286)    # and the green on it
const C_SEA      := Color(0.114, 0.427, 0.478)
const C_SEA_LIT  := Color(0.204, 0.588, 0.596)
const C_SAND     := Color(0.878, 0.812, 0.686)
const C_CONC     := Color(0.847, 0.831, 0.796)    # hotel towers
const C_CONC_D   := Color(0.706, 0.686, 0.647)
const C_STUCCO   := Color(0.784, 0.706, 0.588)    # Chinatown
const C_BRICK    := Color(0.588, 0.373, 0.310)
const C_TIN      := Color(0.545, 0.549, 0.541)
const C_TIMBER   := Color(0.639, 0.518, 0.404)
const C_LEAF     := Color(0.180, 0.353, 0.243)
const C_LEAF_HI  := Color(0.278, 0.475, 0.302)
const C_GLASS    := Color(0.157, 0.212, 0.239)
const C_WARM     := Color(1.0, 0.859, 0.588)
const C_INK      := Color(0.110, 0.106, 0.102)
const C_RED      := Color(0.729, 0.235, 0.196)
const C_TOWER_G  := Color(0.267, 0.341, 0.376)

const GROUND_Y := 238.0


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
			C_CONC, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"chinatown":  _draw_chinatown()
		"kakaako":    _draw_kakaako()
		"manoa":      _draw_manoa()
		"northshore": _draw_northshore()
		_:            _draw_waikiki()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_STUCCO.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 15)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.26, 0.32, 0.34), 0.04)
	CA.vignette(self, 0.24)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Waikīkī ──────────────────────────────────────────────────────────────────

func _draw_waikiki() -> void:
	# Ocean along the whole back, and the crater closing the east end of it.
	draw_rect(Rect2(0.0, 172.0, CA.VW, CA.PAVE_TOP - 172.0), C_SEA)
	for i in range(16):
		var wy: float = 178.0 + float(i) * 7.2
		draw_line(Vector2(0.0, wy), Vector2(CA.VW, wy),
			C_SEA_LIT.darkened(0.24 - 0.02 * float(i % 3)), 1.0)
	for b in range(3):
		var by: float = 246.0 + float(b) * 6.0
		draw_line(Vector2(0.0, by), Vector2(CA.VW, by),
			Color(0.94, 0.96, 0.95, 0.26 + 0.14 * sin(_t * 0.8 + float(b))), 2.6)
	_draw_diamond_head(1010.0)
	# The hotel wall: towers standing directly on the sand, in a row, with the
	# beach in front of them and nothing behind.
	var x: float = -40.0
	var i2: int = 0
	while x < 900.0:
		var w: float = 108.0 + float((i2 * 19) % 3) * 26.0
		var top: float = 44.0 + float((i2 * 31) % 4) * 22.0
		CA.block(self, x, w, top, GROUND_Y, C_CONC, C_CONC_D)
		# Continuous lānai balconies, which is what a Waikīkī tower is.
		var floors: int = int((GROUND_Y - top) / 16.0)
		for f in range(floors):
			var fy: float = top + 10.0 + float(f) * 16.0
			if fy > GROUND_Y - 20.0:
				break
			draw_rect(Rect2(x + 3.0, fy, w - 6.0, 9.0), C_GLASS.lightened(0.06))
			draw_rect(Rect2(x + 3.0, fy + 9.0, w - 6.0, 3.0), C_CONC_D)
		x += w + 8.0
		i2 += 1
	draw_rect(Rect2(0.0, 252.0, 920.0, CA.PAVE_TOP - 252.0), C_SAND)
	_draw_banyan(430.0)
	# Surfboards in a rack, stood on end, which is the other Waikīkī object.
	for s in range(9):
		var bx: float = 560.0 + float(s) * 15.0
		draw_rect(Rect2(bx, 232.0, 10.0, 58.0),
			[C_RED, C_WARM, C_SEA_LIT, C_CONC][s % 4].darkened(0.10))
		draw_rect(Rect2(bx, 232.0, 10.0, 6.0), C_CONC.lightened(0.1))


# Lēʻahi. A tuff cone with one shoulder higher than the other and a notch in
# the seaward side, and it is the shape this island is sold with.
func _draw_diamond_head(cx: float) -> void:
	var base: float = 262.0
	var pts := PackedVector2Array([
		Vector2(cx - 340.0, base), Vector2(cx - 250.0, base - 42.0),
		Vector2(cx - 150.0, base - 112.0), Vector2(cx - 60.0, base - 150.0),
		Vector2(cx + 10.0, base - 134.0), Vector2(cx + 46.0, base - 156.0),
		Vector2(cx + 130.0, base - 122.0), Vector2(cx + 240.0, base - 52.0),
		Vector2(cx + 330.0, base),
	])
	draw_colored_polygon(pts, C_TUFF)
	# The wet side is green and the seaward side is not; the line between them
	# runs down the ridge and is the most recognisable thing about it.
	var green := PackedVector2Array([
		Vector2(cx - 340.0, base), Vector2(cx - 250.0, base - 42.0),
		Vector2(cx - 150.0, base - 112.0), Vector2(cx - 96.0, base - 74.0),
		Vector2(cx - 180.0, base - 20.0), Vector2(cx - 250.0, base),
	])
	draw_colored_polygon(green, C_TUFF_G)
	for i in range(9):
		var gx: float = cx - 300.0 + float(i) * 26.0
		draw_line(Vector2(gx, base), Vector2(gx + 14.0, base - 30.0 - float(i) * 5.0),
			C_TUFF.darkened(0.14), 1.4)
	if not GameState.is_morning():
		draw_circle(Vector2(cx + 46.0, base - 160.0), 2.5,
			Color(1.0, 0.86, 0.62, 0.6 + 0.4 * sin(_t * 1.7)))


func _draw_banyan(x: float) -> void:
	draw_rect(Rect2(x - 15.0, 196.0, 30.0, 96.0), C_TIMBER.darkened(0.30))
	# Aerial roots down from the limbs, which is the whole point of a banyan.
	for i in range(7):
		var rx: float = x - 66.0 + float(i) * 22.0
		draw_rect(Rect2(rx, 208.0 + float(i % 3) * 8.0, 4.0,
			84.0 - float(i % 3) * 8.0), C_TIMBER.darkened(0.36))
	for c in range(9):
		draw_circle(Vector2(x - 78.0 + float(c) * 20.0,
			186.0 - float((c * 7) % 3) * 14.0), 36.0, C_LEAF)
	for c in range(6):
		draw_circle(Vector2(x - 56.0 + float(c) * 24.0, 170.0), 26.0, C_LEAF_HI)


func _draw_chinatown() -> void:
	CA.far_mass(self, 196.0, C_STUCCO.darkened(0.44), C_STUCCO.darkened(0.28),
		9, 23)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 96.0 + float((i * 17) % 3) * 20.0
		var top: float = 150.0 + float((i * 23) % 3) * 12.0
		var body: Color = C_STUCCO if i % 3 else C_BRICK
		CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
		# A parapet with the building's date on it, and a recessed lanai
		# balcony on the upper floor set back behind two posts.
		CA.band(self, x - 3.0, w + 6.0, top - 12.0, 12.0, body.lightened(0.16))
		draw_rect(Rect2(x + 10.0, top + 16.0, w - 20.0, 40.0), body.darkened(0.34))
		draw_rect(Rect2(x + 10.0, top + 52.0, w - 20.0, 5.0), C_TIMBER)
		draw_rect(Rect2(x + 14.0, top + 16.0, 5.0, 40.0), C_TIMBER)
		draw_rect(Rect2(x + w - 19.0, top + 16.0, 5.0, 40.0), C_TIMBER)
		CA.window_row(self, x + 22.0, w - 44.0, top + 24.0, 2, 14.0, 22.0,
			C_GLASS, body.darkened(0.30), (i * 13) % 7)
		# The old painted sign, showing through the new one.
		if i % 2 == 0:
			draw_rect(Rect2(x + 12.0, top + 66.0, w - 24.0, 22.0),
				Color(C_RED.r, C_RED.g, C_RED.b, 0.30))
			for k in range(3):
				draw_rect(Rect2(x + 22.0 + float(k) * 22.0, top + 70.0, 13.0, 14.0),
					Color(0.92, 0.88, 0.80, 0.40))
		x += w + 3.0
		i += 1
	# A lei stand: the whole front open to the street, and the stock hanging.
	draw_rect(Rect2(392.0, 208.0, 176.0, 12.0), C_TIMBER.darkened(0.2))
	for l in range(10):
		var lx: float = 404.0 + float(l) * 17.0
		draw_rect(Rect2(lx, 220.0, 2.0, 26.0), C_TIMBER.darkened(0.4))
		for k in range(5):
			draw_circle(Vector2(lx + 1.0, 246.0 + float(k) * 7.0), 5.0,
				[C_RED, C_WARM, Color(0.902, 0.549, 0.706),
					C_LEAF_HI][(l + k) % 4])


func _draw_kakaako() -> void:
	CA.far_mass(self, 168.0, C_TOWER_G.darkened(0.40), C_TOWER_G.darkened(0.22),
		8, 47)
	# Glass going up in the gaps between corrugated sheds. Both are true at
	# once and the join is the district.
	for i in range(3):
		var tx: float = 130.0 + float(i) * 400.0
		var th: float = 22.0 + float((i * 29) % 3) * 26.0
		CA.block(self, tx, 118.0, th, GROUND_Y - 30.0, C_TOWER_G,
			C_TOWER_G.darkened(0.22))
		var bands: int = int((GROUND_Y - 30.0 - th) / 13.0)
		for b in range(bands):
			draw_rect(Rect2(tx + 5.0, th + 7.0 + float(b) * 13.0, 108.0, 8.0),
				C_GLASS.lightened(0.08))
	var x: float = -20.0
	var i2: int = 0
	while x < CA.VW + 20.0:
		var w: float = 128.0 + float((i2 * 19) % 3) * 26.0
		var top: float = 176.0
		CA.block(self, x, w, top, GROUND_Y, C_TIN, C_TIN.darkened(0.20))
		for c in range(int(w / 9.0)):
			draw_rect(Rect2(x + float(c) * 9.0, top, 4.0, GROUND_Y - top),
				C_TIN.darkened(0.10))
		# The mural: the entire gable end, floor to roof.
		var hue: Color = [C_RED, C_SEA_LIT, C_WARM, Color(0.541, 0.302, 0.635)][i2 % 4]
		draw_rect(Rect2(x + 8.0, top + 10.0, w - 16.0, GROUND_Y - top - 20.0),
			Color(hue.r, hue.g, hue.b, 0.78))
		for k in range(5):
			draw_circle(Vector2(x + 26.0 + float(k) * 24.0,
				top + 34.0 + float((k * 11) % 3) * 16.0), 13.0,
				Color(0.96, 0.93, 0.86, 0.55))
		x += w + 4.0
		i2 += 1


func _draw_manoa() -> void:
	# The valley wall behind, and it is raining, and it will stop.
	draw_rect(Rect2(0.0, 96.0, CA.VW, CA.PAVE_TOP - 96.0), C_LEAF.darkened(0.34))
	for i in range(26):
		draw_circle(Vector2(fmod(float(i) * 137.0, CA.VW),
			120.0 + float((i * 53) % 120)), 44.0, C_LEAF.darkened(0.20))
	for i in range(18):
		draw_circle(Vector2(fmod(float(i) * 211.0 + 40.0, CA.VW),
			150.0 + float((i * 71) % 90)), 34.0, C_LEAF_HI.darkened(0.28))
	# Plantation houses: single-wall timber, tin roof, up on posts.
	var x: float = -20.0
	var i2: int = 0
	while x < CA.VW + 20.0:
		var w: float = 116.0 + float((i2 * 13) % 3) * 18.0
		var top: float = 194.0 + float((i2 * 7) % 2) * 10.0
		CA.block(self, x, w, top + 16.0, GROUND_Y - 18.0, C_TIMBER,
			C_TIMBER.darkened(0.20))
		for c in range(int((GROUND_Y - 18.0 - top - 16.0) / 8.0)):
			CA.band(self, x, w, top + 20.0 + float(c) * 8.0, 1.5,
				C_TIMBER.darkened(0.28))
		CA.roof(self, x, w, top + 16.0, 20.0, C_TIN)
		CA.window_row(self, x + 12.0, w - 24.0, top + 30.0, 2, 18.0, 22.0,
			C_GLASS, C_TIMBER.lightened(0.20), (i2 * 11) % 7)
		for pcol in range(4):
			draw_rect(Rect2(x + 12.0 + float(pcol) * (w / 4.0), GROUND_Y - 18.0,
				7.0, 18.0), C_TIMBER.darkened(0.34))
		x += w + 5.0
		i2 += 1
	# Rain, and the light behind it.
	for i in range(120):
		var rx: float = fmod(float(i) * 79.0 + _t * 40.0, CA.VW)
		var ry: float = fmod(float(i) * 131.0 + _t * 460.0, CA.PAVE_TOP)
		draw_line(Vector2(rx, ry), Vector2(rx - 2.0, ry + 14.0),
			Color(0.78, 0.86, 0.90, 0.16), 1.0)


func _draw_northshore() -> void:
	draw_rect(Rect2(0.0, 186.0, CA.VW, 52.0), C_SEA.lightened(0.05))
	for i in range(7):
		draw_line(Vector2(0.0, 192.0 + float(i) * 7.0),
			Vector2(CA.VW, 192.0 + float(i) * 7.0),
			C_SEA_LIT.darkened(0.22), 1.0)
	# One wave, standing up, because in winter this is what the road is for.
	var wx: float = 300.0 + 60.0 * sin(_t * 0.4)
	var wave := PackedVector2Array()
	for st in range(20):
		var f: float = float(st) / 19.0
		wave.append(Vector2(wx - 180.0 + 360.0 * f,
			238.0 - 46.0 * sin(f * PI) * (0.5 + 0.5 * sin(_t * 0.4))))
	wave.append(Vector2(wx + 180.0, 242.0))
	wave.append(Vector2(wx - 180.0, 242.0))
	draw_colored_polygon(wave, C_SEA_LIT)
	draw_rect(Rect2(0.0, 240.0, CA.VW, CA.PAVE_TOP - 240.0), C_SAND.darkened(0.06))
	# False-front timber storefronts, one storey pretending to be two.
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 104.0 + float((i * 11) % 3) * 22.0
		var top: float = 178.0
		CA.block(self, x, w, top + 22.0, GROUND_Y, C_TIMBER.lightened(0.10),
			C_TIMBER.darkened(0.12))
		draw_rect(Rect2(x - 3.0, top, w + 6.0, 26.0),
			[C_RED, C_SEA_LIT, C_WARM][i % 3].darkened(0.18))
		draw_rect(Rect2(x - 3.0, top, w + 6.0, 5.0), C_TIMBER.lightened(0.24))
		for k in range(4):
			draw_rect(Rect2(x + 14.0 + float(k) * 22.0, top + 8.0, 12.0, 12.0),
				Color(0.95, 0.92, 0.85, 0.75))
		draw_rect(Rect2(x - 8.0, GROUND_Y - 56.0, w + 16.0, 7.0),
			C_TIN.darkened(0.12))
		draw_rect(Rect2(x + 4.0, GROUND_Y - 56.0, 4.0, 56.0), C_TIMBER.darkened(0.3))
		draw_rect(Rect2(x + w - 8.0, GROUND_Y - 56.0, 4.0, 56.0),
			C_TIMBER.darkened(0.3))
		x += w + 6.0
		i += 1


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.451, 0.435, 0.408)
	var road: Color = Color(0.188, 0.188, 0.196)
	if district == "waikiki" or district == "northshore":
		pave = C_SAND.darkened(0.22)
	elif district == "manoa":
		pave = Color(0.404, 0.400, 0.353)
	CA.ground(self, pave, road, pave.darkened(0.12))
	CA.slabs(self, CA.PAVE_TOP, 80.0, 56.0, 40.0, pave.lightened(0.11))
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.20))
	CA.kerb(self, CA.FAR_TOP, pave.lightened(0.20))
	CA.slabs(self, CA.FAR_TOP, 132.0, 56.0, 40.0, pave.lightened(0.08))
	if district == "manoa" or not GameState.is_morning():
		# It rained an hour ago and the road has not finished with it.
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.34, 0.40, 0.44, 0.16), _t)


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	match district:
		"chinatown":
			for i in range(4):
				CA.lamp(self, 120.0 + float(i) * 278.0, CA.PAVE_TOP + 62.0,
					86.0, Color(0.239, 0.235, 0.227), C_WARM, on)
			CA.crates(self, 760.0, CA.PAVE_TOP + 58.0, 3, 2, C_TIMBER)
		"kakaako":
			for i in range(4):
				CA.lamp(self, 96.0 + float(i) * 292.0, CA.PAVE_TOP + 62.0,
					92.0, Color(0.271, 0.278, 0.286), C_WARM, on)
			CA.bin(self, 640.0, CA.PAVE_TOP + 64.0, C_TIN.darkened(0.2))
		"manoa":
			for i in range(6):
				_draw_palm(70.0 + float(i) * 202.0, CA.PAVE_TOP + 6.0, 1.0)
		"northshore":
			for i in range(4):
				_draw_palm(120.0 + float(i) * 280.0, CA.PAVE_TOP + 6.0, 1.15)
			CA.stall(self, 640.0, CA.PAVE_TOP + 58.0, 128.0, C_SEA_LIT,
				[C_RED, C_WARM, Color(0.541, 0.302, 0.635)])
		_:
			for px in [96.0, 340.0, 470.0, 700.0, 1010.0]:
				_draw_palm(float(px), CA.PAVE_TOP + 6.0, 1.0)
			for lx in [330.0, 640.0, 780.0, 980.0]:
				CA.lamp(self, float(lx), CA.PAVE_TOP + 64.0,
					88.0, Color(0.259, 0.251, 0.239), C_WARM, on)
	if on:
		CA.motes(self, 20, Color(0.92, 0.90, 0.80, 0.08), _t, 11.0, 22.0, 1.3)


# A coconut palm: a bare leaning trunk with the whole crown at the top, and
# the fronds are the only thing in this city that is always moving.
func _draw_palm(x: float, base: float, sc: float) -> void:
	var h: float = 118.0 * sc
	var lean: float = 12.0 * sc
	var trunk := PackedVector2Array([
		Vector2(x - 7.0 * sc, base), Vector2(x + 7.0 * sc, base),
		Vector2(x + lean + 4.0 * sc, base - h), Vector2(x + lean - 4.0 * sc, base - h),
	])
	draw_colored_polygon(trunk, C_TIMBER.darkened(0.26))
	for r in range(7):
		draw_rect(Rect2(x - 7.0 * sc + float(r), base - float(r) * h / 7.0 - 6.0,
			14.0 * sc - float(r) * 1.4, 2.0), C_TIMBER.darkened(0.40))
	var top := Vector2(x + lean, base - h)
	for f in range(8):
		var a: float = -PI * 0.94 + float(f) * PI * 0.135
		a += 0.06 * sin(_t * 1.1 + float(f))
		var tip := top + Vector2(cos(a), sin(a)) * (52.0 * sc)
		var mid := top + Vector2(cos(a), sin(a)) * (30.0 * sc) + Vector2(0.0, 6.0 * sc)
		draw_line(top, mid, C_LEAF_HI, 5.0 * sc)
		draw_line(mid, tip, C_LEAF, 4.0 * sc)


# ── Collision ────────────────────────────────────────────────────────────────

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	match district:
		"northshore":
			out.append(Rect2(640.0, 330.0, 128.0, 22.0))
		"chinatown":
			out.append(Rect2(760.0, 336.0, 74.0, 18.0))
		_:
			pass
	return out


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	if district != "chinatown":
		return []
	return [
		[Vector2(300.0, CA.PAVE_TOP + 64.0), 0, 1],
	]
