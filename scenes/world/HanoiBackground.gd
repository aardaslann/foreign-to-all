extends Node2D

# Hanoi. Five districts, and the elevation is the product of a tax.
#
# TUBE HOUSES. Frontage was taxed, so everyone built two or three metres wide
# and went fifty or sixty metres back. That single fiscal fact produces the
# entire Old Quarter elevation: very tall, very thin, mismatched fronts, none
# of them level with the next, none of them the same colour, and a shop open
# straight onto the street with the family living above it.
#
# Over the top of all of it, the wire. Hanoi has the densest overhead cabling
# on the itinerary - not a tidy run but a black mass knotted at every pole, and
# it is the first thing anybody notices and the last thing anybody draws.
#
# On the pavement: plastic stools. Twenty centimetres high, primary coloured,
# and they are where the city actually eats. Nothing else here is more
# identifying, including the hats.
#
# PHO CO is the thirty-six streets. LONG BIEN is the 1902 cantilever bridge and
# the market under it. BA DINH is the French quarter - mustard villas, wide
# boulevards, and the only straight lines in the city. TAY HO is the lake.
# DONG DA is where the metro starts and where most people actually live.
#
# Vietnam is here for tone: the right word at the wrong pitch is a different
# word. That is not visual and this plate does not pretend it is.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "phoco"
# "phoco" | "longbien" | "badinh" | "tayho" | "dongda"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Faded ochre, and a lot of it. Then teal shutters, and the deep green of
# rain trees over everything.
const C_SKY_ZEN  := Color(0.062, 0.056, 0.125)
const C_SKY_MID  := Color(0.098, 0.086, 0.161)
const C_SKY_LOW  := Color(0.184, 0.141, 0.180)
const C_SKY_HAZE := Color(0.278, 0.192, 0.169)

const C_DAY_HI   := Color(0.494, 0.573, 0.639)
const C_DAY_MID  := Color(0.678, 0.694, 0.667)
const C_DAY_LOW  := Color(0.831, 0.784, 0.678)

const WASH := [
	Color(0.792, 0.686, 0.451),   # the ochre everybody thinks of
	Color(0.847, 0.792, 0.643),   # cream
	Color(0.702, 0.643, 0.494),   # dirty mustard
	Color(0.639, 0.686, 0.639),   # pale green
	Color(0.784, 0.643, 0.529),   # apricot
]

const C_MUSTARD := Color(0.831, 0.686, 0.353)   # the colonial yellow, Ba Dinh
const C_TEAL    := Color(0.196, 0.353, 0.318)   # shutters, and it is dark
const C_RED     := Color(0.780, 0.196, 0.161)
const C_TIMBER  := Color(0.318, 0.243, 0.176)
const C_GLASS   := Color(0.165, 0.180, 0.196)
const C_WIRE    := Color(0.063, 0.059, 0.067, 0.88)
const C_STOOL   := [Color(0.847, 0.263, 0.220), Color(0.196, 0.435, 0.706),
	Color(0.910, 0.702, 0.180), Color(0.180, 0.529, 0.373)]
const C_MOSS    := Color(0.298, 0.404, 0.286)
const C_WATER   := Color(0.180, 0.373, 0.361)
const C_STEEL   := Color(0.404, 0.376, 0.353)   # the bridge
const C_LAMP    := Color(1.0, 0.855, 0.612)
const C_JOINT   := Color(0.086, 0.082, 0.106, 0.34)

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
			WASH[1], Color(0.20, 0.15, 0.11), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	_draw_far_towers()
	match district:
		"longbien": _draw_longbien()
		"badinh":   _draw_badinh()
		"tayho":    _draw_tayho()
		"dongda":   _draw_dongda()
		_:          _draw_phoco()
	if district != "tayho":
		_draw_wires()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_TIMBER.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 9)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.66, 0.56, 0.34), 0.05)
	CA.vignette(self, 0.26)


# ── Wires ─────────────────────────────────────────────────────────────────────
# Not a run. A mass. Eight or nine bundles between poles and a black knot at
# every one, and it is the most photographed thing in the city.

