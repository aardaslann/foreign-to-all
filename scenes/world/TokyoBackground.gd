extends Node2D

# Tokyo. Four districts, and not one of them is the postcard.
#
# No neon wall, no scramble crossing. What actually identifies this city from
# the ground is much duller and much more specific: utility poles, an absolute
# tangle of overhead wire, buildings that are small and set right on the lot
# line with no pavement between them and the road, and vending machines lit all
# night in streets with nobody in them.
#
# YANAKA is shitamachi - low town. It missed the firebombing and the earthquake,
# so it is still wooden houses, tiled roofs, and a hundred-and-seventy-metre
# shopping street with lanterns strung down it.
#
# JINBOCHO is a hundred and thirty second-hand bookshops in a row. It is a
# street made entirely of writing the alien cannot read, stacked to head height
# on the pavement under awnings, and it is the plate where that is the joke.
#
# SHINBASHI is under the elevated railway: brick arches, izakaya crammed into
# them, salarymen standing up to drink at seven.
#
# ASAKUSA is the temple approach - a tiled roof much bigger than everything
# near it, and one enormous paper lantern.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "yanaka"
# "yanaka" | "jinbocho" | "shinbashi" | "asakusa" | "ueno"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Grey-beige render, dark timber, and one indigo. Japanese street colour is
# quieter than its reputation; the saturation lives on signage and cloth.
const C_SKY_ZEN  := Color(0.055, 0.055, 0.118)
const C_SKY_MID  := Color(0.086, 0.086, 0.153)
const C_SKY_LOW  := Color(0.157, 0.141, 0.184)
const C_SKY_HAZE := Color(0.239, 0.196, 0.184)

const C_DAY_HI   := Color(0.518, 0.576, 0.639)
const C_DAY_MID  := Color(0.647, 0.671, 0.686)
const C_DAY_LOW  := Color(0.769, 0.761, 0.729)

const C_RENDER   := Color(0.839, 0.827, 0.796)
const C_RENDER_B := Color(0.706, 0.678, 0.635)
const C_TIMBER   := Color(0.243, 0.204, 0.169)
const C_TIMBER_L := Color(0.451, 0.361, 0.267)
const C_TILE     := Color(0.286, 0.302, 0.318)   # kawara roof tile, blue-grey
const C_BRICK    := Color(0.451, 0.298, 0.251)
const C_GLASS    := Color(0.169, 0.184, 0.204)
const C_INDIGO   := Color(0.145, 0.239, 0.451)
const C_VERMIL   := Color(0.769, 0.216, 0.169)   # the lantern, and only that
const C_PAPER    := Color(0.933, 0.898, 0.816)
const C_WIRE     := Color(0.078, 0.075, 0.086, 0.82)
const C_LAMP     := Color(1.0, 0.878, 0.671)
const C_JOINT    := Color(0.078, 0.075, 0.094, 0.30)

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
			C_INDIGO, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_PAPER, C_TIMBER, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	_draw_far_towers()
	match district:
		"jinbocho": _draw_jinbocho()
		"shinbashi": _draw_shinbashi()
		"asakusa":  _draw_asakusa()
		"ueno":     _draw_ueno()
		_:          _draw_yanaka()
	_draw_wires()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_RENDER.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 87)
	_draw_ground()
	# Kaminarimon stands ON the street, in front of the shop row, so it
	# is drawn after the ground rather than behind it.
	if district == "asakusa":
		_draw_kaminarimon(600.0)
	_draw_doors()
	_draw_furniture()
	CA.vignette(self, 0.26)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Wires ─────────────────────────────────────────────────────────────────────
# The single most identifying feature of a Japanese street, and the one thing
# every visitor photographs without meaning to. Poles are concrete, not wood,
# and the bundle at each one is a mess nobody has ever tidied.

