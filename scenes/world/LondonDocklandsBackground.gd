extends Node2D

# The Docklands. You come up out of the DLR and the city has changed material.
#
# The terrace was illegible and human — brick you could read the age of, a hole
# in front of every door, chimneys that told you which way the hill went. This
# is the inverse, and the inversion is done by subtraction. Everything that made
# the terrace London is simply not here:
#
#   no chimney stacks   the roofline is off the top of the frame. there is no
#                       silhouette to squint at, which is the point.
#   no basement areas   the ground is one level granite plane laid to a
#                       tolerance. nothing to trip on, nowhere to stand.
#   no stucco, no brick  glass, anodised aluminium and precast concrete.
#   no pillar-box red   the only red in the district is an aircraft warning
#                       light, and it is a hundred metres up.
#
# What replaces them is direction. The terrace was horizontal — sooted courses,
# sills, cornices, dirt falling downwards. This is vertical: mullion, mullion,
# mullion, and reflective glass with no colour of its own, holding whatever the
# sky is doing, which today is nothing. Same greys. Smooth instead of sooted.
#
# Ground bands match the terrace exactly (plaza at 292) so the player, the exits
# and the collision boxes all behave identically.

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# ── Palette (docs/design/london.md, the cold end of it) ────────────────────────
const C_LID        := Color(0.106, 0.118, 0.149)   # overcast lid, same as the terrace
const C_CLOUD      := Color(0.173, 0.192, 0.235)   # cloud belly
const C_HAZE       := Color(0.239, 0.227, 0.204)   # sodium haze — darkened out here, nothing to bounce off
const C_GLASS_SKY  := Color(0.290, 0.325, 0.384)   # glazing holding the sky, high up
const C_GLASS_DK   := Color(0.114, 0.129, 0.161)   # glazing in its own shadow, lower down
const C_GLASS_LIT  := Color(0.851, 0.898, 0.902)   # a floor left lit. fluorescent, not the terrace's milk
const C_MULLION    := Color(0.478, 0.494, 0.510)   # anodised aluminium. the vertical, over and over
const C_SPANDREL   := Color(0.216, 0.235, 0.259)   # the opaque band between floors
const C_STEEL      := Color(0.639, 0.655, 0.671)   # bollards, handrails, the pass reader
const C_CONC       := Color(0.435, 0.443, 0.451)   # precast. viaduct girder and piers
const C_CONC_DK    := Color(0.298, 0.310, 0.325)   # the shaded face of it
const C_CONC_LT    := Color(0.561, 0.569, 0.576)   # parapet, pier nosing
const C_GRANITE    := Color(0.396, 0.400, 0.408)   # plaza paving
const C_GRAN_DK    := Color(0.294, 0.298, 0.310)   # joints, setts, the shadow in them
const C_COPING     := Color(0.482, 0.478, 0.463)   # dock coping — the one warm stone left
const C_WATER      := Color(0.043, 0.055, 0.075)   # the basin. old dock water, no bottom to it
const C_WATER_LT   := Color(0.216, 0.263, 0.310)   # what the towers leave on it
const C_IRON       := Color(0.055, 0.058, 0.070)   # mooring bollards, sign ink. Northern line black
const C_MOSS       := Color(0.196, 0.243, 0.204)   # clipped hedge, delivered at this size
const C_SIGN       := Color(0.878, 0.882, 0.870)   # vinyl fascia panel. every chain uses this white
const C_DLR        := Color(0.000, 0.647, 0.671)   # DLR turquoise — this plate's ONE statutory accent
const C_AVIATION   := Color(0.882, 0.145, 0.106)   # TfL red's cousin, on a mast, obligatory

# Ground bands. 292 is shared with the terrace and the high street; the walkable
# band runs below it to the dock edge, and the dock edge is where it stops.
const PAVE_TOP  := 292.0   # granite plaza
const QUAY_TOP  := 470.0   # paving stops, the dock's own setts show through
const COPE_TOP  := 500.0   # coping — the last thing you can stand on
const WATER_TOP := 526.0   # black water from here to the bottom of the frame

