extends Node2D

# Sydney. Five districts, and a light that is different from everywhere else on
# the board — the daytime palette here is harder and bluer, because Australian
# light genuinely is. It is the only city whose morning plate is brighter than
# its evening one by a wide margin.
#
# The material running through all of it is Sydney sandstone: a warm honey
# ochre they call yellowblock, quarried out of the ground the city stands on.
# Convicts cut it, the churches and the customs house are built from it, and it
# still turns up as a retaining wall in the middle of a glass district.
#
# CIRCULAR QUAY is the arrival, and it should be — it is the busiest square
# kilometre in the country. The Opera House is not white: it is over a million
# Swedish tiles in two finishes, glossy white and matte cream, laid in chevrons
# so the shells change as the light moves. The bridge is a grey steel arch with
# decorative granite-faced pylons that hold nothing up. Ferries are green and
# yellow. The Rocks behind it is the oldest colonial fabric in Australia.
#
# The CBD is where the towers are, and unlike Paris this city put them right in
# the middle of town. Sydney Tower is a gold turret on a concrete stalk and
# nothing else in the world looks like it. Sandstone Victorian survives between
# the glass, which is the actual texture of the place.
#
# NEWTOWN is two kilometres of Victorian terraces with cast-iron lace on the
# verandahs and corrugated iron behind the parapets, and the King Street mural
# that has been there since 1991.
#
# BONDI is a crescent of sand, a cream Mediterranean-revival pavilion from
# 1929, deco flats up the hill, and the red-and-yellow flags that mean the only
# safe water is the water between them.
#
# CABRAMATTA is Vietnamese-Australian Sydney, thirty kilometres west, where
# people resettled after 1975. A Pai Lau gateway, stone lions, and low
# shopfronts with awnings cantilevered out over the footpath, which is how
# suburban Australia has always built a high street.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "circularquay"
# "circularquay" | "cbd" | "newtown" | "bondi" | "cabramatta"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.055, 0.071, 0.145)
const C_SKY_MID  := Color(0.094, 0.114, 0.196)
const C_SKY_LOW  := Color(0.192, 0.169, 0.212)
const C_SKY_HAZE := Color(0.353, 0.239, 0.208)

# Harder and bluer than Europe. This is the point of the city's daylight.
const C_DAY_HI   := Color(0.352, 0.549, 0.780)
const C_DAY_MID  := Color(0.588, 0.729, 0.855)
const C_DAY_LOW  := Color(0.808, 0.851, 0.878)

const C_SAND     := Color(0.808, 0.694, 0.502)    # Sydney yellowblock
const C_SAND_B   := Color(0.706, 0.596, 0.424)
const C_SAND_D   := Color(0.576, 0.482, 0.345)
const C_BRICK    := Color(0.545, 0.310, 0.243)    # Newtown terraces
const C_IRON     := Color(0.169, 0.180, 0.184)    # verandah lace, rails
const C_TIN      := Color(0.510, 0.522, 0.529)    # corrugated roofs
const C_GLASS    := Color(0.153, 0.196, 0.235)
const C_TOWER    := Color(0.271, 0.322, 0.384)
const C_STEEL    := Color(0.392, 0.408, 0.427)    # the bridge
const C_SHELL_G  := Color(0.933, 0.925, 0.898)    # glossy tile
const C_SHELL_M  := Color(0.859, 0.831, 0.769)    # matte cream tile
const C_GOLD     := Color(0.831, 0.667, 0.322)    # the tower turret
const C_CREAM    := Color(0.902, 0.867, 0.788)    # pavilion, deco flats
const C_WATER    := Color(0.129, 0.259, 0.318)
const C_FERRY_G  := Color(0.106, 0.353, 0.243)
const C_FERRY_Y  := Color(0.902, 0.749, 0.208)
const C_FLAG_R   := Color(0.827, 0.157, 0.157)
const C_LEAF     := Color(0.239, 0.322, 0.239)
const C_WARM     := Color(1.0, 0.855, 0.596)
const C_INK      := Color(0.114, 0.110, 0.106)
const C_RED_LAC  := Color(0.667, 0.157, 0.145)    # the Pai Lau

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
			C_FERRY_G, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_CREAM, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"cbd":        _draw_cbd()
		"newtown":    _draw_newtown()
		"bondi":      _draw_bondi()
		"cabramatta": _draw_cabramatta()
		_:            _draw_quay()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	if district == "bondi":
		_draw_beach()
	else:
		CA.ground_floor(self, GROUND_Y, C_SAND_B.darkened(0.24), C_GLASS,
			C_WARM, not GameState.is_morning(), 75)
		_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.26, 0.30, 0.34), 0.04)
	CA.vignette(self, 0.24)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Circular Quay ────────────────────────────────────────────────────────────

