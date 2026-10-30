extends Node2D

# Seoul. Euljiro and Jongno.
#
# EULJIRO is the tool-and-printing quarter: about eighty tile and pottery shops
# and several thousand small workshops, in three-storey blocks built so tight
# against each other that they read as one continuous building. The research
# phrase that decided this plate was "oil-stained walls, rusted iron stairs,
# worn signboards" — nothing here is styled, everything is USED, and the
# machines on the ground floor have been running since the sixties.
#
# The other half of the fact matters just as much: craftsmen in their sixties
# and seventies work the ground floors by day, and people in their twenties
# drink on the upper floors of the same buildings at night. Two generations,
# one staircase. That is why this city owns the register mechanic, and it is
# why the plate is drawn with the workshops lit low and the upper floors lit
# warm — you can see both populations at once.
#
# Behind all of it, glass towers at a completely different scale, because the
# alleys only survive in pockets between redevelopments. The towers are drawn
# cold and enormous and slightly out of focus. They are not on this street.
#
# JONGNO is older and quieter: the arcade, and the men who have been coming to
# it for forty years.
#
# Ground bands are Berlin gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "euljiro"
# "euljiro" | "jongno" | "mangwon" | "seongsu" | "hongdae"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Grey-green tile, oxidised steel, and signage in the four colours Korean shop
# boards actually use: red, cobalt, green and black on white.
const C_SKY_ZEN  := Color(0.058, 0.056, 0.118)
const C_SKY_MID  := Color(0.086, 0.086, 0.157)
const C_SKY_LOW  := Color(0.153, 0.129, 0.180)
const C_SKY_HAZE := Color(0.255, 0.180, 0.161)

const C_DAY_HI   := Color(0.482, 0.545, 0.616)
const C_DAY_MID  := Color(0.612, 0.643, 0.671)
const C_DAY_LOW  := Color(0.729, 0.722, 0.694)

const C_TILE     := Color(0.639, 0.643, 0.620)    # the ubiquitous wall tile
const C_TILE_B   := Color(0.545, 0.561, 0.549)
const C_RENDER   := Color(0.478, 0.463, 0.435)
const C_STEEL    := Color(0.416, 0.400, 0.373)
const C_RUST     := Color(0.451, 0.278, 0.184)
const C_SHUTTER  := Color(0.365, 0.373, 0.376)
const C_GLASS    := Color(0.161, 0.176, 0.196)

const C_SIGN_W   := Color(0.902, 0.894, 0.859)
const C_SIGN_R   := Color(0.788, 0.196, 0.192)
const C_SIGN_B   := Color(0.145, 0.302, 0.596)
const C_SIGN_G   := Color(0.129, 0.427, 0.302)
const C_INK      := Color(0.114, 0.106, 0.098)

const C_TOWER    := Color(0.271, 0.298, 0.353)
const C_TOWER_G  := Color(0.310, 0.353, 0.416)
const C_WARM     := Color(1.0, 0.855, 0.588)

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
			C_SIGN_B, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_SIGN_W, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	_draw_towers()
	match district:
		"jongno":  _draw_arcade()
		"mangwon": _draw_mangwon()
		"seongsu": _draw_seongsu()
		"hongdae": _draw_hongdae()
		_:         _draw_alley()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_RENDER.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 69)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.22, 0.26, 0.32), 0.05)
	CA.vignette(self, 0.28)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.05))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# The towers. Drawn first, drawn cold, and drawn without a ground floor, so
# they read as being somewhere else entirely rather than at the end of the road.
func _draw_towers() -> void:
	var body: Color = C_TOWER if GameState.is_morning() else C_TOWER.darkened(0.44)
	var glass: Color = C_TOWER_G if GameState.is_morning() \
		else C_TOWER_G.darkened(0.50)
	var spec := [[92.0, 96.0, 18.0], [246.0, 74.0, 44.0], [640.0, 108.0, 8.0],
		[812.0, 82.0, 30.0], [1008.0, 92.0, 22.0]]
	for i in range(spec.size()):
		var s: Array = spec[i]
		var x: float = float(s[0])
		var w: float = float(s[1])
		var top: float = float(s[2])
		draw_rect(Rect2(x, top, w, 210.0 - top), body)
		draw_rect(Rect2(x + w - 10.0, top, 10.0, 210.0 - top), body.darkened(0.20))
		var rows: int = int((200.0 - top) / 15.0)
		for r in range(rows):
			var fy: float = top + 6.0 + float(r) * 15.0
			draw_rect(Rect2(x + 4.0, fy, w - 8.0, 9.0), glass)
			if not GameState.is_morning() and ((i * 11 + r * 7) % 7) < 2:
				draw_rect(Rect2(x + 4.0, fy, w - 8.0, 9.0),
					Color(0.85, 0.88, 0.92, 0.32))
		for b in range(int(w / 18.0) + 1):
			draw_rect(Rect2(x + float(b) * 18.0, top, 2.0, 210.0 - top),
				body.lightened(0.14))
		if not GameState.is_morning():
			var blink: float = 0.35 + 0.65 * absf(sin(_t * 1.5 + float(i)))
			draw_circle(Vector2(x + w * 0.5, top - 4.0), 2.2,
				Color(0.92, 0.30, 0.28, blink))


