extends Node2D

# Prenzlauer Berg. The best bones in Berlin and the highest rent in Berlin, and
# those are not two facts.
#
# Mitte sits BACK from you — wide street, flat frontage, a lot of sky.
# London sits ON TOP of you — narrow, busy roofline, a hole before every door.
# Prenzlberg does neither. It stands STRAIGHT UP. Five storeys of 1900s Altbau
# coming out of the pavement with no setback and no relief, ornamented the whole
# way, and the only horizontal in the street is the shop cornice at head height.
# Three things carry that, and none of them are in MitteBackground.gd:
#   1. the Hofeinfahrt — a barrel vault driven through the building to a
#      courtyard, and the one surface in the district nobody has cleaned
#   2. restored stucco touching unrestored stucco, and the difference between
#      them is money and nothing else
#   3. bullet holes. Still there. At first-floor level, on the grey house.
#
# The harder thing to draw is that this is the first street the alien walks down
# that somebody looks after. Swept setts. Planted tree pits. A child's mitten
# somebody found and tied to the playground fence at the height a child looks.
# It is not that the street is rich. It is that somebody comes out in the
# morning, and up to now nowhere has.
#
# Ground bands match Mitte exactly (292 / 372 / 516) so the player, the exits,
# collision and the map all behave identically.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── Palette ───────────────────────────────────────────────────────────────────
# Berlin's own, off MitteBackground.gd and pushed one notch cooler. This is the
# north-east of the city; the light does not go warm here, ever.

const C_SKY_ZEN  := Color(0.049, 0.044, 0.114)   # night zenith — straight indigo
const C_SKY_MID  := Color(0.078, 0.064, 0.154)   # the band the roofline cuts
const C_SKY_LOW  := Color(0.164, 0.094, 0.186)   # light pollution off the cloud
const C_SKY_HAZE := Color(0.286, 0.156, 0.134)   # sodium sitting on the eaves
const C_DAY_HI   := Color(0.404, 0.556, 0.722)   # morning, and it is a cold blue
const C_DAY_LO   := Color(0.514, 0.632, 0.764)   # haze above the rooftops

const C_GREY       := Color(0.310, 0.318, 0.345) # unrestored render — 1989 grey
const C_GREY_LT    := Color(0.392, 0.396, 0.416) # cement patches on the grey house
const C_PANEL      := Color(0.451, 0.455, 0.463) # the 1970s infill, precast
const C_ZINC       := Color(0.196, 0.208, 0.247) # roof, downpipes, dormer cheeks
const C_ORNAMENT   := Color(0.769, 0.749, 0.702) # restored stucco: pediments, garlands
const C_REVEAL     := Color(0.129, 0.129, 0.153) # inside a two-foot-thick reveal
const C_KREUZ      := Color(0.878, 0.867, 0.831) # window frames — white, here
const C_SILL       := Color(0.671, 0.663, 0.639) # cast sills, streaked underneath
const C_GLASS      := Color(0.098, 0.110, 0.153) # unlit glass, cold
const C_LIT        := Color(0.965, 0.878, 0.647) # lit rooms — warmer than the street
const C_BULLET     := Color(0.129, 0.125, 0.141) # the holes, still in the stucco
const C_BRANDMAUER := Color(0.278, 0.259, 0.243) # party wall left bare by the infill

const C_SETT    := Color(0.220, 0.231, 0.267)    # Kopfsteinpflaster — the side street
const C_SETT_LT := Color(0.286, 0.298, 0.333)    # crowns the wheels have polished
const C_SLAB    := Color(0.322, 0.325, 0.341)    # pavement slabs, and they are swept
const C_MOSAIC  := Color(0.259, 0.263, 0.282)    # the small-sett strip by the kerb
const C_KERB    := Color(0.435, 0.435, 0.443)    # granite, higher than it looks
const C_RAIL    := Color(0.510, 0.522, 0.533)    # tram rail, worn bright by the M2
const C_SOIL    := Color(0.145, 0.125, 0.106)    # tree pits, planted, not paved over

const C_BARK       := Color(0.494, 0.482, 0.435) # plane bark, flaking
const C_LEAF       := Color(0.239, 0.322, 0.235) # canopy at dusk
const C_LEAF_DAY   := Color(0.318, 0.420, 0.278) # canopy in the morning
const C_GERANIUM   := Color(0.702, 0.259, 0.243) # window boxes — the one warm colour
const C_TERRACOTTA := Color(0.510, 0.302, 0.220) # pots, on every second sill

# Statutory and civic. One at a time, never two in the same glance.
const C_U_BLUE  := Color(0.050, 0.220, 0.550)    # the U on its blue square
const C_BVG_YEL := Color(0.949, 0.769, 0.106)    # the tram flag
const C_APO_RED := Color(0.741, 0.208, 0.169)    # the Apotheken A, and door accents
const C_AMPEL_R := Color(0.918, 0.220, 0.180)    # the standing man
const C_AMPEL_G := Color(0.298, 0.847, 0.318)    # the walking one, hat and all
const C_BOARD   := Color(0.145, 0.169, 0.161)    # fascias: painted, matte, tasteful
const C_INK     := Color(0.882, 0.863, 0.808)    # the lettering on them

const C_PLAY_WOOD := Color(0.400, 0.286, 0.196)  # climbing frame, larch, weathered
const C_PLAY_RAIL := Color(0.180, 0.290, 0.231)  # the green fence round the Spielplatz
const C_SAND      := Color(0.549, 0.494, 0.400)  # the sandpit, and it is raked
const C_MITTEN    := Color(0.796, 0.361, 0.412)  # a glove, tied where she will see it

# Shared with Mitte so collision and exits stay true
const PAVE_TOP := 292.0
const ROAD_TOP := 372.0
const PAVE_BOT := 516.0

# Facade geometry. GF_TOP is the shop cornice, and it is the only horizontal in
# the whole street — everything else goes up.
const GF_TOP    := 228.0
const EAVES_5   := 34.0
const EAVES_IN  := 92.0

# [x, width, storeys, kind, hue] — kind: 0 unrestored · 1 restored · 2 infill.
# Restored and unrestored are deliberately adjacent. The 1970s infill at 616 is
# a Baulücke: something stood there until 1945 and something cheaper replaced it.
const _ALTBAU := [
	[-26, 214, 5, 1, 0], [188, 196, 5, 1, 3], [384, 232, 5, 0, 2],
	[616, 208, 4, 2, 2], [824, 190, 5, 1, 1], [1014, 190, 5, 0, 2],
]

