extends Node2D

# Zürich. Two streets, and the joke is that they are four hundred metres apart.
#
# NIEDERDORF is the medieval lane on the east bank of the Limmat: setts underfoot,
# no cars, centuries-old facades leaning gently toward one another across a gap
# narrow enough to touch both sides. Guild houses with carved stone portals.
# Everything is five hundred years old and in perfect condition, which is the
# part a player arriving from Berlin actually notices — Kreuzberg's walls are a
# palimpsest nobody has ever cleaned, and these were washed this morning.
#
# LANGSTRASSE is the one street in the city that does not perform. Seventies
# concrete dropped between old blocks, kebab light, betting shops, a launderette.
# It is here so Zürich is not a postcard, and because the alien needs one place
# in this country where somebody might actually talk to it.
#
# Why Switzerland is on the itinerary at all: the German learned across the
# whole of Act I is a WRITTEN language here. Every sign in Niederdorf is legible
# — shop names, street plates, the menu in the window — and not one person in
# the lane is speaking it. So this plate is deliberately dense with readable
# signage. The legibility is the cruelty.
#
# Ground bands are Berlin's, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "niederdorf"
# "niederdorf" | "langstrasse" | "zurichwest" | "seefeld" | "oerlikon"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Swiss limewash: cream, oxblood, ochre, sage, dove. Saturation is low and the
# VALUES sit close together, which is what makes a row of coloured houses read
# as expensive rather than as a toy town.
const C_SKY_ZEN  := Color(0.062, 0.058, 0.130)
const C_SKY_MID  := Color(0.098, 0.090, 0.176)
const C_SKY_LOW  := Color(0.169, 0.141, 0.208)
const C_SKY_HAZE := Color(0.243, 0.184, 0.192)

const C_DAY_HI   := Color(0.502, 0.596, 0.686)   # alpine light: clean, cold, high
const C_DAY_MID  := Color(0.639, 0.702, 0.749)
const C_DAY_LOW  := Color(0.769, 0.780, 0.769)

const FACADES := [
	Color(0.851, 0.824, 0.769),   # cream
	Color(0.686, 0.573, 0.502),   # ochre
	Color(0.612, 0.451, 0.412),   # oxblood, faded
	Color(0.643, 0.671, 0.620),   # sage
	Color(0.780, 0.757, 0.722),   # dove
	Color(0.729, 0.639, 0.545),   # sand
]

const C_TIMBER   := Color(0.243, 0.180, 0.141)
const C_STONE    := Color(0.545, 0.529, 0.498)    # portals, quoins, sills
const C_ROOFTILE := Color(0.400, 0.318, 0.286)
const C_GLASS    := Color(0.184, 0.196, 0.239)
const C_SHUTTER  := Color(0.427, 0.290, 0.259)
const C_LAMP     := Color(1.0, 0.882, 0.671)
const C_SETT     := Color(0.055, 0.050, 0.086, 0.42)

# Langstrasse only
const C_CONC    := Color(0.494, 0.490, 0.478)
const C_CONC_DK := Color(0.361, 0.361, 0.353)
const C_NEON_R  := Color(0.902, 0.290, 0.361)
const C_NEON_G  := Color(0.322, 0.851, 0.639)

const GROUND_Y := 232.0     # shopfront head height in the lane


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


func _draw_doors(board: Color, ink: Color, accent: Color) -> void:
	for d in _doors:
		var x: float = float(d["x"])
		InteriorArt.frontage(self, x, GROUND_Y, CA.PAVE_TOP, String(d["kind"]),
			accent, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			board, ink, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	_draw_far_towers()
	match district:
		"langstrasse": _draw_langstrasse()
		"zurichwest":  _draw_zurichwest()
		"seefeld":     _draw_seefeld()
		"oerlikon":    _draw_oerlikon()
		_:             _draw_niederdorf()
	_draw_ground()
	_draw_doors(C_STONE.lightened(0.30), C_TIMBER, C_SHUTTER)
	_draw_furniture()
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.06))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Niederdorf ────────────────────────────────────────────────────────────────
# Eleven narrow houses, none the same width or height, and every one of them
# leaning. The lean is the character of the street, and it is done by giving
# each block its own top edge and letting the eaves nearly meet.