# Towers: [x, width, top]. A negative top runs off the frame, which is the only
# honest way to draw thirty storeys in 292 pixels of sky. Each tower holds
# exactly one door in its base.
const _TOWERS := [
	[-100, 296, -46], [220, 172, 34], [422, 176, -70],
	[622, 178, 58], [812, 178, -18], [1010, 200, 76],
]

# The viaduct's piers land in the gaps between the shopfronts, because nobody
# moved the railway for the plaza and nobody moved the plaza for the railway.
const _PIER_X := [196.0, 398.0, 600.0, 795.0, 989.0]

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
	_draw_far()
	_draw_towers()
	_draw_viaduct()
	_draw_dlr_train()
	_draw_doors(PAVE_TOP - 74.0, PAVE_TOP, C_SIGN, C_IRON, C_DLR, C_GLASS_DK)
	_draw_plaza()
	_draw_basin()
	_draw_piers()
	_draw_furniture()


# What stops you. Not much, and all of it private: five railway piers, a line of
# bollards marking somebody's land, two planters, a pass reader and the dock.
# Every footprint here reaches past 300 on purpose — the walkable band starts
# there, and a solid that stops short of it is decoration.
func solids() -> Array:
	var out: Array = []
	for i in range(_PIER_X.size()):
		var px: float = float(_PIER_X[i])
		out.append(Rect2(px - 20.0, PAVE_TOP, 40.0, 38.0))
	# The dock edge. There is no railing along most of it and nobody thinks that
	# is strange.
	out.append(Rect2(-40.0, COPE_TOP - 6.0, VW + 80.0, 32.0))
	# The security line, in two runs. The gap between them is where a bollard was
	# taken out and never put back, and it happens to be the way to the chemist.
	out.append(Rect2(612.0, 400.0, 66.0, 36.0))
	out.append(Rect2(730.0, 400.0, 66.0, 36.0))
	out.append(Rect2(180.0, 384.0, 140.0, 46.0))    # planter
	out.append(Rect2(910.0, 384.0, 140.0, 46.0))    # planter
	out.append(Rect2(340.0, 362.0, 24.0, 34.0))     # the pass reader on its stalk
	out.append(Rect2(553.0, 340.0, 26.0, 44.0))     # wayfinding totem
	return out


# ── Sky ───────────────────────────────────────────────────────────────────────
# Still no blue, still a lid. But the sodium is gone: there are no shops down
# here throwing light up, so the underside of the cloud is dimmer than it is
# over the terrace two miles west.

func _draw_sky() -> void:
	if GameState.is_morning():
		draw_rect(Rect2(0, 0, VW, PAVE_TOP), Color(0.435, 0.463, 0.494))
		draw_rect(Rect2(0, 132, VW, 160), Color(0.529, 0.549, 0.565))
		return
	draw_rect(Rect2(0, 0, VW, PAVE_TOP), C_LID)
	draw_rect(Rect2(0, 88, VW, 138), C_CLOUD)
	draw_rect(Rect2(0, 196, VW, 96), C_HAZE.darkened(0.34))


# What you see through the gaps between the towers: more of the same estate,
# further away, and a crane that has been there long enough to be a landmark.
func _draw_far() -> void:
	var mass: Color = C_LID.lightened(0.12)
	if GameState.is_morning():
		mass = Color(0.380, 0.404, 0.435)
	draw_rect(Rect2(0, 148, VW, PAVE_TOP - 148.0), mass)
	for i in range(46):
		var wx: float = 8.0 + float(i) * 25.0
		var wy: float = 168.0 + float((i * 7) % 4) * 24.0
		draw_rect(Rect2(wx, wy, 7.0, 9.0), mass.lightened(0.18))
	# One tower that is not part of this street, with the light on the top of it
	draw_rect(Rect2(600.0, 52.0, 24.0, PAVE_TOP - 52.0), mass.darkened(0.14))
	draw_rect(Rect2(596.0, 46.0, 32.0, 7.0), mass)
	var blink: float = 0.5 + 0.5 * sin(_t * 1.3)
	draw_circle(Vector2(612.0, 41.0), 2.4,
		Color(C_AVIATION.r, C_AVIATION.g, C_AVIATION.b, 0.30 + 0.55 * blink))
	_draw_crane(1000.0)