# Restoration colours. Desaturated, cool, and chosen by a committee — the
# Altbau palette is regulated, which is its own kind of joke.
const FACADE_HUES := [
	Color(0.639, 0.612, 0.541),   # cream-ochre, the commonest
	Color(0.588, 0.529, 0.522),   # dusty rose, one house in five
	Color(0.310, 0.318, 0.345),   # never used on a restored house
	Color(0.522, 0.565, 0.545),   # pale sage, the expensive one
]

# Hoisted: this project has been bitten by inferring a type off a subscript.
const TAG_INKS := [
	Color(0.898, 0.918, 0.941, 0.28), Color(0.353, 0.796, 0.855, 0.24),
	Color(0.949, 0.451, 0.251, 0.22),
]
# [x, y, width] — only where wall actually shows between the shopfronts
const WALL_TAGS := [
	[332.0, 246.0, 44.0], [966.0, 244.0, 80.0], [1058.0, 252.0, 76.0],
]

var _t: float = 0.0


# ── Doors ─────────────────────────────────────────────────────────────────────
# Read straight off the SceneExit siblings, so the sign over a door and the
# building behind it are the same building by construction. Previously the
# signage was drawn at fixed positions that had nothing to do with the doors,
# which is why you could walk under MARKET and come out in a hotel.

const IA := preload("res://scenes/world/InteriorArt.gd")

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
	_draw_sky()
	_draw_wasserturm(716.0)
	_draw_altbau_row()
	_draw_wall_tags()
	_draw_hofeinfahrt(566.0)
	_draw_ground()
	_draw_doors(236.0, PAVE_TOP, C_BOARD, C_INK, C_APO_RED, C_GLASS)
	_draw_pavement_furniture()
	_draw_far_side()


# What stops you. Every footprint here reaches past y=300, because the walkable
# band starts at 300 and anything ending above it is decoration the player
# strolls through. The Spielplatz fence is the important one: it has a gate, and
# the gate is the only way in, which is what a fence round children is for.
func solids() -> Array:
	var out: Array = []
	out.append(Rect2(140.0, 256.0, 30.0, 64.0))    # plane tree, upper pavement
	out.append(Rect2(194.0, 272.0, 50.0, 38.0))    # café tables and their blankets
	out.append(Rect2(296.0, 274.0, 84.0, 36.0))    # prams, three abreast
	out.append(Rect2(396.0, 264.0, 34.0, 46.0))    # bin, with the Pfand beside it
	out.append(Rect2(762.0, 270.0, 66.0, 42.0))    # cargo bike
	out.append(Rect2(944.0, 256.0, 30.0, 64.0))    # plane tree, upper pavement
	out.append(Rect2(1030.0, 250.0, 12.0, 60.0))   # tram flag
	out.append(Rect2(1090.0, 248.0, 14.0, 62.0))   # Ampelmann post
	out.append(Rect2(34.0, 246.0, 14.0, 62.0))     # the U sign by the stairs
	out.append(Rect2(170.0, 552.0, 32.0, 66.0))    # plane tree, lower pavement
	out.append(Rect2(300.0, 574.0, 100.0, 32.0))   # bench, repainted by somebody
	out.append(Rect2(434.0, 482.0, 52.0, 120.0))   # Litfaßsäule
	out.append(Rect2(556.0, 522.0, 130.0, 30.0))   # Spielplatz fence, left of the gate
	out.append(Rect2(766.0, 522.0, 138.0, 30.0))   # and right of it
	out.append(Rect2(556.0, 522.0, 18.0, 126.0))   # its west rail
	out.append(Rect2(886.0, 522.0, 18.0, 126.0))   # its east rail
	out.append(Rect2(690.0, 556.0, 88.0, 74.0))    # the climbing frame
	out.append(Rect2(984.0, 556.0, 92.0, 54.0))    # Glascontainer
	return out


# ── Sky ───────────────────────────────────────────────────────────────────────
# There is very little of it, and that is the point of a five-storey street.

func _draw_sky() -> void:
	if GameState.is_morning():
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), C_DAY_HI)
		draw_rect(Rect2(0, 96, VW, 196), C_DAY_LO)
		draw_rect(Rect2(0, 210, VW, 82), C_DAY_LO.lightened(0.10))
		return
	draw_rect(Rect2(0, 0, VW, PAVE_TOP), C_SKY_ZEN)
	draw_rect(Rect2(0, 40, VW, 150), C_SKY_MID)
	draw_rect(Rect2(0, 160, VW, 80), C_SKY_LOW)
	draw_rect(Rect2(0, 232, VW, 60), C_SKY_HAZE)


# The Wasserturm. A fat brick drum on the only hill in the district, and the
# reason the sky here is worth leaving a gap for. Visible over the infill,
# because the house that used to block it is not there any more.
func _draw_wasserturm(x: float) -> void:
	var morning: bool = GameState.is_morning()
	var brick: Color = Color(0.400, 0.290, 0.263) if morning else Color(0.129, 0.098, 0.129)
	draw_rect(Rect2(x - 44.0, 42.0, 88.0, 60.0), brick)
	draw_rect(Rect2(x - 44.0, 42.0, 12.0, 60.0), brick.lightened(0.12))
	draw_rect(Rect2(x + 32.0, 42.0, 12.0, 60.0), brick.darkened(0.18))
	# the conical cap, stepped rather than sloped so it stays pixel-honest
	for s in range(5):
		var sw: float = 88.0 - float(s) * 15.0
		draw_rect(Rect2(x - sw * 0.5, 42.0 - float(s + 1) * 6.0, sw, 7.0),
			brick.darkened(0.06 * float(s)))
	# a ring of small round-headed windows, and at dusk somebody is home in one
	for i in range(7):
		var wx: float = x - 36.0 + float(i) * 12.0
		var lit: bool = i == 3 and not morning
		draw_rect(Rect2(wx, 60.0, 6.0, 14.0), C_LIT if lit else Color(0.075, 0.070, 0.090))


# ── The Altbau row ────────────────────────────────────────────────────────────

func _draw_altbau_row() -> void:
	# The infill is shorter, so its neighbours' party walls stand bare above it.
	# A Brandmauer with nothing against it is the shape a bomb leaves.
	draw_rect(Rect2(600.0, EAVES_5, 18.0, EAVES_IN - EAVES_5), C_BRANDMAUER)
	draw_rect(Rect2(822.0, EAVES_5, 18.0, EAVES_IN - EAVES_5), C_BRANDMAUER)
	for i in range(_ALTBAU.size()):
		var unit: Array = _ALTBAU[i]
		_draw_unit(float(unit[0]), float(unit[1]), int(unit[2]), int(unit[3]),
			int(unit[4]), i)


