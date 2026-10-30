class_name CityArt
extends Object

# Street primitives, shared by the twelve cities built after Berlin.
#
# Berlin, London and İstanbul each hand-rolled their own kerbs, windows and
# awnings, which is why those three files run five to eight hundred lines. Most
# of that is not the city — it is the same masonry written out again in a
# different colour. This is that masonry, once.
#
# What is deliberately NOT in here: anything that identifies a place. No city
# gets its signature from a shared function. The Hofeinfahrt, the cholet, the
# torii lamp, the barakoni balcony and the pixação all live in the city that
# owns them. This file draws the boring parts so those have room to be good.
#
# Every helper takes the CanvasItem first, matching InteriorArt.
#
# The bands are not negotiable — the player, the exits, the collision boxes and
# the map all read them:
#   sky ends 292 · pavement 292-372 · road 372-516 · far pavement 516-648

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0

const PAVE_TOP := 292.0
const ROAD_TOP := 372.0
const FAR_TOP  := 516.0

const C_VOID := Color(0.043, 0.039, 0.110)


# ── Ground ────────────────────────────────────────────────────────────────────

static func void_fill(ci: CanvasItem) -> void:
	ci.draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2.0, VH + EXT * 2.0), C_VOID)


# The three bands, flat. Texture goes on top of this, never instead of it.
static func ground(ci: CanvasItem, pave: Color, road: Color, far: Color) -> void:
	ci.draw_rect(Rect2(0, PAVE_TOP, VW, ROAD_TOP - PAVE_TOP), pave)
	ci.draw_rect(Rect2(0, ROAD_TOP, VW, FAR_TOP - ROAD_TOP), road)
	ci.draw_rect(Rect2(0, FAR_TOP, VW, VH - FAR_TOP), far)


# The lip between pavement and road. Two lines, and the lower one is always the
# dirty one, because that is where the water sits.
static func kerb(ci: CanvasItem, y: float, stone: Color) -> void:
	ci.draw_rect(Rect2(0, y - 6.0, VW, 6.0), stone)
	ci.draw_rect(Rect2(0, y - 6.0, VW, 2.0), stone.lightened(0.22))
	ci.draw_rect(Rect2(0, y, VW, 3.0), Color(0, 0, 0, 0.28))


# Cubes laid in rows. Rome's sampietrini, Zürich's setts, Karaköy's quay — the
# same operation at three sizes, which is genuinely all that separates them.
static func setts(ci: CanvasItem, top: float, height: float, size: float,
		joint: Color) -> void:
	var rows: int = int(height / size) + 1
	var cols: int = int(VW / size) + 2
	for r in range(rows):
		var y: float = top + float(r) * size
		var off: float = (size * 0.5) if (r % 2) else 0.0
		ci.draw_rect(Rect2(0, y, VW, 1.0), joint)
		for c in range(cols):
			ci.draw_rect(Rect2(float(c) * size + off - size, y, 1.0, size), joint)


# Big rectangular slabs. A grid reads as a floor; a stagger reads as a street.
static func slabs(ci: CanvasItem, top: float, height: float, w: float, h: float,
		joint: Color, stagger: bool = true) -> void:
	var rows: int = int(height / h) + 1
	var cols: int = int(VW / w) + 2
	for r in range(rows):
		var y: float = top + float(r) * h
		var off: float = (w * 0.5) if (stagger and (r % 2)) else 0.0
		ci.draw_rect(Rect2(0, y, VW, 1.2), joint)
		for c in range(cols):
			ci.draw_rect(Rect2(float(c) * w + off - w, y, 1.2, h), joint)


# Wet ground. Not puddles — a sheen, because a puddle you can see the edge of
# reads as a hole in the floor at this resolution.
static func sheen(ci: CanvasItem, top: float, height: float, col: Color,
		t: float) -> void:
	for i in range(5):
		var y: float = top + 8.0 + float(i) * (height / 5.0)
		var a: float = 0.05 + 0.035 * sin(t * 0.6 + float(i) * 1.3)
		ci.draw_rect(Rect2(0, y, VW, 3.0), Color(col.r, col.g, col.b, a))


# ── Sky ───────────────────────────────────────────────────────────────────────

# Four bands, top to bottom. Morning swaps the whole stack rather than
# lightening it, because dawn and midday are different colours, not brightnesses.
static func sky(ci: CanvasItem, zenith: Color, mid: Color, low: Color,
		haze: Color) -> void:
	ci.draw_rect(Rect2(0, 0, VW, PAVE_TOP), zenith)
	ci.draw_rect(Rect2(0, 70, VW, 120), mid)
	ci.draw_rect(Rect2(0, 178, VW, 76), low)
	ci.draw_rect(Rect2(0, 246, VW, PAVE_TOP - 246.0), haze)


