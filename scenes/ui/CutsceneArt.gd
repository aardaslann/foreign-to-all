class_name CutsceneArt
extends Object


# The grade tint per city, for the wash over the finished frame.
const PAL := {
	"default":  [Color8(14, 13, 22), Color8(255, 218, 152)],
	"hanoi":    [Color8(12, 15, 14), Color8(255, 207, 123)],
	"tokyo":    [Color8(13, 12, 19), Color8(255, 196, 131)],
	"rome":     [Color8(18, 14, 12), Color8(255, 217, 152)],
	"moscow":   [Color8(12, 13, 18), Color8(246, 229, 196)],
	"mexico":   [Color8(18, 13, 15), Color8(255, 207, 122)],
	"dakar":    [Color8(19, 15, 11), Color8(255, 221, 152)],
	"mumbai":   [Color8(18, 14, 11), Color8(255, 205, 118)],
	"lapaz":    [Color8(14, 12, 18), Color8(255, 215, 158)],
	"sydney":   [Color8(11, 14, 18), Color8(255, 224, 162)],
	"honolulu": [Color8(11, 15, 17), Color8(255, 218, 135)],
	"newyork":  [Color8(11, 12, 16), Color8(255, 212, 130)],
	"toronto":  [Color8(12, 14, 17), Color8(248, 226, 180)],
}


static func pal(city: String) -> Array:
	return PAL.get(city, PAL["default"])


# The people, drawn by the one thing that draws people.
#
# This file used to build them itself, out of tapering polygons and ellipses,
# on the same 22-unit skeleton the sprites use. It was right about the
# proportions and wrong about the language. The sprite is FLAT - hard edges,
# twelve colours, no curve anywhere - and a smooth figure on a correct
# skeleton still reads as a different game standing in the same street, which
# is exactly what it looked like.
#
# scenes/npc/CharacterArt.gd draws the grid the sprite actually IS, read out
# of art/player/strips/idle_down.png a pixel at a time. The street draws from
# the same place, so the cast in a cutscene is the cast outside it.
const CH := preload("res://scenes/npc/CharacterArt.gd")


static func look(seed_i: int, city: String) -> Dictionary:
	return CH.look(seed_i, city)


static func alien_look() -> Dictionary:
	return CH.alien_look()


static func person(ci: CanvasItem, x: float, y: float, sc: float, act: String,
		_p: Array, t: float, is_player: bool, seed_i: int,
		city: String = "berlin", appearance: Dictionary = {},
		seated: bool = false, clip_row: int = 99) -> void:
	if sc <= 0.02:
		return
	var who: Dictionary = CH.alien_look() if is_player else CH.look(seed_i, city)
	who["seated"] = seated
	who["barefoot"] = bool(appearance.get("barefoot", false))
	who["balaclava"] = bool(appearance.get("balaclava", false))
	if not is_player and not appearance.is_empty():
		for key: String in ["build", "wear", "cut", "face"]:
			if appearance.has(key): who[key] = appearance[key]
		for letter: String in appearance.get("pal", {}):
			var color: Variant = appearance["pal"][letter]
			who["pal"][letter] = Color(color) if color is String else color
	# A scale of 1.0 has always meant "as tall as somebody on the street",
	# which is 68 pixels of frame. The grid is 22 units, so a unit is this,
	# and every camera and framing decision in Cutscene.gd still holds.
	CH.draw_figure(ci, Vector2(x, y), sc * 68.0 / 22.0, who, act, t, seed_i, clip_row)