# ── Euljiro ───────────────────────────────────────────────────────────────────
# One continuous three-storey mass, divided into units by nothing but a change
# of tile and a downpipe. There is no gap between buildings anywhere on the
# street, which is what makes the alley read as a corridor rather than a road.

const UNITS := [
	# x, width, tile variant
	[-12.0, 132.0, 0], [120.0, 96.0, 1], [216.0, 118.0, 0], [334.0, 104.0, 2],
	[438.0, 126.0, 1], [564.0, 92.0, 0], [656.0, 138.0, 2], [794.0, 108.0, 1],
	[902.0, 116.0, 0], [1018.0, 148.0, 2],
]


func _draw_alley() -> void:
	for i in range(UNITS.size()):
		var u: Array = UNITS[i]
		_draw_unit(float(u[0]), float(u[1]), int(u[2]), i)
	# The one thing every photograph of this street has in it: a rusted iron
	# staircase bolted to the outside, going to the bars on the upper floors.
	_draw_outside_stair(586.0)
	_draw_outside_stair(1006.0)


func _draw_unit(x: float, w: float, variant: int, seed_i: int) -> void:
	var tiles := [C_TILE, C_TILE_B, C_RENDER]
	var body: Color = tiles[variant]
	if not GameState.is_morning():
		body = body.darkened(0.48)
	var top: float = 96.0
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	# Tile courses. The wall is a grid of 15cm squares and at this scale that
	# is a horizontal every four pixels, which is most of the texture.
	for r in range(int((GROUND_Y - top) / 9.0)):
		draw_rect(Rect2(x, top + float(r) * 9.0, w, 1.0), Color(0, 0, 0, 0.10))
	draw_rect(Rect2(x + w - 4.0, top, 4.0, GROUND_Y - top), body.darkened(0.26))
	# Oil and rain, always downwards, always from a fixing.
	for k in range(3):
		var sx: float = x + 14.0 + float((seed_i * 31 + k * 47) % int(w - 24.0))
		draw_rect(Rect2(sx, top + 30.0, 3.0, GROUND_Y - top - 40.0),
			Color(0.09, 0.07, 0.05, 0.20))

	# Two floors of windows, and every one of them has a box unit under it.
	for s in range(2):
		var wy: float = top + 22.0 + float(s) * 52.0
		var bays: int = maxi(2, int(w / 44.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 23 + s * 9) % (1 << bays)
		CA.window_row(self, x, w, wy, bays, 26.0, 24.0, C_GLASS, C_STEEL, lit)
		var step: float = w / float(bays)
		for b in range(bays):
			_draw_aircon(x + step * (float(b) + 0.5) + 15.0, wy + 26.0)

	# Signboards, stacked up the corner of every unit. This is the single most
	# recognisable thing about a Korean commercial street and it is also, for
	# this game, the wall: dense, legible as marks, meaningless as language.
	var board: Color = [C_SIGN_W, C_SIGN_R, C_SIGN_B, C_SIGN_G][seed_i % 4]
	var ink: Color = C_INK if board == C_SIGN_W else C_SIGN_W
	CA.sign_stack(self, x + 4.0, top + 6.0, w * 0.52, 3, board, ink, seed_i)
	# One projecting blade sign at right angles, because half of them stick out.
	if (seed_i % 3) == 0:
		var bx: float = x + w - 20.0
		draw_rect(Rect2(bx, top + 14.0, 15.0, 74.0), board.darkened(0.10))
		draw_rect(Rect2(bx, top + 14.0, 15.0, 2.0), board.lightened(0.24))
		for m in range(4):
			draw_rect(Rect2(bx + 4.0, top + 22.0 + float(m) * 16.0, 7.0, 10.0), ink)

	# The corrugated plastic awning over the workshop door, and the roller
	# shutter half down beside it.
	if (seed_i % 2) == 0:
		_draw_corrugated(x + 10.0, GROUND_Y - 30.0, w - 30.0)
	if (seed_i % 4) == 1:
		_draw_shutter(x + 16.0, GROUND_Y - 62.0, minf(w - 32.0, 92.0))


func _draw_aircon(x: float, y: float) -> void:
	var box: Color = Color(0.706, 0.702, 0.678)
	if not GameState.is_morning():
		box = box.darkened(0.45)
	draw_rect(Rect2(x, y, 20.0, 14.0), box)
	draw_rect(Rect2(x, y, 20.0, 2.0), box.lightened(0.20))
	for i in range(4):
		draw_rect(Rect2(x + 2.0, y + 3.0 + float(i) * 3.0, 16.0, 1.2),
			Color(0, 0, 0, 0.28))
	draw_rect(Rect2(x + 4.0, y + 14.0, 2.0, 26.0), Color(0.20, 0.19, 0.18, 0.55))


func _draw_corrugated(x: float, y: float, w: float) -> void:
	var sheet: Color = Color(0.196, 0.404, 0.373, 0.88)
	if not GameState.is_morning():
		sheet = sheet.darkened(0.35)
	draw_rect(Rect2(x, y, w, 13.0), sheet)
	for i in range(int(w / 7.0)):
		draw_rect(Rect2(x + float(i) * 7.0, y, 2.0, 13.0), Color(0, 0, 0, 0.16))
	draw_rect(Rect2(x, y + 13.0, w, 3.0), Color(0, 0, 0, 0.32))


func _draw_shutter(x: float, y: float, w: float) -> void:
	var sh: Color = C_SHUTTER if GameState.is_morning() \
		else C_SHUTTER.darkened(0.42)
	draw_rect(Rect2(x, y, w, 44.0), sh)
	for i in range(11):
		draw_rect(Rect2(x, y + float(i) * 4.0, w, 1.4), Color(0, 0, 0, 0.24))
	draw_rect(Rect2(x, y + 44.0, w, 3.0), sh.darkened(0.40))


func _draw_outside_stair(x: float) -> void:
	var rust: Color = C_RUST if GameState.is_morning() else C_RUST.darkened(0.42)
	draw_rect(Rect2(x, 116.0, 4.0, 122.0), rust)
	draw_rect(Rect2(x + 44.0, 116.0, 4.0, 122.0), rust)
	for i in range(11):
		var sy: float = 128.0 + float(i) * 10.0
		draw_rect(Rect2(x, sy, 48.0, 3.0), rust.lightened(0.10))
	# A landing, and the strip light over the door at the top of it.
	draw_rect(Rect2(x - 6.0, 112.0, 60.0, 5.0), rust.darkened(0.20))
	if not GameState.is_morning():
		draw_rect(Rect2(x + 8.0, 104.0, 30.0, 4.0),
			Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.75))
		for i in range(3):
			draw_rect(Rect2(x - float(i) * 8.0, 100.0 - float(i) * 4.0,
				46.0 + float(i) * 16.0, 16.0 + float(i) * 8.0),
				Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.030))


