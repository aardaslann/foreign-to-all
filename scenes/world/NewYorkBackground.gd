extends Node2D

# New York. Five districts, and the thing that organises the plates is the
# 1916 zoning law: buildings here have to step back as they rise so that some
# light reaches the street, which is why the skyline is wedding-cake shaped and
# why the street below is a canyon with a strip of sky at the top of it.
#
# MIDTOWN is the arrival. The Empire State Building is 443 metres to the tip
# and the street is at the bottom of it, so what the plate shows is the base
# and the first two setbacks and then it leaves the top of the frame. In front
# of that: sidewalk sheds. Green-painted scaffolding tunnels over the footpath,
# nine thousand of them in the city at any time, some up for decades. They are
# more characteristic of this street than anything with a name.
#
# THE LOWER EAST SIDE is tenements: five and six storeys of brick with the
# fire escapes bolted to the FRONT, zigzagging down the facade, because the
# law wanted a second way out and nobody was going to lose rentable floor for
# it.
#
# HARLEM is brownstone rows with stoops - a full flight of steps up to a door
# on the first floor, and the stoop is a room the street can use.
#
# WILLIAMSBURG is warehouses under the bridge, with wooden water tanks on the
# roofs. They are wooden because wood does not sweat and does not freeze the
# way steel does, and there are something like fifteen thousand of them.
#
# JACKSON HEIGHTS has the elevated running straight down the middle of the
# avenue on steel columns, and under it a street where more languages are
# spoken than anywhere else on the planet.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "midtown"
# "midtown" | "lowereast" | "harlem" | "williamsburg" | "jacksonheights"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.051, 0.055, 0.098)
const C_SKY_MID  := Color(0.090, 0.098, 0.161)
const C_SKY_LOW  := Color(0.208, 0.169, 0.192)
const C_SKY_HAZE := Color(0.376, 0.259, 0.204)

const C_DAY_HI   := Color(0.435, 0.510, 0.612)
const C_DAY_MID  := Color(0.612, 0.655, 0.702)
const C_DAY_LOW  := Color(0.792, 0.796, 0.780)

const C_LIME     := Color(0.769, 0.741, 0.643)    # Empire State limestone
const C_LIME_D   := Color(0.612, 0.588, 0.502)
const C_BRICK    := Color(0.545, 0.322, 0.267)    # tenement brick
const C_BRICK_D  := Color(0.435, 0.259, 0.216)
const C_BROWN    := Color(0.451, 0.318, 0.235)    # brownstone
const C_IRON     := Color(0.153, 0.161, 0.169)    # fire escapes, columns
const C_SHED     := Color(0.184, 0.400, 0.298)    # sidewalk shed green
const C_TANK     := Color(0.482, 0.376, 0.286)    # water tanks
const C_TOWER    := Color(0.263, 0.294, 0.345)
const C_GLASS    := Color(0.145, 0.180, 0.220)
const C_CAB      := Color(0.929, 0.749, 0.153)
const C_STEAM    := Color(0.820, 0.839, 0.867)
const C_WARM     := Color(1.0, 0.851, 0.596)
const C_INK      := Color(0.106, 0.102, 0.098)
const C_LEAF     := Color(0.212, 0.318, 0.235)

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
			C_CAB, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_LIME, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"lowereast":      _draw_lowereast()
		"harlem":         _draw_harlem()
		"williamsburg":   _draw_williamsburg()
		"jacksonheights": _draw_jacksonheights()
		_:                _draw_midtown()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_LIME.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 45)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.24, 0.26, 0.30), 0.05)
	CA.vignette(self, 0.28)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Midtown ──────────────────────────────────────────────────────────────────

func _draw_midtown() -> void:
	# Towers either side, and the one in the middle is far too tall to fit.
	for i in range(7):
		var tx: float = -60.0 + float(i) * 190.0
		if tx > 300.0 and tx < 780.0:
			continue
		var th: float = 20.0 + float((i * 23) % 4) * 24.0
		CA.block(self, tx, 150.0, th, GROUND_Y, C_TOWER, C_TOWER.darkened(0.22))
		var bands: int = int((GROUND_Y - th) / 12.0)
		for b in range(bands):
			var lit: bool = ((i * 5 + b * 11) % 6) < 2 and not GameState.is_morning()
			draw_rect(Rect2(tx + 6.0, th + 6.0 + float(b) * 12.0, 138.0, 7.0),
				Color(0.36, 0.34, 0.26) if lit else C_GLASS.lightened(0.08))
	_draw_empire(540.0)


