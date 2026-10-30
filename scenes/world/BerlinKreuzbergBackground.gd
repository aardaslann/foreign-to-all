extends Node2D

# Kreuzberg. Berlin, and the one street in the game that is two cities standing
# in the same place without either of them having agreed to it.
#
# Mitte sits BACK from you — wide, flat, a lot of sky.
# London sits ON TOP of you. Istanbul sits above and below.
# Kreuzberg is LOUD. Every surface is being used by somebody for something, and
# the thing that carries it is not architecture, it is lettering: MANAV and
# SPÄTI on the same wall, in the same plastic, at the same height, neither one
# translated for the other. A player arriving from Istanbul will read the
# Turkish first and be wrong about which country they are in. That mistake is
# the whole reason this street exists.
#
# Three things no other Berlin street here has:
#   1. Altbau standing directly against a 1970s panel slab, tops nowhere near
#      level, nobody ever having tried to make the two agree
#   2. graffiti as the wall's actual surface — throw-ups first, tags over them,
#      stickers over those, and none of it ever removed
#   3. the Landwehrkanal along the near side, a dirt towpath, and a brick bridge
#
# Berlin's palette holds everywhere except the greengrocer's awning and the
# bakery board. The warm saturation is allowed in exactly where it would really
# arrive — on fruit, on a striped canopy, on a spit turning in a window.
#
# Ground bands match Mitte, London and Istanbul exactly so the player, the
# exits and the collision boxes behave identically. The canal takes the far
# pavement's place and is fenced, because water you can walk into is a bug.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── Palette ───────────────────────────────────────────────────────────────────
const C_ALTBAU    := Color(0.435, 0.412, 0.361)   # altbau stucco, soot in the mouldings
const C_ALTBAU_2  := Color(0.392, 0.408, 0.376)   # the green-grey one, every third block
const C_ALTBAU_LT := Color(0.545, 0.514, 0.451)   # cornice, sills, string course
const C_ALTBAU_DK := Color(0.310, 0.294, 0.263)   # the shaded return of every block
const C_ZINC      := Color(0.259, 0.271, 0.294)   # mansard roof and its dormers
const C_PANEL     := Color(0.541, 0.529, 0.494)   # precast panel, the social housing
const C_PANEL_DK  := Color(0.412, 0.404, 0.380)   # the joint between panels
const C_PANEL_LT  := Color(0.639, 0.624, 0.584)   # parapet, where the light lands
const C_BALCONY   := Color(0.451, 0.463, 0.443)   # balcony slabs and their railings
const C_SASH_DE   := Color(0.831, 0.824, 0.788)   # window frames — white, always
const C_GLASS     := Color(0.098, 0.106, 0.133)   # unlit glass
const C_GLASS_LIT := Color(0.968, 0.855, 0.596)   # a room with somebody in it
const C_PAVE      := Color(0.325, 0.325, 0.318)   # berlin pavement, small grey slabs
const C_RADWEG    := Color(0.443, 0.271, 0.235)   # the red brick cycle strip
const C_KERB      := Color(0.404, 0.396, 0.380)   # kerbstone, coping, bridge string
const C_ASPHALT   := Color(0.184, 0.188, 0.204)   # road, patched and repatched
const C_IRON      := Color(0.075, 0.078, 0.090)   # viaduct, railings, posts, bike frames
const C_ALU       := Color(0.643, 0.651, 0.647)   # satellite dishes, spit shaft, trays
const C_INK       := Color(0.129, 0.118, 0.110)   # sign lettering on a pale board

# The canal, and what grows over it
const C_TOWPATH   := Color(0.286, 0.259, 0.216)   # compacted dirt, roots, no slabs
const C_CANAL     := Color(0.129, 0.184, 0.169)   # green and not moving
const C_CANAL_LT  := Color(0.204, 0.267, 0.239)   # what passes for a ripple
const C_LEAF      := Color(0.208, 0.286, 0.204)   # the trees, older than the buildings
const C_BARK      := Color(0.322, 0.298, 0.263)   # plane bark, flaking
const C_BRICK_K   := Color(0.396, 0.243, 0.212)   # the bridge — the only brick here
const C_BRIDGE_GN := Color(0.161, 0.290, 0.243)   # balustrade, repainted green forever

# Berlin's statutory colours. Never two of them in the same glance.
const C_BVG_YELLOW := Color(0.976, 0.784, 0.086)  # the U1 carriage, and nothing else
const C_U_BLUE     := Color(0.050, 0.220, 0.550)  # the U on its square, as in mitte
const C_BSR_ORANGE := Color(0.898, 0.396, 0.086)  # bins, and only bins

# The warm end. İznik-adjacent, and it lives on produce, plastic and awning
# canvas — never on a wall, never on the architecture.
const C_BOLE    := Color(0.784, 0.271, 0.227)     # tomatoes, awning stripe, the A
const C_TURQ    := Color(0.184, 0.643, 0.627)     # the other awning stripe
const C_EMERALD := Color(0.122, 0.478, 0.353)     # peppers, the kuaför's sign box
const C_SAFRON  := Color(0.878, 0.639, 0.169)     # quince, and the light inside a fırın
const C_TILE_W  := Color(0.941, 0.925, 0.878)     # backlit plastic, always too bright
const C_SPIT    := Color(0.741, 0.400, 0.243)     # the cone, under its element
const C_CRATE   := Color(0.478, 0.353, 0.235)     # produce crates, out on the pavement