func _draw_wires() -> void:
	# Asakusa opens the span across the gate. Everywhere else the poles run
	# on a regular pitch; here one of them stood directly through the
	# lantern, which is the one thing on the plate that has to read.
	var poles := [64.0, 318.0, 572.0, 826.0, 1096.0]
	if district == "asakusa":
		poles = [64.0, 300.0, 900.0, 1096.0]
	for i in range(poles.size() - 1):
		CA.wires(self, float(poles[i]), 118.0, float(poles[i + 1]), 124.0,
			6, 24.0, C_WIRE)
		CA.wires(self, float(poles[i]), 168.0, float(poles[i + 1]), 172.0,
			3, 14.0, C_WIRE)
	for p in poles:
		var px: float = float(p)
		draw_rect(Rect2(px - 4.0, CA.PAVE_TOP + 40.0 - 216.0, 8.0, 216.0),
			Color(0.588, 0.580, 0.561) if GameState.is_morning()
			else Color(0.588, 0.580, 0.561).darkened(0.48))
		for a in range(2):
			draw_rect(Rect2(px - 16.0, 112.0 + float(a) * 22.0, 32.0, 3.0),
				Color(0.40, 0.39, 0.38))
		CA.wire_knot(self, px, 140.0, C_WIRE)
		# The transformer can, which every third pole carries.
		if int(px) % 2 == 0:
			draw_rect(Rect2(px + 6.0, 148.0, 15.0, 24.0), Color(0.42, 0.41, 0.40))
			draw_rect(Rect2(px + 6.0, 148.0, 15.0, 3.0), Color(0.55, 0.54, 0.52))


# ── Yanaka ────────────────────────────────────────────────────────────────────
# Wooden two-storey houses, tiled roofs, a lane too narrow for a pavement, and
# the lantern string of Yanaka Ginza overhead.

func _draw_yanaka() -> void:
	for spec in [[-16.0, 96.0, 2], [82.0, 78.0, 2], [162.0, 104.0, 2],
			[268.0, 84.0, 2], [354.0, 92.0, 3], [448.0, 76.0, 2],
			[526.0, 108.0, 2], [636.0, 88.0, 2], [726.0, 96.0, 3],
			[824.0, 82.0, 2], [908.0, 110.0, 2], [1020.0, 142.0, 2]]:
		_draw_machiya(float(spec[0]), float(spec[1]), int(spec[2]))
	_draw_lanterns(196.0)


# A machiya: timber post-and-beam, plaster infill, a tiled roof with a deep
# overhang, and a noren curtain in the doorway if the shop is open.
func _draw_machiya(x: float, w: float, storeys: int) -> void:
	var body: Color = C_RENDER if (int(x) % 3) else C_RENDER_B
	var wood: Color = C_TIMBER
	var tile: Color = C_TILE
	if not GameState.is_morning():
		body = body.darkened(0.46)
		wood = wood.darkened(0.30)
		tile = tile.darkened(0.42)
	var floor_h: float = 40.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	# The frame. Exposed posts at the corners and a beam at every floor is what
	# makes a Japanese timber house read as timber at eight pixels a storey.
	draw_rect(Rect2(x, top, 5.0, GROUND_Y - top), wood)
	draw_rect(Rect2(x + w - 5.0, top, 5.0, GROUND_Y - top), wood)
	for s in range(storeys + 1):
		draw_rect(Rect2(x, GROUND_Y - float(s) * floor_h - 4.0, w, 5.0), wood)
	# Kawara. Heavy, barrel-jointed, with a deep overhang and a shadow under it.
	draw_rect(Rect2(x - 9.0, top - 15.0, w + 18.0, 16.0), tile)
	draw_rect(Rect2(x - 11.0, top - 3.0, w + 22.0, 6.0), tile.darkened(0.24))
	draw_rect(Rect2(x - 9.0, top - 15.0, w + 18.0, 3.0), tile.lightened(0.24))
	for i in range(int((w + 18.0) / 8.0)):
		draw_rect(Rect2(x - 9.0 + float(i) * 8.0, top - 15.0, 2.0, 16.0),
			Color(0, 0, 0, 0.16))
	draw_rect(Rect2(x - 6.0, top + 3.0, w + 12.0, 7.0), Color(0, 0, 0, 0.22))
	# Upper floor: shoji, warm when lit. Lower floor: glass and a curtain.
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var lit: bool = not GameState.is_morning() and ((int(x) + s * 7) % 3) == 0
		draw_rect(Rect2(x + 8.0, wy, w - 16.0, 22.0),
			Color(0.98, 0.92, 0.76, 0.90) if lit else C_GLASS)
		for g in range(int((w - 16.0) / 11.0) + 1):
			draw_rect(Rect2(x + 8.0 + float(g) * 11.0, wy, 1.4, 22.0), wood)
		draw_rect(Rect2(x + 8.0, wy + 10.0, w - 16.0, 1.4), wood)
	if (int(x) % 4) == 0:
		_draw_noren(x + w * 0.5, GROUND_Y - 34.0, minf(w - 16.0, 62.0))