# What is behind the street and much further away. One flat mass plus lit
# specks; the specks are what make it read as distance rather than as a wall.
static func far_mass(ci: CanvasItem, top: float, col: Color, lit: Color,
		count: int, seed_i: int = 0) -> void:
	ci.draw_rect(Rect2(0, top, VW, PAVE_TOP - top), col)
	for i in range(count):
		var wx: float = 6.0 + float((i * 97 + seed_i * 13) % int(VW))
		var wy: float = top + 10.0 + float((i * 41 + seed_i * 7) % 5) * 18.0
		ci.draw_rect(Rect2(wx, wy, 6.0, 8.0), lit)


# ── Buildings ─────────────────────────────────────────────────────────────────

# A plain mass with a flat top. Everything else is applied to this.
static func block(ci: CanvasItem, x: float, w: float, top: float,
		ground_y: float, body: Color, shade: Color) -> void:
	ci.draw_rect(Rect2(x, top, w, ground_y - top), body)
	ci.draw_rect(Rect2(x + w - 12.0, top, 12.0, ground_y - top), shade)
	ci.draw_rect(Rect2(x, top, 6.0, ground_y - top), Color(1, 1, 1, 0.05))


# A cornice, a string course, or a floor band — the horizontal that tells you
# how tall a building is. Without one, a wall has no scale at all.
static func band(ci: CanvasItem, x: float, w: float, y: float, h: float,
		col: Color) -> void:
	ci.draw_rect(Rect2(x, y, w, h), col)
	ci.draw_rect(Rect2(x, y, w, 1.5), col.lightened(0.26))
	ci.draw_rect(Rect2(x, y + h - 1.5, w, 1.5), Color(0, 0, 0, 0.22))


# One window. `lit` is decided by the caller so a whole elevation can be lit in
# a pattern rather than at random, which is what makes a block look inhabited.
static func window(ci: CanvasItem, x: float, y: float, w: float, h: float,
		glass: Color, frame: Color, lit: bool) -> void:
	ci.draw_rect(Rect2(x - 1.5, y - 1.5, w + 3.0, h + 3.0), frame)
	ci.draw_rect(Rect2(x, y, w, h), glass if not lit
		else Color(0.98, 0.90, 0.68, 0.92))
	# One mullion and one transom. Two lines is the difference between a
	# window and a dark rectangle.
	ci.draw_rect(Rect2(x + w * 0.5 - 0.6, y, 1.2, h), frame)
	ci.draw_rect(Rect2(x, y + h * 0.42, w, 1.2), frame)


# A row of them, evenly. The pattern of lit ones is the caller's business.
static func window_row(ci: CanvasItem, x: float, w: float, y: float,
		count: int, ww: float, wh: float, glass: Color, frame: Color,
		lit_mask: int) -> void:
	if count <= 0:
		return
	var step: float = w / float(count)
	for i in range(count):
		var wx: float = x + step * (float(i) + 0.5) - ww * 0.5
		window(ci, wx, y, ww, wh, glass, frame, ((lit_mask >> i) & 1) == 1)


# Louvred shutters, folded back against the wall. Rome, Hanoi, Dakar and Mexico
# City all have these and all of them are a different colour.
static func shutters(ci: CanvasItem, x: float, y: float, w: float, h: float,
		col: Color) -> void:
	var leaf: float = 6.0
	for side in [-1.0, 1.0]:
		var lx: float = x - leaf if side < 0.0 else x + w
		ci.draw_rect(Rect2(lx, y, leaf, h), col)
		for i in range(int(h / 4.0)):
			ci.draw_rect(Rect2(lx, y + float(i) * 4.0, leaf, 1.0),
				Color(0, 0, 0, 0.25))


# A shallow balcony on brackets. `solid` gives a stone or masonry front;
# otherwise it is railings, which is most of the world.
static func balcony(ci: CanvasItem, x: float, y: float, w: float,
		rail: Color, solid: bool = false) -> void:
	ci.draw_rect(Rect2(x - 4.0, y + 12.0, w + 8.0, 4.0), rail.darkened(0.30))
	for i in range(3):
		var bx: float = x + 6.0 + float(i) * ((w - 12.0) * 0.5)
		ci.draw_rect(Rect2(bx, y + 16.0, 3.0, 7.0), rail.darkened(0.40))
	if solid:
		ci.draw_rect(Rect2(x - 2.0, y - 4.0, w + 4.0, 17.0), rail)
		ci.draw_rect(Rect2(x - 2.0, y - 4.0, w + 4.0, 2.0), rail.lightened(0.25))
		return
	ci.draw_rect(Rect2(x - 2.0, y - 5.0, w + 4.0, 2.0), rail)
	for i in range(int(w / 7.0)):
		ci.draw_rect(Rect2(x + float(i) * 7.0, y - 4.0, 1.4, 16.0), rail)


