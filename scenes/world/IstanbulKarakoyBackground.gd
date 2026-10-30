extends Node2D

# Karaköy — the waterfront, and the correction the Istanbul act needed.
#
# The çarşı and the han are both dry and inland, which is a lie about a city
# that is sea level nearly everywhere and gets to work by boat. This plate is
# where the game admits it: the Bosphorus across the top, ferries actually
# crossing it, and a quay you can stand on with the water at your knees.
#
# The projection needs saying out loud, because water and frontage share the top
# of the screen here and nowhere else in the game. You are standing on the
# corner of the quay, where the street bends round the head of the ferry pier.
# Seaward is up-and-left. Landward is up-and-right, and it climbs — Galata's
# hill starts at the kerb and does not stop. That hinge is why there is open
# water and a stacked frontage at the same height.
#
# The palette rule from docs/design/istanbul.md still holds: İznik saturation
# only on ceramic, tile, glass and the eye, never on architecture. One addition
# that only this district earns — the sea is not jewellery. It is ground, and
# ground is allowed to be a real blue-green at scale. Everything else here runs
# cooler and wetter than the çarşı's plaster and timber, which is the whole
# reason for coming down the hill.
#
# One thing this street deliberately does NOT have: the netted sky. Over water
# there is nothing overhead, and after four cables-and-laundry plates the
# absence should read as a change of pressure, the way the han does.
#
# Reputation region id: "karakoy" (already declared in GameState.CITY_REGIONS).
# Ground bands are Berlin's, London's and the çarşı's, untouched, so the player,
# the exits and the collision boxes behave identically.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── The sea. New, and the only place in the game saturation is allowed at size ─
const C_SEA       := Color(0.145, 0.361, 0.396)   # the body of the water, morning
const C_SEA_DEEP  := Color(0.086, 0.196, 0.259)   # the same water at dusk, and the deep lane
const C_SEA_LIT   := Color(0.271, 0.522, 0.518)   # the pale band at the horizon
const C_SEA_FOAM  := Color(0.780, 0.831, 0.816)   # chop, wake, the lap against the stone
const C_HAZE_SEA  := Color(0.541, 0.596, 0.612)   # the far shore, flattened by four kilometres

# ── Stone, iron, rope — a working quay ────────────────────────────────────────
const C_QUAY      := Color(0.545, 0.529, 0.494)   # granite coping and setts
const C_QUAY_WET  := Color(0.353, 0.365, 0.361)   # the course the tide keeps dark
const C_IRON      := Color(0.180, 0.176, 0.169)   # bollards, pipe rail, tram rail
const C_ROPE      := Color(0.639, 0.573, 0.435)   # mooring line, hawser, chandler's stock

# ── Karaköy is not Balat. Cut stone banking houses, not painted timber ────────
const C_STONE     := Color(0.647, 0.612, 0.541)   # the frontage run at the toe of the hill
const C_STONE_DK  := Color(0.478, 0.451, 0.400)   # rustication joints, window reveals
const C_STONE_LT  := Color(0.784, 0.749, 0.667)   # cornice, sill, sun on the top course

# ── Carried over from docs/design/istanbul.md so it stays the same city ───────
const C_SHADOW    := Color(0.165, 0.122, 0.094)   # inside the ferry hall, under the canopy
const C_TIMB_DK   := Color(0.290, 0.212, 0.149)   # crates, the chandler's bench
const C_PLASTER   := Color(0.541, 0.435, 0.306)   # the ferry hall's walls, repaired often
const C_TERRA     := Color(0.710, 0.337, 0.235)   # a scrap of pantile, simit, the griddle
const C_PALEBLUE  := Color(0.353, 0.478, 0.549)   # fish crates, a bucket
const C_CONCRETE  := Color(0.494, 0.478, 0.443)   # the hill behind, yap-sat all the way up
const C_ALU       := Color(0.643, 0.651, 0.647)   # canopy edge, turnstiles, trolley
const C_SIGNBOX   := Color(0.902, 0.878, 0.824)   # backlit fascia, always too bright
const C_GLASS_M   := Color(0.239, 0.290, 0.310)   # unlit glazing
const C_ASPHALT   := Color(0.192, 0.188, 0.192)   # the tram road
const C_CABLE     := Color(0.239, 0.227, 0.204)   # ironwork, wheels, a flat cap

# İznik. Ceramic, tile, glass and the eye. Nothing else.
const C_COBALT    := Color(0.110, 0.224, 0.659)
const C_TURQ      := Color(0.184, 0.643, 0.627)
const C_BOLE      := Color(0.784, 0.271, 0.227)
const C_TILE_W    := Color(0.941, 0.925, 0.878)

# The boats
const C_HULL      := Color(0.882, 0.878, 0.859)   # vapur white, and never clean
const C_HULL_DK   := Color(0.129, 0.133, 0.145)   # the band at the waterline, the funnel top
const C_FUNNEL    := Color(0.780, 0.635, 0.318)   # Şehir Hatları ochre
const C_SMOKE     := Color(0.290, 0.294, 0.310)   # what the funnel leaves behind
const C_GULL      := Color(0.925, 0.929, 0.918)   # two strokes, at this range

# Shared with every other street so exits and collision stay true
const PAVE_TOP := 292.0
const ROAD_TOP := 372.0
const PAVE_BOT := 516.0

# The water's own bands. The coping lands exactly on PAVE_TOP so the stone and
# the walkable band are the same edge and there is no seam to fall into.
const SEA_TOP  := 76.0
const QUAY_TOP := 268.0