func _draw_unit(x: float, w: float, storeys: int, kind: int, hue_i: int,
		seed_i: int) -> void:
	var eaves: float = EAVES_5 if storeys == 5 else EAVES_IN
	var wall: Color = FACADE_HUES[hue_i % FACADE_HUES.size()]
	if kind == 0:
		wall = C_GREY
	elif kind == 2:
		wall = C_PANEL

	if kind == 2:
		draw_rect(Rect2(x, eaves - 12.0, w, 14.0), C_ZINC.darkened(0.20))
		draw_rect(Rect2(x, eaves - 12.0, w, 3.0), C_ZINC.lightened(0.10))
	else:
		_draw_roof(x, w, eaves, seed_i)

	draw_rect(Rect2(x, eaves, w, GF_TOP - eaves), wall)
	# Pilaster strips at the party walls. Every unit is a separate building and
	# the joint between two of them is always visible from the street.
	draw_rect(Rect2(x, eaves, 7.0, GF_TOP - eaves), wall.darkened(0.18))
	draw_rect(Rect2(x + w - 7.0, eaves, 7.0, GF_TOP - eaves), wall.darkened(0.24))

	if kind == 2:
		_draw_infill_bands(x, w, eaves)
	else:
		for r in range(4):
			_draw_window_row(x, w, eaves + 4.0 + float(r) * 30.0, kind, seed_i * 5 + r)
		_draw_brustung(x, w, kind, seed_i)
	if kind == 0:
		_draw_bullet_holes(x, w, seed_i)

	# The ground floor, and the cornice over it. Shop or no shop, the Sockel is
	# always darker — a hundred and twenty years of boots and street water.
	draw_rect(Rect2(x - 3.0, GF_TOP - 8.0, w + 6.0, 9.0), C_ORNAMENT.darkened(0.30))
	draw_rect(Rect2(x, GF_TOP, w, PAVE_TOP - GF_TOP), wall.darkened(0.22))
	draw_rect(Rect2(x, PAVE_TOP - 16.0, w, 16.0), wall.darkened(0.42))


func _draw_roof(x: float, w: float, eaves: float, seed_i: int) -> void:
	# Steep zinc, and the attic is lived in — Berlin sold every roof it had.
	draw_rect(Rect2(x, 4.0, w, eaves - 2.0), C_ZINC)
	draw_rect(Rect2(x, 4.0, w, 3.0), C_ZINC.lightened(0.14))
	for s in range(int(w / 22.0)):
		draw_rect(Rect2(x + float(s) * 22.0, 4.0, 2.0, eaves - 2.0),
			C_ZINC.darkened(0.22))
	for d in range(2):
		var dx: float = x + w * (0.28 + float(d) * 0.42)
		var lit: bool = ((seed_i * 17 + d) % 5) < 2
		draw_rect(Rect2(dx - 15.0, 2.0, 30.0, 26.0), C_ZINC.lightened(0.08))
		draw_rect(Rect2(dx - 11.0, 6.0, 22.0, 20.0), C_LIT if lit else C_GLASS)
	# The eaves cornice is deep enough to be the only shadow up here.
	draw_rect(Rect2(x - 5.0, eaves - 7.0, w + 10.0, 9.0), C_ORNAMENT.darkened(0.26))
	draw_rect(Rect2(x - 5.0, eaves - 7.0, w + 10.0, 2.0), C_ORNAMENT.darkened(0.06))
	draw_rect(Rect2(x, eaves + 2.0, w, 4.0), Color(0, 0, 0, 0.20))


func _draw_window_row(x: float, w: float, y: float, kind: int, seed_i: int) -> void:
	var cols: int = maxi(int((w - 36.0) / 46.0), 2)
	var step: float = (w - 40.0) / float(cols)
	for c in range(cols):
		_draw_window(x + 20.0 + float(c) * step, y, kind, seed_i * 11 + c * 7)


func _draw_window(x: float, y: float, kind: int, seed_i: int) -> void:
	# The ornament over the opening is the whole argument of the street. On the
	# restored house it is a moulded pediment; on the grey one it is whatever
	# survived, and a band of cement where it did not.
	if kind == 1:
		draw_rect(Rect2(x - 6.0, y - 9.0, 34.0, 7.0), C_ORNAMENT)
		draw_rect(Rect2(x - 3.0, y - 12.0, 28.0, 3.0), C_ORNAMENT.lightened(0.16))
	else:
		draw_rect(Rect2(x - 5.0, y - 8.0, 32.0, 6.0), C_GREY_LT)
	draw_rect(Rect2(x - 2.0, y, 26.0, 32.0), C_REVEAL)
	draw_rect(Rect2(x, y, 22.0, 30.0), C_KREUZ)
	var lit: bool = ((seed_i * 41) % 7) < 3
	draw_rect(Rect2(x + 2.0, y + 2.0, 18.0, 26.0), C_LIT if lit else C_GLASS)
	# A Kreuzstock: one mullion, one high transom. Never a single sheet of glass.
	draw_rect(Rect2(x + 10.0, y + 2.0, 2.0, 26.0), C_KREUZ)
	draw_rect(Rect2(x + 2.0, y + 8.0, 18.0, 2.0), C_KREUZ)
	draw_rect(Rect2(x - 4.0, y + 30.0, 30.0, 4.0), C_SILL)
	draw_rect(Rect2(x - 2.0, y + 34.0, 26.0, 4.0), Color(0, 0, 0, 0.14))
	# Somebody waters these. That is the thing the alien has not seen before.
	if (seed_i * 13) % 5 == 0:
		draw_rect(Rect2(x + 1.0, y + 31.0, 20.0, 6.0), C_TERRACOTTA)
		draw_circle(Vector2(x + 6.0, y + 30.0), 3.5, C_LEAF)
		draw_circle(Vector2(x + 15.0, y + 29.0), 3.0, C_GERANIUM)