# A pitched or hipped roof, seen almost edge-on. Two rects and a ridge.
static func roof(ci: CanvasItem, x: float, w: float, eaves: float,
		height: float, tile: Color) -> void:
	ci.draw_rect(Rect2(x - 4.0, eaves - height, w + 8.0, height), tile)
	ci.draw_rect(Rect2(x - 6.0, eaves - 4.0, w + 12.0, 5.0), tile.darkened(0.22))
	ci.draw_rect(Rect2(x - 4.0, eaves - height, w + 8.0, 2.5), tile.lightened(0.22))
	for i in range(int(w / 9.0)):
		ci.draw_rect(Rect2(x + float(i) * 9.0, eaves - height, 1.0, height),
			Color(0, 0, 0, 0.13))


# ── Street furniture ──────────────────────────────────────────────────────────

# A striped canopy over a shopfront. Two colours, because one is a tarpaulin
# and two is a business.
static func awning(ci: CanvasItem, x: float, y: float, w: float,
		a: Color, b: Color) -> void:
	var stripes: int = maxi(3, int(w / 15.0))
	var sw: float = w / float(stripes)
	for i in range(stripes):
		ci.draw_rect(Rect2(x + float(i) * sw, y, sw, 17.0),
			a if (i % 2) == 0 else b)
	ci.draw_rect(Rect2(x, y + 17.0, w, 3.0), Color(0, 0, 0, 0.30))
	ci.draw_rect(Rect2(x, y, w, 2.0), Color(1, 1, 1, 0.10))
	# The two arms holding it out, which is the only thing making it read as
	# projecting rather than as painted on.
	ci.draw_rect(Rect2(x + 3.0, y - 9.0, 2.0, 10.0), Color(0, 0, 0, 0.35))
	ci.draw_rect(Rect2(x + w - 5.0, y - 9.0, 2.0, 10.0), Color(0, 0, 0, 0.35))


# A pole with cross-arms. The thing everything else hangs off, in half the
# cities on the list.
static func pole(ci: CanvasItem, x: float, base_y: float, height: float,
		col: Color, arms: int = 2) -> void:
	ci.draw_rect(Rect2(x - 3.0, base_y - height, 6.0, height), col)
	ci.draw_rect(Rect2(x - 3.0, base_y - height, 2.0, height), col.lightened(0.18))
	for i in range(arms):
		var ay: float = base_y - height + 14.0 + float(i) * 16.0
		ci.draw_rect(Rect2(x - 13.0, ay, 26.0, 2.5), col.darkened(0.15))
	ci.draw_rect(Rect2(x - 6.0, base_y - 3.0, 12.0, 4.0), Color(0, 0, 0, 0.30))


# Cables between two poles, sagging. Tokyo, Hanoi, Mumbai and São Paulo all
# live under these, and it is the most recognisable thing about all four.
static func wires(ci: CanvasItem, x0: float, y0: float, x1: float, y1: float,
		count: int, sag: float, col: Color) -> void:
	for i in range(count):
		var off: float = float(i) * 3.4
		var s: float = sag + float(i) * 2.2
		var pts := PackedVector2Array()
		for k in range(9):
			var u: float = float(k) / 8.0
			var x: float = lerpf(x0, x1, u)
			var y: float = lerpf(y0, y1, u) + off + sin(u * PI) * s
			pts.append(Vector2(x, y))
		ci.draw_polyline(pts, col, 1.1, true)


# A messy bundle where the cables meet the pole. Tidy wires read as a diagram.
static func wire_knot(ci: CanvasItem, x: float, y: float, col: Color) -> void:
	ci.draw_rect(Rect2(x - 11.0, y - 7.0, 22.0, 15.0), col.darkened(0.20))
	for i in range(7):
		var a: float = float(i) * 0.9
		ci.draw_line(Vector2(x, y), Vector2(x + cos(a) * 13.0, y + sin(a) * 9.0),
			col, 1.0)