# Shared with Mitte, London and Istanbul so exits and collision stay true
const PAVE_TOP  := 292.0
const ROAD_TOP  := 372.0
const PAVE_BOT  := 516.0
const WATER_TOP := 592.0

# Blocks along the street: [x, width, storeys, 0 = altbau | 1 = panel slab].
# Alternating on purpose, and the storey counts deliberately incompatible —
# a four-storey stucco house against an eight-storey slab, party wall to party
# wall, is the single most Kreuzberg fact available.
const _BLOCKS := [
	[-50, 248, 4, 0], [198, 236, 8, 1], [434, 226, 4, 0],
	[660, 214, 7, 1], [874, 232, 4, 0], [1106, 122, 8, 1],
]

# The second layer of signage — the businesses that are not on the ground floor
# and put a board up anyway. Turkish and German, same height, same plastic.
const UPPER_SIGNS := [
	["KUAFÖR", 216.0, 202.0], ["SPÄTI", 400.0, 206.0],
	["DÜĞÜN SALONU", 574.0, 202.0], ["SPIELHALLE", 790.0, 206.0],
	["ÇAY OCAĞI", 964.0, 202.0],
]
const _SIGN_BOARDS := [
	Color(0.941, 0.925, 0.878), Color(0.878, 0.639, 0.169),
	Color(0.784, 0.271, 0.227), Color(0.129, 0.478, 0.416),
	Color(0.941, 0.925, 0.878),
]
const _SIGN_INKS := [
	Color(0.129, 0.118, 0.110), Color(0.129, 0.118, 0.110),
	Color(0.941, 0.925, 0.878), Color(0.941, 0.925, 0.878),
	Color(0.663, 0.212, 0.278),
]

# Graffiti. Bottom layer: throw-ups, big and fast. [x, y, w, h]
const _THROWS := [
	[-24.0, 200.0, 196.0, 70.0], [180.0, 172.0, 232.0, 100.0],
	[424.0, 204.0, 168.0, 66.0], [616.0, 164.0, 252.0, 108.0],
	[888.0, 202.0, 196.0, 68.0], [1096.0, 176.0, 148.0, 96.0],
]
const _GRAF_FILL := [
	Color(0.180, 0.286, 0.549), Color(0.663, 0.212, 0.278),
	Color(0.129, 0.478, 0.416), Color(0.549, 0.325, 0.639),
	Color(0.780, 0.529, 0.129), Color(0.204, 0.220, 0.259),
]
const _GRAF_INK := [
	Color(0.902, 0.918, 0.941, 0.34), Color(0.349, 0.800, 0.851, 0.28),
	Color(0.949, 0.451, 0.251, 0.26), Color(0.749, 0.400, 0.851, 0.24),
]

# Hoisted out of the draw calls — this project has been bitten by inference on
# subscripts before, and a named const reads better at the call site anyway.
const PRODUCE := [C_BOLE, C_EMERALD, C_SAFRON, C_BOLE, C_TURQ]
const BIKE_HUES := [
	Color(0.192, 0.208, 0.235), Color(0.478, 0.278, 0.235),
	Color(0.259, 0.353, 0.310), Color(0.541, 0.529, 0.494),
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
	_draw_hochbahn()
	_draw_blocks()
	_draw_graffiti()
	_draw_upper_signs()
	_draw_doors(238.0, PAVE_TOP, C_TILE_W, C_INK, C_BOLE, C_GLASS)
	_draw_ground()
	_draw_street()
	_draw_canal()


# What blocks you. The buildings do not need entries — player collision already
# stops at y=300 — so everything here is out on the pavement, which is where
# Kreuzberg keeps its business anyway. The canal railing is the important one:
# without it the towpath just runs into the water.
func solids() -> Array:
	var out: Array = []
	out.append(Rect2(238.0, 286.0, 118.0, 36.0))   # the manav's crates
	out.append(Rect2(742.0, 288.0, 74.0, 32.0))    # empties outside the imbiss
	out.append(Rect2(408.0, 284.0, 96.0, 34.0))    # bikes, chained in a row
	out.append(Rect2(946.0, 284.0, 88.0, 34.0))    # more bikes
	out.append(Rect2(586.0, 268.0, 46.0, 54.0))    # the stromkasten
	out.append(Rect2(848.0, 274.0, 32.0, 48.0))    # bsr bin
	out.append(Rect2(160.0, 272.0, 14.0, 50.0))    # lamp column
	out.append(Rect2(35.0, 248.0, 11.0, 54.0))     # the U sign's post
	out.append(Rect2(0.0, 556.0, 1024.0, 32.0))    # canal railing
	out.append(Rect2(1024.0, 494.0, 128.0, 42.0))  # bridge parapet
	out.append(Rect2(1024.0, 540.0, 128.0, 54.0))  # bridge abutment
	out.append(Rect2(58.0, 542.0, 26.0, 40.0))     # plane tree on the towpath
	out.append(Rect2(990.0, 542.0, 26.0, 40.0))    # the other one
	return out


# ── Sky ───────────────────────────────────────────────────────────────────────
# Mitte's bands, unchanged. Whatever else is different here, it is the same
# weather two U-Bahn stops away.

func _draw_sky() -> void:
	if GameState.is_morning():
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.42, 0.58, 0.74))
		draw_rect(Rect2(0, 190, VW, 102), Color(0.52, 0.64, 0.77))
		return
	draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.045, 0.040, 0.105))
	draw_rect(Rect2(0, 45, VW, 180), Color(0.072, 0.058, 0.148))
	draw_rect(Rect2(0, 180, VW, 70), Color(0.160, 0.090, 0.182))
	draw_rect(Rect2(0, 250, VW, 42), Color(0.300, 0.160, 0.135))


