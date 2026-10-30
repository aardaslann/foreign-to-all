extends Node2D

# Berlin. The first city in the game, and until now the only one still drawn
# on the prototype's architecture - flat blocks with square holes in them,
# while nineteen other cities had been rebuilt around it. This is the port.
#
# What makes a Berlin street look like Berlin is the ALTBAU: five storeys of
# stuccoed brick from the 1870s boom, with a heavy cornice, a string course
# between the first and second floors, tall windows that get shorter as they
# go up, and a carriage arch through the middle of the block. Behind that arch
# is a Hinterhof - a courtyard with another building in it, and often another
# arch and another courtyard behind that. Half the city lives at the back.
#
# The other half of the vocabulary is what got built after: Plattenbau slabs
# in the east, poured in sections and craned into place, and the gaps where
# the war took a building out and nothing replaced it - Brandmauer, a blank
# party wall three storeys high with the ghost of a roofline on it.
#
# Over all of it the FERNSEHTURM: 368 metres, a sphere on a concrete shaft,
# put up by a government that wanted to be seen from the other side. You
# cannot get away from it and the plates do not let you.
#
# Ground bands are Berlin gauge, which is this city's gauge: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "mitte"
# "mitte" | "kiez" | "prenzlberg" | "kreuzberg" | "ost"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
# Berlin stucco is not cream. It is a cold grey-green-ochre that goes almost
# lilac at dusk, and the brick behind it where it has come off is dark red.
const C_SKY_ZEN  := Color(0.055, 0.051, 0.114)
const C_SKY_MID  := Color(0.094, 0.086, 0.169)
const C_SKY_LOW  := Color(0.200, 0.145, 0.192)
const C_SKY_HAZE := Color(0.345, 0.204, 0.184)

const C_DAY_HI   := Color(0.424, 0.549, 0.690)
const C_DAY_MID  := Color(0.612, 0.678, 0.729)
const C_DAY_LOW  := Color(0.812, 0.804, 0.769)

const C_STUCCO   := Color(0.729, 0.706, 0.639)    # Altbau render
const C_STUCCO_B := Color(0.639, 0.612, 0.549)
const C_STUCCO_D := Color(0.510, 0.486, 0.435)
const C_BRICK    := Color(0.478, 0.290, 0.243)    # where the render came off
const C_PLATTE   := Color(0.671, 0.663, 0.635)    # panel block
const C_PLATTE_D := Color(0.541, 0.537, 0.518)
const C_ZINC     := Color(0.376, 0.388, 0.427)    # roofs
const C_GLASS    := Color(0.145, 0.169, 0.208)
const C_IRON     := Color(0.157, 0.161, 0.176)
const C_WARM     := Color(1.0, 0.855, 0.596)
const C_INK      := Color(0.106, 0.102, 0.098)
const C_LEAF     := Color(0.216, 0.322, 0.239)
const C_TOWER    := Color(0.749, 0.741, 0.722)    # the Fernsehturm shaft
const C_SPHERE   := Color(0.831, 0.827, 0.812)    # and its sphere
const C_TAG      := Color(0.847, 0.263, 0.235)    # everything at arm's height
# What is on a Berlin ground floor. Spaeti is the corner shop that is open
# when nothing else is, and there is one on nearly every block.
const BERLIN_TRADES := ["bakery", "pharmacy", "grocer", "cafe", "bar",
	"barber", "clothes", "post", "laundry", "books"]

const TAG_HUES := [Color(0.847, 0.263, 0.235), Color(0.259, 0.478, 0.788),
	Color(0.949, 0.827, 0.278)]

const GROUND_Y := 238.0

# The opening in the street wall the television tower stands in.
const TOWER_L := 742.0
const TOWER_R := 986.0


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
			C_TAG.darkened(0.30), C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_STUCCO, C_INK, not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"kiez":       _draw_kiez()
		"prenzlberg": _draw_prenzlberg()
		"kreuzberg":  _draw_kreuzberg()
		"ost":        _draw_ost()
		_:            _draw_mitte()
	CA.ground_floor(self, GROUND_Y, C_STUCCO_D.darkened(0.24), C_GLASS, C_WARM,
		not GameState.is_morning(), 2, BERLIN_TRADES)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	CA.air(self, Color(0.24, 0.24, 0.32), 0.05)
	CA.vignette(self, 0.28)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.04))
		return
	CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)