# The split cloth in a doorway. Hung means open; taken in means shut, and that
# is the only opening-hours sign a lot of these places have.
func _draw_noren(x: float, y: float, w: float) -> void:
	var cloth: Color = C_INDIGO if GameState.is_morning() \
		else C_INDIGO.darkened(0.30)
	draw_rect(Rect2(x - w * 0.5, y, w, 22.0), cloth)
	draw_rect(Rect2(x - w * 0.5, y, w, 2.0), cloth.lightened(0.30))
	draw_rect(Rect2(x - 1.0, y + 4.0, 2.0, 18.0), Color(0, 0, 0, 0.30))
	for i in range(3):
		draw_rect(Rect2(x - 9.0, y + 5.0 + float(i) * 5.0, 18.0, 3.0),
			C_PAPER.darkened(0.10))


# The lantern string over Yanaka Ginza. Paper, warm, and strung the whole way
# down rather than hung at doors.
func _draw_lanterns(y: float) -> void:
	var on: bool = not GameState.is_morning()
	var pts := PackedVector2Array()
	for k in range(13):
		var u: float = float(k) / 12.0
		pts.append(Vector2(lerpf(-20.0, CA.VW + 20.0, u), y + sin(u * PI) * 12.0))
	draw_polyline(pts, Color(0.20, 0.19, 0.18, 0.80), 1.6, true)
	for i in range(12):
		var u: float = (float(i) + 0.5) / 12.0
		var lx: float = lerpf(-20.0, CA.VW + 20.0, u)
		var ly: float = y + sin(u * PI) * 12.0 + 4.0
		var body: Color = C_PAPER if on else C_PAPER.darkened(0.44)
		draw_rect(Rect2(lx - 8.0, ly, 16.0, 22.0), body)
		draw_rect(Rect2(lx - 8.0, ly, 16.0, 3.0), C_VERMIL.darkened(0.20))
		draw_rect(Rect2(lx - 8.0, ly + 19.0, 16.0, 3.0), C_VERMIL.darkened(0.20))
		for r in range(3):
			draw_rect(Rect2(lx - 8.0, ly + 6.0 + float(r) * 5.0, 16.0, 1.0),
				Color(0, 0, 0, 0.14))
		if not on:
			continue
		for k in range(3):
			draw_circle(Vector2(lx, ly + 11.0), 13.0 + float(k) * 10.0,
				Color(1.0, 0.88, 0.66, 0.035 - float(k) * 0.008))


# ── Jinbocho ──────────────────────────────────────────────────────────────────
# A street made of writing. The books come out onto the pavement at opening and
# go back in at closing, stacked to head height under a long awning, and the
# alien can read precisely none of it.

func _draw_jinbocho() -> void:
	for spec in [[-14.0, 128.0, 4], [118.0, 108.0, 3], [230.0, 136.0, 4],
			[370.0, 116.0, 3], [490.0, 142.0, 4], [636.0, 110.0, 3],
			[750.0, 130.0, 4], [884.0, 120.0, 3], [1008.0, 152.0, 4]]:
		_draw_bookshop(float(spec[0]), float(spec[1]), int(spec[2]))


func _draw_bookshop(x: float, w: float, storeys: int) -> void:
	var body: Color = C_RENDER_B if (int(x) % 2) else Color(0.612, 0.573, 0.522)
	if not GameState.is_morning():
		body = body.darkened(0.48)
	var floor_h: float = 34.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.20))
	CA.band(self, x, w, top, 6.0, body.lightened(0.16))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var bays: int = maxi(1, int(w / 42.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 17 + s * 11) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 22.0, C_GLASS,
			C_TIMBER, lit)
	# The awning, and under it the books: three shelves of vertical spines, in
	# the browns and reds a wall of second-hand paper actually is.
	draw_rect(Rect2(x + 4.0, GROUND_Y - 52.0, w - 8.0, 12.0),
		C_TIMBER_L if GameState.is_morning() else C_TIMBER_L.darkened(0.40))
	draw_rect(Rect2(x + 4.0, GROUND_Y - 40.0, w - 8.0, 4.0), Color(0, 0, 0, 0.34))
	var spine := [Color(0.451, 0.290, 0.235), Color(0.361, 0.325, 0.271),
		Color(0.502, 0.412, 0.290), Color(0.298, 0.267, 0.290),
		Color(0.545, 0.353, 0.259)]
	for shelf in range(3):
		var sy: float = GROUND_Y - 36.0 + float(shelf) * 12.0
		var n: int = int((w - 16.0) / 4.0)
		for i in range(n):
			var c: Color = spine[(i + shelf * 3 + int(x)) % spine.size()]
			if not GameState.is_morning():
				c = c.darkened(0.40)
			var h: float = 9.0 + float((i * 13 + shelf) % 3)
			draw_rect(Rect2(x + 8.0 + float(i) * 4.0, sy + (11.0 - h), 3.0, h), c)
		draw_rect(Rect2(x + 6.0, sy + 11.0, w - 12.0, 1.6), Color(0, 0, 0, 0.30))
	# A glass case on the pavement with the expensive ones in it.
	if (int(x) % 3) == 0:
		draw_rect(Rect2(x + 20.0, CA.PAVE_TOP + 6.0, 54.0, 30.0),
			Color(0.71, 0.76, 0.78, 0.30))
		draw_rect(Rect2(x + 20.0, CA.PAVE_TOP + 6.0, 54.0, 30.0),
			C_TIMBER, false, 1.6)


