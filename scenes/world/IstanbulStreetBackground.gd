extends Node2D

# Istanbul — drawn, like London, because there is no art handoff for it either.
# Composed from docs/design/istanbul.md.
#
# Berlin sits BACK from you: wide, flat, a lot of sky.
# London sits ON TOP of you: narrow, busy roofline, a hole before every door.
# Istanbul sits ABOVE AND BELOW you. The city is on a hill and never lets you
# forget it, and the thing that says so is the `cumba` — the closed timber bay
# window that juts out over the lane on brackets, from both sides at once,
# until the two sides nearly touch.
#
# Two districts, and the difference between them is the whole act:
#   "carsi" — the market lane. Stepped ground, netted sky, warm dark.
#   "han"   — through the gate. A rectangular courtyard with a portico all the
#             way round and OPEN SKY, the only open sky in the city. After the
#             lane it should read as a change of pressure, not just of scenery.
#
# Ground bands stay where Berlin and London put them so the player, the exits
# and the collision boxes all behave identically.

@export var district: String = "carsi"
# "carsi" | "han" | "beyoglu" | "kadikoy"

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── Palette (docs/design/istanbul.md) ─────────────────────────────────────────
const C_SHADOW   := Color(0.165, 0.122, 0.094)   # under awnings, inside the arcade
const C_TIMB_DK  := Color(0.290, 0.212, 0.149)   # brackets, shutters, cumba soffit
const C_TIMBER   := Color(0.420, 0.310, 0.208)   # upper storeys
const C_PLASTER  := Color(0.541, 0.435, 0.306)   # worn ground floors
const C_SUN      := Color(0.788, 0.659, 0.471)   # the lit face — the base note
const C_BLEACH   := Color(0.910, 0.835, 0.690)   # where the sun sits longest
const C_TERRA    := Color(0.710, 0.337, 0.235)   # pantiles, pots
const C_ROOF_SH  := Color(0.549, 0.290, 0.227)   # under every tile course
const C_ROSE     := Color(0.659, 0.341, 0.310)   # one house in five
const C_MINT     := Color(0.490, 0.608, 0.435)   # one house in seven
const C_PALEBLUE := Color(0.353, 0.478, 0.549)   # shutters, the cool house
const C_CABLE    := Color(0.239, 0.227, 0.204)   # the netting overhead, ironwork

# The modern city. Istanbul is not an old town — it is sixteen million people in
# mid-century concrete, and the timber lane is one surviving layer inside that,
# not the whole of it. These blocks stand BEHIND the historic frontage and are
# taller than it, so the skyline reads apartment-block first and pantile second.
const C_CONCRETE := Color(0.494, 0.478, 0.443)   # yap-sat block, weathered
const C_CONC_DK  := Color(0.376, 0.365, 0.341)   # the shaded return
const C_CONC_LT  := Color(0.596, 0.580, 0.541)   # sun on the parapet
const C_GLASS_M  := Color(0.239, 0.290, 0.310)   # modern shopfront glazing
const C_ALU      := Color(0.643, 0.651, 0.647)   # window frames, AC units, dishes
const C_SIGNBOX  := Color(0.902, 0.878, 0.824)   # backlit fascia, always too bright
const C_ASPHALT  := Color(0.192, 0.188, 0.192)   # the lane is tarmac, not sand

# İznik. Saturated, and ONLY ever on ceramic, glass, tile or the eye —
# never on architecture. Istanbul has no statutory colour; it has jewellery.
const C_COBALT   := Color(0.110, 0.224, 0.659)
const C_TURQ     := Color(0.184, 0.643, 0.627)
const C_BOLE     := Color(0.784, 0.271, 0.227)
const C_EMERALD  := Color(0.122, 0.478, 0.353)
const C_TILE_W   := Color(0.941, 0.925, 0.878)

# Shared with Berlin and London so exits and collision stay true
const PAVE_TOP := 292.0
const MID      := 470.0
const PAVE_BOT := 516.0

# Houses along the lane: [x, width, storeys, wall colour index]
# Gapped on purpose. The surviving timber houses are islands in the concrete,
# not a continuous frontage — the blocks behind them show through the gaps, and
# that layering IS the city. A solid run of pantiles would be an old town.
const _HOUSES := [
	[-30, 168, 2, 0], [268, 152, 3, 1], [560, 160, 2, 2], [880, 156, 3, 3],
]

# Hoisted out of the draw calls: indexing an inline array literal parses, but
# this project has been bitten by inference on subscripts before, and a named
# const is easier to read at the call site anyway.
const AWNING_STRIPES := [C_BOLE, C_TURQ, C_EMERALD, C_COBALT]
const PRODUCE_HUES   := [C_BOLE, C_EMERALD, C_TERRA]
const LAUNDRY_HUES   := [C_TILE_W, C_PALEBLUE, C_ROSE, C_MINT]

var _t: float = 0.0


# ── Doors ─────────────────────────────────────────────────────────────────────
# Read straight off the SceneExit siblings, so the sign over a door and the
# building behind it are the same building by construction. Previously the
# signage was drawn at fixed positions that had nothing to do with the doors,
# which is why you could walk under MARKET and come out in a hotel.

const IA := preload("res://scenes/world/InteriorArt.gd")
const CA := preload("res://scenes/world/CityArt.gd")

var _doors: Array = []


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
		_doors.append({
			"x": (child as Node2D).position.x,
			"label": String(label),
			"kind": String(child.get("frontage") if child.get("frontage") != null else "shop"),
		})


func _draw_doors(ground_y: float, base_y: float, board: Color, ink: Color,
		accent: Color, glass: Color) -> void:
	for d in _doors:
		var x: float = float(d["x"])
		IA.frontage(self, x, ground_y, base_y, String(d["kind"]), accent, glass, _t)
		IA.fascia(self, x, ground_y - 78.0, String(d["label"]), board, ink,
			not GameState.is_morning())


func _ready() -> void:
	_collect_doors()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2.0, VH + EXT * 2.0), C_VOID)
	match district:
		"han":     _draw_han()
		"beyoglu": _draw_beyoglu()
		"kadikoy": _draw_kadikoy()
		_:         _draw_carsi()



# ── Beyoğlu ───────────────────────────────────────────────────────────────────
# İstiklal. Nineteenth-century European apartment blocks five and six storeys
# high, built by Levantine and Greek merchants when this was Pera, with arcaded
# passages cut through half of them. The nostalgic tram runs down the middle of
# a street that has no other traffic on it.
#
# It is the one district in this city that was built to look like somewhere
# else, and the alien - who has just come from four of those somewhere-elses -
# is the only person on the street who can tell.

# The row opens once, for the side street the tower stands at the top of.
# Solid, it stood in front of the only thing in Beyoglu anybody climbs.
const PERA_ROW := [
	[-16.0, 148.0, 6], [136.0, 122.0, 5], [258.0, 156.0, 6], [418.0, 130.0, 5],
	[706.0, 150.0, 5], [864.0, 150.0, 6], [1022.0, 150.0, 5],
]


func _draw_beyoglu() -> void:
	_draw_lane_sky()
	for i in range(PERA_ROW.size()):
		var spec: Array = PERA_ROW[i]
		_draw_pera(float(spec[0]), float(spec[1]), int(spec[2]), i)
	_draw_lane_up(556.0, 142.0)
	_draw_galata(627.0)
	# İstiklal is a shopping street and the Pera blocks have shops cut into
	# the bottom of every one of them. Without this the district drew six
	# storeys of apartment and then two-thirds of a frame of nothing.
	CA.ground_floor(self, 236.0, C_PLASTER.darkened(0.24), C_GLASS_M,
		Color(1.0, 0.855, 0.596), not GameState.is_morning(), 63,
		["clothes", "books", "bakery", "cafe", "post", "barber",
		"pharmacy", "grocer"])
	_draw_istiklal_ground()
	_draw_doors(236.0, PAVE_TOP, C_SIGNBOX, Color(0.129, 0.106, 0.086),
		C_TURQ, C_GLASS_M)
	_draw_istiklal_furniture()
	_draw_tram(fmod(_t * 0.05, 1.0))