# ── Altbau ───────────────────────────────────────────────────────────────────
# The 1870s tenement, which is most of the buildings in this city. Five
# storeys, a heavy cornice, a string course under the first floor, windows
# that shorten as they rise, and a carriage arch through to the courtyard.
func _altbau(x: float, w: float, top: float, lit: int, arch: bool) -> void:
	CA.block(self, x, w, top, GROUND_Y, C_STUCCO, C_STUCCO_B)
	# The cornice: three courses, the middle one proud of the others.
	draw_rect(Rect2(x - 7.0, top - 14.0, w + 14.0, 8.0), C_STUCCO_D)
	draw_rect(Rect2(x - 10.0, top - 6.0, w + 20.0, 6.0), C_STUCCO.lightened(0.12))
	draw_rect(Rect2(x - 4.0, top, w + 8.0, 4.0), C_STUCCO_D.darkened(0.18))
	CA.roof(self, x, w, top - 14.0, 20.0, C_ZINC)
	# Dormers in the roof, because the top floor was always the cheapest.
	for d in range(maxi(1, int(w / 60.0))):
		var dx: float = x + w * (float(d) + 0.5) / float(maxi(1, int(w / 60.0)))
		draw_rect(Rect2(dx - 10.0, top - 30.0, 20.0, 18.0), C_ZINC.lightened(0.14))
		CA.window(self, dx - 6.0, top - 26.0, 12.0, 12.0, C_GLASS,
			C_ZINC.lightened(0.24), (lit >> d) & 1 == 1)

	var floors: int = 5
	var fh: float = (GROUND_Y - top) / float(floors)
	for f in range(floors):
		var fy: float = top + fh * float(f) + 9.0
		# Windows shorten as they go up: the piano nobile is the first floor.
		var wh: float = fh - 20.0 - float(f) * 1.6
		var count: int = maxi(2, int(w / 42.0))
		CA.window_row(self, x + 9.0, w - 18.0, fy, count, 16.0, wh,
			C_GLASS, C_STUCCO_D, lit >> f)
		# The string course between ground and first, and a lighter band above.
		if f == 1:
			draw_rect(Rect2(x - 3.0, fy - 9.0, w + 6.0, 5.0), C_STUCCO_D)
		if f == 0:
			draw_rect(Rect2(x, top + fh - 6.0, w, 3.0), C_STUCCO_D.darkened(0.10))
		# Window surrounds on the good floors only.
		if f <= 1:
			for c in range(count):
				var cx: float = x + 9.0 + (w - 18.0) * (float(c) + 0.5) / float(count)
				draw_rect(Rect2(cx - 12.0, fy - 5.0, 24.0, 4.0),
					C_STUCCO.lightened(0.16))
	if arch:
		# The Hofeinfahrt. Behind it another building, and often another arch.
		var ax: float = x + w * 0.5
		draw_rect(Rect2(ax - 30.0, GROUND_Y - 74.0, 60.0, 74.0), C_STUCCO_D)
		draw_rect(Rect2(ax - 24.0, GROUND_Y - 62.0, 48.0, 62.0),
			Color(0.086, 0.078, 0.086))
		draw_circle(Vector2(ax, GROUND_Y - 62.0), 24.0, Color(0.086, 0.078, 0.086))
		draw_circle(Vector2(ax, GROUND_Y - 62.0), 24.0, C_STUCCO_D)
		draw_rect(Rect2(ax - 24.0, GROUND_Y - 62.0, 48.0, 62.0),
			Color(0.086, 0.078, 0.086))
		# A light on in the courtyard beyond it.
		if not GameState.is_morning():
			draw_rect(Rect2(ax - 12.0, GROUND_Y - 48.0, 24.0, 30.0),
				Color(0.35, 0.29, 0.20))


# ── The districts ────────────────────────────────────────────────────────────

func _draw_mitte() -> void:
	CA.far_mass(self, 178.0, C_STUCCO_D.darkened(0.44),
		C_STUCCO_D.darkened(0.26), 10, 17)
	_draw_fernsehturm(858.0)
	var x: float = -30.0
	var i: int = 0
	while x < CA.VW + 30.0:
		var w: float = 124.0 + float((i * 19) % 3) * 22.0
		# Skip any building that OVERLAPS the gap, not just one that
		# starts in it - that was how the tower ended up behind a wall.
		if x + w < TOWER_L or x > TOWER_R:
			_altbau(x, w, 74.0 + float((i * 13) % 2) * 10.0,
				(i * 37) % 63, i % 3 == 1)
		x += w + 5.0
		i += 1