# 443 metres, and the street is at the bottom of it. At 1.6 pixels to the
# metre the base fills the frame and the first setback is near the ceiling;
# the mast is nine hundred pixels above the top of this picture. Trying to fit
# the whole building in is what makes a skyscraper look like a filing cabinet.
func _draw_empire(cx: float) -> void:
	var base: float = CA.PAVE_TOP
	# The five-storey limestone base, wall to wall.
	draw_rect(Rect2(cx - 250.0, 116.0, 500.0, base - 116.0), C_LIME)
	draw_rect(Rect2(cx - 250.0, 116.0, 500.0, 8.0), C_LIME.lightened(0.14))
	# The first setback, and the second going out of frame.
	draw_rect(Rect2(cx - 196.0, 44.0, 392.0, 76.0), C_LIME.darkened(0.06))
	draw_rect(Rect2(cx - 196.0, 44.0, 392.0, 7.0), C_LIME.lightened(0.10))
	draw_rect(Rect2(cx - 140.0, -30.0, 280.0, 80.0), C_LIME.darkened(0.12))
	# The vertical piers. They run the whole height without a break, which is
	# the entire trick of the design and the reason it reads as tall.
	for i in range(19):
		var px: float = cx - 236.0 + float(i) * 26.0
		draw_rect(Rect2(px, 116.0, 9.0, base - 116.0), C_LIME.lightened(0.10))
		if px > cx - 190.0 and px < cx + 182.0:
			draw_rect(Rect2(px, 44.0, 9.0, 76.0), C_LIME.lightened(0.06))
		if px > cx - 134.0 and px < cx + 126.0:
			draw_rect(Rect2(px, -30.0, 9.0, 80.0), C_LIME.lightened(0.02))
	for i in range(18):
		var wx: float = cx - 227.0 + float(i) * 26.0
		for f in range(9):
			var wy: float = 128.0 + float(f) * 17.0
			if wy > base - 70.0:
				break
			var lit2: bool = ((i * 7 + f * 13) % 7) < 2 and not GameState.is_morning()
			draw_rect(Rect2(wx, wy, 17.0, 11.0),
				Color(0.38, 0.35, 0.26) if lit2 else C_GLASS)
	# The entrance: three storeys of bronze and glass, and it is still only
	# the bottom eight per cent of the building.
	draw_rect(Rect2(cx - 66.0, base - 92.0, 132.0, 92.0), C_LIME.darkened(0.30))
	draw_rect(Rect2(cx - 54.0, base - 80.0, 108.0, 80.0), Color(0.310, 0.239, 0.161))
	draw_rect(Rect2(cx - 44.0, base - 68.0, 88.0, 68.0), C_GLASS.lightened(0.10))


func _draw_lowereast() -> void:
	CA.far_mass(self, 150.0, C_BRICK_D.darkened(0.44), C_BRICK_D.darkened(0.26),
		9, 31)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 108.0 + float((i * 17) % 3) * 14.0
		var top: float = 62.0 + float((i * 23) % 3) * 16.0
		var body: Color = C_BRICK if i % 3 else C_BRICK.darkened(0.10)
		CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
		CA.band(self, x - 4.0, w + 8.0, top - 10.0, 10.0, body.lightened(0.20))
		var floors: int = int((GROUND_Y - top) / 34.0)
		for f in range(floors):
			var fy: float = top + 14.0 + float(f) * 34.0
			if fy > GROUND_Y - 40.0:
				break
			CA.window_row(self, x + 8.0, w - 16.0, fy, 3, 17.0, 22.0,
				C_GLASS, body.lightened(0.24), (i * 13 + f * 5) % 31)
		_fire_escape(x + w * 0.5, top + 12.0, w - 30.0, floors)
		x += w + 3.0
		i += 1