const HOUSES := [
	# x, width, storeys, colour index
	[-10.0, 128.0, 5, 0], [118.0, 96.0, 6, 2], [214.0, 112.0, 5, 4],
	[326.0, 88.0, 6, 1], [414.0, 134.0, 4, 3], [548.0, 104.0, 6, 5],
	[652.0, 118.0, 5, 0], [770.0, 92.0, 6, 2], [862.0, 126.0, 5, 1],
	[988.0, 108.0, 6, 4], [1096.0, 96.0, 5, 3],
]


# The opening in the lane the two towers stand in.
const TOWER_L := 700.0
const TOWER_R := 902.0


func _draw_niederdorf() -> void:
	# The Grossmünster, two flat-topped towers over the roofline. It is the one
	# silhouette in Switzerland everybody can draw from memory.
	_draw_grossmunster(742.0)
	for i in range(HOUSES.size()):
		var h: Array = HOUSES[i]
		# The lane opens for the church. Drawn first and then built over,
		# which is what was happening, it may as well not be there.
		if float(h[0]) + float(h[1]) > TOWER_L and float(h[0]) < TOWER_R:
			continue
		_draw_house(float(h[0]), float(h[1]), int(h[2]), int(h[3]), i)


func _draw_house(x: float, w: float, storeys: int, ci: int, seed_i: int) -> void:
	var body: Color = FACADES[ci]
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var floor_h: float = 30.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	# The lean: alternate houses tip toward each other by a couple of degrees,
	# which at this scale is four pixels of overhang and reads perfectly.
	var lean: float = 4.0 if (seed_i % 2) == 0 else -3.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + lean, top), Vector2(x + w + lean, top),
		Vector2(x + w, GROUND_Y), Vector2(x, GROUND_Y),
	]), body)
	draw_rect(Rect2(x + w - 9.0, top, 9.0, GROUND_Y - top), body.darkened(0.16))

	var tile: Color = C_ROOFTILE if GameState.is_morning() \
		else C_ROOFTILE.darkened(0.40)
	CA.roof(self, x + lean, w, top + 4.0, 20.0, tile)

	# Windows: small, deep, in strict vertical bays. Swiss facades stay rigidly
	# ordered even when the building itself is crooked.
	var bays: int = maxi(2, int(w / 34.0))
	for s in range(storeys - 1):
		var wy: float = top + 20.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 37 + s * 11) % (1 << bays)
		CA.window_row(self, x + lean * 0.5, w, wy, bays, 15.0, 19.0,
			C_GLASS, C_TIMBER, lit)
		# Shutters on the lower floors only — nobody has bothered up top.
		if s >= storeys - 3:
			var step: float = w / float(bays)
			var sh: Color = C_SHUTTER if GameState.is_morning() \
				else C_SHUTTER.darkened(0.35)
			for b in range(bays):
				CA.shutters(self, x + lean * 0.5 + step * (float(b) + 0.5) - 7.5,
					wy, 15.0, 19.0, sh)

	# The carved stone portal. One per guild house, and the only place stone
	# ever appears on a limewashed wall.
	if (seed_i % 3) == 0:
		var px: float = x + w * 0.5
		draw_rect(Rect2(px - 22.0, GROUND_Y - 6.0, 44.0, 6.0), C_STONE)
		draw_rect(Rect2(px - 26.0, GROUND_Y - 10.0, 52.0, 5.0),
			C_STONE.lightened(0.16))
		for k in range(4):
			draw_rect(Rect2(px - 18.0 + float(k) * 10.0, GROUND_Y - 5.0,
				3.0, 4.0), C_STONE.darkened(0.30))

	# A painted date or shop name straight onto the render. Perfectly legible,
	# and no help whatsoever.
	if (seed_i % 4) == 1:
		var ty: float = top + 12.0
		var ink: Color = C_TIMBER if GameState.is_morning() \
			else C_TIMBER.lightened(0.18)
		for k in range(5):
			draw_rect(Rect2(x + 12.0 + float(k) * 11.0, ty, 7.0, 9.0), ink)