func _draw_wires() -> void:
	var poles := [56.0, 296.0, 536.0, 776.0, 1024.0, 1152.0]
	for i in range(poles.size() - 1):
		CA.wires(self, float(poles[i]), 108.0, float(poles[i + 1]), 114.0,
			9, 30.0, C_WIRE)
		CA.wires(self, float(poles[i]), 164.0, float(poles[i + 1]), 168.0,
			5, 18.0, C_WIRE)
	for p in poles:
		var px: float = float(p)
		draw_rect(Rect2(px - 5.0, CA.PAVE_TOP + 40.0 - 226.0, 10.0, 226.0),
			Color(0.545, 0.537, 0.518) if GameState.is_morning()
			else Color(0.545, 0.537, 0.518).darkened(0.50))
		CA.wire_knot(self, px, 128.0, C_WIRE)
		CA.wire_knot(self, px, 152.0, C_WIRE)
		# A meter box and a loudspeaker, on every pole, always.
		draw_rect(Rect2(px + 7.0, 178.0, 16.0, 22.0), Color(0.40, 0.40, 0.38))
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 8.0, 186.0), Vector2(px - 22.0, 178.0),
			Vector2(px - 22.0, 198.0), Vector2(px - 8.0, 194.0),
		]), Color(0.45, 0.44, 0.42))


# ── The tube house ────────────────────────────────────────────────────────────
# Two to four metres wide, four or five storeys, and no two neighbours agree on
# floor height, colour, or where the roof stops.

func _draw_tube(x: float, w: float, storeys: int, ci: int, seed_i: int) -> void:
	var body: Color = WASH[ci % WASH.size()]
	var teal: Color = C_TEAL
	if not GameState.is_morning():
		body = body.darkened(0.46)
		teal = teal.darkened(0.40)
	var floor_h: float = 34.0 + float(seed_i % 3) * 3.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	draw_rect(Rect2(x + w - 4.0, top, 4.0, GROUND_Y - top), body.darkened(0.22))
	draw_rect(Rect2(x, top, 3.0, GROUND_Y - top), Color(1, 1, 1, 0.06))
	# Damp and mould, coming UP from the ground as well as down from the roof,
	# which is what a monsoon climate does and a cold one does not.
	draw_rect(Rect2(x, GROUND_Y - 40.0, w, 40.0),
		Color(C_MOSS.r, C_MOSS.g, C_MOSS.b, 0.16))
	for k in range(2):
		var sx: float = x + 4.0 + float((seed_i * 41 + k * 59) % int(maxf(w - 8.0, 4.0)))
		draw_rect(Rect2(sx, top + 8.0, 4.0, GROUND_Y - top - 30.0),
			Color(0.16, 0.16, 0.12, 0.18))
	# The top: a parapet, a water tank, and often a shrine.
	draw_rect(Rect2(x - 3.0, top - 9.0, w + 6.0, 10.0), body.lightened(0.16))
	draw_rect(Rect2(x + w * 0.5 - 9.0, top - 24.0, 18.0, 15.0),
		Color(0.286, 0.435, 0.478) if GameState.is_morning()
		else Color(0.286, 0.435, 0.478).darkened(0.46))
	# One or two windows per floor, with a shallow iron balcony on most.
	var bays: int = maxi(1, int(w / 40.0))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 37 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 20.0, 22.0, C_GLASS, teal, lit)
		var step: float = w / float(bays)
		for b in range(bays):
			CA.shutters(self, x + step * (float(b) + 0.5) - 10.0, wy, 20.0, 22.0,
				teal)
		if (seed_i + s) % 2 == 0:
			CA.balcony(self, x + 3.0, wy + 22.0, w - 6.0,
				Color(0.30, 0.29, 0.28) if GameState.is_morning()
				else Color(0.30, 0.29, 0.28).lightened(0.14))
	# A vertical sign down the front, because the frontage is too narrow for a
	# horizontal one. This is the direct architectural consequence of the tax.
	if (seed_i % 2) == 0:
		var bx: float = x + w - 12.0
		var sc: Color = [C_RED, C_TEAL, Color(0.196, 0.353, 0.639)][seed_i % 3]
		if not GameState.is_morning():
			sc = sc.darkened(0.36)
		draw_rect(Rect2(bx, top + 16.0, 11.0, 82.0), sc)
		draw_rect(Rect2(bx, top + 16.0, 11.0, 2.0), sc.lightened(0.24))
		for m in range(5):
			draw_rect(Rect2(bx + 3.0, top + 22.0 + float(m) * 15.0, 5.0, 9.0),
				Color(0.95, 0.93, 0.88))