# ── The Hochbahn ──────────────────────────────────────────────────────────────
# The U1 is a street over, up on its iron, and you can see the yellow of it
# crossing the gaps in the roofline. It is how the player knew where to get off,
# and it is the only Berlin silhouette that belongs to this district and not to
# Mitte. Drawn before the blocks, so the tall slabs cut it and the low stucco
# houses do not.

func _draw_hochbahn() -> void:
	draw_rect(Rect2(0, 46, VW, 6), C_IRON.lightened(0.12))
	draw_rect(Rect2(0, 52, VW, 18), C_IRON)
	for i in range(int(VW / 26.0) + 1):
		var gx: float = float(i) * 26.0
		draw_line(Vector2(gx, 52), Vector2(gx + 26.0, 70), C_IRON.lightened(0.18), 2.0)
		draw_line(Vector2(gx + 26.0, 52), Vector2(gx, 70), C_IRON.darkened(0.35), 2.0)
	draw_rect(Rect2(0, 68, VW, 4), Color(0, 0, 0, 0.30))
	_draw_train(fmod(_t * 78.0, VW + 1000.0) - 660.0)


func _draw_train(x: float) -> void:
	if x < -600.0 or x > VW + 40.0:
		return
	for c in range(2):
		var cx: float = x + float(c) * 274.0
		draw_rect(Rect2(cx, 18, 266, 30), C_BVG_YELLOW)
		draw_rect(Rect2(cx, 18, 266, 4), C_BVG_YELLOW.lightened(0.26))
		draw_rect(Rect2(cx, 42, 266, 6), C_BVG_YELLOW.darkened(0.36))
		for w in range(6):
			var lit: bool = ((w + c) % 3) != 2
			var pane: Color = C_GLASS
			if lit:
				pane = C_GLASS_LIT
			draw_rect(Rect2(cx + 15.0 + float(w) * 42.0, 24, 30, 15), pane)
		draw_rect(Rect2(cx + 260, 18, 8, 30), C_IRON)


# ── The blocks ────────────────────────────────────────────────────────────────

func _draw_blocks() -> void:
	for i in range(_BLOCKS.size()):
		var b: Array = _BLOCKS[i]
		var x: float = float(b[0])
		var w: float = float(b[1])
		var n: int = int(b[2])
		if int(b[3]) == 1:
			_draw_sozialbau(x, w, n, i)
		else:
			_draw_altbau(x, w, n, i)


func _draw_altbau(x: float, w: float, storeys: int, i: int) -> void:
	var top: float = 96.0 - float(i % 3) * 7.0
	var body: Color = C_ALTBAU
	if i % 3 == 1:
		body = C_ALTBAU_2
	# Zinc mansard with dormers punched into it. Berlin's roofline is a shallow
	# grey lid, never a gable, and never level with its neighbour.
	draw_rect(Rect2(x - 5.0, top - 20.0, w + 10.0, 22.0), C_ZINC)
	draw_rect(Rect2(x - 5.0, top - 20.0, w + 10.0, 3.0), C_ZINC.lightened(0.22))
	for d in range(int(w / 78.0)):
		var dx: float = x + 26.0 + float(d) * 78.0
		draw_rect(Rect2(dx, top - 15.0, 30.0, 15.0), C_ZINC.darkened(0.24))
		draw_rect(Rect2(dx + 4.0, top - 12.0, 22.0, 12.0), C_GLASS)
	draw_rect(Rect2(x - 7.0, top, w + 14.0, 8.0), C_ALTBAU_LT)
	# Stucco body. Sooted on the return, and one bright edge where the sun gets in.
	draw_rect(Rect2(x, top + 8.0, w, 238.0 - top - 8.0), body)
	draw_rect(Rect2(x + w - 9.0, top + 8.0, 9.0, 238.0 - top - 8.0), C_ALTBAU_DK)
	draw_rect(Rect2(x, top + 8.0, 5.0, 238.0 - top - 8.0), body.lightened(0.10))
	# Four windows to a floor, tall — the altbau proportion, and the reason the
	# rents here stopped being cheap.
	var fh: float = (238.0 - top - 14.0) / float(maxi(storeys, 1))
	for r in range(storeys):
		var wy: float = top + 16.0 + float(r) * fh
		for c in range(4):
			_draw_de_window(x + 16.0 + float(c) * ((w - 46.0) / 4.0), wy,
				30.0, fh - 11.0, i * 5 + r * 3 + c, r == 0)
	# The string course under the first floor, the one bit of ornament the
	# landlord paid for before he stopped.
	draw_rect(Rect2(x, top + 12.0 + fh, w, 4.0), C_ALTBAU_LT)
	draw_rect(Rect2(x, top + 16.0 + fh, w, 2.0), C_ALTBAU_DK)