# The band between the shop cornice and the first-floor sills. On a restored
# house it carries garlands and a cartouche with the year cut into it; on the
# grey one it carries the shop signs, the weather, and the holes.
func _draw_brustung(x: float, w: float, kind: int, seed_i: int) -> void:
	draw_rect(Rect2(x, 152.0, w, 6.0), C_ORNAMENT.darkened(0.36 if kind == 0 else 0.14))
	if kind != 1:
		draw_rect(Rect2(x + 8.0, 176.0, w - 16.0, 30.0), Color(0, 0, 0, 0.10))
		return
	for g in range(3):
		var gx: float = x + w * (0.22 + float(g) * 0.28)
		draw_rect(Rect2(gx - 22.0, 176.0, 44.0, 8.0), C_ORNAMENT)
		draw_circle(Vector2(gx, 186.0), 7.0, C_ORNAMENT.darkened(0.10))
		draw_circle(Vector2(gx - 16.0, 184.0), 5.0, C_ORNAMENT.darkened(0.18))
		draw_circle(Vector2(gx + 16.0, 184.0), 5.0, C_ORNAMENT.darkened(0.18))
	# The cartouche. Every restored Altbau puts its build year back on, because
	# the year is the thing being sold.
	var cx: float = x + w * 0.5
	draw_rect(Rect2(cx - 26.0, 198.0, 52.0, 20.0), C_ORNAMENT.darkened(0.08))
	draw_rect(Rect2(cx - 22.0, 202.0, 44.0, 12.0), C_ORNAMENT.darkened(0.28))
	for n in range(4):
		draw_rect(Rect2(cx - 17.0 + float(n) * 10.0, 205.0, 5.0,
			7.0 - float((seed_i + n) % 2)), C_ORNAMENT.lightened(0.10))


# Nobody filled these in. On this house the stucco was never re-rendered, so
# the pattern is still there — a diagonal scatter across the first floor, going
# up left to right, which is the direction the fire came from.
func _draw_bullet_holes(x: float, w: float, seed_i: int) -> void:
	for i in range(11):
		var hx: float = x + 22.0 + float(i) * ((w - 44.0) / 11.0)
		var hy: float = 208.0 - float(i) * 3.4 - float((i * seed_i * 7) % 9)
		var r: float = 2.2 + float((i * 5) % 3)
		draw_circle(Vector2(hx, hy), r + 1.0, C_GREY_LT.darkened(0.10))
		draw_circle(Vector2(hx, hy), r, C_BULLET)
		draw_rect(Rect2(hx - r, hy + r, r * 2.0, 3.0), Color(0, 0, 0, 0.18))


# The infill. Precast, three bands of aluminium window, no ornament and nothing
# to restore. It is not ugly. It is just from a country that had other problems.
func _draw_infill_bands(x: float, w: float, eaves: float) -> void:
	for r in range(3):
		var y: float = eaves + 12.0 + float(r) * 34.0
		draw_rect(Rect2(x + 12.0, y, w - 24.0, 24.0), C_REVEAL)
		var panes: int = int((w - 24.0) / 40.0)
		for p in range(panes):
			var px: float = x + 16.0 + float(p) * 40.0
			var lit: bool = ((p * 13 + r * 5) % 6) < 2
			draw_rect(Rect2(px, y + 3.0, 32.0, 18.0), C_LIT if lit else C_GLASS)
			draw_rect(Rect2(px + 32.0, y + 3.0, 3.0, 18.0), C_SILL.darkened(0.20))
		draw_rect(Rect2(x + 10.0, y + 24.0, w - 20.0, 4.0), C_SILL.darkened(0.30))
		# The joints between panels never quite closed, and they stain.
		draw_rect(Rect2(x + 10.0, y - 6.0, w - 20.0, 3.0), Color(0, 0, 0, 0.16))


# Berlin is written on at hand height, permanently, everywhere. Here it is not
# on the restored fronts — those get scrubbed within the week, and you can see
# where. It is on the grey house, where nobody has been paid to care.
func _draw_wall_tags() -> void:
	for i in range(WALL_TAGS.size()):
		var t: Array = WALL_TAGS[i]
		var x: float = float(t[0])
		var y: float = float(t[1])
		var w: float = float(t[2])
		var ink: Color = TAG_INKS[i % TAG_INKS.size()]
		# A tag is one gesture, so it is linked strokes and not lettering
		var prev: Vector2 = Vector2(x, y + 14.0)
		for s in range(6):
			var nx: float = x + w * (float(s + 1) / 6.0)
			var ny: float = y + (13.0 if s % 2 == 0 else -5.0) + float((i * 5 + s) % 5)
			draw_line(prev, Vector2(nx, ny), ink, 2.6)
			prev = Vector2(nx, ny)
		# The scrubbed one — the tag is gone and the shadow of the scrub is not
		if i == 0:
			draw_rect(Rect2(x - 10.0, y - 4.0, w + 24.0, 30.0),
				Color(0.86, 0.86, 0.84, 0.07))


# The Hofeinfahrt. A barrel vault driven straight through the building, wide
# enough for a cart because it was built for carts. It belongs to everybody and
# therefore to nobody: bare render, tags to shoulder height, and at the far end
# a strip of lit courtyard the alien can see all the way into and not reach.
func _draw_hofeinfahrt(x: float) -> void:
	var spring: float = 196.0
	draw_rect(Rect2(x - 60.0, spring - 46.0, 120.0, PAVE_TOP - spring + 46.0),
		C_ORNAMENT.darkened(0.34))
	for a in range(11):
		var ang: float = PI + float(a) * PI / 10.0
		draw_rect(Rect2(x + cos(ang) * 52.0 - 8.0, spring + sin(ang) * 52.0 - 8.0,
			16.0, 16.0), C_ORNAMENT.darkened(0.14))
	draw_circle(Vector2(x, spring), 44.0, Color(0.043, 0.043, 0.055))
	draw_rect(Rect2(x - 44.0, spring, 88.0, PAVE_TOP - spring),
		Color(0.043, 0.043, 0.055))
	# Vault ribs, receding. Four is enough to say "this goes a long way in".
	for r in range(4):
		var inset: float = 6.0 + float(r) * 7.0
		draw_rect(Rect2(x - 44.0 + inset, spring - 28.0 + float(r) * 22.0,
			88.0 - inset * 2.0, 3.0), Color(0.11, 0.11, 0.13))
	_draw_courtyard_beyond(x, spring)
	for i in range(3):
		var tx: float = x - 40.0 + float(i) * 32.0
		draw_line(Vector2(tx, 250.0), Vector2(tx + 22.0, 264.0),
			TAG_INKS[i % TAG_INKS.size()], 2.4)
	# Forty names on one panel, and one of them is handwritten on tape.
	draw_rect(Rect2(x + 52.0, 238.0, 20.0, 44.0), Color(0.196, 0.196, 0.227))
	for b in range(7):
		draw_rect(Rect2(x + 55.0, 242.0 + float(b) * 5.6, 14.0, 3.0),
			Color(0.780, 0.780, 0.741, 0.95 if b == 4 else 0.65))