# ── Jongno ────────────────────────────────────────────────────────────────────
# Lower, older, and with a covered arcade running the whole length of it. The
# men under it have been coming here for forty years and the alien is going to
# have to work out how to address every single one of them.

# The opening in the arcade the gate stands in.
const GATE_L := 330.0
const GATE_R := 790.0


func _draw_arcade() -> void:
	_draw_gwanghwamun(560.0)
	var body: Color = C_RENDER if GameState.is_morning() \
		else C_RENDER.darkened(0.48)
	# The gate stands in a gap in the arcade. Tiling the whole width
	# buried its podium and its lower roof and left a red eave floating
	# over a row of shop windows.
	for i in range(7):
		var x: float = -20.0 + float(i) * 172.0
		if x + 168.0 > GATE_L and x < GATE_R:
			continue
		draw_rect(Rect2(x, 140.0, 168.0, GROUND_Y - 140.0), body)
		for r in range(int((GROUND_Y - 140.0) / 9.0)):
			draw_rect(Rect2(x, 140.0 + float(r) * 9.0, 168.0, 1.0),
				Color(0, 0, 0, 0.09))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (i * 19) % 16
		CA.window_row(self, x, 168.0, 164.0, 4, 24.0, 22.0, C_GLASS, C_STEEL, lit)
		CA.sign_stack(self, x + 6.0, 200.0, 90.0, 2,
			[C_SIGN_W, C_SIGN_G, C_SIGN_R][i % 3], C_INK, i)
	# The arcade roof: a continuous canopy on posts, which is the whole
	# character of the street. It puts the entire pavement in shade.
	var canopy: Color = Color(0.243, 0.235, 0.212)
	if not GameState.is_morning():
		canopy = canopy.darkened(0.40)
	draw_rect(Rect2(-20.0, GROUND_Y - 6.0, CA.VW + 40.0, 10.0), canopy)
	draw_rect(Rect2(-20.0, GROUND_Y - 6.0, CA.VW + 40.0, 2.0),
		canopy.lightened(0.18))
	for i in range(9):
		var px: float = 40.0 + float(i) * 134.0
		draw_rect(Rect2(px - 4.0, GROUND_Y + 4.0, 8.0, CA.PAVE_TOP - GROUND_Y + 30.0),
			canopy.darkened(0.10))
	draw_rect(Rect2(0, GROUND_Y + 4.0, CA.VW, CA.PAVE_TOP - GROUND_Y + 46.0),
		Color(0, 0, 0, 0.20))