func _draw_de_window(x: float, y: float, w: float, h: float, seed_i: int,
		ornate: bool) -> void:
	if h < 10.0:
		return
	if ornate:
		draw_rect(Rect2(x - 6.0, y - 8.0, w + 12.0, 5.0), C_ALTBAU_LT)
	draw_rect(Rect2(x - 2.0, y - 2.0, w + 4.0, h + 4.0), C_SASH_DE)
	var lit: bool = ((seed_i * 41) % 7) < 3
	var pane: Color = C_GLASS
	if lit and not GameState.is_morning():
		pane = C_GLASS_LIT
	draw_rect(Rect2(x, y, w, h), pane)
	# Two casements, and every so often the left one tipped open at the top,
	# which is how a German window is always found.
	draw_rect(Rect2(x + w * 0.5 - 1.5, y, 3.0, h), C_SASH_DE)
	if seed_i % 4 == 0:
		draw_rect(Rect2(x, y, w * 0.5, 5.0), C_SASH_DE.darkened(0.26))
	draw_rect(Rect2(x - 4.0, y + h, w + 8.0, 4.0), C_ALTBAU_LT.darkened(0.10))
	draw_rect(Rect2(x - 2.0, y + h + 4.0, w + 4.0, 4.0), Color(0, 0, 0, 0.16))


func _draw_sozialbau(x: float, w: float, storeys: int, i: int) -> void:
	var fh: float = 26.0
	var top: float = 238.0 - float(storeys) * fh
	draw_rect(Rect2(x, top, w, 238.0 - top), C_PANEL)
	draw_rect(Rect2(x, top - 7.0, w, 9.0), C_PANEL_LT)
	draw_rect(Rect2(x + w - 12.0, top, 12.0, 238.0 - top), C_PANEL_DK)
	# The panel joints. The whole idea of the system was that you could count
	# them from the street, and forty years later you still can.
	for r in range(storeys + 1):
		draw_rect(Rect2(x, top + float(r) * fh, w, 2.0), C_PANEL_DK)
	for c in range(int(w / 62.0) + 1):
		draw_rect(Rect2(x + float(c) * 62.0, top, 2.0, 238.0 - top), C_PANEL_DK)
	for s in range(storeys):
		_draw_slab_floor(x, w, top + 8.0 + float(s) * fh, i * 3 + s)
	# The lift overrun and the aerials on top of it
	draw_rect(Rect2(x + w * 0.5 - 26.0, top - 24.0, 52.0, 18.0), C_PANEL_DK)
	draw_rect(Rect2(x + w * 0.5 - 2.0, top - 44.0, 3.0, 22.0), C_IRON)


func _draw_slab_floor(x: float, w: float, y: float, seed_i: int) -> void:
	# Windows first, then the balcony slab across the front of them, because
	# that continuous horizontal is the only thing the design had to say.
	for c in range(int((w - 24.0) / 62.0)):
		var lit: bool = ((seed_i * 13 + c * 7) % 6) < 2
		var pane: Color = C_GLASS
		if lit and not GameState.is_morning():
			pane = C_GLASS_LIT
		var wx: float = x + 16.0 + float(c) * 62.0
		draw_rect(Rect2(wx, y - 17.0, 34.0, 17.0), C_SASH_DE.darkened(0.16))
		draw_rect(Rect2(wx + 2.0, y - 15.0, 30.0, 13.0), pane)
	draw_rect(Rect2(x + 6.0, y, w - 12.0, 11.0), C_BALCONY)
	draw_rect(Rect2(x + 6.0, y, w - 12.0, 3.0), C_BALCONY.lightened(0.20))
	for b in range(int((w - 26.0) / 9.0)):
		draw_rect(Rect2(x + 13.0 + float(b) * 9.0, y - 9.0, 2.0, 9.0),
			C_BALCONY.lightened(0.12))
	# A dish aimed at Türksat, a rug over the rail, a rack of washing. Nobody
	# sits on these balconies; they are the flat's only cupboard.
	if seed_i % 3 == 0:
		draw_circle(Vector2(x + w - 36.0, y - 6.0), 7.0, C_ALU)
		draw_rect(Rect2(x + w - 37.0, y - 8.0, 2.0, 10.0), C_IRON)
	elif seed_i % 3 == 1:
		draw_rect(Rect2(x + 24.0, y - 11.0, 46.0, 13.0), C_BOLE.darkened(0.24))
		draw_rect(Rect2(x + 24.0, y - 11.0, 46.0, 3.0), C_SAFRON.darkened(0.22))
	else:
		for l in range(3):
			draw_rect(Rect2(x + 28.0 + float(l) * 16.0, y - 10.0, 11.0, 11.0),
				C_TILE_W.darkened(0.10 * float(l % 2)))


# ── Graffiti ──────────────────────────────────────────────────────────────────
# In Mitte the tags sit at hand height and stop. Here the paint IS the surface
# and the render is what shows through the gaps in it. Three layers, in the
# order they actually happen: throw-ups fast and big, tags over them, stickers
# over those — and the stickers are the only layer anybody reads.