# No kerb and no carriageway: the whole width between the shopfronts is laid
# in granite sett, and the only thing on it is the single tram track.
func _draw_istiklal_ground() -> void:
	var stone := Color(0.451, 0.435, 0.427)
	var joint := Color(0.310, 0.298, 0.294)
	if not GameState.is_morning():
		stone = stone.darkened(0.44)
		joint = joint.darkened(0.44)
	draw_rect(Rect2(0, PAVE_TOP, VW, VH - PAVE_TOP), stone)
	CA.setts(self, PAVE_TOP, VH - PAVE_TOP, 15.0, joint)
	# It falls away downhill towards Tünel, so the far end is in shade.
	draw_rect(Rect2(0, PAVE_TOP, VW, 26.0), Color(0, 0, 0, 0.20))
	draw_rect(Rect2(0, PAVE_TOP, VW, 5.0), Color(0, 0, 0, 0.30))
	# The track. One line, laid flush, worn bright where the wheels run.
	for rail in [-30.0, 30.0]:
		draw_rect(Rect2(0, 396.0 + rail, VW, 5.0), Color(0.42, 0.40, 0.38))
		draw_rect(Rect2(0, 396.0 + rail, VW, 2.0), Color(0.72, 0.70, 0.66))
	for s in range(24):
		draw_rect(Rect2(float(s) * 50.0 + 6.0, 384.0, 34.0, 26.0),
			Color(0, 0, 0, 0.10))


func _draw_istiklal_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	var iron := Color(0.216, 0.208, 0.208)
	for lx in [96.0, 386.0, 676.0, 966.0]:
		CA.lamp(self, float(lx), PAVE_TOP + 34.0, 96.0, iron,
			Color(1.0, 0.867, 0.612), lit)
	for bx in [232.0, 528.0, 824.0, 1096.0]:
		CA.bollard(self, float(bx), PAVE_TOP + 30.0, iron.lightened(0.10))
	CA.bin(self, 626.0, PAVE_TOP + 30.0, Color(0.203, 0.310, 0.263))


# The side street the tower is at the top of: two returning walls in
# shade and the hill climbing away between them.
func _draw_lane_up(x: float, w: float) -> void:
	# Nearly black. At the tower's own value the two merged and the drum
	# disappeared into the wall behind it.
	var shade: Color = C_PLASTER.darkened(0.68 if GameState.is_morning() else 0.86)
	draw_rect(Rect2(x, 128.0, w, PAVE_TOP - 128.0), shade)
	for i in range(7):
		draw_rect(Rect2(x, 216.0 + float(i) * 12.0, w, 4.0),
			shade.lightened(0.10))
	draw_rect(Rect2(x, 128.0, 16.0, PAVE_TOP - 128.0), shade.darkened(0.24))
	draw_rect(Rect2(x + w - 16.0, 128.0, 16.0, PAVE_TOP - 128.0),
		shade.darkened(0.24))
	# One lamp a long way up it, which is what tells you the lane climbs.
	if not GameState.is_morning():
		for g in range(4):
			draw_circle(Vector2(x + w * 0.5, 250.0), 14.0 + float(g) * 13.0,
				Color(1.0, 0.855, 0.596, 0.055))

func _draw_pera(x: float, w: float, storeys: int, seed_i: int) -> void:
	var body: Color = [C_SUN, C_BLEACH, C_ROSE, C_PLASTER.lightened(0.24)][seed_i % 4]
	var trim: Color = C_TILE_W
	if not GameState.is_morning():
		body = body.darkened(0.48)
		trim = trim.darkened(0.44)
	var floor_h: float = 34.0
	var top: float = 236.0 - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, 236.0 - top), body)
	draw_rect(Rect2(x + w - 8.0, top, 8.0, 236.0 - top), body.darkened(0.20))
	# A heavy cornice and a string course at every floor - the European kit.
	draw_rect(Rect2(x - 6.0, top - 11.0, w + 12.0, 12.0), trim)
	draw_rect(Rect2(x - 8.0, top - 15.0, w + 16.0, 5.0), trim.lightened(0.12))
	for s in range(1, storeys):
		draw_rect(Rect2(x, 236.0 - float(s) * floor_h, w, 4.0), trim)
	var bays: int = maxi(2, int(w / 46.0))
	var step: float = w / float(bays)
	for s in range(storeys - 1):
		var wy: float = top + 15.0 + float(s) * floor_h
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 31 + s * 13) % (1 << mini(bays, 20))
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			var on: bool = ((lit >> b) & 1) == 1
			draw_rect(Rect2(bx - 12.0, wy, 24.0, 24.0),
				Color(0.98, 0.90, 0.70, 0.88) if on else C_GLASS_M)
			draw_rect(Rect2(bx - 14.0, wy - 6.0, 28.0, 5.0), trim)
			draw_rect(Rect2(bx - 13.0, wy + 24.0, 26.0, 4.0), trim)
			if s == 0:
				draw_rect(Rect2(bx - 17.0, wy + 28.0, 34.0, 2.4), C_CABLE)
				for k in range(5):
					draw_rect(Rect2(bx - 15.0 + float(k) * 7.0, wy + 28.0, 1.6, 12.0),
						C_CABLE)
				draw_rect(Rect2(bx - 17.0, wy + 40.0, 34.0, 2.4), C_CABLE)
	# The passage: an arched cut straight through the ground floor with a lit
	# arcade behind it. There are a dozen of these off Istiklal.
	if (seed_i % 3) == 0:
		var px: float = x + w * 0.5
		draw_rect(Rect2(px - 26.0, 174.0, 52.0, 62.0), C_SHADOW.darkened(0.30))
		for k in range(11):
			var u: float = float(k) / 10.0
			var dy: float = sin(u * PI) * 20.0
			draw_rect(Rect2(px - 26.0 + u * 52.0 - 3.0, 174.0 - dy, 7.0, dy + 4.0),
				C_SHADOW.darkened(0.30))
		if not GameState.is_morning():
			draw_rect(Rect2(px - 20.0, 190.0, 40.0, 46.0),
				Color(1.0, 0.86, 0.60, 0.36))


# The red tram. One car, no traffic to share the street with, and people
# hanging off the back of it.
func _draw_tram(u: float) -> void:
	var red: Color = C_BOLE
	if not GameState.is_morning():
		red = red.darkened(0.30)
	var x: float = lerpf(-200.0, VW + 200.0, u)
	var y: float = 396.0
	draw_rect(Rect2(0, y + 26.0, VW, 3.0), C_CABLE)
	draw_rect(Rect2(0, y + 40.0, VW, 3.0), C_CABLE)
	draw_rect(Rect2(x - 84.0, y - 62.0, 168.0, 88.0), red)
	draw_rect(Rect2(x - 84.0, y - 62.0, 168.0, 7.0), Color(0.94, 0.92, 0.86))
	draw_rect(Rect2(x - 84.0, y - 26.0, 168.0, 6.0), Color(0.94, 0.92, 0.86))
	for i in range(5):
		draw_rect(Rect2(x - 74.0 + float(i) * 32.0, y - 52.0, 24.0, 22.0),
			Color(0.98, 0.90, 0.70, 0.80) if not GameState.is_morning()
			else Color(0.24, 0.29, 0.31))
	draw_rect(Rect2(x - 4.0, y - 82.0, 8.0, 22.0), C_CABLE)
	draw_rect(Rect2(x - 22.0, y - 84.0, 44.0, 4.0), C_CABLE)
	draw_circle(Vector2(x - 52.0, y + 30.0), 9.0, Color(0.13, 0.12, 0.12))
	draw_circle(Vector2(x + 52.0, y + 30.0), 9.0, Color(0.13, 0.12, 0.12))


# ── Kadıköy ───────────────────────────────────────────────────────────────────
# The Asian side. Six-storey concrete blocks from the seventies with a balcony
# on every flat, the fish market under awnings, and the ferry.
#
# It is the only district in the game on a different continent from its own
# city, and the plate says so by putting the water and the far shore in it.

func _draw_kadikoy() -> void:
	# No sea. Bahariye runs inland from the pier and you cannot see the water
	# from it - a strip of Bosphorus over the roofline was a nice picture and
	# a lie, and it was squashing the buildings into warehouses to fit.
	_draw_lane_sky()
	for spec in [[-20.0, 168.0, 5], [152.0, 142.0, 4], [298.0, 176.0, 5],
			[478.0, 148.0, 4], [630.0, 170.0, 5], [804.0, 144.0, 4],
			[952.0, 180.0, 5]]:
		_draw_bahariye(float(spec[0]), float(spec[1]), int(spec[2]),
			int(spec[0]) % 6)
	_draw_bahariye_ground()
	_draw_bull(210.0)
	_draw_nostalgic_tram(fmod(_t * 0.045, 1.0))