# ── Mangwon ───────────────────────────────────────────────────────────────────
# West, residential, and low. Two-storey brick houses with a rooftop terrace on
# every one, a market lane one street wide, and nobody in a hurry.
#
# This is where somebody drops the honorifics with the alien, so the plate is
# built to let that land: small buildings, hand-painted boards rather than
# backlit ones, and the only district in the city where you see sky between
# the roofs.

const MANGWON_ROW := [
	[-14.0, 126.0, 2], [112.0, 104.0, 3], [216.0, 132.0, 2], [348.0, 110.0, 3],
	[458.0, 128.0, 2], [586.0, 106.0, 3], [692.0, 134.0, 2], [826.0, 112.0, 3],
	[938.0, 130.0, 2], [1068.0, 100.0, 3],
]


func _draw_mangwon() -> void:
	var brick: Color = Color(0.686, 0.514, 0.427)
	var brick_b: Color = Color(0.600, 0.545, 0.494)
	if not GameState.is_morning():
		brick = brick.darkened(0.48)
		brick_b = brick_b.darkened(0.48)
	CA.far_mass(self, 178.0, brick.darkened(0.36),
		Color(0.88, 0.84, 0.76, 0.20), 20, 6)
	for i in range(MANGWON_ROW.size()):
		var spec: Array = MANGWON_ROW[i]
		_draw_villa_row(float(spec[0]), float(spec[1]), int(spec[2]),
			brick if (i % 2) == 0 else brick_b, i)
	# The market awning, in the green-and-white stripe every Korean market uses.
	for i in range(6):
		CA.awning(self, -20.0 + float(i) * 200.0, 206.0, 196.0,
			Color(0.129, 0.412, 0.298), Color(0.906, 0.894, 0.867))


