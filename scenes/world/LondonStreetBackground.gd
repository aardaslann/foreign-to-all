extends Node2D

# London — drawn, not plated. Berlin ships as pixel plates; London has no art
# handoff, so the whole city is composed here from the palette in
# docs/design/london.md.
#
# The rule that keeps it from looking like recoloured Berlin:
#   Berlin sits BACK from you — wide street, flat frontage, tall windows, sky.
#   London sits ON TOP of you — narrow street, busy roofline, and every house
#   has a hole in front of it.
# Three things carry that read, and none of them exist in Berlin:
#   1. chimney stacks — the identifying silhouette, never level, stepping downhill
#   2. the basement area — railings, a void, steps up to a raised door
#   3. stucco ground floors under brick upper storeys — a horizontal band Berlin
#      does not have
#
# Street bands match Berlin's exactly (pavement 292, road 372, pavement 516) so
# the player, exits, collision and the map all behave identically.

@export var district: String = "terrace"
# "terrace" | "highstreet" | "soho" | "brixton"

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── Palette (docs/design/london.md) ───────────────────────────────────────────
const C_LID        := Color(0.106, 0.118, 0.149)   # overcast lid
const C_CLOUD      := Color(0.173, 0.192, 0.235)   # cloud belly
const C_HAZE       := Color(0.239, 0.227, 0.204)   # sodium haze
const C_BRICK      := Color(0.361, 0.318, 0.251)   # London yellow stock, sooted
const C_BRICK_DK   := Color(0.275, 0.239, 0.192)   # soot under sills
const C_BRICK_LIT  := Color(0.431, 0.373, 0.286)   # where light lands
const C_BRICK_RED  := Color(0.427, 0.192, 0.157)   # flat arches, stacks
const C_STUCCO     := Color(0.769, 0.741, 0.675)   # rendered ground floors
const C_SLATE      := Color(0.180, 0.192, 0.220)   # roof, wet horizontals
const C_SASH       := Color(0.910, 0.886, 0.831)   # window frames — bright line
const C_GLASS      := Color(0.102, 0.114, 0.141)   # unlit glass
const C_GLASS_LIT  := Color(0.941, 0.843, 0.604)   # lit — milkier than Berlin
const C_TARMAC     := Color(0.200, 0.208, 0.235)   # cooler, bluer, always damp
const C_YORK       := Color(0.294, 0.290, 0.275)   # pavement slabs
const C_KERB       := Color(0.416, 0.400, 0.376)   # higher lip than Berlin's
const C_BARK       := Color(0.561, 0.541, 0.463)   # plane bark flake
const C_IRON       := Color(0.055, 0.058, 0.070)   # railings, lamp columns

# Statutory accents — used sparingly, never two in the same glance
const C_TFL_RED    := Color(0.882, 0.145, 0.106)
const C_TFL_BLUE   := Color(0.000, 0.098, 0.659)
const C_POST_RED   := Color(0.635, 0.231, 0.235)   # deeper, browner than TfL
const C_DBL_YELLOW := Color(0.847, 0.722, 0.000)

# Ground bands, shared with Berlin so collision and exits stay true
const PAVE_TOP  := 292.0
const ROAD_TOP  := 372.0
const PAVE_BOT  := 516.0

# Terrace units: [x, width, storeys, roof_step] — heights never level, the
# terrace walks downhill the way a real one does
# The opening in the terrace the Elizabeth Tower stands at the end of.
const BEN_L := 846.0
const BEN_R := 1006.0

const _TERRACE := [
	[-40, 190, 3, 0], [150, 172, 3, 8], [322, 166, 2, 14],
	[488, 180, 3, 6], [668, 174, 3, 18], [842, 168, 2, 24],
	[1010, 182, 3, 12],
]

