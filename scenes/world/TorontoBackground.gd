extends Node2D

# Toronto. Five districts, and the two facts that shape the plates are that
# half the people in this city were born somewhere else, and that everything
# faces a lake you cannot see the far side of.
#
# DOWNTOWN is the arrival. The CN Tower is 553 metres and was the tallest
# freestanding structure on earth for thirty-two years; the street is at the
# bottom of it, so the plate shows the hexagonal concrete shaft and the three
# buttress legs and nothing else, because nothing else fits. Behind it the
# bank towers: one set black, one set gold, and the gold is not paint - there
# is real gold in the glass, twenty-four kilograms of it.
#
# KENSINGTON MARKET is Victorian houses that were never converted so much as
# repurposed - the shop is in the front room, the produce is on what was the
# garden, and every one of them is painted a different colour.
#
# GERRARD is the India Bazaar: a low commercial strip of sari shops and gold
# jewellers, with the whole stock in the window because the whole stock in the
# window is the point.
#
# THE DISTILLERY is the largest surviving group of Victorian industrial
# buildings in North America. Red brick, cast iron, cobbles, and no cars.
#
# SCARBOROUGH is post-war slab apartments and strip malls, and at the end of
# it a ninety-metre cliff of layered sediment dropping straight into the lake.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "downtown"
# "downtown" | "kensington" | "gerrard" | "distillery" | "scarborough"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.055, 0.063, 0.110)
const C_SKY_MID  := Color(0.098, 0.114, 0.180)
const C_SKY_LOW  := Color(0.204, 0.180, 0.208)
const C_SKY_HAZE := Color(0.353, 0.278, 0.239)

const C_DAY_HI   := Color(0.400, 0.529, 0.678)
const C_DAY_MID  := Color(0.616, 0.702, 0.769)
const C_DAY_LOW  := Color(0.831, 0.855, 0.851)

const C_CONC     := Color(0.678, 0.667, 0.643)    # the tower shaft
const C_CONC_D   := Color(0.541, 0.529, 0.502)
const C_BLACK_T  := Color(0.145, 0.153, 0.169)    # the TD towers
const C_GOLD_T   := Color(0.788, 0.635, 0.290)    # and the gold ones
const C_BRICK    := Color(0.573, 0.318, 0.259)    # Distillery, Kensington
const C_BRICK_D  := Color(0.447, 0.251, 0.208)
const C_IRON     := Color(0.161, 0.169, 0.180)
const C_GLASS    := Color(0.149, 0.192, 0.235)
const C_LEAF     := Color(0.212, 0.337, 0.259)
const C_WARM     := Color(1.0, 0.867, 0.639)
const C_INK      := Color(0.110, 0.106, 0.102)
const C_SLAB     := Color(0.588, 0.573, 0.545)    # Scarborough concrete
const C_BLUFF    := Color(0.729, 0.671, 0.549)    # the cliff, layered
const C_LAKE     := Color(0.153, 0.318, 0.400)
const C_RED      := Color(0.729, 0.220, 0.196)    # the streetcars

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
		"kensington":  _draw_kensington()
		"gerrard":     _draw_gerrard()
		"distillery":  _draw_distillery()
		"scarborough": _draw_scarborough()
		_:             _draw_downtown()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_BRICK.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 93)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.24, 0.28, 0.32), 0.05)
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Downtown ─────────────────────────────────────────────────────────────────

func _draw_downtown() -> void:
	# The bank towers, either side. One set black and one set gold, and the
	# gold is twenty-four kilos of real gold in the glass.
	for i in range(6):
		var tx: float = -70.0 + float(i) * 214.0
		if tx > 330.0 and tx < 700.0:
			continue
		var th: float = 26.0 + float((i * 19) % 3) * 30.0
		var body: Color = C_BLACK_T if i % 2 == 0 else C_GOLD_T.darkened(0.44)
		var pane: Color = C_GLASS if i % 2 == 0 else C_GOLD_T.darkened(0.20)
		CA.block(self, tx, 172.0, th, GROUND_Y, body, body.darkened(0.20))
		var bands: int = int((GROUND_Y - th) / 13.0)
		for b in range(bands):
			draw_rect(Rect2(tx + 7.0, th + 7.0 + float(b) * 13.0, 158.0, 8.0),
				pane)
			# The TD towers have the mullions running the full height and
			# nothing else, which is the entire building.
			for m in range(9):
				draw_rect(Rect2(tx + 7.0 + float(m) * 18.0, th, 3.0,
					GROUND_Y - th), body.lightened(0.10))
	_draw_cn_tower(516.0)