# Frontage: [x, width, roof_y, stone tone]. Index 0 is the ferry hall and is
# drawn differently — it stands in the water, so it is kept low and the sea
# shows over its roof. The rest step UP as x increases, because the hill does.
const _FRONT := [
	[-70, 268, 136, 0], [498, 196, 144, 1], [678, 176, 112, 2],
	[840, 178, 84, 1], [1000, 190, 50, 3],
]

# Hoisted out of the draw calls. Inference on a subscript has broken this
# project before, and a named const reads better at the call site anyway.
const BOLLARDS     := [222.0, 292.0, 362.0, 434.0]
const ANGLERS      := [248.0, 318.0, 388.0, 462.0]
const ANGLER_COATS := [
	Color(0.290, 0.310, 0.302), Color(0.376, 0.325, 0.271),
	Color(0.243, 0.290, 0.341),
]
const RAIL_YS   := [406.0, 430.0, 470.0, 494.0]   # two tracks, four rails
const _FERRIES  := [[98.0, 0.62, 15.0], [142.0, 0.88, -11.0], [200.0, 1.18, 22.0]]
const _SLOPE    := [
	[366.0, 292.0, 470.0, 192.0], [470.0, 192.0, 700.0, 122.0],
	[700.0, 122.0, 920.0, 58.0], [920.0, 58.0, 1160.0, 18.0],
]
const _DOMES := [110.0, 268.0, 486.0, 690.0, 902.0]

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
	_draw_far_shore()
	_draw_sea()
	_draw_ferries()
	_draw_gulls()
	_draw_fish_boat(330.0)
	_draw_sea_wall()
	_draw_galata()
	_draw_frontage()
	_draw_doors(236.0, PAVE_TOP, C_SIGNBOX, Color(0.129, 0.106, 0.086), C_TURQ, C_GLASS_M)
	_draw_ground()
	_draw_quay_edge()
	_draw_quay_clutter()
	_draw_anglers()
	_draw_simit_cart(538.0, 268.0)
	_draw_simit_cart(206.0, 508.0)


# What blocks you. The frontage run is belt-and-braces behind WorldBorder's
# wall_top; the quay furniture is the real work. A footprint has to reach below
# y=300 or the player walks straight through it, because that is where the
# walkable band starts. The pipe rail gets none — the border already holds that
# line — and the cats get none, because a cat moves when you get close and
# nothing else on this quay does.
func solids() -> Array:
	var out: Array = []
	for i in range(_FRONT.size()):
		var f: Array = _FRONT[i]
		out.append(Rect2(float(f[0]) + 8.0, PAVE_TOP - 26.0, float(f[1]) - 16.0, 32.0))
	for i in range(BOLLARDS.size()):
		var bx: float = float(BOLLARDS[i])
		out.append(Rect2(bx - 16.0, 286.0, 32.0, 26.0))
	out.append(Rect2(534.0, 272.0, 96.0, 46.0))     # simit cart, outside the tünel
	out.append(Rect2(202.0, 512.0, 96.0, 46.0))     # the other cart, near side
	out.append(Rect2(696.0, 294.0, 100.0, 36.0))    # fish crates outside the pazarı
	out.append(Rect2(394.0, 296.0, 54.0, 30.0))     # the coil of hawser
	out.append(Rect2(864.0, 296.0, 80.0, 34.0))     # chandler's stock on the pavement
	out.append(Rect2(638.0, 526.0, 82.0, 38.0))     # the çaycı's trolley
	return out


# ══ Water ═════════════════════════════════════════════════════════════════════

func _draw_sky() -> void:
	var morning: bool = GameState.is_morning()
	if morning:
		draw_rect(Rect2(0, 0, VW, SEA_TOP), Color(0.647, 0.706, 0.729))
		draw_rect(Rect2(0, 26, VW, 50), Color(0.769, 0.792, 0.784))
	else:
		draw_rect(Rect2(0, 0, VW, SEA_TOP), Color(0.169, 0.153, 0.212))
		draw_rect(Rect2(0, 32, VW, 44), Color(0.451, 0.294, 0.267))


# The other side. Eminönü, and it is one value — four kilometres of air does
# that. Domes and needles are in it because the city has them, not to announce
# anything; nobody on this quay looks up at them.
func _draw_far_shore() -> void:
	var morning: bool = GameState.is_morning()
	var far: Color = C_HAZE_SEA if morning else C_HAZE_SEA.darkened(0.55)
	draw_rect(Rect2(0, SEA_TOP - 20.0, VW, 20.0), far)
	for b in range(17):
		var bx: float = -24.0 + float(b) * 72.0
		var bh: float = 9.0 + float((b * 7) % 5) * 3.0
		draw_rect(Rect2(bx, SEA_TOP - 20.0 - bh, 64.0, bh + 20.0), far.darkened(0.05))
	for i in range(_DOMES.size()):
		var x: float = float(_DOMES[i])
		var r: float = 13.0 + float(i % 3) * 5.0
		draw_rect(Rect2(x - r - 10.0, SEA_TOP - 54.0, 3.0, 54.0), far)
		draw_rect(Rect2(x + r + 8.0, SEA_TOP - 47.0, 3.0, 47.0), far)
		draw_circle(Vector2(x, SEA_TOP - 20.0), r, far.lightened(0.07))
		draw_rect(Rect2(x - r, SEA_TOP - 20.0, r * 2.0, 20.0), far.lightened(0.07))