func _draw_graffiti() -> void:
	for i in range(_THROWS.size()):
		var g: Array = _THROWS[i]
		_draw_throw(float(g[0]), float(g[1]), float(g[2]), float(g[3]), i)
	for i in range(14):
		_draw_tag(-30.0 + float(i) * 86.0, 214.0 + float((i * 7) % 5) * 9.0,
			64.0 + float((i * 11) % 40), i)
	for i in range(18):
		var sx: float = 12.0 + float(i) * 63.0
		var sy: float = 250.0 + float((i * 5) % 4) * 10.0
		draw_rect(Rect2(sx, sy, 15.0, 11.0), _GRAF_FILL[i % _GRAF_FILL.size()])
		draw_rect(Rect2(sx, sy, 15.0, 3.0), Color(1, 1, 1, 0.30))


func _draw_throw(x: float, y: float, w: float, h: float, i: int) -> void:
	# A throw-up is bubble letters: overlapping rounds sharing one flat
	# baseline, outlined last, and it took ninety seconds.
	var fill: Color = _GRAF_FILL[i % _GRAF_FILL.size()]
	var edge: Color = Color(0.055, 0.050, 0.070, 0.85)
	var n: int = maxi(int(w / 34.0), 1)
	for b in range(n):
		var bx: float = x + 20.0 + float(b) * ((w - 30.0) / float(n))
		var by: float = y + h * 0.5 + float((b * 5) % 3) * 5.0 - 6.0
		draw_circle(Vector2(bx, by), h * 0.34, edge)
		draw_circle(Vector2(bx, by), h * 0.28, fill)
		draw_circle(Vector2(bx - h * 0.09, by - h * 0.09), h * 0.10,
			Color(1, 1, 1, 0.22))
	draw_rect(Rect2(x + 12.0, y + h - 12.0, w - 24.0, 5.0), edge)
	# The drips, because nobody stands there waiting for it to dry
	for d in range(5):
		draw_rect(Rect2(x + 26.0 + float(d) * (w / 5.4), y + h - 8.0, 3.0,
			10.0 + float((d * 13) % 16)), fill)


func _draw_tag(x: float, y: float, w: float, i: int) -> void:
	# One continuous gesture, laid over whatever was already there
	var ink: Color = _GRAF_INK[i % _GRAF_INK.size()]
	var prev: Vector2 = Vector2(x, y + 12.0)
	for s in range(6):
		var nx: float = x + w * (float(s + 1) / 6.0)
		var ny: float = y + (12.0 if s % 2 == 0 else -5.0) + float((i * 5 + s) % 5)
		draw_line(prev, Vector2(nx, ny), ink, 2.4)
		prev = Vector2(nx, ny)
	draw_line(Vector2(x, y + 17.0), Vector2(x + w * 0.62, y + 18.0),
		Color(ink.r, ink.g, ink.b, ink.a * 0.55), 1.6)


# The second signage layer. Two languages, one height, one kind of plastic, and
# nobody has translated either of them for the other. This is the jolt.
func _draw_upper_signs() -> void:
	for i in range(UPPER_SIGNS.size()):
		var s: Array = UPPER_SIGNS[i]
		var sx: float = float(s[1])
		var sy: float = float(s[2])
		var board: Color = _SIGN_BOARDS[i % _SIGN_BOARDS.size()]
		var ink: Color = _SIGN_INKS[i % _SIGN_INKS.size()]
		IA.fascia(self, sx, sy, String(s[0]), board, ink,
			not GameState.is_morning())


# ── Ground ────────────────────────────────────────────────────────────────────

func _draw_ground() -> void:
	draw_rect(Rect2(0, PAVE_TOP, VW, ROAD_TOP - PAVE_TOP), C_PAVE)
	var line: Color = Color(0, 0, 0, 0.12)
	for r in range(2):
		var sy: float = PAVE_TOP + float(r) * 23.0
		draw_rect(Rect2(0, sy, VW, 1.0), line)
		for c in range(int(VW / 34.0) + 1):
			draw_rect(Rect2(float(c) * 34.0 + float(r % 2) * 17.0, sy, 1.0, 23.0), line)
	# The red brick Radweg, which nobody cycles on because the bikes are parked
	# on it. Berlin puts the cycle lane in the pavement and then loses it.
	draw_rect(Rect2(0, PAVE_TOP + 46.0, VW, 22.0), C_RADWEG)
	for i in range(int(VW / 15.0) + 1):
		draw_rect(Rect2(float(i) * 15.0, PAVE_TOP + 46.0, 1.0, 22.0),
			C_RADWEG.darkened(0.20))
	draw_rect(Rect2(0, ROAD_TOP - 9.0, VW, 9.0), C_KERB)
	draw_rect(Rect2(0, ROAD_TOP - 9.0, VW, 2.0), C_KERB.lightened(0.24))
	# Asphalt, patched over patches, with a broken centre line and no tram
	# rails — this side of the wall never had any.
	draw_rect(Rect2(0, ROAD_TOP, VW, PAVE_BOT - ROAD_TOP), C_ASPHALT)
	for p in range(7):
		draw_rect(Rect2(float((p * 173) % 1080), ROAD_TOP + 18.0 + float((p * 29) % 90),
			90.0 + float((p * 41) % 120), 30.0), Color(0, 0, 0, 0.09))
	for m in range(12):
		draw_rect(Rect2(float(m) * 96.0 + 18.0, 442.0, 44.0, 4.0),
			Color(0.80, 0.80, 0.76, 0.32))
	draw_rect(Rect2(0, PAVE_BOT - 8.0, VW, 8.0), C_KERB.darkened(0.14))