# Pedestrianised: no kerb, no carriageway, one surface from shopfront to
# shopfront with the tram rail set into it. The ground was not being painted
# here at all, so the lower half of the district was simply void.
func _draw_bahariye_ground() -> void:
	var morning: bool = GameState.is_morning()
	var stone: Color = Color(0.541, 0.514, 0.475) if morning 		else Color(0.153, 0.145, 0.169)
	draw_rect(Rect2(0, PAVE_TOP, VW, VH - PAVE_TOP), stone)
	# laid in courses, the way a paved street is
	for r in range(12):
		var y: float = PAVE_TOP + float(r) * 30.0
		draw_rect(Rect2(0, y, VW, 1.5), stone.darkened(0.14))
		var off: float = 22.0 if r % 2 == 1 else 0.0
		for c in range(27):
			draw_rect(Rect2(off + float(c) * 44.0, y, 1.5, 30.0),
				stone.darkened(0.10))
	# the two rails, set flush
	for ry in [PAVE_TOP - 2.0, PAVE_TOP + 16.0]:
		draw_rect(Rect2(0, ry, VW, 2.5), stone.darkened(0.34))


# Painted, corniced, and no two the same colour. Art Deco and neo-classical,
# four or five storeys, shopfronts and awnings under, boutiques and bookshops
# and a bakery, and nothing above six floors.
const _BAHARIYE := [
	Color(0.867, 0.784, 0.643), Color(0.729, 0.482, 0.416),
	Color(0.596, 0.663, 0.643), Color(0.827, 0.671, 0.451),
	Color(0.643, 0.573, 0.663), Color(0.788, 0.831, 0.796),
]


func _draw_bahariye(x: float, w: float, storeys: int, seed_i: int) -> void:
	var morning: bool = GameState.is_morning()
	var face: Color = _BAHARIYE[seed_i % _BAHARIYE.size()]
	if not morning:
		face = face.darkened(0.58)
	# The shopfront band is 52 deep and the floors sit ON it, rather than
	# being drawn over the top of it and losing two thirds of their height.
	var shop_top: float = PAVE_TOP - 52.0
	var top: float = shop_top - float(storeys) * 36.0
	draw_rect(Rect2(x, top, w, shop_top - top), face)
	# cornice at the parapet, and a moulded band at every floor
	draw_rect(Rect2(x - 4.0, top - 7.0, w + 8.0, 8.0), face.darkened(0.22))
	draw_rect(Rect2(x - 2.0, top - 11.0, w + 4.0, 4.0), face.lightened(0.12))
	for f in range(storeys):
		var fy: float = top + 9.0 + float(f) * 36.0
		draw_rect(Rect2(x, fy + 27.0, w, 2.5), face.darkened(0.16))
		var cols: int = maxi(2, int(w / 40.0))
		for c in range(cols):
			var wx: float = x + 10.0 + float(c) * (w - 20.0) / float(cols)
			var lit: bool = not morning and ((c + f + seed_i) % 3 != 0)
			# tall shuttered windows, and a sill under each
			draw_rect(Rect2(wx - 2.0, fy - 2.0, 22.0, 26.0), face.darkened(0.18))
			draw_rect(Rect2(wx, fy, 18.0, 22.0),
				Color(0.937, 0.855, 0.612) if lit else Color(0.259, 0.286, 0.325))
			draw_rect(Rect2(wx + 8.0, fy, 2.0, 22.0), face.darkened(0.34))
			draw_rect(Rect2(wx - 3.0, fy + 24.0, 24.0, 3.0), face.darkened(0.26))
			# a balcony on the first floor, which this street is full of
			if f == 1:
				draw_rect(Rect2(wx - 6.0, fy + 24.0, 30.0, 3.0), face.darkened(0.30))
				for b in range(6):
					draw_rect(Rect2(wx - 5.0 + float(b) * 5.0, fy + 27.0, 1.5, 8.0),
						face.darkened(0.36))
	# the shops: separate units, each with its own awning and its own light
	var units: int = maxi(2, int(w / 62.0))
	var uw: float = w / float(units)
	for u in range(units):
		var ux: float = x + float(u) * uw
		draw_rect(Rect2(ux + 1.0, shop_top, uw - 2.0, 52.0), face.darkened(0.34))
		# A shop window is darker than the street and it is not a hole: there
		# is a lit interior behind it and a reflection of the sky on it.
		var glass: Color = Color(0.961, 0.902, 0.706) if not morning 			else Color(0.427, 0.451, 0.478)
		draw_rect(Rect2(ux + 5.0, shop_top + 12.0, uw - 10.0, 34.0), glass)
		if morning:
			draw_rect(Rect2(ux + 5.0, shop_top + 12.0, uw - 10.0, 9.0),
				Color(0.573, 0.616, 0.647))
			draw_rect(Rect2(ux + 9.0, shop_top + 30.0, uw - 18.0, 14.0),
				Color(0.686, 0.573, 0.400))
		# the sign over the window
		draw_rect(Rect2(ux + 3.0, shop_top + 2.0, uw - 6.0, 9.0),
			face.darkened(0.48))
		var aw: Color = [Color(0.667, 0.267, 0.243), Color(0.235, 0.416, 0.369),
			Color(0.294, 0.345, 0.510), Color(0.784, 0.588, 0.208)][(u + seed_i) % 4]
		if not morning:
			aw = aw.darkened(0.42)
		# a scalloped awning, which every one of these has
		draw_rect(Rect2(ux + 2.0, shop_top - 9.0, uw - 4.0, 9.0), aw)
		for k in range(int(uw / 9.0)):
			draw_circle(Vector2(ux + 6.0 + float(k) * 9.0, shop_top), 4.0, aw)


# The bronze bull at Altiyol. Kadikoy's meeting place - people say "at the
# bull" the way Londoners say "under the clock", and it is the centre of the
# neighbourhood's universe.
func _draw_bull(x: float) -> void:
	var bronze: Color = Color(0.310, 0.271, 0.196) if GameState.is_morning() 		else Color(0.176, 0.153, 0.129)
	var lit: Color = bronze.lightened(0.22)
	var base: float = 292.0
	# plinth
	draw_rect(Rect2(x - 26.0, base - 14.0, 52.0, 14.0), Color(0.365, 0.353, 0.337))
	draw_rect(Rect2(x - 29.0, base - 17.0, 58.0, 4.0), Color(0.416, 0.404, 0.388))
	# body, heavy and low
	draw_rect(Rect2(x - 22.0, base - 44.0, 42.0, 24.0), bronze)
	draw_rect(Rect2(x - 22.0, base - 44.0, 42.0, 6.0), lit)
	# legs
	for lx in [-18.0, -6.0, 6.0, 15.0]:
		draw_rect(Rect2(x + lx, base - 21.0, 5.0, 21.0), bronze)
	# head, down, and the horns
	draw_rect(Rect2(x - 34.0, base - 42.0, 15.0, 17.0), bronze)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 34.0, base - 42.0), Vector2(x - 41.0, base - 50.0),
		Vector2(x - 33.0, base - 46.0),
	]), lit)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 22.0, base - 42.0), Vector2(x - 17.0, base - 51.0),
		Vector2(x - 21.0, base - 45.0),
	]), lit)
	draw_rect(Rect2(x + 18.0, base - 43.0, 4.0, 14.0), bronze)   # tail


# The T3, red and wooden, running the length of Bahariye up to Moda and back.
# It is the single most identifiable thing on this street.
func _draw_nostalgic_tram(u: float) -> void:
	var x: float = lerpf(-220.0, VW + 220.0, u)
	var body: Color = Color(0.647, 0.184, 0.176)
	var trim: Color = Color(0.914, 0.878, 0.808)
	if not GameState.is_morning():
		body = body.darkened(0.34)
		trim = trim.darkened(0.44)
	var base: float = 292.0
	# the rail it runs on, all the way along
	draw_rect(Rect2(0, base - 2.0, VW, 2.0), Color(0.318, 0.298, 0.286))
	draw_rect(Rect2(x - 76.0, base - 62.0, 152.0, 60.0), body)
	draw_rect(Rect2(x - 76.0, base - 62.0, 152.0, 7.0), trim)
	draw_rect(Rect2(x - 76.0, base - 20.0, 152.0, 5.0), trim)
	for i in range(5):
		draw_rect(Rect2(x - 66.0 + float(i) * 27.0, base - 52.0, 20.0, 26.0),
			Color(0.933, 0.878, 0.663) if not GameState.is_morning()
			else Color(0.478, 0.588, 0.612))
	draw_rect(Rect2(x - 52.0, base - 8.0, 14.0, 8.0), Color(0.180, 0.176, 0.176))
	draw_rect(Rect2(x + 38.0, base - 8.0, 14.0, 8.0), Color(0.180, 0.176, 0.176))
	# the pole and the wire it takes its power off
	draw_rect(Rect2(x - 2.0, base - 92.0, 3.0, 31.0), Color(0.278, 0.267, 0.267))
	draw_rect(Rect2(0, base - 94.0, VW, 1.5), Color(0.278, 0.267, 0.267, 0.75))