func _draw_sea() -> void:
	var morning: bool = GameState.is_morning()
	var body: Color = C_SEA if morning else C_SEA_DEEP
	var band: Color = C_SEA_LIT if morning else C_SEA.darkened(0.34)
	draw_rect(Rect2(-EXT, SEA_TOP, VW + EXT * 2.0, QUAY_TOP - SEA_TOP), body)
	draw_rect(Rect2(-EXT, SEA_TOP, VW + EXT * 2.0, 22.0), band)
	draw_rect(Rect2(-EXT, QUAY_TOP - 30.0, VW + EXT * 2.0, 30.0), body.darkened(0.20))
	# Chop. Horizontal marks only — a vertical stroke on water reads as a post.
	# Squared distance so it crowds toward the horizon the way real chop does.
	for i in range(150):
		var u: float = float((i * 137) % 1000) / 1000.0
		var v: float = float((i * 61) % 1000) / 1000.0
		var y: float = SEA_TOP + 10.0 + v * v * (QUAY_TOP - SEA_TOP - 24.0)
		var drift: float = fmod(u * VW + _t * (6.0 + v * 15.0), VW + 60.0) - 30.0
		draw_rect(Rect2(drift, y, 5.0 + v * 17.0, 1.0 + v),
			Color(C_SEA_FOAM.r, C_SEA_FOAM.g, C_SEA_FOAM.b, 0.09 + 0.11 * v))
	if not morning:
		_draw_glitter()


# At dusk the sun lays a broken lane across the water. It is the only warm thing
# on the sea, and it is how the district stays cooler than the çarşı without
# going cold.
func _draw_glitter() -> void:
	for i in range(72):
		var v: float = float((i * 53) % 1000) / 1000.0
		var y: float = SEA_TOP + 14.0 + v * (QUAY_TOP - SEA_TOP - 28.0)
		var spread: float = 24.0 + v * 156.0
		var x: float = 846.0 - v * 130.0 + sin(float(i) * 2.7 + _t * 0.6) * spread
		draw_rect(Rect2(x, y, 7.0 + v * 10.0, 1.6),
			Color(0.98, 0.78, 0.46, 0.09 + 0.22 * (1.0 - v)))


# Vapur. Squat, white, a black band at the waterline, one ochre funnel, and
# always more gulls behind than in front. Three at three distances, because
# there is never only one boat on the Bosphorus.
func _draw_ferries() -> void:
	for i in range(_FERRIES.size()):
		var f: Array = _FERRIES[i]
		var y: float = float(f[0])
		var s: float = float(f[1])
		var v: float = float(f[2])
		var p: float = fmod(_t * absf(v) + float(i) * 370.0, VW + 460.0)
		var x: float = p - 230.0
		if v < 0.0:
			x = VW + 230.0 - p
		_draw_ferry(x, y, s, v > 0.0)


func _draw_ferry(x: float, y: float, s: float, right: bool) -> void:
	var hh: float = 17.0 * s
	var bow: float = 59.0 * s
	var dir_sign: float = 1.0 if right else -1.0
	var nose: float = bow * dir_sign
	var tail: float = -nose
	draw_colored_polygon(PackedVector2Array([
		Vector2(x + tail, y - hh * 0.55), Vector2(x + nose * 0.80, y - hh),
		Vector2(x + nose, y - hh * 0.30), Vector2(x + nose * 0.92, y + hh * 0.5),
		Vector2(x + tail * 0.95, y + hh * 0.5),
	]), C_HULL)
	draw_rect(Rect2(x - bow * 0.94, y + hh * 0.08, bow * 1.88, hh * 0.44), C_HULL_DK)
	# Two decks of superstructure, set back from the bow
	var sw: float = 74.0 * s
	draw_rect(Rect2(x - sw * 0.5, y - hh - 13.0 * s, sw, 13.0 * s), C_HULL.darkened(0.06))
	draw_rect(Rect2(x - sw * 0.42, y - hh - 24.0 * s, sw * 0.84, 11.0 * s), C_HULL)
	# Windows. Lit at dusk, and then they are the only warm thing on the water.
	var pane: Color = C_GLASS_M
	if not GameState.is_morning():
		pane = Color(0.98, 0.86, 0.58, 0.90)
	var count: int = int(maxf(sw / (9.0 * s), 3.0))
	for i in range(count):
		draw_rect(Rect2(x - sw * 0.5 + 3.0 * s + float(i) * 9.0 * s,
			y - hh - 10.0 * s, 5.0 * s, 6.0 * s), pane)
	draw_rect(Rect2(x - 4.5 * s, y - hh - 42.0 * s, 9.0 * s, 20.0 * s), C_FUNNEL)
	draw_rect(Rect2(x - 4.5 * s, y - hh - 42.0 * s, 9.0 * s, 6.0 * s), C_HULL_DK)
	draw_rect(Rect2(x + sw * 0.36, y - hh - 40.0 * s, 2.0 * s, 18.0 * s), C_HULL_DK)
	for p in range(4):
		var pf: float = float(p)
		draw_circle(Vector2(x - dir_sign * pf * 13.0 * s, y - hh - 46.0 * s - pf * 7.0 * s),
			5.0 * s + pf * 2.0 * s, Color(C_SMOKE.r, C_SMOKE.g, C_SMOKE.b, 0.15 - pf * 0.033))
	_draw_wake(x + tail, y + hh * 0.42, bow * 2.0, right)