# What the passage frames. Green, lit, and quiet — the first thing in the game
# that looks like it is being kept rather than used.
func _draw_courtyard_beyond(x: float, spring: float) -> void:
	var morning: bool = GameState.is_morning()
	var lightfall: Color = Color(0.545, 0.596, 0.573) if morning \
		else Color(0.271, 0.235, 0.204)
	draw_rect(Rect2(x - 21.0, spring + 16.0, 42.0, 50.0), lightfall)
	draw_rect(Rect2(x - 21.0, spring + 16.0, 42.0, 4.0), lightfall.darkened(0.30))
	var leaf: Color = C_LEAF_DAY if morning else C_LEAF
	draw_circle(Vector2(x - 8.0, spring + 46.0), 13.0, leaf.darkened(0.18))
	draw_circle(Vector2(x + 11.0, spring + 52.0), 10.0, leaf.darkened(0.28))
	# Bicycles against the wall down there, and a courtyard bin
	draw_rect(Rect2(x + 6.0, spring + 30.0, 13.0, 16.0), Color(0.16, 0.16, 0.18))
	if not morning:
		var lamp: float = 0.7 + 0.3 * sin(_t * 0.8)
		draw_circle(Vector2(x, spring + 34.0), 20.0,
			Color(0.98, 0.86, 0.60, 0.09 * lamp))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	# Upper pavement: big slabs, a strip of small setts against the kerb, and it
	# has been swept. There is no litter drawn on this street on purpose.
	draw_rect(Rect2(0, PAVE_TOP, VW, ROAD_TOP - PAVE_TOP), C_SLAB)
	for r in range(3):
		draw_rect(Rect2(0, PAVE_TOP + 4.0 + float(r) * 22.0, VW, 1.0),
			Color(0, 0, 0, 0.13))
	for c in range(int(VW / 58.0) + 1):
		draw_rect(Rect2(float(c) * 58.0, PAVE_TOP, 1.0, 46.0), Color(0, 0, 0, 0.11))
	draw_rect(Rect2(0, PAVE_TOP + 46.0, VW, 16.0), C_MOSAIC)
	_draw_setts(PAVE_TOP + 46.0, 16.0, 8.0)
	draw_rect(Rect2(0, ROAD_TOP - 11.0, VW, 11.0), C_KERB)
	draw_rect(Rect2(0, ROAD_TOP - 11.0, VW, 2.0), C_KERB.lightened(0.20))

	# Carriageway: Kopfsteinpflaster, and the tram runs on it
	draw_rect(Rect2(0, ROAD_TOP, VW, PAVE_BOT - ROAD_TOP), C_SETT)
	_draw_setts(ROAD_TOP, PAVE_BOT - ROAD_TOP, 15.0)
	_draw_tram_rails()

	# Lower pavement, the side the children are on
	draw_rect(Rect2(0, PAVE_BOT, VW, VH - PAVE_BOT), C_SLAB.darkened(0.08))
	draw_rect(Rect2(0, PAVE_BOT, VW, 9.0), C_KERB.darkened(0.12))
	for r in range(4):
		draw_rect(Rect2(0, PAVE_BOT + 12.0 + float(r) * 30.0, VW, 1.0),
			Color(0, 0, 0, 0.12))
	_draw_hopscotch(212.0, 604.0)


func _draw_setts(top: float, height: float, size: float) -> void:
	var rows: int = int(height / size) + 1
	for r in range(rows):
		var y: float = top + float(r) * size
		var offset: float = 0.0 if r % 2 == 0 else size * 0.5
		var cols: int = int(VW / size) + 2
		for c in range(cols):
			var sx: float = offset + float(c) * size - size
			# Every fourth stone catches light — a cobble is a dome, not a tile
			if (r * 7 + c * 3) % 4 == 0:
				draw_rect(Rect2(sx + 1.0, y + 1.0, size - 3.0, size - 3.0), C_SETT_LT)
			draw_rect(Rect2(sx, y, size, 1.0), Color(0, 0, 0, 0.20))
			draw_rect(Rect2(sx, y, 1.0, size), Color(0, 0, 0, 0.18))


# Two rails, and the granite setts either side of them are laid to follow the
# rail rather than the street. The M2 has been through here since 1901.
func _draw_tram_rails() -> void:
	var pairs := [408.0, 434.0, 468.0, 494.0]
	for i in range(pairs.size()):
		var y: float = float(pairs[i])
		draw_rect(Rect2(0, y - 3.0, VW, 3.0), Color(0, 0, 0, 0.26))
		draw_rect(Rect2(0, y, VW, 4.0), C_RAIL)
		draw_rect(Rect2(0, y, VW, 1.0), C_RAIL.lightened(0.24))
		draw_rect(Rect2(0, y + 4.0, VW, 2.0), Color(0, 0, 0, 0.22))


# Chalk. Somebody's child drew this yesterday and the rain has not been yet.
func _draw_hopscotch(x: float, y: float) -> void:
	var chalk: Color = Color(0.878, 0.855, 0.796, 0.34)
	for i in range(6):
		var cy: float = y - float(i) * 13.0
		draw_rect(Rect2(x, cy, 34.0, 13.0), chalk, false, 1.6)
		draw_rect(Rect2(x + 14.0, cy + 4.0, 5.0, 5.0), chalk)


# ── Upper pavement ────────────────────────────────────────────────────────────

func _draw_pavement_furniture() -> void:
	_draw_u_sign(40.0)
	_draw_plane_tree(155.0, PAVE_TOP + 26.0, 1.0)
	_draw_cafe_tables(196.0)
	_draw_prams(300.0)
	_draw_bin_and_pfand(413.0)
	_draw_cargo_bike(795.0)
	_draw_plane_tree(959.0, PAVE_TOP + 26.0, 0.86)
	_draw_tram_flag(1036.0)
	_draw_ampelmann(1096.0)