func _draw_crane(x: float) -> void:
	draw_rect(Rect2(x - 4.0, 44.0, 8.0, 180.0), C_CONC_DK)
	draw_rect(Rect2(x - 70.0, 44.0, 210.0, 5.0), C_CONC_DK)
	draw_rect(Rect2(x - 3.0, 28.0, 5.0, 18.0), C_CONC_DK)
	for i in range(6):
		draw_rect(Rect2(x + 12.0 + float(i) * 22.0, 49.0, 2.0, 11.0), C_CONC_DK)


# ── The towers ────────────────────────────────────────────────────────────────

func _draw_towers() -> void:
	for i in range(_TOWERS.size()):
		var tw: Array = _TOWERS[i]
		_draw_tower(float(tw[0]), float(tw[1]), float(tw[2]), i)
	# Drawn across all six at once, because the reflected horizon lands at the
	# same height on every building. It is the only thing that makes six separate
	# towers read as one wall.
	_draw_reflected_horizon()


func _draw_tower(x: float, w: float, top: float, seed_i: int) -> void:
	var ground_y: float = PAVE_TOP - 74.0
	var body_h: float = ground_y - top
	draw_rect(Rect2(x, top, w, body_h), C_SPANDREL)
	# A spandrel band and a strip of glass, fifteen times. There is no cornice
	# to stop it and no string course to count from — the repetition IS the
	# elevation, and it is what makes the building unmeasurable by eye.
	var pitch: float = 17.0
	var rows: int = int(body_h / pitch)
	for r in range(rows):
		var fy: float = top + float(r) * pitch
		draw_rect(Rect2(x + 4.0, fy, w - 8.0, 5.0), C_SPANDREL.lightened(0.10))
		draw_rect(Rect2(x + 4.0, fy + 5.0, w - 8.0, pitch - 6.0), _pane(r, rows, seed_i))
	var bays: int = int((w - 8.0) / 21.0)
	for b in range(bays + 1):
		draw_rect(Rect2(x + 4.0 + float(b) * 21.0, top, 2.5, body_h), C_MULLION)
	# The returning corner. These are not flat and the corner is the only place
	# you can tell, so it is worth two rects.
	draw_rect(Rect2(x + w - 16.0, top, 16.0, body_h), Color(0, 0, 0, 0.22))
	draw_rect(Rect2(x, top, 10.0, body_h), Color(1, 1, 1, 0.05))
	if top > 0.0:
		_draw_tower_top(x, w, top, seed_i)
	_draw_lobby(x, w, ground_y)


# Reflective glass has no colour of its own. High up it holds the sky, low down
# it holds the water, and after hours it holds whichever floors the cleaners are
# working through.
func _pane(r: int, rows: int, seed_i: int) -> Color:
	var depth: float = float(r) / float(maxi(rows - 1, 1))
	var g: Color = C_GLASS_SKY.lerp(C_GLASS_DK, depth * 0.85)
	if GameState.is_morning():
		return g.lightened(0.07)
	if ((seed_i * 13 + r * 7) % 6) < 2:
		return C_GLASS_LIT.darkened(0.12)
	return g.darkened(0.26)


# Plant, not architecture. The top of one of these is where the air handling
# lives, and it is fenced off from the people who work under it.
func _draw_tower_top(x: float, w: float, top: float, seed_i: int) -> void:
	draw_rect(Rect2(x + 2.0, top - 18.0, w - 4.0, 18.0), C_CONC)
	draw_rect(Rect2(x + 2.0, top - 18.0, w - 4.0, 4.0), C_CONC_LT)
	for i in range(3):
		var bx: float = x + 14.0 + float(i) * ((w - 44.0) / 3.0)
		draw_rect(Rect2(bx, top - 31.0, 24.0, 13.0), C_STEEL.darkened(0.38))
	draw_rect(Rect2(x + w * 0.5 - 2.0, top - 62.0, 4.0, 31.0), C_CONC_DK)
	if GameState.is_morning():
		return
	var blink: float = 0.35 + 0.65 * absf(sin(_t * 1.6 + float(seed_i)))
	draw_circle(Vector2(x + w * 0.5, top - 64.0), 2.2,
		Color(C_AVIATION.r, C_AVIATION.g, C_AVIATION.b, blink))