# Two or three storeys of face brick, with a railed roof terrace and the usual
# forest of tanks, aircon and drying frames on top of it.
func _draw_villa_row(x: float, w: float, storeys: int, body: Color,
		seed_i: int) -> void:
	var floor_h: float = 40.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	for r in range(int((GROUND_Y - top) / 6.0)):
		var y: float = top + float(r) * 6.0
		draw_rect(Rect2(x, y, w, 1.0), Color(0, 0, 0, 0.11))
		var off: float = 9.0 if (r % 2) else 0.0
		for c in range(int(w / 18.0) + 1):
			draw_rect(Rect2(x + off + float(c) * 18.0, y, 1.0, 6.0),
				Color(0, 0, 0, 0.09))
	draw_rect(Rect2(x + w - 5.0, top, 5.0, GROUND_Y - top), body.darkened(0.22))
	var rail: Color = C_STEEL if GameState.is_morning() else C_STEEL.darkened(0.40)
	draw_rect(Rect2(x - 3.0, top - 7.0, w + 6.0, 8.0), body.lightened(0.16))
	for i in range(int(w / 12.0)):
		draw_rect(Rect2(x + float(i) * 12.0, top - 20.0, 2.0, 14.0), rail)
	draw_rect(Rect2(x - 3.0, top - 22.0, w + 6.0, 2.4), rail)
	draw_rect(Rect2(x + w * 0.5 - 11.0, top - 38.0, 22.0, 17.0),
		Color(0.278, 0.435, 0.478) if GameState.is_morning()
		else Color(0.278, 0.435, 0.478).darkened(0.46))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var bays: int = maxi(1, int(w / 48.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (seed_i * 27 + s * 11) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 28.0, 24.0, C_GLASS, C_STEEL, lit)
		var step: float = w / float(bays)
		for b in range(bays):
			_draw_aircon(x + step * (float(b) + 0.5) + 16.0, wy + 26.0)
	# Painted straight on the brick, not backlit.
	if (seed_i % 2) == 0:
		var board: Color = [C_SIGN_G, C_SIGN_R, C_SIGN_B][seed_i % 3]
		if not GameState.is_morning():
			board = board.darkened(0.34)
		draw_rect(Rect2(x + 5.0, GROUND_Y - 66.0, w - 10.0, 17.0), board)
		for m in range(int((w - 20.0) / 11.0)):
			draw_rect(Rect2(x + 10.0 + float(m) * 11.0, GROUND_Y - 62.0, 6.0, 9.0),
				C_SIGN_W)


# ── Seongsu ───────────────────────────────────────────────────────────────────
# Red-brick shoe factories from the seventies. Half still make shoes and half
# are cafes now, with the loading doors and the crane beams left exactly where
# they were. Line 2 runs over the top on a viaduct.

func _draw_seongsu() -> void:
	var brick: Color = Color(0.612, 0.373, 0.310)
	var steel: Color = C_STEEL
	if not GameState.is_morning():
		brick = brick.darkened(0.50)
		steel = steel.darkened(0.50)
	CA.far_mass(self, 152.0, brick.darkened(0.40),
		Color(0.86, 0.82, 0.76, 0.22), 24, 9)
	_draw_line2_viaduct(steel)
	for spec in [[-18.0, 214.0, 3], [200.0, 186.0, 4], [392.0, 226.0, 3],
			[624.0, 198.0, 4], [828.0, 240.0, 3]]:
		_draw_factory(float(spec[0]), float(spec[1]), int(spec[2]), brick, steel)


func _draw_factory(x: float, w: float, storeys: int, brick: Color,
		steel: Color) -> void:
	var floor_h: float = 42.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), brick)
	for r in range(int((GROUND_Y - top) / 6.0)):
		draw_rect(Rect2(x, top + float(r) * 6.0, w, 1.0), Color(0, 0, 0, 0.13))
	draw_rect(Rect2(x + w - 7.0, top, 7.0, GROUND_Y - top), brick.darkened(0.24))
	draw_rect(Rect2(x - 4.0, top - 9.0, w + 8.0, 10.0), brick.lightened(0.14))
	# Steel-framed factory glazing: many small panes, and it is the whole look.
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var lit: bool = not GameState.is_morning() and ((int(x) + s * 3) % 2) == 0
		draw_rect(Rect2(x + 10.0, wy, w - 20.0, 26.0),
			Color(0.98, 0.90, 0.70, 0.80) if lit else C_GLASS)
		for c in range(int((w - 20.0) / 13.0) + 1):
			draw_rect(Rect2(x + 10.0 + float(c) * 13.0, wy, 1.8, 26.0), steel)
		draw_rect(Rect2(x + 10.0, wy + 12.0, w - 20.0, 1.8), steel)
		draw_rect(Rect2(x + 8.0, wy - 3.0, w - 16.0, 3.0), steel.darkened(0.20))
	# The loading door, and the crane beam still bolted over it.
	var dx: float = x + w * 0.5
	draw_rect(Rect2(dx - 34.0, GROUND_Y - 58.0, 68.0, 58.0), brick.darkened(0.34))
	draw_rect(Rect2(dx - 30.0, GROUND_Y - 54.0, 60.0, 54.0),
		steel.darkened(0.16) if GameState.is_morning() else Color(0.14, 0.13, 0.13))
	for i in range(7):
		draw_rect(Rect2(dx - 30.0, GROUND_Y - 50.0 + float(i) * 7.0, 60.0, 2.0),
			Color(0, 0, 0, 0.26))
	draw_rect(Rect2(dx - 8.0, GROUND_Y - 78.0, 44.0, 6.0), steel)
	draw_rect(Rect2(dx + 30.0, GROUND_Y - 78.0, 5.0, 14.0), steel.darkened(0.20))