func _draw_quay() -> void:
	# The harbour, full depth, because the first version of this plate put a
	# continuous street wall in front of it and the Opera House came out as a
	# white blob peeking over a roof.
	draw_rect(Rect2(0.0, 150.0, CA.VW, CA.PAVE_TOP - 150.0), C_WATER)
	for i in range(20):
		var wy: float = 156.0 + float(i) * 7.0
		draw_line(Vector2(0.0, wy), Vector2(CA.VW, wy),
			C_WATER.lightened(0.09 + 0.03 * float(i % 3)), 1.0)
	_draw_bridge()
	_draw_opera()
	_draw_ferry(300.0 + fmod(_t * 14.0, 260.0), 206.0)
	# The Rocks, either side of the opening. Sandstone, low, and cut off well
	# below the shells so the two landmarks own the sky.
	var x: float = -20.0
	var i2: int = 0
	while x < CA.VW + 20.0:
		var w: float = 96.0 + float((i2 * 23) % 3) * 18.0
		var top: float = 214.0 + float((i2 * 17) % 3) * 6.0
		CA.block(self, x, w, top, GROUND_Y, C_SAND, C_SAND_B)
		for c in range(int((GROUND_Y - top) / 13.0)):
			CA.band(self, x, w, top + float(c) * 13.0, 1.0, C_SAND_D.darkened(0.1))
		CA.roof(self, x, w, top, 14.0, C_TIN)
		CA.window_row(self, x + 8.0, w - 16.0, top + 14.0,
			maxi(2, int(w / 40.0)), 13.0, 16.0, C_GLASS, C_SAND_D, (i2 * 13) % 27)
		x += w + 3.0
		i2 += 1


# The shells, at the size the thing deserves. Two tile finishes laid in
# chevrons, which is why the roof changes as you walk round it - that is the
# whole trick of the design and it needs to be big enough to see.
func _draw_opera() -> void:
	var cx: float = 742.0
	var base: float = 252.0
	# The podium, in the same sandstone as the rest of the city.
	draw_rect(Rect2(cx - 186.0, base - 20.0, 372.0, 20.0), C_SAND_B)
	draw_rect(Rect2(cx - 186.0, base - 20.0, 372.0, 4.0), C_SAND)
	# Four shells, rising to the tallest at the seaward end, plus the small
	# one that is actually the restaurant and that everybody forgets.
	var shells := [[-140.0, 108.0, 54.0], [-58.0, 152.0, 70.0],
		[38.0, 196.0, 84.0], [146.0, 100.0, 50.0]]
	for i in range(shells.size()):
		var row: Array = shells[i]
		var sx: float = cx + float(row[0])
		var h: float = float(row[1])
		var w: float = float(row[2])
		var pts := PackedVector2Array()
		pts.append(Vector2(sx - w, base - 20.0))
		for st in range(19):
			var f: float = float(st) / 18.0
			pts.append(Vector2(sx - w + w * 2.0 * f,
				base - 20.0 - h * sin(f * PI * 0.60) / sin(PI * 0.60)))
		pts.append(Vector2(sx + w, base - 20.0))
		draw_colored_polygon(pts, C_SHELL_G if i % 2 == 0 else C_SHELL_M)
		# The chevron ribs, in the other finish.
		for r in range(7):
			var rf: float = 0.10 + float(r) * 0.13
			var rx: float = sx - w + w * 2.0 * rf
			var ry: float = base - 20.0 - h * sin(rf * PI * 0.60) / sin(PI * 0.60)
			draw_line(Vector2(rx, ry), Vector2(rx, base - 20.0),
				(C_SHELL_M if i % 2 == 0 else C_SHELL_G), 1.8)
		# The glass wall under the open mouth of each shell.
		draw_rect(Rect2(sx - w + 4.0, base - 44.0, w * 2.0 - 8.0, 24.0),
			C_GLASS.lightened(0.06))