# The high street's shops. Fascia lettering is the one thing the alien CAN read
# here — and reading it is no help at all, which is London's whole lesson.
const SHOP_NAMES := ["LAUNDERETTE", "NEWSAGENT", "CHEMIST", "CAFE", "OFF LICENCE"]
const SHOP_HUES := [
	Color(0.106, 0.243, 0.180), Color(0.243, 0.114, 0.129),
	Color(0.114, 0.157, 0.290), Color(0.290, 0.208, 0.098),
	Color(0.161, 0.129, 0.239),
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
	_draw_district()
	_draw_ground()
	_draw_doors(PAVE_TOP - 74.0, PAVE_TOP, C_STUCCO, C_IRON, C_BRICK_RED, C_GLASS)
	_draw_street_furniture()



# ── The districts ─────────────────────────────────────────────────────────────
# The `district` export was declared and never read, so Bethnal Green and Roman
# Road rendered as the same street. They are not the same street. The terrace
# bones are shared - this is one city and it was built by the same speculators
# in the same forty years - but what happens at ground level is the difference.

func _draw_district() -> void:
	# The tower goes in before the terrace, so the terrace stands in front
	# of it and only the spire and the dial clear the chimney line - which
	# is how you see it from anywhere in this city that is not the bridge.
	#
	# It sits in the West End, not on a high street. From the bottom of
	# Soho you are looking down Whitehall at it from about half a mile;
	# from a residential high street you are looking at a residential high
	# street. It was in the wrong district and the wrong size for one.
	if district == "soho":
		_draw_big_ben(884.0)
	_draw_terrace()
	match district:
		"highstreet": _draw_shopfronts()
		"soho":       _draw_soho()
		"brixton":    _draw_brixton()
		_:            pass


# Roman Road. The same terrace with its ground floor knocked out for shops, a
# continuous fascia across the lot, and stalls down the kerb. This is exactly
# how a London high street happens and it is why the upper floors still look
# residential.
func _draw_shopfronts() -> void:
	var board: Color = C_STUCCO.darkened(0.34)
	var ink: Color = C_SASH
	if not GameState.is_morning():
		board = board.darkened(0.30)
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		# The fascia, unbroken, and a different colour on every unit because
		# every unit was painted by a different tenant.
		var tint: Color = board
		if (i % 3) == 1:
			tint = Color(0.243, 0.322, 0.278)
		elif (i % 3) == 2:
			tint = Color(0.396, 0.220, 0.208)
		if not GameState.is_morning():
			tint = tint.darkened(0.28)
		draw_rect(Rect2(x + 4.0, PAVE_TOP - 96.0, w - 8.0, 22.0), tint)
		draw_rect(Rect2(x + 4.0, PAVE_TOP - 96.0, w - 8.0, 2.0), tint.lightened(0.22))
		for m in range(int((w - 24.0) / 12.0)):
			draw_rect(Rect2(x + 12.0 + float(m) * 12.0, PAVE_TOP - 91.0, 7.0, 12.0),
				ink)
		# The glazing, and the roller shutter box over it.
		draw_rect(Rect2(x + 8.0, PAVE_TOP - 74.0, w - 16.0, 60.0),
			C_GLASS if GameState.is_morning()
			else Color(0.941, 0.843, 0.604, 0.72))
		draw_rect(Rect2(x + 6.0, PAVE_TOP - 78.0, w - 12.0, 8.0), C_IRON)
	# Market stalls down the kerb, with a striped tarpaulin over each.
	for i in range(4):
		var sx: float = 120.0 + float(i) * 230.0
		draw_rect(Rect2(sx - 66.0, PAVE_TOP - 48.0, 132.0, 12.0),
			Color(0.694, 0.239, 0.204) if GameState.is_morning()
			else Color(0.694, 0.239, 0.204).darkened(0.42))
		draw_rect(Rect2(sx - 62.0, PAVE_TOP - 8.0, 124.0, 8.0), C_IRON.lightened(0.20))
		for k in range(4):
			draw_rect(Rect2(sx - 56.0 + float(k) * 34.0, PAVE_TOP - 34.0, 26.0, 26.0),
				Color(0.55, 0.47, 0.35) if GameState.is_morning()
				else Color(0.55, 0.47, 0.35).darkened(0.40))


# Soho. Narrower, taller, painted rather than bare brick, and every frontage
# carrying a projecting blade sign. It is the one part of central London that
# is still vertical rather than horizontal.
func _draw_soho() -> void:
	var pal := [Color(0.702, 0.612, 0.529), Color(0.494, 0.396, 0.376),
		Color(0.400, 0.427, 0.443), Color(0.612, 0.514, 0.443)]
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		var c: Color = pal[i % pal.size()]
		if not GameState.is_morning():
			c = c.darkened(0.46)
		# Painted render over the brick, from first floor up.
		draw_rect(Rect2(x + 3.0, 116.0, w - 6.0, PAVE_TOP - 190.0), c)
		# The blade sign, at right angles to the wall, lit at night.
		if (i % 2) == 0:
			var bx: float = x + w - 16.0
			var neon: Color = [C_TFL_RED, Color(0.20, 0.72, 0.62),
				Color(0.95, 0.78, 0.22)][i % 3]
			var on: bool = not GameState.is_morning()
			draw_rect(Rect2(bx, 150.0, 14.0, 76.0),
				neon.darkened(0.30) if on else C_IRON)
			for m in range(4):
				draw_rect(Rect2(bx + 3.0, 156.0 + float(m) * 18.0, 8.0, 11.0),
					Color(neon.r, neon.g, neon.b, 0.95) if on else C_SASH)
			if on:
				for k in range(3):
					draw_rect(Rect2(bx - 8.0 - float(k) * 6.0, 144.0 - float(k) * 6.0,
						30.0 + float(k) * 12.0, 90.0 + float(k) * 12.0),
						Color(neon.r, neon.g, neon.b, 0.026))
		# A fire escape, zigzagged down the front, on a couple of them.
		if (i % 3) == 0:
			for s in range(3):
				var fy: float = 150.0 + float(s) * 30.0
				draw_rect(Rect2(x + 8.0, fy, w - 30.0, 3.0), C_IRON.lightened(0.18))
				draw_rect(Rect2(x + 8.0, fy, 2.4, 30.0), C_IRON.lightened(0.18))
				draw_rect(Rect2(x + w - 24.0, fy, 2.4, 30.0), C_IRON.lightened(0.18))


# Brixton. The railway bridge across the top, the covered market arcade under
# it, and Electric Avenue - the first market street in Britain to be lit by
# electric light, which is a fact the street has never stopped being about.
func _draw_brixton() -> void:
	var brick: Color = C_BRICK_RED
	if not GameState.is_morning():
		brick = brick.darkened(0.46)
	# The rail bridge, with the arches occupied.
	draw_rect(Rect2(-20.0, 128.0, VW + 40.0, 34.0), brick.darkened(0.20))
	draw_rect(Rect2(-20.0, 128.0, VW + 40.0, 5.0), brick.lightened(0.16))
	draw_rect(Rect2(-20.0, 156.0, VW + 40.0, 7.0), Color(0, 0, 0, 0.34))
	for i in range(5):
		var ax: float = -30.0 + float(i) * 246.0
		draw_rect(Rect2(ax, 162.0, 214.0, PAVE_TOP - 236.0), brick)
		var ox: float = ax + 36.0
		draw_rect(Rect2(ox, 200.0, 142.0, PAVE_TOP - 274.0),
			Color(0.086, 0.078, 0.082))
		for k in range(11):
			var u: float = float(k) / 10.0
			var dy: float = sin(u * PI) * 24.0
			draw_rect(Rect2(ox + u * 142.0 - 7.0, 200.0 - dy, 15.0, dy + 4.0),
				Color(0.086, 0.078, 0.082))
	# The arcade canopy over the pavement, and the strings of bulbs under it.
	var canopy: Color = Color(0.216, 0.239, 0.259)
	if not GameState.is_morning():
		canopy = canopy.darkened(0.36)
	draw_rect(Rect2(-20.0, PAVE_TOP - 82.0, VW + 40.0, 10.0), canopy)
	for i in range(9):
		draw_rect(Rect2(30.0 + float(i) * 134.0, PAVE_TOP - 72.0, 7.0, 72.0),
			canopy.lightened(0.10))
	if not GameState.is_morning():
		for i in range(26):
			var bx: float = 24.0 + float(i) * 44.0
			draw_circle(Vector2(bx, PAVE_TOP - 66.0 + sin(float(i) * 0.9) * 4.0),
				3.4, Color(1.0, 0.90, 0.70, 0.92))
			draw_circle(Vector2(bx, PAVE_TOP - 66.0 + sin(float(i) * 0.9) * 4.0),
				11.0, Color(1.0, 0.88, 0.66, 0.05))
	# Produce crates, out to the kerb, stacked three high.
	for i in range(6):
		var cx: float = 60.0 + float(i) * 180.0
		for r in range(3):
			draw_rect(Rect2(cx, PAVE_TOP - 14.0 - float(r) * 15.0, 62.0, 14.0),
				Color(0.545, 0.463, 0.322) if GameState.is_morning()
				else Color(0.545, 0.463, 0.322).darkened(0.42))
			draw_rect(Rect2(cx + 4.0, PAVE_TOP - 18.0 - float(r) * 15.0, 54.0, 5.0),
				[Color(0.86, 0.62, 0.16), Color(0.71, 0.24, 0.22),
				 Color(0.28, 0.51, 0.29)][(i + r) % 3])


# ── Sky ───────────────────────────────────────────────────────────────────────
# There is no blue. The lid is the point: London's sky is a ceiling, and at
# night the sodium bounces back off the underside of it.

# Street furniture you cannot walk through. The railings run the whole terrace
# frontage, which is what stops you strolling through the basement areas.
func solids() -> Array:
	var out: Array = []
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		out.append(Rect2(x + 10.0, PAVE_TOP - 30.0, w - 20.0, 36.0))
	out.append(Rect2(197.0, PAVE_TOP - 60.0, 30.0, 96.0))    # pillar box
	out.append(Rect2(552.0, PAVE_TOP - 40.0, 16.0, 76.0))    # lamp column
	out.append(Rect2(866.0, PAVE_TOP - 40.0, 28.0, 76.0))    # plane tree
	out.append(Rect2(687.0, PAVE_TOP - 40.0, 26.0, 74.0))    # bin
	return out


func _draw_sky() -> void:
	var morning: bool = GameState.is_morning()
	if morning:
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.435, 0.463, 0.494))
		draw_rect(Rect2(0, 150, VW, 142), Color(0.541, 0.549, 0.553))
		draw_rect(Rect2(0, 236, VW, 56), Color(0.647, 0.631, 0.596))
	else:
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), C_LID)
		draw_rect(Rect2(0, 96, VW, 130), C_CLOUD)
		draw_rect(Rect2(0, 200, VW, 92), C_HAZE)