func _draw_kiez() -> void:
	CA.far_mass(self, 196.0, C_STUCCO_D.darkened(0.46),
		C_STUCCO_D.darkened(0.28), 9, 29)
	var x: float = -30.0
	var i: int = 0
	while x < CA.VW + 30.0:
		var w: float = 116.0 + float((i * 17) % 3) * 20.0
		_altbau(x, w, 92.0 + float((i * 7) % 3) * 8.0, (i * 23) % 63, i % 4 == 2)
		# A Brandmauer: a blank party wall where the neighbour was taken out
		# and never replaced, with the ghost of its roofline still on it.
		if i % 5 == 3:
			_brandmauer(x + w + 3.0, 96.0)
		x += w + 4.0
		i += 1
	_draw_tags()


func _brandmauer(x: float, top: float) -> void:
	draw_rect(Rect2(x, top, 74.0, GROUND_Y - top), C_BRICK.darkened(0.20))
	# The pitch of the roof that used to lean on it.
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, top + 34.0), Vector2(x + 37.0, top + 6.0),
		Vector2(x + 74.0, top + 34.0), Vector2(x + 74.0, top + 44.0),
		Vector2(x, top + 44.0),
	]), C_BRICK.darkened(0.34))
	for r in range(int((GROUND_Y - top) / 9.0)):
		draw_rect(Rect2(x, top + float(r) * 9.0, 74.0, 1.4),
			C_BRICK.darkened(0.30))


func _draw_prenzlberg() -> void:
	CA.far_mass(self, 202.0, C_STUCCO_D.darkened(0.44),
		C_STUCCO_D.darkened(0.26), 8, 41)
	var x: float = -30.0
	var i: int = 0
	while x < CA.VW + 30.0:
		var w: float = 130.0 + float((i * 11) % 3) * 18.0
		_altbau(x, w, 66.0, (i * 29) % 63, i % 3 == 0)
		x += w + 4.0
		i += 1
	# The elevated U2 viaduct, on iron trestles down the middle of the street.
	var deck: float = 196.0
	draw_rect(Rect2(0.0, deck, CA.VW, 20.0), C_IRON.lightened(0.10))
	draw_rect(Rect2(0.0, deck + 20.0, CA.VW, 5.0), C_IRON.lightened(0.18))
	for p in range(7):
		var px: float = 46.0 + float(p) * 176.0
		draw_rect(Rect2(px - 8.0, deck + 25.0, 16.0, CA.PAVE_TOP - deck - 25.0),
			C_IRON.lightened(0.06))
		draw_rect(Rect2(px - 22.0, deck + 25.0, 44.0, 7.0), C_IRON.lightened(0.14))
		for b in range(3):
			draw_line(Vector2(px - 8.0, deck + 40.0 + float(b) * 20.0),
				Vector2(px + 8.0, deck + 52.0 + float(b) * 20.0),
				C_IRON.lightened(0.16), 1.4)


func _draw_kreuzberg() -> void:
	CA.far_mass(self, 190.0, C_BRICK.darkened(0.46), C_BRICK.darkened(0.28),
		9, 53)
	var x: float = -30.0
	var i: int = 0
	while x < CA.VW + 30.0:
		var w: float = 112.0 + float((i * 13) % 3) * 24.0
		if i % 4 == 3:
			_platte(x, w, 84.0, (i * 19) % 63)
		else:
			_altbau(x, w, 88.0 + float((i * 5) % 2) * 12.0, (i * 31) % 63,
				i % 3 == 1)
		x += w + 4.0
		i += 1
	_draw_tags()


func _draw_ost() -> void:
	CA.far_mass(self, 168.0, C_PLATTE_D.darkened(0.44),
		C_PLATTE_D.darkened(0.26), 11, 61)
	_draw_fernsehturm(320.0)
	var x: float = -30.0
	var i: int = 0
	while x < CA.VW + 30.0:
		var w: float = 168.0 + float((i * 7) % 2) * 30.0
		if x < 190.0 or x > 470.0:
			_platte(x, w, 58.0 + float((i * 11) % 2) * 16.0, (i * 43) % 63)
		x += w + 6.0
		i += 1