func _draw_grossmunster(x: float) -> void:
	# Floodlit at night. At the value it used to carry the two towers were
	# darker than the sky behind them and read as a pair of chimneys.
	var stone: Color = Color(0.412, 0.376, 0.341)
	var lit: bool = not GameState.is_morning()
	if lit:
		stone = stone.darkened(0.24)
	var roof: Color = stone.darkened(0.34)
	var tw: float = 58.0
	var gap: float = 84.0
	var body_l: float = x - 26.0
	var body_r: float = x + gap + tw + 26.0

	# The nave between and behind them. Without it the towers stand on
	# nothing and the thing is not a church.
	draw_rect(Rect2(body_l, 150.0, body_r - body_l, 142.0), stone.darkened(0.12))
	draw_colored_polygon(PackedVector2Array([
		Vector2(body_l, 152.0), Vector2(body_r, 152.0),
		Vector2(body_r - 26.0, 122.0), Vector2(body_l + 26.0, 122.0),
	]), roof)
	# The round-headed Romanesque windows down the nave wall.
	for k in range(6):
		var wx: float = body_l + 24.0 + float(k) * ((body_r - body_l - 48.0) / 5.0)
		draw_rect(Rect2(wx - 8.0, 176.0, 16.0, 34.0), stone.darkened(0.44))
		draw_circle(Vector2(wx, 176.0), 8.0, stone.darkened(0.44))
		if lit:
			draw_rect(Rect2(wx - 6.0, 178.0, 12.0, 30.0),
				Color(1.0, 0.855, 0.573, 0.30))

	for side in [0.0, gap]:
		var tx: float = x + side
		draw_rect(Rect2(tx, 30.0, tw, 216.0), stone)
		draw_rect(Rect2(tx, 30.0, 11.0, 216.0), stone.lightened(0.14))
		draw_rect(Rect2(tx + tw - 8.0, 30.0, 8.0, 216.0), stone.darkened(0.14))
		# The string courses that divide the stages.
		for c in range(4):
			draw_rect(Rect2(tx - 3.0, 62.0 + float(c) * 44.0, tw + 6.0, 5.0),
				stone.lightened(0.10))
		# The octagonal neo-Gothic top: a drum, then the pointed helm, then
		# the finial. That outline is the whole silhouette of Zurich.
		draw_rect(Rect2(tx - 6.0, 22.0, tw + 12.0, 11.0), stone.lightened(0.18))
		draw_rect(Rect2(tx + 4.0, 2.0, tw - 8.0, 22.0), stone.darkened(0.08))
		draw_colored_polygon(PackedVector2Array([
			Vector2(tx + 1.0, 4.0), Vector2(tx + tw - 1.0, 4.0),
			Vector2(tx + tw * 0.5, -30.0),
		]), roof)
		draw_rect(Rect2(tx + tw * 0.5 - 1.5, -44.0, 3.0, 16.0), stone.lightened(0.24))
		# The clock face, the only lit thing up there at night.
		var face: Color = Color(0.90, 0.86, 0.74) if GameState.is_morning() \
			else Color(0.98, 0.92, 0.72)
		draw_circle(Vector2(tx + tw * 0.5, 88.0), 17.0, stone.darkened(0.30))
		draw_circle(Vector2(tx + tw * 0.5, 88.0), 14.0, face)
		draw_rect(Rect2(tx + tw * 0.5 - 1.5, 78.0, 3.0, 11.0), stone.darkened(0.50))
		draw_rect(Rect2(tx + tw * 0.5, 87.0, 9.0, 3.0), stone.darkened(0.50))
		# Louvred belfry openings.
		for k2 in range(2):
			draw_rect(Rect2(tx + 12.0, 126.0 + float(k2) * 48.0, tw - 24.0, 30.0),
				stone.darkened(0.42))
			draw_circle(Vector2(tx + tw * 0.5, 126.0 + float(k2) * 48.0,),
				(tw - 24.0) * 0.5, stone.darkened(0.42))

	if lit:
		for g in range(4):
			draw_rect(Rect2(body_l - 30.0 + float(g) * 14.0,
				250.0 - float(g) * 62.0, body_r - body_l + 60.0 - float(g) * 28.0,
				70.0), Color(1.0, 0.867, 0.612, 0.045))