# A stack of signboards up a wall. Seoul, Tokyo, Hanoi and Mumbai all do this;
# what differs is the colour and how far it projects.
static func sign_stack(ci: CanvasItem, x: float, y: float, w: float, rows: int,
		board: Color, ink: Color, seed_i: int = 0) -> void:
	for i in range(rows):
		var sy: float = y + float(i) * 21.0
		var sw: float = w * (0.72 + 0.28 * float((i * 7 + seed_i) % 4) / 3.0)
		var tint: Color = board if (i % 2) == 0 else board.darkened(0.18)
		ci.draw_rect(Rect2(x, sy, sw, 18.0), tint)
		ci.draw_rect(Rect2(x, sy, sw, 1.4), tint.lightened(0.24))
		# Lettering, as marks. The alien cannot read them and neither can the
		# renderer, which is the correct amount of honesty.
		var marks: int = int(sw / 9.0)
		for m in range(marks):
			ci.draw_rect(Rect2(x + 4.0 + float(m) * 9.0, sy + 5.0, 5.0, 8.0), ink)


# A trestle with goods on it. The unit of every market in the game.
static func stall(ci: CanvasItem, x: float, y: float, w: float,
		cloth: Color, goods: Array) -> void:
	ci.draw_rect(Rect2(x, y, w, 6.0), cloth)
	ci.draw_rect(Rect2(x, y + 6.0, w, 22.0), cloth.darkened(0.28))
	ci.draw_rect(Rect2(x + 4.0, y + 28.0, 4.0, 14.0), Color(0, 0, 0, 0.40))
	ci.draw_rect(Rect2(x + w - 8.0, y + 28.0, 4.0, 14.0), Color(0, 0, 0, 0.40))
	if goods.is_empty():
		return
	var n: int = int(w / 13.0)
	for i in range(n):
		var g: Color = goods[i % goods.size()]
		ci.draw_circle(Vector2(x + 8.0 + float(i) * 13.0, y - 2.0), 4.4, g)


static func crates(ci: CanvasItem, x: float, y: float, cols: int, rows: int,
		col: Color) -> void:
	for r in range(rows):
		for c in range(cols):
			var cx: float = x + float(c) * 30.0 + float(r) * 5.0
			var cy: float = y - float(r) * 20.0
			ci.draw_rect(Rect2(cx, cy, 28.0, 19.0), col)
			ci.draw_rect(Rect2(cx, cy, 28.0, 2.0), col.lightened(0.20))
			ci.draw_rect(Rect2(cx + 2.0, cy + 5.0, 24.0, 1.4), Color(0, 0, 0, 0.25))


# A tree as a trunk and a mass. Species is a matter of canopy shape and colour,
# and both are the caller's.
static func tree(ci: CanvasItem, x: float, base_y: float, h: float,
		trunk: Color, canopy: Color, spread: float = 1.0) -> void:
	ci.draw_rect(Rect2(x - 4.0, base_y - h, 8.0, h), trunk)
	var cy: float = base_y - h - 6.0
	ci.draw_circle(Vector2(x, cy), 20.0 * spread, canopy)
	ci.draw_circle(Vector2(x - 14.0 * spread, cy + 8.0), 14.0 * spread, canopy)
	ci.draw_circle(Vector2(x + 14.0 * spread, cy + 6.0), 15.0 * spread, canopy)
	ci.draw_circle(Vector2(x + 2.0, cy - 11.0 * spread), 13.0 * spread,
		canopy.lightened(0.10))
	ci.draw_rect(Rect2(x - 13.0, base_y - 3.0, 26.0, 4.0), Color(0, 0, 0, 0.22))


static func bollard(ci: CanvasItem, x: float, y: float, col: Color) -> void:
	ci.draw_rect(Rect2(x - 5.0, y - 26.0, 10.0, 26.0), col)
	ci.draw_rect(Rect2(x - 5.0, y - 26.0, 3.0, 26.0), col.lightened(0.20))
	ci.draw_rect(Rect2(x - 6.0, y - 28.0, 12.0, 3.0), col.lightened(0.14))
	ci.draw_rect(Rect2(x - 6.0, y, 13.0, 3.0), Color(0, 0, 0, 0.30))


static func bin(ci: CanvasItem, x: float, y: float, col: Color) -> void:
	ci.draw_rect(Rect2(x - 12.0, y - 30.0, 24.0, 30.0), col)
	ci.draw_rect(Rect2(x - 14.0, y - 33.0, 28.0, 5.0), col.lightened(0.18))
	ci.draw_rect(Rect2(x - 12.0, y - 30.0, 4.0, 30.0), col.lightened(0.12))
	ci.draw_rect(Rect2(x - 13.0, y, 27.0, 3.0), Color(0, 0, 0, 0.28))


