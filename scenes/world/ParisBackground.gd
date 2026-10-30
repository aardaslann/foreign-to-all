extends Node2D

# Paris. Five districts, and the one fact that organises all of them.
#
# Paris does not stack. After the Tour Montparnasse went up in 1973 the city
# banned height in the centre outright, so the towers were pushed out past the
# boundary to LA DÉFENSE and the middle of Paris stayed at seven storeys. That
# is why the skyline of this city is a flat cream line with a lattice mast and
# a white dome sticking out of it, and why the one district with skyscrapers in
# it is technically not Paris at all. The plates are drawn to make that legible.
#
# CHAMP-DE-MARS is the arrival. The tower is iron lattice, four splayed legs,
# arches between them, and it is not grey — it is a graded bronze-brown that
# gets lighter towards the top so the whole thing reads as one colour against
# the sky. Around it: Haussmann. Cream limestone, a cornice line every building
# on the street obeys, wrought iron running along the second and fifth floors,
# and grey zinc mansards on top. The zinc is the real colour of Paris roofs.
#
# LE MARAIS escaped Haussmann entirely, so nothing lines up: different heights,
# different centuries, narrow pavements, carriage gates. Place des Vosges is
# red brick with stone quoins and steep blue slate, from 1612.
#
# MONTMARTRE is a hill with stairs. Sacré-Cœur is travertine that whitens in
# rain, so it is the brightest object in the game. Two windmills left, ivy,
# and small houses that do not behave like the rest of the city.
#
# BELLEVILLE is the other Paris: a hill of cheap low buildings with 1970s
# social housing towers dropped straight into the middle of them, painted
# walls, Chinese and North African shopfronts on the same block.
#
# LA DÉFENSE is a concrete deck with the roads and the trains underneath it,
# a hollow marble cube lined up on the same axis as the Arc de Triomphe, and
# the tallest towers in France standing on top.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "champdemars"
# "champdemars" | "marais" | "montmartre" | "belleville" | "ladefense"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Two colours carry this city: Lutetian limestone, which is a warm pale cream,
# and zinc, which is a blue-grey that goes almost violet when it is wet.
const C_SKY_ZEN  := Color(0.063, 0.067, 0.129)
const C_SKY_MID  := Color(0.106, 0.106, 0.176)
const C_SKY_LOW  := Color(0.196, 0.169, 0.204)
const C_SKY_HAZE := Color(0.322, 0.243, 0.220)

const C_DAY_HI   := Color(0.545, 0.596, 0.659)
const C_DAY_MID  := Color(0.678, 0.694, 0.706)
const C_DAY_LOW  := Color(0.804, 0.784, 0.741)

const C_STONE    := Color(0.792, 0.757, 0.678)    # Lutetian limestone
const C_STONE_B  := Color(0.694, 0.663, 0.592)
const C_STONE_D  := Color(0.573, 0.549, 0.494)
const C_ZINC     := Color(0.412, 0.427, 0.478)    # the roofs
const C_ZINC_LIT := Color(0.510, 0.525, 0.573)
const C_IRON     := Color(0.180, 0.184, 0.196)    # balcony rail, tower, lamp
const C_BRICK    := Color(0.545, 0.318, 0.267)    # Place des Vosges
const C_SLATE    := Color(0.310, 0.337, 0.400)
const C_GLASS    := Color(0.169, 0.196, 0.231)
const C_AWN_RED  := Color(0.529, 0.161, 0.161)    # café awnings
const C_GOLD     := Color(0.847, 0.706, 0.396)
const C_WARM     := Color(1.0, 0.867, 0.620)
const C_INK      := Color(0.125, 0.118, 0.114)
const C_LEAF     := Color(0.204, 0.278, 0.212)

const C_TOWER_BR := Color(0.396, 0.310, 0.243)    # "Eiffel Tower Brown", low
const C_TOWER_HI := Color(0.478, 0.396, 0.318)    # and the same paint up top
const C_SACRE    := Color(0.902, 0.886, 0.843)    # travertine, self-whitening
const C_MARBLE   := Color(0.859, 0.855, 0.847)    # the Grande Arche
const C_CONCRETE := Color(0.478, 0.475, 0.467)
const C_TOWER_G  := Color(0.267, 0.310, 0.365)