# ── Langstrasse ───────────────────────────────────────────────────────────────
# The same city with its manners off. Two seventies slabs dropped into the row,
# a kebab window, a betting shop, a launderette running all night.

func _draw_langstrasse() -> void:
	var conc: Color = C_CONC if GameState.is_morning() else C_CONC.darkened(0.50)
	var conc_dk: Color = C_CONC_DK if GameState.is_morning() \
		else C_CONC_DK.darkened(0.50)
	CA.far_mass(self, 150.0, conc.darkened(0.28), conc.lightened(0.10), 26, 3)

	# Two old houses left standing, then the slab, then more. The step in
	# height between them is the whole story of the street.
	_draw_house(-10.0, 118.0, 5, 1, 0)
	_draw_house(108.0, 104.0, 5, 4, 1)
	_draw_slab(212.0, 340.0, conc, conc_dk)
	_draw_slab(552.0, 290.0, conc.darkened(0.06), conc_dk)
	_draw_house(842.0, 126.0, 5, 2, 2)
	_draw_house(968.0, 110.0, 6, 0, 3)
	_draw_house(1078.0, 96.0, 5, 3, 4)

	if not GameState.is_morning():
		_draw_neon(300.0, C_NEON_R)
		_draw_neon(620.0, C_NEON_G)
		_draw_neon(880.0, C_NEON_R.lightened(0.15))


func _draw_slab(x: float, w: float, body: Color, shade: Color) -> void:
	var top: float = 66.0
	CA.block(self, x, w, top, GROUND_Y, body, shade)
	# Floor bands and a continuous ribbon window. Nothing about it is local.
	for s in range(5):
		var y: float = top + 8.0 + float(s) * 32.0
		draw_rect(Rect2(x + 4.0, y + 20.0, w - 8.0, 5.0), shade)
		var bays: int = int((w - 16.0) / 30.0)
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 7 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x + 8.0, w - 16.0, y, bays, 21.0, 17.0,
			C_GLASS, shade.darkened(0.20), lit)
	draw_rect(Rect2(x - 3.0, top - 7.0, w + 6.0, 8.0), shade.lightened(0.10))


func _draw_neon(x: float, col: Color) -> void:
	var flick: float = 1.0
	if fmod(_t * 3.1 + x, 9.0) < 0.16:
		flick = 0.35
	var y: float = GROUND_Y - 96.0
	draw_rect(Rect2(x - 34.0, y, 68.0, 22.0),
		Color(col.r, col.g, col.b, 0.85 * flick))
	draw_rect(Rect2(x - 34.0, y, 68.0, 22.0), Color(0, 0, 0, 0.35))
	for k in range(5):
		draw_rect(Rect2(x - 27.0 + float(k) * 11.0, y + 5.0, 6.0, 12.0),
			Color(col.r, col.g, col.b, 0.95 * flick))
	for i in range(3):
		draw_rect(Rect2(x - 44.0 - float(i) * 7.0, y - float(i) * 5.0,
			88.0 + float(i) * 14.0, 32.0 + float(i) * 10.0),
			Color(col.r, col.g, col.b, 0.030 * flick))


# ── Zurich West ───────────────────────────────────────────────────────────────
# Kreis 5. Until the nineties this was shipbuilding and turbines, and the halls
# are still standing with galleries inside them. Above it the Hardbruecke
# viaduct; under the railway arches, shops.
#
# It is the only part of the city that admits it ever made anything.