# ── Shinbashi ─────────────────────────────────────────────────────────────────
# Under the elevated railway. Brick arches with a bar wedged into each one, and
# a train going over the top of the conversation every ninety seconds.

func _draw_shinbashi() -> void:
	var brick: Color = C_BRICK if GameState.is_morning() else C_BRICK.darkened(0.48)
	# The viaduct, right across, at first-floor height.
	draw_rect(Rect2(-20.0, 96.0, CA.VW + 40.0, 46.0), brick.darkened(0.18))
	draw_rect(Rect2(-20.0, 96.0, CA.VW + 40.0, 5.0), brick.lightened(0.16))
	draw_rect(Rect2(-20.0, 136.0, CA.VW + 40.0, 7.0), Color(0, 0, 0, 0.34))
	for i in range(6):
		var ax: float = -30.0 + float(i) * 196.0
		_draw_arch(ax, brick)
	_draw_train()


func _draw_arch(x: float, brick: Color) -> void:
	var w: float = 168.0
	draw_rect(Rect2(x, 142.0, w, GROUND_Y - 142.0), brick)
	for r in range(int((GROUND_Y - 142.0) / 7.0)):
		var y: float = 142.0 + float(r) * 7.0
		draw_rect(Rect2(x, y, w, 1.0), Color(0, 0, 0, 0.13))
		var off: float = 8.0 if (r % 2) else 0.0
		for c in range(int(w / 16.0) + 1):
			draw_rect(Rect2(x + off + float(c) * 16.0, y, 1.0, 7.0),
				Color(0, 0, 0, 0.10))
	# The opening, arched, with an izakaya inside it and a lantern out front.
	var ox: float = x + 24.0
	var ow: float = w - 48.0
	draw_rect(Rect2(ox, 186.0, ow, GROUND_Y - 186.0), Color(0.086, 0.078, 0.075))
	for k in range(9):
		var u: float = float(k) / 8.0
		var dy: float = sin(u * PI) * 16.0
		draw_rect(Rect2(ox + u * ow - 4.0, 186.0 - dy, 9.0, dy + 4.0),
			Color(0.086, 0.078, 0.075))
	var warm: bool = not GameState.is_morning()
	draw_rect(Rect2(ox + 8.0, GROUND_Y - 44.0, ow - 16.0, 44.0),
		Color(0.98, 0.86, 0.62, 0.70) if warm else Color(0.24, 0.22, 0.21))
	_draw_akachochin(x + w * 0.5, 178.0, warm)


# The red paper lantern outside an izakaya. It means exactly one thing and
# everybody in the country reads it instantly: this place is open and cheap.
func _draw_akachochin(x: float, y: float, on: bool) -> void:
	var body: Color = C_VERMIL if on else C_VERMIL.darkened(0.46)
	draw_rect(Rect2(x - 1.0, y - 10.0, 2.0, 10.0), Color(0.20, 0.19, 0.18))
	draw_rect(Rect2(x - 11.0, y, 22.0, 28.0), body)
	draw_rect(Rect2(x - 11.0, y, 22.0, 4.0), Color(0.13, 0.12, 0.12))
	draw_rect(Rect2(x - 11.0, y + 24.0, 22.0, 4.0), Color(0.13, 0.12, 0.12))
	for r in range(4):
		draw_rect(Rect2(x - 11.0, y + 7.0 + float(r) * 5.0, 22.0, 1.0),
			Color(0, 0, 0, 0.18))
	for k in range(3):
		draw_rect(Rect2(x - 5.0, y + 7.0 + float(k) * 6.0, 10.0, 4.0),
			Color(0.95, 0.92, 0.86, 0.85))
	if not on:
		return
	for k in range(4):
		draw_circle(Vector2(x, y + 14.0), 17.0 + float(k) * 12.0,
			Color(1.0, 0.52, 0.36, 0.040 - float(k) * 0.008))