# ── The pavement, which is where everything actually happens ──────────────────

func _draw_street() -> void:
	_draw_manav(298.0)
	_draw_spit(700.0)
	_draw_apotheke_a(880.0)
	_draw_crates(742.0)
	_draw_bikes(408.0, 5)
	_draw_bikes(946.0, 4)
	_draw_stromkasten(586.0)
	_draw_bin(848.0)
	_draw_lamp(166.0)
	_draw_u_sign(40.0)


func _draw_manav(x: float) -> void:
	# The greengrocer. This is the only place on the street where the
	# saturation is allowed all the way up, and it gets there on a strip of
	# awning canvas and a tomato — never on the building.
	var y: float = 208.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 96.0, y), Vector2(x + 96.0, y),
		Vector2(x + 82.0, y + 40.0), Vector2(x - 82.0, y + 40.0),
	]), C_TILE_W)
	for b in range(8):
		if b % 2 == 1:
			continue
		var stripe: Color = C_BOLE
		if b % 4 != 0:
			stripe = C_TURQ
		var bx: float = x - 82.0 + float(b) * 22.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, y), Vector2(bx + 18.0, y),
			Vector2(bx + 15.0, y + 40.0), Vector2(bx - 3.0, y + 40.0),
		]), stripe)
	draw_rect(Rect2(x - 88.0, y + 38.0, 176.0, 5.0), C_IRON)
	draw_rect(Rect2(x - 82.0, y + 43.0, 164.0, 24.0), Color(0, 0, 0, 0.24))
	# Crates out on the pavement, tipped forward so you can see into them.
	# Everything is priced by the kilo in a language the player cannot read.
	for c in range(4):
		var cx: float = x - 60.0 + float(c) * 30.0
		draw_rect(Rect2(cx, 288.0, 28.0, 32.0), C_CRATE)
		draw_rect(Rect2(cx, 283.0, 28.0, 8.0), C_CRATE.darkened(0.24))
		for p in range(6):
			draw_circle(Vector2(cx + 6.0 + float(p % 3) * 9.0,
				291.0 + float(p / 3) * 9.0), 4.2,
				PRODUCE[(c * 2 + p) % PRODUCE.size()])


func _draw_spit(x: float) -> void:
	# The vertical spit, in the window, at eye height, turning. It is the first
	# thing in Berlin the alien recognises as food, and it is Turkish.
	var top: float = 244.0
	var h: float = 44.0
	draw_rect(Rect2(x - 30.0, top - 5.0, 60.0, h + 14.0), Color(0.078, 0.070, 0.062))
	draw_rect(Rect2(x + 12.0, top, 10.0, h), Color(0.85, 0.33, 0.18, 0.75))
	var turn: float = sin(_t * 0.9)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 14.0, top), Vector2(x + 8.0, top),
		Vector2(x + 3.0, top + h), Vector2(x - 9.0, top + h),
	]), C_SPIT)
	draw_rect(Rect2(x - 13.0 + turn * 4.0, top + 4.0, 5.0, h - 8.0),
		C_SPIT.lightened(0.26))
	draw_rect(Rect2(x + 1.0 + turn * 3.0, top + 6.0, 4.0, h - 12.0),
		C_SPIT.darkened(0.30))
	draw_rect(Rect2(x - 3.0, top - 9.0, 4.0, 12.0), C_ALU)
	draw_rect(Rect2(x - 16.0, top + h, 26.0, 5.0), C_ALU.darkened(0.24))
	if not GameState.is_morning():
		draw_circle(Vector2(x, PAVE_TOP), 62.0, Color(0.98, 0.62, 0.30, 0.045))


func _draw_apotheke_a(x: float) -> void:
	# The red A, hung out perpendicular so it reads from down the street.
	# Germany's sign, not Turkey's, and it is shut by half six.
	draw_rect(Rect2(x + 44.0, 200.0, 6.0, 34.0), C_IRON)
	draw_rect(Rect2(x + 48.0, 198.0, 44.0, 38.0), C_TILE_W)
	draw_rect(Rect2(x + 48.0, 198.0, 44.0, 3.0), C_TILE_W.darkened(0.26))
	draw_line(Vector2(x + 60.0, 230.0), Vector2(x + 70.0, 204.0), C_BOLE, 5.0)
	draw_line(Vector2(x + 80.0, 230.0), Vector2(x + 70.0, 204.0), C_BOLE, 5.0)
	draw_rect(Rect2(x + 63.0, 218.0, 14.0, 4.0), C_BOLE)
	if not GameState.is_morning():
		draw_circle(Vector2(x + 70.0, 217.0), 34.0, Color(0.95, 0.94, 0.90, 0.05))


func _draw_crates(x: float) -> void:
	# Drink crates stacked outside the İmbiss, four high, taken in at four a.m.
	for r in range(4):
		var cy: float = 312.0 - float(r) * 13.0
		draw_rect(Rect2(x, cy, 70.0, 13.0), C_CRATE.darkened(0.18))
		draw_rect(Rect2(x, cy, 70.0, 3.0), C_CRATE.lightened(0.10))
		for b in range(5):
			draw_rect(Rect2(x + 5.0 + float(b) * 13.0, cy + 2.0, 7.0, 9.0),
				Color(0.24, 0.40, 0.26, 0.85))