func _draw_zurichwest() -> void:
	var brick: Color = Color(0.478, 0.365, 0.318)
	var steel: Color = Color(0.435, 0.447, 0.463)
	if not GameState.is_morning():
		brick = brick.darkened(0.50)
		steel = steel.darkened(0.50)
	CA.far_mass(self, 140.0, steel.darkened(0.34),
		Color(0.86, 0.88, 0.90, 0.24), 28, 5)
	draw_rect(Rect2(-20.0, 104.0, CA.VW + 40.0, 26.0), steel)
	draw_rect(Rect2(-20.0, 104.0, CA.VW + 40.0, 4.0), steel.lightened(0.18))
	for i in range(6):
		var ax: float = -30.0 + float(i) * 200.0
		draw_rect(Rect2(ax, 130.0, 176.0, GROUND_Y - 130.0), brick)
		for r in range(int((GROUND_Y - 130.0) / 7.0)):
			draw_rect(Rect2(ax, 130.0 + float(r) * 7.0, 176.0, 1.0),
				Color(0, 0, 0, 0.13))
		# The arched opening, glazed, with a shop behind it.
		var ox: float = ax + 26.0
		draw_rect(Rect2(ox, 180.0, 124.0, GROUND_Y - 180.0),
			Color(0.098, 0.094, 0.106))
		for k in range(11):
			var u: float = float(k) / 10.0
			var dy: float = sin(u * PI) * 22.0
			draw_rect(Rect2(ox + u * 124.0 - 6.0, 180.0 - dy, 13.0, dy + 4.0),
				Color(0.098, 0.094, 0.106))
		if not GameState.is_morning():
			draw_rect(Rect2(ox + 8.0, GROUND_Y - 52.0, 108.0, 52.0),
				Color(0.98, 0.88, 0.66, 0.62))
	_draw_hall(560.0, brick, steel)


# The turbine hall: a long shed with a saw-tooth roof. That north light is what
# every factory in Europe was built with and nothing else has it.
func _draw_hall(x: float, brick: Color, steel: Color) -> void:
	var w: float = 420.0
	draw_rect(Rect2(x - w * 0.5, 176.0, w, 46.0), brick.darkened(0.14))
	for i in range(7):
		var tx: float = x - w * 0.5 + float(i) * (w / 7.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(tx, 176.0), Vector2(tx, 150.0),
			Vector2(tx + w / 7.0, 176.0),
		]), steel.darkened(0.18))
		draw_rect(Rect2(tx + 2.0, 152.0, 5.0, 22.0),
			Color(0.68, 0.76, 0.80, 0.55))
	draw_rect(Rect2(x - w * 0.5 - 6.0, 172.0, w + 12.0, 6.0), steel)


# ── Seefeld ───────────────────────────────────────────────────────────────────
# Out along the lake. Wide, green, expensive, and the water at the end of every
# side street. The calmest plate in the country.

func _draw_seefeld() -> void:
	var lake: Color = Color(0.180, 0.322, 0.400)
	if not GameState.is_morning():
		lake = lake.darkened(0.52)
	draw_rect(Rect2(0, 186.0, CA.VW, 36.0), lake)
	for i in range(5):
		draw_rect(Rect2(0, 192.0 + float(i) * 6.0, CA.VW, 2.0),
			Color(0.78, 0.86, 0.90, 0.10 + 0.05 * sin(_t * 0.4 + float(i))))
	# The Alps, but only on a clear morning. At night there is nothing there.
	if GameState.is_morning():
		var snow := Color(0.851, 0.878, 0.902)
		var rock := Color(0.427, 0.475, 0.549)
		for peak in [[220.0, 128.0], [420.0, 112.0], [640.0, 134.0], [880.0, 120.0]]:
			var px: float = float(peak[0])
			var pt: float = float(peak[1])
			draw_colored_polygon(PackedVector2Array([
				Vector2(px - 120.0, 186.0), Vector2(px, pt),
				Vector2(px + 120.0, 186.0),
			]), rock)
			draw_colored_polygon(PackedVector2Array([
				Vector2(px - 30.0, pt + 30.0), Vector2(px, pt),
				Vector2(px + 30.0, pt + 30.0),
			]), snow)
	for spec in [[-16.0, 168.0, 3, 3], [200.0, 152.0, 3, 0], [396.0, 176.0, 3, 5],
			[620.0, 158.0, 3, 1], [830.0, 170.0, 3, 4], [1040.0, 140.0, 3, 2]]:
		_draw_house(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 6)
	for tx in [150.0, 520.0, 900.0]:
		CA.tree(self, float(tx), CA.PAVE_TOP - 6.0, 58.0,
			Color(0.259, 0.220, 0.180), Color(0.220, 0.376, 0.286), 1.2)