# Plane trees, and they are enormous. The canopy closes over the street in
# summer, which is most of why anyone wanted to live here before it was fashion.
func _draw_plane_tree(x: float, base_y: float, s: float) -> void:
	# Baumscheibe: the tree pit is soil and it has been planted, not paved
	draw_rect(Rect2(x - 26.0, base_y - 10.0, 52.0, 20.0), C_SOIL)
	for i in range(5):
		draw_circle(Vector2(x - 18.0 + float(i) * 9.0, base_y - 4.0), 4.0,
			C_LEAF.darkened(0.10))
	draw_circle(Vector2(x - 12.0, base_y - 6.0), 3.0, C_GERANIUM)
	draw_rect(Rect2(x - 15.0 * s, base_y - 170.0 * s, 30.0 * s, 170.0 * s),
		C_BARK.darkened(0.38))
	for f in range(9):
		var fy: float = base_y - 162.0 * s + float(f) * 18.0 * s
		draw_rect(Rect2(x - 14.0 * s + float((f * 5) % 3) * 8.0 * s, fy,
			11.0 * s, 13.0 * s), C_BARK)
	var canopy: Color = C_LEAF_DAY if GameState.is_morning() else C_LEAF
	draw_circle(Vector2(x, base_y - 206.0 * s), 74.0 * s, canopy)
	draw_circle(Vector2(x - 52.0 * s, base_y - 176.0 * s), 46.0 * s, canopy)
	draw_circle(Vector2(x + 50.0 * s, base_y - 182.0 * s), 50.0 * s, canopy)
	draw_circle(Vector2(x + 8.0 * s, base_y - 250.0 * s), 40.0 * s,
		canopy.lightened(0.06))


# Blankets on the chairs. Not cushions — blankets, folded, put out every
# morning and taken in every night, so that people can sit outside in March.
func _draw_cafe_tables(x: float) -> void:
	for i in range(2):
		var tx: float = x + float(i) * 30.0
		draw_rect(Rect2(tx - 2.0, 302.0, 22.0, 8.0), Color(0, 0, 0, 0.20))
		draw_rect(Rect2(tx, 268.0, 20.0, 4.0), Color(0.271, 0.220, 0.180))
		draw_rect(Rect2(tx + 8.0, 272.0, 4.0, 30.0), Color(0.196, 0.165, 0.141))
	for c in range(3):
		var cx: float = x + 4.0 + float(c) * 16.0
		draw_rect(Rect2(cx, 278.0, 13.0, 4.0), Color(0.235, 0.196, 0.165))
		draw_rect(Rect2(cx, 258.0, 13.0, 20.0), Color(0.235, 0.196, 0.165))
		var wool := [Color(0.596, 0.325, 0.298), Color(0.400, 0.435, 0.400),
			Color(0.549, 0.510, 0.404)]
		draw_rect(Rect2(cx - 2.0, 262.0, 17.0, 13.0), wool[c % wool.size()])
		draw_rect(Rect2(cx - 2.0, 262.0, 17.0, 3.0),
			wool[c % wool.size()].lightened(0.16))
		draw_rect(Rect2(cx + 1.0, 282.0, 3.0, 20.0), Color(0.180, 0.153, 0.129))
		draw_rect(Rect2(cx + 9.0, 282.0, 3.0, 20.0), Color(0.180, 0.153, 0.129))


# Three abreast, parked outside the bakery, and there is no way past them on the
# pavement. This is the single most accurate object on the street.
func _draw_prams(x: float) -> void:
	for i in range(3):
		var px: float = x + float(i) * 28.0
		var hood := [Color(0.180, 0.220, 0.290), Color(0.310, 0.267, 0.239),
			Color(0.204, 0.259, 0.235)]
		var col: Color = hood[i % hood.size()]
		draw_rect(Rect2(px - 3.0, 304.0, 28.0, 7.0), Color(0, 0, 0, 0.20))
		draw_rect(Rect2(px, 282.0, 22.0, 18.0), col)
		draw_rect(Rect2(px, 274.0, 22.0, 10.0), col.lightened(0.14))
		draw_rect(Rect2(px + 2.0, 276.0, 18.0, 4.0), Color(0.878, 0.867, 0.831, 0.55))
		draw_rect(Rect2(px + 18.0, 268.0, 4.0, 16.0), Color(0.20, 0.20, 0.22))
		draw_circle(Vector2(px + 4.0, 302.0), 4.5, Color(0.11, 0.11, 0.13))
		draw_circle(Vector2(px + 17.0, 302.0), 4.5, Color(0.11, 0.11, 0.13))
		# A rain cover on one of them, clipped on whether it is raining or not
		if i == 1:
			draw_rect(Rect2(px - 1.0, 272.0, 24.0, 14.0), Color(0.78, 0.82, 0.86, 0.20))


# Pfand. Nobody throws a deposit bottle away — you stand it beside the bin so
# whoever collects them does not have to put a hand in. It is the politest
# thing this city does and it is entirely unspoken.
func _draw_bin_and_pfand(x: float) -> void:
	draw_rect(Rect2(x - 17.0, 264.0, 34.0, 44.0), Color(0.161, 0.180, 0.169))
	draw_rect(Rect2(x - 19.0, 260.0, 38.0, 6.0), Color(0.204, 0.227, 0.212))
	draw_rect(Rect2(x - 12.0, 270.0, 24.0, 3.0), Color(0.05, 0.06, 0.05))
	# The BSR ash-can orange, one stripe, because they paint everything orange
	draw_rect(Rect2(x - 17.0, 288.0, 34.0, 5.0), Color(0.847, 0.435, 0.106))
	for i in range(4):
		var bx: float = x + 22.0 + float(i) * 11.0
		var glass: Color = Color(0.239, 0.420, 0.259, 0.85) if i % 2 == 0 \
			else Color(0.360, 0.300, 0.180, 0.85)
		draw_rect(Rect2(bx, 288.0, 7.0, 20.0), glass)
		draw_rect(Rect2(bx + 2.0, 282.0, 3.0, 7.0), glass)