func _draw_line2_viaduct(steel: Color) -> void:
	draw_rect(Rect2(-20.0, 92.0, CA.VW + 40.0, 26.0), steel.darkened(0.24))
	draw_rect(Rect2(-20.0, 92.0, CA.VW + 40.0, 4.0), steel.lightened(0.12))
	draw_rect(Rect2(-20.0, 114.0, CA.VW + 40.0, 6.0), Color(0, 0, 0, 0.32))
	for i in range(5):
		draw_rect(Rect2(60.0 + float(i) * 260.0 - 13.0, 118.0, 26.0, 130.0),
			steel.darkened(0.16))
	var cycle: float = fmod(_t, 26.0) / 26.0
	if cycle > 0.34:
		return
	var tx: float = lerpf(-400.0, CA.VW + 260.0, cycle / 0.34)
	for c in range(3):
		var cx: float = tx + float(c) * 138.0
		draw_rect(Rect2(cx, 54.0, 132.0, 40.0), Color(0.804, 0.816, 0.827))
		draw_rect(Rect2(cx, 70.0, 132.0, 8.0), Color(0.169, 0.545, 0.318))
		for k in range(4):
			draw_rect(Rect2(cx + 14.0 + float(k) * 29.0, 60.0, 21.0, 9.0),
				Color(0.20, 0.23, 0.26) if GameState.is_morning()
				else Color(0.94, 0.93, 0.88, 0.85))


# ── Hongdae ───────────────────────────────────────────────────────────────────
# The art-school streets. Low buildings covered wall to wall in murals, buskers
# with a speaker and a floor mat, and a population almost entirely under thirty
# - which makes it the one district in the country where the alien can get a
# whole sentence out without first working out who outranks whom.
#
# That is not the same as there being no register. It is that everybody here
# has agreed to use the same one, and the alien is finally inside the agreement.

func _draw_hongdae() -> void:
	var body: Color = Color(0.741, 0.729, 0.706)
	if not GameState.is_morning():
		body = body.darkened(0.48)
	CA.far_mass(self, 172.0, body.darkened(0.34),
		Color(0.86, 0.86, 0.84, 0.20), 22, 15)
	for i in range(HONGDAE_ROW.size()):
		var spec: Array = HONGDAE_ROW[i]
		_draw_villa_row(float(spec[0]), float(spec[1]), int(spec[2]), body, i)
		if (i % 2) == 0:
			_draw_mural(float(spec[0]) + 8.0, GROUND_Y - 92.0,
				float(spec[1]) - 16.0, i)


const HONGDAE_ROW := [
	[-14.0, 138.0, 3], [124.0, 112.0, 2], [236.0, 144.0, 3], [380.0, 118.0, 2],
	[498.0, 140.0, 3], [638.0, 116.0, 2], [754.0, 146.0, 3], [900.0, 120.0, 2],
	[1020.0, 148.0, 3],
]


# Painted wall to wall, signed, and repainted often enough that the edges of
# the last one still show through.
func _draw_mural(x: float, y: float, w: float, seed_i: int) -> void:
	var pal := [Color(0.902, 0.325, 0.416), Color(0.180, 0.545, 0.729),
		Color(0.949, 0.769, 0.220), Color(0.196, 0.639, 0.463),
		Color(0.549, 0.322, 0.678)]
	for i in range(6):
		var c: Color = pal[(i + seed_i) % pal.size()]
		if not GameState.is_morning():
			c = c.darkened(0.44)
		var bw: float = w / 6.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x + float(i) * bw, y + 84.0),
			Vector2(x + float(i) * bw + 6.0, y + float((i * 19) % 26)),
			Vector2(x + float(i) * bw + bw - 4.0, y + float((i * 31) % 22)),
			Vector2(x + float(i) * bw + bw - 10.0, y + 84.0),
		]), Color(c.r, c.g, c.b, 0.80))
	draw_rect(Rect2(x + w - 30.0, y + 70.0, 22.0, 4.0), Color(0.10, 0.09, 0.10, 0.66))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave: Color = Color(0.400, 0.396, 0.376)
	var road: Color = Color(0.294, 0.290, 0.286)
	if not GameState.is_morning():
		pave = pave.darkened(0.44)
		road = road.darkened(0.46)
	CA.ground(self, pave, road, pave.darkened(0.08))
	# Interlocking pavers, the small grey rectangular kind laid everywhere in
	# this city, and never quite level after the last time they were lifted.
	CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 26.0, 15.0,
		Color(0, 0, 0, 0.14))
	CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 26.0, 15.0,
		Color(0, 0, 0, 0.14))
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.14))
	# A painted yellow loading line, worn through where the vans stop.
	for i in range(14):
		var x: float = float(i) * 84.0
		var wear: float = 0.55 if (i % 3) else 0.22
		draw_rect(Rect2(x, CA.ROAD_TOP + 9.0, 52.0, 4.0),
			Color(0.85, 0.71, 0.24, wear))
	# The drain cover every workshop street has, and the wet ring round it.
	for x in [268.0, 742.0]:
		draw_rect(Rect2(float(x) - 17.0, 396.0, 34.0, 22.0), road.darkened(0.24))
		for k in range(5):
			draw_rect(Rect2(float(x) - 13.0, 400.0 + float(k) * 4.0, 26.0, 2.0),
				Color(0, 0, 0, 0.34))
	CA.sheen(self, CA.ROAD_TOP, CA.FAR_TOP - CA.ROAD_TOP,
		Color(0.62, 0.68, 0.74), _t)