# ── Oerlikon ──────────────────────────────────────────────────────────────────
# North, past the tracks. Machine-tool works and a marshalling yard until the
# nineties, and now new housing built on the plots at exactly the density the
# planners wrote down, all of it finished within four years of each other.
#
# It is the only street in the country with no old buildings on it at all, and
# a player arriving from Niederdorf will find that far stranger than the
# medieval lane was. Everything here is correct and nothing is worn.

func _draw_oerlikon() -> void:
	var conc: Color = Color(0.729, 0.718, 0.694)
	var dark: Color = Color(0.545, 0.541, 0.529)
	if not GameState.is_morning():
		conc = conc.darkened(0.48)
		dark = dark.darkened(0.48)
	CA.far_mass(self, 128.0, dark.darkened(0.30),
		Color(0.86, 0.88, 0.90, 0.22), 30, 23)
	for spec in [[-20.0, 246.0, 6], [236.0, 218.0, 7], [464.0, 262.0, 6],
			[736.0, 232.0, 7], [978.0, 210.0, 6]]:
		_draw_new_block(float(spec[0]), float(spec[1]), int(spec[2]), conc, dark)


func _draw_new_block(x: float, w: float, storeys: int, body: Color,
		dark: Color) -> void:
	var floor_h: float = 30.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, dark)
	draw_rect(Rect2(x - 3.0, top - 7.0, w + 6.0, 8.0), dark.lightened(0.18))
	# Punched openings in a strict grid, all the same size, with a recessed
	# loggia every third bay. There is no ornament and none was intended.
	var bays: int = maxi(3, int(w / 44.0))
	var step: float = w / float(bays)
	for s in range(storeys - 1):
		var wy: float = top + 10.0 + float(s) * floor_h
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			if ((b + s) % 3) == 0:
				draw_rect(Rect2(bx - 17.0, wy - 2.0, 34.0, 24.0),
					dark.darkened(0.24))
				for k in range(5):
					draw_rect(Rect2(bx - 15.0 + float(k) * 7.0, wy + 12.0, 1.6, 9.0),
						dark.lightened(0.34))
				continue
			var on: bool = not GameState.is_morning() 				and ((int(x) + s * 5 + b * 3) % 4) == 0
			draw_rect(Rect2(bx - 13.0, wy, 26.0, 20.0),
				Color(0.98, 0.92, 0.76, 0.86) if on else C_GLASS)
			draw_rect(Rect2(bx - 14.0, wy - 2.0, 28.0, 2.2), body.lightened(0.16))
	# One tree per plot, planted at the same time as the building and still the
	# same height as the one next door.
	CA.tree(self, x + w * 0.5, CA.PAVE_TOP + 32.0, 34.0,
		Color(0.290, 0.243, 0.204), Color(0.271, 0.400, 0.310), 0.7)


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.365, 0.353, 0.345)
	var road: Color = Color(0.310, 0.298, 0.294)
	if not GameState.is_morning():
		pave = pave.darkened(0.42)
		road = road.darkened(0.44)
	# Niederdorf has no kerb at all — one surface, wall to wall, which is what
	# a street with no cars in it actually looks like.
	if district == "niederdorf":
		CA.ground(self, pave, pave.darkened(0.06), pave.darkened(0.12))
		CA.setts(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 13.0, C_SETT)
		# A drainage channel down the middle, in bigger stones.
		draw_rect(Rect2(0, 438.0, CA.VW, 16.0), pave.darkened(0.18))
		CA.setts(self, 438.0, 16.0, 16.0, C_SETT.darkened(0.10))
	else:
		CA.ground(self, pave, road, pave.darkened(0.10))
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 54.0, 40.0,
			Color(0, 0, 0, 0.13))
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 54.0, 40.0,
			Color(0, 0, 0, 0.13))
		for i in range(9):
			draw_rect(Rect2(float(i) * 132.0 + 30.0, 440.0, 62.0, 5.0),
				Color(0.80, 0.78, 0.72, 0.30))
	# Cleaned overnight and still damp at this hour. This is the one place the
	# obsessive maintenance turns into an actual pixel.
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.72, 0.78, 0.88), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var post: Color = Color(0.176, 0.169, 0.161)
	var lit: bool = not GameState.is_morning()
	if district == "niederdorf":
		# Wrought-iron lanterns on brackets off the wall, not on posts. There
		# is no room in the lane for posts.
		for x in [96.0, 386.0, 676.0, 966.0]:
			_draw_wall_lantern(float(x), lit)
		CA.tree(self, 470.0, CA.PAVE_TOP + 34.0, 42.0,
			Color(0.243, 0.208, 0.176), Color(0.235, 0.353, 0.290), 0.85)
		# A fountain. There are over a thousand in this city and every one is
		# drinkable, which is the most Zürich fact there is.
		_draw_fountain(848.0)
	else:
		for x in [140.0, 470.0, 800.0, 1080.0]:
			CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 76.0, post, C_LAMP, lit)
		CA.bin(self, 300.0, CA.PAVE_TOP + 40.0, Color(0.239, 0.298, 0.267))
		CA.bin(self, 918.0, CA.PAVE_TOP + 40.0, Color(0.239, 0.298, 0.267))
		CA.bollard(self, 620.0, CA.PAVE_TOP + 40.0, Color(0.55, 0.56, 0.57))
		CA.bollard(self, 660.0, CA.PAVE_TOP + 40.0, Color(0.55, 0.56, 0.57))