func _draw_bikes(x: float, n: int) -> void:
	# Chained to the railing, to the lamp post, to each other, to a sign that
	# came out of the ground years ago. The third one has no front wheel and
	# has not moved in longer than the player has been on this planet.
	for i in range(n):
		var bx: float = x + float(i) * 21.0
		var lean: float = float((i * 7) % 3) - 1.0
		var frame: Color = BIKE_HUES[i % BIKE_HUES.size()]
		draw_circle(Vector2(bx, 310.0), 11.0, C_IRON)
		draw_circle(Vector2(bx, 310.0), 8.0, Color(0.24, 0.24, 0.26, 0.35))
		if i != 2:
			draw_circle(Vector2(bx + 24.0 + lean, 310.0), 11.0, C_IRON)
			draw_circle(Vector2(bx + 24.0 + lean, 310.0), 8.0,
				Color(0.24, 0.24, 0.26, 0.35))
		draw_line(Vector2(bx, 310.0), Vector2(bx + 14.0, 291.0), frame, 2.6)
		draw_line(Vector2(bx + 14.0, 291.0), Vector2(bx + 24.0 + lean, 310.0),
			frame, 2.6)
		draw_line(Vector2(bx + 6.0, 310.0), Vector2(bx + 16.0, 288.0), frame, 2.2)
		draw_rect(Rect2(bx + 10.0, 286.0, 12.0, 3.0), C_IRON)


func _draw_stromkasten(x: float) -> void:
	# A grey metal cabinet, stickered past legibility. Every flat surface at
	# hand height in this district has been claimed by somebody.
	draw_rect(Rect2(x, 268.0, 46.0, 54.0), Color(0.451, 0.455, 0.443))
	draw_rect(Rect2(x, 268.0, 46.0, 4.0), Color(0.549, 0.553, 0.541))
	draw_rect(Rect2(x + 40.0, 268.0, 6.0, 54.0), Color(0.353, 0.357, 0.349))
	for i in range(9):
		var sx: float = x + 3.0 + float(i % 3) * 14.0
		var sy: float = 274.0 + float(i / 3) * 15.0
		draw_rect(Rect2(sx, sy, 13.0, 12.0), _GRAF_FILL[i % _GRAF_FILL.size()])
		draw_rect(Rect2(sx, sy + 2.0, 13.0, 2.0), Color(1, 1, 1, 0.34))
	draw_line(Vector2(x + 2.0, 314.0), Vector2(x + 44.0, 300.0),
		Color(0.902, 0.918, 0.941, 0.40), 2.4)


func _draw_bin(x: float) -> void:
	# Orange, and orange only ever means this. There are bottles stood beside it
	# rather than in it, which is the local courtesy.
	draw_rect(Rect2(x, 274.0, 32.0, 48.0), C_BSR_ORANGE.darkened(0.16))
	draw_rect(Rect2(x, 274.0, 32.0, 5.0), C_BSR_ORANGE)
	draw_rect(Rect2(x + 3.0, 288.0, 26.0, 9.0), Color(0.98, 0.96, 0.90, 0.80))
	draw_rect(Rect2(x - 3.0, 270.0, 38.0, 6.0), Color(0.20, 0.20, 0.21))
	for i in range(3):
		draw_rect(Rect2(x + 36.0 + float(i) * 10.0, 302.0, 7.0, 18.0),
			Color(0.24, 0.42, 0.26, 0.85))


func _draw_lamp(x: float) -> void:
	draw_rect(Rect2(x, 154.0, 14.0, 168.0), C_IRON)
	draw_rect(Rect2(x + 3.0, 154.0, 3.0, 168.0), C_IRON.lightened(0.14))
	draw_rect(Rect2(x - 2.0, 146.0, 44.0, 8.0), C_IRON)
	draw_rect(Rect2(x + 26.0, 152.0, 20.0, 9.0), C_IRON.lightened(0.10))
	if not GameState.is_morning():
		var glow: float = 0.74 + 0.06 * sin(_t * 1.1)
		draw_circle(Vector2(x + 36.0, 160.0), 52.0,
			Color(0.98, 0.82, 0.48, 0.055 * glow))
		draw_rect(Rect2(x + 28.0, 158.0, 16.0, 6.0),
			Color(0.99, 0.88, 0.62, glow))


# The U on its blue square. Same sign as Mitte's, because it is the same
# network, and it is the only thing here that looks municipal.
func _draw_u_sign(x: float) -> void:
	var y: float = PAVE_TOP - 44.0
	draw_rect(Rect2(x - 5.0, 248.0, 11.0, 54.0), C_IRON)
	draw_rect(Rect2(x - 24.0, y - 48.0, 48.0, 48.0), C_U_BLUE)
	draw_rect(Rect2(x - 24.0, y - 48.0, 48.0, 48.0), Color(0.85, 0.88, 0.92),
		false, 2.0)
	draw_rect(Rect2(x - 12.0, y - 40.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x + 6.0, y - 40.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x - 12.0, y - 22.0, 24.0, 6.0), Color(0.94, 0.96, 0.98))