# Bolted to the front of the building, zigzagging down. The law wanted a
# second way out and nobody was going to give up rentable floor for it.
func _fire_escape(cx: float, top: float, w: float, floors: int) -> void:
	for f in range(floors):
		var fy: float = top + 18.0 + float(f) * 34.0
		if fy > GROUND_Y - 24.0:
			break
		draw_rect(Rect2(cx - w * 0.5, fy + 22.0, w, 4.0), C_IRON)
		for b in range(int(w / 8.0)):
			draw_rect(Rect2(cx - w * 0.5 + float(b) * 8.0, fy + 8.0, 2.0, 14.0),
				C_IRON)
		draw_rect(Rect2(cx - w * 0.5, fy + 8.0, 2.5, 18.0), C_IRON)
		draw_rect(Rect2(cx + w * 0.5 - 2.5, fy + 8.0, 2.5, 18.0), C_IRON)
		# The ladder to the next one down, on alternating sides.
		var lx: float = cx - w * 0.5 + 6.0 if f % 2 == 0 else cx + w * 0.5 - 12.0
		for r in range(6):
			draw_rect(Rect2(lx, fy + 26.0 + float(r) * 5.0, 7.0, 1.6), C_IRON)


func _draw_harlem() -> void:
	CA.far_mass(self, 168.0, C_BROWN.darkened(0.44), C_BROWN.darkened(0.26),
		8, 19)
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 92.0
		var top: float = 104.0
		CA.block(self, x, w, top, GROUND_Y, C_BROWN, C_BROWN.darkened(0.16))
		CA.band(self, x - 4.0, w + 8.0, top - 12.0, 12.0, C_BROWN.lightened(0.16))
		for f in range(3):
			CA.window_row(self, x + 10.0, w - 20.0, top + 16.0 + float(f) * 40.0,
				2, 18.0, 26.0, C_GLASS, C_BROWN.lightened(0.22),
				(i * 11 + f * 7) % 15)
		# The stoop: a full flight up to a door on the first floor, and it is
		# a room the street is allowed to use.
		var sx: float = x + w * 0.5
		for st in range(7):
			draw_rect(Rect2(sx - 26.0, GROUND_Y - 8.0 - float(st) * 8.0,
				52.0, 8.0), C_BROWN.lightened(0.10 + 0.02 * float(st % 2)))
		draw_rect(Rect2(sx - 30.0, GROUND_Y - 64.0, 8.0, 60.0), C_IRON)
		draw_rect(Rect2(sx + 22.0, GROUND_Y - 64.0, 8.0, 60.0), C_IRON)
		draw_rect(Rect2(sx - 20.0, GROUND_Y - 116.0, 40.0, 54.0),
			Color(0.216, 0.145, 0.110))
		x += w + 3.0
		i += 1


func _draw_williamsburg() -> void:
	CA.far_mass(self, 176.0, C_BRICK_D.darkened(0.46), C_BRICK_D.darkened(0.28),
		7, 43)
	# The bridge, coming in over the top of everything from the left.
	var deck: float = 128.0
	draw_rect(Rect2(-40.0, deck, 520.0, 12.0), C_IRON.lightened(0.14))
	for i in range(14):
		var bx: float = -30.0 + float(i) * 36.0
		draw_rect(Rect2(bx, deck - 44.0, 5.0, 44.0), C_IRON.lightened(0.08))
		draw_line(Vector2(bx, deck - 44.0), Vector2(bx + 36.0, deck),
			C_IRON.lightened(0.04), 1.6)
	draw_rect(Rect2(-40.0, deck - 52.0, 520.0, 8.0), C_IRON.lightened(0.10))
	var x: float = -20.0
	var i2: int = 0
	while x < CA.VW + 20.0:
		var w: float = 140.0 + float((i2 * 13) % 3) * 24.0
		var top: float = 172.0 + float((i2 * 19) % 2) * 14.0
		CA.block(self, x, w, top, GROUND_Y, C_BRICK.darkened(0.14),
			C_BRICK_D.darkened(0.10))
		for f in range(2):
			CA.window_row(self, x + 12.0, w - 24.0, top + 22.0 + float(f) * 46.0,
				4, 20.0, 28.0, C_GLASS, C_BRICK.lightened(0.16),
				(i2 * 7 + f * 11) % 15)
		_water_tank(x + w * 0.5, top)
		x += w + 4.0
		i2 += 1