# A hull with no wake sits on the water like a sticker.
func _draw_wake(x: float, y: float, w: float, right: bool) -> void:
	var dir_sign: float = -1.0 if right else 1.0
	for i in range(5):
		var f: float = float(i)
		draw_rect(Rect2(x + dir_sign * (9.0 + f * w * 0.30), y + f * 1.5, w * 0.30, 1.9),
			Color(C_SEA_FOAM.r, C_SEA_FOAM.g, C_SEA_FOAM.b, 0.30 - f * 0.05))


# Gulls follow the boats because people throw simit off the stern. Wings only —
# at this range a gull is two strokes and nothing more, and drawing a beak on it
# would make it a duck.
func _draw_gulls() -> void:
	for i in range(22):
		var fi: float = float(i)
		var x: float = fmod(fi * 97.0 + _t * (10.0 + fi * 1.3), VW + 80.0) - 40.0
		var y: float = 34.0 + float((i * 37) % 148) + sin(_t * (1.0 + fi * 0.28) + fi) * 11.0
		if y > QUAY_TOP - 34.0:
			continue
		var beat: float = sin(_t * 7.0 + fi * 1.9) * 3.0
		var sp: float = 5.0 + float(i % 3) * 2.0
		draw_line(Vector2(x - sp, y - beat), Vector2(x, y), C_GULL, 1.7)
		draw_line(Vector2(x, y), Vector2(x + sp, y - beat), C_GULL, 1.7)


# Where the water stops being water. Cut granite, a course the tide keeps dark,
# and a green line at the exact height the sea reaches twice a day.
func _draw_sea_wall() -> void:
	draw_rect(Rect2(-EXT, QUAY_TOP, VW + EXT * 2.0, 9.0), C_QUAY_WET)
	draw_rect(Rect2(-EXT, QUAY_TOP + 9.0, VW + EXT * 2.0, 15.0), C_QUAY)
	draw_rect(Rect2(-EXT, QUAY_TOP + 9.0, VW + EXT * 2.0, 3.0), C_QUAY.lightened(0.22))
	for i in range(26):
		var jx: float = -20.0 + float(i) * 48.0
		draw_rect(Rect2(jx, QUAY_TOP + 9.0, 1.5, 15.0), Color(0, 0, 0, 0.20))
		draw_rect(Rect2(jx + 6.0, QUAY_TOP + 1.0, 34.0, 4.0), Color(0.239, 0.353, 0.278, 0.34))
	for i in range(20):
		var lx: float = float(i) * 62.0 + sin(_t * 1.1 + float(i)) * 7.0
		draw_rect(Rect2(lx, QUAY_TOP - 3.0, 30.0, 3.0),
			Color(C_SEA_FOAM.r, C_SEA_FOAM.g, C_SEA_FOAM.b, 0.26))


# ══ Land ══════════════════════════════════════════════════════════════════════

# The hill. The reason this reads as a shore and not a street is that the city
# visibly leaves the water and goes up. The tower is on it because it is on it —
# no glow, no sunset behind it, half-hidden by roofs.
func _draw_galata() -> void:
	var slope: Color = C_CONCRETE.darkened(0.12)
	if not GameState.is_morning():
		slope = C_CONCRETE.darkened(0.54)
	for i in range(_SLOPE.size()):
		var s: Array = _SLOPE[i]
		draw_colored_polygon(PackedVector2Array([
			Vector2(float(s[0]), float(s[1])), Vector2(float(s[2]), float(s[3])),
			Vector2(float(s[2]), PAVE_TOP), Vector2(float(s[0]), PAVE_TOP),
		]), slope)
	# Houses on the slope: all roof and no detail at this range, stepping upward
	for i in range(30):
		var fi: float = float(i)
		var hx: float = 428.0 + fi * 25.0
		var hy: float = 198.0 - fi * 5.6 + float((i * 13) % 4) * 9.0
		draw_rect(Rect2(hx, hy, 24.0, 32.0), slope.lightened(0.11))
		draw_rect(Rect2(hx - 3.0, hy - 5.0, 30.0, 6.0), C_TERRA.darkened(0.36))
	_draw_tower(1006.0, 28.0, slope)


func _draw_tower(x: float, y: float, base: Color) -> void:
	var body: Color = base.lightened(0.17)
	draw_rect(Rect2(x - 21.0, y + 16.0, 42.0, 100.0), body)
	draw_rect(Rect2(x - 21.0, y + 16.0, 7.0, 100.0), body.lightened(0.10))
	draw_rect(Rect2(x + 14.0, y + 16.0, 7.0, 100.0), body.darkened(0.15))
	draw_rect(Rect2(x - 26.0, y + 9.0, 52.0, 8.0), body.lightened(0.06))   # the gallery
	for i in range(7):
		draw_rect(Rect2(x - 22.0 + float(i) * 6.5, y + 1.0, 3.0, 9.0), C_CABLE)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, y - 30.0), Vector2(x + 20.0, y + 3.0), Vector2(x - 20.0, y + 3.0),
	]), C_CABLE.lightened(0.12))
	for i in range(3):
		draw_rect(Rect2(x - 13.0 + float(i) * 12.0, y + 44.0, 8.0, 17.0), C_SHADOW)