# A street lamp, and the pool it throws. The pool is the point; the lamp is
# just where it comes from.
static func lamp(ci: CanvasItem, x: float, base_y: float, h: float,
		post: Color, glow: Color, on: bool) -> void:
	ci.draw_rect(Rect2(x - 2.5, base_y - h, 5.0, h), post)
	ci.draw_rect(Rect2(x - 9.0, base_y - h - 5.0, 18.0, 6.0), post.darkened(0.15))
	if not on:
		return
	ci.draw_circle(Vector2(x, base_y - h - 1.0), 6.0,
		Color(glow.r, glow.g, glow.b, 0.85))
	for i in range(4):
		var rr: float = 16.0 + float(i) * 13.0
		ci.draw_circle(Vector2(x, base_y - h - 1.0), rr,
			Color(glow.r, glow.g, glow.b, 0.045 - float(i) * 0.009))
	# What it actually lights, which is a patch of pavement and nothing else.
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 10.0, base_y - h), Vector2(x + 10.0, base_y - h),
		Vector2(x + 46.0, base_y + 16.0), Vector2(x - 46.0, base_y + 16.0),
	]), Color(glow.r, glow.g, glow.b, 0.055))



# ── Atmosphere ────────────────────────────────────────────────────────────────

# A darkening at the frame edges. Every plate in the game has one; without it
# the 1152-wide box reads as a stage set with the wings showing.
static func vignette(ci: CanvasItem, strength: float = 0.22) -> void:
	for i in range(7):
		var a: float = strength * (1.0 - float(i) / 7.0) * 0.30
		var inset: float = float(i) * 13.0
		ci.draw_rect(Rect2(inset - 40.0, -40.0, 44.0, VH + 80.0),
			Color(0, 0, 0, a))
		ci.draw_rect(Rect2(VW - inset - 4.0, -40.0, 44.0, VH + 80.0),
			Color(0, 0, 0, a))
	ci.draw_rect(Rect2(-40.0, -40.0, VW + 80.0, 60.0), Color(0, 0, 0, strength * 0.5))


# Warm or cold air sitting in the street. One rect, low alpha, and it does more
# for a city's identity than any single object in it.
static func air(ci: CanvasItem, col: Color, amount: float) -> void:
	ci.draw_rect(Rect2(0, 0, VW, VH), Color(col.r, col.g, col.b, amount))


# Dust, rain or snow, depending entirely on what you pass in.
static func motes(ci: CanvasItem, count: int, col: Color, t: float,
		speed: float, drift: float, size: float) -> void:
	for i in range(count):
		var seed_x: float = float((i * 137) % 1152)
		var fall: float = fmod(t * speed + float(i * 53), VH + 80.0)
		var x: float = seed_x + sin(t * 0.6 + float(i)) * drift
		ci.draw_rect(Rect2(x, fall - 40.0, size, size * 2.2), col)


# ── Skyline ───────────────────────────────────────────────────────────────────
# A cluster of towers a long way behind the street, for the cities that have
# one. Deliberately cold, flat and hazed at the base: these are never on the
# road the player is standing on. They are the financial district seen from a
# market, which is how most of these cities are actually arranged — and the
# cities that genuinely have no skyline (Rome, La Paz, Berlin) never call this.
static func skyline(ci: CanvasItem, base_y: float, body: Color, glass: Color,
		count: int, seed_i: int, lit: bool) -> void:
	var slot: float = VW / float(maxi(1, count))
	for i in range(count):
		var h: int = (i * 37 + seed_i * 13) % 100
		var top: float = base_y - 44.0 - float(h) * 1.30
		var w: float = slot * (0.42 + float((i * 17 + seed_i) % 5) * 0.09)
		var x: float = slot * float(i) + (slot - w) * 0.5
		ci.draw_rect(Rect2(x, top, w, base_y - top), body)
		ci.draw_rect(Rect2(x, top, w * 0.30, base_y - top), body.lightened(0.07))
		# A mast on the tallest few. That silhouette is what reads as a skyline.
		if h > 78:
			ci.draw_rect(Rect2(x + w * 0.5 - 1.0, top - 16.0, 2.0, 16.0), body)
		var rows: int = int((base_y - top) / 11.0)
		for r in range(rows):
			var y: float = top + 6.0 + float(r) * 11.0
			var on: bool = lit and ((i * 5 + r * 7 + seed_i) % 7) < 2
			var pane: Color = Color(0.98, 0.86, 0.62, 0.22) if on else glass
			ci.draw_rect(Rect2(x + 3.0, y, w - 6.0, 5.0), pane)
	# Haze across the base, so the cluster sits behind the street.
	ci.draw_rect(Rect2(0.0, base_y - 40.0, VW, 40.0),
		Color(body.r, body.g, body.b, 0.28))