# The panel block: poured in sections in a yard and craned into place, so the
# joints between the panels are the only articulation the facade has.
func _platte(x: float, w: float, top: float, lit: int) -> void:
	CA.block(self, x, w, top, GROUND_Y, C_PLATTE, C_PLATTE_D)
	var rows: int = int((GROUND_Y - top) / 26.0)
	var cols: int = maxi(3, int(w / 44.0))
	for r in range(rows):
		var ry: float = top + float(r) * 26.0
		draw_rect(Rect2(x, ry, w, 2.0), C_PLATTE_D.darkened(0.14))
		for c in range(cols):
			var cx: float = x + w * (float(c) + 0.5) / float(cols)
			draw_rect(Rect2(cx - 1.0, ry, 2.0, 26.0), C_PLATTE_D.darkened(0.10))
			var on: bool = ((r * 7 + c * 5 + lit) % 6) < 2 \
				and not GameState.is_morning()
			draw_rect(Rect2(cx - 13.0, ry + 7.0, 26.0, 14.0),
				Color(0.36, 0.33, 0.24) if on else C_GLASS)
	draw_rect(Rect2(x - 3.0, top - 7.0, w + 6.0, 7.0), C_PLATTE_D)


# Graffiti at arm's height on absolutely everything, which is not vandalism
# here so much as the surface finish.
func _draw_tags() -> void:
	for i in range(11):
		var tx: float = 40.0 + float(i) * 104.0
		var ty: float = GROUND_Y - 34.0 - float((i * 13) % 3) * 8.0
		var hue: Color = TAG_HUES[i % TAG_HUES.size()]
		for k in range(4):
			draw_rect(Rect2(tx + float(k) * 9.0, ty - float((k * 7) % 3) * 4.0,
				6.0, 16.0), Color(hue.r, hue.g, hue.b, 0.55))


# ── The Fernsehturm ──────────────────────────────────────────────────────────
# 368 metres. A concrete shaft with a steel sphere on it and a spire above
# that, put up by a government that wanted the other half of the city to have
# to look at it.
#
# The joke it is best known for is an accident: the sphere is faceted, so in
# sunlight the reflection lands on it as a cross. The state could not get rid
# of it and the city has never stopped calling it the Pope's Revenge.
func _draw_fernsehturm(cx: float) -> void:
	var morning: bool = GameState.is_morning()
	var shaft: Color = C_TOWER if morning else C_TOWER.darkened(0.30)
	var ball: Color = C_SPHERE if morning else C_SPHERE.darkened(0.24)
	var sphere_y: float = 96.0
	var r: float = 40.0

	var pts := PackedVector2Array([
		Vector2(cx - 26.0, GROUND_Y), Vector2(cx + 26.0, GROUND_Y),
		Vector2(cx + 13.0, sphere_y), Vector2(cx - 13.0, sphere_y),
	])
	draw_colored_polygon(pts, shaft)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 26.0, GROUND_Y), Vector2(cx - 12.0, GROUND_Y),
		Vector2(cx - 6.0, sphere_y), Vector2(cx - 13.0, sphere_y),
	]), shaft.lightened(0.10))

	# The sphere is faceted, so it is a stack of bands rather than a circle,
	# which is also how it catches the light.
	draw_circle(Vector2(cx, sphere_y), r, ball)
	for k in range(7):
		var f: float = float(k) / 6.0
		var y: float = sphere_y - r + f * r * 2.0
		var half: float = sqrt(maxf(r * r - (y - sphere_y) * (y - sphere_y), 0.0))
		draw_rect(Rect2(cx - half, y, half * 2.0, 2.0), ball.darkened(0.16))
	var band: Color = Color(0.36, 0.33, 0.24)
	if morning:
		band = C_GLASS.lightened(0.10)
	draw_rect(Rect2(cx - r + 4.0, sphere_y - 10.0, (r - 4.0) * 2.0, 13.0), band)
	draw_rect(Rect2(cx - r + 9.0, sphere_y + 9.0, (r - 9.0) * 2.0, 9.0),
		C_GLASS.lightened(0.06))
	if morning:
		draw_rect(Rect2(cx - 3.0, sphere_y - 26.0, 6.0, 52.0),
			Color(1.0, 1.0, 1.0, 0.60))
		draw_rect(Rect2(cx - 20.0, sphere_y - 9.0, 40.0, 6.0),
			Color(1.0, 1.0, 1.0, 0.60))

	# The spire, which is another eighty metres and always forgotten.
	draw_colored_polygon(PackedVector2Array([
		Vector2(cx - 9.0, sphere_y - r + 6.0), Vector2(cx + 9.0, sphere_y - r + 6.0),
		Vector2(cx + 3.0, 8.0), Vector2(cx - 3.0, 8.0),
	]), shaft.darkened(0.06))
	draw_rect(Rect2(cx - 1.5, -14.0, 3.0, 24.0), shaft.darkened(0.14))
	if not morning:
		var pulse: float = 0.4 + 0.6 * absf(sin(_t * 1.6))
		draw_circle(Vector2(cx, 10.0), 3.0, Color(0.95, 0.32, 0.26, pulse))