func _draw_apartment(x: float, w: float, storeys: int, seed_i: int) -> void:
	var body: Color = C_CONCRETE if (seed_i % 2) else C_CONC_LT
	if not GameState.is_morning():
		body = body.darkened(0.48)
	var floor_h: float = 30.0
	var top: float = 236.0 - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, 236.0 - top), body)
	draw_rect(Rect2(x + w - 9.0, top, 9.0, 236.0 - top), C_CONC_DK)
	draw_rect(Rect2(x - 4.0, top - 8.0, w + 8.0, 9.0), C_CONC_LT)
	for s in range(storeys - 1):
		var wy: float = top + 12.0 + float(s) * floor_h
		var bays: int = maxi(2, int(w / 50.0))
		var step: float = w / float(bays)
		for b in range(bays):
			var bx: float = x + step * (float(b) + 0.5)
			var on: bool = not GameState.is_morning() \
				and ((seed_i * 13 + s * 5 + b) % 3) == 0
			draw_rect(Rect2(bx - 14.0, wy, 28.0, 18.0),
				Color(0.98, 0.90, 0.70, 0.85) if on else C_GLASS_M)
			draw_rect(Rect2(bx - 15.0, wy - 2.0, 30.0, 2.4), C_ALU)
			# A balcony on every flat, and something on most of them.
			draw_rect(Rect2(bx - 18.0, wy + 18.0, 36.0, 4.0), body.lightened(0.12))
			for k in range(5):
				draw_rect(Rect2(bx - 16.0 + float(k) * 8.0, wy + 22.0, 1.8, 8.0),
					C_ALU)
			if ((seed_i + s + b) % 3) == 0:
				draw_rect(Rect2(bx - 12.0, wy + 21.0, 9.0, 9.0),
					C_TURQ if GameState.is_morning() else C_TURQ.darkened(0.40))
			if s == 0 and (b % 2) == 0:
				draw_circle(Vector2(bx + 15.0, wy + 8.0), 6.0, C_ALU)
	draw_rect(Rect2(x + w * 0.5 - 12.0, top - 22.0, 24.0, 15.0), C_ALU.darkened(0.20))


func _draw_ferry(u: float, water: Color) -> void:
	var hull: Color = Color(0.878, 0.867, 0.839)
	if not GameState.is_morning():
		hull = hull.darkened(0.46)
	var x: float = lerpf(VW + 160.0, -160.0, u)
	var y: float = 198.0
	draw_rect(Rect2(x - 62.0, y - 12.0, 124.0, 16.0), hull)
	draw_rect(Rect2(x - 44.0, y - 26.0, 88.0, 15.0), hull.darkened(0.10))
	draw_rect(Rect2(x - 30.0, y - 36.0, 34.0, 11.0), hull.darkened(0.18))
	draw_rect(Rect2(x + 14.0, y - 44.0, 7.0, 19.0), Color(0.78, 0.27, 0.23))
	for i in range(7):
		draw_rect(Rect2(x - 52.0 + float(i) * 15.0, y - 22.0, 8.0, 7.0),
			Color(0.24, 0.29, 0.31) if GameState.is_morning()
			else Color(0.98, 0.90, 0.70, 0.80))
	draw_rect(Rect2(x - 74.0, y + 4.0, 148.0, 4.0),
		Color(water.r, water.g, water.b, 0.55))


# What blocks you. In the lane it is the shopfronts and the stalls; in the han
# it is the fountain, the tree and the arcade piers. The cats do not block —
# they move when you get close, which is the only accurate thing to do.
func solids() -> Array:
	var out: Array = []
	if district == "han":
		out.append(Rect2(502.0, 396.0, 148.0, 60.0))          # şadırvan
		out.append(Rect2(186.0, 452.0, 92.0, 34.0))           # tree kerb
		for i in range(8):
			var span: float = VW / 8.0
			out.append(Rect2(span * float(i), 340.0, 22.0, 56.0))   # arcade piers
		return out
	for i in range(_HOUSES.size()):
		var h: Array = _HOUSES[i]
		out.append(Rect2(float(h[0]), PAVE_TOP - 30.0, float(h[1]), 34.0))
	for i in range(4):
		var x: float = 40.0 + float(i) * 300.0
		out.append(Rect2(x + 92.0, 296.0, 90.0, 32.0))        # crate stacks
	out.append(Rect2(498.0, PAVE_TOP - 34.0, 124.0, 38.0))    # the han gate reveal
	return out


func _wall_colour(i: int) -> Color:
	# Never uniform. Every house a different colour, every colour sun-bleached
	# on one side and not the other.
	match i % 5:
		0: return C_SUN
		1: return C_ROSE
		2: return C_PLASTER
		3: return C_MINT
		_: return C_PALEBLUE


# ══ The market lane ═══════════════════════════════════════════════════════════

func _draw_carsi() -> void:
	_draw_lane_sky()
	# NOT the sixties concrete. Everywhere else in this city that observation
	# is right and the blocks tower over the old fabric - but not here. The
	# ground around the Kapalicarsi is protected: what stands over this lane
	# is the bazaar's OWN roof, sixty-odd lead domes in a field, with the
	# Beyazit fire tower behind them and no high-rise for a kilometre.
	_draw_bazaar_roofs()
	# On the third hill, straight up behind the lane. Galata is across the
	# Golden Horn and does not belong in this quarter's sky.
	_draw_suleymaniye(430.0)
	_draw_houses()
	_draw_doors(236.0, PAVE_TOP, C_SIGNBOX, Color(0.129, 0.106, 0.086), C_TURQ, C_GLASS_M)
	_draw_stepped_ground()
	_draw_stalls()
	_draw_overhead_net()
	_draw_han_gate(560.0)


# There is very little sky here and what there is arrives warm — the opposite
# of London, where the sky is a closed grey lid.
func _draw_lane_sky() -> void:
	var morning: bool = GameState.is_morning()
	if morning:
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.612, 0.678, 0.706))
		draw_rect(Rect2(0, 120, VW, 172), Color(0.788, 0.741, 0.647))
	else:
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.196, 0.153, 0.180))
		draw_rect(Rect2(0, 90, VW, 130), Color(0.318, 0.208, 0.204))
		draw_rect(Rect2(0, 190, VW, 102), Color(0.463, 0.271, 0.212))


# ── The modern city ───────────────────────────────────────────────────────────
# Six- and seven-storey yap-sat blocks from the sixties and seventies: concrete
# frame, continuous balconies, aluminium windows, a water tank and a forest of
# satellite dishes on the roof. They stand behind and above the timber houses,
# because that is the actual relationship — the old lane survives in the gaps
# between them, not the other way round.

const _BLOCKS := [
	[-60, 210, 6], [190, 176, 7], [400, 194, 5],
	[620, 182, 7], [830, 200, 6], [1040, 190, 7],
]


# The roofscape of the Grand Bazaar: lead-grey domes, each with a small
# lantern on top, packed edge to edge over sixty-one streets. Behind them the
# Beyazit Tower - white, fluted, a fire-watch tower on the third hill.
func _draw_bazaar_roofs() -> void:
	var morning: bool = GameState.is_morning()
	var lead: Color = Color(0.443, 0.463, 0.478) if morning 		else Color(0.180, 0.169, 0.196)
	var lit: Color = lead.lightened(0.16)
	var dark: Color = lead.darkened(0.28)
	# Two ranks, the far one smaller and paler, so the roof has depth in it.
	for rank in range(2):
		var base: float = 214.0 - float(rank) * 22.0
		var r: float = 34.0 - float(rank) * 7.0
		var step: float = r * 1.72
		var col: Color = lead if rank == 0 else lead.lightened(0.10)
		var x: float = -20.0 + float(rank) * 26.0
		while x < VW + 40.0:
			# the dome
			draw_circle(Vector2(x, base), r, col)
			draw_rect(Rect2(x - r, base, r * 2.0, r * 0.55), col)
			# the light down its left side, the way lead takes the sun
			draw_circle(Vector2(x - r * 0.30, base - r * 0.28), r * 0.46,
				col.lightened(0.10) if rank == 0 else col)
			# the lantern on top
			draw_rect(Rect2(x - 2.5, base - r - 9.0, 5.0, 9.0), dark)
			draw_rect(Rect2(x - 4.0, base - r - 11.5, 8.0, 2.5), lit)
			x += step
	# Beyazit Tower, on the hill behind the whole field of them.
	var tw: Color = Color(0.855, 0.831, 0.780) if morning 		else Color(0.298, 0.267, 0.290)
	var tx: float = 250.0
	draw_rect(Rect2(tx - 13.0, 96.0, 26.0, 96.0), tw)
	draw_rect(Rect2(tx - 16.0, 92.0, 32.0, 7.0), tw.darkened(0.14))
	draw_rect(Rect2(tx - 9.0, 66.0, 18.0, 28.0), tw)
	draw_rect(Rect2(tx - 11.0, 62.0, 22.0, 5.0), tw.darkened(0.14))
	draw_colored_polygon(PackedVector2Array([
		Vector2(tx - 9.0, 62.0), Vector2(tx, 42.0), Vector2(tx + 9.0, 62.0),
	]), tw.darkened(0.22))
	for i in range(4):
		draw_rect(Rect2(tx - 10.0 + float(i) * 6.0, 108.0, 2.0, 74.0),
			tw.darkened(0.10))