# ── Pho Co ────────────────────────────────────────────────────────────────────
# The thirty-six streets. Nineteen frontages across a plate that fits eight
# anywhere else, and that density IS the district.

const PHOCO_ROW := [
	[-12.0, 58.0, 5, 0], [46.0, 44.0, 4, 2], [90.0, 66.0, 5, 1], [156.0, 50.0, 4, 3],
	[206.0, 62.0, 5, 4], [268.0, 42.0, 4, 0], [310.0, 70.0, 5, 2], [380.0, 54.0, 4, 1],
	[434.0, 60.0, 5, 3], [494.0, 46.0, 4, 4], [540.0, 68.0, 5, 0], [608.0, 52.0, 4, 2],
	[660.0, 64.0, 5, 1], [724.0, 48.0, 4, 3], [772.0, 72.0, 5, 4], [844.0, 56.0, 4, 0],
	[900.0, 62.0, 5, 2], [962.0, 50.0, 4, 1], [1012.0, 74.0, 5, 3], [1086.0, 66.0, 4, 4],
]


func _draw_phoco() -> void:
	for i in range(PHOCO_ROW.size()):
		var spec: Array = PHOCO_ROW[i]
		_draw_tube(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]), i)


# ── Long Bien ─────────────────────────────────────────────────────────────────
# The 1902 bridge: a cantilever truss over the Red River, bombed repeatedly,
# patched in mismatched steel, and still carrying trains. The market lives
# under it.

func _draw_longbien() -> void:
	var water: Color = C_WATER
	if not GameState.is_morning():
		water = water.darkened(0.50)
	draw_rect(Rect2(0, 196.0, CA.VW, 22.0), water)
	_draw_bridge()
	for spec in [[-14.0, 74.0, 3, 2], [64.0, 58.0, 3, 0], [124.0, 68.0, 3, 3],
			[916.0, 62.0, 3, 1], [980.0, 76.0, 3, 4], [1060.0, 60.0, 3, 2]]:
		_draw_tube(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 9)
	for i in range(5):
		CA.stall(self, 230.0 + float(i) * 138.0, CA.PAVE_TOP + 10.0, 120.0,
			Color(0.196, 0.353, 0.318),
			[Color(0.86, 0.28, 0.20), Color(0.92, 0.76, 0.20),
			 Color(0.25, 0.53, 0.30)])