# ── The terrace ───────────────────────────────────────────────────────────────

func _draw_terrace() -> void:
	# One dome or one clock tower, never both: the West End looks down
	# Whitehall, everywhere else looks east at the cathedral.
	var ben: bool = district == "soho"
	if not ben:
		_draw_st_pauls(830.0)
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		var storeys: int = int(unit[2])
		var step: float = float(unit[3])
		# The terrace opens for the street the tower stands at the end
		# of. Solid, it left a lit clock face floating in a wall.
		if ben and x + w > BEN_L and x < BEN_R:
			continue
		_draw_house(x, w, storeys, step, i)
	# Chimney stacks last so they sit above every roofline
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		var step: float = float(unit[3])
		if ben and x + w > BEN_L and x < BEN_R:
			continue
		var roof_y: float = 96.0 + step
		_draw_stack(x + w, roof_y, 4 + (i % 4))


func _draw_house(x: float, w: float, storeys: int, step: float, seed_i: int) -> void:
	var roof_y: float = 96.0 + step
	var ground_y: float = PAVE_TOP - 74.0

	# Slate roof — shallow, and wet
	draw_rect(Rect2(x, roof_y - 16.0, w, 18.0), C_SLATE)
	draw_rect(Rect2(x, roof_y - 16.0, w, 3.0), C_SLATE.lightened(0.18))

	# Brick body
	draw_rect(Rect2(x, roof_y, w, ground_y - roof_y), C_BRICK)
	draw_rect(Rect2(x, roof_y, 6.0, ground_y - roof_y), C_BRICK_DK)
	draw_rect(Rect2(x + w - 6.0, roof_y, 6.0, ground_y - roof_y), C_BRICK_DK)
	# Cornice under the gutter
	draw_rect(Rect2(x, roof_y + 2.0, w, 5.0), C_STUCCO.darkened(0.35))

	# Sash windows, two per storey, soot smudged beneath each sill
	var rows: int = maxi(storeys, 1)
	for r in range(rows):
		var wy: float = roof_y + 26.0 + float(r) * ((ground_y - roof_y - 34.0) / float(rows))
		for c in range(2):
			var wx: float = x + 26.0 + float(c) * (w - 76.0)
			_draw_sash(wx, wy, 44.0, 52.0, seed_i * 7 + r * 3 + c)

	# Stucco ground floor — the horizontal band Berlin does not have
	draw_rect(Rect2(x, ground_y, w, PAVE_TOP - ground_y), C_STUCCO)
	draw_rect(Rect2(x, ground_y, w, 4.0), C_STUCCO.darkened(0.28))
	for g in range(3):
		var gy: float = ground_y + 16.0 + float(g) * 18.0
		draw_rect(Rect2(x, gy, w, 2.0), C_STUCCO.darkened(0.16))

	# Raised front door, reached by steps
	var dx: float = x + w * 0.5 - 18.0
	draw_rect(Rect2(dx, ground_y + 14.0, 36.0, PAVE_TOP - ground_y - 14.0),
		C_BRICK_RED.darkened(0.35))
	draw_rect(Rect2(dx + 4.0, ground_y + 18.0, 28.0, 14.0), C_GLASS_LIT)  # fanlight