# 553 metres. The street is at the foot of it, so this is the shaft and the
# three legs and that is all there is room for - the pod is two hundred metres
# above the top of this image and the antenna is another two hundred past that.
func _draw_cn_tower(cx: float) -> void:
	var base: float = CA.PAVE_TOP
	var lit: bool = not GameState.is_morning()
	# Three concrete faces at genuinely different values. The first pass used
	# three tones a few per cent apart and the tallest thing in the country
	# came out as a flat grey slab.
	var face_l: Color = C_CONC_D.darkened(0.22)
	var face_c: Color = C_CONC
	var face_r: Color = C_CONC_D
	if lit:
		face_l = face_l.darkened(0.10)
		face_c = face_c.lightened(0.04)

	# It tapers. Half-width at the pavement against half-width off the top of
	# the plate - about a hundred and fifty metres of it is in frame.
	var w_lo: float = 74.0
	var w_hi: float = 50.0
	var top: float = -40.0

	# The buttress flare: the shaft swells into three legs over the last
	# forty metres, which is the shape everybody actually recognises.
	var flare: float = base - 96.0
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx + side * w_lo, flare),
			Vector2(cx + side * 146.0, base),
			Vector2(cx + side * 96.0, base),
			Vector2(cx + side * w_lo * 0.62, flare),
		]), face_r if side > 0.0 else face_l)

	# The shaft, in three vertical facets.
	var facets := [[-1.00, -0.34, face_l], [-0.34, 0.30, face_c],
		[0.30, 1.00, face_r]]
	for f in facets:
		var a: float = float(f[0])
		var b: float = float(f[1])
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx + a * w_hi, top), Vector2(cx + b * w_hi, top),
			Vector2(cx + b * w_lo, base), Vector2(cx + a * w_lo, base),
		]), f[2])

	# The elevator run and the seams between facets, both of which read as
	# vertical lines that follow the taper.
	for e in [-0.34, 0.30]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx + e * w_hi - 3.0, top), Vector2(cx + e * w_hi + 3.0, top),
			Vector2(cx + e * w_lo + 4.0, base), Vector2(cx + e * w_lo - 4.0, base),
		]), C_CONC_D.darkened(0.34))
	# The slip-form lifts: the tower was poured in one continuous climb and
	# the horizontal joints from it are visible all the way up.
	for r in range(13):
		var ry: float = 2.0 + float(r) * 24.0
		var t: float = (ry - top) / (base - top)
		var hw: float = lerp(w_hi, w_lo, clampf(t, 0.0, 1.0))
		draw_rect(Rect2(cx - hw, ry, hw * 2.0, 1.6), C_CONC_D.darkened(0.16))

	# The base building it comes out of.
	draw_rect(Rect2(cx - 196.0, base - 62.0, 392.0, 62.0), C_CONC_D.darkened(0.20))
	draw_rect(Rect2(cx - 196.0, base - 62.0, 392.0, 6.0), C_CONC.darkened(0.06))
	for w in range(12):
		draw_rect(Rect2(cx - 178.0 + float(w) * 31.0, base - 46.0, 21.0, 30.0),
			C_GLASS.lightened(0.06))

	if lit:
		# Lit from below in whatever colour the night has been given over to,
		# which is a very Toronto way to run a national landmark.
		var glow := Color(0.36, 0.62, 0.86)
		for k in range(9):
			var f2: float = float(k) / 8.0
			var gy: float = base - 40.0 - f2 * (base - top)
			var ghw: float = lerp(w_lo, w_hi, f2) + 10.0
			draw_rect(Rect2(cx - ghw, gy, ghw * 2.0, 30.0),
				Color(glow.r, glow.g, glow.b, 0.075 * (1.0 - f2 * 0.7)))
		draw_rect(Rect2(cx - w_lo * 0.34, top, w_lo * 0.24, base - top),
			Color(glow.r, glow.g, glow.b, 0.14))