func _draw_bridge() -> void:
	var steel: Color = C_STEEL
	var patch: Color = Color(0.478, 0.404, 0.341)
	if not GameState.is_morning():
		steel = steel.darkened(0.48)
		patch = patch.darkened(0.48)
	var deck: float = 148.0
	draw_rect(Rect2(-20.0, deck, CA.VW + 40.0, 9.0), steel)
	draw_rect(Rect2(-20.0, deck + 9.0, CA.VW + 40.0, 4.0), steel.darkened(0.26))
	# The trusses. Diamond-braced spans that rise to a peak over each pier,
	# which is the Long Bien silhouette and nothing else looks like it.
	for s in range(4):
		var sx: float = -40.0 + float(s) * 320.0
		var peak: float = 62.0
		# Two quads, not one chevron. A six-point band with a reflex vertex at
		# the apex is concave, and Godot's ear-clipper refuses it outright -
		# "Invalid polygon data, triangulation failed", every frame, forever.
		# Wind each quad upper-edge-first, then down the far cap, then back
		# along the lower edge. Pairing the LOWER left point with the UPPER
		# right one makes a bow-tie: the two long edges cross about a third of
		# the way along, and Godot refuses to triangulate it.
		var col: Color = steel if (s % 2) == 0 else patch
		draw_colored_polygon(PackedVector2Array([
			Vector2(sx, deck - 6.0), Vector2(sx + 160.0, peak),
			Vector2(sx + 160.0, peak + 8.0), Vector2(sx, deck),
		]), col)
		draw_colored_polygon(PackedVector2Array([
			Vector2(sx + 160.0, peak), Vector2(sx + 320.0, deck - 6.0),
			Vector2(sx + 320.0, deck), Vector2(sx + 160.0, peak + 8.0),
		]), col)
		# The lattice inside the span.
		for k in range(10):
			var u: float = float(k) / 9.0
			var tx: float = sx + u * 320.0
			var ty: float = lerpf(deck, peak, 1.0 - absf(u - 0.5) * 2.0)
			draw_line(Vector2(tx, deck), Vector2(tx + 16.0, ty),
				steel.darkened(0.16), 1.6)
			draw_line(Vector2(tx + 32.0, deck), Vector2(tx + 16.0, ty),
				steel.darkened(0.16), 1.6)
	for i in range(4):
		var px: float = 120.0 + float(i) * 320.0
		draw_rect(Rect2(px - 11.0, deck + 12.0, 22.0, 90.0), steel.darkened(0.18))
		draw_rect(Rect2(px - 15.0, deck + 12.0, 30.0, 7.0), steel.darkened(0.10))


# ── Ba Dinh ───────────────────────────────────────────────────────────────────
# The French quarter. Mustard villas with white trim behind walls, wide
# boulevards, rain trees, and the only straight lines in the city.

func _draw_badinh() -> void:
	CA.far_mass(self, 196.0,
		Color(0.298, 0.353, 0.286) if GameState.is_morning()
		else Color(0.298, 0.353, 0.286).darkened(0.56),
		Color(0.90, 0.86, 0.70, 0.18), 14, 6)
	for spec in [[-16.0, 176.0], [190.0, 158.0], [376.0, 184.0], [590.0, 162.0],
			[782.0, 178.0], [990.0, 170.0]]:
		_draw_villa(float(spec[0]), float(spec[1]))
	for tx in [140.0, 480.0, 880.0]:
		_draw_rain_tree(float(tx))


func _draw_villa(x: float, w: float) -> void:
	var body: Color = C_MUSTARD
	var trim: Color = Color(0.933, 0.918, 0.878)
	var teal: Color = C_TEAL
	if not GameState.is_morning():
		body = body.darkened(0.46)
		trim = trim.darkened(0.44)
		teal = teal.darkened(0.40)
	var top: float = GROUND_Y - 96.0
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	draw_rect(Rect2(x - 6.0, top - 10.0, w + 12.0, 11.0), trim)
	CA.roof(self, x, w, top - 10.0, 16.0,
		Color(0.588, 0.353, 0.267) if GameState.is_morning()
		else Color(0.588, 0.353, 0.267).darkened(0.46))
	var bays: int = maxi(2, int(w / 52.0))
	var step: float = w / float(bays)
	for s in range(2):
		var wy: float = top + 14.0 + float(s) * 44.0
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 19 + s * 7) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 26.0, 32.0, C_GLASS, trim, lit)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			CA.shutters(self, bx - 13.0, wy, 26.0, 32.0, teal)
			draw_rect(Rect2(bx - 17.0, wy - 6.0, 34.0, 5.0), trim)
	# The wall and the gate. You never see the whole villa; you see the wall.
	draw_rect(Rect2(x - 4.0, CA.PAVE_TOP - 44.0, w + 8.0, 44.0), body.lightened(0.10))
	draw_rect(Rect2(x - 4.0, CA.PAVE_TOP - 48.0, w + 8.0, 6.0), trim)
	var gx: float = x + w * 0.5
	draw_rect(Rect2(gx - 22.0, CA.PAVE_TOP - 42.0, 44.0, 42.0), Color(0.16, 0.19, 0.18))
	for i in range(7):
		draw_rect(Rect2(gx - 20.0 + float(i) * 6.0, CA.PAVE_TOP - 40.0, 2.0, 40.0),
			teal.lightened(0.20))