const GROUND_Y := 238.0

# The opening in the street wall that the tower stands in.
const GAP_L := 470.0
const GAP_R := 942.0


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
			C_AWN_RED, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_STONE, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"marais":     _draw_marais()
		"montmartre": _draw_montmartre()
		"belleville": _draw_belleville()
		"ladefense":  _draw_ladefense()
		_:            _draw_champdemars()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_STONE_B.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 51)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.24, 0.25, 0.31), 0.05)
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.05))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Haussmann ────────────────────────────────────────────────────────────────
# One terrace obeying one cornice line, because that is the law that made this
# city look like itself: a height limit, a stone, an angle for the roof, and
# iron on the second and fifth floors and nowhere else.
func _haussmann(x: float, w: float, top: float, lit: int) -> void:
	CA.block(self, x, w, top, GROUND_Y, C_STONE, C_STONE_B)
	# The mansard: a steep zinc roof with dormers punched into it.
	var mans: float = 34.0
	draw_rect(Rect2(x - 2.0, top - mans, w + 4.0, mans), C_ZINC)
	draw_rect(Rect2(x - 2.0, top - mans, w + 4.0, 4.0), C_ZINC_LIT)
	var dorms: int = maxi(1, int(w / 46.0))
	for i in range(dorms):
		var dx: float = x + w * (float(i) + 0.5) / float(dorms)
		draw_rect(Rect2(dx - 9.0, top - mans + 8.0, 18.0, 20.0), C_ZINC_LIT)
		CA.window(self, dx - 6.0, top - mans + 12.0, 12.0, 14.0,
			C_GLASS, C_STONE_D, (lit >> i) & 1 == 1)
	# The cornice, and then the floors under it.
	CA.band(self, x - 3.0, w + 6.0, top, 5.0, C_STONE_D)
	var floors: int = 5
	var fh: float = (GROUND_Y - top) / float(floors)
	for f in range(floors):
		var fy: float = top + fh * float(f) + 10.0
		var count: int = maxi(2, int(w / 40.0))
		CA.window_row(self, x + 8.0, w - 16.0, fy, count, 15.0, fh - 20.0,
			C_GLASS, C_STONE_D, lit >> f)
		# Iron runs the full width on the second and fifth floors only.
		if f == 1 or f == 4:
			CA.balcony(self, x + 4.0, fy + fh - 22.0, w - 8.0, C_IRON)


func _draw_champdemars() -> void:
	CA.far_mass(self, 196.0, C_STONE_D.darkened(0.35),
		C_STONE_D.darkened(0.2), 11, 41)
	# The terrace stops either side of the lawn. That gap is the Champ-de-Mars
	# itself, and it is the only reason you can see the thing you came for -
	# a continuous street wall would hide all 330 metres of it, which is what
	# the first version of this plate did.
	var x: float = -30.0
	var seed_i: int = 7
	while x < CA.VW + 30.0:
		var w: float = 118.0 + float(seed_i % 3) * 16.0
		if x + w < GAP_L or x > GAP_R:
			_haussmann(x, w, 84.0, (seed_i * 37) % 63)
		x += w + 4.0
		seed_i += 1
	_draw_eiffel()
	# Plane trees along the gravel allee, pollarded flat, and not in the gap.
	for i in range(7):
		var tx: float = 70.0 + float(i) * 168.0
		if tx > GAP_L - 30.0 and tx < GAP_R + 30.0:
			continue
		CA.tree(self, tx, CA.PAVE_TOP + 4.0, 74.0,
			Color(0.443, 0.408, 0.353), C_LEAF, 1.15)