# Every ninety seconds, and nobody under the arches looks up.
func _draw_train() -> void:
	var cycle: float = fmod(_t, 22.0) / 22.0
	if cycle > 0.42:
		return
	var tx: float = lerpf(-460.0, CA.VW + 300.0, cycle / 0.42)
	for c in range(3):
		var cx: float = tx + float(c) * 152.0
		draw_rect(Rect2(cx, 52.0, 144.0, 44.0), Color(0.784, 0.796, 0.808))
		draw_rect(Rect2(cx, 52.0, 144.0, 5.0), Color(0.878, 0.886, 0.894))
		draw_rect(Rect2(cx, 70.0, 144.0, 7.0), Color(0.129, 0.451, 0.310))
		var pane: Color = Color(0.184, 0.208, 0.239)
		if not GameState.is_morning():
			pane = Color(0.949, 0.941, 0.878, 0.88)
		for i in range(5):
			draw_rect(Rect2(cx + 12.0 + float(i) * 26.0, 58.0, 19.0, 11.0), pane)
		draw_rect(Rect2(cx, 94.0, 144.0, 4.0), Color(0, 0, 0, 0.34))


# ── Asakusa ───────────────────────────────────────────────────────────────────
# The temple approach. One tiled roof far bigger than anything near it, one
# enormous paper lantern, and a run of small shops the whole way to the gate.

func _draw_asakusa() -> void:
	_draw_temple_roof(600.0)
	for spec in [[-16.0, 92.0], [78.0, 86.0], [166.0, 96.0], [264.0, 82.0],
			[348.0, 90.0], [816.0, 88.0], [906.0, 94.0], [1002.0, 86.0],
			[1090.0, 92.0]]:
		_draw_stall_shop(float(spec[0]), float(spec[1]))


func _draw_temple_roof(x: float) -> void:
	var tile: Color = C_TILE.darkened(0.10)
	if not GameState.is_morning():
		# Floodlit, not unlit. Darkening this to night values buried the one
		# building the district exists for.
		tile = tile.darkened(0.18)
	# A hipped-and-gabled roof, drawn as a swept trapezoid. The sweep is the
	# whole silhouette; a flat roof here would read as a warehouse.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 250.0, 190.0), Vector2(x - 150.0, 84.0),
		Vector2(x + 150.0, 84.0), Vector2(x + 250.0, 190.0),
		Vector2(x + 214.0, 196.0), Vector2(x - 214.0, 196.0),
	]), tile)
	draw_rect(Rect2(x - 158.0, 78.0, 316.0, 10.0), tile.lightened(0.20))
	for i in range(24):
		draw_rect(Rect2(x - 210.0 + float(i) * 18.0, 92.0, 2.0, 100.0),
			Color(0, 0, 0, 0.14))
	draw_rect(Rect2(x - 220.0, 190.0, 440.0, 8.0), tile.darkened(0.26))
	# Upturned corners. Without these the roof is a shed.
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + side * 250.0, 190.0),
			Vector2(x + side * 316.0, 156.0),
			Vector2(x + side * 320.0, 172.0),
			Vector2(x + side * 258.0, 198.0),
		]), tile.lightened(0.06))
	# No posts here. This is the hall roof standing behind the shop row;
	# the gate in front of it has its own, drawn after the ground.