func _draw_wall_lantern(x: float, on: bool) -> void:
	var iron := Color(0.145, 0.141, 0.133)
	draw_rect(Rect2(x, 168.0, 26.0, 3.0), iron)
	draw_rect(Rect2(x + 24.0, 168.0, 3.0, 12.0), iron)
	draw_rect(Rect2(x + 19.0, 180.0, 14.0, 16.0), iron)
	if not on:
		return
	draw_rect(Rect2(x + 21.0, 182.0, 10.0, 12.0),
		Color(C_LAMP.r, C_LAMP.g, C_LAMP.b, 0.90))
	for i in range(4):
		draw_circle(Vector2(x + 26.0, 188.0), 14.0 + float(i) * 12.0,
			Color(C_LAMP.r, C_LAMP.g, C_LAMP.b, 0.040 - float(i) * 0.008))


func _draw_fountain(x: float) -> void:
	var stone: Color = C_STONE if GameState.is_morning() \
		else C_STONE.darkened(0.44)
	draw_rect(Rect2(x - 42.0, CA.PAVE_TOP + 18.0, 84.0, 26.0), stone)
	draw_rect(Rect2(x - 42.0, CA.PAVE_TOP + 18.0, 84.0, 4.0), stone.lightened(0.20))
	draw_rect(Rect2(x - 38.0, CA.PAVE_TOP + 22.0, 76.0, 12.0),
		Color(0.243, 0.376, 0.404, 0.75))
	draw_rect(Rect2(x - 5.0, CA.PAVE_TOP - 46.0, 10.0, 64.0), stone)
	draw_rect(Rect2(x - 11.0, CA.PAVE_TOP - 52.0, 22.0, 8.0), stone.lightened(0.14))
	# The spout, always running. Nobody turns it off; that is the point of it.
	var jitter: float = sin(_t * 9.0) * 0.6
	draw_rect(Rect2(x + 5.0 + jitter, CA.PAVE_TOP - 40.0, 2.0, 56.0),
		Color(0.68, 0.82, 0.86, 0.55))


func solids() -> Array:
	var out: Array = []
	if district == "niederdorf":
		out.append(Rect2(806.0, CA.PAVE_TOP + 18.0, 84.0, 30.0))    # fountain
		out.append(Rect2(456.0, CA.PAVE_TOP + 10.0, 28.0, 30.0))    # tree
	else:
		out.append(Rect2(288.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))    # bin
		out.append(Rect2(906.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))    # bin
		out.append(Rect2(614.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))    # bollard
		out.append(Rect2(654.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))    # bollard
	return out


# The towers, where this city actually has them.
# Almost nothing. The Prime Tower and two neighbours - it was the tallest
	# building in the country and it is 126 metres, which says everything.
func _draw_far_towers() -> void:
	if district != "zurichwest":
		return
	CA.skyline(self, 224.0, Color(0.271, 0.286, 0.325), Color(0.169, 0.192, 0.227),
		3, 11, not GameState.is_morning())