# ── The ground floor ──────────────────────────────────────────────────────────
# The band between where the upper storeys stop (GROUND_Y, 238) and the
# pavement (292). Every district was leaving it bare, which put a stripe of
# raw sky under the whole terrace and made the buildings look like they were
# floating an inch off the ground - most visible in Bondi, where the sky's
# low band is warm and the strip read as a brown bar.
#
# So this is the storey the shops are in: a continuous run of frontage with
# glazing, stall risers, a fascia course and the odd shut roller shutter.
# Doors draw over the top of it, so a district gets a whole street of shops
# and the four that lead somewhere are the ones with signs on.
static func ground_floor(ci: CanvasItem, top: float, body: Color, glass: Color,
		warm: Color, lit: bool, seed_i: int = 0, trades: Array = []) -> void:
	var h: float = PAVE_TOP - top
	ci.draw_rect(Rect2(0.0, top, VW, h), body)
	# The fascia course the shop names would sit on.
	ci.draw_rect(Rect2(0.0, top, VW, 7.0), body.lightened(0.14))
	ci.draw_rect(Rect2(0.0, top + 7.0, VW, 2.0), body.darkened(0.30))

	var bay: float = 128.0
	var n: int = int(VW / bay) + 1
	for i in range(n):
		var x: float = float(i) * bay
		var k: int = (i * 7 + seed_i) % 9
		if k == 3:
			# Shut. Every street has one and it has been shut a long time.
			ci.draw_rect(Rect2(x + 10.0, top + 14.0, bay - 20.0, h - 20.0),
				body.darkened(0.26))
			for r in range(int((h - 24.0) / 6.0)):
				ci.draw_rect(Rect2(x + 10.0, top + 16.0 + float(r) * 6.0,
					bay - 20.0, 3.0), body.darkened(0.14))
			continue
		# Glazing, set back behind a stall riser, with the transom above it.
		ci.draw_rect(Rect2(x + 8.0, top + 14.0, bay - 16.0, h - 14.0),
			body.darkened(0.34))
		var pane: Color = glass
		if lit and k % 3 == 0:
			pane = Color(warm.r, warm.g, warm.b, 0.85)
		ci.draw_rect(Rect2(x + 14.0, top + 20.0, bay - 28.0, h - 40.0), pane)
		ci.draw_rect(Rect2(x + 14.0, top + 20.0, bay - 28.0, 6.0),
			pane.darkened(0.24))
		# The mullion, and the recessed door beside it.
		ci.draw_rect(Rect2(x + bay * 0.5 - 2.0, top + 20.0, 4.0, h - 40.0),
			body.darkened(0.40))
		ci.draw_rect(Rect2(x + bay - 34.0, top + 22.0, 22.0, h - 22.0),
			body.darkened(0.46))
		# The stall riser the window sits on.
		ci.draw_rect(Rect2(x + 8.0, PAVE_TOP - 20.0, bay - 16.0, 20.0),
			body.darkened(0.20))
		# The sign, hung off a bracket at right angles to the wall, which
		# is the only signage that works when you cannot read the words.
		if k != 3 and k != 7:
			var set: Array = trades if not trades.is_empty() else TRADES
			var which: String = String(set[(i * 7 + seed_i * 3) % set.size()])
			trade(ci, which, x + 16.0, top + 20.0,
				body.lightened(0.24), body.darkened(0.62), warm, lit)
		if k == 5:
			# An awning, wound out, on about one shop in nine.
			ci.draw_rect(Rect2(x + 4.0, top + 16.0, bay - 8.0, 9.0),
				warm.darkened(0.42))
			ci.draw_rect(Rect2(x + 4.0, top + 25.0, bay - 8.0, 3.0),
				warm.darkened(0.56))


# ── Trade signs ───────────────────────────────────────────────────────────────
# What the shop IS. A street of identical glazing tells the player nothing, and
# in a game about not being able to read, a symbol hanging off a bracket at
# right angles to the facade is the one piece of signage that works in every
# country and every alphabet - which is exactly why every country uses them.
#
# Drawn as a projecting board on a bracket, because that is how a shop sign is
# hung when it needs to be read by somebody walking down the street rather than
# standing in front of it.

const TRADES := ["pharmacy", "bakery", "cafe", "bar", "grocer", "barber",
	"laundry", "books", "butcher", "post", "clothes", "hardware"]