# A steel arch with two granite-faced pylons that carry no load whatsoever.
func _draw_bridge() -> void:
	var lx: float = -40.0
	var rx: float = 548.0
	var span: float = rx - lx
	var rise: float = 128.0
	var deck: float = 186.0
	var top_pts := PackedVector2Array()
	var bot_pts := PackedVector2Array()
	for i in range(29):
		var f: float = float(i) / 28.0
		var ax: float = lx + span * f
		var ay: float = deck - rise * sin(f * PI)
		top_pts.append(Vector2(ax, ay))
		bot_pts.append(Vector2(ax, ay + 20.0))
	draw_polyline(top_pts, C_STEEL, 5.0, true)
	draw_polyline(bot_pts, C_STEEL, 4.0, true)
	for i in range(0, 29, 2):
		draw_line(top_pts[i], bot_pts[i], C_STEEL.darkened(0.1), 1.6)
	for i in range(2, 27, 2):
		draw_line(bot_pts[i], Vector2(bot_pts[i].x, deck),
			C_STEEL.darkened(0.15), 1.3)
	draw_rect(Rect2(lx, deck, span, 10.0), C_STEEL.darkened(0.2))
	# The pylons: granite facing over concrete, carrying nothing at all.
	for px in [lx + 74.0, rx - 74.0]:
		draw_rect(Rect2(px - 21.0, deck - 74.0, 42.0, 84.0), C_SAND_B)
		draw_rect(Rect2(px - 25.0, deck - 82.0, 50.0, 10.0), C_SAND)
		for f in range(3):
			CA.window_row(self, px - 15.0, 30.0, deck - 62.0 + float(f) * 18.0,
				2, 9.0, 11.0, C_GLASS, C_SAND_D, 0)


func _draw_ferry(x: float, y: float) -> void:
	draw_rect(Rect2(x - 34.0, y - 12.0, 68.0, 12.0), C_FERRY_G)
	draw_rect(Rect2(x - 26.0, y - 24.0, 52.0, 12.0), C_FERRY_Y)
	draw_rect(Rect2(x - 6.0, y - 34.0, 8.0, 10.0), C_FERRY_G)
	draw_rect(Rect2(x - 34.0, y, 68.0, 3.0), C_WATER.lightened(0.22))


# ── CBD ──────────────────────────────────────────────────────────────────────

func _draw_cbd() -> void:
	CA.far_mass(self, 132.0, C_TOWER.darkened(0.42), C_TOWER.darkened(0.22),
		9, 53)
	var tops := [20.0, 54.0, 8.0, 74.0, 34.0, 62.0, 16.0]
	var x: float = -40.0
	var i: int = 0
	while x < CA.VW + 40.0:
		var w: float = 88.0 + float((i * 19) % 3) * 30.0
		var top: float = float(tops[i % tops.size()])
		# Every third gap is a Victorian sandstone survivor, which is what
		# this city's streets actually look like from the footpath.
		if i % 3 == 1:
			var vt: float = 152.0
			CA.block(self, x, w, vt, GROUND_Y, C_SAND, C_SAND_B)
			for c in range(int((GROUND_Y - vt) / 15.0)):
				CA.band(self, x, w, vt + float(c) * 15.0, 1.0,
					C_SAND_D.darkened(0.1))
			CA.roof(self, x, w, vt, 18.0, C_TIN)
			CA.window_row(self, x + 8.0, w - 16.0, vt + 16.0,
				maxi(2, int(w / 40.0)), 14.0, 22.0, C_GLASS, C_SAND_D,
				(i * 11) % 27)
		else:
			CA.block(self, x, w, top, GROUND_Y, C_TOWER, C_TOWER.darkened(0.2))
			var bands: int = int((GROUND_Y - top) / 12.0)
			for b in range(bands):
				var by: float = top + 6.0 + float(b) * 12.0
				var lit: bool = ((i * 5 + b * 13) % 6) < 2 \
					and not GameState.is_morning()
				var pane: Color = Color(0.36, 0.34, 0.27) if lit \
					else C_GLASS.lightened(0.08)
				draw_rect(Rect2(x + 5.0, by, w - 10.0, 7.0), pane)
		x += w + 8.0
		i += 1
	_draw_sydney_tower(322.0)


# A gold turret on a concrete stalk. Nothing else in the world looks like it.
func _draw_sydney_tower(cx: float) -> void:
	draw_rect(Rect2(cx - 9.0, 34.0, 18.0, 204.0), Color(0.663, 0.647, 0.616))
	draw_rect(Rect2(cx - 9.0, 34.0, 5.0, 204.0), Color(0.741, 0.725, 0.694))
	# The turret: a drum with a flared underside and a spire on top.
	draw_rect(Rect2(cx - 30.0, 40.0, 60.0, 30.0), C_GOLD)
	draw_rect(Rect2(cx - 30.0, 40.0, 60.0, 5.0), C_GOLD.lightened(0.18))
	var skirt := PackedVector2Array([
		Vector2(cx - 30.0, 70.0), Vector2(cx + 30.0, 70.0),
		Vector2(cx + 12.0, 88.0), Vector2(cx - 12.0, 88.0),
	])
	draw_colored_polygon(skirt, C_GOLD.darkened(0.18))
	draw_rect(Rect2(cx - 2.5, 2.0, 5.0, 38.0), Color(0.729, 0.706, 0.671))
	for i in range(6):
		CA.window(self, cx - 25.0 + float(i) * 9.0, 48.0, 6.0, 12.0,
			C_GLASS.lightened(0.12), C_GOLD.darkened(0.25),
			not GameState.is_morning())
	# The stay cables. There are fifty-six of them and they are why it stands.
	for s in [-1.0, 1.0]:
		draw_line(Vector2(cx + float(s) * 9.0, 92.0),
			Vector2(cx + float(s) * 46.0, 238.0),
			Color(0.62, 0.61, 0.59, 0.55), 1.0)