static func _ellipse(ci: CanvasItem, cx: float, cy: float, rx: float,
		ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(26):
		var a: float = TAU * float(i) / 26.0
		pts.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	ci.draw_colored_polygon(pts, col)


# The shaded side of a round form: a crescent hugging one edge, which is how
# a flat drawing says "this is not flat".
#
# The outer and inner arcs must not share their end points. They did, and
# every head in the game threw a triangulation failure and drew nothing.
static func _crescent(ci: CanvasItem, cx: float, cy: float, rx: float,
		ry: float, bite: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var n: int = 15
	for i in range(n):
		var f: float = float(i) / float(n - 1)
		var a: float = -PI * 0.5 + PI * f
		pts.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	for j in range(n - 2, 0, -1):
		var g: float = float(j) / float(n - 1)
		var a2: float = -PI * 0.5 + PI * g
		pts.append(Vector2(cx + cos(a2) * rx * (1.0 - bite * 2.0),
			cy + sin(a2) * ry))
	ci.draw_colored_polygon(pts, col)

static func _round_rect(ci: CanvasItem, rx: float, ry: float, w: float,
		h: float, r: float, col: Color) -> void:
	var rad: float = minf(r, minf(w, h) * 0.5)
	ci.draw_rect(Rect2(rx + rad, ry, w - rad * 2.0, h), col)
	ci.draw_rect(Rect2(rx, ry + rad, w, h - rad * 2.0), col)
	for c in [Vector2(rx + rad, ry + rad), Vector2(rx + w - rad, ry + rad),
			Vector2(rx + rad, ry + h - rad), Vector2(rx + w - rad, ry + h - rad)]:
		_ellipse(ci, c.x, c.y, rad, rad, col)


# A filled polygon with a keyline round it, which every shape in this game has.
static func _stroked(ci: CanvasItem, pts: PackedVector2Array, fill: Color,
		line: Color, width: float) -> void:
	if pts.size() < 3:
		return
	# Two consecutive points in the same place cannot be triangulated,
	# and a tapering limb makes them whenever a pose is tight.
	var clean := PackedVector2Array()
	for p in pts:
		if clean.is_empty() or clean[clean.size() - 1].distance_to(p) > 0.35:
			clean.append(p)
	if clean.size() < 3:
		return
	pts = clean
	var closed := pts + PackedVector2Array([pts[0]])
	ci.draw_polyline(closed, line, width, true)
	ci.draw_colored_polygon(pts, fill)
	ci.draw_polyline(closed, line, width * 0.55, true)


static func _bez(a: Vector2, b: Vector2, c: Vector2, f: float) -> Vector2:
	var g: float = 1.0 - f
	return a * (g * g) + b * (2.0 * g * f) + c * (f * f)


# ── Sets ──────────────────────────────────────────────────────────────────────
# What a shot is standing in.
#
# Every film in the game already said where its shot happens - "set": "park",
# "set": "interior", "set": "counter" - and for a long time nothing read it.
# So the line "half the district is lying on the grass" played over a pavement
# with two people standing on it, and Toronto's streetcar beat never had a
# streetcar in it. The words were right and the picture was a different scene.
#
# A set is drawn over the plate and under the people. The city is still up
# there - its roofline, its landmark, its light - and the ground under the
# cast becomes whatever the sentence says it is. Two sets cover the frame
# outright, because you cannot see a street from inside a tram.

const INDOOR_SETS := ["interior", "shop", "counter"]


# ci        the canvas
# kind      the shot's "set"
# w, h      frame size
# gfar      canvas y of the ground under the FURTHEST person
# gnear     canvas y of the ground under the NEAREST person
# k         plate pixels to canvas pixels
static func stage(ci: CanvasItem, kind: String, w: float, h: float,
		gfar: float, gnear: float, k: float, city: String, t: float,
		morning: bool, pan: float = 0.5) -> void:
	# A set may name what kind of place it is - "counter/bakery" - because
	# a bakery the size of a doorway and a shop full of tins are not the
	# same room, and the line usually says which one it is.
	var variant: String = ""
	if kind.contains("/"):
		var bits: PackedStringArray = kind.split("/")
		kind = bits[0]
		variant = String(bits[1])
	# A shot may name two: "field+stall" is a trestle standing on grass,
	# "water+market" is a market along a canal bank. They draw in order.
	if kind.contains("+"):
		for part: String in kind.split("+"):
			stage(ci, part, w, h, gfar, gnear, k, city, t, morning, pan)
		return
	match kind:
		"park", "field":   _set_grass(ci, w, h, gfar, gnear, k, morning, kind)
		"beach":           _set_beach(ci, w, h, gfar, gnear, k, morning, t)
		"water":           _set_water(ci, w, h, gfar, gnear, k, morning, t)
		"market", "stall": _set_market(ci, w, h, gfar, gnear, k, morning, kind)
		"station", "platform": _set_platform(ci, w, h, gfar, gnear, k, morning,
			city, t)
		"tram":            _set_tram(ci, w, h, gfar, gnear, k, morning,
			city, t)
		"steps":           _set_steps(ci, w, h, gfar, gnear, k, morning)
		"courtyard":       _set_courtyard(ci, w, h, gfar, gnear, k, morning)
		"gate":            _set_gate(ci, w, h, gfar, gnear, k, morning)
		"queue":           _set_queue(ci, w, h, gfar, gnear, k, morning)
		"interior":        _set_interior(ci, w, h, gfar, gnear, k, morning,
			city, t, pan)
		"shop", "counter": _set_room(ci, w, h, gfar, gnear, k, morning,
			variant, pan)
		_:                 pass


# Anything that has to stand in FRONT of the people: the near edge of a
# counter, the front of a stall. Drawn after the cast.
static func stage_front(ci: CanvasItem, kind: String, w: float, h: float,
		gfar: float, gnear: float, k: float, morning: bool) -> void:
	if kind.contains("+"):
		for part: String in kind.split("+"):
			stage_front(ci, part, w, h, gfar, gnear, k, morning)
		return
	match kind:
		"counter", "shop":
			var top: float = lerpf(gnear, h, 0.34)
			var wood := Color(0.478, 0.353, 0.243)
			if not morning:
				wood = wood.darkened(0.34)
			ci.draw_rect(Rect2(0.0, top, w, h - top), wood)
			ci.draw_rect(Rect2(0.0, top, w, 7.0 * k), wood.lightened(0.18))
			ci.draw_rect(Rect2(0.0, top + 7.0 * k, w, 3.0 * k), wood.darkened(0.30))
			for i in range(int(w / (78.0 * k)) + 1):
				ci.draw_rect(Rect2(float(i) * 78.0 * k, top + 12.0 * k, 2.5 * k,
					h - top), Color(0, 0, 0, 0.14))
		_:
			pass


# A park: grass, and the gravel path the sellers work.
#
# The first version drew a verge along the bottom of the frame, which is
# not what a formal lawn with a tower at the end of it looks like. The
# second drew a row of trees across the back and put them over the tower,
# which is worse. A set adds the ground; the plate keeps its own horizon.
static func _set_grass(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, kind: String) -> void:
	var green: Color = Color8(83, 122, 62)
	var dry: Color = Color8(115, 138, 71)
	if not morning:
		green = green.darkened(0.48)
		dry = dry.darkened(0.48)
	# The grass runs well back behind the cast, so it reads as a lawn
	# rather than as a verge - but it stops short of the plate's own
	# skyline. A row of drawn trees went straight over the Eiffel Tower,
	# and the plate already has whatever is at the back of this park.
	var top: float = maxf(gfar - 58.0 * k, 0.0)
	ci.draw_rect(Rect2(0.0, top, w, h - top), green)
	for i in range(10):
		var f: float = float(i) / 9.0
		var y: float = lerpf(top, h, f)
		if (i % 2) == 0:
			ci.draw_rect(Rect2(0.0, y, w, lerpf(7.0, 26.0, f) * k), dry)
	ci.draw_rect(Rect2(0.0, top, w, 4.0 * k), green.lightened(0.16))
	if kind == "park":
		# The gravel path across it.
		var grit: Color = Color8(177, 163, 139)
		if not morning:
			grit = grit.darkened(0.44)
		# Narrow, and at their feet. At forty-six pixels it was a dirt road
		# across the middle of the picture with lawn above and below it.
		var path: float = gfar - 8.0 * k
		ci.draw_rect(Rect2(0.0, path, w, 26.0 * k), grit)
		ci.draw_rect(Rect2(0.0, path, w, 3.0 * k), grit.darkened(0.22))
		for i3 in range(50):
			ci.draw_rect(Rect2(float((i3 * 197) % int(maxf(w, 1.0))),
				path + float((i3 * 71) % 24) * k, 2.0 * k, 2.0 * k),
				Color(0, 0, 0, 0.10))

# Sand under the cast. Nothing above it: the plates that call for this
# set already have their own sea and their own horizon, and drawing a
# second one put Bondi's pavilion in the water.
static func _set_beach(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, t: float) -> void:
	var sand: Color = Color8(224, 207, 169)
	var wet: Color = Color8(180, 168, 140)
	if not morning:
		sand = sand.darkened(0.44)
		wet = wet.darkened(0.46)
	var top: float = maxf(gfar, 0.0)
	ci.draw_rect(Rect2(0.0, top, w, 16.0 * k), wet)
	ci.draw_rect(Rect2(0.0, top, w, 3.0 * k), Color(1, 1, 1, 0.24))
	ci.draw_rect(Rect2(0.0, top + 16.0 * k, w, h), sand)
	for i in range(70):
		ci.draw_rect(Rect2(float((i * 173) % int(maxf(w, 1.0))),
			top + 22.0 * k + float((i * 97) % 220) * k, 9.0 * k, 3.0 * k),
			sand.darkened(0.05) if (i % 2) else sand.lightened(0.05))

# A quay: the edge, the rail across it, and a shallow band of water just
# beyond. Filling the frame with water drowned whatever the plate had up
# there, which in most of these districts is the far shore.
static func _set_water(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, t: float) -> void:
	var deep: Color = Color8(45, 82, 102)
	var lit: Color = Color8(177, 212, 218)
	var stone: Color = Color8(156, 152, 143)
	var iron: Color = Color8(60, 62, 66)
	if not morning:
		deep = deep.darkened(0.42)
		stone = stone.darkened(0.44)
		iron = iron.darkened(0.30)
	var top: float = maxf(gfar, 0.0)
	var edge: float = lerpf(top, h, 0.34)
	ci.draw_rect(Rect2(0.0, top, w, edge - top), deep)
	for i in range(7):
		var y: float = top + float(i) * (edge - top) / 7.0
		var al: float = 0.07 + 0.05 * sin(t * 0.5 + float(i) * 0.8)
		ci.draw_rect(Rect2(0.0, y, w, 2.0 * k),
			Color(lit.r, lit.g, lit.b, al))
	ci.draw_rect(Rect2(0.0, edge, w, h - edge), stone)
	ci.draw_rect(Rect2(0.0, edge, w, 5.0 * k), stone.lightened(0.16))
	var rail: float = edge + 6.0 * k
	ci.draw_rect(Rect2(0.0, rail, w, 4.0 * k), iron)
	ci.draw_rect(Rect2(0.0, rail + 17.0 * k, w, 3.0 * k), iron)
	for i2 in range(int(w / (54.0 * k)) + 2):
		ci.draw_rect(Rect2(float(i2) * 54.0 * k, rail, 4.0 * k, 30.0 * k),
			iron)

# A market: three stalls standing behind the cast, at intervals.
#
# The first version ran a trestle and an awning edge to edge at head
# height, which is not a market - it is a red and white barrier across the
# middle of the picture with the city hidden behind it. A market is
# discrete things with gaps between them, and the gaps are how you can
# still see where you are.
static func _set_market(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, kind: String) -> void:
	var spots: Array = [0.08, 0.50, 0.88] if kind == "market" else [0.62]
	for f: float in spots:
		_stall(ci, w * f, gfar + 6.0 * k, w * 0.30, k, morning,
			int(f * 100.0))


static func _stall(ci: CanvasItem, cx: float, base: float, sw: float,
		k: float, morning: bool, seed_i: int) -> void:
	var timber: Color = Color8(122, 90, 62)
	var shade: Color = [Color8(189, 71, 62), Color8(56, 120, 108),
		Color8(196, 152, 54)][seed_i % 3]
	var pale: Color = Color8(240, 237, 230)
	if not morning:
		timber = timber.darkened(0.36)
		shade = shade.darkened(0.42)
		pale = pale.darkened(0.44)
	var half: float = sw * 0.5
	var top: float = base - 30.0 * k
	var awn: float = base - 116.0 * k
	# Two poles and the awning slung between them.
	for s in [-1.0, 1.0]:
		ci.draw_rect(Rect2(cx + s * (half - 5.0 * k) - 2.5 * k, awn,
			5.0 * k, base - awn), timber.darkened(0.18))
	var bands: int = 6
	for i in range(bands):
		var bx: float = cx - half + sw * float(i) / float(bands)
		ci.draw_rect(Rect2(bx, awn, sw / float(bands), 20.0 * k),
			shade if (i % 2) == 0 else pale)
	# The scalloped edge, which is what stops it reading as a plank.
	for i2 in range(bands * 2):
		var sx: float = cx - half + sw * float(i2) / float(bands * 2)
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(sx, awn + 20.0 * k),
			Vector2(sx + sw / float(bands * 2), awn + 20.0 * k),
			Vector2(sx + sw / float(bands * 4), awn + 30.0 * k),
		]), (shade if (i2 % 2) == 0 else pale).darkened(0.14))
	# The trestle, and one tray of produce on it.
	var hues := [Color8(207, 56, 47), Color8(230, 165, 49),
		Color8(92, 139, 62), Color8(138, 74, 139)]
	ci.draw_rect(Rect2(cx - half, top - 24.0 * k, sw, 24.0 * k),
		timber.lightened(0.10))
	for q in range(4):
		var c: Color = hues[(q + seed_i) % hues.size()]
		if not morning:
			c = c.darkened(0.38)
		var qx: float = cx - half + 10.0 * k + float(q) * (sw - 20.0 * k) / 4.0
		ci.draw_rect(Rect2(qx, top - 22.0 * k, (sw - 20.0 * k) / 4.0 - 6.0 * k,
			20.0 * k), timber.darkened(0.24))
		for r in range(3):
			ci.draw_circle(Vector2(qx + 8.0 * k + float(r) * 9.0 * k,
				top - 13.0 * k), 5.4 * k, c)
	ci.draw_rect(Rect2(cx - half, top, sw, 12.0 * k), timber)
	ci.draw_rect(Rect2(cx - half, top, sw, 4.0 * k), timber.lightened(0.22))
	# The cloth hanging off the front of it to the ground.
	ci.draw_rect(Rect2(cx - half, top + 12.0 * k, sw, base - top - 12.0 * k),
		shade.darkened(0.24))