func _draw_sash(x: float, y: float, w: float, h: float, seed_i: int) -> void:
	# Flat brick arch over the opening
	draw_rect(Rect2(x - 3.0, y - 7.0, w + 6.0, 7.0), C_BRICK_RED)
	# Reveal
	draw_rect(Rect2(x, y, w, h), C_SASH)
	var lit: bool = ((seed_i * 37) % 5) < 2
	var pane: Color = C_GLASS_LIT if lit else C_GLASS
	if lit:
		pane = Color(pane.r, pane.g, pane.b, 0.86)
	draw_rect(Rect2(x + 4.0, y + 4.0, w - 8.0, h - 8.0), pane)
	# The horns — the horizontal that says "sash" and not "casement"
	draw_rect(Rect2(x + 4.0, y + h * 0.5 - 2.0, w - 8.0, 4.0), C_SASH)
	draw_rect(Rect2(x + w * 0.5 - 1.5, y + 4.0, 3.0, h - 8.0), C_SASH)
	# Stone sill, and the soot it sheds
	draw_rect(Rect2(x - 5.0, y + h, w + 10.0, 5.0), C_STUCCO.darkened(0.12))
	draw_rect(Rect2(x - 3.0, y + h + 5.0, w + 6.0, 6.0), Color(0, 0, 0, 0.16))