# The tower. Four legs splayed out, arches slung between them, two platforms,
# and the mast. Drawn behind the terrace so it reads as being where it is —
# across the river and a long way up — rather than on this street.
# The tower, at the size it is.
#
# 330 metres, and the street is at the foot of it. Fitting all of that into
# 290 pixels of sky is what every previous version of this did, and it made
# the most famous object on the planet look like a garden ornament. So the
# plate shows what you would actually see standing on the Champ-de-Mars:
# four legs the width of the lawn, the arch, the first platform, and then it
# leaves the top of the frame and does not come back.
#
# Scale is honest. The base is 125 metres across and the first platform is at
# 57 metres, so at 3.7 pixels to the metre the feet span the whole gap and the
# platform sits near the top of the sky. The second platform, at 115 metres,
# is a hundred and thirty pixels above the ceiling of this image.
const EIF_CX    := 706.0
const EIF_FOOT  := 236.0        # half the base: 125m at 3.7 px/m
const EIF_PX_M  := 3.68
const EIF_P1_M  := 57.0         # first platform


func _eif_y(metres: float) -> float:
	return CA.PAVE_TOP - metres * EIF_PX_M


# Half-width at a given height, on the curve Eiffel used to put the wind load
# straight into the ground.
func _eif_w(metres: float) -> float:
	var f: float = clampf(metres / 330.0, 0.0, 1.0)
	return EIF_FOOT * pow(1.0 - f, 2.3) + 16.0


func _draw_eiffel() -> void:
	var p1y: float = _eif_y(EIF_P1_M)
	var w1: float = _eif_w(EIF_P1_M)

	# Four legs. The near pair is drawn lighter so the box reads as a box and
	# not as two flat A-frames.
	for side in [-1.0, 1.0]:
		for pair in [0, 1]:
			var scale: float = 1.0 if pair == 0 else 0.42
			var col: Color = C_TOWER_BR if pair == 0 				else C_TOWER_BR.lightened(0.12)
			var outer := PackedVector2Array()
			var inner := PackedVector2Array()
			for st in range(19):
				var m: float = EIF_P1_M * float(st) / 18.0
				var w: float = _eif_w(m) * scale
				var y: float = _eif_y(m)
				var thick: float = 46.0 - 26.0 * (m / EIF_P1_M)
				outer.append(Vector2(EIF_CX + side * w, y))
				inner.append(Vector2(EIF_CX + side * maxf(w - thick, 6.0), y))
			inner.reverse()
			var leg := outer.duplicate()
			leg.append_array(inner)
			draw_colored_polygon(leg, col)
			# Cross-bracing inside each leg.
			for st in range(0, 17, 2):
				var m2: float = EIF_P1_M * float(st) / 18.0
				var m3: float = EIF_P1_M * float(st + 2) / 18.0
				draw_line(
					Vector2(EIF_CX + side * _eif_w(m2) * scale, _eif_y(m2)),
					Vector2(EIF_CX + side * maxf(_eif_w(m3) * scale - 40.0, 6.0),
						_eif_y(m3)),
					col.darkened(0.16), 2.0)

	# The arch. It carries nothing; Eiffel added it because the public
	# expected a monument to have one, and it is the reason the silhouette
	# reads at a glance.
	var arch := PackedVector2Array()
	for st in range(33):
		var f: float = float(st) / 32.0
		var ax: float = EIF_CX - EIF_FOOT * 0.80 + EIF_FOOT * 1.60 * f
		arch.append(Vector2(ax, p1y + 26.0 + 92.0 * sin(f * PI)))
	draw_polyline(arch, C_TOWER_BR, 7.0, true)

	# The first platform, at 57 metres, running most of the width of the sky.
	draw_rect(Rect2(EIF_CX - w1 - 34.0, p1y - 8.0, (w1 + 34.0) * 2.0, 22.0),
		C_TOWER_BR)
	draw_rect(Rect2(EIF_CX - w1 - 34.0, p1y - 8.0, (w1 + 34.0) * 2.0, 6.0),
		C_TOWER_HI)
	for i in range(int(w1 / 12.0) * 2):
		draw_rect(Rect2(EIF_CX - w1 - 28.0 + float(i) * 12.0, p1y - 22.0,
			4.0, 14.0), C_TOWER_HI)

	# Above the platform the tower keeps going, out of the top of the frame.
	for side2 in [-1.0, 1.0]:
		var shaft := PackedVector2Array()
		var back := PackedVector2Array()
		for st in range(13):
			var m4: float = EIF_P1_M + float(st) * 6.0
			var y4: float = _eif_y(m4)
			if y4 < -40.0:
				break
			var w4: float = _eif_w(m4)
			shaft.append(Vector2(EIF_CX + side2 * w4, y4))
			back.append(Vector2(EIF_CX + side2 * maxf(w4 - 30.0, 8.0), y4))
		if shaft.size() < 2:
			continue
		back.reverse()
		shaft.append_array(back)
		draw_colored_polygon(shaft, C_TOWER_HI)