# A platform, and the thing that pulls into it. The streetcar beat in
# Toronto used to play with no streetcar anywhere in it, which is most of
# the way to not being a streetcar beat.
#
# The car stands ABOVE the platform edge, because that is where it is when
# you are on a platform looking at it. Drawn below the edge it was a red
# sliver behind a concrete slab.
static func _set_platform(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, city: String,
		t: float) -> void:
	var conc: Color = Color8(146, 143, 138)
	var edge: Color = Color8(212, 176, 60)
	var dark: Color = Color8(28, 30, 36)
	if not morning:
		conc = conc.darkened(0.44)
		edge = edge.darkened(0.24)
	var lip: float = maxf(gfar - 8.0 * k, 0.0)
	var car_h: float = 118.0 * k
	# The trackbed behind, then the car standing in it.
	ci.draw_rect(Rect2(0.0, maxf(lip - car_h - 26.0 * k, 0.0), w,
		car_h + 26.0 * k), dark)
	_car(ci, -20.0, lip - car_h, w + 40.0, car_h, k, city, morning)
	# The platform he is standing on: the lip, the tactile strip, the slabs.
	ci.draw_rect(Rect2(0.0, lip, w, h - lip), conc)
	ci.draw_rect(Rect2(0.0, lip, w, 6.0 * k), conc.lightened(0.18))
	ci.draw_rect(Rect2(0.0, lip + 6.0 * k, w, 11.0 * k), edge)
	for i in range(int(w / (13.0 * k)) + 1):
		ci.draw_rect(Rect2(float(i) * 13.0 * k + 3.0 * k, lip + 8.0 * k,
			6.0 * k, 7.0 * k), edge.darkened(0.26))
	for i2 in range(int(w / (78.0 * k)) + 1):
		ci.draw_rect(Rect2(float(i2) * 78.0 * k, lip + 20.0 * k, 2.0 * k, h),
			Color(0, 0, 0, 0.12))