func _draw_frontage() -> void:
	for i in range(_FRONT.size()):
		var f: Array = _FRONT[i]
		var x: float = float(f[0])
		var w: float = float(f[1])
		var roof: float = float(f[2])
		if i == 0:
			_draw_ferry_hall(x, w, roof)
		else:
			_draw_stone_block(x, w, roof, int(f[3]), i)


# The iskele. A low hall standing in the water on piles, with a wide iron canopy
# over the gangways so a thousand people an hour can queue out of the rain. Kept
# low on purpose: the sea shows over its roof, and that is the sea-level read.
func _draw_ferry_hall(x: float, w: float, roof: float) -> void:
	draw_rect(Rect2(x, roof + 20.0, w, PAVE_TOP - roof - 20.0), C_PLASTER)
	draw_rect(Rect2(x, roof + 20.0, w, 6.0), C_SHADOW)
	draw_rect(Rect2(x - 10.0, roof, w + 20.0, 20.0), C_CABLE)
	draw_rect(Rect2(x - 10.0, roof, w + 20.0, 4.0), C_ALU)
	draw_rect(Rect2(x - 10.0, roof + 20.0, w + 20.0, 7.0), Color(0, 0, 0, 0.30))
	for i in range(6):
		draw_rect(Rect2(x + 12.0 + float(i) * (w / 6.0), roof + 27.0, 6.0,
			PAVE_TOP - roof - 27.0), C_CABLE)
	# The turnstile row behind glass, and the clock nobody sets
	draw_rect(Rect2(x + 16.0, roof + 46.0, w - 32.0, 54.0), C_GLASS_M)
	for i in range(7):
		draw_rect(Rect2(x + 24.0 + float(i) * 30.0, roof + 62.0, 12.0, 36.0), C_ALU)
	draw_circle(Vector2(x + w * 0.5, roof + 9.0), 11.0, C_TILE_W)
	draw_circle(Vector2(x + w * 0.5, roof + 9.0), 9.0, C_SHADOW)
	draw_rect(Rect2(x + w * 0.5 - 1.0, roof + 2.0, 2.0, 8.0), C_TILE_W)
	# The tiled panel by the door — the only saturation on the whole building
	for i in range(6):
		draw_rect(Rect2(x + 208.0 + float(i % 3) * 16.0,
			roof + 112.0 + float(i / 3) * 16.0, 15.0, 15.0),
			C_COBALT if i % 3 != 1 else C_TURQ)


# Karaköy is not Balat. These are late-Ottoman banking houses in cut stone —
# rusticated at the bottom, arched windows above, a cornice that overhangs, and
# plastic signage screwed straight into the masonry. The stone is why the
# district reads cooler than the çarşı's plaster and timber.
func _draw_stone_block(x: float, w: float, roof: float, tone: int, seed_i: int) -> void:
	var wall: Color = _stone_tone(tone)
	draw_rect(Rect2(x, roof, w, PAVE_TOP - roof), wall)
	draw_rect(Rect2(x, roof, w, 5.0), C_TERRA.darkened(0.24))
	draw_rect(Rect2(x - 6.0, roof + 5.0, w + 12.0, 11.0), C_STONE_LT)
	draw_rect(Rect2(x - 6.0, roof + 16.0, w + 12.0, 5.0), Color(0, 0, 0, 0.24))
	draw_rect(Rect2(x, roof, 10.0, PAVE_TOP - roof), Color(1, 1, 1, 0.06))
	draw_rect(Rect2(x + w - 12.0, roof, 12.0, PAVE_TOP - roof), Color(0, 0, 0, 0.16))
	var storeys: int = int((PAVE_TOP - roof - 46.0) / 46.0)
	for s in range(storeys):
		var wy: float = roof + 30.0 + float(s) * 46.0
		draw_rect(Rect2(x + 4.0, wy + 40.0, w - 8.0, 4.0), C_STONE_LT.darkened(0.10))
		for c in range(3):
			_draw_arched_window(x + 18.0 + float(c) * ((w - 62.0) * 0.5), wy,
				seed_i * 5 + s * 3 + c)
	# Rustication on the bottom course: deep joints, the banking-house tell
	for r in range(3):
		draw_rect(Rect2(x, PAVE_TOP - 34.0 + float(r) * 11.0, w, 2.0), C_STONE_DK)


func _draw_arched_window(x: float, y: float, seed_i: int) -> void:
	draw_rect(Rect2(x, y + 8.0, 26.0, 28.0), C_STONE_DK)
	draw_circle(Vector2(x + 13.0, y + 10.0), 13.0, C_STONE_DK)
	var pane: Color = C_GLASS_M
	if ((seed_i * 41) % 5) < 2:
		pane = Color(0.97, 0.85, 0.58, 0.88)
	draw_rect(Rect2(x + 3.0, y + 10.0, 20.0, 24.0), pane)
	draw_circle(Vector2(x + 13.0, y + 11.0), 10.0, pane)
	draw_rect(Rect2(x + 12.0, y + 2.0, 2.0, 32.0), C_STONE_LT)
	draw_rect(Rect2(x - 3.0, y + 36.0, 32.0, 4.0), C_STONE_LT)


func _stone_tone(i: int) -> Color:
	# Cut stone weathers to four or five values on one street, never to one.
	match i % 4:
		0: return C_STONE
		1: return C_STONE.darkened(0.09)
		2: return C_PLASTER.lightened(0.12)
		_: return C_STONE_LT.darkened(0.14)


# ══ Ground ════════════════════════════════════════════════════════════════════