# The base. Double-height, lit all night, and empty all night. This is the part
# the player stands in front of and cannot get into, and the desk inside it has
# nobody behind it at the hour they will be looking.
func _draw_lobby(x: float, w: float, ground_y: float) -> void:
	var h: float = PAVE_TOP - ground_y
	draw_rect(Rect2(x, ground_y, w, h), C_GLASS_DK)
	draw_rect(Rect2(x + 4.0, ground_y + 4.0, w - 8.0, h - 8.0), C_GLASS_LIT.darkened(0.64))
	var bays: int = int(w / 26.0)
	for b in range(bays + 1):
		draw_rect(Rect2(x + float(b) * 26.0, ground_y, 3.0, h), C_MULLION.darkened(0.22))
	draw_rect(Rect2(x + w * 0.5 - 34.0, PAVE_TOP - 28.0, 68.0, 17.0), C_STEEL.darkened(0.45))
	draw_rect(Rect2(x + w * 0.5 - 34.0, PAVE_TOP - 30.0, 68.0, 3.0), C_STEEL)
	draw_rect(Rect2(x, ground_y, w, 4.0), C_CONC_DK)


# Reads as haze if you are not looking for it, and as the reflected horizon if
# you are. Both are true.
func _draw_reflected_horizon() -> void:
	draw_rect(Rect2(0, 170, VW, 9.0), Color(0.78, 0.82, 0.87, 0.10))
	draw_rect(Rect2(0, 179, VW, 5.0), Color(0.78, 0.82, 0.87, 0.05))


# ── The railway ───────────────────────────────────────────────────────────────
# A concrete box girder on piers, crossing the plaza at first-floor level. It is
# the only thing out here that was designed to be looked at from underneath, and
# it is the only structure in the district with a visible date on it.

func _draw_viaduct() -> void:
	draw_rect(Rect2(-40.0, 96.0, VW + 80.0, 34.0), C_CONC)
	draw_rect(Rect2(-40.0, 96.0, VW + 80.0, 5.0), C_CONC_LT)
	draw_rect(Rect2(-40.0, 124.0, VW + 80.0, 6.0), C_CONC_DK)
	# Concrete only ever weathers downwards, and it does it from the joints.
	for i in range(15):
		draw_rect(Rect2(float(i) * 84.0 - 20.0, 100.0, 5.0, 30.0), Color(0, 0, 0, 0.16))
	# The line stripe. Out here the network names itself in paint and nowhere else.
	draw_rect(Rect2(-40.0, 117.0, VW + 80.0, 3.0), C_DLR.darkened(0.28))
	draw_rect(Rect2(-40.0, 130.0, VW + 80.0, 7.0), Color(0, 0, 0, 0.30))


func _draw_piers() -> void:
	for i in range(_PIER_X.size()):
		_draw_pier(float(_PIER_X[i]))


func _draw_pier(x: float) -> void:
	draw_rect(Rect2(x - 20.0, 130.0, 40.0, 200.0), C_CONC)
	draw_rect(Rect2(x - 20.0, 130.0, 7.0, 200.0), C_CONC_LT)
	draw_rect(Rect2(x + 12.0, 130.0, 8.0, 200.0), C_CONC_DK)
	draw_rect(Rect2(x - 14.0, 150.0, 6.0, 160.0), Color(0, 0, 0, 0.13))
	# Somebody flyposted it and somebody else scraped it off, badly. Two acts of
	# maintenance, neither of them about the pier.
	draw_rect(Rect2(x - 12.0, 236.0, 22.0, 26.0), Color(0.72, 0.70, 0.66, 0.16))
	draw_rect(Rect2(x - 26.0, 314.0, 52.0, 16.0), C_CONC_DK)
	draw_rect(Rect2(x - 26.0, 314.0, 52.0, 3.0), C_CONC_LT)