# Whatever this city runs. It is a different object in each of them and the
# livery is most of what tells you which country you are standing in.
const TRANSIT_LIVERY := {
	"toronto": [Color8(196, 30, 38), "tram"], "istanbul": [Color8(200, 69, 58), "tram"],
	"lisbon": [Color8(216, 178, 40), "tram"], "zurich": [Color8(173, 37, 43), "tram"],
	"moscow": [Color8(180, 39, 37), "metro"], "london": [Color8(206, 38, 45), "metro"],
	"berlin": [Color8(214, 176, 42), "metro"], "paris": [Color8(52, 92, 160), "metro"],
	"tokyo": [Color8(37, 74, 139), "metro"], "seoul": [Color8(43, 139, 81), "metro"],
	"newyork": [Color8(158, 162, 168), "metro"], "mexico": [Color8(224, 81, 130), "metro"],
	"saopaulo": [Color8(37, 82, 175), "metro"], "hanoi": [Color8(45, 103, 73), "metro"],
	"mumbai": [Color8(199, 163, 50), "metro"], "dakar": [Color8(27, 115, 102), "bus"],
	"lapaz": [Color8(199, 50, 50), "cable"], "sydney": [Color8(38, 92, 152), "metro"],
	"honolulu": [Color8(48, 118, 156), "bus"], "tbilisi": [Color8(186, 46, 52), "metro"],
	"rome": [Color8(201, 92, 37), "metro"],
}


static func _car(ci: CanvasItem, x: float, vy: float, cw: float,
		vh: float, k: float, city: String, morning: bool) -> void:
	var spec: Array = TRANSIT_LIVERY.get(city, [Color8(180, 60, 55), "tram"])
	var body: Color = spec[0]
	var glass: Color = Color8(150, 178, 190) if morning else Color8(232, 208, 150)
	var trim: Color = Color8(238, 236, 230)
	if not morning:
		body = body.darkened(0.20)
		trim = trim.darkened(0.30)
	ci.draw_rect(Rect2(x, vy, cw, vh), body)
	ci.draw_rect(Rect2(x, vy, cw, 7.0 * k), body.lightened(0.18))
	ci.draw_rect(Rect2(x, vy + vh - 9.0 * k, cw, 9.0 * k), body.darkened(0.28))
	var seg: float = 108.0 * k
	for i in range(int(cw / seg) + 1):
		var sx: float = x + float(i) * seg + 8.0 * k
		if sx + seg * 0.62 > x + cw:
			break
		if (i % 3) == 2:
			ci.draw_rect(Rect2(sx, vy + 12.0 * k, seg * 0.44,
				vh - 20.0 * k), Color8(24, 26, 30))
			ci.draw_rect(Rect2(sx, vy + 12.0 * k, 3.0 * k, vh - 20.0 * k), trim)
		else:
			ci.draw_rect(Rect2(sx, vy + 16.0 * k, seg * 0.62, 40.0 * k), glass)
			ci.draw_rect(Rect2(sx, vy + 16.0 * k, seg * 0.62, 4.0 * k),
				glass.lightened(0.20))
	if String(spec[1]) == "tram":
		ci.draw_line(Vector2(x + cw * 0.46, vy),
			Vector2(x + cw * 0.56, vy - 30.0 * k), Color8(40, 40, 44), 3.0 * k)


static func _vehicle(ci: CanvasItem, w: float, top: float, k: float,
		city: String, morning: bool, t: float) -> void:
	var spec: Array = TRANSIT_LIVERY.get(city, [Color8(180, 60, 55), "tram"])
	var body: Color = spec[0]
	var kind: String = String(spec[1])
	var glass: Color = Color8(150, 178, 190) if morning else Color8(232, 208, 150)
	var trim: Color = Color8(238, 236, 230)
	if not morning:
		body = body.darkened(0.20)
		trim = trim.darkened(0.30)
	# It is pulled up alongside, so it fills the width and is cut by the frame.
	var vy: float = top + 8.0 * k
	var vh: float = 96.0 * k
	ci.draw_rect(Rect2(-20.0, vy, w + 40.0, vh), body)
	ci.draw_rect(Rect2(-20.0, vy, w + 40.0, 7.0 * k), body.lightened(0.18))
	ci.draw_rect(Rect2(-20.0, vy + vh - 9.0 * k, w + 40.0, 9.0 * k),
		body.darkened(0.28))
	# A band of windows, and the doors between them.
	var seg: float = 108.0 * k
	var n: int = int(w / seg) + 2
	for i in range(n):
		var x: float = float(i) * seg - 10.0
		if (i % 3) == 2:
			# A door, open, with the step down out of it.
			ci.draw_rect(Rect2(x, vy + 12.0 * k, seg * 0.44, vh - 20.0 * k),
				Color8(24, 26, 30))
			ci.draw_rect(Rect2(x, vy + 12.0 * k, 3.0 * k, vh - 20.0 * k), trim)
			ci.draw_rect(Rect2(x + seg * 0.44 - 3.0 * k, vy + 12.0 * k, 3.0 * k,
				vh - 20.0 * k), trim)
		else:
			ci.draw_rect(Rect2(x, vy + 16.0 * k, seg * 0.62, 40.0 * k), glass)
			ci.draw_rect(Rect2(x, vy + 16.0 * k, seg * 0.62, 4.0 * k),
				glass.lightened(0.20))
	if kind == "tram":
		# The pole and the wire it runs on, which is the whole difference.
		ci.draw_rect(Rect2(0.0, vy - 30.0 * k, w, 2.5 * k), Color8(40, 40, 44))
		ci.draw_line(Vector2(w * 0.46, vy), Vector2(w * 0.60, vy - 30.0 * k),
			Color8(40, 40, 44), 3.0 * k)
	elif kind == "cable":
		ci.draw_rect(Rect2(0.0, vy - 44.0 * k, w, 3.0 * k), Color8(40, 40, 44))
		for s in [-1.0, 1.0]:
			ci.draw_line(Vector2(w * 0.5 + s * 40.0 * k, vy),
				Vector2(w * 0.5, vy - 44.0 * k), Color8(40, 40, 44), 3.0 * k)
	else:
		# Wheels, for the things that have them where you can see them.
		for i2 in range(int(w / (150.0 * k)) + 2):
			ci.draw_circle(Vector2(float(i2) * 150.0 * k + 40.0 * k,
				vy + vh + 2.0 * k), 11.0 * k, Color8(26, 26, 30))


# A tram in the road, not a tram at a platform. Istiklal has one coming
# through the crowd at walking pace and the beat is entirely about the
# crowd's indifference to it, which does not work with no tram in frame.
static func _set_tram(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, city: String, t: float) -> void:
	# Behind the cast, and only two thirds of it in shot, because it is
	# passing rather than waiting.
	var vy: float = gfar - 104.0 * k
	var pass_x: float = fmod(t * 26.0, 1.6) - 0.3
	_car(ci, -w * 0.35 + pass_x * w, vy, w * 1.15, 104.0 * k, k, city,
		morning)
	# The rails it runs on, flush in the setts.
	for r in [-16.0, 16.0]:
		ci.draw_rect(Rect2(0.0, gfar + r * k, w, 3.0 * k),
			Color8(126, 122, 114) if morning else Color8(78, 76, 72))