# Setts on the quay, asphalt with tram rail let into it, pavement again on the
# near side. Wetter than the çarşı everywhere, because this is a surface the sea
# gets onto twice a day and nobody has ever dried it.
func _draw_ground() -> void:
	draw_rect(Rect2(0, PAVE_TOP, VW, ROAD_TOP - PAVE_TOP), C_QUAY.darkened(0.26))
	_draw_setts(PAVE_TOP, ROAD_TOP - PAVE_TOP)
	draw_rect(Rect2(0, ROAD_TOP - 9.0, VW, 9.0), C_QUAY)
	draw_rect(Rect2(0, ROAD_TOP - 9.0, VW, 2.0), C_QUAY.lightened(0.24))
	draw_rect(Rect2(0, ROAD_TOP, VW, PAVE_BOT - ROAD_TOP), C_ASPHALT.lightened(0.05))
	_draw_tram_rails()
	draw_rect(Rect2(0, PAVE_BOT, VW, VH - PAVE_BOT), C_QUAY.darkened(0.32))
	draw_rect(Rect2(0, PAVE_BOT, VW, 8.0), C_QUAY.darkened(0.12))
	_draw_setts(PAVE_BOT + 8.0, VH - PAVE_BOT - 8.0)
	# Standing water. It never fully dries here and the light knows it.
	var pulse: float = 0.5 + 0.5 * sin(_t * 0.45)
	for i in range(6):
		var px: float = 60.0 + float(i) * 196.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(px, ROAD_TOP + 24.0), Vector2(px + 66.0, ROAD_TOP + 20.0),
			Vector2(px + 40.0, PAVE_BOT - 8.0), Vector2(px - 40.0, PAVE_BOT - 4.0),
		]), Color(0.60, 0.72, 0.74, 0.04 + 0.03 * pulse))


func _draw_setts(top: float, height: float) -> void:
	var line: Color = Color(0, 0, 0, 0.16)
	var rows: int = int(height / 22.0) + 1
	for r in range(rows):
		var y: float = top + float(r) * 22.0
		draw_rect(Rect2(0, y, VW, 1.0), line)
		var offset: float = 0.0 if r % 2 == 0 else 15.0
		var cols: int = int(VW / 30.0) + 1
		for c in range(cols):
			draw_rect(Rect2(offset + float(c) * 30.0, y, 1.0, 22.0), line)


# The tram runs along the water here, and the rail is set flush into the road, so
# the only sign of it is two bright lines and the groove beside each one. No
# catenary drawn: over water there is nothing overhead, which is the point.
func _draw_tram_rails() -> void:
	for i in range(RAIL_YS.size()):
		var y: float = float(RAIL_YS[i])
		draw_rect(Rect2(0, y - 4.0, VW, 4.0), C_ASPHALT.darkened(0.40))
		draw_rect(Rect2(0, y, VW, 3.0), C_ALU.darkened(0.20))
		draw_rect(Rect2(0, y, VW, 1.0), C_ALU.lightened(0.30))
	var y0: float = float(RAIL_YS[0])
	var y2: float = float(RAIL_YS[2])
	for s in range(24):
		var sx: float = -10.0 + float(s) * 50.0
		draw_rect(Rect2(sx, y0 - 6.0, 34.0, 42.0), Color(0, 0, 0, 0.05))
		draw_rect(Rect2(sx + 18.0, y2 - 6.0, 34.0, 42.0), Color(0, 0, 0, 0.05))


# ══ The quay itself ═══════════════════════════════════════════════════════════

# Iron bollards, a rope slung between them, and the pipe rail that half the
# district leans on all day. The rail stops where the frontage starts, because
# that is where the water stops.
func _draw_quay_edge() -> void:
	draw_rect(Rect2(192.0, 246.0, 302.0, 4.0), C_IRON.lightened(0.16))
	draw_rect(Rect2(192.0, 264.0, 302.0, 3.0), C_IRON)
	for i in range(9):
		draw_rect(Rect2(198.0 + float(i) * 36.0, 246.0, 4.0, 46.0), C_IRON)
	for i in range(BOLLARDS.size()):
		_draw_bollard(float(BOLLARDS[i]))
	for i in range(BOLLARDS.size() - 1):
		var a: float = float(BOLLARDS[i])
		var b: float = float(BOLLARDS[i + 1])
		_draw_sagging(a, 266.0, b, 266.0, 13.0, C_ROPE)
	# A coil of hawser somebody will trip over, and it has a solid for that
	for i in range(4):
		draw_circle(Vector2(420.0, 308.0), 26.0 - float(i) * 6.0,
			C_ROPE.darkened(0.09 * float(i % 2)))


# A cast-iron mushroom on a stone plinth. The plinth is drawn down to y=312 so
# the art and the collision box agree about where the thing stands.
func _draw_bollard(x: float) -> void:
	draw_rect(Rect2(x - 16.0, 294.0, 32.0, 18.0), C_QUAY.darkened(0.14))
	draw_rect(Rect2(x - 16.0, 294.0, 32.0, 3.0), C_QUAY.lightened(0.16))
	draw_rect(Rect2(x - 10.0, 258.0, 20.0, 38.0), C_IRON)
	draw_rect(Rect2(x - 10.0, 258.0, 5.0, 38.0), C_IRON.lightened(0.22))
	draw_circle(Vector2(x, 258.0), 13.0, C_IRON.lightened(0.08))
	draw_circle(Vector2(x, 255.0), 11.0, C_IRON.lightened(0.20))