# ── Furniture ─────────────────────────────────────────────────────────────────
# Everything on this pavement belongs to a workshop and has been put outside
# because there is no room for it inside.

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	if district == "jongno":
		_draw_bench(210.0)
		_draw_bench(690.0)
		CA.bin(self, 470.0, CA.PAVE_TOP + 40.0, Color(0.278, 0.322, 0.290))
		CA.tree(self, 930.0, CA.PAVE_TOP + 36.0, 46.0,
			Color(0.235, 0.196, 0.157), Color(0.263, 0.373, 0.271), 0.9)
		return
	CA.crates(self, 296.0, CA.PAVE_TOP + 40.0, 2, 3, Color(0.196, 0.353, 0.541))
	CA.crates(self, 806.0, CA.PAVE_TOP + 38.0, 2, 2, Color(0.639, 0.235, 0.220))
	_draw_cylinders(468.0)
	_draw_handcart(660.0)
	for x in [116.0, 552.0, 1002.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 44.0, 82.0,
			Color(0.243, 0.243, 0.235), C_WARM, lit)
	# A cat on the crates. Every workshop street on earth has one.


func _draw_bench(x: float) -> void:
	var wood: Color = Color(0.451, 0.353, 0.263)
	if not GameState.is_morning():
		wood = wood.darkened(0.42)
	draw_rect(Rect2(x - 46.0, CA.PAVE_TOP + 22.0, 92.0, 8.0), wood)
	draw_rect(Rect2(x - 46.0, CA.PAVE_TOP + 22.0, 92.0, 2.0), wood.lightened(0.20))
	draw_rect(Rect2(x - 40.0, CA.PAVE_TOP + 30.0, 6.0, 16.0), wood.darkened(0.30))
	draw_rect(Rect2(x + 34.0, CA.PAVE_TOP + 30.0, 6.0, 16.0), wood.darkened(0.30))


# Blue LPG bottles, chained to the wall. Ubiquitous, and the reason half these
# workshops smell the way they do.
func _draw_cylinders(x: float) -> void:
	var blue: Color = Color(0.169, 0.365, 0.549)
	if not GameState.is_morning():
		blue = blue.darkened(0.42)
	for i in range(3):
		var cx: float = x + float(i) * 21.0
		draw_rect(Rect2(cx, CA.PAVE_TOP + 12.0, 17.0, 32.0), blue)
		draw_rect(Rect2(cx, CA.PAVE_TOP + 12.0, 5.0, 32.0), blue.lightened(0.18))
		draw_rect(Rect2(cx + 4.0, CA.PAVE_TOP + 6.0, 9.0, 7.0), blue.darkened(0.30))
	draw_rect(Rect2(x - 3.0, CA.PAVE_TOP + 24.0, 70.0, 2.0), Color(0.35, 0.34, 0.32))