# A flight of steps, which several districts in this game are built on.
static func _set_steps(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool) -> void:
	var stone: Color = Color8(158, 152, 141)
	if not morning:
		stone = stone.darkened(0.46)
	var top: float = maxf(gfar, 0.0)
	ci.draw_rect(Rect2(0.0, top, w, h - top), stone)
	for i in range(7):
		var f: float = float(i) / 7.0
		var y: float = lerpf(top, h, f)
		var rise: float = lerpf(10.0, 22.0, f) * k
		ci.draw_rect(Rect2(0.0, y, w, 4.0 * k), stone.lightened(0.18))
		ci.draw_rect(Rect2(0.0, y + 4.0 * k, w, 4.0 * k), Color(0, 0, 0, 0.24))
		ci.draw_rect(Rect2(0.0, y + rise, w, 2.0 * k), Color(0, 0, 0, 0.10))


# Flagstones, and nothing else. Every plate that asks for this set is
# already standing in a courtyard and has its own walls; the first
# version pasted two grey slabs over the han's arcade.
static func _set_courtyard(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool) -> void:
	var flag: Color = Color8(163, 156, 143)
	if not morning:
		flag = flag.darkened(0.48)
	var top: float = maxf(gfar, 0.0)
	ci.draw_rect(Rect2(0.0, top, w, h - top), flag)
	ci.draw_rect(Rect2(0.0, top, w, 4.0 * k), flag.lightened(0.14))
	for i in range(int(w / (46.0 * k)) + 1):
		ci.draw_rect(Rect2(float(i) * 46.0 * k, top, 2.0 * k, h),
			Color(0, 0, 0, 0.12))
	for r in range(7):
		ci.draw_rect(Rect2(0.0, top + float(r) * 42.0 * k, w, 2.0 * k),
			Color(0, 0, 0, 0.12))

# A way in: an arch big enough to take a cart, and the dark on the far side.
static func _set_gate(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool) -> void:
	var stone: Color = Color8(186, 172, 148)
	if not morning:
		stone = stone.darkened(0.46)
	var cx: float = w * 0.5
	var half: float = 132.0 * k
	var ground: float = maxf(gfar, 0.0)
	var spring: float = ground - 96.0 * k
	var head: float = spring - 108.0 * k
	ci.draw_rect(Rect2(cx - half - 40.0 * k, 0.0, half * 2.0 + 80.0 * k,
		ground), stone)
	var pts := PackedVector2Array()
	pts.append(Vector2(cx - half, ground))
	pts.append(Vector2(cx - half, spring))
	for i in range(15):
		var a: float = PI * float(i) / 14.0
		pts.append(Vector2(cx - cos(a) * half, spring - sin(a) * (spring - head)))
	pts.append(Vector2(cx + half, ground))
	ci.draw_colored_polygon(pts, Color8(28, 24, 26))
	for i2 in range(15):
		var a2: float = PI * float(i2) / 14.0
		var ox: float = cx - cos(a2) * (half + 13.0 * k)
		var oy: float = spring - sin(a2) * (spring - head + 13.0 * k)
		ci.draw_rect(Rect2(ox - 7.0 * k, oy - 7.0 * k, 14.0 * k, 14.0 * k),
			stone.lightened(0.10) if (i2 % 2) else stone.darkened(0.10))


# A rope line, and the posts holding it.
static func _set_queue(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool) -> void:
	var post: Color = Color8(56, 58, 64)
	var rope: Color = Color8(150, 36, 42)
	if not morning:
		post = post.darkened(0.36)
		rope = rope.darkened(0.30)
	var y: float = lerpf(maxf(gfar, 0.0), h, 0.62)
	for i in range(int(w / (128.0 * k)) + 2):
		var x: float = float(i) * 128.0 * k
		ci.draw_rect(Rect2(x - 4.0 * k, y - 54.0 * k, 8.0 * k, 54.0 * k), post)
		ci.draw_rect(Rect2(x - 11.0 * k, y - 3.0 * k, 22.0 * k, 6.0 * k), post)
		ci.draw_circle(Vector2(x, y - 56.0 * k), 6.0 * k, post.lightened(0.30))
	for i2 in range(int(w / (128.0 * k)) + 1):
		var x2: float = float(i2) * 128.0 * k
		ci.draw_line(Vector2(x2, y - 50.0 * k),
			Vector2(x2 + 64.0 * k, y - 38.0 * k), rope, 5.0 * k)
		ci.draw_line(Vector2(x2 + 64.0 * k, y - 38.0 * k),
			Vector2(x2 + 128.0 * k, y - 50.0 * k), rope, 5.0 * k)


# Inside the thing that was standing at the platform a moment ago.
#
# Laid out around the floor the cast is standing on, not around the top of
# the frame: the seats run along behind them at the height of a seat, the
# window band is above that, and the poles go floor to ceiling. The first
# version measured everything down from the ceiling and left everybody
# sitting in mid-air a foot in front of the bench.
static func _set_interior(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, city: String, t: float,
		pan: float) -> void:
	var spec: Array = TRANSIT_LIVERY.get(city, [Color8(180, 60, 55), "tram"])
	var body: Color = spec[0]
	var wall: Color = Color8(214, 212, 206)
	var floor_c: Color = Color8(74, 76, 82)
	if not morning:
		wall = wall.darkened(0.30)
		floor_c = floor_c.darkened(0.24)
		body = body.darkened(0.16)
	# It covers the frame. You cannot see a street from in here.
	ci.draw_rect(Rect2(0.0, 0.0, w, h), wall)

	var floor_top: float = gfar + 4.0 * k
	var seat_top: float = floor_top - 54.0 * k
	var win_bot: float = seat_top - 16.0 * k
	var win_top: float = maxf(win_bot - 128.0 * k, 18.0 * k)

	# The window band, with the city smearing past it.
	var seg: float = 176.0 * k
	# The view out slides with the camera.
	var off: float = fmod((pan - 0.5) * w * 0.72, seg)
	for i in range(int(w / seg) + 3):
		var x: float = float(i) * seg + 8.0 * k + off - seg
		ci.draw_rect(Rect2(x, win_top, seg - 20.0 * k, win_bot - win_top),
			Color8(120, 146, 162) if morning else Color8(28, 32, 46))
		for b in range(7):
			var bx: float = x + fmod(float(b) * 34.0 * k + t * 90.0 * k,
				seg - 20.0 * k)
			ci.draw_rect(Rect2(bx, win_top + 10.0 * k
				+ float((b * 17) % 30) * k, 12.0 * k,
				minf(30.0 * k, win_bot - win_top - 14.0 * k)),
				Color(1, 1, 1, 0.09) if morning
				else Color(1.0, 0.86, 0.55, 0.13))
		ci.draw_rect(Rect2(x - 6.0 * k, win_top - 6.0 * k, 6.0 * k,
			win_bot - win_top + 12.0 * k), wall.darkened(0.26))
	ci.draw_rect(Rect2(0.0, win_bot, w, 8.0 * k), body)

	# The bench, at seat height, directly behind the cast.
	ci.draw_rect(Rect2(0.0, seat_top, w, floor_top - seat_top),
		body.darkened(0.24))
	for i2 in range(int(w / (104.0 * k)) + 1):
		var sx: float = float(i2) * 104.0 * k + 6.0 * k
		ci.draw_rect(Rect2(sx, seat_top + 4.0 * k, 92.0 * k,
			floor_top - seat_top - 8.0 * k), body)
		ci.draw_rect(Rect2(sx, seat_top + 4.0 * k, 92.0 * k, 5.0 * k),
			body.lightened(0.22))
	ci.draw_rect(Rect2(0.0, floor_top, w, h - floor_top), floor_c)
	ci.draw_rect(Rect2(0.0, floor_top, w, 4.0 * k), floor_c.lightened(0.18))

	# The grab poles, floor to ceiling.
	for p in range(4):
		var px: float = w * (0.11 + 0.26 * float(p))
		ci.draw_rect(Rect2(px, 0.0, 7.0 * k, h),
			Color8(196, 198, 202) if morning else Color8(120, 122, 128))
		ci.draw_rect(Rect2(px, 0.0, 2.5 * k, h),
			Color8(232, 234, 238) if morning else Color8(158, 160, 166))

