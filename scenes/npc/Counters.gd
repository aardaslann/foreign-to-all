extends Object

# Where the counter is that this person works at.
#
# Everything in this game is drawn in a flat straight-down projection, so a
# stall, a desk or a bar is a box of pixels in the background layer and a
# person is a sprite drawn on top of it. That is why the greengrocer looked
# like he was standing ON his crates and the receptionist looked like a bust
# sitting on the hotel desk: nothing was ever in front of anybody.
#
# A worker is not placed against a counter by hand — there are hundreds of
# them and a hand-kept list would be wrong within a week. Instead the counter
# is found from the collision the scene already has. Backgrounds declare their
# furniture as `solids()`, and the eight hand-built rooms declare theirs as
# CollisionPolygon2D, so between the two every counter in the game is already
# described exactly once, next to the code that draws it.
#
# Standing "at" a counter means: over its footprint in x, and level with it in
# y or a little way behind it. A passer-by two metres away is not at it.

# Behind a counter, or level with its back edge. A customer stands well in
# front of one and is not working at it, so the window in front is narrow.
const REACH_BEHIND := 34.0
const REACH_INTO := 12.0


# The drawn box of the counter this person is at, or a zero Rect2.
static func front(who: Node2D, probe: Vector2 = Vector2.INF) -> Rect2:
	var top: Node = who.get_tree().current_scene if who.is_inside_tree() else null
	if top == null:
		top = who.get_parent()
	while top != null and top.get_parent() != null and not (top is Node2D):
		top = top.get_parent()
	if top == null:
		return Rect2()
	var boxes: Array = []
	_gather(top, who, boxes)
	# Usually the person's own position, but a ServicePoint stands in FRONT of
	# its counter and draws its clerk at an offset, so it asks about the point
	# the clerk is drawn at rather than about the trigger's own feet.
	var here: Vector2 = who.global_position
	if probe.x < 1.0e19:
		here = probe
	var best: Rect2 = Rect2()
	var best_area: float = 1.0e20
	for r: Rect2 in boxes:
		if r.size.x <= 1.0 or r.size.y <= 1.0:
			continue
		if here.x < r.position.x or here.x > r.end.x:
			continue
		if here.y < r.position.y - REACH_BEHIND or here.y > r.position.y + REACH_INTO:
			continue
		var area: float = r.size.x * r.size.y
		if area < best_area:
			best_area = area
			best = r
	return best


static func _gather(n: Node, who: Node2D, out: Array) -> void:
	# A background states its furniture as world-space drawn boxes. This is the
	# whole box, not the walkable footprint Solids clamps it to, which is what
	# makes it the right thing to hide a person behind.
	if n != who and n.has_method("solids"):
		for r in n.call("solids"):
			if r is Rect2:
				out.append(r as Rect2)
	elif n is CollisionPolygon2D and not who.is_ancestor_of(n) and n != who:
		var body: Node = n.get_parent()
		if body is StaticBody2D and String(body.name) != "WorldBorder":
			var poly: PackedVector2Array = (n as CollisionPolygon2D).polygon
			if poly.size() >= 3:
				var lo: Vector2 = (n as Node2D).to_global(poly[0])
				var hi: Vector2 = lo
				for i in range(1, poly.size()):
					var p: Vector2 = (n as Node2D).to_global(poly[i])
					lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
					hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
				out.append(Rect2(lo, hi - lo))
	for c in n.get_children():
		_gather(c, who, out)


# How a person standing at a counter should be drawn.
#
# Two things were wrong and only one of them was position. In a flat
# straight-down projection a counter is a box whose FAR edge is the floor line
# behind it, so somebody working there stands with their soles on that edge and
# draws upward: legs hidden by the box, torso and head above it. That is
# already almost right. What made them read as floating was the SHADOW — a
# person behind a counter has no visible floor under them, so the ellipse
# landed on the counter's own surface, and an ellipse under somebody's feet on
# top of a table is the exact picture of standing on the table.
#
# The other half is placement, and the first attempt got it exactly one step
# short. Standing somebody's soles ON the counter's far edge and then drawing
# every row of them puts their legs and their shoes across the top slab of the
# counter, because the counter is background art drawn UNDER them. Removing the
# shadow stopped it looking like a person on a table and left it looking like a
# person hovering just behind one, which is what the hotel screenshot shows.
#
# What is actually true: a counter hides you from about the hip down. So the
# soles go a little way INSIDE the counter's footprint, and the figure is
# clipped at exactly the row that lands on the counter's top edge - which is
# arithmetic, not a guess, and adapts to any counter in the game without a
# hand-kept list.
#
#     row r is drawn at  at.y + (r - 26) * unit          CharacterArt.draw_figure
#     so the row at the counter's top edge is
#     26 + (top - soles) / unit  =  26 - STAND_IN / unit
#
# At the street's unit of 2 that is row 20: hem, legs and shoes hidden, waist
# and up drawn. Never moved UP - somebody deliberately placed in front of a
# counter is a customer and is left alone.
#
# Returns {"offset": Vector2, "clip": int}. Clip 99 is the ordinary figure in
# the open, shadow and all.
const STAND_IN := 12.0   # how far behind the far edge the soles go, in pixels
const ROWS := 26         # CharacterArt.H, and the row the soles sit under


static func stance(who: Node2D, unit: float,
		probe: Vector2 = Vector2.INF) -> Dictionary:
	var plain: Dictionary = {"offset": Vector2.ZERO, "clip": 99}
	# Authored foreground objects already hide the lower body. Applying the
	# old rectangular crop as well leaves floating heads (or hides a clerk).
	var host := who.get_parent()
	if host != null and host.get_meta("object_silhouettes", false):
		return plain
	if unit <= 0.02:
		return plain
	var r: Rect2 = front(who, probe)
	if r.size.x <= 1.0:
		return plain
	var here: float = who.global_position.y
	if probe.x < 1.0e19:
		here = probe.y
	var soles: float = r.position.y + minf(STAND_IN, r.size.y * 0.5)
	var clip: int = clampi(
		int(round(float(ROWS) + (r.position.y - soles) / unit)), 15, ROWS)
	return {
		"offset": Vector2(0.0, maxf(0.0, soles - here)),
		"clip": clip,
	}