# ── Newtown ──────────────────────────────────────────────────────────────────

func _draw_newtown() -> void:
	CA.far_mass(self, 214.0, C_BRICK.darkened(0.45), C_BRICK.darkened(0.3),
		8, 37)
	# Victorian terraces: two storeys, a verandah on the upper floor with cast
	# iron lace along it, and corrugated iron hidden behind a parapet.
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 74.0 + float((i * 13) % 3) * 14.0
		var top: float = 142.0 + float((i * 7) % 2) * 8.0
		var body: Color = C_BRICK if i % 3 != 1 else C_CREAM.darkened(0.12)
		CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
		CA.band(self, x - 2.0, w + 4.0, top - 12.0, 12.0, body.lightened(0.12))
		CA.band(self, x - 2.0, w + 4.0, top - 14.0, 3.0, C_SAND)
		draw_rect(Rect2(x + 6.0, top - 30.0, w - 12.0, 18.0), C_TIN)
		CA.window_row(self, x + 9.0, w - 18.0, top + 16.0,
			2, 15.0, 24.0, C_GLASS, C_SAND, (i * 17) % 15)
		# The verandah: a floor, a post at each end, and iron lace between.
		var vy: float = top + 52.0
		draw_rect(Rect2(x + 2.0, vy, w - 4.0, 5.0), C_TIN.darkened(0.15))
		draw_rect(Rect2(x + 5.0, vy, 4.0, GROUND_Y - vy), C_IRON)
		draw_rect(Rect2(x + w - 9.0, vy, 4.0, GROUND_Y - vy), C_IRON)
		for l in range(int((w - 18.0) / 9.0)):
			var lx: float = x + 11.0 + float(l) * 9.0
			draw_rect(Rect2(lx, vy - 13.0, 2.0, 13.0), C_IRON)
			draw_circle(Vector2(lx + 1.0, vy - 13.0), 3.0, C_IRON)
		x += w + 2.0
		i += 1
	_draw_dream_mural(690.0)


# Painted in 1991 on the corner of King and Lennox, and the street has
# defended it ever since.
func _draw_dream_mural(x: float) -> void:
	draw_rect(Rect2(x - 62.0, 148.0, 124.0, 86.0), Color(0.239, 0.192, 0.157))
	draw_rect(Rect2(x - 58.0, 152.0, 116.0, 78.0), Color(0.898, 0.286, 0.145))
	draw_circle(Vector2(x - 24.0, 182.0), 20.0, Color(0.290, 0.216, 0.169))
	draw_rect(Rect2(x - 36.0, 200.0, 24.0, 26.0), Color(0.180, 0.180, 0.212))
	for i in range(4):
		draw_rect(Rect2(x + 4.0, 164.0 + float(i) * 15.0, 48.0, 6.0),
			Color(0.949, 0.914, 0.831))


# ── Bondi ────────────────────────────────────────────────────────────────────