# Kaminarimon. It stands ON the street in front of the shop row, not behind
# it, which is why it is drawn after the ground: two vermilion posts, the
# tiled hip over them, and four metres of red paper hanging in the middle.
# It is the one object in this city that everybody arrives to look at.
func _draw_kaminarimon(x: float) -> void:
	var on: bool = not GameState.is_morning()
	var body: Color = C_VERMIL if on else C_VERMIL.darkened(0.18)
	var post: Color = body.darkened(0.24)
	var tile: Color = C_TILE.darkened(0.34 if on else 0.22)
	var soffit: float = 158.0
	var foot: float = 302.0

	if on:
		# Lit from inside. The glow goes down first so it does not wash out
		# the paper it is coming through.
		for k in range(5):
			draw_circle(Vector2(x, 236.0), 92.0 + float(k) * 34.0,
				Color(1.0, 0.46, 0.30, 0.050 - float(k) * 0.008))

	# The two great posts, on their stone footings.
	for px in [-116.0, 116.0]:
		draw_rect(Rect2(x + px - 17.0, soffit, 34.0, foot - soffit), post)
		draw_rect(Rect2(x + px - 17.0, soffit, 10.0, foot - soffit),
			post.lightened(0.16))
		draw_rect(Rect2(x + px - 23.0, foot - 16.0, 46.0, 16.0),
			Color(0.376, 0.365, 0.341) if GameState.is_morning()
			else Color(0.243, 0.235, 0.220))
	# The beam across them, and the bracket blocks the roof sits on.
	draw_rect(Rect2(x - 146.0, soffit - 16.0, 292.0, 18.0), post.darkened(0.14))
	for b in range(7):
		draw_rect(Rect2(x - 128.0 + float(b) * 42.0, soffit - 30.0, 22.0, 16.0),
			post.lightened(0.06))

	# The hip roof: a swept trapezoid with the corners turning up. Flat, it
	# is a shed; the sweep is the whole silhouette.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 168.0, soffit - 28.0), Vector2(x - 104.0, soffit - 92.0),
		Vector2(x + 104.0, soffit - 92.0), Vector2(x + 168.0, soffit - 28.0),
		Vector2(x + 148.0, soffit - 22.0), Vector2(x - 148.0, soffit - 22.0),
	]), tile)
	draw_rect(Rect2(x - 110.0, soffit - 98.0, 220.0, 9.0), tile.lightened(0.24))
	for i in range(17):
		draw_rect(Rect2(x - 140.0 + float(i) * 17.0, soffit - 86.0, 2.0, 60.0),
			Color(0, 0, 0, 0.16))
	for side in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + side * 168.0, soffit - 28.0),
			Vector2(x + side * 214.0, soffit - 54.0),
			Vector2(x + side * 218.0, soffit - 40.0),
			Vector2(x + side * 174.0, soffit - 20.0),
		]), tile.lightened(0.08))
	draw_rect(Rect2(x - 152.0, soffit - 24.0, 304.0, 7.0), tile.darkened(0.30))

	# The lantern. A barrel, so the sides are darker than the middle.
	var lt: float = soffit + 6.0
	var lh: float = 118.0
	draw_rect(Rect2(x - 12.0, soffit, 24.0, 10.0), Color(0.13, 0.12, 0.12))
	draw_rect(Rect2(x - 66.0, lt, 132.0, lh), body.darkened(0.16))
	draw_rect(Rect2(x - 52.0, lt, 104.0, lh), body)
	draw_rect(Rect2(x - 24.0, lt, 48.0, lh), body.lightened(0.08))
	draw_rect(Rect2(x - 66.0, lt, 132.0, 13.0), Color(0.13, 0.12, 0.12))
	draw_rect(Rect2(x - 66.0, lt + lh - 13.0, 132.0, 13.0), Color(0.13, 0.12, 0.12))
	for r in range(8):
		draw_rect(Rect2(x - 66.0, lt + 17.0 + float(r) * 11.0, 132.0, 1.8),
			Color(0, 0, 0, 0.20))
	# The black band across the middle with the characters on it.
	draw_rect(Rect2(x - 66.0, lt + 40.0, 132.0, 44.0), Color(0.10, 0.09, 0.09))
	for k2 in range(4):
		draw_rect(Rect2(x - 47.0 + float(k2) * 24.0, lt + 48.0, 18.0, 28.0),
			Color(0.94, 0.91, 0.85))
	draw_rect(Rect2(x - 15.0, lt + lh, 30.0, 13.0), Color(0.20, 0.16, 0.14))


func _draw_stall_shop(x: float, w: float) -> void:
	var body: Color = C_RENDER if (int(x) % 2) else C_RENDER_B
	if not GameState.is_morning():
		body = body.darkened(0.46)
	draw_rect(Rect2(x, 168.0, w, GROUND_Y - 168.0), body)
	draw_rect(Rect2(x, 168.0, w, 5.0), body.lightened(0.18))
	CA.awning(self, x + 3.0, 190.0, w - 6.0, C_VERMIL.darkened(0.10),
		Color(0.91, 0.88, 0.82))
	CA.sign_stack(self, x + 5.0, 216.0, w - 12.0, 1,
		C_PAPER, C_TIMBER, int(x))


# ── Ueno ──────────────────────────────────────────────────────────────────────
# Ameyoko. A market that grew into the space under the JR viaduct after the war
# and never left, so the roof is a railway and the shops are wedged between the
# piers. Goods hang from every available inch of frontage, the signage is three
# deep, and a train goes over the top of the conversation every two minutes.