func _draw_sagging(x0: float, y0: float, x1: float, y1: float,
		sag: float, col: Color) -> void:
	var steps: int = 18
	var prev: Vector2 = Vector2(x0, y0)
	for s in range(1, steps + 1):
		var u: float = float(s) / float(steps)
		var p: Vector2 = Vector2(lerpf(x0, x1, u), lerpf(y0, y1, u) + sin(u * PI) * sag)
		draw_line(prev, p, col, 2.4)
		prev = p


# The balık-ekmek boat. Moored against the wall, high in the bow, a griddle
# amidships, and it never stops moving because the wall does not stop the swell.
# You eat standing on stone while the man cooking is three feet below you and
# rising and falling, and that height difference is the entire transaction.
func _draw_fish_boat(x: float) -> void:
	var roll: float = sin(_t * 1.35) * 3.4
	var y: float = 270.0 + sin(_t * 1.35 + 0.7) * 2.2
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 66.0, y - 6.0 - roll), Vector2(x + 62.0, y - 10.0 + roll),
		Vector2(x + 70.0, y - 22.0 + roll), Vector2(x - 74.0, y - 16.0 - roll),
	]), C_HULL.darkened(0.07))
	draw_rect(Rect2(x - 74.0, y - 17.0 - roll, 144.0, 5.0), C_BOLE)
	for i in range(4):
		draw_rect(Rect2(x - 58.0 + float(i) * 38.0, y - 76.0 + roll * 0.4, 4.0, 58.0), C_ALU)
	draw_rect(Rect2(x - 72.0, y - 86.0 + roll * 0.4, 148.0, 10.0), C_BOLE.darkened(0.15))
	draw_rect(Rect2(x - 72.0, y - 76.0 + roll * 0.4, 148.0, 5.0), C_TILE_W)
	# The griddle, and the smoke that does the real advertising
	draw_rect(Rect2(x - 26.0, y - 40.0, 56.0, 12.0), C_IRON)
	for i in range(5):
		draw_circle(Vector2(x - 16.0 + float(i) * 12.0, y - 44.0), 5.0, C_TERRA.lightened(0.16))
	for p in range(5):
		var pf: float = float(p)
		draw_circle(Vector2(x + 2.0 + sin(_t * 0.9 + pf) * 9.0, y - 52.0 - pf * 13.0),
			7.0 + pf * 3.0, Color(0.86, 0.86, 0.84, 0.11 - pf * 0.018))
	# A nazar on the canopy post, because every working boat has one
	draw_circle(Vector2(x + 54.0, y - 62.0), 7.0, C_COBALT)
	draw_circle(Vector2(x + 54.0, y - 62.0), 4.0, C_TILE_W)
	draw_circle(Vector2(x + 54.0, y - 62.0), 2.0, C_TURQ)
	draw_line(Vector2(x - 74.0, y - 14.0), Vector2(224.0, 266.0), C_ROPE, 2.0)
	draw_circle(Vector2(x - 80.0, y - 9.0), 12.0, C_IRON.darkened(0.22))


# Men fishing off the wall. Not a metaphor and not a crowd — four of them,
# spaced the way men who have been there since six space themselves, rods out
# over the water and a bucket each. They are scenery: they do not turn round.
func _draw_anglers() -> void:
	for i in range(ANGLERS.size()):
		_draw_angler(float(ANGLERS[i]), i)


func _draw_angler(x: float, seed_i: int) -> void:
	var coat: Color = ANGLER_COATS[seed_i % ANGLER_COATS.size()]
	var sway: float = sin(_t * 0.5 + float(seed_i) * 1.7) * 1.4
	draw_rect(Rect2(x - 9.0, 258.0, 7.0, 44.0), C_CABLE.darkened(0.10))
	draw_rect(Rect2(x + 2.0, 258.0, 7.0, 44.0), C_CABLE.darkened(0.10))
	draw_rect(Rect2(x - 11.0 + sway, 224.0, 22.0, 38.0), coat)
	draw_rect(Rect2(x - 11.0 + sway, 224.0, 6.0, 38.0), coat.lightened(0.15))
	draw_circle(Vector2(x + sway, 216.0), 8.0, Color(0.706, 0.573, 0.451))
	draw_rect(Rect2(x - 10.0 + sway, 208.0, 20.0, 5.0), C_CABLE)
	# The rod goes out over the water, which is the only reason he is standing here
	var tip: Vector2 = Vector2(x - 98.0, 148.0 + sin(_t * 0.6 + float(seed_i)) * 5.0)
	draw_line(Vector2(x + 7.0 + sway, 232.0), tip, C_ROPE.darkened(0.20), 1.6)
	draw_line(tip, Vector2(tip.x - 5.0, 252.0), Color(0.86, 0.88, 0.86, 0.40), 1.0)
	# A bucket, and it is not empty
	draw_rect(Rect2(x + 15.0, 276.0, 20.0, 22.0), C_PALEBLUE.darkened(0.14))
	draw_rect(Rect2(x + 17.0, 278.0, 16.0, 5.0), C_SEA_FOAM.darkened(0.22))