# Chimney stacks — clusters of pots on the party wall, never level.
# If the player squints at a black cut-out of this skyline they should know
# which city it is.
func _draw_stack(x: float, roof_y: float, pots: int) -> void:
	var sw: float = 30.0
	var sh: float = 46.0
	var sx: float = x - sw * 0.5
	var sy: float = roof_y - 16.0 - sh
	draw_rect(Rect2(sx, sy, sw, sh + 18.0), C_BRICK)
	draw_rect(Rect2(sx, sy, sw, 5.0), C_BRICK_LIT)
	draw_rect(Rect2(sx, sy + sh - 10.0, sw, 4.0), C_BRICK_RED)
	for p in range(pots):
		var px: float = sx + 4.0 + float(p) * ((sw - 8.0) / float(maxi(pots, 1)))
		var ph: float = 12.0 + float((p * 5) % 3) * 4.0
		draw_rect(Rect2(px, sy - ph, 5.0, ph), C_BRICK_RED.darkened(0.15))
		draw_rect(Rect2(px, sy - ph, 5.0, 2.0), C_BRICK_RED.lightened(0.25))


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	# York stone pavement — slabs, not Berlin's continuous grey
	draw_rect(Rect2(0, PAVE_TOP, VW, ROAD_TOP - PAVE_TOP), C_YORK)
	_draw_slabs(PAVE_TOP, ROAD_TOP - PAVE_TOP)

	# Granite kerb — a higher lip than Berlin's, so it reads as a step
	draw_rect(Rect2(0, ROAD_TOP - 10.0, VW, 10.0), C_KERB)
	draw_rect(Rect2(0, ROAD_TOP - 10.0, VW, 2.0), C_KERB.lightened(0.22))

	# Tarmac, always faintly wet
	draw_rect(Rect2(0, ROAD_TOP, VW, PAVE_BOT - ROAD_TOP), C_TARMAC)
	draw_rect(Rect2(0, ROAD_TOP + 2.0, VW, 3.0), C_TARMAC.lightened(0.10))
	# Double yellows against the kerb — the dirtier cousin of Circle line yellow
	draw_rect(Rect2(0, ROAD_TOP + 6.0, VW, 3.0), C_DBL_YELLOW.darkened(0.15))
	draw_rect(Rect2(0, ROAD_TOP + 12.0, VW, 3.0), C_DBL_YELLOW.darkened(0.15))
	_draw_wet_sheen()

	# Far pavement
	draw_rect(Rect2(0, PAVE_BOT, VW, VH - PAVE_BOT), C_YORK.darkened(0.10))
	draw_rect(Rect2(0, PAVE_BOT, VW, 8.0), C_KERB.darkened(0.10))
	_draw_slabs(PAVE_BOT + 8.0, VH - PAVE_BOT - 8.0)


func _draw_slabs(top: float, height: float) -> void:
	var line: Color = Color(0, 0, 0, 0.13)
	var rows: int = int(height / 34.0) + 1
	for r in range(rows):
		var y: float = top + float(r) * 34.0
		draw_rect(Rect2(0, y, VW, 1.0), line)
		var offset: float = 0.0 if r % 2 == 0 else 32.0
		var cols: int = int(VW / 64.0) + 1
		for c in range(cols):
			draw_rect(Rect2(offset + float(c) * 64.0, y, 1.0, 34.0), line)