func _draw_kensington() -> void:
	CA.far_mass(self, 186.0, C_BRICK_D.darkened(0.44), C_BRICK_D.darkened(0.28),
		8, 29)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 88.0 + float((i * 13) % 3) * 16.0
		var top: float = 146.0 + float((i * 7) % 2) * 10.0
		# A Victorian house with the front room turned into a shop and the
		# whole thing painted, and the paint is the point.
		var body: Color = _kens_hue(i)
		CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.20))
		var gable := PackedVector2Array([
			Vector2(x - 4.0, top), Vector2(x + w * 0.5, top - 40.0),
			Vector2(x + w + 4.0, top),
		])
		draw_colored_polygon(gable, body.darkened(0.26))
		CA.window_row(self, x + 10.0, w - 20.0, top + 16.0, 2, 17.0, 24.0,
			C_GLASS, body.lightened(0.26), (i * 11) % 15)
		# The shopfront, and the stock out on what used to be the garden.
		draw_rect(Rect2(x + 4.0, GROUND_Y - 66.0, w - 8.0, 66.0),
			body.darkened(0.34))
		draw_rect(Rect2(x + 10.0, GROUND_Y - 58.0, w - 20.0, 44.0),
			C_GLASS.lightened(0.10))
		draw_rect(Rect2(x - 6.0, GROUND_Y - 74.0, w + 12.0, 10.0),
			body.lightened(0.10))
		x += w + 3.0
		i += 1
	for c in range(14):
		draw_rect(Rect2(70.0 + float(c) * 74.0, CA.PAVE_TOP + 30.0, 52.0, 22.0),
			C_BRICK.darkened(0.30))
		for k in range(3):
			draw_circle(Vector2(84.0 + float(c) * 74.0 + float(k) * 12.0,
				CA.PAVE_TOP + 28.0), 7.0,
				[C_RED, C_LEAF, C_GOLD_T][(c + k) % 3])


# Every house on this block is a different colour and none of them agreed
# on it with any of the others.
const KENS := [Color(0.792, 0.541, 0.286), Color(0.384, 0.529, 0.451),
	Color(0.686, 0.310, 0.310), Color(0.478, 0.451, 0.635),
	Color(0.749, 0.678, 0.361)]


func _kens_hue(i: int) -> Color:
	return KENS[i % KENS.size()]


func _draw_gerrard() -> void:
	CA.far_mass(self, 196.0, C_BRICK_D.darkened(0.46), C_BRICK_D.darkened(0.30),
		7, 41)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 104.0 + float((i * 17) % 3) * 18.0
		var top: float = 168.0
		CA.block(self, x, w, top, GROUND_Y, C_BRICK.darkened(0.10),
			C_BRICK_D.darkened(0.10))
		CA.band(self, x - 3.0, w + 6.0, top - 10.0, 10.0, C_BRICK.lightened(0.14))
		CA.window_row(self, x + 10.0, w - 20.0, top + 14.0, 2, 18.0, 20.0,
			C_GLASS, C_BRICK.lightened(0.18), (i * 13) % 15)
		# The whole stock in the window, which is the entire retail strategy.
		draw_rect(Rect2(x + 6.0, GROUND_Y - 70.0, w - 12.0, 70.0),
			C_BRICK.darkened(0.34))
		draw_rect(Rect2(x + 12.0, GROUND_Y - 62.0, w - 24.0, 52.0),
			C_GLASS.lightened(0.14))
		for k in range(5):
			var kx: float = x + 20.0 + float(k) * ((w - 40.0) / 5.0)
			draw_rect(Rect2(kx, GROUND_Y - 56.0, 12.0, 40.0),
				[C_RED, C_GOLD_T, C_LEAF, Color(0.541, 0.302, 0.635)][k % 4])
		# The gold shops light their windows harder than anything else here.
		if i % 3 == 1 and not GameState.is_morning():
			draw_rect(Rect2(x + 12.0, GROUND_Y - 62.0, w - 24.0, 52.0),
				Color(C_GOLD_T.r, C_GOLD_T.g, C_GOLD_T.b, 0.22))
		x += w + 4.0
		i += 1