func _draw_marais() -> void:
	CA.far_mass(self, 214.0, C_STONE_D.darkened(0.4),
		C_STONE_D.darkened(0.25), 9, 13)
	# Nothing lines up. Every building is a different age and a different
	# height, which is exactly what surviving the rebuild looks like.
	var heights := [96.0, 132.0, 74.0, 118.0, 86.0, 148.0, 104.0]
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 92.0 + float((i * 29) % 4) * 22.0
		var top: float = float(heights[i % heights.size()])
		if i % 4 == 1:
			# Place des Vosges: brick with stone quoins and steep blue slate.
			CA.block(self, x, w, top, GROUND_Y, C_BRICK, C_BRICK.darkened(0.18))
			for q in range(6):
				CA.band(self, x, 11.0, top + float(q) * 26.0, 13.0, C_STONE)
				CA.band(self, x + w - 11.0, 11.0, top + float(q) * 26.0, 13.0,
					C_STONE)
			CA.roof(self, x, w, top, 40.0, C_SLATE)
			# The arcade at street level is the whole point of the square.
			var arcs: int = maxi(2, int(w / 52.0))
			for a in range(arcs):
				var ax: float = x + w * (float(a) + 0.5) / float(arcs)
				draw_rect(Rect2(ax - 20.0, GROUND_Y - 54.0, 40.0, 54.0),
					Color(0.153, 0.129, 0.129))
		else:
			CA.block(self, x, w, top, GROUND_Y, C_STONE_B, C_STONE_D)
			CA.roof(self, x, w, top, 26.0, C_ZINC)
			var floors: int = maxi(3, int((GROUND_Y - top) / 40.0))
			for f in range(floors):
				var fy: float = top + 14.0 + float(f) * 38.0
				if fy > GROUND_Y - 40.0:
					break
				CA.window_row(self, x + 7.0, w - 14.0, fy,
					maxi(2, int(w / 38.0)), 14.0, 22.0,
					C_GLASS, C_STONE_D, (i * 13 + f * 5) % 31)
				if f == 1:
					CA.shutters(self, x + 10.0, fy, 14.0, 22.0,
						Color(0.267, 0.298, 0.263))
		# The carriage gate. The Marais is mansions hidden behind these.
		if i % 3 == 2:
			draw_rect(Rect2(x + w * 0.5 - 26.0, GROUND_Y - 76.0, 52.0, 76.0),
				Color(0.204, 0.169, 0.141))
			draw_rect(Rect2(x + w * 0.5 - 26.0, GROUND_Y - 76.0, 52.0, 5.0),
				C_STONE_D)
		x += w + 3.0
		i += 1