# The road is never dry. A slow sheen sells damp better than any texture.
func _draw_wet_sheen() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_t * 0.5)
	for i in range(5):
		var x: float = 90.0 + float(i) * 240.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, ROAD_TOP + 20.0), Vector2(x + 54.0, ROAD_TOP + 20.0),
			Vector2(x - 26.0, PAVE_BOT), Vector2(x - 80.0, PAVE_BOT),
		]), Color(0.72, 0.76, 0.85, 0.035 + 0.02 * pulse))


# ── Street furniture ──────────────────────────────────────────────────────────
# The basement areas and railings run the length of the pavement. This is the
# single most London thing on the plate after the chimneys.

func _draw_street_furniture() -> void:
	_draw_areas_and_railings()
	_draw_pillar_box(212.0)
	_draw_lamp_column(560.0)
	_draw_plane_tree(348.0)
	_draw_bin(700.0)


func _draw_areas_and_railings() -> void:
	for i in range(_TERRACE.size()):
		var unit: Array = _TERRACE[i]
		var x: float = float(unit[0])
		var w: float = float(unit[1])
		# The void in front of the house
		draw_rect(Rect2(x + 10.0, PAVE_TOP + 6.0, w - 20.0, 26.0), Color(0.031, 0.035, 0.043))
		draw_rect(Rect2(x + 10.0, PAVE_TOP + 6.0, w - 20.0, 3.0), C_YORK.darkened(0.30))
		# Cast-iron railings above it
		var bars: int = int((w - 20.0) / 14.0)
		for b in range(bars):
			var bx: float = x + 14.0 + float(b) * 14.0
			draw_rect(Rect2(bx, PAVE_TOP - 26.0, 2.5, 32.0), C_IRON)
		draw_rect(Rect2(x + 10.0, PAVE_TOP - 28.0, w - 20.0, 4.0), C_IRON)
		# Steps up to the raised door
		var dx: float = x + w * 0.5 - 20.0
		draw_rect(Rect2(dx, PAVE_TOP - 22.0, 40.0, 28.0), C_STUCCO.darkened(0.22))
		draw_rect(Rect2(dx, PAVE_TOP - 14.0, 40.0, 2.0), C_STUCCO.darkened(0.40))


# Post Office red, not TfL red — deeper and browner, and that difference is a
# real London colour event when they stand near each other.
func _draw_pillar_box(x: float) -> void:
	draw_rect(Rect2(x - 15.0, PAVE_TOP - 62.0, 30.0, 62.0), C_POST_RED)
	draw_rect(Rect2(x - 15.0, PAVE_TOP - 62.0, 30.0, 6.0), C_POST_RED.lightened(0.18))
	draw_circle(Vector2(x, PAVE_TOP - 68.0), 15.0, C_POST_RED.darkened(0.10))
	draw_rect(Rect2(x - 9.0, PAVE_TOP - 46.0, 18.0, 4.0), Color(0.02, 0.02, 0.02))
	draw_rect(Rect2(x - 15.0, PAVE_TOP - 2.0, 30.0, 3.0), Color(0, 0, 0, 0.35))


func _draw_lamp_column(x: float) -> void:
	draw_rect(Rect2(x - 3.0, PAVE_TOP - 150.0, 6.0, 150.0), C_IRON)
	draw_rect(Rect2(x - 8.0, PAVE_TOP - 8.0, 16.0, 8.0), C_IRON)
	draw_rect(Rect2(x - 16.0, PAVE_TOP - 162.0, 32.0, 14.0), C_IRON.lightened(0.10))
	if not GameState.is_morning():
		var glow: float = 0.72 + 0.06 * sin(_t * 1.1)
		draw_circle(Vector2(x, PAVE_TOP - 150.0), 46.0,
			Color(0.98, 0.78, 0.42, 0.055 * glow))
		draw_rect(Rect2(x - 13.0, PAVE_TOP - 158.0, 26.0, 8.0),
			Color(0.99, 0.86, 0.58, glow))