func _draw_bondi() -> void:
	# The sea used to be a sixty-pixel stripe with a normal street under it,
	# so the one district in this city that is a beach did not read as one.
	# It is now sea to the horizon, surf, wet sand, the sea wall, and dry
	# sand all the way to the bottom of the frame - the player walks on the
	# beach here, not on a road beside it.
	var morning: bool = GameState.is_morning()
	# The Tasman, not the harbour. C_WATER is the colour of Sydney Cove in
	# shadow between two headlands and it made the open sea look like a
	# wall standing behind the beach.
	var deep := Color(0.106, 0.361, 0.478)
	var shallow := Color(0.267, 0.663, 0.678)
	var sand: Color = Color(0.878, 0.812, 0.663)
	var wet: Color = Color(0.706, 0.659, 0.549)
	if not morning:
		deep = Color(0.055, 0.129, 0.184)
		shallow = Color(0.110, 0.267, 0.310)
		sand = sand.darkened(0.42)
		wet = wet.darkened(0.44)

	# The headlands at either end, which is what makes it Bondi and not any
	# other beach: a bay with a bluff closing each side.
	var rock: Color = Color(0.478, 0.443, 0.400)
	if not morning:
		rock = rock.darkened(0.46)

	# Sea. Deep at the horizon, shallow at the break.
	for i in range(22):
		var f: float = float(i) / 21.0
		draw_rect(Rect2(0.0, 64.0 + f * 132.0, CA.VW, 7.0), deep.lerp(shallow, f))
	draw_rect(Rect2(0.0, 64.0, CA.VW, 3.0), shallow.lightened(0.24))
	# Swell lines, and they move.
	for w in range(7):
		var wy: float = 86.0 + float(w) * 15.0
		var ph: float = sin(_t * 0.5 + float(w) * 0.9)
		draw_rect(Rect2(0.0, wy + ph * 2.0, CA.VW, 2.0),
			Color(1.0, 1.0, 1.0, 0.05 + 0.03 * float(w % 3)))
	# The moon path: broken glitter on the swell, densest under the moon
	# and thinning away from it. Drawn as a solid wedge it came out as a
	# grey pyramid standing in the bay.
	if not morning:
		for k in range(150):
			var ky: float = 70.0 + float((k * 47) % 128)
			var spread: float = 40.0 + (ky - 70.0) * 3.4
			var off: float = (float((k * 173) % 200) / 100.0 - 1.0) * spread
			var kx: float = 742.0 + off
			if kx < -10.0 or kx > CA.VW:
				continue
			var fade: float = 1.0 - absf(off) / maxf(spread, 1.0)
			var glint: float = 0.6 + 0.4 * sin(_t * 1.7 + float(k))
			draw_rect(Rect2(kx, ky, 5.0 + float(k % 4) * 3.0, 2.0),
				Color(0.878, 0.918, 0.941, 0.05 + 0.16 * fade * glint))
	# The break. Three lines of white water, each on its own beat.
	for b in range(3):
		var by: float = 196.0 + float(b) * 9.0
		var bp: float = sin(_t * 0.8 + float(b) * 1.3)
		draw_rect(Rect2(0.0, by + bp * 1.5, CA.VW, 5.0 + float(b) * 1.5),
			Color(0.96, 0.97, 0.97, 0.34 + 0.20 * bp))
	# Wet sand, where the water has just been.
	draw_rect(Rect2(0.0, 222.0, CA.VW, 22.0), wet)
	draw_rect(Rect2(0.0, 222.0, CA.VW, 4.0), Color(0.98, 0.98, 0.96, 0.34))

	for side in [-1.0, 1.0]:
		var hx: float = 576.0 + side * 576.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(hx + side * 120.0, 62.0), Vector2(hx - side * 176.0, 116.0),
			Vector2(hx - side * 140.0, 238.0), Vector2(hx + side * 120.0, 238.0),
		]), rock)
		draw_colored_polygon(PackedVector2Array([
			Vector2(hx - side * 176.0, 116.0), Vector2(hx - side * 140.0, 238.0),
			Vector2(hx - side * 108.0, 238.0),
		]), rock.darkened(0.20))

	# The sea wall: the concrete lip the promenade sits on, with the steps
	# down onto the sand.
	var conc: Color = Color(0.729, 0.706, 0.663)
	if not morning:
		conc = conc.darkened(0.44)
	draw_rect(Rect2(0.0, 244.0, CA.VW, GROUND_Y - 244.0 + 54.0), conc)
	draw_rect(Rect2(0.0, 244.0, CA.VW, 6.0), conc.lightened(0.16))
	for r in range(28):
		draw_rect(Rect2(float(r) * 42.0, 250.0, 2.0, 48.0), Color(0, 0, 0, 0.10))
	for sx in [188.0, 700.0]:
		for st in range(4):
			draw_rect(Rect2(sx - 46.0, 262.0 + float(st) * 9.0, 92.0, 5.0),
				conc.lightened(0.10))

	# The pavilion, up on the promenade: cream, 1929, arched loggia,
	# terracotta roof.
	var px: float = 470.0
	draw_rect(Rect2(px - 150.0, 176.0, 300.0, 70.0), C_CREAM)
	draw_rect(Rect2(px - 154.0, 168.0, 308.0, 10.0), Color(0.635, 0.353, 0.267))
	for a in range(7):
		var ax: float = px - 126.0 + float(a) * 42.0
		draw_rect(Rect2(ax - 13.0, 208.0, 26.0, 38.0), Color(0.322, 0.290, 0.259))
		draw_circle(Vector2(ax, 208.0), 13.0, Color(0.322, 0.290, 0.259))

	# Deco flats up the hill behind, at both ends.
	for s in [0.0, 1.0]:
		var bx: float = -52.0 + float(s) * 1024.0
		for i in range(2):
			var fx: float = bx + float(i) * 92.0
			var ft: float = 118.0 + float(i) * 12.0
			CA.block(self, fx, 84.0, ft, 250.0, C_CREAM, C_CREAM.darkened(0.14))
			for f in range(3):
				CA.band(self, fx, 84.0, ft + 14.0 + float(f) * 26.0, 4.0,
					C_CREAM.darkened(0.22))
				CA.window_row(self, fx + 7.0, 70.0, ft + 20.0 + float(f) * 26.0,
					3, 13.0, 14.0, C_GLASS, C_CREAM.darkened(0.2),
					(i * 7 + f * 11) % 7)
	_draw_flags(300.0)
	_draw_flags(760.0)