func _draw_modern_blocks() -> void:
	for i in range(_BLOCKS.size()):
		var b: Array = _BLOCKS[i]
		_draw_block(float(b[0]), float(b[1]), int(b[2]), i)


func _draw_block(x: float, w: float, storeys: int, seed_i: int) -> void:
	var floor_h: float = 30.0
	var top: float = 214.0 - float(storeys) * floor_h
	var body: Color = C_CONCRETE if seed_i % 3 != 1 else C_CONCRETE.darkened(0.10)

	draw_rect(Rect2(x, top, w, 214.0 - top), body)
	draw_rect(Rect2(x, top, w, 5.0), C_CONC_LT)              # parapet catches sun
	draw_rect(Rect2(x + w - 14.0, top, 14.0, 214.0 - top), C_CONC_DK)

	# Continuous balconies — the defining horizontal of every Turkish apartment
	for s in range(storeys):
		var by: float = top + 12.0 + float(s) * floor_h
		draw_rect(Rect2(x + 6.0, by, w - 12.0, 15.0), C_CONC_DK)
		draw_rect(Rect2(x + 6.0, by, w - 12.0, 3.0), C_CONC_LT)
		# Glazed-in balcony on some floors, open on others
		if (seed_i + s) % 3 == 0:
			draw_rect(Rect2(x + 10.0, by - 15.0, w - 20.0, 15.0), C_GLASS_M)
			for g in range(int((w - 20.0) / 26.0)):
				draw_rect(Rect2(x + 10.0 + float(g) * 26.0, by - 15.0, 2.0, 15.0), C_ALU)
		else:
			for r in range(int((w - 20.0) / 9.0)):
				draw_rect(Rect2(x + 12.0 + float(r) * 9.0, by - 11.0, 2.0, 11.0), C_ALU)
			# Washing, an aircon box, a satellite dish — the balcony is storage
			if s % 2 == 0:
				draw_rect(Rect2(x + w - 46.0, by - 13.0, 18.0, 13.0), C_ALU)
			else:
				draw_circle(Vector2(x + 24.0, by - 8.0), 7.0, C_ALU.lightened(0.15))
				draw_rect(Rect2(x + 23.0, by - 9.0, 2.0, 9.0), C_CABLE)

	# Roof: water tanks and the dish farm
	for d in range(3):
		var dx: float = x + 20.0 + float(d) * (w / 3.2)
		draw_rect(Rect2(dx, top - 13.0, 20.0, 13.0), C_ALU.darkened(0.20))
		draw_circle(Vector2(dx + 26.0, top - 8.0), 6.0, C_ALU)
	draw_rect(Rect2(x + w * 0.5 - 3.0, top - 34.0, 3.0, 34.0), C_CABLE)


# ── Shopfronts ────────────────────────────────────────────────────────────────
# Backlit plastic fascia boards, one per shop, too bright and slightly too big.
# They are the loudest thing at eye level in any Istanbul street and the alien
# can see every letter of them.

const SHOP_SIGNS := ["ECZANE", "MARKET", "KUAFÖR", "BÜFE", "DÖVİZ", "LOKANTA"]
const SHOP_SIGN_HUES := [
	Color(0.122, 0.478, 0.353), Color(0.784, 0.271, 0.227),
	Color(0.110, 0.224, 0.659), Color(0.847, 0.573, 0.145),
	Color(0.122, 0.478, 0.353), Color(0.643, 0.176, 0.322),
]


func _draw_houses() -> void:
	for i in range(_HOUSES.size()):
		var h: Array = _HOUSES[i]
		_draw_house(float(h[0]), float(h[1]), int(h[2]), int(h[3]), i)
	# Cumbas last, so they overhang everything including their neighbours
	for i in range(_HOUSES.size()):
		var h2: Array = _HOUSES[i]
		if i % 2 == 0:
			_draw_cumba(float(h2[0]) + float(h2[1]) * 0.5, 118.0 + float(i % 3) * 14.0, i)


func _draw_house(x: float, w: float, storeys: int, ci: int, seed_i: int) -> void:
	var wall: Color = _wall_colour(ci)
	var top: float = 96.0 + float(seed_i % 3) * 12.0

	# Pantile roof — every course shadowed underneath
	draw_rect(Rect2(x - 8.0, top - 20.0, w + 16.0, 22.0), C_TERRA)
	for c in range(int(w / 18.0) + 1):
		draw_rect(Rect2(x - 8.0 + float(c) * 18.0, top - 20.0, 3.0, 22.0), C_ROOF_SH)
	draw_rect(Rect2(x - 8.0, top + 1.0, w + 16.0, 4.0), C_ROOF_SH)

	# Timber above, plaster below — the horizontal Istanbul has and the others don't
	var split: float = PAVE_TOP - 96.0
	draw_rect(Rect2(x, top, w, split - top), wall)
	draw_rect(Rect2(x, split, w, PAVE_TOP - split), C_PLASTER.darkened(0.10))
	draw_rect(Rect2(x, split, w, 5.0), C_TIMB_DK)

	# Sun sits on one side only
	draw_rect(Rect2(x, top, 14.0, split - top), Color(1, 1, 1, 0.07))
	draw_rect(Rect2(x + w - 12.0, top, 12.0, split - top), Color(0, 0, 0, 0.13))

	# Shutters, and small shallow ironwork with things living on it
	for s in range(int(storeys)):
		var sy: float = top + 26.0 + float(s) * 54.0
		if sy > split - 40.0:
			break
		for c2 in range(2):
			var sx: float = x + 26.0 + float(c2) * (w - 74.0)
			draw_rect(Rect2(sx, sy, 40, 44), C_SHADOW)
			draw_rect(Rect2(sx, sy, 18, 44), C_PALEBLUE.darkened(0.15))
			draw_rect(Rect2(sx + 22.0, sy, 18, 44), C_PALEBLUE.darkened(0.15))
			draw_rect(Rect2(sx - 6.0, sy + 44.0, 52, 5), C_TIMB_DK)
			for b in range(7):
				draw_rect(Rect2(sx - 4.0 + float(b) * 8.0, sy + 46.0, 2, 14), C_CABLE)


# The cumba. Closed timber bay on brackets, projecting out over the lane.
# This is the silhouette that says Istanbul and nothing else.
func _draw_cumba(cx: float, y: float, seed_i: int) -> void:
	var w: float = 104.0
	var h: float = 74.0
	var proj: float = 26.0
	var body: Color = _wall_colour(seed_i + 1)
	# Brackets underneath, carrying it
	for b in range(3):
		var bx: float = cx - w * 0.5 + 12.0 + float(b) * (w * 0.5 - 12.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, y + h), Vector2(bx + 16.0, y + h),
			Vector2(bx + 4.0, y + h + 24.0),
		]), C_TIMB_DK)
	draw_rect(Rect2(cx - w * 0.5, y, w, h), body)
	draw_rect(Rect2(cx - w * 0.5, y, w, 4.0), C_TIMB_DK)
	draw_rect(Rect2(cx - w * 0.5, y + h - 5.0, w, 5.0), C_TIMB_DK)
	# It leans out, so its underside is always in shadow
	draw_rect(Rect2(cx - w * 0.5, y + h, w, proj * 0.4), Color(0, 0, 0, 0.22))
	# Three lights across the front, the middle one taller
	for p in range(3):
		var px: float = cx - w * 0.5 + 12.0 + float(p) * 32.0
		var ph: float = 44.0 if p == 1 else 36.0
		draw_rect(Rect2(px, y + 14.0, 24, ph), C_TIMB_DK)
		var lit: bool = ((seed_i * 5 + p) % 4) < 2
		var glass: Color = Color(0.98, 0.85, 0.58, 0.85) if lit else Color(0.13, 0.12, 0.15)
		draw_rect(Rect2(px + 3.0, y + 17.0, 18, ph - 6.0), glass)