# Plane trees flake — that camouflage bark is why they survive the air here
func _draw_plane_tree(x: float) -> void:
	draw_rect(Rect2(x - 9.0, PAVE_TOP - 130.0, 18.0, 130.0), C_BARK.darkened(0.35))
	for f in range(7):
		var fy: float = PAVE_TOP - 122.0 + float(f) * 17.0
		var fx: float = x - 9.0 + float((f * 5) % 3) * 5.0
		draw_rect(Rect2(fx, fy, 9.0, 11.0), C_BARK)
	var canopy: Color = Color(0.294, 0.361, 0.259)
	if not GameState.is_morning():
		canopy = Color(0.196, 0.239, 0.180)
	draw_circle(Vector2(x, PAVE_TOP - 158.0), 54.0, canopy)
	draw_circle(Vector2(x - 34.0, PAVE_TOP - 138.0), 34.0, canopy)
	draw_circle(Vector2(x + 32.0, PAVE_TOP - 142.0), 36.0, canopy)


func _draw_bin(x: float) -> void:
	draw_rect(Rect2(x - 13.0, PAVE_TOP - 40.0, 26.0, 40.0), C_IRON.lightened(0.12))
	draw_rect(Rect2(x - 15.0, PAVE_TOP - 44.0, 30.0, 5.0), C_IRON)


# ── High street variant ───────────────────────────────────────────────────────
# The second plate: same terrace above, shopfront fascias below. A London high
# street is the ground floor of a residential terrace with its face replaced.


# St Paul's, a long way off and small, seen down the gap between two terraces.
#
# You can see it from here because it is illegal to build anything that would
# stop you. There are thirteen protected sightlines across this city, some of
# them from ten miles out, and whole developments have been redesigned to stay
# out of them. The dome is the only thing in London with that kind of law
# around it, and from a terrace in the east it is about eleven pixels tall.
func _draw_st_pauls(cx: float) -> void:
	var pale: Color = Color(0.639, 0.647, 0.678) if GameState.is_morning() else Color(0.376, 0.384, 0.435)
	# It sat at 176 with the drum starting below the chimney line, so the
	# most familiar dome in the country was entirely behind a terrace.
	# Wren's whole argument was that it should be visible from a long way
	# off, and there are laws about it.
	var y: float = 92.0
	draw_rect(Rect2(cx - 44.0, y - 4.0, 88.0, 34.0), pale)
	draw_circle(Vector2(cx, y - 4.0), 34.0, pale)
	# The lit western face of the dome, which is how it reads as a sphere.
	draw_circle(Vector2(cx - 9.0, y - 9.0), 24.0, pale.lightened(0.10))
	draw_rect(Rect2(cx - 34.0, y - 14.0, 68.0, 12.0), pale.darkened(0.10))
	# The stone lantern, the golden gallery under it and the cross on top.
	draw_rect(Rect2(cx - 9.0, y - 58.0, 18.0, 22.0), pale)
	draw_circle(Vector2(cx, y - 58.0), 10.0, pale)
	draw_rect(Rect2(cx - 12.0, y - 38.0, 24.0, 5.0), pale.lightened(0.14))
	draw_rect(Rect2(cx - 2.0, y - 80.0, 4.0, 22.0), pale)
	draw_rect(Rect2(cx - 7.0, y - 74.0, 14.0, 4.0), pale)
	# The two western towers, one either side of the drum.
	for s in [-1.0, 1.0]:
		draw_rect(Rect2(cx + s * 60.0 - 10.0, y + 6.0, 20.0, 42.0),
			pale.darkened(0.06))
		draw_rect(Rect2(cx + s * 60.0 - 13.0, y - 2.0, 26.0, 9.0), pale)
		draw_rect(Rect2(cx + s * 60.0 - 6.0, y - 16.0, 12.0, 15.0),
			pale.darkened(0.04))


