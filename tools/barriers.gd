extends SceneTree

# Every solid in the game, measured, so a barrier with nothing drawn under it
# has somewhere to show up.
#
# "I can't walk into some places that I should be able to" cannot be chased by
# looking at six scenes. tools/collide.gd draws the collision map over one
# street's art, which is the right tool for judging one street and useless for
# finding the one street out of two hundred that is wrong. This boots all of
# them, walks every StaticBody2D that is not the world border, and reports
# anything with the shape of a fault:
#
#   WIDE      a solid more than a third of the plate across AND tall enough to
#             be a wall rather than a lip, with nobody served at it.
#   OUTSIDE   a solid wholly off the 1152x648 plate: a barrier with nothing
#             drawn under it anywhere.
#   FLOAT     a solid entirely above the walkable line, where there is no floor
#             for anything to stand on.
#   TWIN      two solids the same size overlapping by more than half, which
#             means one was declared twice, or moved and left a ghost behind.
#
# ── Why those are narrower than they look ────────────────────────────────────
#
# This reported 104 suspects for weeks and not one of them was a fault, which
# is the same thing as reporting none: nobody works a list that is wrong.
# Measured on 2026-09-10, the 104 was
#
#   60 WIDE     every quay, platform lip, shop frontage and service counter in
#               the game. A check-in desk IS a third of a plate across, and
#               Docklands' 1232-wide solid is the edge of the dock, which is
#               the one thing that stops you walking into the water.
#   30 STACK    stalls. A stall is a body and a counter and they overlap on
#               purpose; so does a shopfront and its step. That is how the
#               whole game is built.
#   14 OUTSIDE  streets carrying on past the frame. Esquilino's arcade starts
#               its nine piers at x=-30 so the portico does not begin neatly
#               inside the picture, and the four visible pixels of the first
#               one are correctly solid.
#
# So: a wide solid is excused by a ServicePoint standing at it, because what
# separates a counter from a wall declared as furniture is not a measurement,
# it is that somebody is served there. An overlap is excused unless the two
# are the same SIZE, because a ghost is the same size as the thing it ghosts.
# And a solid is only outside if none of it is on the plate at all.
#
# Note that Solids._add_box clamps every PROCEDURAL solid to FOOT (26px) tall,
# so WIDE can now only ever fire on collision hand-authored in a .tscn. For
# procedural solids width alone cannot tell a quay from a mistake, and
# pretending it can is what produced sixty false alarms.
#
# A fifth rule lived here briefly on 2026-09-10 and has been taken out again:
# solids sitting in Crowd.gd's walking band, because the crowd consulted no
# collision and walked through furniture. It reported 57 districts, and 55 of
# those were the game's own named people - CityNPC and KeyNPC are StaticBody2D,
# so everybody with a name was being measured as a barrier. Excluding people
# (which every rule here wanted anyway; there is very obviously something drawn
# under Frau Amsler) left two, both in the Han: the fountain and the tree's
# planter. Crowd.gd walks round them now, so the rule had nothing left to say
# and keeping it would have put two non-faults back on the list.
#
# All four rules were proven by breaking something on purpose and watching
# them fire, which is the only way to know a checker reporting zero is
# reporting anything at all.
#
#   cp tools/barriers.gd barriers.gd
#   <godot> --path . --script res://barriers.gd
#   rm barriers.gd

const PLATE := Vector2(1152.0, 648.0)
const WIDE := 384.0        # a third of the plate
const EDGE := 32.0         # anything flatter than this is a lip, not a wall
const WALK_TOP := 240.0    # nothing walkable is above this on any plate
# (the on-plate fraction rule is gone - see _mostly_off for why)
const TWIN := 6.0          # two solids the same size to within this are one

var _queue: Array = []
var _cur: Node = null
var _frames: int = 0
var _reports: Array = []
var _scenes: int = 0
var _solids: int = 0


func _initialize() -> void:
	var d := DirAccess.open("res://scenes/world")
	for f in d.get_files():
		if f.ends_with(".tscn"):
			_queue.append("res://scenes/world/" + f)
	_queue.sort()


func _process(_delta: float) -> bool:
	if _cur != null:
		_frames += 1
		if _frames < 3:
			return false
		_measure(_cur, String(_cur.get_meta("path", "")))
		_cur.free()
		_cur = null
	if _queue.is_empty():
		print("BARRIERS: %d scenes, %d solids" % [_scenes, _solids])
		for r: String in _reports:
			print("  ", r)
		print("BARRIERS: %d suspect" % _reports.size())
		return true
	var path: String = _queue.pop_front()
	var ps: PackedScene = load(path)
	if ps == null:
		_reports.append("LOAD FAILED " + path)
		return false
	_cur = ps.instantiate()
	_cur.set_meta("path", path.get_file())
	root.add_child(_cur)
	_scenes += 1
	_frames = 0
	return false