# The ground is never level. Draw it as a stair, not a plane.
func _draw_stepped_ground() -> void:
	# Tarmac, patched and re-patched, with granite kerbs at the step edges.
	# Not sand — this is a working street in a city of sixteen million, and
	# the steps are there because the hill is, not because it is a bazaar.
	var risers := [PAVE_TOP, 348.0, 404.0, MID, 528.0, 592.0]
	for i in range(risers.size()):
		var y: float = float(risers[i])
		var next_y: float = float(risers[i + 1]) if i + 1 < risers.size() else VH
		var tone: float = 0.04 * float(i % 2)
		draw_rect(Rect2(0, y, VW, next_y - y), C_ASPHALT.lightened(0.06 + tone))
		# Granite nosing on the step, and the shadow it throws
		draw_rect(Rect2(0, y, VW, 6.0), C_CONC_LT.darkened(0.10))
		draw_rect(Rect2(0, y + 6.0, VW, 5.0), Color(0, 0, 0, 0.26))
		# Patched tarmac: irregular repairs, no grid
		for p in range(4):
			var px: float = float(((i * 7 + p * 13) * 91) % 1000)
			var pw: float = 90.0 + float((p * 37) % 120)
			draw_rect(Rect2(px, y + 14.0, pw, maxf(next_y - y - 20.0, 4.0)),
				Color(0, 0, 0, 0.07))
		# A drain, because a stepped street has to move water
		if i == 2:
			draw_rect(Rect2(890, y + 16.0, 46.0, 16.0), C_CABLE.darkened(0.20))
			for g in range(4):
				draw_rect(Rect2(894.0 + float(g) * 11.0, y + 18.0, 5.0, 12.0),
					Color(0.05, 0.05, 0.06))


func _draw_stalls() -> void:
	# Awnings cantilevered from both sides, and a plastic stool under each
	for i in range(4):
		var x: float = 40.0 + float(i) * 300.0
		_draw_awning(x, 236.0, 210.0, i)
		draw_rect(Rect2(x + 30.0, 330, 44, 8), C_BOLE.darkened(0.20))
		for l in range(4):
			draw_rect(Rect2(x + 32.0 + float(l % 2) * 36.0, 338,
				5, 22), C_BOLE.darkened(0.35))
		# Crates, and produce as İznik-bright dots because that is where
		# saturation is allowed to live
		draw_rect(Rect2(x + 96.0, 302, 82, 40), C_TIMBER)
		for d in range(9):
			draw_circle(Vector2(x + 104.0 + float(d % 5) * 17.0,
				310.0 + float(d / 5) * 15.0), 6.0,
				PRODUCE_HUES[d % PRODUCE_HUES.size()])


func _draw_awning(x: float, y: float, w: float, seed_i: int) -> void:
	var stripe_a: Color = AWNING_STRIPES[seed_i % AWNING_STRIPES.size()]
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, y), Vector2(x + w, y),
		Vector2(x + w - 14.0, y + 46.0), Vector2(x + 14.0, y + 46.0),
	]), C_TILE_W)
	var bands: int = int(w / 26.0)
	for b in range(bands):
		if b % 2 == 1:
			continue
		var bx: float = x + 14.0 + float(b) * 26.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, y), Vector2(bx + 20.0, y),
			Vector2(bx + 17.0, y + 46.0), Vector2(bx - 3.0, y + 46.0),
		]), stripe_a)
	draw_rect(Rect2(x + 10.0, y + 44.0, w - 20.0, 5.0), C_TIMB_DK)
	# Everything under an awning is in the warm dark
	draw_rect(Rect2(x + 14.0, y + 49.0, w - 28.0, 30.0), Color(0, 0, 0, 0.20))


# The sky is netted: cable pole to pole, laundry between balconies, string
# lights nobody has taken down. Draw it last so it crosses everything.
func _draw_overhead_net() -> void:
	# Kept above y=190 so the cables cross the sky and the upper storeys, not
	# the illuminated shop signs — a net drawn over the fascias read as clutter
	# rather than as wiring.
	var lines := [
		[0.0, 62.0, VW, 96.0], [0.0, 108.0, VW, 78.0],
		[0.0, 44.0, VW, 132.0], [0.0, 138.0, VW, 112.0],
	]
	for i in range(lines.size()):
		var l: Array = lines[i]
		var x0: float = float(l[0])
		var y0: float = float(l[1])
		var x1: float = float(l[2])
		var y1: float = float(l[3])
		var sag: float = 26.0 + float(i % 3) * 10.0
		_draw_sagging(x0, y0, x1, y1, sag, C_CABLE)

	# Laundry, on the second line, because somebody lives above the shop
	for i in range(6):
		var lx: float = 130.0 + float(i) * 158.0
		var ly: float = 150.0 + sin(float(i) * 1.3) * 14.0
		var col: Color = LAUNDRY_HUES[i % LAUNDRY_HUES.size()]
		var sway: float = sin(_t * 0.7 + float(i)) * 3.0
		draw_rect(Rect2(lx + sway, ly, 40, 54), col)
		draw_rect(Rect2(lx + sway, ly, 40, 4), Color(0, 0, 0, 0.18))

	# String lights, warm, and only at dusk
	if not GameState.is_morning():
		for i in range(26):
			var bx: float = 20.0 + float(i) * 44.0
			var by: float = 92.0 + sin(float(i) * 0.55) * 22.0 + 20.0
			var pulse: float = 0.7 + 0.3 * sin(_t * 1.4 + float(i) * 0.6)
			draw_circle(Vector2(bx, by), 12.0, Color(0.99, 0.80, 0.45, 0.05 * pulse))
			draw_circle(Vector2(bx, by), 2.6, Color(1.0, 0.88, 0.60, pulse))


func _draw_sagging(x0: float, y0: float, x1: float, y1: float,
		sag: float, col: Color) -> void:
	var steps: int = 22
	var prev: Vector2 = Vector2(x0, y0)
	for s in range(1, steps + 1):
		var u: float = float(s) / float(steps)
		var p: Vector2 = Vector2(
			lerpf(x0, x1, u),
			lerpf(y0, y1, u) + sin(u * PI) * sag)
		draw_line(prev, p, col, 1.8)
		prev = p


# The way in. Deliberately unremarkable — a studded timber door in a stone
# arch, and nothing about it announces the courtyard behind.
func _draw_han_gate(x: float) -> void:
	draw_rect(Rect2(x - 62.0, 150, 124, PAVE_TOP - 150.0), C_PLASTER.darkened(0.18))
	# Voussoirs round the arch
	for a in range(11):
		var ang: float = PI + float(a) * PI / 10.0
		var px: float = x + cos(ang) * 56.0
		var py: float = 196.0 + sin(ang) * 56.0
		draw_rect(Rect2(px - 9.0, py - 9.0, 18, 18), C_BLEACH.darkened(0.10))
	draw_circle(Vector2(x, 196), 46.0, C_SHADOW)
	draw_rect(Rect2(x - 46.0, 196, 92, PAVE_TOP - 196.0), C_SHADOW)
	# The doors themselves, studded, one leaf standing open on the dark
	draw_rect(Rect2(x - 44.0, 172, 40, PAVE_TOP - 172.0), C_TIMB_DK)
	for r in range(6):
		for c in range(3):
			draw_circle(Vector2(x - 38.0 + float(c) * 13.0,
				186.0 + float(r) * 17.0), 2.2, C_CABLE.lightened(0.25))
	draw_rect(Rect2(x + 4.0, 172, 40, PAVE_TOP - 172.0), Color(0.09, 0.07, 0.08))



func _draw_han() -> void:
	_draw_open_sky()
	_draw_arcade()
	_draw_courtyard_ground()
	_draw_sadirvan(576.0, 452.0)
	_draw_courtyard_tree(232.0)
	_draw_yusuf_door(846.0)


# The only open sky in Istanbul, because the courtyard is a hole punched up
# through the city.
func _draw_open_sky() -> void:
	var morning: bool = GameState.is_morning()
	var sky: Color = Color(0.612, 0.729, 0.784) if morning else Color(0.271, 0.208, 0.267)
	draw_rect(Rect2(0, 0, VW, 170), sky)
	if morning:
		draw_rect(Rect2(0, 96, VW, 74), Color(0.788, 0.788, 0.729))
	else:
		draw_rect(Rect2(0, 92, VW, 78), Color(0.478, 0.294, 0.243))
		for i in range(14):
			draw_circle(Vector2(70.0 + float(i) * 78.0,
				30.0 + sin(float(i) * 2.1) * 18.0), 1.4,
				Color(1, 0.96, 0.86, 0.55))