func _draw_montmartre() -> void:
	CA.far_mass(self, 226.0, C_STONE_D.darkened(0.42),
		C_STONE_D.darkened(0.26), 8, 61)
	_draw_sacre_coeur()
	# The hill: the terrace steps down to the right instead of running level.
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 84.0 + float((i * 17) % 3) * 20.0
		var top: float = 186.0 + float(i) * 7.0
		CA.block(self, x, w, top, GROUND_Y, C_STONE_B, C_STONE_D)
		CA.roof(self, x, w, top, 24.0, C_ZINC)
		CA.window_row(self, x + 7.0, w - 14.0, top + 18.0,
			maxi(2, int(w / 36.0)), 13.0, 20.0, C_GLASS, C_STONE_D,
			(i * 11) % 27)
		CA.window_row(self, x + 7.0, w - 14.0, top + 58.0,
			maxi(2, int(w / 36.0)), 13.0, 20.0, C_GLASS, C_STONE_D,
			(i * 23) % 27)
		if i % 3 == 0:
			# Ivy, which does not happen anywhere else in this city.
			for v in range(9):
				draw_circle(Vector2(x + 8.0 + float(v % 3) * 9.0,
					top + 30.0 + float(v) * 7.0), 5.0,
					Color(0.157, 0.239, 0.169, 0.85))
		x += w + 3.0
		i += 1
	_draw_windmill(196.0, 168.0)
	# The stairs. Montmartre is mostly stairs with a handrail up the middle.
	for s in range(9):
		var sy: float = CA.PAVE_TOP + 2.0 + float(s) * 8.0
		draw_rect(Rect2(884.0 - float(s) * 5.0, sy,
			150.0 + float(s) * 10.0, 5.0), C_STONE_D)
	draw_rect(Rect2(958.0, CA.PAVE_TOP - 46.0, 4.0, 118.0), C_IRON)


func _draw_sacre_coeur() -> void:
	var cx: float = 548.0
	var base: float = 172.0
	# It stands on the top of the butte, which is the highest ground in the
	# city, so it belongs well above the roofline rather than peeping over it.
	# Travertine bleaches itself white in rain: this is the brightest object
	# in the game and it is meant to be.
	draw_rect(Rect2(cx - 148.0, base - 86.0, 296.0, 86.0), C_SACRE)
	draw_rect(Rect2(cx - 148.0, base - 86.0, 296.0, 5.0), C_SACRE.lightened(0.10))
	draw_rect(Rect2(cx - 156.0, base - 8.0, 312.0, 10.0), C_SACRE.darkened(0.08))
	# Three arches across the front, which is how the west end actually reads.
	for a in range(3):
		var ax: float = cx - 78.0 + float(a) * 78.0
		draw_rect(Rect2(ax - 26.0, base - 52.0, 52.0, 52.0),
			Color(0.318, 0.290, 0.337))
		draw_circle(Vector2(ax, base - 52.0), 26.0, Color(0.318, 0.290, 0.337))
		draw_circle(Vector2(ax, base - 52.0), 26.0, C_SACRE.darkened(0.04))
		draw_rect(Rect2(ax - 26.0, base - 52.0, 52.0, 52.0),
			Color(0.318, 0.290, 0.337))
	# The domes: one big one on a drum, two smaller, and the campanile behind
	# that is taller than any of them and that nobody ever remembers.
	var domes := [[-104.0, 34.0], [0.0, 56.0], [104.0, 34.0]]
	for d in domes:
		var dx: float = cx + float(d[0])
		var r: float = float(d[1])
		var drum: float = base - 86.0
		draw_rect(Rect2(dx - r * 0.86, drum - r * 0.55, r * 1.72, r * 0.55),
			C_SACRE.darkened(0.05))
		draw_circle(Vector2(dx, drum - r * 0.55), r, C_SACRE)
		draw_rect(Rect2(dx - r, drum - r * 0.55, r * 2.0, r * 0.6), C_SACRE)
		draw_rect(Rect2(dx - 3.0, drum - r * 0.55 - r - 20.0, 6.0, 22.0), C_SACRE)
		for w in range(5):
			CA.window(self, dx - r * 0.7 + float(w) * r * 0.34,
				drum - r * 0.5, 7.0, 15.0,
				Color(0.325, 0.294, 0.353), C_SACRE.darkened(0.16),
				not GameState.is_morning())
	draw_rect(Rect2(cx + 158.0, base - 176.0, 38.0, 176.0), C_SACRE)
	draw_rect(Rect2(cx + 158.0, base - 176.0, 10.0, 176.0),
		C_SACRE.lightened(0.06))
	draw_circle(Vector2(cx + 177.0, base - 176.0), 20.0, C_SACRE)
	draw_rect(Rect2(cx + 175.0, base - 212.0, 4.0, 18.0), C_SACRE)