# The dry sand the player is standing on, and what is lying about on it.
# Drawn over the three ground bands, because at Bondi there is no road.
func _draw_beach() -> void:
	var sand := Color(0.878, 0.812, 0.663)
	if not GameState.is_morning():
		sand = sand.darkened(0.42)
	draw_rect(Rect2(0.0, CA.PAVE_TOP, CA.VW, CA.VH - CA.PAVE_TOP), sand)
	# It is not one flat colour. Dry drifts, damp patches, and footprints.
	for i in range(64):
		var dx: float = float((i * 173) % 1160) - 8.0
		var dy: float = CA.PAVE_TOP + float((i * 97) % 340)
		var dw: float = 40.0 + float((i * 31) % 90)
		draw_rect(Rect2(dx, dy, dw, 7.0 + float(i % 3) * 4.0),
			sand.lightened(0.06) if (i % 2) else sand.darkened(0.05))
	for i in range(70):
		var fx: float = float((i * 211) % 1150)
		var fy: float = CA.PAVE_TOP + 12.0 + float((i * 137) % 320)
		draw_rect(Rect2(fx, fy, 7.0, 4.0), sand.darkened(0.16))
		draw_rect(Rect2(fx + 11.0, fy + 9.0, 7.0, 4.0), sand.darkened(0.16))
	# Towels and umbrellas. Nobody is on them; the district's people are
	# drawn by the NPC layer.
	for spec in [[126.0, 402.0, 0], [352.0, 470.0, 1], [598.0, 424.0, 2],
			[846.0, 496.0, 3], [1024.0, 416.0, 4]]:
		_draw_towel(float(spec[0]), float(spec[1]), int(spec[2]))
	_draw_umbrella(238.0, 448.0, 0)
	_draw_umbrella(922.0, 528.0, 2)


func _draw_towel(x: float, y: float, i: int) -> void:
	var hues := [Color(0.851, 0.298, 0.267), Color(0.196, 0.478, 0.678),
		Color(0.941, 0.769, 0.267), Color(0.235, 0.573, 0.451),
		Color(0.588, 0.353, 0.612)]
	var c: Color = hues[i % hues.size()]
	if not GameState.is_morning():
		c = c.darkened(0.42)
	draw_rect(Rect2(x - 34.0, y - 3.0, 72.0, 6.0), Color(0, 0, 0, 0.14))
	draw_rect(Rect2(x - 32.0, y - 11.0, 64.0, 22.0), c)
	for s in range(3):
		draw_rect(Rect2(x - 32.0, y - 7.0 + float(s) * 7.0, 64.0, 2.5),
			c.lightened(0.22))


func _draw_umbrella(x: float, y: float, i: int) -> void:
	var c := Color(0.898, 0.478, 0.235) if i == 0 else Color(0.243, 0.510, 0.729)
	if not GameState.is_morning():
		c = c.darkened(0.40)
	draw_rect(Rect2(x - 22.0, y - 3.0, 46.0, 6.0), Color(0, 0, 0, 0.16))
	draw_rect(Rect2(x - 1.5, y - 62.0, 3.0, 62.0), Color(0.647, 0.639, 0.612))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 54.0, y - 62.0), Vector2(x + 54.0, y - 62.0),
		Vector2(x + 40.0, y - 74.0), Vector2(x, y - 84.0),
		Vector2(x - 40.0, y - 74.0),
	]), c)
	for k in range(3):
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 54.0 + float(k) * 36.0, y - 62.0),
			Vector2(x - 36.0 + float(k) * 36.0, y - 62.0),
			Vector2(x, y - 84.0),
		]), c.lightened(0.20))