# What a chemist puts over its door, which is NOT the same shape everywhere.
#
# A green cross was being drawn in all twenty cities, and in Turkiye that is
# wrong twice over: the sign there is a red letter E on white in a red box,
# for Eczane, and a cross over a shop in a Muslim-majority country reads as a
# church to the people who actually live there. Germany is a red A for
# Apotheke and is equally not a cross. Where a country signs its pharmacies
# with a word, the word is what goes up.
const PHARMACY_MARK := {
	"istanbul": "E",                                   # Eczane, red on white
	"berlin": "A", "zurich": "A",                      # Apotheke, red
	"tokyo": "KUSURI", "seoul": "YAK",
	"mumbai": "CHEMIST", "hanoi": "THUOC",
	"newyork": "Rx", "honolulu": "Rx", "toronto": "Rx",
}


static func pharmacy_mark(ci: CanvasItem, cx: float, cy: float,
		ink: Color, lit: bool) -> void:
	var mark: String = String(PHARMACY_MARK.get(GameState.city, "cross"))
	var red := Color(0.816, 0.161, 0.145)
	var green := Color(0.25, 0.78, 0.45)
	if mark == "cross":
		var g: Color = green if lit else ink
		ci.draw_rect(Rect2(cx - 3.0, cy - 10.0, 6.0, 20.0), g)
		ci.draw_rect(Rect2(cx - 10.0, cy - 3.0, 20.0, 6.0), g)
		return
	if mark == "E" or mark == "A":
		# One big letter on white, boxed in red. Drawn as strokes, because a
		# font at this size is four unreadable pixels.
		var c: Color = red if lit else ink
		ci.draw_rect(Rect2(cx - 11.0, cy - 12.0, 22.0, 24.0), c)
		ci.draw_rect(Rect2(cx - 8.0, cy - 9.0, 16.0, 18.0),
			Color(0.949, 0.937, 0.910))
		if mark == "E":
			ci.draw_rect(Rect2(cx - 5.0, cy - 7.0, 4.0, 14.0), c)
			for k in range(3):
				ci.draw_rect(Rect2(cx - 5.0, cy - 7.0 + float(k) * 5.5,
					10.0, 3.5), c)
		else:
			ci.draw_colored_polygon(PackedVector2Array([
				Vector2(cx, cy - 8.0), Vector2(cx + 6.0, cy + 7.0),
				Vector2(cx + 2.0, cy + 7.0), Vector2(cx - 2.0, cy + 7.0),
				Vector2(cx - 6.0, cy + 7.0),
			]), c)
			ci.draw_rect(Rect2(cx - 3.5, cy + 0.5, 7.0, 3.0),
				Color(0.949, 0.937, 0.910))
		return
	# A word, on a lit panel. Short enough to read at this size.
	var panel: Color = Color(0.16, 0.44, 0.30) if lit else ink
	ci.draw_rect(Rect2(cx - 17.0, cy - 7.0, 34.0, 14.0), panel)
	ci.draw_rect(Rect2(cx - 15.0, cy - 5.0, 30.0, 10.0), panel.lightened(0.14))
	var n: int = mini(mark.length(), 7)
	var step: float = 28.0 / float(n)
	for i in range(n):
		ci.draw_rect(Rect2(cx - 14.0 + float(i) * step, cy - 3.0,
			step * 0.62, 6.0), Color(0.949, 0.937, 0.910))