# A cargo bike. Two children's helmets in the box and a rain cover rolled back.
# It costs more than a car did when this street was cheap.
func _draw_cargo_bike(x: float) -> void:
	draw_rect(Rect2(x - 34.0, 306.0, 68.0, 6.0), Color(0, 0, 0, 0.20))
	draw_rect(Rect2(x - 32.0, 274.0, 42.0, 26.0), Color(0.196, 0.239, 0.275))
	draw_rect(Rect2(x - 32.0, 274.0, 42.0, 4.0), Color(0.259, 0.310, 0.345))
	draw_circle(Vector2(x - 22.0, 278.0), 5.0, Color(0.741, 0.694, 0.239))
	draw_circle(Vector2(x - 9.0, 278.0), 5.0, Color(0.400, 0.549, 0.635))
	draw_rect(Rect2(x + 8.0, 262.0, 4.0, 38.0), Color(0.16, 0.16, 0.18))
	draw_rect(Rect2(x + 2.0, 262.0, 18.0, 3.0), Color(0.16, 0.16, 0.18))
	draw_rect(Rect2(x - 4.0, 284.0, 26.0, 3.0), Color(0.16, 0.16, 0.18))
	draw_circle(Vector2(x - 28.0, 302.0), 8.0, Color(0.098, 0.098, 0.114))
	draw_circle(Vector2(x + 18.0, 300.0), 10.0, Color(0.098, 0.098, 0.114))
	draw_circle(Vector2(x + 18.0, 300.0), 5.0, Color(0.20, 0.20, 0.22))


# The U. White on a blue square, and it means the ground opens here. This is the
# way the alien arrived, and it is the only sign on the street it will recognise
# again from anywhere else in the city.
func _draw_u_sign(x: float) -> void:
	draw_rect(Rect2(x - 5.0, 246.0, 10.0, 62.0), Color(0.10, 0.10, 0.11))
	draw_rect(Rect2(x - 24.0, 208.0, 48.0, 48.0), C_U_BLUE)
	draw_rect(Rect2(x - 24.0, 208.0, 48.0, 48.0), Color(0.85, 0.88, 0.92), false, 2.0)
	draw_rect(Rect2(x - 12.0, 216.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x + 6.0, 216.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x - 12.0, 232.0, 24.0, 6.0), Color(0.94, 0.96, 0.98))


# The tram flag. Yellow, and it is the only saturated yellow in Berlin that is
# allowed on the street rather than on a vehicle.
func _draw_tram_flag(x: float) -> void:
	draw_rect(Rect2(x - 5.0, 250.0, 10.0, 60.0), Color(0.11, 0.11, 0.12))
	draw_rect(Rect2(x - 20.0, 216.0, 40.0, 36.0), C_BVG_YEL)
	draw_rect(Rect2(x - 20.0, 216.0, 40.0, 4.0), C_BVG_YEL.darkened(0.24))
	draw_rect(Rect2(x - 12.0, 224.0, 24.0, 5.0), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(x - 12.0, 234.0, 24.0, 10.0), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(x - 9.0, 236.0, 7.0, 6.0), C_BVG_YEL)
	draw_rect(Rect2(x + 2.0, 236.0, 7.0, 6.0), C_BVG_YEL)


# The Ampelmännchen. Not a generic pedestrian signal — he has a hat, he leans
# forward, and he is the one piece of the DDR that everybody kept.
func _draw_ampelmann(x: float) -> void:
	var y: float = 248.0
	draw_rect(Rect2(x - 5.0, y, 10.0, 62.0), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(x - 16.0, y - 64.0, 32.0, 68.0), Color(0.075, 0.075, 0.085))
	var walk: bool = fmod(_t, 8.0) < 5.0
	var red: Color = Color(C_AMPEL_R.r, C_AMPEL_R.g, C_AMPEL_R.b, 0.30 if walk else 0.95)
	draw_circle(Vector2(x, y - 48.0), 4.0, red)
	draw_rect(Rect2(x - 8.0, y - 52.0, 16.0, 3.0), red)
	draw_rect(Rect2(x - 2.0, y - 44.0, 4.0, 12.0), red)
	draw_rect(Rect2(x - 9.0, y - 42.0, 18.0, 3.0), red)
	var grn: Color = Color(C_AMPEL_G.r, C_AMPEL_G.g, C_AMPEL_G.b, 0.95 if walk else 0.28)
	draw_circle(Vector2(x + 1.0, y - 24.0), 4.0, grn)
	draw_rect(Rect2(x - 7.0, y - 28.0, 16.0, 3.0), grn)
	draw_rect(Rect2(x - 1.0, y - 20.0, 4.0, 10.0), grn)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 1, y - 10), Vector2(x + 3, y - 10),
		Vector2(x + 8, y - 3), Vector2(x + 4, y - 3),
	]), grn)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 1, y - 10), Vector2(x + 2, y - 10),
		Vector2(x - 5, y - 3), Vector2(x - 8, y - 3),
	]), grn)
	draw_rect(Rect2(x - 8.0, y - 19.0, 14.0, 3.0), grn)


# ── Lower pavement ────────────────────────────────────────────────────────────

func _draw_far_side() -> void:
	_draw_plane_tree(186.0, 616.0, 1.0)
	_draw_bench(350.0)
	_draw_litfass(460.0)
	_draw_spielplatz(556.0)
	_draw_glascontainer(1030.0)


# Somebody repainted this bench. Badly, and by hand, and not because they were
# asked to. The alien has walked through two cities and not seen that yet.
func _draw_bench(x: float) -> void:
	draw_rect(Rect2(x - 52.0, 600.0, 104.0, 8.0), Color(0, 0, 0, 0.20))
	for s in range(5):
		draw_rect(Rect2(x - 50.0, 562.0 + float(s) * 8.0, 100.0, 6.0),
			Color(0.220, 0.318, 0.259).lightened(0.03 * float(s % 2)))
	draw_rect(Rect2(x - 46.0, 574.0, 8.0, 28.0), Color(0.129, 0.129, 0.141))
	draw_rect(Rect2(x + 38.0, 574.0, 8.0, 28.0), Color(0.129, 0.129, 0.141))
	# The brush marks went the wrong way on the top slat and nobody minded
	for b in range(7):
		draw_rect(Rect2(x - 44.0 + float(b) * 13.0, 562.0, 3.0, 6.0),
			Color(1, 1, 1, 0.10))