# The rain tree: an enormously wide, flat, low canopy on a short trunk. It
# shades the whole boulevard and it is what the French planted here.
func _draw_rain_tree(x: float) -> void:
	var trunk: Color = Color(0.298, 0.243, 0.196)
	var leaf: Color = Color(0.192, 0.365, 0.259)
	if not GameState.is_morning():
		trunk = trunk.darkened(0.48)
		leaf = leaf.darkened(0.54)
	var base: float = CA.FAR_TOP + 18.0
	draw_rect(Rect2(x - 8.0, base - 76.0, 16.0, 76.0), trunk)
	for i in range(4):
		draw_line(Vector2(x, base - 66.0),
			Vector2(x - 60.0 + float(i) * 40.0, base - 104.0), trunk, 4.0)
	for i in range(7):
		draw_circle(Vector2(x - 84.0 + float(i) * 28.0,
			base - 108.0 - float((i * 17) % 14)), 26.0,
			Color(leaf.r, leaf.g, leaf.b, 0.86))
	draw_rect(Rect2(x - 30.0, base - 3.0, 60.0, 5.0), Color(0, 0, 0, 0.20))


# ── Tay Ho ────────────────────────────────────────────────────────────────────
# West Lake. Water across the top, a causeway, lotus in the shallows, and a
# temple on a spit. No wires - it is the only place in the city you can see sky.

func _draw_tayho() -> void:
	var water: Color = C_WATER
	if not GameState.is_morning():
		water = water.darkened(0.50)
	draw_rect(Rect2(0, 132.0, CA.VW, 92.0), water)
	for i in range(11):
		var y: float = 140.0 + float(i) * 8.0
		var a: float = 0.09 + 0.06 * sin(_t * 0.4 + float(i) * 0.7)
		draw_rect(Rect2(0, y, CA.VW, 2.5), Color(0.72, 0.84, 0.82, a))
	_draw_temple(268.0)
	# Lotus. Flat pads on the water with a few flowers standing up out of them.
	for i in range(22):
		var lx: float = 520.0 + float((i * 71) % 600)
		var ly: float = 176.0 + float((i * 43) % 44)
		draw_circle(Vector2(lx, ly), 9.0, Color(0.192, 0.408, 0.294, 0.85))
		if (i % 4) == 0:
			draw_rect(Rect2(lx - 2.0, ly - 16.0, 3.0, 14.0),
				Color(0.235, 0.443, 0.310))
			draw_circle(Vector2(lx - 0.5, ly - 19.0), 5.0,
				Color(0.929, 0.741, 0.792) if GameState.is_morning()
				else Color(0.929, 0.741, 0.792).darkened(0.44))
	for spec in [[-14.0, 168.0], [850.0, 156.0], [1030.0, 148.0]]:
		_draw_villa(float(spec[0]), float(spec[1]))
	for tx in [640.0]:
		_draw_rain_tree(float(tx))