# Two cars, no cab, no driver, nobody looking out. It comes every ninety seconds
# whether or not anyone is on the platform, which is the most legible and least
# reassuring fact in the district.
func _draw_dlr_train() -> void:
	var cycle: float = fmod(_t, 26.0) / 26.0
	var tx: float = lerpf(-380.0, VW + 380.0, cycle)
	_draw_car(tx)
	_draw_car(tx - 168.0)
	# Parapet last, because the train stands behind it.
	draw_rect(Rect2(-40.0, 84.0, VW + 80.0, 13.0), C_CONC_LT.darkened(0.12))
	draw_rect(Rect2(-40.0, 84.0, VW + 80.0, 3.0), C_CONC_LT)


func _draw_car(x: float) -> void:
	draw_rect(Rect2(x, 44.0, 158.0, 46.0), C_STEEL.darkened(0.32))
	draw_rect(Rect2(x, 44.0, 158.0, 5.0), C_STEEL)
	draw_rect(Rect2(x, 62.0, 158.0, 6.0), C_DLR)
	var pane: Color = C_GLASS_DK.lightened(0.12)
	if not GameState.is_morning():
		pane = Color(0.902, 0.933, 0.949, 0.85)
	for i in range(6):
		draw_rect(Rect2(x + 10.0 + float(i) * 24.0, 50.0, 18.0, 12.0), pane)
	draw_rect(Rect2(x, 88.0, 158.0, 4.0), Color(0, 0, 0, 0.35))


# ── The plaza ─────────────────────────────────────────────────────────────────

func _draw_plaza() -> void:
	draw_rect(Rect2(0, PAVE_TOP, VW, QUAY_TOP - PAVE_TOP), C_GRANITE)
	_draw_slabs(PAVE_TOP, QUAY_TOP - PAVE_TOP)
	# The viaduct's shadow, hard-edged and dead straight — the only mark on the
	# whole plane, and the only shade to stand in.
	draw_rect(Rect2(0, 338, VW, 54.0), Color(0, 0, 0, 0.14))
	for i in range(_PIER_X.size()):
		var px: float = float(_PIER_X[i])
		draw_rect(Rect2(px - 18.0, PAVE_TOP, 34.0, 46.0), Color(0, 0, 0, 0.13))
	# Where the new paving stops, the dock's own setts are still under it.
	draw_rect(Rect2(0, QUAY_TOP, VW, COPE_TOP - QUAY_TOP), C_GRAN_DK)
	for c in range(int(VW / 22.0) + 1):
		draw_rect(Rect2(float(c) * 22.0, QUAY_TOP, 1.5, COPE_TOP - QUAY_TOP),
			Color(0, 0, 0, 0.20))
	draw_rect(Rect2(0, QUAY_TOP + 14.0, VW, 1.5), Color(0, 0, 0, 0.20))
	draw_rect(Rect2(0, QUAY_TOP, VW, 3.0), Color(0, 0, 0, 0.22))


# No bond and no stagger. York stone is laid in courses that break at every
# joint; this is a grid, which is why it reads as a floor and not as a street.
func _draw_slabs(top: float, height: float) -> void:
	var line: Color = Color(0, 0, 0, 0.10)
	var rows: int = int(height / 44.0) + 1
	var cols: int = int(VW / 132.0) + 1
	for r in range(rows):
		var y: float = top + float(r) * 44.0
		draw_rect(Rect2(0, y, VW, 1.5), line)
		for c in range(cols):
			draw_rect(Rect2(float(c) * 132.0, y, 1.5, 44.0), line)


# ── The basin ─────────────────────────────────────────────────────────────────
# It is not a river. It does not go anywhere. There is nothing to see in it
# except the buildings, upside down and further away than they are.

func _draw_basin() -> void:
	draw_rect(Rect2(0, COPE_TOP - 6.0, VW, 32.0), C_COPING)
	draw_rect(Rect2(0, COPE_TOP - 6.0, VW, 4.0), C_COPING.lightened(0.16))
	draw_rect(Rect2(0, WATER_TOP - 5.0, VW, 5.0), C_COPING.darkened(0.45))
	draw_rect(Rect2(0, WATER_TOP, VW, VH - WATER_TOP), C_WATER)
	_draw_reflections()
	for i in range(6):
		_draw_mooring(64.0 + float(i) * 208.0)
	_draw_gull(344.0, COPE_TOP - 3.0, 0)
	_draw_gull(706.0, COPE_TOP - 3.0, 1)