# ── Ground and furniture ─────────────────────────────────────────────────────

func _draw_ground() -> void:
	var pave := Color(0.416, 0.408, 0.400)
	var road := Color(0.169, 0.169, 0.184)
	CA.ground(self, pave, road, pave.darkened(0.12))
	# Berlin pavement is small granite setts with a band of larger slabs down
	# the middle of it, and the kerb is granite as well.
	CA.slabs(self, CA.PAVE_TOP, 80.0, 26.0, 26.0, pave.lightened(0.12))
	CA.slabs(self, CA.PAVE_TOP + 26.0, 28.0, 60.0, 28.0,
		pave.lightened(0.18), false)
	CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.22))
	CA.kerb(self, CA.FAR_TOP, pave.lightened(0.22))
	CA.slabs(self, CA.FAR_TOP, 132.0, 26.0, 26.0, pave.lightened(0.09))
	if district == "prenzlberg":
		CA.setts(self, CA.ROAD_TOP, 144.0, 15.0,
			Color(0.129, 0.125, 0.145, 0.50))
	if not GameState.is_morning():
		CA.sheen(self, CA.ROAD_TOP, 144.0, Color(0.30, 0.28, 0.42, 0.13), _t)


func _draw_furniture() -> void:
	var on: bool = not GameState.is_morning()
	for i in range(5):
		CA.lamp(self, 92.0 + float(i) * 244.0, CA.PAVE_TOP + 62.0, 96.0,
			C_IRON, C_WARM, on)
	match district:
		"kiez":
			_litfass(232.0)
			_u_sign(648.0)
			CA.bin(self, 880.0, CA.PAVE_TOP + 64.0, Color(0.267, 0.271, 0.278))
		"prenzlberg":
			for i in range(4):
				CA.tree(self, 150.0 + float(i) * 260.0, CA.PAVE_TOP + 4.0, 78.0,
					Color(0.365, 0.310, 0.259), C_LEAF, 1.1)
		"kreuzberg":
			CA.crates(self, 320.0, CA.PAVE_TOP + 58.0, 3, 2,
				Color(0.494, 0.373, 0.278))
		"ost":
			_litfass(760.0)
			_u_sign(180.0)
			_bus_stop(452.0)
		_:
			_litfass(196.0)
			_u_sign(496.0)
			_bus_stop(760.0)
			CA.bin(self, 1064.0, CA.PAVE_TOP + 64.0, Color(0.267, 0.271, 0.278))
	if on:
		CA.motes(self, 22, Color(0.90, 0.88, 0.80, 0.08), _t, 10.0, 20.0, 1.3)


# The Litfasssaeule: a fat cylinder of posters, invented in this city in 1854
# because it was sick of people flyposting on walls. It worked, and it stayed.
func _litfass(x: float) -> void:
	var base: float = CA.PAVE_TOP + 64.0
	draw_rect(Rect2(x - 24.0, base - 96.0, 48.0, 96.0), Color(0.235, 0.220, 0.216))
	for p in range(4):
		var pc: Color = TAG_HUES[p % TAG_HUES.size()].darkened(0.52)
		pc = pc.lerp(Color(0.400, 0.376, 0.353), 0.38)
		draw_rect(Rect2(x - 22.0 + float(p) * 12.0, base - 88.0, 10.0, 74.0), pc)
		draw_rect(Rect2(x - 22.0 + float(p) * 12.0, base - 88.0, 10.0, 5.0),
			pc.lightened(0.22))
		# A corner curling off, which every one of these has.
		draw_rect(Rect2(x - 22.0 + float(p) * 12.0, base - 34.0, 5.0, 8.0),
			pc.darkened(0.30))
	draw_rect(Rect2(x - 27.0, base - 104.0, 54.0, 10.0), Color(0.176, 0.165, 0.161))
	# A shallow cap, not a ball. Drawn as a full circle it sat on top of
	# the column like a bowling ball.
	var cap := PackedVector2Array()
	for k in range(13):
		var a: float = PI + PI * float(k) / 12.0
		cap.append(Vector2(x + cos(a) * 27.0, base - 104.0 + sin(a) * 15.0))
	cap.append(Vector2(x + 27.0, base - 104.0))
	cap.append(Vector2(x - 27.0, base - 104.0))
	draw_colored_polygon(cap, Color(0.176, 0.165, 0.161))