func _draw_windmill(x: float, base: float) -> void:
	draw_rect(Rect2(x - 17.0, base - 62.0, 34.0, 62.0),
		Color(0.400, 0.353, 0.298))
	CA.roof(self, x - 17.0, 34.0, base - 62.0, 16.0, C_SLATE)
	var spin: float = _t * 0.22
	for i in range(4):
		var a: float = spin + float(i) * PI * 0.5
		var tip := Vector2(x + cos(a) * 44.0, base - 74.0 + sin(a) * 44.0)
		draw_line(Vector2(x, base - 74.0), tip, Color(0.278, 0.243, 0.204), 3.0)


func _draw_belleville() -> void:
	CA.far_mass(self, 206.0, C_CONCRETE.darkened(0.42),
		C_CONCRETE.darkened(0.28), 10, 29)
	# The clash: 1970s social housing slabs standing straight up out of a
	# street of small cheap buildings. Both are true at once, and the gap
	# between them is what the district looks like.
	for i in range(3):
		var tx: float = 96.0 + float(i) * 372.0
		var th: float = 44.0 + float((i * 31) % 3) * 22.0
		CA.block(self, tx, 108.0, th, GROUND_Y - 40.0,
			C_CONCRETE.darkened(0.15), C_CONCRETE.darkened(0.3))
		for f in range(11):
			var fy: float = th + 12.0 + float(f) * 16.0
			if fy > GROUND_Y - 60.0:
				break
			CA.window_row(self, tx + 6.0, 96.0, fy, 5, 12.0, 10.0,
				C_GLASS, C_CONCRETE.darkened(0.35), (i * 7 + f * 19) % 31)
	var hues := [Color(0.702, 0.239, 0.286), Color(0.208, 0.435, 0.545),
		Color(0.847, 0.596, 0.176)]
	var x: float = -20.0
	var i2: int = 0
	while x < CA.VW + 20.0:
		var w: float = 76.0 + float((i2 * 19) % 4) * 18.0
		var top: float = 150.0 + float((i2 * 13) % 4) * 14.0
		CA.block(self, x, w, top, GROUND_Y, C_STONE_D, C_STONE_D.darkened(0.16))
		CA.roof(self, x, w, top, 20.0, C_ZINC)
		CA.window_row(self, x + 6.0, w - 12.0, top + 16.0,
			maxi(2, int(w / 34.0)), 12.0, 18.0, C_GLASS,
			C_STONE_D.darkened(0.3), (i2 * 17) % 29)
		# Painted walls. Every gable end here has something on it.
		if i2 % 3 == 1:
			var hue: Color = hues[i2 % 3]
			draw_rect(Rect2(x + 8.0, top + 46.0, w - 16.0, 58.0),
				Color(hue.r, hue.g, hue.b, 0.70))
			for b in range(5):
				draw_rect(Rect2(x + 14.0 + float(b) * 11.0, top + 54.0,
					6.0, 42.0), Color(0.086, 0.078, 0.094, 0.55))
		x += w + 3.0
		i2 += 1