func _draw_temple(x: float) -> void:
	# Tran Quoc, on its causeway out into West Lake. The pavilion alone was
	# unrecognisable - what everybody in Hanoi actually pictures is the
	# eleven-storey brick stupa standing over it, so that is the silhouette
	# this draws and it is drawn tall enough to clear the roofline.
	var red: Color = C_RED
	var tile: Color = Color(0.478, 0.286, 0.220)
	var brick := Color(0.612, 0.361, 0.267)
	var gold := Color(0.831, 0.678, 0.318)
	if not GameState.is_morning():
		red = red.darkened(0.26)
		tile = tile.darkened(0.34)
		brick = brick.darkened(0.24)
		gold = gold.darkened(0.10)

	# The causeway out to it.
	draw_rect(Rect2(x - 190.0, 214.0, 210.0, 10.0), Color(0.612, 0.545, 0.463)
		if GameState.is_morning() else Color(0.612, 0.545, 0.463).darkened(0.40))
	draw_rect(Rect2(x - 190.0, 214.0, 210.0, 3.0), Color(0.72, 0.66, 0.58, 0.5))

	# The hall, with the roof turning up at the corners.
	draw_rect(Rect2(x - 52.0, 178.0, 104.0, 44.0), red.darkened(0.24))
	for i in range(3):
		draw_rect(Rect2(x - 34.0 + float(i) * 30.0, 190.0, 16.0, 32.0),
			Color(0.106, 0.086, 0.078))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 76.0, 180.0), Vector2(x - 62.0, 158.0),
		Vector2(x + 62.0, 158.0), Vector2(x + 76.0, 180.0),
		Vector2(x + 90.0, 171.0), Vector2(x + 66.0, 152.0),
		Vector2(x - 66.0, 152.0), Vector2(x - 90.0, 171.0),
	]), tile)
	draw_rect(Rect2(x - 66.0, 148.0, 132.0, 6.0), tile.lightened(0.20))

	# The stupa: eleven tiers, each one a little narrower than the one under
	# it, each with six arched niches and a Buddha in every niche.
	var sx: float = x + 96.0
	var foot: float = 208.0
	var tiers: int = 11
	var th: float = 15.0
	for t in range(tiers):
		var f: float = float(t) / float(tiers - 1)
		var hw: float = lerp(40.0, 21.0, f)
		var ty: float = foot - float(t + 1) * th
		draw_rect(Rect2(sx - hw, ty, hw * 2.0, th), brick)
		draw_rect(Rect2(sx - hw, ty, hw * 0.30, th), brick.lightened(0.14))
		# The cornice each storey sits under, which is what makes the tower
		# read as a stack rather than as a tapering post.
		draw_rect(Rect2(sx - hw - 4.0, ty, hw * 2.0 + 8.0, 3.5),
			brick.darkened(0.28))
		var niches: int = 3 if hw > 30.0 else 2
		for n in range(niches):
			var nw: float = hw * 2.0 / float(niches)
			var nx: float = sx - hw + nw * (float(n) + 0.5)
			draw_rect(Rect2(nx - 4.5, ty + 6.0, 9.0, th - 8.0),
				brick.darkened(0.52))
			draw_circle(Vector2(nx, ty + 6.0), 4.5, brick.darkened(0.52))
			draw_circle(Vector2(nx, ty + 8.5), 2.6, gold)
	# The lotus finial on top, and the nine-ringed spire under it.
	var tip: float = foot - float(tiers) * th
	draw_colored_polygon(PackedVector2Array([
		Vector2(sx - 26.0, tip), Vector2(sx + 26.0, tip),
		Vector2(sx + 14.0, tip - 12.0), Vector2(sx - 14.0, tip - 12.0),
	]), brick.lightened(0.08))
	for r in range(5):
		draw_rect(Rect2(sx - 9.0 + float(r) * 1.4, tip - 16.0 - float(r) * 5.0,
			18.0 - float(r) * 2.8, 3.0), gold)
	draw_circle(Vector2(sx, tip - 44.0), 6.0, gold)
	draw_rect(Rect2(sx - 1.5, tip - 56.0, 3.0, 13.0), gold)

func _draw_dongda() -> void:
	CA.far_mass(self, 178.0,
		Color(0.412, 0.396, 0.365) if GameState.is_morning()
		else Color(0.412, 0.396, 0.365).darkened(0.58),
		Color(0.88, 0.84, 0.70, 0.22), 34, 8)
	_draw_viaduct()
	for spec in [[-16.0, 118.0, 6, 0], [110.0, 96.0, 7, 2], [214.0, 124.0, 6, 1],
			[346.0, 102.0, 7, 3], [456.0, 130.0, 6, 4], [594.0, 98.0, 7, 0],
			[700.0, 126.0, 6, 2], [834.0, 108.0, 7, 1], [950.0, 140.0, 6, 3],
			[1098.0, 88.0, 7, 4]]:
		_draw_tube(float(spec[0]), float(spec[1]), int(spec[2]), int(spec[3]),
			int(spec[0]) % 11)