# Red over yellow. The water between two of these is the only water anyone is
# watching, and that is a rule with a body count behind it.
func _draw_flags(x: float) -> void:
	draw_rect(Rect2(x - 1.5, 190.0, 3.0, 40.0), Color(0.235, 0.220, 0.204))
	var flap: float = 5.0 * sin(_t * 2.2 + x * 0.01)
	var pts := PackedVector2Array([
		Vector2(x + 1.5, 190.0), Vector2(x + 26.0, 193.0 + flap),
		Vector2(x + 26.0, 209.0 + flap), Vector2(x + 1.5, 206.0),
	])
	draw_colored_polygon(pts, C_FLAG_R)
	var pts2 := PackedVector2Array([
		Vector2(x + 1.5, 206.0), Vector2(x + 26.0, 209.0 + flap),
		Vector2(x + 26.0, 224.0 + flap), Vector2(x + 1.5, 221.0),
	])
	draw_colored_polygon(pts2, C_FERRY_Y)


# ── Cabramatta ───────────────────────────────────────────────────────────────

func _draw_cabramatta() -> void:
	CA.far_mass(self, 226.0, Color(0.361, 0.337, 0.318),
		Color(0.42, 0.40, 0.38), 7, 71)
	var bodies := [C_CREAM.darkened(0.10), Color(0.769, 0.686, 0.588),
		Color(0.706, 0.616, 0.522)]
	# Low suburban shopfronts, one or two storeys, with the awning cantilevered
	# out over the footpath. That awning is how Australia builds a high street.
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 86.0 + float((i * 11) % 3) * 16.0
		var top: float = 170.0 + float((i * 19) % 2) * 14.0
		var body: Color = bodies[i % 3]
		CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.16))
		CA.band(self, x - 2.0, w + 4.0, top - 10.0, 10.0, body.lightened(0.14))
		CA.window_row(self, x + 8.0, w - 16.0, top + 14.0,
			2, 16.0, 20.0, C_GLASS, body.darkened(0.28), (i * 13) % 15)
		draw_rect(Rect2(x - 4.0, GROUND_Y - 58.0, w + 8.0, 6.0),
			body.darkened(0.3))
		draw_rect(Rect2(x + 4.0, GROUND_Y - 58.0, 3.0, 58.0), C_IRON)
		draw_rect(Rect2(x + w - 7.0, GROUND_Y - 58.0, 3.0, 58.0), C_IRON)
		# Vertical shop signs, the other thing this street is full of.
		if i % 2 == 0:
			CA.sign_stack(self, x + w - 16.0, top + 12.0, 13.0, 4,
				C_RED_LAC, Color(0.949, 0.898, 0.729), i)
		x += w + 3.0
		i += 1
	_draw_pai_lau(576.0)


# The gateway at Freedom Plaza: three bays, red columns, green glazed tile
# roofs with the eaves turned up, and a stone lion each side of the road.
func _draw_pai_lau(cx: float) -> void:
	var base: float = GROUND_Y
	var green := Color(0.129, 0.353, 0.278)
	for s in [-1.0, 1.0]:
		for inner in [0.42, 1.0]:
			var px: float = cx + float(s) * 74.0 * float(inner)
			draw_rect(Rect2(px - 8.0, base - 132.0, 16.0, 132.0), C_RED_LAC)
			draw_rect(Rect2(px - 8.0, base - 132.0, 4.0, 132.0),
				C_RED_LAC.lightened(0.18))
	_pai_roof(cx, base - 148.0, 96.0, green)
	_pai_roof(cx - 106.0, base - 122.0, 58.0, green)
	_pai_roof(cx + 106.0, base - 122.0, 58.0, green)
	for s in [-1.0, 1.0]:
		var lx: float = cx + float(s) * 178.0
		draw_rect(Rect2(lx - 15.0, base - 22.0, 30.0, 22.0), C_SAND_D)
		draw_rect(Rect2(lx - 11.0, base - 46.0, 22.0, 24.0), C_SAND_B)
		draw_circle(Vector2(lx, base - 50.0), 11.0, C_SAND_B)