func _measure(n: Node, scene: String) -> void:
	var boxes: Array = []
	_collect(n, boxes)
	_solids += boxes.size()
	# Where somebody can be served. A wide solid with one of these standing
	# at it is a counter, and a counter is SUPPOSED to be a wide solid.
	var desks: Array = []
	_counters(n, desks)
	for b: Rect2 in boxes:
		var what: String = ""
		# An EDGE is wide and flat: a quay, a platform lip, a counter, a
		# shop frontage. Those are supposed to run the width of the room,
		# and reporting them was 60 of the 104 this tool used to cry about
		# - which is why nobody ever worked the list. Only a wide solid
		# that is also TALL is a wall that has been declared as furniture.
		if b.size.x > WIDE and b.size.y > EDGE and not _served(b, desks):
			what = "WIDE %dx%d" % [int(b.size.x), int(b.size.y)]
		elif _mostly_off(b):
			what = "OUTSIDE"
		elif b.end.y < WALK_TOP:
			what = "FLOAT"
		if not what.is_empty():
			_reports.append("%-28s %-12s at (%d,%d) %dx%d"
				% [scene, what, int(b.position.x), int(b.position.y),
					int(b.size.x), int(b.size.y)])
	for i in range(boxes.size()):
		for j in range(i + 1, boxes.size()):
			var a: Rect2 = boxes[i]
			var c: Rect2 = boxes[j]
			var hit: Rect2 = a.intersection(c)
			if hit.size.x <= 0.0 or hit.size.y <= 0.0:
				continue
			var area: float = hit.size.x * hit.size.y
			var small: float = minf(a.size.x * a.size.y, c.size.x * c.size.y)
			if small <= 0.0 or area / small <= 0.5:
				continue
			# A stall is a body and a counter, a shopfront is a wall and a
			# step, and the two parts overlap on purpose. That is how the
			# whole game is built, and reporting it was the other 30 of the
			# 104. What this is actually looking for is the fault in its own
			# docstring - "declared twice, or moved and left a ghost behind"
			# - and a ghost is the same SIZE as the thing it is a ghost of.
			if absf(a.size.x - c.size.x) > TWIN \
					or absf(a.size.y - c.size.y) > TWIN:
				continue
			_reports.append("%-28s %-12s (%d,%d) over (%d,%d) both %dx%d"
				% [scene, "TWIN", int(a.position.x), int(a.position.y),
					int(c.position.x), int(c.position.y),
					int(a.size.x), int(a.size.y)])


# A person is not a barrier.
#
# CityNPC and KeyNPC are StaticBody2D, so every named person in the game was
# being measured as furniture. That is wrong for every rule here - this file
# is about a solid with nothing drawn under it, and there is very obviously
# something drawn under Frau Amsler - and it is what made the walking-band
# check report 57 districts on its first run. All 57 were somebody standing
# where they are supposed to stand.
func _is_person(n: Node) -> bool:
	return n.get("npc_id") != null or n.get("city") != null


# Every place in this scene where a service is offered.
func _counters(n: Node, out: Array) -> void:
	if n is Area2D:
		# get() returns nil for a property the node has not got, so an
		# ordinary Area2D falls straight through rather than throwing.
		var sv: Variant = n.get("service")
		if sv != null and not String(sv).is_empty():
			out.append((n as Node2D).global_position)
	for ch in n.get_children():
		_counters(ch, out)


# Is this wide solid a counter? A counter is exactly the shape this tool is
# built to be suspicious of - long, solid, and standing between the player and
# the far side of the room - and there are five of them in the game's service
# interiors, all correct. The thing that tells them apart from a wall declared
# as furniture is not a measurement: it is that somebody is served there.
func _served(b: Rect2, desks: Array) -> bool:
	# You are served standing IN FRONT of the counter, not on it - every
	# service point in the game's interiors sits about a stride below the
	# solid it belongs to - so the test is the counter's own width, and a
	# stride of depth under its bottom edge.
	var front := Rect2(b.position.x - 24.0, b.position.y,
		b.size.x + 48.0, b.size.y + 96.0)
	for p: Vector2 in desks:
		if front.has_point(p):
			return true
	return false


# A solid that runs off the SIDE of the plate is right, however little of it
# is left on screen. The street does not stop at the edge of the picture and
# neither do the things along it: Esquilino's arcade is nine piers at 140
# apart starting at -30, so the portico carries on past the frame instead of
# beginning neatly inside it, and the four visible pixels of that first pier
# are correctly solid. Judging it by how much is visible called that a fault.
#
# What is actually wrong is a barrier with NOTHING drawn under it - one wholly
# outside the picture, or below the floor, where the player can be stopped by
# something they can never see.
func _mostly_off(b: Rect2) -> bool:
	var on: Rect2 = b.intersection(Rect2(Vector2.ZERO, PLATE))
	return on.size.x <= 0.0 or on.size.y <= 0.0


# Solid bodies only, and never the world border — that one is SUPPOSED to be
# a wall with nothing drawn on it.
func _collect(n: Node, out: Array) -> void:
	if n is StaticBody2D and String(n.name) != "WorldBorder" and not _is_person(n):
		for c in n.get_children():
			if c is CollisionShape2D and c.shape != null:
				var cs: CollisionShape2D = c
				if cs.shape is RectangleShape2D:
					var s: Vector2 = (cs.shape as RectangleShape2D).size
					out.append(Rect2(cs.global_position - s * 0.5, s))
			elif c is CollisionPolygon2D:
				var poly: PackedVector2Array = (c as CollisionPolygon2D).polygon
				if poly.size() < 3:
					continue
				var lo: Vector2 = (c as Node2D).to_global(poly[0])
				var hi: Vector2 = lo
				for k in range(1, poly.size()):
					var p: Vector2 = (c as Node2D).to_global(poly[k])
					lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
					hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
				out.append(Rect2(lo, hi - lo))
	for ch in n.get_children():
		_collect(ch, out)