# Line 2A runs on concrete above the traffic, which is the newest thing in the
# city by about a century.
func _draw_viaduct() -> void:
	var conc: Color = Color(0.671, 0.659, 0.639)
	if not GameState.is_morning():
		conc = conc.darkened(0.50)
	draw_rect(Rect2(-20.0, 74.0, CA.VW + 40.0, 30.0), conc)
	draw_rect(Rect2(-20.0, 74.0, CA.VW + 40.0, 5.0), conc.lightened(0.16))
	draw_rect(Rect2(-20.0, 99.0, CA.VW + 40.0, 6.0), Color(0, 0, 0, 0.30))
	for i in range(4):
		var px: float = 90.0 + float(i) * 320.0
		draw_rect(Rect2(px - 16.0, 104.0, 32.0, 170.0), conc)
		draw_rect(Rect2(px - 16.0, 104.0, 7.0, 170.0), conc.lightened(0.12))
	# The train, every few minutes, and nobody on the street looks up.
	var cycle: float = fmod(_t, 30.0) / 30.0
	if cycle < 0.36:
		var tx: float = lerpf(-380.0, CA.VW + 240.0, cycle / 0.36)
		for c in range(3):
			var cx: float = tx + float(c) * 132.0
			draw_rect(Rect2(cx, 38.0, 126.0, 38.0), Color(0.831, 0.839, 0.847))
			draw_rect(Rect2(cx, 52.0, 126.0, 7.0), Color(0.176, 0.404, 0.286))
			for k in range(4):
				draw_rect(Rect2(cx + 12.0 + float(k) * 28.0, 43.0, 20.0, 9.0),
					Color(0.20, 0.24, 0.27) if GameState.is_morning()
					else Color(0.94, 0.93, 0.88, 0.85))


# ── Ground ────────────────────────────────────────────────────────────────────
# The pavement is not for walking. It is parking, kitchen, and dining room, and
# the walking happens in the road. That is not a complaint, it is the plan.

func _draw_ground() -> void:
	var pave: Color = Color(0.463, 0.443, 0.408)
	var road: Color = Color(0.290, 0.282, 0.271)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.08))
	CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 30.0, 30.0, C_JOINT)
	CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 30.0, 30.0, C_JOINT)
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.16))
	# Wet. It is wet here most of the year and the ground shows it more than
	# anywhere else on the itinerary.
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.60, 0.66, 0.64), _t)
	for i in range(6):
		draw_rect(Rect2(float((i * 197) % 1080), CA.ROAD_TOP + 24.0 +
			float((i * 61) % 90), 46.0, 8.0), Color(0.42, 0.50, 0.48, 0.30))


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [180.0, 700.0, 1080.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 76.0, C_TIMBER, C_LAMP, lit)
	# The plastic stools. Twenty centimetres high, primary coloured, and this is
	# where the city eats. More identifying than any building on the plate.
	if district != "badinh":
		_draw_stools(400.0, 6)
		_draw_stools(830.0, 5)
	# Motorbikes, parked ON the pavement in a solid rank, which is why nobody
	# walks on it.
	_draw_bikes(250.0, 5)
	if district == "phoco" or district == "longbien" or district == "dongda":
		_draw_bikes(920.0, 4)
	CA.bin(self, 620.0, CA.PAVE_TOP + 40.0, C_TEAL.darkened(0.16))