func _draw_ladefense() -> void:
	# No fill of small buildings here — the whole horizon is towers, and there
	# is nothing under seventy metres in sight.
	CA.far_mass(self, 140.0, C_TOWER_G.darkened(0.4), C_TOWER_G.darkened(0.2),
		7, 83)
	var tops := [26.0, 62.0, 14.0, 78.0, 40.0, 92.0]
	var x: float = -40.0
	var i: int = 0
	while x < CA.VW + 40.0:
		var w: float = 96.0 + float((i * 23) % 3) * 34.0
		var top: float = float(tops[i % tops.size()])
		CA.block(self, x, w, top, GROUND_Y - 30.0, C_TOWER_G,
			C_TOWER_G.darkened(0.22))
		# Curtain wall: continuous glazing, no punched windows, no cornice.
		var bands: int = int((GROUND_Y - 30.0 - top) / 13.0)
		for b in range(bands):
			var by: float = top + 7.0 + float(b) * 13.0
			var lit: bool = ((i * 7 + b * 11) % 5) < 2 \
				and not GameState.is_morning()
			var pane: Color = Color(0.35, 0.33, 0.26) if lit \
				else C_GLASS.lightened(0.10)
			draw_rect(Rect2(x + 5.0, by, w - 10.0, 8.0), pane)
		x += w + 26.0
		i += 1
	_draw_grande_arche()
	# The deck. Everything that moves is underneath it, which is why the
	# surface is so quiet and so windy.
	draw_rect(Rect2(0.0, GROUND_Y - 30.0, CA.VW, 30.0), C_CONCRETE)
	draw_rect(Rect2(0.0, GROUND_Y - 30.0, CA.VW, 4.0),
		C_CONCRETE.lightened(0.16))


# A hollow cube in white marble, lined up on the same axis as the Arc de
# Triomphe four miles away. It is an arch with offices in the sides.
func _draw_grande_arche() -> void:
	var cx: float = 576.0
	var outer: float = 178.0
	var top: float = 34.0
	draw_rect(Rect2(cx - outer * 0.5, top, outer, outer * 1.02), C_MARBLE)
	draw_rect(Rect2(cx - outer * 0.5, top, outer, 5.0), C_MARBLE.lightened(0.08))
	# The hole, which is most of it.
	var inner: float = outer - 62.0
	var behind: Color = C_DAY_MID if GameState.is_morning() else C_SKY_MID
	draw_rect(Rect2(cx - inner * 0.5, top + 30.0, inner, outer * 1.02 - 30.0),
		behind)
	# Office windows in the sides and the lintel.
	for s in [-1.0, 1.0]:
		for f in range(9):
			var ox: float = cx + float(s) * (inner * 0.5)
			CA.window_row(self, ox - (15.0 if s > 0.0 else 16.0), 31.0,
				top + 40.0 + float(f) * 18.0, 2, 11.0, 11.0,
				C_GLASS, C_MARBLE.darkened(0.18), (f * 13) % 3)
	for f in range(3):
		CA.window_row(self, cx - inner * 0.5, inner, top + 6.0 + float(f) * 9.0,
			9, 12.0, 6.0, C_GLASS, C_MARBLE.darkened(0.18), (f * 7) % 5)


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = C_STONE_D.darkened(0.22)
	var road: Color = Color(0.180, 0.176, 0.196)
	if district == "ladefense":
		pave = C_CONCRETE.darkened(0.18)
		road = C_CONCRETE.darkened(0.32)
	CA.ground(self, pave, road, pave.darkened(0.12))
	if district == "ladefense":
		# A deck, not a street: big poured slabs and no kerb at all.
		CA.slabs(self, CA.PAVE_TOP, 80.0, 96.0, 40.0, pave.lightened(0.10), false)
		CA.slabs(self, CA.FAR_TOP, 132.0, 96.0, 40.0, pave.lightened(0.06), false)
	else:
		# Paris pavement is small square slabs; the roadway is asphalt over
		# the old setts, and the setts come through where it has worn.
		CA.slabs(self, CA.PAVE_TOP, 80.0, 34.0, 26.0, pave.lightened(0.13))
		CA.kerb(self, CA.ROAD_TOP, C_STONE_D.lightened(0.10))
		CA.setts(self, CA.ROAD_TOP + 96.0, 48.0, 15.0,
			Color(0.129, 0.125, 0.145, 0.55))
		CA.kerb(self, CA.FAR_TOP, C_STONE_D.lightened(0.10))
		CA.slabs(self, CA.FAR_TOP, 132.0, 34.0, 26.0, pave.lightened(0.09))
	if not GameState.is_morning():
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.32, 0.30, 0.45, 0.13), _t)


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	match district:
		"ladefense":
			# Nothing soft. Bollards, a bin, and a great deal of nothing.
			for i in range(9):
				CA.bollard(self, 84.0 + float(i) * 128.0, CA.PAVE_TOP + 62.0,
					Color(0.376, 0.384, 0.404))
			CA.bin(self, 940.0, CA.PAVE_TOP + 64.0, C_CONCRETE.darkened(0.2))
		"montmartre":
			for i in range(4):
				CA.lamp(self, 130.0 + float(i) * 268.0, CA.PAVE_TOP + 64.0,
					92.0, C_IRON, C_WARM, on)
			CA.tree(self, 430.0, CA.PAVE_TOP + 60.0, 64.0,
				Color(0.412, 0.376, 0.325), C_LEAF, 1.0)
		"belleville":
			for i in range(4):
				CA.lamp(self, 96.0 + float(i) * 292.0, CA.PAVE_TOP + 64.0,
					86.0, C_IRON.lightened(0.1), C_WARM, on)
			CA.stall(self, 300.0, CA.PAVE_TOP + 58.0, 118.0,
				Color(0.647, 0.184, 0.204),
				[Color(0.663, 0.235, 0.180), Color(0.286, 0.451, 0.243),
					Color(0.831, 0.643, 0.239)])
			CA.crates(self, 760.0, CA.PAVE_TOP + 58.0, 3, 2,
				Color(0.478, 0.353, 0.243))
		"marais":
			for i in range(4):
				CA.lamp(self, 120.0 + float(i) * 278.0, CA.PAVE_TOP + 62.0,
					88.0, C_IRON, C_WARM, on)
			CA.bollard(self, 520.0, CA.PAVE_TOP + 60.0, C_IRON)
			CA.bollard(self, 556.0, CA.PAVE_TOP + 60.0, C_IRON)
		_:
			# Champ-de-Mars: iron lamps, a Wallace fountain, and the men
			# selling rings of miniature towers threaded on a wire.
			for i in range(5):
				CA.lamp(self, 84.0 + float(i) * 246.0, CA.PAVE_TOP + 64.0,
					96.0, C_IRON, C_WARM, on)
			_draw_wallace(392.0, CA.PAVE_TOP + 66.0)
			CA.stall(self, 828.0, CA.PAVE_TOP + 58.0, 96.0,
				Color(0.180, 0.204, 0.259),
				[C_TOWER_HI, C_GOLD, C_TOWER_BR])
	if on:
		CA.motes(self, 26, Color(0.92, 0.88, 0.76, 0.10), _t, 9.0, 22.0, 1.4)