func _draw_ueno() -> void:
	var conc: Color = Color(0.545, 0.533, 0.510)
	if not GameState.is_morning():
		conc = conc.darkened(0.50)
	# The viaduct. It is the ceiling of the market, not a thing behind it.
	draw_rect(Rect2(-20.0, 92.0, CA.VW + 40.0, 40.0), conc)
	draw_rect(Rect2(-20.0, 92.0, CA.VW + 40.0, 5.0), conc.lightened(0.16))
	draw_rect(Rect2(-20.0, 126.0, CA.VW + 40.0, 8.0), Color(0, 0, 0, 0.36))
	for i in range(6):
		var px: float = -10.0 + float(i) * 208.0
		draw_rect(Rect2(px, 134.0, 44.0, GROUND_Y - 134.0), conc)
		draw_rect(Rect2(px, 134.0, 12.0, GROUND_Y - 134.0), conc.lightened(0.10))
		for k in range(9):
			draw_rect(Rect2(px, 150.0 + float(k) * 11.0, 44.0, 1.4),
				Color(0, 0, 0, 0.14))
	# The shops, wedged between the piers, three signs deep on every one.
	for i in range(6):
		var sx: float = 40.0 + float(i) * 208.0
		draw_rect(Rect2(sx, 168.0, 156.0, GROUND_Y - 168.0),
			C_RENDER_B if GameState.is_morning() else C_RENDER_B.darkened(0.48))
		CA.awning(self, sx + 4.0, 206.0, 148.0, C_VERMIL.darkened(0.10),
			Color(0.90, 0.87, 0.80))
		CA.sign_stack(self, sx + 6.0, 140.0, 140.0, 3,
			[C_PAPER, C_VERMIL, C_INDIGO][i % 3],
			C_TIMBER if (i % 3) == 0 else C_PAPER, i)
		# Hanging goods, right down to head height, which is why nobody can
		# see the shop they are standing in front of.
		for k in range(9):
			var hx: float = sx + 10.0 + float(k) * 16.0
			var h: float = 22.0 + float((i * 7 + k * 13) % 18)
			draw_rect(Rect2(hx, 226.0, 3.0, h), Color(0.24, 0.22, 0.20, 0.70))
			draw_rect(Rect2(hx - 5.0, 226.0 + h, 13.0, 11.0),
				[Color(0.78, 0.28, 0.22), Color(0.86, 0.70, 0.24),
				 Color(0.30, 0.45, 0.62)][(i + k) % 3] if GameState.is_morning()
				else Color(0.42, 0.36, 0.32))
	_draw_train()


# ── Ground ────────────────────────────────────────────────────────────────────
# Yanaka has no kerb, because the lane has no pavement. Everywhere else does.