# ── The Elizabeth Tower ──────────────────────────────────────────────────────
# Ninety-six metres of Gothic Revival with a clock on it, and the name people
# use is not the tower's - Big Ben is the hour bell hanging inside it, thirteen
# and a half tons of it, cast twice because the first one cracked. The second
# one cracked too. It has been rung with a lighter hammer ever since and the
# note everybody knows is the sound of a broken bell.
#
# The clock faces are seven metres across, lit from behind, and the light is
# on whenever the House is sitting, which is the only reason anybody ever
# looks up at it after dark.
func _draw_big_ben(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	# Anston limestone: a warm sand colour that goes grey with soot and has
	# been cleaned twice in a hundred and fifty years.
	var stone: Color = Color(0.706, 0.643, 0.510)
	# The gilding on the clock frame and the string courses. Regilded in
	# 2020 for the first time since 1985.
	var trim := Color(0.780, 0.643, 0.361)
	if not morning:
		# Floodlit, and the dials are lit from behind. It is the brightest
		# thing on the skyline, not the darkest.
		stone = stone.darkened(0.10)
		trim = trim.lightened(0.08)
	var base: float = 292.0
	var clock_y: float = 44.0

	# Footing to finial the tower is 430 pixels and the plate is 292 down
	# to the pavement, so at its authored size the spire, the lantern and
	# the whole belfry were above the top of the frame and all that was
	# left was a lit dial in a wall.
	const S := 0.62
	draw_set_transform(Vector2(cx - S * cx, base - S * base), 0.0,
		Vector2(S, S))

	# The shaft, in four stages with a string course between each.
	draw_rect(Rect2(cx - 40.0, clock_y - 6.0, 80.0, base - clock_y + 6.0), stone)
	draw_rect(Rect2(cx - 40.0, clock_y - 6.0, 26.0, base - clock_y + 6.0),
		stone.lightened(0.07))
	for st in range(4):
		var sy: float = clock_y + 34.0 + float(st) * 46.0
		if sy > base - 20.0:
			break
		draw_rect(Rect2(cx - 44.0, sy, 88.0, 6.0), trim)
		# Two lancet windows per stage, with the hood mould over them.
		for s2 in [-1.0, 1.0]:
			draw_rect(Rect2(cx + s2 * 17.0 - 7.0, sy + 14.0, 14.0, 22.0),
				stone.darkened(0.46))
			draw_circle(Vector2(cx + s2 * 17.0, sy + 14.0), 7.0,
				stone.darkened(0.46))
	# The buttresses at the corners, which is what makes it read as Gothic.
	for s3 in [-1.0, 1.0]:
		draw_rect(Rect2(cx + s3 * 44.0 - 6.0, clock_y + 10.0, 12.0,
			base - clock_y - 10.0), stone.darkened(0.10))

	# The clock stage: a stone frame, a face, hands, and the gallery over it.
	draw_rect(Rect2(cx - 50.0, clock_y - 38.0, 100.0, 82.0), stone.lightened(0.04))
	draw_rect(Rect2(cx - 50.0, clock_y + 40.0, 100.0, 8.0), trim)
	var face: Color = Color(0.918, 0.890, 0.812)
	draw_circle(Vector2(cx, clock_y + 2.0), 33.0, trim)
	draw_circle(Vector2(cx, clock_y + 2.0), 29.0, face)
	for h in range(12):
		var a: float = TAU * float(h) / 12.0
		draw_line(Vector2(cx + sin(a) * 24.0, clock_y + 2.0 - cos(a) * 24.0),
			Vector2(cx + sin(a) * 28.0, clock_y + 2.0 - cos(a) * 28.0),
			trim.darkened(0.20), 1.6)
	draw_line(Vector2(cx, clock_y + 2.0), Vector2(cx + 9.0, clock_y - 8.0),
		trim.darkened(0.40), 2.4)
	draw_line(Vector2(cx, clock_y + 2.0), Vector2(cx - 3.0, clock_y - 18.0),
		trim.darkened(0.40), 1.8)

	# The belfry above, open, with the louvres the bell sounds through.
	draw_rect(Rect2(cx - 38.0, clock_y - 78.0, 76.0, 46.0), stone.darkened(0.06))
	for l in range(5):
		draw_rect(Rect2(cx - 30.0 + float(l) * 15.0, clock_y - 70.0, 9.0, 32.0),
			stone.darkened(0.50))
	draw_rect(Rect2(cx - 42.0, clock_y - 84.0, 84.0, 7.0), trim)
	# The spire, and the lantern on top that is lit when the House is sitting.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 34.0, clock_y - 84.0), Vector2(cx + 34.0, clock_y - 84.0),
		Vector2(cx, clock_y - 168.0),
	]), stone.darkened(0.16))
	for s4 in [-1.0, 1.0]:
		draw_rect(Rect2(cx + s4 * 30.0 - 4.0, clock_y - 104.0, 8.0, 22.0),
			stone.darkened(0.10))
	draw_rect(Rect2(cx - 4.0, clock_y - 182.0, 8.0, 16.0), trim)
	if not morning:
		# The faces are lit from behind, always. The lantern is lit only when
		# they are sitting, which most nights they are not.
		draw_circle(Vector2(cx, clock_y + 2.0), 29.0, Color(1.0, 0.93, 0.74, 0.58))
		draw_circle(Vector2(cx, clock_y + 2.0), 52.0, Color(1.0, 0.90, 0.68, 0.06))
		draw_circle(Vector2(cx, clock_y - 176.0), 5.0,
			Color(1.0, 0.86, 0.52, 0.35 + 0.25 * sin(_t * 0.7)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