func _draw_stools(x: float, n: int) -> void:
	var y: float = CA.PAVE_TOP + 38.0
	for i in range(n):
		var c: Color = C_STOOL[i % C_STOOL.size()]
		if not GameState.is_morning():
			c = c.darkened(0.42)
		var sx: float = x + float(i) * 26.0
		var sy: float = y - float((i * 13) % 3) * 3.0
		draw_rect(Rect2(sx - 8.0, sy - 10.0, 17.0, 4.0), c)
		draw_rect(Rect2(sx - 7.0, sy - 6.0, 3.0, 6.0), c.darkened(0.24))
		draw_rect(Rect2(sx + 5.0, sy - 6.0, 3.0, 6.0), c.darkened(0.24))
		draw_rect(Rect2(sx - 8.0, sy, 18.0, 2.0), Color(0, 0, 0, 0.22))
	# A low table with a pot on it, because the stools are for eating at.
	var t: Color = Color(0.729, 0.694, 0.612)
	if not GameState.is_morning():
		t = t.darkened(0.42)
	draw_rect(Rect2(x + 26.0, y - 20.0, 44.0, 5.0), t)
	draw_rect(Rect2(x + 30.0, y - 15.0, 4.0, 14.0), t.darkened(0.26))
	draw_rect(Rect2(x + 60.0, y - 15.0, 4.0, 14.0), t.darkened(0.26))
	draw_rect(Rect2(x + 38.0, y - 30.0, 20.0, 11.0), Color(0.55, 0.55, 0.53))
	# Steam. There is always something on the boil.
	for k in range(3):
		var rise: float = fmod(_t * 14.0 + float(k) * 20.0, 46.0)
		draw_circle(Vector2(x + 48.0 + sin(_t + float(k)) * 4.0,
			y - 32.0 - rise), 4.0 + rise * 0.10,
			Color(0.90, 0.90, 0.88, 0.10 - rise * 0.002))


func _draw_bikes(x: float, n: int) -> void:
	var frame: Color = Color(0.271, 0.278, 0.290)
	if not GameState.is_morning():
		frame = frame.darkened(0.38)
	for i in range(n):
		var bx: float = x + float(i) * 24.0
		var by: float = CA.PAVE_TOP + 30.0
		draw_arc(Vector2(bx, by), 8.0, 0, TAU, 14, frame, 3.0)
		draw_arc(Vector2(bx + 20.0, by), 8.0, 0, TAU, 14, frame, 3.0)
		var body: Color = C_STOOL[(i + 1) % C_STOOL.size()].darkened(0.20)
		if not GameState.is_morning():
			body = body.darkened(0.40)
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx - 2.0, by - 8.0), Vector2(bx + 12.0, by - 12.0),
			Vector2(bx + 22.0, by - 8.0), Vector2(bx + 20.0, by - 3.0),
			Vector2(bx + 1.0, by - 3.0),
		]), body)
		draw_rect(Rect2(bx + 15.0, by - 24.0, 3.0, 14.0), frame)
		draw_rect(Rect2(bx + 9.0, by - 26.0, 15.0, 3.0), frame)
		draw_rect(Rect2(bx - 3.0, by - 16.0, 13.0, 5.0), frame.darkened(0.20))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(608.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(240.0, CA.PAVE_TOP + 14.0, 128.0, 28.0))      # bikes
	if district != "badinh":
		out.append(Rect2(388.0, CA.PAVE_TOP + 18.0, 92.0, 24.0))   # stools
		out.append(Rect2(818.0, CA.PAVE_TOP + 18.0, 78.0, 24.0))   # stools
	if district == "phoco" or district == "longbien" or district == "dongda":
		out.append(Rect2(910.0, CA.PAVE_TOP + 14.0, 104.0, 28.0))  # bikes
	if district == "badinh" or district == "tayho":
		for tx in [140.0, 480.0, 880.0]:
			out.append(Rect2(float(tx) - 10.0, CA.FAR_TOP + 2.0, 20.0, 20.0))
	for p in [56.0, 296.0, 536.0, 776.0, 1024.0]:
		out.append(Rect2(float(p) - 6.0, CA.PAVE_TOP + 14.0, 12.0, 28.0))
	return out


# The towers, where this city actually has them.
# Lotte and Keangnam across the lake - two towers on their own, a long way
	# from the thirty-six streets.
func _draw_far_towers() -> void:
	if district != "tayho":
		return
	CA.skyline(self, 212.0, Color(0.267, 0.278, 0.325), Color(0.161, 0.180, 0.224),
		5, 47, not GameState.is_morning())