# Wooden, because wood does not sweat in summer or freeze solid in winter the
# way a steel tank does. There are about fifteen thousand of them up there.
func _water_tank(x: float, roof: float) -> void:
	var legs: float = 26.0
	for lx in [x - 24.0, x + 20.0]:
		draw_rect(Rect2(lx, roof - legs, 5.0, legs), C_IRON)
	draw_rect(Rect2(x - 30.0, roof - legs - 46.0, 60.0, 46.0), C_TANK)
	for s in range(7):
		draw_rect(Rect2(x - 30.0 + float(s) * 9.0, roof - legs - 46.0, 3.0, 46.0),
			C_TANK.darkened(0.16))
	draw_rect(Rect2(x - 30.0, roof - legs - 34.0, 60.0, 3.0), C_IRON)
	draw_rect(Rect2(x - 30.0, roof - legs - 16.0, 60.0, 3.0), C_IRON)
	var cone := PackedVector2Array([
		Vector2(x - 34.0, roof - legs - 46.0), Vector2(x + 34.0, roof - legs - 46.0),
		Vector2(x, roof - legs - 72.0),
	])
	draw_colored_polygon(cone, C_TANK.darkened(0.22))


func _draw_jacksonheights() -> void:
	CA.far_mass(self, 196.0, C_BRICK_D.darkened(0.48), C_BRICK_D.darkened(0.30),
		8, 53)
	# Garden-apartment brick behind, low.
	var x: float = -20.0
	var i: int = 0
	while x < CA.VW + 20.0:
		var w: float = 124.0 + float((i * 11) % 3) * 18.0
		var top: float = 172.0
		CA.block(self, x, w, top, GROUND_Y, C_BRICK.darkened(0.06),
			C_BRICK_D.darkened(0.06))
		CA.window_row(self, x + 10.0, w - 20.0, top + 18.0, 3, 18.0, 22.0,
			C_GLASS, C_BRICK.lightened(0.18), (i * 13) % 15)
		x += w + 4.0
		i += 1
	# The elevated, straight down the middle of the avenue on steel columns.
	var deck: float = 150.0
	draw_rect(Rect2(0.0, deck, CA.VW, 26.0), C_IRON.darkened(0.10))
	draw_rect(Rect2(0.0, deck + 26.0, CA.VW, 6.0), C_IRON.lightened(0.10))
	for i2 in range(9):
		var px: float = 30.0 + float(i2) * 136.0
		draw_rect(Rect2(px - 9.0, deck + 32.0, 18.0, GROUND_Y - deck - 32.0),
			C_IRON.lightened(0.06))
		draw_rect(Rect2(px - 22.0, deck + 32.0, 44.0, 8.0), C_IRON.lightened(0.12))
		for r in range(4):
			draw_line(Vector2(px - 9.0, deck + 46.0 + float(r) * 22.0),
				Vector2(px + 9.0, deck + 60.0 + float(r) * 22.0),
				C_IRON.lightened(0.14), 1.4)
	# A train going over, which happens every four minutes all night.
	var tx: float = fmod(_t * 90.0, CA.VW + 700.0) - 350.0
	if tx > -340.0:
		draw_rect(Rect2(tx, deck - 44.0, 330.0, 46.0), Color(0.686, 0.694, 0.706))
		draw_rect(Rect2(tx, deck - 44.0, 330.0, 6.0), Color(0.780, 0.788, 0.796))
		for c in range(9):
			draw_rect(Rect2(tx + 14.0 + float(c) * 36.0, deck - 34.0, 24.0, 18.0),
				C_WARM.darkened(0.10) if not GameState.is_morning()
				else C_GLASS.lightened(0.18))


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.435, 0.427, 0.412)
	var road: Color = Color(0.169, 0.169, 0.180)
	CA.ground(self, pave, road, pave.darkened(0.12))
	# New York pavement is poured in big slabs with expansion joints, not laid.
	CA.slabs(self, CA.PAVE_TOP, 80.0, 74.0, 40.0, pave.lightened(0.09), false)
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
	CA.kerb(self, CA.FAR_TOP, pave.lightened(0.18))
	CA.slabs(self, CA.FAR_TOP, 132.0, 74.0, 40.0, pave.lightened(0.07), false)
	# The lane markings, and one manhole with the city breathing through it.
	for i in range(12):
		draw_rect(Rect2(float(i) * 104.0, CA.ROAD_TOP + 66.0, 56.0, 4.0),
			Color(0.780, 0.741, 0.353, 0.55))
	_draw_steam(742.0, CA.ROAD_TOP + 24.0)
	if not GameState.is_morning():
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.30, 0.30, 0.42, 0.13), _t)