# ── Collision ────────────────────────────────────────────────────────────────

func solids() -> Array[Rect2]:
	var out: Array[Rect2] = []
	if district == "kreuzberg":
		out.append(Rect2(320.0, 336.0, 74.0, 18.0))
	return out


# The U on its blue square. It has meant the same thing on this street since
# 1902, and it is the first sign in the game the alien can trust, because it
# is a shape and not a word.
func _u_sign(x: float) -> void:
	var y: float = CA.PAVE_TOP - 96.0
	draw_rect(Rect2(x - 2.5, y, 5.0, 96.0), Color(0.10, 0.10, 0.11))
	draw_rect(Rect2(x - 24.0, y - 46.0, 48.0, 48.0), Color(0.05, 0.22, 0.55))
	draw_rect(Rect2(x - 24.0, y - 46.0, 48.0, 48.0),
		Color(0.85, 0.88, 0.92), false, 2.0)
	draw_rect(Rect2(x - 12.0, y - 38.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x + 6.0, y - 38.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x - 12.0, y - 20.0, 24.0, 6.0), Color(0.94, 0.96, 0.98))


# The stop: a glass shelter, a bench in it, a lit timetable case, and the H on
# a pole out at the kerb - which is what marks a bus stop in this country, and
# is another shape rather than a word.
func _bus_stop(x: float) -> void:
	var base: float = CA.PAVE_TOP + 66.0
	var top: float = base - 104.0
	var on: bool = not GameState.is_morning()
	draw_rect(Rect2(x - 76.0, top, 152.0, 8.0), Color(0.208, 0.216, 0.231))
	draw_rect(Rect2(x - 76.0, top + 8.0, 8.0, 96.0), Color(0.208, 0.216, 0.231))
	draw_rect(Rect2(x + 68.0, top + 8.0, 8.0, 96.0), Color(0.208, 0.216, 0.231))
	draw_rect(Rect2(x - 68.0, top + 8.0, 136.0, 74.0),
		Color(0.271, 0.310, 0.353, 0.50))
	draw_rect(Rect2(x - 52.0, base - 34.0, 104.0, 7.0), Color(0.443, 0.365, 0.286))
	draw_rect(Rect2(x - 46.0, base - 27.0, 6.0, 27.0), Color(0.208, 0.216, 0.231))
	draw_rect(Rect2(x + 40.0, base - 27.0, 6.0, 27.0), Color(0.208, 0.216, 0.231))
	var case: Color = Color(0.647, 0.596, 0.451)
	if on:
		case = Color(0.925, 0.882, 0.741)
	draw_rect(Rect2(x + 24.0, top + 20.0, 36.0, 48.0), case)
	for r in range(7):
		draw_rect(Rect2(x + 28.0, top + 25.0 + float(r) * 6.0, 28.0, 2.0),
			Color(0.294, 0.278, 0.251))
	var px: float = x - 98.0
	draw_rect(Rect2(px - 2.5, base - 112.0, 5.0, 112.0), Color(0.208, 0.216, 0.231))
	draw_circle(Vector2(px, base - 118.0), 21.0, Color(0.161, 0.169, 0.184))
	draw_circle(Vector2(px, base - 118.0), 17.0, Color(0.945, 0.812, 0.208))
	draw_rect(Rect2(px - 8.0, base - 129.0, 4.0, 22.0), Color(0.129, 0.125, 0.118))
	draw_rect(Rect2(px + 4.0, base - 129.0, 4.0, 22.0), Color(0.129, 0.125, 0.118))
	draw_rect(Rect2(px - 8.0, base - 120.0, 16.0, 4.0), Color(0.129, 0.125, 0.118))


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	if district != "kreuzberg":
		return []
	return [
		[Vector2(900.0, CA.PAVE_TOP + 64.0), 0, 0],
	]