func _pai_roof(cx: float, y: float, half: float, tile: Color) -> void:
	draw_rect(Rect2(cx - half, y, half * 2.0, 12.0), tile)
	draw_rect(Rect2(cx - half, y, half * 2.0, 3.0), tile.lightened(0.2))
	# Upturned eaves — the corners lift, which is the whole silhouette.
	for s in [-1.0, 1.0]:
		var pts := PackedVector2Array([
			Vector2(cx + float(s) * half, y + 12.0),
			Vector2(cx + float(s) * (half + 22.0), y - 2.0),
			Vector2(cx + float(s) * (half + 22.0), y + 5.0),
			Vector2(cx + float(s) * half, y + 16.0),
		])
		draw_colored_polygon(pts, tile.darkened(0.12))
	draw_rect(Rect2(cx - half + 6.0, y - 7.0, half * 2.0 - 12.0, 7.0),
		C_RED_LAC.darkened(0.15))


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.427, 0.412, 0.396)
	var road: Color = Color(0.176, 0.180, 0.196)
	CA.ground(self, pave, road, pave.darkened(0.12))
	CA.slabs(self, CA.PAVE_TOP, 80.0, 60.0, 40.0, pave.lightened(0.11))
	CA.kerb(self, CA.ROAD_TOP, C_SAND_D.lightened(0.14))
	CA.kerb(self, CA.FAR_TOP, C_SAND_D.lightened(0.14))
	CA.slabs(self, CA.FAR_TOP, 132.0, 60.0, 40.0, pave.lightened(0.08))
	if district == "cbd":
		# Light rail runs down the middle of George Street now.
		draw_rect(Rect2(0.0, CA.ROAD_TOP + 52.0, CA.VW, 3.0),
			Color(0.545, 0.541, 0.529))
		draw_rect(Rect2(0.0, CA.ROAD_TOP + 84.0, CA.VW, 3.0),
			Color(0.545, 0.541, 0.529))
	if not GameState.is_morning():
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.30, 0.32, 0.44, 0.12), _t)


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	match district:
		"cbd":
			for i in range(5):
				CA.lamp(self, 92.0 + float(i) * 244.0, CA.PAVE_TOP + 62.0,
					94.0, Color(0.263, 0.271, 0.282), C_WARM, on)
			CA.bin(self, 700.0, CA.PAVE_TOP + 64.0, Color(0.318, 0.325, 0.337))
		"newtown":
			for i in range(4):
				CA.lamp(self, 110.0 + float(i) * 282.0, CA.PAVE_TOP + 62.0,
					86.0, C_IRON, C_WARM, on)
			CA.crates(self, 250.0, CA.PAVE_TOP + 58.0, 3, 2,
				Color(0.502, 0.376, 0.278))
		"bondi":
			# Norfolk Island pines. They line this beach and nothing else does.
			for i in range(5):
				_draw_pine(120.0 + float(i) * 232.0, CA.PAVE_TOP + 6.0)
			CA.bin(self, 640.0, CA.PAVE_TOP + 64.0, Color(0.361, 0.365, 0.376))
		"cabramatta":
			for i in range(4):
				CA.lamp(self, 130.0 + float(i) * 274.0, CA.PAVE_TOP + 62.0,
					84.0, C_IRON, C_WARM, on)
			CA.stall(self, 236.0, CA.PAVE_TOP + 58.0, 122.0,
				Color(0.612, 0.176, 0.169),
				[C_LEAF, Color(0.831, 0.643, 0.212), Color(0.729, 0.286, 0.208)])
			CA.crates(self, 852.0, CA.PAVE_TOP + 58.0, 3, 2,
				Color(0.482, 0.365, 0.263))
		_:
			for i in range(5):
				CA.lamp(self, 96.0 + float(i) * 242.0, CA.PAVE_TOP + 62.0,
					92.0, Color(0.239, 0.251, 0.263), C_WARM, on)
			CA.bollard(self, 500.0, CA.PAVE_TOP + 60.0, C_IRON)
			CA.bollard(self, 540.0, CA.PAVE_TOP + 60.0, C_IRON)
	if on:
		CA.motes(self, 22, Color(0.90, 0.92, 0.86, 0.09), _t, 10.0, 20.0, 1.3)


func _draw_pine(x: float, base: float) -> void:
	draw_rect(Rect2(x - 4.0, base - 96.0, 8.0, 96.0), Color(0.318, 0.278, 0.235))
	for i in range(8):
		var ly: float = base - 92.0 + float(i) * 11.0
		var half: float = 8.0 + float(i) * 3.4
		draw_rect(Rect2(x - half, ly, half * 2.0, 6.0), C_LEAF)


# ── Collision ────────────────────────────────────────────────────────────────
# Declared beside the art so the two cannot drift apart. Solids.gd reads this.

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	match district:
		"cabramatta":
			out.append(Rect2(236.0, 330.0, 122.0, 22.0))
			out.append(Rect2(852.0, 336.0, 74.0, 18.0))
		"newtown":
			out.append(Rect2(250.0, 336.0, 74.0, 18.0))
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
	if district != "newtown":
		return []
	return [
		[Vector2(900.0, CA.PAVE_TOP + 64.0), 0, 0],
	]