# The Wallace fountain: dark green cast iron, four caryatids holding up a
# dome, free drinking water since 1872. There are still about a hundred.
func _draw_wallace(x: float, base: float) -> void:
	var g := Color(0.129, 0.239, 0.180)
	draw_rect(Rect2(x - 15.0, base - 8.0, 30.0, 8.0), g.darkened(0.2))
	draw_rect(Rect2(x - 10.0, base - 34.0, 20.0, 26.0), g)
	for i in range(4):
		draw_rect(Rect2(x - 13.0 + float(i) * 8.0, base - 74.0, 5.0, 40.0), g)
	draw_rect(Rect2(x - 17.0, base - 82.0, 34.0, 9.0), g)
	draw_rect(Rect2(x - 12.0, base - 90.0, 24.0, 8.0), g.lightened(0.12))
	draw_rect(Rect2(x - 2.0, base - 96.0, 4.0, 7.0), g)


# ── Collision ────────────────────────────────────────────────────────────────
# Declared beside the art so the two cannot drift apart. Solids.gd reads this.

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	match district:
		"montmartre":
			out.append(Rect2(884.0, 286.0, 200.0, 10.0))
		"belleville":
			out.append(Rect2(300.0, 330.0, 118.0, 22.0))
			out.append(Rect2(760.0, 336.0, 74.0, 18.0))
		"champdemars":
			out.append(Rect2(377.0, 226.0, 30.0, 70.0))
			out.append(Rect2(828.0, 330.0, 96.0, 22.0))
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
	if district != "marais":
		return []
	return [
		[Vector2(866.0, CA.PAVE_TOP + 64.0), 1, 0],
	]