# ── The Landwehrkanal ─────────────────────────────────────────────────────────
# It takes the far pavement's place. Green, not moving, and the reason the
# trees on this street are older than anything built beside them. The railing
# is load-bearing in the other sense: without it the towpath runs into water.

func _draw_canal() -> void:
	draw_rect(Rect2(0, PAVE_BOT, VW, WATER_TOP - PAVE_BOT), C_TOWPATH)
	for i in range(26):
		draw_rect(Rect2(float(i) * 46.0, PAVE_BOT + 10.0 + float((i * 7) % 40),
			34.0, 8.0), C_TOWPATH.lightened(0.10))
	draw_rect(Rect2(0, WATER_TOP - 11.0, VW, 11.0), C_KERB.darkened(0.18))
	draw_rect(Rect2(0, WATER_TOP - 11.0, VW, 2.0), C_KERB.lightened(0.10))
	draw_rect(Rect2(0, WATER_TOP, VW, VH - WATER_TOP), C_CANAL)
	for i in range(9):
		var drift: float = sin(_t * 0.35 + float(i) * 0.8) * 9.0
		draw_rect(Rect2(float(i) * 132.0 + drift, WATER_TOP + 8.0 + float(i % 3) * 15.0,
			96.0, 3.0), C_CANAL_LT.lightened(0.06))
	_draw_railing()
	_draw_canal_tree(70.0)
	_draw_canal_tree(1002.0)
	_draw_bridge(1024.0)
	_draw_pfand_row(304.0)


func _draw_railing() -> void:
	draw_rect(Rect2(0, 556.0, 1024.0, 4.0), C_IRON)
	draw_rect(Rect2(0, 574.0, 1024.0, 3.0), C_IRON)
	for i in range(int(1024.0 / 24.0) + 1):
		draw_rect(Rect2(float(i) * 24.0, 556.0, 3.0, 30.0), C_IRON)
	draw_rect(Rect2(0, 584.0, 1024.0, 3.0), Color(0, 0, 0, 0.24))


func _draw_canal_tree(x: float) -> void:
	# Planted before the wall went up and ignored by both sides of it. The
	# branch out over the water is the only thing on this street anybody has
	# ever photographed on purpose.
	draw_rect(Rect2(x - 12.0, 512.0, 24.0, 70.0), C_BARK)
	for f in range(5):
		draw_rect(Rect2(x - 12.0 + float((f * 5) % 3) * 7.0,
			518.0 + float(f) * 13.0, 9.0, 9.0), C_BARK.lightened(0.20))
	var leaf: Color = C_LEAF
	if not GameState.is_morning():
		leaf = C_LEAF.darkened(0.34)
	draw_circle(Vector2(x, 486.0), 46.0, leaf)
	draw_circle(Vector2(x - 32.0, 508.0), 30.0, leaf)
	draw_circle(Vector2(x + 30.0, 504.0), 32.0, leaf)
	draw_line(Vector2(x + 6.0, 528.0), Vector2(x + 88.0, 612.0),
		C_BARK.darkened(0.28), 3.0)
	draw_circle(Vector2(x + 62.0, 604.0), 26.0, leaf.darkened(0.18))
	draw_circle(Vector2(x + 96.0, 622.0), 20.0, leaf.darkened(0.24))


func _draw_bridge(x: float) -> void:
	# Brick, iron, and a cast balustrade somebody has been repainting the same
	# green for a hundred years. One of the few places in Kreuzberg you can
	# stand still without being in somebody's way.
	var w: float = VW - x + 14.0
	draw_rect(Rect2(x, 540.0, w, VH - 540.0), C_BRICK_K)
	for r in range(6):
		draw_rect(Rect2(x, 544.0 + float(r) * 18.0, w, 2.0), C_BRICK_K.darkened(0.26))
	draw_circle(Vector2(x + 8.0, 642.0), 40.0, C_CANAL.darkened(0.42))
	draw_rect(Rect2(x - 6.0, 528.0, w + 12.0, 14.0), C_KERB)
	draw_rect(Rect2(x - 6.0, 528.0, w + 12.0, 3.0), C_KERB.lightened(0.18))
	for b in range(int(w / 17.0) + 2):
		draw_rect(Rect2(x - 4.0 + float(b) * 17.0, 500.0, 5.0, 30.0), C_BRIDGE_GN)
	draw_rect(Rect2(x - 6.0, 494.0, w + 12.0, 7.0), C_BRIDGE_GN.darkened(0.20))
	draw_rect(Rect2(x - 6.0, 494.0, w + 12.0, 2.0), C_BRIDGE_GN.lightened(0.26))


func _draw_pfand_row(x: float) -> void:
	# Empties stood in a row on the coping. Nobody in Berlin throws a deposit
	# bottle away; you leave it where whoever collects them can reach it
	# without putting a hand into a bin.
	for i in range(6):
		var glass: Color = Color(0.24, 0.42, 0.26, 0.85)
		if i % 2 == 1:
			glass = Color(0.36, 0.30, 0.18, 0.85)
		var bx: float = x + float(i) * 13.0
		draw_rect(Rect2(bx, 568.0, 7.0, 18.0), glass)
		draw_rect(Rect2(bx + 2.0, 560.0, 3.0, 9.0), glass)