# Two storeys of porticoed gallery on stone piers, running all the way round.
func _draw_arcade() -> void:
	# Upper gallery
	draw_rect(Rect2(0, 170, VW, 96), C_BLEACH.darkened(0.12))
	_draw_arches(186.0, 62.0, 8, C_SHADOW)
	draw_rect(Rect2(0, 262, VW, 12), C_PLASTER.darkened(0.22))
	# The gallery rail, and the shade behind it
	for i in range(38):
		draw_rect(Rect2(6.0 + float(i) * 30.0, 236, 4, 26), C_TIMB_DK)

	# Lower arcade — deeper shade; the workshops are under here
	draw_rect(Rect2(0, 274, VW, 118), C_BLEACH.darkened(0.20))
	_draw_arches(292.0, 76.0, 8, C_SHADOW.darkened(0.20))
	draw_rect(Rect2(0, 388, VW, 8), C_PLASTER.darkened(0.30))


func _draw_arches(y: float, h: float, count: int, void_col: Color) -> void:
	var span: float = VW / float(count)
	for i in range(count):
		var cx: float = span * (float(i) + 0.5)
		var r: float = span * 0.34
		# Pier
		draw_rect(Rect2(cx - span * 0.5, y - 6.0, 22, h + 10.0), C_BLEACH.darkened(0.30))
		# The opening: a half-round on a square, which is the whole grammar
		draw_circle(Vector2(cx, y + r), r, void_col)
		draw_rect(Rect2(cx - r, y + r, r * 2.0, h - r), void_col)
		# Voussoir ring
		for a in range(9):
			var ang: float = PI + float(a) * PI / 8.0
			draw_rect(Rect2(cx + cos(ang) * (r + 5.0) - 4.0,
				y + r + sin(ang) * (r + 5.0) - 4.0, 8, 8), C_BLEACH)


func _draw_courtyard_ground() -> void:
	draw_rect(Rect2(0, 396, VW, VH - 396.0), C_SUN.darkened(0.08))
	# Big flagstones, not the lane's cobble — the han was built, not accreted
	for r in range(5):
		for c in range(11):
			var fx: float = -20.0 + float(c) * 108.0 + (54.0 if r % 2 == 1 else 0.0)
			var fy: float = 400.0 + float(r) * 52.0
			draw_rect(Rect2(fx, fy, 104, 48), C_SUN.lightened(0.04 * float((r + c) % 3)))
			draw_rect(Rect2(fx, fy, 104, 1.5), Color(0, 0, 0, 0.10))
			draw_rect(Rect2(fx, fy, 1.5, 48), Color(0, 0, 0, 0.10))
	# The arcade throws a hard edge of shade across the near flagstones
	draw_rect(Rect2(0, 396, VW, 26), Color(0, 0, 0, 0.16))


# The şadırvan. Running water, in the middle, and it is the only sound.
func _draw_sadirvan(x: float, y: float) -> void:
	draw_circle(Vector2(x, y + 6.0), 74.0, Color(0, 0, 0, 0.14))
	draw_circle(Vector2(x, y), 72.0, C_BLEACH.darkened(0.16))
	draw_circle(Vector2(x, y), 62.0, C_TURQ.darkened(0.35))
	draw_circle(Vector2(x, y), 54.0, C_TURQ.darkened(0.12))
	# İznik ring — saturation is allowed here, because this is tile
	for i in range(16):
		var a: float = float(i) * TAU / 16.0
		draw_circle(Vector2(x + cos(a) * 64.0, y + sin(a) * 64.0), 5.0,
			C_COBALT if i % 2 == 0 else C_TILE_W)
	# The column, and the water coming off it
	draw_rect(Rect2(x - 13.0, y - 76.0, 26, 78), C_BLEACH.darkened(0.06))
	draw_rect(Rect2(x - 18.0, y - 84.0, 36, 12), C_BLEACH)
	var t: float = fmod(_t * 0.9, 1.0)
	for s in range(3):
		var sy: float = y - 68.0 + fmod(t + float(s) * 0.33, 1.0) * 62.0
		draw_rect(Rect2(x - 2.0, sy, 4, 12), Color(0.78, 0.92, 0.94, 0.60))
	draw_circle(Vector2(x, y + 2.0), 16.0 + sin(_t * 2.2) * 2.0,
		Color(1, 1, 1, 0.10))


func _draw_courtyard_tree(x: float) -> void:
	draw_rect(Rect2(x - 46.0, 470, 92, 26), C_BLEACH.darkened(0.24))
	draw_rect(Rect2(x - 40.0, 462, 80, 12), C_PLASTER.darkened(0.20))
	draw_rect(Rect2(x - 11.0, 300, 22, 168), C_TIMB_DK)
	var leaf: Color = Color(0.180, 0.259, 0.196)
	if GameState.is_morning():
		leaf = Color(0.286, 0.404, 0.259)
	draw_circle(Vector2(x, 268), 78.0, leaf)
	draw_circle(Vector2(x - 52.0, 300), 46.0, leaf)
	draw_circle(Vector2(x + 50.0, 296), 48.0, leaf)
	# Dapple on the flagstones underneath
	for i in range(9):
		draw_circle(Vector2(x - 60.0 + float(i) * 16.0,
			500.0 + sin(float(i) * 1.7) * 18.0), 11.0, Color(0, 0, 0, 0.05))


# Yusuf's door, under the arcade. Above it, on a cord between two blue glass
# eyes, the bright fragment — hung there four years ago by a brother who
# thought it was pretty and drilled a hole through it.
func _draw_yusuf_door(x: float) -> void:
	draw_rect(Rect2(x - 56.0, 300, 112, 92), C_SHADOW.darkened(0.30))
	draw_rect(Rect2(x - 44.0, 316, 88, 76), C_TIMB_DK)
	for i in range(4):
		draw_rect(Rect2(x - 40.0 + float(i) * 22.0, 320, 16, 68),
			C_TIMBER.darkened(0.10))
	# Stacked bowls in the doorway, İznik-bright because they are ceramic
	for i in range(5):
		var by: float = 372.0 - float(i) * 7.0
		draw_rect(Rect2(x + 58.0, by, 34, 7),
			C_TILE_W if i % 2 == 0 else C_COBALT)
	# The cord, and what is on it
	draw_line(Vector2(x - 52.0, 306), Vector2(x + 52.0, 306), C_CABLE, 1.6)
	_draw_nazar(x - 30.0, 320.0)
	_draw_nazar(x + 30.0, 320.0)
	_draw_charm(x, 324.0)


func _draw_nazar(x: float, y: float) -> void:
	draw_line(Vector2(x, 306), Vector2(x, y - 10.0), C_CABLE, 1.2)
	draw_circle(Vector2(x, y), 11.0, C_COBALT)
	draw_circle(Vector2(x, y), 7.0, C_TILE_W)
	draw_circle(Vector2(x, y), 4.0, C_TURQ)
	draw_circle(Vector2(x, y), 2.0, Color(0.05, 0.05, 0.09))


# It does not hang straight. There is a hole drilled through it that should
# not be there, and that is why it can be worn at all.
func _draw_charm(x: float, y: float) -> void:
	var sway: float = sin(_t * 0.8) * 2.5
	draw_line(Vector2(x, 306), Vector2(x + sway, y - 12.0), C_CABLE, 1.2)
	var glow: float = 0.72 + 0.28 * sin(_t * 1.6)
	draw_circle(Vector2(x + sway, y + 2.0), 22.0, Color(0.96, 0.86, 0.52, 0.10 * glow))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + sway, y - 12.0), Vector2(x + sway + 11.0, y - 2.0),
		Vector2(x + sway + 7.0, y + 14.0), Vector2(x + sway - 7.0, y + 14.0),
		Vector2(x + sway - 11.0, y - 2.0),
	]), Color(0.94, 0.88, 0.66))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + sway, y - 12.0), Vector2(x + sway + 11.0, y - 2.0),
		Vector2(x + sway, y + 4.0),
	]), Color(1.0, 0.96, 0.82, 0.85))
	# The hole. Kerem's.
	draw_circle(Vector2(x + sway, y - 6.0), 2.6, C_SHADOW)