# The flat two-wheeled cart everything in this quarter moves on.
func _draw_handcart(x: float) -> void:
	var steel: Color = C_STEEL if GameState.is_morning() else C_STEEL.darkened(0.40)
	draw_rect(Rect2(x - 34.0, CA.PAVE_TOP + 26.0, 68.0, 7.0), steel)
	draw_rect(Rect2(x - 34.0, CA.PAVE_TOP + 26.0, 68.0, 2.0), steel.lightened(0.20))
	draw_rect(Rect2(x + 30.0, CA.PAVE_TOP - 4.0, 5.0, 32.0), steel)
	draw_rect(Rect2(x + 18.0, CA.PAVE_TOP - 6.0, 18.0, 4.0), steel)
	draw_circle(Vector2(x - 22.0, CA.PAVE_TOP + 38.0), 7.0, Color(0.13, 0.12, 0.12))
	draw_circle(Vector2(x + 20.0, CA.PAVE_TOP + 38.0), 7.0, Color(0.13, 0.12, 0.12))
	CA.crates(self, x - 30.0, CA.PAVE_TOP + 26.0, 2, 1, Color(0.549, 0.482, 0.290))


func solids() -> Array:
	var out: Array = []
	if district == "jongno":
		out.append(Rect2(164.0, CA.PAVE_TOP + 22.0, 92.0, 24.0))     # bench
		out.append(Rect2(644.0, CA.PAVE_TOP + 22.0, 92.0, 24.0))     # bench
		out.append(Rect2(458.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))     # bin
		out.append(Rect2(916.0, CA.PAVE_TOP + 12.0, 28.0, 30.0))     # tree
		# The arcade posts. You walk between them, not through them.
		for i in range(9):
			out.append(Rect2(36.0 + float(i) * 134.0, CA.PAVE_TOP + 4.0, 8.0, 30.0))
		return out
	out.append(Rect2(296.0, CA.PAVE_TOP - 2.0, 68.0, 44.0))          # crates
	out.append(Rect2(806.0, CA.PAVE_TOP + 18.0, 68.0, 24.0))         # crates
	out.append(Rect2(462.0, CA.PAVE_TOP + 12.0, 66.0, 32.0))         # cylinders
	out.append(Rect2(626.0, CA.PAVE_TOP + 26.0, 68.0, 20.0))         # handcart
	return out


# Gwanghwamun, the main gate of the palace at the top of Jongno. Burned in an
# invasion, rebuilt, moved by an occupying government to get it out of the way
# of their own building, bombed, rebuilt again in concrete, and then taken down
# in 2006 and rebuilt a third time in wood on the original alignment - which
# was three degrees off from where the concrete one had been, and they moved it.
func _draw_gwanghwamun(cx: float) -> void:
	var stone: Color = C_RENDER if GameState.is_morning() else C_RENDER.darkened(0.30)
	var beam := Color(0.643, 0.267, 0.212)
	var base: float = 258.0
	# The stone podium, with three arched openings through it.
	draw_rect(Rect2(cx - 190.0, base - 84.0, 380.0, 84.0), stone)
	for i in range(-1, 2):
		var ax: float = cx + float(i) * 108.0
		var w: float = 44.0 if i == 0 else 36.0
		draw_rect(Rect2(ax - w, base - 56.0, w * 2.0, 56.0), stone.darkened(0.52))
		draw_circle(Vector2(ax, base - 56.0), w, stone.darkened(0.52))
	draw_rect(Rect2(cx - 196.0, base - 92.0, 392.0, 10.0), stone.lightened(0.10))
	# The wooden pavilion on top: two roofs, and the eaves turn up.
	_gate_roof(cx, base - 148.0, 206.0, beam)
	draw_rect(Rect2(cx - 168.0, base - 148.0, 336.0, 26.0), beam.darkened(0.20))
	for c in range(11):
		draw_rect(Rect2(cx - 156.0 + float(c) * 30.0, base - 144.0, 12.0, 22.0),
			beam.lightened(0.14))
	_gate_roof(cx, base - 196.0, 178.0, beam)


func _gate_roof(cx: float, y: float, half: float, tile: Color) -> void:
	draw_rect(Rect2(cx - half, y, half * 2.0, 16.0), tile.darkened(0.34))
	draw_rect(Rect2(cx - half, y, half * 2.0, 4.0), tile.darkened(0.16))
	for s in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx + s * half, y + 16.0),
			Vector2(cx + s * (half + 34.0), y - 6.0),
			Vector2(cx + s * (half + 34.0), y + 6.0),
			Vector2(cx + s * half, y + 22.0),
		]), tile.darkened(0.40))
	draw_rect(Rect2(cx - half + 10.0, y - 8.0, half * 2.0 - 20.0, 8.0),
		tile.darkened(0.24))


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	if district == "jongno":
		return []
	return [
		[Vector2(330.0, CA.PAVE_TOP + 4.0), 1, 0],
	]