func _draw_ground() -> void:
	var pave: Color = Color(0.435, 0.427, 0.404)
	var road: Color = Color(0.310, 0.302, 0.290)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	if district == "yanaka":
		CA.ground(self, pave, pave.darkened(0.05), pave.darkened(0.11))
		CA.slabs(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 34.0, 22.0, C_JOINT)
		# The painted edge line that stands in for a kerb on a lane this narrow.
		draw_rect(Rect2(0, 384.0, CA.VW, 3.0), Color(0.86, 0.84, 0.78, 0.34))
		draw_rect(Rect2(0, 508.0, CA.VW, 3.0), Color(0.86, 0.84, 0.78, 0.34))
	else:
		CA.ground(self, pave, road, pave.darkened(0.08))
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 30.0, 30.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 30.0, 30.0, C_JOINT)
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.16))
		for i in range(12):
			draw_rect(Rect2(float(i) * 98.0, 442.0, 48.0, 4.0),
				Color(0.88, 0.86, 0.80, 0.30))
	# Tenji blocks: the yellow tactile paving invented in this country, and now
	# on every pavement in it. Nothing else on the itinerary has them.
	var yellow: Color = Color(0.898, 0.769, 0.180)
	if not GameState.is_morning():
		yellow = yellow.darkened(0.36)
	for i in range(int(CA.VW / 30.0) + 1):
		var bx: float = float(i) * 30.0
		draw_rect(Rect2(bx, 352.0, 28.0, 14.0), yellow)
		for d in range(4):
			draw_rect(Rect2(bx + 3.0 + float(d) * 7.0, 355.0, 4.0, 4.0),
				yellow.darkened(0.24))
	CA.sheen(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP,
		Color(0.62, 0.66, 0.72), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	# The vending machine. Lit all night, in a street with nobody in it, and
	# more than any single object it is what a Japanese street looks like at
	# four in the morning.
	_draw_vending(212.0, lit)
	if district != "yanaka":
		_draw_vending(922.0, lit)
	for x in [396.0, 760.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 74.0,
			Color(0.35, 0.35, 0.34), C_LAMP, lit)
	CA.bin(self, 560.0, CA.PAVE_TOP + 40.0, Color(0.35, 0.36, 0.38))
	# Yanaka's cats are declared in cats() and stand as nodes; see CatArt.
	# Bicycles, parked in a row against the wall, which is where they live.
	_draw_bikes(660.0, 4)


func _draw_vending(x: float, on: bool) -> void:
	var body: Color = Color(0.878, 0.859, 0.827) if on \
		else Color(0.647, 0.635, 0.612)
	draw_rect(Rect2(x - 24.0, CA.PAVE_TOP - 62.0, 48.0, 62.0),
		Color(0.28, 0.28, 0.30))
	draw_rect(Rect2(x - 22.0, CA.PAVE_TOP - 60.0, 44.0, 42.0), body)
	# The rows of cans behind the glass, which is what makes it readable.
	var tints := [C_VERMIL, C_INDIGO, Color(0.20, 0.55, 0.32),
		Color(0.85, 0.68, 0.16)]
	for r in range(3):
		for c in range(4):
			var t: Color = tints[(r + c) % tints.size()]
			if not on:
				t = t.darkened(0.40)
			draw_rect(Rect2(x - 18.0 + float(c) * 10.0,
				CA.PAVE_TOP - 56.0 + float(r) * 12.0, 7.0, 9.0), t)
	draw_rect(Rect2(x - 22.0, CA.PAVE_TOP - 16.0, 44.0, 14.0),
		Color(0.24, 0.24, 0.26))
	if not on:
		return
	for k in range(4):
		draw_circle(Vector2(x, CA.PAVE_TOP - 38.0), 30.0 + float(k) * 16.0,
			Color(0.90, 0.94, 1.0, 0.030 - float(k) * 0.006))


func _draw_bikes(x: float, n: int) -> void:
	var frame: Color = Color(0.30, 0.31, 0.33)
	if not GameState.is_morning():
		frame = frame.darkened(0.36)
	for i in range(n):
		var bx: float = x + float(i) * 22.0
		var by: float = CA.PAVE_TOP + 34.0
		draw_circle(Vector2(bx, by), 8.0, Color(0, 0, 0, 0.0))
		draw_arc(Vector2(bx, by), 8.0, 0, TAU, 14, frame, 1.6)
		draw_arc(Vector2(bx + 17.0, by), 8.0, 0, TAU, 14, frame, 1.6)
		draw_line(Vector2(bx, by), Vector2(bx + 9.0, by - 13.0), frame, 1.8)
		draw_line(Vector2(bx + 17.0, by), Vector2(bx + 9.0, by - 13.0), frame, 1.8)
		draw_rect(Rect2(bx + 2.0, by - 20.0, 12.0, 6.0), frame.lightened(0.20))


func solids() -> Array:
	var out: Array = []
	out.append(Rect2(188.0, CA.PAVE_TOP - 22.0, 48.0, 26.0))       # vending
	out.append(Rect2(548.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))       # bin
	out.append(Rect2(652.0, CA.PAVE_TOP + 18.0, 92.0, 26.0))       # bikes
	if district != "yanaka":
		out.append(Rect2(898.0, CA.PAVE_TOP - 22.0, 48.0, 26.0))   # vending
	if district == "asakusa":
		out.append(Rect2(401.0, CA.PAVE_TOP - 40.0, 26.0, 44.0))   # temple post
		out.append(Rect2(773.0, CA.PAVE_TOP - 40.0, 26.0, 44.0))   # temple post
	for p in [64.0, 318.0, 572.0, 826.0, 1096.0]:
		out.append(Rect2(float(p) - 5.0, CA.PAVE_TOP + 14.0, 10.0, 28.0))
	return out


# The towers, where this city actually has them.
# Shiodome stands directly over these bars. The towers went up on the old
	# freight yard and the drinking stayed underneath them.
func _draw_far_towers() -> void:
	if district != "shinbashi":
		return
	CA.skyline(self, 238.0, Color(0.263, 0.286, 0.341), Color(0.157, 0.180, 0.224),
		10, 53, not GameState.is_morning())


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	if district != "yanaka":
		return []
	return [
		[Vector2(640.0, CA.PAVE_TOP + 6.0), 0, 2],
		[Vector2(856.0, CA.PAVE_TOP + 44.0), 1, 1],
	]