# Glass box on three wheels, a red frame, and the rings stacked so you can see
# how many are left. There is one wherever people have to stop and wait, which
# on a quay is everywhere.
func _draw_simit_cart(x: float, y: float) -> void:
	draw_rect(Rect2(x - 4.0, y + 44.0, 96.0, 8.0), Color(0, 0, 0, 0.22))
	draw_rect(Rect2(x, y, 88.0, 46.0), C_BOLE.darkened(0.20))
	draw_rect(Rect2(x + 5.0, y + 5.0, 78.0, 32.0), Color(0.90, 0.94, 0.94, 0.40))
	for r in range(2):
		for c in range(5):
			var sx: float = x + 14.0 + float(c) * 15.0
			var sy: float = y + 14.0 + float(r) * 15.0
			draw_circle(Vector2(sx, sy), 6.0, C_TERRA.lightened(0.22))
			draw_circle(Vector2(sx, sy), 2.2, Color(0.90, 0.94, 0.94, 0.40))
	draw_rect(Rect2(x, y - 22.0, 88.0, 20.0), C_BOLE)
	draw_rect(Rect2(x + 3.0, y - 19.0, 82.0, 5.0), C_TILE_W)
	draw_circle(Vector2(x + 14.0, y + 50.0), 8.0, C_CABLE)
	draw_circle(Vector2(x + 72.0, y + 50.0), 8.0, C_CABLE)
	draw_rect(Rect2(x + 84.0, y + 8.0, 22.0, 4.0), C_CABLE)


# What a working quay leaves lying about. Every one of these has a solid, because
# every one of them is ankle height and none of them move.
func _draw_quay_clutter() -> void:
	for i in range(3):
		var cx: float = 700.0 + float(i) * 32.0
		var cy: float = 296.0 - float(i % 2) * 6.0
		draw_rect(Rect2(cx, cy, 28.0, 34.0), C_PALEBLUE.lightened(0.26))
		draw_rect(Rect2(cx + 2.0, cy + 2.0, 24.0, 8.0), C_SEA_FOAM)
		for f in range(3):
			draw_rect(Rect2(cx + 3.0 + float(f) * 8.0, cy + 4.0, 6.0, 4.0),
				C_ALU.lightened(0.22))
	draw_rect(Rect2(694.0, 328.0, 106.0, 4.0), Color(0.72, 0.82, 0.84, 0.28))
	# The chandler's stock, out on the pavement because the shop is full of it
	draw_rect(Rect2(864.0, 300.0, 80.0, 28.0), C_TIMB_DK)
	for i in range(3):
		draw_circle(Vector2(880.0 + float(i) * 24.0, 302.0), 11.0, C_ROPE)
		draw_circle(Vector2(880.0 + float(i) * 24.0, 302.0), 5.0, C_TIMB_DK)
	# The rack the fenders hang off. It was one upright with a crossbar ten
	# pixels under the top of it, which at this size is not a chandler's
	# display - it is a crucifix, standing on a quay in Istanbul. An A-frame
	# with a top rail does the same job and cannot be read as anything else.
	draw_rect(Rect2(930.0, 268.0, 40.0, 5.0), C_IRON)          # top rail
	draw_colored_polygon(PackedVector2Array([                   # left leg
		Vector2(934.0, 271.0), Vector2(938.0, 271.0),
		Vector2(930.0, 328.0), Vector2(926.0, 328.0),
	]), C_IRON)
	draw_colored_polygon(PackedVector2Array([                   # right leg
		Vector2(962.0, 271.0), Vector2(966.0, 271.0),
		Vector2(974.0, 328.0), Vector2(970.0, 328.0),
	]), C_IRON)
	draw_rect(Rect2(934.0, 300.0, 32.0, 3.0), C_IRON.darkened(0.18))
	# and two fenders slung off the rail, which is what the rack is for
	for i in range(2):
		var fx: float = 940.0 + float(i) * 20.0
		draw_rect(Rect2(fx - 1.0, 273.0, 2.0, 9.0), C_ROPE.darkened(0.24))
		draw_rect(Rect2(fx - 5.0, 282.0, 10.0, 22.0), C_ROPE)
		draw_rect(Rect2(fx - 5.0, 282.0, 3.0, 22.0), C_ROPE.lightened(0.22))
	# The çaycı's trolley, parked between deliveries. The glasses are glass, so
	# they are allowed to be the brightest thing at ground level.
	draw_rect(Rect2(638.0, 526.0, 82.0, 38.0), C_ALU.darkened(0.24))
	draw_rect(Rect2(642.0, 518.0, 74.0, 9.0), C_ALU)
	for i in range(6):
		draw_rect(Rect2(646.0 + float(i) * 12.0, 504.0, 8.0, 15.0), C_BOLE.lightened(0.24))
	draw_circle(Vector2(652.0, 566.0), 7.0, C_CABLE)
	draw_circle(Vector2(708.0, 566.0), 7.0, C_CABLE)


# ══ Cats ══════════════════════════════════════════════════════════════════════
# Copied wholesale from IstanbulStreetBackground.gd, poses and coats intact,
# because a Karaköy cat is the same animal as a çarşı cat and drawing it twice
# two different ways would say otherwise. One of them is on a bollard, which is
# exactly and only where they sit.
#
#   0 — loaf. Paws folded under, tail wrapped round, eyes shut to a line.
#   1 — sitting upright, tail laid out flat, watching you and not caring.


# The three cats of Karakoy, as nodes rather than as paint. See CatArt.
func cats() -> Array:
	return [
		[Vector2(292.0, 252.0), 0, 2],   # on the bollard, where a cat sits
		[Vector2(664.0, 322.0), 1, 0],   # by the fish crates, on the arithmetic
		[Vector2(986.0, 562.0), 0, 1],
	]