# A room with a counter in it: a shop, a booth, a desk. The wall behind, the
# shelves on it, the floor. The counter is drawn in front of the cast.
static func _set_room(ci: CanvasItem, w: float, h: float, gfar: float,
		gnear: float, k: float, morning: bool, variant: String,
		pan: float) -> void:
	var wall: Color = Color8(196, 186, 168)
	var floor_c: Color = Color8(122, 110, 96)
	var shelf: Color = Color8(146, 116, 86)
	if not morning:
		wall = wall.darkened(0.34)
		floor_c = floor_c.darkened(0.36)
		shelf = shelf.darkened(0.34)
	ci.draw_rect(Rect2(0.0, 0.0, w, h), wall)
	ci.draw_rect(Rect2(0.0, 0.0, w, 26.0 * k), wall.darkened(0.18))
	# Muted: a shelf of stock, not a sweetshop.
	# The whole room slides with the camera, so two shots in one shop are
	# two shots rather than one drawing twice.
	var off: float = (pan - 0.5) * w * 0.72
	var tins := [Color8(150, 96, 78), Color8(168, 146, 96), Color8(104, 122, 104),
		Color8(142, 140, 134), Color8(112, 100, 124), Color8(126, 110, 88)]
	for r in range(3):
		var y: float = 74.0 * k + float(r) * 82.0 * k
		ci.draw_rect(Rect2(0.0, y, w, 7.0 * k), shelf)
		ci.draw_rect(Rect2(0.0, y, w, 2.0 * k), shelf.lightened(0.20))
		for i in range(int(w / (44.0 * k)) + 2):
			var bx: float = float(i) * 44.0 * k + 6.0 * k + fmod(off, 44.0 * k)
			var bh: float = 38.0 * k + float((i * 13 + r * 7) % 20) * k
			var c: Color = tins[(i + r) % tins.size()]
			if not morning:
				c = c.darkened(0.34)
			if variant == "workshop":
				# A tool board: silhouettes hung in rows, each on its own peg.
				# A metal shop is not a shelf of tins.
				var steel: Color = Color8(150, 154, 160) if morning \
					else Color8(96, 100, 106)
				var grip: Color = Color8(122, 84, 56) if morning \
					else Color8(84, 58, 40)
				var kind2: int = (i + r) % 3
				if kind2 == 0:
					ci.draw_rect(Rect2(bx + 12.0 * k, y - 52.0 * k, 5.0 * k,
						34.0 * k), steel)
					ci.draw_rect(Rect2(bx + 8.0 * k, y - 20.0 * k, 13.0 * k,
						20.0 * k), grip)
				elif kind2 == 1:
					ci.draw_rect(Rect2(bx + 6.0 * k, y - 50.0 * k, 22.0 * k,
						7.0 * k), steel)
					ci.draw_rect(Rect2(bx + 14.0 * k, y - 43.0 * k, 6.0 * k,
						30.0 * k), grip)
				else:
					ci.draw_rect(Rect2(bx + 10.0 * k, y - 46.0 * k, 9.0 * k,
						40.0 * k), steel)
					ci.draw_rect(Rect2(bx + 7.0 * k, y - 46.0 * k, 15.0 * k,
						6.0 * k), grip)
				ci.draw_circle(Vector2(bx + 15.0 * k, y - 56.0 * k), 2.0 * k,
					steel.darkened(0.34))
				continue
			if variant == "food":
				# A hot counter: a griddle, a stack of plates, steam. Half the
				# counters in this game are places you eat standing up.
				if r == 0:
					continue
				if (i % 4) == 0:
					ci.draw_rect(Rect2(bx, y - 30.0 * k, 38.0 * k, 30.0 * k),
						Color8(96, 94, 92) if morning else Color8(58, 58, 58))
					ci.draw_rect(Rect2(bx + 3.0 * k, y - 27.0 * k, 32.0 * k,
						6.0 * k), Color8(48, 46, 46))
				else:
					for q3 in range(3):
						ci.draw_rect(Rect2(bx + 4.0 * k, y - 8.0 * k
							- float(q3) * 7.0 * k, 30.0 * k, 5.0 * k),
							c.lightened(0.20) if (q3 % 2) else c)
				continue
			if variant == "clothes":
				# A rail of other people's coats, which is not a shelf of tins.
				if r != 1:
					continue
				var rail: float = y - 96.0 * k
				ci.draw_rect(Rect2(bx - 2.0 * k, rail, 44.0 * k, 3.0 * k),
					Color8(158, 158, 162))
				ci.draw_rect(Rect2(bx + 14.0 * k, rail, 3.0 * k, 9.0 * k),
					Color8(158, 158, 162))
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(bx + 4.0 * k, rail + 9.0 * k),
					Vector2(bx + 28.0 * k, rail + 9.0 * k),
					Vector2(bx + 34.0 * k, rail + 84.0 * k),
					Vector2(bx - 2.0 * k, rail + 84.0 * k),
				]), c)
				ci.draw_rect(Rect2(bx + 4.0 * k, rail + 9.0 * k, 9.0 * k,
					75.0 * k), c.lightened(0.14))
				continue
			if variant == "cases":
				# A glass case with small things laid out in rows in it.
				var glass: Color = Color8(176, 198, 208) if morning \
					else Color8(66, 82, 94)
				ci.draw_rect(Rect2(bx, y - 46.0 * k, 38.0 * k, 46.0 * k), glass)
				ci.draw_rect(Rect2(bx, y - 46.0 * k, 38.0 * k, 3.0 * k),
					glass.lightened(0.24))
				for q2 in range(3):
					for r3 in range(2):
						ci.draw_circle(Vector2(bx + 9.0 * k + float(q2) * 10.0 * k,
							y - 34.0 * k + float(r3) * 16.0 * k), 3.6 * k, c)
				continue
			if variant == "bakery":
				# Loaves lying on their sides, not tins standing up.
				var crust: Color = Color8(196, 146, 78) if morning \
					else Color8(130, 96, 52)
				if (i % 3) == 2:
					continue
				ci.draw_colored_polygon(PackedVector2Array([
					Vector2(bx, y), Vector2(bx + 4.0 * k, y - 20.0 * k),
					Vector2(bx + 34.0 * k, y - 20.0 * k),
					Vector2(bx + 38.0 * k, y),
				]), crust)
				ci.draw_rect(Rect2(bx + 4.0 * k, y - 20.0 * k, 30.0 * k, 4.0 * k),
					crust.lightened(0.20))
				for q in range(3):
					ci.draw_line(Vector2(bx + 10.0 * k + float(q) * 9.0 * k,
						y - 17.0 * k), Vector2(bx + 14.0 * k + float(q) * 9.0 * k,
						y - 5.0 * k), crust.darkened(0.28), 1.6 * k)
				continue
			ci.draw_rect(Rect2(bx, y - bh, 30.0 * k, bh), c)
			ci.draw_rect(Rect2(bx, y - bh, 8.0 * k, bh), c.lightened(0.14))
			ci.draw_rect(Rect2(bx, y - bh, 30.0 * k, 4.0 * k), c.darkened(0.22))
	var fy: float = h * 0.62
	ci.draw_rect(Rect2(0.0, fy, w, h - fy), floor_c)
	ci.draw_rect(Rect2(0.0, fy, w, 4.0 * k), floor_c.lightened(0.16))
	for i2 in range(int(w / (58.0 * k)) + 1):
		ci.draw_rect(Rect2(float(i2) * 58.0 * k, fy, 2.0 * k, h),
			Color(0, 0, 0, 0.10))