static func trade(ci: CanvasItem, kind: String, x: float, y: float,
		board: Color, ink: Color, glow: Color, lit: bool) -> void:
	# The bracket, off the wall.
	ci.draw_rect(Rect2(x - 2.0, y - 4.0, 26.0, 3.0), ink)
	ci.draw_rect(Rect2(x + 22.0, y - 4.0, 3.0, 8.0), ink)
	var bx: float = x + 6.0
	var by: float = y + 4.0
	var w: float = 36.0
	var h: float = 30.0
	ci.draw_rect(Rect2(bx, by, w, h), board.darkened(0.35))
	ci.draw_rect(Rect2(bx + 2.0, by + 2.0, w - 4.0, h - 4.0), board)
	var cx: float = bx + w * 0.5
	var cy: float = by + h * 0.5
	var mark: Color = glow if lit else ink

	match kind:
		"pharmacy":
			pharmacy_mark(ci, cx, cy, ink, lit)
		"bakery":
			# A pretzel, which is three loops and reads as bread everywhere.
			ci.draw_arc(Vector2(cx, cy - 1.0), 8.0, PI * 0.15, PI * 0.85, 12,
				mark, 2.6)
			ci.draw_arc(Vector2(cx - 5.0, cy + 3.0), 5.0, -PI * 0.9, PI * 0.6,
				10, mark, 2.4)
			ci.draw_arc(Vector2(cx + 5.0, cy + 3.0), 5.0, PI * 0.4, PI * 1.9,
				10, mark, 2.4)
		"cafe":
			ci.draw_rect(Rect2(cx - 8.0, cy - 5.0, 14.0, 11.0), mark)
			ci.draw_arc(Vector2(cx + 7.0, cy), 4.0, -PI * 0.5, PI * 0.5, 8,
				mark, 2.2)
			ci.draw_rect(Rect2(cx - 11.0, cy + 7.0, 22.0, 2.5), mark)
			for i in range(2):
				ci.draw_rect(Rect2(cx - 5.0 + float(i) * 7.0, cy - 12.0, 2.0,
					5.0), Color(mark.r, mark.g, mark.b, 0.55))
		"bar":
			ci.draw_colored_polygon(PackedVector2Array([
				Vector2(cx - 8.0, cy - 9.0), Vector2(cx + 8.0, cy - 9.0),
				Vector2(cx + 2.0, cy + 2.0), Vector2(cx - 2.0, cy + 2.0),
			]), mark)
			ci.draw_rect(Rect2(cx - 1.5, cy + 2.0, 3.0, 7.0), mark)
			ci.draw_rect(Rect2(cx - 7.0, cy + 9.0, 14.0, 2.5), mark)
		"grocer":
			for i in range(3):
				ci.draw_circle(Vector2(cx - 7.0 + float(i) * 7.0,
					cy - 3.0 + float(i % 2) * 4.0), 4.5, mark)
			ci.draw_rect(Rect2(cx - 11.0, cy + 5.0, 22.0, 3.0), mark)
		"barber":
			# The pole. Red and white and older than every other sign here.
			ci.draw_rect(Rect2(cx - 4.0, cy - 11.0, 8.0, 22.0),
				board.lightened(0.40))
			for i in range(4):
				ci.draw_rect(Rect2(cx - 4.0, cy - 11.0 + float(i) * 6.0, 8.0,
					3.0), Color(0.78, 0.20, 0.18))
		"laundry":
			ci.draw_arc(Vector2(cx, cy), 9.0, 0.0, TAU, 18, mark, 2.4)
			ci.draw_arc(Vector2(cx, cy), 4.5, 0.0, TAU, 12, mark, 2.0)
		"books":
			for i in range(4):
				ci.draw_rect(Rect2(cx - 10.0 + float(i) * 5.5, cy - 9.0
					+ float((i * 3) % 3), 4.0, 18.0 - float((i * 3) % 3)),
					mark if i % 2 == 0 else Color(mark.r, mark.g, mark.b, 0.62))
		"butcher":
			for i in range(3):
				var hx: float = cx - 8.0 + float(i) * 8.0
				ci.draw_rect(Rect2(hx - 1.0, cy - 11.0, 2.0, 7.0), mark)
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(hx - 4.0, cy - 4.0), Vector2(hx + 4.0, cy - 4.0),
					Vector2(hx + 2.5, cy + 9.0), Vector2(hx - 2.5, cy + 9.0),
				]), mark)
		"post":
			ci.draw_rect(Rect2(cx - 11.0, cy - 7.0, 22.0, 15.0), mark)
			ci.draw_line(Vector2(cx - 11.0, cy - 7.0), Vector2(cx, cy + 2.0),
				board, 2.0)
			ci.draw_line(Vector2(cx + 11.0, cy - 7.0), Vector2(cx, cy + 2.0),
				board, 2.0)
		"clothes":
			ci.draw_arc(Vector2(cx, cy - 6.0), 3.5, PI, TAU, 8, mark, 2.0)
			ci.draw_line(Vector2(cx, cy - 3.0), Vector2(cx, cy + 1.0), mark, 2.0)
			ci.draw_line(Vector2(cx - 11.0, cy + 6.0), Vector2(cx + 11.0, cy + 6.0),
				mark, 2.4)
			ci.draw_line(Vector2(cx - 11.0, cy + 6.0), Vector2(cx, cy + 1.0),
				mark, 2.0)
			ci.draw_line(Vector2(cx + 11.0, cy + 6.0), Vector2(cx, cy + 1.0),
				mark, 2.0)
		"hardware":
			ci.draw_rect(Rect2(cx - 2.0, cy - 10.0, 4.0, 20.0), mark)
			ci.draw_rect(Rect2(cx - 9.0, cy - 10.0, 18.0, 6.0), mark)
		_:
			ci.draw_rect(Rect2(cx - 8.0, cy - 8.0, 16.0, 16.0), mark)