func _draw_distillery() -> void:
	CA.far_mass(self, 176.0, C_BRICK_D.darkened(0.42), C_BRICK_D.darkened(0.26),
		8, 17)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 132.0 + float((i * 11) % 3) * 22.0
		var top: float = 108.0 + float((i * 19) % 3) * 18.0
		CA.block(self, x, w, top, GROUND_Y, C_BRICK, C_BRICK_D)
		# Segmental arched windows in tall bays, which is what a Victorian
		# industrial building is: a lot of window held up by a little brick.
		var bays: int = maxi(2, int(w / 44.0))
		for b in range(bays):
			var bx: float = x + 10.0 + float(b) * ((w - 20.0) / float(bays))
			var bw: float = (w - 20.0) / float(bays) - 10.0
			for f in range(3):
				var fy: float = top + 24.0 + float(f) * 44.0
				if fy > GROUND_Y - 44.0:
					break
				draw_rect(Rect2(bx, fy, bw, 32.0), C_GLASS.lightened(0.06))
				draw_circle(Vector2(bx + bw * 0.5, fy), bw * 0.5,
					C_BRICK.lightened(0.12))
				draw_rect(Rect2(bx, fy, bw, 4.0), C_BRICK.lightened(0.16))
		CA.band(self, x - 4.0, w + 8.0, top - 12.0, 12.0, C_BRICK.lightened(0.18))
		x += w + 5.0
		i += 1
	# The chimney, which every distillery had and this one kept.
	draw_rect(Rect2(880.0, 34.0, 40.0, GROUND_Y - 34.0), C_BRICK.darkened(0.14))
	draw_rect(Rect2(874.0, 34.0, 52.0, 14.0), C_BRICK.lightened(0.10))
	for r in range(9):
		draw_rect(Rect2(880.0, 60.0 + float(r) * 22.0, 40.0, 3.0),
			C_BRICK_D.darkened(0.10))