# ── Props ─────────────────────────────────────────────────────────────────────
# The one object a line is about.
#
# The films have always been able to name one - "prop": "coin", "prop": "glass"
# - and nothing ever drew them, so a beat whose whole subject is a nail with
# paper tickets hanging off it played as two people in a room. A prop is small,
# it is drawn where the shot says, and there is never more than one.

static func prop(ci: CanvasItem, kind: String, x: float, gfar: float,
		w: float, h: float, k: float, morning: bool, t: float) -> void:
	if kind.is_empty():
		return
	# Chest height on whoever is standing near that spot, which is where a
	# thing being shown to somebody actually is.
	var y: float = gfar - 46.0 * k
	match kind:
		"nail":    _prop_nail(ci, x, gfar - 118.0 * k, k, morning)
		"bread":   _prop_bread(ci, x, y, k, morning)
		"glass":   _prop_glass(ci, x, y, k, morning)
		"coin":    _prop_coin(ci, x, y - 12.0 * k, k, morning)
		"bowl":    _prop_bowl(ci, x, y, k, morning)
		"board":   _prop_board(ci, x, gfar - 112.0 * k, k, morning)
		"lantern": _prop_lantern(ci, x, gfar - 152.0 * k, k, morning)
		"flag":    _prop_flag(ci, x, gfar, k, morning, t)
		"smoke":   _prop_smoke(ci, x, gfar - 30.0 * k, k, t)
		_:         pass


# A nail in the wall with paper tickets on it. Askida ekmek: somebody has paid
# for a loaf and hung the receipt up, and whoever needs it takes one down.
static func _prop_nail(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var paper: Color = Color8(238, 232, 214)
	var ink: Color = Color8(66, 58, 50)
	var iron: Color = Color8(74, 70, 66)
	if not morning:
		paper = paper.darkened(0.26)
		ink = ink.lightened(0.10)
	ci.draw_rect(Rect2(x - 3.0 * k, y - 9.0 * k, 6.0 * k, 18.0 * k), iron)
	ci.draw_circle(Vector2(x, y - 9.0 * k), 5.0 * k, iron.lightened(0.20))
	for i in range(5):
		var a: float = -0.5 + 0.25 * float(i)
		var px: float = x + sin(a) * 26.0 * k
		var py: float = y + 8.0 * k + cos(a) * 8.0 * k
		ci.draw_line(Vector2(x, y), Vector2(px, py), ink, 1.4 * k)
		ci.draw_rect(Rect2(px - 14.0 * k, py, 28.0 * k, 38.0 * k), paper)
		ci.draw_rect(Rect2(px - 14.0 * k, py, 28.0 * k, 4.0 * k),
			paper.darkened(0.14))
		for r in range(3):
			ci.draw_rect(Rect2(px - 10.0 * k, py + 11.0 * k + float(r) * 8.0 * k,
				20.0 * k, 2.4 * k), ink)


static func _prop_bread(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var crust: Color = Color8(196, 146, 78)
	if not morning:
		crust = crust.darkened(0.34)
	for s in [-1.0, 1.0]:
		var bx: float = x + s * 18.0 * k
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(bx - 20.0 * k, y + 9.0 * k), Vector2(bx - 15.0 * k, y - 8.0 * k),
			Vector2(bx + 15.0 * k, y - 8.0 * k), Vector2(bx + 20.0 * k, y + 9.0 * k),
		]), crust)
		ci.draw_rect(Rect2(bx - 16.0 * k, y - 8.0 * k, 32.0 * k, 4.0 * k),
			crust.lightened(0.18))
		for c in range(3):
			ci.draw_line(Vector2(bx - 9.0 * k + float(c) * 9.0 * k, y - 6.0 * k),
				Vector2(bx - 5.0 * k + float(c) * 9.0 * k, y + 4.0 * k),
				crust.darkened(0.26), 1.6 * k)