# ── Galata Kulesi ────────────────────────────────────────────────────────────
# Sixty-seven metres of stone drum with a conical lead roof, put up by the
# Genoese in 1348 as the high point of their own walled town on this side of
# the water. It has been a watchtower, a fire lookout, a prison and an
# observatory, and the fire watch is the job it held longest - men lived at
# the top of it and rang down when Constantinople started burning, which it
# did about once a decade.
# Süleymaniye, on the third hill directly above the bazaar quarter. Galata used
# to stand here, which was wrong twice over: the tower is across the Golden
# Horn in Beyoğlu, a different side of a different waterway, and it is already
# drawn there. What actually stands over Çarşı - over every lane of it, from
# almost anywhere in the quarter - is Sinan's mosque.
func _draw_suleymaniye(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var stone := Color(0.788, 0.741, 0.663)
	var lead := Color(0.376, 0.400, 0.427)
	if not morning:
		# Floodlit, and between the minarets in Ramadan there is a mahya, a
		# line of lamps spelling something out. He will not read that either.
		stone = stone.darkened(0.18)
		lead = lead.darkened(0.22)
	var base: float = 236.0

	# The four minarets. Two tall at the courtyard corners, two shorter at the
	# far end - that asymmetry is how you know which mosque it is.
	for spec in [[-224.0, 214.0, 2], [-118.0, 168.0, 1],
			[118.0, 168.0, 1], [224.0, 214.0, 2]]:
		var mx: float = cx + float(spec[0])
		var mh: float = float(spec[1])
		var balconies: int = int(spec[2])
		var top: float = base - mh
		draw_rect(Rect2(mx - 5.0, top + 14.0, 10.0, mh - 14.0), stone)
		draw_rect(Rect2(mx - 5.0, top + 14.0, 3.5, mh - 14.0), stone.lightened(0.12))
		for b in range(balconies):
			var by: float = top + 40.0 + float(b) * 46.0
			draw_rect(Rect2(mx - 9.0, by, 18.0, 5.0), stone.lightened(0.20))
			draw_rect(Rect2(mx - 9.0, by + 5.0, 18.0, 3.0), stone.darkened(0.30))
		# The lead cap and the alem on top of it.
		draw_colored_polygon(PackedVector2Array([
			Vector2(mx - 6.0, top + 15.0), Vector2(mx + 6.0, top + 15.0),
			Vector2(mx, top - 12.0),
		]), lead)
		draw_rect(Rect2(mx - 1.0, top - 22.0, 2.0, 11.0), stone.lightened(0.24))

	# The prayer hall under them, stepping up in half domes to the great one.
	draw_rect(Rect2(cx - 162.0, base - 84.0, 324.0, 84.0), stone)
	draw_rect(Rect2(cx - 162.0, base - 84.0, 324.0, 5.0), stone.lightened(0.14))
	for s in [-1.0, 1.0]:
		_dome(cx + s * 100.0, base - 84.0, 58.0, 32.0, lead, stone)
	_dome(cx, base - 104.0, 82.0, 46.0, lead, stone)
	# The great dome, and the alem standing on it.
	_dome(cx, base - 138.0, 106.0, 68.0, lead, stone)
	draw_rect(Rect2(cx - 2.0, base - 138.0 - 68.0 - 24.0, 4.0, 26.0),
		stone.lightened(0.24))
	draw_circle(Vector2(cx, base - 138.0 - 68.0 - 28.0), 5.0, stone.lightened(0.24))

	if not morning:
		for g in range(4):
			var f: float = float(g) / 3.0
			draw_rect(Rect2(cx - 200.0 + f * 60.0, base - 40.0 - f * 190.0,
				400.0 - f * 120.0, 60.0), Color(1.0, 0.878, 0.647, 0.038))


# A lead dome on a drum, with the window band round the bottom of it.
func _dome(cx: float, base_y: float, half: float, h: float, lead: Color,
		stone: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(19):
		var a: float = PI * float(i) / 18.0
		pts.append(Vector2(cx - cos(a) * half, base_y - sin(a) * h))
	pts.append(Vector2(cx + half, base_y))
	pts.append(Vector2(cx - half, base_y))
	draw_colored_polygon(pts, lead)
	# The lit side.
	var lit := PackedVector2Array()
	for i in range(10):
		var a2: float = PI * (0.5 + float(i) / 18.0)
		lit.append(Vector2(cx - cos(a2) * half, base_y - sin(a2) * h))
	lit.append(Vector2(cx - half * 0.42, base_y))
	lit.append(Vector2(cx - half, base_y))
	draw_colored_polygon(lit, lead.lightened(0.14))
	# The drum, with its windows.
	draw_rect(Rect2(cx - half, base_y, half * 2.0, 10.0), stone)
	for w in range(int(half / 11.0)):
		draw_rect(Rect2(cx - half + 6.0 + float(w) * 11.0, base_y + 2.0, 4.0, 7.0),
			stone.darkened(0.52))


func _draw_galata(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var stone: Color = Color(0.784, 0.741, 0.663)
	if not morning:
		stone = stone.darkened(0.30)
	var lead: Color = Color(0.400, 0.408, 0.427)
	if not morning:
		lead = lead.darkened(0.26)
	var base: float = 214.0
	var top: float = 62.0

	# The tower is 244 pixels from footing to finial and the plate has 236
	# of sky, so at its authored size the cone went off the top and what
	# was left read as a turret on somebody's roof. Squashed a little,
	# widened rather more, and stood on a lower footing that the shop
	# storey covers - which is where it is anyway, up the hill behind
	# the street.
	const SX := 1.34
	const SY := 0.92
	const FOOT := 262.0
	draw_set_transform(Vector2(cx - SX * cx, FOOT - SY * base), 0.0,
		Vector2(SX, SY))

	# The drum. Slightly wider at the foot, and the courses show.
	draw_rect(Rect2(cx - 34.0, top, 68.0, base - top), stone)
	draw_rect(Rect2(cx - 34.0, top, 22.0, base - top), stone.lightened(0.08))
	draw_rect(Rect2(cx + 20.0, top, 14.0, base - top), stone.darkened(0.12))
	for r in range(int((base - top) / 13.0)):
		draw_rect(Rect2(cx - 34.0, top + 10.0 + float(r) * 13.0, 68.0, 1.4),
			stone.darkened(0.16))
	# Small windows, two to a course, all the way up.
	for w in range(5):
		var wy: float = top + 34.0 + float(w) * 26.0
		if wy > base - 26.0:
			break
		for s2 in [-1.0, 1.0]:
			draw_rect(Rect2(cx + s2 * 15.0 - 5.0, wy, 10.0, 15.0),
				stone.darkened(0.52))
			draw_circle(Vector2(cx + s2 * 15.0, wy), 5.0, stone.darkened(0.52))

	# The gallery: a balcony ringing the tower under the cone, with the
	# balustrade and the shadow it throws on the drum.
	draw_rect(Rect2(cx - 44.0, top - 6.0, 88.0, 9.0), stone.lightened(0.14))
	draw_rect(Rect2(cx - 44.0, top + 3.0, 88.0, 4.0), stone.darkened(0.30))
	for b in range(11):
		draw_rect(Rect2(cx - 41.0 + float(b) * 8.0, top - 18.0, 4.0, 12.0),
			stone.lightened(0.06))
	draw_rect(Rect2(cx - 44.0, top - 22.0, 88.0, 5.0), stone.lightened(0.16))

	# The cone. Lead, steep, and the shape everybody draws.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 40.0, top - 22.0), Vector2(cx + 40.0, top - 22.0),
		Vector2(cx, top - 92.0),
	]), lead)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 40.0, top - 22.0), Vector2(cx - 10.0, top - 22.0),
		Vector2(cx, top - 92.0),
	]), lead.lightened(0.10))
	draw_rect(Rect2(cx - 1.5, top - 108.0, 3.0, 18.0), lead.darkened(0.20))
	if not morning:
		# It is floodlit, and the colour changes for whatever the country is
		# commemorating that week.
		for k in range(3):
			draw_circle(Vector2(cx, top + 40.0), 60.0 + float(k) * 30.0,
				Color(0.96, 0.78, 0.46, 0.035))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	match district:
		"carsi":
			return [
				[Vector2(300.0, 402.0), 0, 0],   # loafing on a step, eyes shut
				[Vector2(742.0, 344.0), 1, 2],   # ginger on a crate, watching
				[Vector2(944.0, 498.0), 0, 1],
			]
		"han":
			return [[Vector2(620.0, 560.0), 1, 1]]  # this one owns the fountain
		"beyoglu":
			return [[Vector2(318.0, PAVE_TOP + 24.0), 0, 2]]
	return []