func _draw_reflections() -> void:
	var wob: float = sin(_t * 0.4) * 2.0
	for i in range(_TOWERS.size()):
		var tw: Array = _TOWERS[i]
		var x: float = float(tw[0])
		var w: float = float(tw[1])
		draw_rect(Rect2(x + 8.0 + wob, WATER_TOP, w - 16.0, VH - WATER_TOP),
			Color(C_WATER_LT.r, C_WATER_LT.g, C_WATER_LT.b, 0.16))
	# Flat bands, not ripples. Dock water inside a basin barely moves, and that
	# stillness is what makes it read as depth rather than as a surface.
	for r in range(7):
		var y: float = WATER_TOP + 8.0 + float(r) * 17.0
		var a: float = 0.05 + 0.03 * sin(_t * 0.7 + float(r) * 0.9)
		draw_rect(Rect2(0, y, VW, 3.0), Color(0.62, 0.70, 0.78, a))


# Cast iron, still bolted where it was bolted. They were kept because they are
# listed, so the only honest object in the district survives on a technicality.
func _draw_mooring(x: float) -> void:
	draw_rect(Rect2(x - 11.0, COPE_TOP - 22.0, 22.0, 24.0), C_IRON)
	draw_rect(Rect2(x - 11.0, COPE_TOP - 18.0, 5.0, 18.0), C_IRON.lightened(0.12))
	draw_rect(Rect2(x - 14.0, COPE_TOP - 26.0, 28.0, 6.0), C_IRON.lightened(0.18))
	draw_rect(Rect2(x - 13.0, COPE_TOP + 2.0, 26.0, 4.0), Color(0, 0, 0, 0.35))


# ── Street furniture ──────────────────────────────────────────────────────────
# Six objects on a plaza you could land a plane on, and five of them are there
# to stop you doing something.

func _draw_furniture() -> void:
	_draw_security_line(612.0, 730.0)
	_draw_planter(250.0)
	_draw_planter(980.0)
	_draw_pass_reader(352.0)
	_draw_totem(566.0)
	_draw_flying_gull()


# The boundary of somebody's land, in stainless steel and nothing else. No gate,
# no sign, no notice — you simply cannot walk here. The one place you can is
# where a bollard was taken out for a delivery and never put back.
func _draw_security_line(a: float, b: float) -> void:
	for i in range(3):
		_draw_bollard(a + 11.0 + float(i) * 22.0)
		_draw_bollard(b + 11.0 + float(i) * 22.0)
	draw_rect(Rect2(700.0, 428.0, 22.0, 8.0), C_STEEL.darkened(0.42))
	draw_rect(Rect2(700.0, 428.0, 22.0, 2.0), C_STEEL)


func _draw_bollard(x: float) -> void:
	draw_rect(Rect2(x - 8.0, 400.0, 16.0, 36.0), C_STEEL.darkened(0.30))
	draw_rect(Rect2(x - 8.0, 400.0, 5.0, 36.0), C_STEEL)
	draw_rect(Rect2(x - 8.0, 400.0, 16.0, 4.0), C_STEEL.lightened(0.20))
	draw_rect(Rect2(x - 9.0, 434.0, 18.0, 4.0), Color(0, 0, 0, 0.30))


# A hedge that arrived on a lorry at the size it is now and will be replaced at
# the same size. The only green in the frame, and it is furniture.
func _draw_planter(x: float) -> void:
	draw_rect(Rect2(x - 70.0, 384.0, 140.0, 46.0), C_GRANITE.lightened(0.10))
	draw_rect(Rect2(x - 70.0, 384.0, 140.0, 5.0), C_GRANITE.lightened(0.26))
	draw_rect(Rect2(x - 70.0, 424.0, 140.0, 6.0), C_GRAN_DK)
	draw_rect(Rect2(x - 64.0, 366.0, 128.0, 22.0), C_MOSS.darkened(0.20))
	for i in range(7):
		draw_rect(Rect2(x - 62.0 + float(i) * 18.0, 361.0, 15.0, 12.0), C_MOSS)
	draw_rect(Rect2(x - 70.0, 430.0, 142.0, 5.0), Color(0, 0, 0, 0.24))