# A tulip glass on a saucer, which is the only shape tea comes in here.
static func _prop_glass(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var tea: Color = Color8(176, 74, 30)
	var glass: Color = Color8(226, 232, 236)
	if not morning:
		tea = tea.darkened(0.20)
		glass = glass.darkened(0.30)
	ci.draw_rect(Rect2(x - 13.0 * k, y + 12.0 * k, 26.0 * k, 3.0 * k), glass)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 7.0 * k, y - 12.0 * k), Vector2(x + 7.0 * k, y - 12.0 * k),
		Vector2(x + 4.0 * k, y + 12.0 * k), Vector2(x - 4.0 * k, y + 12.0 * k),
	]), tea)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 7.0 * k, y - 12.0 * k), Vector2(x - 3.0 * k, y - 12.0 * k),
		Vector2(x - 1.0 * k, y + 12.0 * k), Vector2(x - 4.0 * k, y + 12.0 * k),
	]), Color(1, 1, 1, 0.30))
	ci.draw_rect(Rect2(x - 8.0 * k, y - 14.0 * k, 16.0 * k, 2.5 * k), glass)

static func _prop_coin(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var metal: Color = Color8(206, 176, 92)
	if not morning:
		metal = metal.darkened(0.24)
	ci.draw_circle(Vector2(x, y), 9.0 * k, metal.darkened(0.30))
	ci.draw_circle(Vector2(x, y), 7.4 * k, metal)
	ci.draw_circle(Vector2(x - 2.0 * k, y - 2.0 * k), 3.0 * k,
		metal.lightened(0.24))


static func _prop_bowl(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var ware: Color = Color8(228, 226, 218)
	var soup: Color = Color8(178, 132, 66)
	if not morning:
		ware = ware.darkened(0.30)
		soup = soup.darkened(0.30)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 20.0 * k, y - 6.0 * k), Vector2(x + 20.0 * k, y - 6.0 * k),
		Vector2(x + 13.0 * k, y + 12.0 * k), Vector2(x - 13.0 * k, y + 12.0 * k),
	]), ware)
	ci.draw_rect(Rect2(x - 19.0 * k, y - 6.0 * k, 38.0 * k, 4.0 * k), soup)


# A board with something chalked on it he cannot read.
static func _prop_board(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var slate: Color = Color8(46, 44, 42)
	var chalk: Color = Color8(226, 224, 214)
	var frame: Color = Color8(112, 84, 56)
	if not morning:
		slate = slate.darkened(0.20)
		chalk = chalk.darkened(0.24)
		frame = frame.darkened(0.34)
	ci.draw_rect(Rect2(x - 40.0 * k, y - 30.0 * k, 80.0 * k, 60.0 * k), frame)
	ci.draw_rect(Rect2(x - 35.0 * k, y - 25.0 * k, 70.0 * k, 50.0 * k), slate)
	for r in range(4):
		var lw: float = 46.0 * k - float((r * 13) % 20) * k
		ci.draw_rect(Rect2(x - 27.0 * k, y - 17.0 * k + float(r) * 11.0 * k,
			lw, 3.0 * k), chalk)


static func _prop_lantern(ci: CanvasItem, x: float, y: float, k: float,
		morning: bool) -> void:
	var paper: Color = Color8(214, 72, 52)
	if not morning:
		paper = paper.lightened(0.06)
	ci.draw_rect(Rect2(x - 2.0 * k, y - 26.0 * k, 4.0 * k, 26.0 * k),
		Color8(60, 50, 42))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x - 12.0 * k, y), Vector2(x + 12.0 * k, y),
		Vector2(x + 18.0 * k, y + 22.0 * k), Vector2(x + 12.0 * k, y + 44.0 * k),
		Vector2(x - 12.0 * k, y + 44.0 * k), Vector2(x - 18.0 * k, y + 22.0 * k),
	]), paper)
	for r2 in range(4):
		ci.draw_rect(Rect2(x - 17.0 * k, y + 8.0 * k + float(r2) * 9.0 * k,
			34.0 * k, 1.6 * k), Color(0, 0, 0, 0.20))
	ci.draw_rect(Rect2(x - 13.0 * k, y + 18.0 * k, 26.0 * k, 12.0 * k),
		Color8(28, 24, 24))


static func _prop_flag(ci: CanvasItem, x: float, base: float, k: float,
		morning: bool, t: float) -> void:
	var pole: Color = Color8(96, 92, 86)
	if not morning:
		pole = pole.darkened(0.34)
	ci.draw_rect(Rect2(x - 2.0 * k, base - 116.0 * k, 4.0 * k, 116.0 * k), pole)
	var wave: float = sin(t * 2.2) * 4.0 * k
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x + 2.0 * k, base - 112.0 * k),
		Vector2(x + 44.0 * k, base - 108.0 * k + wave),
		Vector2(x + 44.0 * k, base - 88.0 * k + wave),
		Vector2(x + 2.0 * k, base - 84.0 * k),
	]), Color8(206, 44, 40) if morning else Color8(150, 34, 32))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(x + 2.0 * k, base - 84.0 * k),
		Vector2(x + 44.0 * k, base - 88.0 * k + wave),
		Vector2(x + 44.0 * k, base - 68.0 * k + wave),
		Vector2(x + 2.0 * k, base - 56.0 * k),
	]), Color8(230, 190, 54) if morning else Color8(170, 140, 44))


static func _prop_smoke(ci: CanvasItem, x: float, y: float, k: float,
		t: float) -> void:
	for i in range(7):
		var f: float = float(i) / 6.0
		var drift: float = sin(t * 0.9 + float(i) * 0.7) * 10.0 * k * f
		ci.draw_circle(Vector2(x + drift, y - f * 92.0 * k),
			(6.0 + f * 16.0) * k, Color(0.86, 0.86, 0.84, 0.16 * (1.0 - f)))


# ── Grade ─────────────────────────────────────────────────────────────────────
# A light touch. The plate underneath is already graded for its own city, and
# the last version buried it.

static func grade(ci: CanvasItem, w: float, h: float, p: Array,
		t: float) -> void:
	var ink: Color = p[0]
	var glow: Color = p[1]
	ci.draw_rect(Rect2(0.0, 0.0, w, h * 0.30),
		Color(glow.r, glow.g, glow.b, 0.020))
	for i in range(110):
		var gx: float = fmod(float(i) * 197.0 + t * 13.0, w)
		var gy: float = fmod(float(i) * 331.0 + t * 7.0, h)
		ci.draw_rect(Rect2(gx, gy, 2.0, 2.0), Color(1, 1, 1, 0.013))
	for k in range(14):
		var f: float = float(k) / 13.0
		var a: float = 0.030 * (1.0 - f)
		var b: float = f * 76.0
		ci.draw_rect(Rect2(0.0, b, w, 6.0), Color(ink.r, ink.g, ink.b, a))
		ci.draw_rect(Rect2(0.0, h - b - 6.0, w, 6.0), Color(ink.r, ink.g, ink.b, a))
		ci.draw_rect(Rect2(b, 0.0, 6.0, h), Color(ink.r, ink.g, ink.b, a * 0.7))
		ci.draw_rect(Rect2(w - b - 6.0, 0.0, 6.0, h),
			Color(ink.r, ink.g, ink.b, a * 0.7))