# Litfaßsäule — the fat advertising column, a Berlin invention, still the only
# thing on the pavement that is round. Posters for things happening in rooms the
# alien cannot get into.
func _draw_litfass(x: float) -> void:
	var top: float = 482.0
	draw_rect(Rect2(x - 26.0, top, 52.0, 120.0), Color(0.145, 0.130, 0.155))
	draw_rect(Rect2(x - 26.0, top, 10.0, 120.0), Color(0.175, 0.158, 0.185))
	draw_rect(Rect2(x + 16.0, top, 10.0, 120.0), Color(0.105, 0.095, 0.115))
	var hues := [Color(0.620, 0.180, 0.220), Color(0.160, 0.300, 0.520),
		Color(0.720, 0.580, 0.160)]
	for i in range(3):
		var py: float = top + 12.0 + float(i) * 34.0
		draw_rect(Rect2(x - 22.0, py, 44.0, 28.0), hues[i % hues.size()].darkened(0.25))
		draw_rect(Rect2(x - 18.0, py + 4.0, 36.0, 3.0), Color(1, 1, 1, 0.30))
		draw_rect(Rect2(x - 18.0, py + 11.0, 26.0, 2.0), Color(1, 1, 1, 0.18))
	draw_rect(Rect2(x - 30.0, top - 8.0, 60.0, 10.0), Color(0.095, 0.085, 0.105))
	draw_rect(Rect2(x - 28.0, 598.0, 56.0, 6.0), Color(0, 0, 0, 0.28))
	# Tagged round the base, like every one of them
	draw_line(Vector2(x - 22.0, 590.0), Vector2(x + 18.0, 578.0),
		TAG_INKS[1], 2.4)


# The Spielplatz. Fenced, gated, raked, and in use. A city that builds this on
# a corner plot worth a fortune is telling you something about itself, and it is
# the first sentence the alien has understood without a word in it.
func _draw_spielplatz(x: float) -> void:
	draw_rect(Rect2(x + 18.0, 552.0, 330.0, VH - 552.0), C_SAND.darkened(0.30))
	draw_circle(Vector2(x + 176.0, 612.0), 78.0, C_SAND)
	draw_circle(Vector2(x + 88.0, 626.0), 46.0, C_SAND)
	# Raked. Somebody did that this morning, and it will not last the day.
	for r in range(7):
		draw_rect(Rect2(x + 108.0, 588.0 + float(r) * 8.0, 136.0, 1.0),
			Color(0, 0, 0, 0.09))
	_draw_climbing_frame(x + 134.0)
	# The fence: green, waist high, and it has a gate. The gate is the point.
	for side in range(2):
		var fx: float = x + float(side) * 330.0
		draw_rect(Rect2(fx, 522.0, 18.0, 126.0), C_PLAY_RAIL)
		draw_rect(Rect2(fx + 4.0, 522.0, 4.0, 126.0), C_PLAY_RAIL.lightened(0.18))
	_draw_fence_run(x, 130.0)
	_draw_fence_run(x + 210.0, 138.0)
	_draw_mitten(x + 96.0, 534.0)


func _draw_fence_run(x: float, w: float) -> void:
	draw_rect(Rect2(x, 522.0, w, 8.0), C_PLAY_RAIL)
	draw_rect(Rect2(x, 522.0, w, 2.0), C_PLAY_RAIL.lightened(0.20))
	draw_rect(Rect2(x, 544.0, w, 6.0), C_PLAY_RAIL)
	var bars: int = int(w / 13.0)
	for b in range(bars):
		draw_rect(Rect2(x + 4.0 + float(b) * 13.0, 522.0, 3.0, 30.0), C_PLAY_RAIL)


# Larch, weathered grey-brown, a slide down one side and a rope up the other.
func _draw_climbing_frame(x: float) -> void:
	draw_rect(Rect2(x - 44.0, 624.0, 92.0, 8.0), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(x - 42.0, 556.0, 84.0, 12.0), C_PLAY_WOOD)
	draw_rect(Rect2(x - 42.0, 556.0, 84.0, 3.0), C_PLAY_WOOD.lightened(0.18))
	for p in range(2):
		draw_rect(Rect2(x - 40.0 + float(p) * 76.0, 560.0, 10.0, 68.0),
			C_PLAY_WOOD.darkened(0.20))
	draw_rect(Rect2(x - 34.0, 568.0, 68.0, 26.0), C_PLAY_WOOD.darkened(0.10))
	# The slide, and it is the only steel here that has been polished by use
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + 34, 570), Vector2(x + 46, 570),
		Vector2(x + 62, 626), Vector2(x + 50, 626),
	]), Color(0.545, 0.565, 0.588))
	# Knotted rope, and it moves, because something on a playground always is
	var sway: float = sin(_t * 0.9) * 3.0
	draw_line(Vector2(x - 30.0, 566.0), Vector2(x - 38.0 + sway, 620.0),
		Color(0.478, 0.416, 0.310), 2.6)
	draw_circle(Vector2(x - 36.0 + sway * 0.7, 598.0), 3.0, Color(0.478, 0.416, 0.310))


# A child's mitten. Somebody found it on the pavement and tied it to the fence
# at the height a four-year-old looks, so that she would find it herself.
# Nothing in this game is kinder than that and nobody was paid to do it.
func _draw_mitten(x: float, y: float) -> void:
	draw_line(Vector2(x, y - 12.0), Vector2(x, y), Color(0.72, 0.70, 0.66, 0.8), 1.4)
	var sway: float = sin(_t * 1.1) * 1.6
	draw_rect(Rect2(x - 6.0 + sway, y, 12.0, 15.0), C_MITTEN)
	draw_rect(Rect2(x - 6.0 + sway, y, 12.0, 3.0), C_MITTEN.lightened(0.20))
	draw_rect(Rect2(x + 5.0 + sway, y + 4.0, 5.0, 7.0), C_MITTEN.darkened(0.10))
	draw_rect(Rect2(x - 4.0 + sway, y + 11.0, 8.0, 3.0), C_MITTEN.darkened(0.24))


# Glascontainer. Three of them, sorted by colour, and there is a sign saying
# what hours you may not use them — which is the most German object in Berlin.
func _draw_glascontainer(x: float) -> void:
	var lids := [Color(0.239, 0.420, 0.259), Color(0.360, 0.300, 0.180),
		Color(0.741, 0.749, 0.741)]
	for i in range(3):
		var cx: float = x - 46.0 + float(i) * 31.0
		draw_rect(Rect2(cx, 556.0, 28.0, 54.0), Color(0.196, 0.212, 0.220))
		draw_rect(Rect2(cx, 552.0, 28.0, 6.0), lids[i % lids.size()])
		draw_rect(Rect2(cx + 9.0, 566.0, 10.0, 5.0), Color(0.05, 0.05, 0.06))
	draw_rect(Rect2(x - 48.0, 606.0, 92.0, 6.0), Color(0, 0, 0, 0.22))
	draw_line(Vector2(x - 40.0, 596.0), Vector2(x + 24.0, 584.0), TAG_INKS[2], 2.6)