# A card reader on a stalk in the middle of the plaza, wired to nothing you can
# see. The guard stands beside it because it is the only object out here that
# gives a person somewhere to be.
func _draw_pass_reader(x: float) -> void:
	draw_rect(Rect2(x - 5.0, 362.0, 10.0, 34.0), C_STEEL.darkened(0.42))
	draw_rect(Rect2(x - 22.0, 344.0, 44.0, 22.0), C_STEEL.darkened(0.30))
	draw_rect(Rect2(x - 18.0, 348.0, 36.0, 13.0), C_GLASS_DK)
	var pulse: float = 0.45 + 0.55 * absf(sin(_t * 2.2))
	draw_rect(Rect2(x + 5.0, 350.0, 9.0, 4.0), Color(C_DLR.r, C_DLR.g, C_DLR.b, pulse))
	draw_rect(Rect2(x - 12.0, 392.0, 24.0, 4.0), Color(0, 0, 0, 0.28))


# Wayfinding. A lit map of the place you are already standing in, oriented to
# nothing, listing eleven buildings that are the same building.
func _draw_totem(x: float) -> void:
	draw_rect(Rect2(x - 13.0, 218.0, 26.0, 166.0), C_STEEL.darkened(0.44))
	draw_rect(Rect2(x - 13.0, 218.0, 5.0, 166.0), C_STEEL.darkened(0.22))
	draw_rect(Rect2(x - 10.0, 236.0, 20.0, 118.0), C_GLASS_LIT.darkened(0.22))
	for i in range(8):
		draw_rect(Rect2(x - 7.0, 244.0 + float(i) * 13.0, 14.0, 3.0),
			C_IRON.lightened(0.32))
	draw_rect(Rect2(x - 7.0, 224.0, 14.0, 8.0), C_DLR)
	draw_rect(Rect2(x - 14.0, 380.0, 28.0, 5.0), Color(0, 0, 0, 0.28))


# ── Gulls ─────────────────────────────────────────────────────────────────────
# Berlin has nobody on the pavement, Istanbul has cats on everything. This place
# has herring gulls: they came for the fish dock, stayed for the sandwiches, and
# they are the only thing in the district moving without a pass.

func _draw_gull(x: float, y: float, pose: int) -> void:
	var bob: float = sin(_t * 0.9 + x * 0.05) * 0.8
	var body: Color = Color(0.902, 0.910, 0.898)
	draw_rect(Rect2(x - 2.0, y - 5.0, 2.0, 5.0), Color(0.86, 0.72, 0.24))
	draw_rect(Rect2(x + 2.0, y - 5.0, 2.0, 5.0), Color(0.86, 0.72, 0.24))
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 9.0, y - 6.0 + bob), Vector2(x + 6.0, y - 9.0 + bob),
		Vector2(x + 10.0, y - 5.0 + bob), Vector2(x - 6.0, y - 3.0 + bob),
	]), body)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 10.0, y - 7.0 + bob), Vector2(x - 2.0, y - 8.0 + bob),
		Vector2(x - 4.0, y - 4.0 + bob),
	]), C_STEEL.darkened(0.30))
	draw_circle(Vector2(x + 8.0, y - 12.0 + bob), 4.0, body.lightened(0.06))
	draw_rect(Rect2(x + 11.0, y - 13.0 + bob, 5.0, 2.0), Color(0.902, 0.706, 0.169))
	draw_circle(Vector2(x + 9.0, y - 13.0 + bob), 1.0, Color(0.08, 0.08, 0.09))
	if pose == 1:
		# One of them has decided to be taller than the other one.
		draw_rect(Rect2(x - 14.0, y - 8.0 + bob, 8.0, 3.0), body)


func _draw_flying_gull() -> void:
	var cycle: float = fmod(_t * 0.06, 1.0)
	var gx: float = lerpf(-40.0, VW + 40.0, cycle)
	var gy: float = 208.0 + sin(cycle * 6.0) * 26.0
	var flap: float = sin(_t * 5.0) * 7.0
	var body: Color = Color(0.902, 0.910, 0.898)
	draw_line(Vector2(gx - 13.0, gy - flap), Vector2(gx, gy), body, 2.6)
	draw_line(Vector2(gx, gy), Vector2(gx + 13.0, gy - flap), body, 2.6)