# Steam off the district heating mains under the street. It is not weather and
# it is not a fire; there are six hundred miles of live steam pipe down there.
func _draw_steam(x: float, y: float) -> void:
	draw_rect(Rect2(x - 26.0, y - 4.0, 52.0, 8.0), Color(0.259, 0.251, 0.243))
	for i in range(10):
		var f: float = fmod(_t * 0.34 + float(i) * 0.1, 1.0)
		var sy: float = y - f * 150.0
		var r: float = 14.0 + f * 46.0
		draw_circle(Vector2(x + 26.0 * sin(f * 2.4 + float(i)), sy), r,
			Color(C_STEAM.r, C_STEAM.g, C_STEAM.b, 0.10 * (1.0 - f)))


# The sidewalk shed: a green scaffolding tunnel over the footpath. There are
# nine thousand of these standing at any moment and some have been up for
# twenty years. Nothing says this city faster.
func _draw_shed(x0: float, x1: float) -> void:
	var y: float = CA.PAVE_TOP - 118.0
	draw_rect(Rect2(x0, y, x1 - x0, 12.0), C_SHED)
	draw_rect(Rect2(x0, y, x1 - x0, 4.0), C_SHED.lightened(0.18))
	draw_rect(Rect2(x0, y + 12.0, x1 - x0, 5.0), C_SHED.darkened(0.28))
	var n: int = int((x1 - x0) / 96.0)
	for i in range(n + 1):
		var px: float = x0 + float(i) * 96.0
		draw_rect(Rect2(px, y + 17.0, 9.0, CA.PAVE_TOP + 46.0 - y - 17.0),
			C_SHED.darkened(0.14))
		draw_rect(Rect2(px - 4.0, y + 17.0, 17.0, 5.0), C_SHED.darkened(0.24))
	for i in range(n * 2):
		draw_rect(Rect2(x0 + 24.0 + float(i) * 48.0, y - 9.0, 30.0, 9.0),
			Color(0.851, 0.804, 0.196, 0.85))


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	match district:
		"midtown":
			_draw_shed(306.0, 494.0)
			for i in range(4):
				CA.lamp(self, 560.0 + float(i) * 168.0, CA.PAVE_TOP + 62.0,
					104.0, Color(0.239, 0.247, 0.259), C_WARM, on)
		"lowereast":
			for i in range(5):
				CA.lamp(self, 84.0 + float(i) * 244.0, CA.PAVE_TOP + 62.0,
					96.0, C_IRON.lightened(0.10), C_WARM, on)
			CA.crates(self, 300.0, CA.PAVE_TOP + 58.0, 3, 2,
				Color(0.478, 0.376, 0.290))
			CA.bin(self, 880.0, CA.PAVE_TOP + 64.0, Color(0.251, 0.259, 0.267))
		"harlem":
			for i in range(4):
				CA.lamp(self, 120.0 + float(i) * 278.0, CA.PAVE_TOP + 62.0,
					98.0, C_IRON.lightened(0.10), C_WARM, on)
			for i in range(5):
				CA.tree(self, 190.0 + float(i) * 210.0, CA.PAVE_TOP + 4.0, 72.0,
					Color(0.353, 0.302, 0.251), C_LEAF, 1.0)
		"williamsburg":
			for i in range(4):
				CA.lamp(self, 140.0 + float(i) * 270.0, CA.PAVE_TOP + 62.0,
					92.0, C_IRON, C_WARM, on)
			CA.bin(self, 620.0, CA.PAVE_TOP + 64.0, Color(0.251, 0.259, 0.267))
		_:
			for i in range(4):
				CA.lamp(self, 100.0 + float(i) * 286.0, CA.PAVE_TOP + 62.0,
					88.0, C_IRON, C_WARM, on)
			CA.stall(self, 470.0, CA.PAVE_TOP + 58.0, 132.0,
				Color(0.616, 0.184, 0.184),
				[C_CAB, Color(0.729, 0.290, 0.208), C_LEAF])
	if on:
		CA.motes(self, 22, Color(0.90, 0.88, 0.80, 0.08), _t, 10.0, 20.0, 1.3)


# ── Collision ────────────────────────────────────────────────────────────────

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	match district:
		"jacksonheights":
			out.append(Rect2(470.0, 330.0, 132.0, 22.0))
		"lowereast":
			out.append(Rect2(300.0, 336.0, 74.0, 18.0))
		_:
			pass
	return out