func _draw_scarborough() -> void:
	# The lake, and the cliff going into it.
	draw_rect(Rect2(0.0, 150.0, CA.VW, 80.0), C_LAKE)
	for i in range(9):
		draw_line(Vector2(0.0, 158.0 + float(i) * 8.0),
			Vector2(CA.VW, 158.0 + float(i) * 8.0), C_LAKE.lightened(0.10), 1.0)
	# Ninety metres of layered sediment, and every layer a different age.
	var bluff := PackedVector2Array([
		Vector2(620.0, 230.0), Vector2(680.0, 128.0), Vector2(790.0, 96.0),
		Vector2(940.0, 88.0), Vector2(1160.0, 96.0), Vector2(1160.0, 230.0),
	])
	draw_colored_polygon(bluff, C_BLUFF)
	for r in range(11):
		draw_line(Vector2(632.0, 220.0 - float(r) * 12.0),
			Vector2(1160.0, 196.0 - float(r) * 10.0),
			C_BLUFF.darkened(0.10 + 0.04 * float(r % 3)), 3.0)
	for g in range(9):
		draw_circle(Vector2(760.0 + float(g) * 46.0, 92.0 - float((g * 7) % 3) * 6.0),
			26.0, C_LEAF.darkened(0.18))
	# Slab apartments, set well back, with grass in front of them.
	for i in range(4):
		var tx: float = -40.0 + float(i) * 168.0
		if tx > 560.0:
			break
		CA.block(self, tx, 130.0, 96.0 + float((i * 13) % 3) * 16.0, GROUND_Y,
			C_SLAB, C_SLAB.darkened(0.20))
		for f in range(9):
			var fy: float = 112.0 + float((i * 13) % 3) * 16.0 + float(f) * 15.0
			if fy > GROUND_Y - 20.0:
				break
			CA.window_row(self, tx + 6.0, 118.0, fy, 6, 12.0, 10.0,
				C_GLASS, C_SLAB.darkened(0.30), (i * 7 + f * 19) % 31)


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.443, 0.435, 0.420)
	var road: Color = Color(0.176, 0.180, 0.192)
	if district == "scarborough":
		pave = Color(0.478, 0.478, 0.451)
	CA.ground(self, pave, road, pave.darkened(0.12))
	if district == "distillery":
		# Cobbles, and no cars have been allowed on them since 1990.
		CA.setts(self, CA.PAVE_TOP, 224.0, 16.0,
			Color(0.153, 0.145, 0.157, 0.55))
	else:
		CA.slabs(self, CA.PAVE_TOP, 80.0, 64.0, 40.0, pave.lightened(0.10))
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
		CA.kerb(self, CA.FAR_TOP, pave.lightened(0.18))
		CA.slabs(self, CA.FAR_TOP, 132.0, 64.0, 40.0, pave.lightened(0.08))
	if district == "downtown" or district == "gerrard":
		# Streetcar rails down the middle of the road, in the traffic, which
		# is how this city has always run them.
		draw_rect(Rect2(0.0, CA.ROAD_TOP + 52.0, CA.VW, 3.0),
			Color(0.545, 0.541, 0.529))
		draw_rect(Rect2(0.0, CA.ROAD_TOP + 86.0, CA.VW, 3.0),
			Color(0.545, 0.541, 0.529))
	if not GameState.is_morning():
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.30, 0.32, 0.44, 0.13), _t)


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	match district:
		"kensington":
			for i in range(4):
				CA.lamp(self, 110.0 + float(i) * 282.0, CA.PAVE_TOP + 62.0,
					86.0, C_IRON, C_WARM, on)
		"gerrard":
			for i in range(4):
				CA.lamp(self, 130.0 + float(i) * 274.0, CA.PAVE_TOP + 62.0,
					88.0, C_IRON, C_WARM, on)
			CA.stall(self, 640.0, CA.PAVE_TOP + 58.0, 124.0, C_RED,
				[C_GOLD_T, C_LEAF, Color(0.729, 0.290, 0.208)])
		"distillery":
			for i in range(5):
				CA.lamp(self, 90.0 + float(i) * 246.0, CA.PAVE_TOP + 62.0,
					96.0, C_IRON, C_WARM, on)
			CA.bollard(self, 520.0, CA.PAVE_TOP + 60.0, C_IRON)
			CA.bollard(self, 560.0, CA.PAVE_TOP + 60.0, C_IRON)
		"scarborough":
			for i in range(5):
				CA.tree(self, 120.0 + float(i) * 210.0, CA.PAVE_TOP + 4.0, 82.0,
					Color(0.376, 0.318, 0.263), C_LEAF, 1.1)
			CA.bin(self, 700.0, CA.PAVE_TOP + 64.0, Color(0.255, 0.263, 0.271))
		_:
			for i in range(5):
				CA.lamp(self, 96.0 + float(i) * 242.0, CA.PAVE_TOP + 62.0,
					100.0, Color(0.239, 0.247, 0.259), C_WARM, on)
			CA.bin(self, 860.0, CA.PAVE_TOP + 64.0, Color(0.255, 0.263, 0.271))
	if on:
		CA.motes(self, 20, Color(0.90, 0.90, 0.84, 0.08), _t, 10.0, 20.0, 1.3)


# ── Collision ────────────────────────────────────────────────────────────────

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	match district:
		"gerrard":
			out.append(Rect2(640.0, 330.0, 124.0, 22.0))
		"distillery":
			out.append(Rect2(500.0, 336.0, 80.0, 14.0))
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
	if district != "kensington":
		return []
	return [
		[Vector2(880.0, CA.PAVE_TOP + 64.0), 1, 0],
	]
