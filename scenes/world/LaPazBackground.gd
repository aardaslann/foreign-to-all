extends Node2D

# La Paz and El Alto. The last city, and the only one built on a slope steep
# enough that its mass transit had to leave the ground.
#
# EL ALTO sits on the rim at four thousand metres: thousands of low unfinished
# brick houses, unpainted, unrendered, with rebar still standing out of the roof
# slab because a floor might go on later. Dusty unmade roads. It is ochre-red
# for kilometres, and it is not poverty being depicted - it is a city that
# builds upward when it can afford to and leaves the steel showing meanwhile.
#
# Among them, the CHOLETS: neo-Andean buildings in sharp geometry, mirrored
# glass and colours taken straight off Aymara textiles, with a ballroom on the
# first floor and the owner living on the top. They were built by people who
# were told their culture was something to keep indoors, and they are the
# loudest facades in the game on purpose.
#
# MERCADO RODRIGUEZ is the stepped market street in the bowl below. SOPOCACHI
# is middle-class, treed, and calm. IRPAVI is the bottom of the valley, six
# hundred metres lower and noticeably greener, which is why the rich moved there.
#
# The altitude does the lighting: the sky is nearly black-blue at the zenith
# even at noon, the sun is violent, and shadows have hard edges. Nowhere else
# on the itinerary gets that.
#
# Ground bands are Berlin gauge, untouched: 292 / 372 / 516.

const CA := preload("res://scenes/world/CityArt.gd")

@export var district: String = "elalto"
# "elalto" | "rodriguez" | "sopocachi" | "irpavi" | "sanpedro"

var _t: float = 0.0
var _doors: Array = []

# ── Palette ───────────────────────────────────────────────────────────────────
const C_SKY_ZEN  := Color(0.043, 0.043, 0.110)
const C_SKY_MID  := Color(0.067, 0.063, 0.145)
const C_SKY_LOW  := Color(0.153, 0.110, 0.169)
const C_SKY_HAZE := Color(0.271, 0.161, 0.153)

# Altiplano daylight: the zenith stays deep because there is a third less
# atmosphere above it, and the horizon burns.
const C_DAY_HI   := Color(0.243, 0.408, 0.639)
const C_DAY_MID  := Color(0.494, 0.616, 0.729)
const C_DAY_LOW  := Color(0.796, 0.769, 0.706)

const C_BRICK    := Color(0.694, 0.451, 0.333)
const C_BRICK_B  := Color(0.612, 0.396, 0.298)
const C_BRICK_D  := Color(0.478, 0.310, 0.243)
const C_CONC     := Color(0.639, 0.627, 0.588)
const C_REBAR    := Color(0.353, 0.318, 0.286)
const C_GLASS    := Color(0.176, 0.208, 0.239)
const C_DUST     := Color(0.702, 0.588, 0.463)
const C_TIN      := Color(0.482, 0.478, 0.463)

# The cholet palette, and the only saturated colour in the country that belongs
# on architecture rather than on cloth.
const C_AY_BLUE  := Color(0.129, 0.435, 0.545)
const C_AY_GOLD  := Color(0.898, 0.612, 0.129)
const C_AY_RED   := Color(0.741, 0.180, 0.212)
const C_AY_GREEN := Color(0.169, 0.518, 0.373)

const C_LAMP     := Color(1.0, 0.831, 0.573)
const C_JOINT    := Color(0.106, 0.078, 0.063, 0.26)

const GROUND_Y := 236.0


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
			C_AY_GOLD, C_GLASS, _t)
		InteriorArt.fascia(self, x, GROUND_Y - 78.0, String(d["label"]),
			C_AY_BLUE, Color(0.95, 0.93, 0.88), not GameState.is_morning())


func _draw() -> void:
	CA.void_fill(self)
	_draw_sky()
	match district:
		"rodriguez": _draw_rodriguez()
		"sopocachi": _draw_sopocachi()
		"irpavi":    _draw_irpavi()
		"sanpedro":  _draw_sanpedro()
		_:           _draw_elalto()
	# The storey the shops are in, between the upper floors and the
	# pavement. The doors draw over the top of it.
	CA.ground_floor(self, GROUND_Y, C_BRICK.darkened(0.24), C_GLASS, C_LAMP,
		not GameState.is_morning(), 21)
	_draw_ground()
	_draw_doors()
	_draw_furniture()
	# Thin air. Everything a long way off goes blue and stays sharp, which is
	# the opposite of haze and is what altitude actually looks like.
	CA.air(self, Color(0.36, 0.44, 0.62), 0.045)
	CA.vignette(self, 0.28)


func _draw_sky() -> void:
	if GameState.is_morning():
		CA.sky(self, C_DAY_HI, C_DAY_MID, C_DAY_LOW, C_DAY_LOW.lightened(0.05))
	else:
		CA.sky(self, C_SKY_ZEN, C_SKY_MID, C_SKY_LOW, C_SKY_HAZE)
	# Illimani. Three summits, snow, and visible from most of the city - the
	# one thing every district here has in common.
	# Every district, El Alto included. Standing on the rim at four
	# thousand metres is where you see it best, and skipping it there
	# left the arrival plate of this city with no mountain in it.
	_draw_illimani()
	# The cable cars. They cross the sky in every district because they are the
	# only way anybody gets between them.
	_draw_teleferico()


func _draw_illimani() -> void:
	var rock: Color = Color(0.243, 0.239, 0.310)
	var snow: Color = Color(0.839, 0.867, 0.898)
	if not GameState.is_morning():
		rock = rock.darkened(0.35)
		snow = Color(0.545, 0.576, 0.667)
	# Six and a half thousand metres, forty kilometres away, and it fills
	# the whole eastern sky. Drawn small it was a bump behind a shop.
	var base: float = 238.0
	for peak in [[326.0, 26.0], [536.0, 62.0], [742.0, 8.0]]:
		var px: float = float(peak[0])
		var top: float = float(peak[1])
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 262.0, base), Vector2(px - 96.0, top + 62.0),
			Vector2(px, top), Vector2(px + 108.0, top + 74.0),
			Vector2(px + 262.0, base),
		]), rock)
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 86.0, top + 88.0), Vector2(px, top),
			Vector2(px + 86.0, top + 92.0), Vector2(px + 34.0, top + 66.0),
			Vector2(px - 8.0, top + 98.0), Vector2(px - 44.0, top + 62.0),
		]), snow)
	draw_rect(Rect2(0, base - 2.0, CA.VW, 4.0), rock.lightened(0.10))


# Mi Teleferico. Ten colour lines, and whichever one this district is on runs
# across the top of the plate with cabins on it. It is not scenery; it is the
# bus, and drawing it any other way would be a lie about the city.
func _draw_teleferico() -> void:
	var col: Color = {
		"elalto": C_AY_RED, "rodriguez": C_AY_RED,
		"sopocachi": C_AY_GOLD, "irpavi": C_AY_GREEN,
	}.get(district, C_AY_RED)
	if not GameState.is_morning():
		col = col.darkened(0.24)
	var y0: float = 62.0
	var y1: float = 128.0
	var cable := Color(0.176, 0.176, 0.196, 0.85)
	draw_line(Vector2(-20.0, y0), Vector2(CA.VW + 20.0, y1), cable, 1.8)
	draw_line(Vector2(-20.0, y0 + 26.0), Vector2(CA.VW + 20.0, y1 + 26.0),
		cable.darkened(0.10), 1.4)
	# Two pylons, and the cabins strung between them.
	for px in [230.0, 880.0]:
		draw_rect(Rect2(px - 5.0, 20.0, 10.0, 148.0), C_TIN.darkened(0.30))
		draw_rect(Rect2(px - 22.0, 18.0, 44.0, 7.0), C_TIN)
	for i in range(4):
		var u: float = fmod(_t * 0.045 + float(i) * 0.25, 1.0)
		var cx: float = lerpf(-30.0, CA.VW + 30.0, u)
		var cy: float = lerpf(y0, y1, u)
		_draw_cabin(cx, cy, col)


func _draw_cabin(x: float, y: float, col: Color) -> void:
	var sway: float = sin(_t * 1.2 + x * 0.02) * 1.4
	draw_rect(Rect2(x - 1.5, y, 3.0, 13.0), Color(0.20, 0.20, 0.22))
	draw_rect(Rect2(x - 11.0 + sway, y + 13.0, 22.0, 22.0), col)
	draw_rect(Rect2(x - 11.0 + sway, y + 13.0, 22.0, 3.0), col.lightened(0.24))
	draw_rect(Rect2(x - 8.0 + sway, y + 18.0, 16.0, 12.0),
		Color(0.286, 0.404, 0.451))
	draw_rect(Rect2(x - 11.0 + sway, y + 32.0, 22.0, 3.0), col.darkened(0.28))


# ── El Alto ───────────────────────────────────────────────────────────────────
# Unfinished brick to the horizon, and two cholets in the middle of it.

func _draw_elalto() -> void:
	CA.far_mass(self, 196.0,
		C_BRICK_D.darkened(0.30) if GameState.is_morning()
		else C_BRICK_D.darkened(0.58),
		Color(0.82, 0.72, 0.58, 0.20), 46, 3)
	for spec in [[-16.0, 132.0, 2], [116.0, 108.0, 3], [224.0, 96.0, 2],
			[698.0, 118.0, 2], [816.0, 104.0, 3], [920.0, 126.0, 2],
			[1046.0, 122.0, 3]]:
		_draw_unfinished(float(spec[0]), float(spec[1]), int(spec[2]))
	_draw_cholet(340.0, C_AY_BLUE, C_AY_GOLD, C_AY_RED)
	_draw_cholet(530.0, C_AY_GREEN, C_AY_RED, C_AY_GOLD)


# A brick box with the next floor already planned for. The rebar standing out
# of the roof slab is the single most recognisable thing about this city, and
# it is not decay - it is a floor that has not been afforded yet.
func _draw_unfinished(x: float, w: float, storeys: int) -> void:
	var body: Color = C_BRICK if (int(x) % 2) else C_BRICK_B
	if not GameState.is_morning():
		body = body.darkened(0.44)
	var floor_h: float = 44.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	draw_rect(Rect2(x, top, w, GROUND_Y - top), body)
	# Brick courses. Coarse, because the blocks are big and unrendered.
	for r in range(int((GROUND_Y - top) / 7.0)):
		var y: float = top + float(r) * 7.0
		draw_rect(Rect2(x, y, w, 1.0), Color(0, 0, 0, 0.14))
		var off: float = 9.0 if (r % 2) else 0.0
		for c in range(int(w / 18.0) + 1):
			draw_rect(Rect2(x + off + float(c) * 18.0, y, 1.0, 7.0),
				Color(0, 0, 0, 0.11))
	# The concrete ring beam at each floor, which is the only rendered part.
	for s in range(storeys):
		draw_rect(Rect2(x - 2.0, GROUND_Y - float(s + 1) * floor_h, w + 4.0, 7.0),
			C_CONC if GameState.is_morning() else C_CONC.darkened(0.44))
	# The rebar. Four to eight bars, bent, waiting.
	var bars: int = 4 + (int(x) % 5)
	for i in range(bars):
		var bx: float = x + 10.0 + float(i) * ((w - 20.0) / float(maxi(bars - 1, 1)))
		var h: float = 12.0 + float((int(x) + i * 7) % 4) * 5.0
		draw_rect(Rect2(bx, top - h, 2.4, h), C_REBAR)
		draw_rect(Rect2(bx, top - h, 6.0, 2.4), C_REBAR)
	# Windows: unglazed openings on the top floor, glazed lower down.
	for s in range(storeys):
		var wy: float = top + 12.0 + float(s) * floor_h
		var bays: int = maxi(1, int(w / 46.0))
		if s == 0 and storeys > 1:
			for b in range(bays):
				var step: float = w / float(bays)
				draw_rect(Rect2(x + step * (float(b) + 0.5) - 13.0, wy, 26.0, 26.0),
					Color(0.09, 0.07, 0.07))
			continue
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 7 + s * 13) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 26.0, 26.0, C_GLASS,
			C_CONC.darkened(0.30), lit)


# The cholet. Sharp geometry, mirrored glass, textile colour, a ballroom on the
# first floor with its own doors, and a chalet on the roof for the owner.
func _draw_cholet(x: float, c1: Color, c2: Color, c3: Color) -> void:
	if not GameState.is_morning():
		c1 = c1.darkened(0.28)
		c2 = c2.darkened(0.28)
		c3 = c3.darkened(0.28)
	var w: float = 176.0
	var top: float = 44.0
	draw_rect(Rect2(x, top, w, GROUND_Y - top), c1)
	draw_rect(Rect2(x + w - 12.0, top, 12.0, GROUND_Y - top), c1.darkened(0.26))
	var bands := [c2, c3, c2, c3]
	for s in range(4):
		var y: float = top + 12.0 + float(s) * 42.0
		var band: Color = bands[s]
		draw_rect(Rect2(x + 5.0, y, w - 10.0, 8.0), band)
		# The stepped diamond, off a weaving. It is the whole argument of the
		# building and it repeats because a textile repeats.
		for k in range(4):
			var dx: float = x + 22.0 + float(k) * 38.0
			draw_rect(Rect2(dx - 5.0, y + 11.0, 30.0, 5.0), band.darkened(0.22))
			draw_rect(Rect2(dx, y + 16.0, 20.0, 5.0), band)
			draw_rect(Rect2(dx + 5.0, y + 21.0, 10.0, 5.0), band)
		var glass := Color(0.243, 0.404, 0.451, 0.92)
		if not GameState.is_morning():
			glass = Color(0.129, 0.196, 0.255, 0.94)
		draw_rect(Rect2(x + 12.0, y + 28.0, w - 24.0, 12.0), glass)
		for b in range(5):
			draw_rect(Rect2(x + 12.0 + float(b) * 31.0, y + 28.0, 2.0, 12.0),
				c1.lightened(0.22))
	# The ballroom. Double-height doors, and lit when nothing else is.
	for dx in [26.0, 106.0]:
		draw_rect(Rect2(x + dx, GROUND_Y - 40.0, 46.0, 40.0), c1.darkened(0.36))
		draw_rect(Rect2(x + dx + 3.0, GROUND_Y - 36.0, 40.0, 36.0),
			c2 if not GameState.is_morning() else c1.darkened(0.20))
	# The chalet on the roof.
	draw_rect(Rect2(x + 34.0, top - 30.0, 108.0, 30.0), c1.lightened(0.10))
	CA.roof(self, x + 34.0, 108.0, top - 28.0, 16.0, c3)
	draw_rect(Rect2(x, top - 4.0, w, 6.0), c2)


# ── Mercado Rodriguez ─────────────────────────────────────────────────────────
# The market street in the bowl. It is on a slope steep enough that the stalls
# are terraced, and the awnings are the roof of the street.

func _draw_rodriguez() -> void:
	CA.far_mass(self, 172.0,
		C_BRICK_D.darkened(0.24) if GameState.is_morning()
		else C_BRICK_D.darkened(0.56),
		Color(0.86, 0.76, 0.60, 0.24), 60, 9)
	for spec in [[-16.0, 122.0, 3], [106.0, 96.0, 4], [202.0, 112.0, 3],
			[314.0, 104.0, 4], [418.0, 128.0, 3], [546.0, 98.0, 4],
			[644.0, 116.0, 3], [760.0, 106.0, 4], [866.0, 124.0, 3],
			[990.0, 178.0, 4]]:
		_draw_rendered(float(spec[0]), float(spec[1]), int(spec[2]))
	# Awnings, right across, in the striped plastic sheet everybody uses.
	for i in range(7):
		var ax: float = -20.0 + float(i) * 172.0
		CA.awning(self, ax, 218.0, 168.0, C_AY_RED, Color(0.90, 0.88, 0.84))


func _draw_rendered(x: float, w: float, storeys: int) -> void:
	var body: Color = C_CONC if (int(x) % 3) else C_BRICK_B
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var floor_h: float = 38.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.20))
	CA.band(self, x, w, top, 6.0, body.lightened(0.14))
	for s in range(storeys - 1):
		var wy: float = top + 14.0 + float(s) * floor_h
		var bays: int = maxi(1, int(w / 44.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 11 + s * 5) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 24.0, 24.0, C_GLASS,
			C_REBAR.lightened(0.20), lit)
	# A painted shop name, in the flat sign-writing every wall here carries.
	if (int(x) % 2) == 0:
		var ink: Color = C_AY_BLUE if GameState.is_morning() \
			else C_AY_BLUE.lightened(0.25)
		for k in range(5):
			draw_rect(Rect2(x + 10.0 + float(k) * 12.0, top + 10.0, 8.0, 11.0), ink)


# ── Sopocachi ─────────────────────────────────────────────────────────────────
# Middle-class, treed, quiet, and six hundred metres lower than the rim. The
# first street in the city where nobody is selling anything.

func _draw_sopocachi() -> void:
	CA.far_mass(self, 186.0,
		Color(0.478, 0.451, 0.427) if GameState.is_morning()
		else Color(0.478, 0.451, 0.427).darkened(0.56),
		Color(0.86, 0.82, 0.72, 0.22), 30, 5)
	for spec in [[-14.0, 158.0, 4], [148.0, 132.0, 5], [284.0, 146.0, 4],
			[434.0, 128.0, 5], [566.0, 162.0, 4], [732.0, 138.0, 5],
			[874.0, 152.0, 4], [1030.0, 138.0, 5]]:
		_draw_apartment(float(spec[0]), float(spec[1]), int(spec[2]))


func _draw_apartment(x: float, w: float, storeys: int) -> void:
	var body: Color = Color(0.749, 0.722, 0.671)
	if (int(x) % 3) == 0:
		body = Color(0.663, 0.612, 0.549)
	if not GameState.is_morning():
		body = body.darkened(0.46)
	var floor_h: float = 36.0
	var top: float = GROUND_Y - float(storeys) * floor_h
	CA.block(self, x, w, top, GROUND_Y, body, body.darkened(0.18))
	CA.band(self, x, w, top, 7.0, body.lightened(0.18))
	for s in range(storeys - 1):
		var wy: float = top + 16.0 + float(s) * floor_h
		var bays: int = maxi(2, int(w / 50.0))
		var lit: int = 0
		if not GameState.is_morning():
			lit = (int(x) * 13 + s * 7) % (1 << mini(bays, 20))
		CA.window_row(self, x, w, wy, bays, 30.0, 24.0, C_GLASS,
			body.darkened(0.34), lit)
		# A shallow balcony per flat, with something drying on it.
		CA.balcony(self, x + 8.0, wy + 24.0, w - 16.0,
			C_REBAR if GameState.is_morning() else C_REBAR.lightened(0.10))


# ── Irpavi ────────────────────────────────────────────────────────────────────
# The valley floor. Lower, warmer, greener, and the reason people who can afford
# to leave the rim do. The teleferico from here is the green line.

func _draw_irpavi() -> void:
	CA.far_mass(self, 156.0,
		Color(0.286, 0.353, 0.298) if GameState.is_morning()
		else Color(0.286, 0.353, 0.298).darkened(0.58),
		Color(0.80, 0.82, 0.70, 0.18), 22, 11)
	# The valley walls, close on both sides. You are at the bottom of something.
	var rock: Color = Color(0.541, 0.416, 0.322)
	if not GameState.is_morning():
		rock = rock.darkened(0.50)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-40.0, 292.0), Vector2(-40.0, 120.0), Vector2(230.0, 292.0),
	]), rock)
	draw_colored_polygon(PackedVector2Array([
		Vector2(CA.VW + 40.0, 292.0), Vector2(CA.VW + 40.0, 132.0),
		Vector2(900.0, 292.0),
	]), rock)
	for spec in [[190.0, 170.0, 3], [372.0, 148.0, 4], [532.0, 176.0, 3],
			[720.0, 152.0, 4]]:
		_draw_apartment(float(spec[0]), float(spec[1]), int(spec[2]))
	for tx in [140.0, 330.0, 640.0, 880.0]:
		CA.tree(self, float(tx), CA.PAVE_TOP - 4.0, 58.0,
			Color(0.318, 0.243, 0.180), Color(0.208, 0.404, 0.278), 1.15)


# ── San Pedro ─────────────────────────────────────────────────────────────────
# A colonial grid on a slope, around a square with a prison on one side of it -
# a prison with no guards inside, where the families live with the inmates and
# the shops on the ground floor sell to the street.
#
# The plate does not sensationalise that. It draws a square with trees in it, a
# high blank wall on one side, and a normal working street on the other three,
# which is what it actually looks like and is stranger for being ordinary.

func _draw_sanpedro() -> void:
	CA.far_mass(self, 182.0,
		C_BRICK_D.darkened(0.26) if GameState.is_morning()
		else C_BRICK_D.darkened(0.58),
		Color(0.88, 0.80, 0.64, 0.22), 30, 21)
	# The wall. Long, high, plain, with one door in it and small windows far
	# too high up to see out of.
	var wall: Color = Color(0.769, 0.706, 0.612)
	if not GameState.is_morning():
		wall = wall.darkened(0.48)
	draw_rect(Rect2(-20.0, 132.0, 560.0, GROUND_Y - 132.0), wall)
	draw_rect(Rect2(-20.0, 124.0, 570.0, 10.0), wall.lightened(0.16))
	for i in range(9):
		draw_rect(Rect2(20.0 + float(i) * 58.0, 156.0, 16.0, 20.0),
			Color(0.098, 0.086, 0.078))
		for b in range(3):
			draw_rect(Rect2(22.0 + float(i) * 58.0 + float(b) * 5.0, 156.0,
				2.0, 20.0), wall.darkened(0.30))
	# The one door, and it is a normal door.
	draw_rect(Rect2(238.0, GROUND_Y - 56.0, 44.0, 56.0), Color(0.404, 0.286, 0.204)
		if GameState.is_morning() else Color(0.404, 0.286, 0.204).darkened(0.46))
	draw_rect(Rect2(232.0, GROUND_Y - 62.0, 56.0, 7.0), wall.lightened(0.20))
	# The ordinary side of the square.
	for spec in [[560.0, 124.0, 3], [688.0, 106.0, 4], [798.0, 130.0, 3],
			[932.0, 112.0, 4], [1048.0, 128.0, 3]]:
		_draw_rendered(float(spec[0]), float(spec[1]), int(spec[2]))
	for tx in [130.0, 330.0, 470.0]:
		CA.tree(self, float(tx), CA.PAVE_TOP + 40.0, 50.0,
			Color(0.298, 0.243, 0.196), Color(0.235, 0.400, 0.286), 1.05)


# ── Ground ────────────────────────────────────────────────────────────────────
# El Alto is unmade and dusty. The bowl is cobbled or concreted. Irpavi is
# tarmac, because that is what money buys first.

func _draw_ground() -> void:
	var pave: Color = C_DUST
	var road: Color = C_DUST.darkened(0.20)
	if district == "irpavi":
		pave = Color(0.549, 0.541, 0.522)
		road = Color(0.290, 0.286, 0.282)
	elif district == "sopocachi":
		pave = Color(0.588, 0.565, 0.522)
		road = Color(0.325, 0.318, 0.310)
	elif district == "rodriguez":
		pave = Color(0.561, 0.494, 0.427)
		road = Color(0.400, 0.353, 0.310)
	if not GameState.is_morning():
		pave = pave.darkened(0.46)
		road = road.darkened(0.48)
	CA.ground(self, pave, road, pave.darkened(0.08))

	if district == "elalto":
		# Unmade. Ruts, not paving, and the dust sits in them.
		for i in range(7):
			var y: float = CA.ROAD_TOP + 8.0 + float(i) * 18.0
			draw_rect(Rect2(0, y, CA.VW, 4.0), road.darkened(0.14))
		for i in range(28):
			var sx: float = float((i * 173) % 1152)
			draw_rect(Rect2(sx, CA.PAVE_TOP + float((i * 37) % 300), 9.0, 4.0),
				C_DUST.lightened(0.14))
	elif district == "rodriguez":
		# Stepped. The street is a staircase and the stalls are terraced on it.
		CA.setts(self, CA.PAVE_TOP, CA.VH - CA.PAVE_TOP, 11.0, C_JOINT)
		for i in range(6):
			var sy: float = CA.PAVE_TOP + 22.0 + float(i) * 46.0
			draw_rect(Rect2(0, sy, CA.VW, 6.0), pave.lightened(0.20))
			draw_rect(Rect2(0, sy + 6.0, CA.VW, 3.0), Color(0, 0, 0, 0.26))
	else:
		CA.slabs(self, CA.PAVE_TOP, CA.ROAD_TOP - CA.PAVE_TOP, 48.0, 34.0, C_JOINT)
		CA.slabs(self, CA.FAR_TOP, CA.VH - CA.FAR_TOP, 48.0, 34.0, C_JOINT)
		CA.kerb(self, CA.ROAD_TOP, pave.lightened(0.18))
		for i in range(10):
			draw_rect(Rect2(float(i) * 118.0, 442.0, 58.0, 5.0),
				Color(0.88, 0.86, 0.78, 0.28))
	# Dust in the air, always, and more of it on the rim.
	CA.motes(self, 26 if district == "elalto" else 12,
		Color(0.82, 0.72, 0.55, 0.10), _t, 12.0, 30.0, 2.0)


# ── Furniture ─────────────────────────────────────────────────────────────────

func _draw_furniture() -> void:
	var lit: bool = not GameState.is_morning()
	for x in [150.0, 520.0, 900.0]:
		CA.lamp(self, float(x), CA.PAVE_TOP + 42.0, 78.0,
			C_REBAR, C_LAMP, lit)
	if district == "rodriguez" or district == "elalto":
		# The aguayo. A striped cloth bundle, carried on the back or set down
		# with the goods in it, and the most common object in either district.
		CA.stall(self, 604.0, CA.PAVE_TOP + 12.0, 132.0, C_AY_RED,
			[C_AY_GOLD, Color(0.898, 0.847, 0.741), Color(0.549, 0.290, 0.176)])
		_draw_aguayo(300.0)
		_draw_aguayo(846.0)
		CA.crates(self, 420.0, CA.PAVE_TOP + 40.0, 2, 2, Color(0.541, 0.443, 0.298))
	else:
		CA.bin(self, 380.0, CA.PAVE_TOP + 40.0, C_AY_GREEN.darkened(0.20))
		CA.bollard(self, 620.0, CA.PAVE_TOP + 40.0, C_CONC)
		CA.bollard(self, 660.0, CA.PAVE_TOP + 40.0, C_CONC)
	if district == "elalto":
		return


# Woven stripes, set down on the ground with the day laid out on top of it.
func _draw_aguayo(x: float) -> void:
	var stripes := [C_AY_RED, C_AY_GOLD, C_AY_GREEN, C_AY_BLUE,
		Color(0.898, 0.867, 0.788)]
	var y: float = CA.PAVE_TOP + 30.0
	for i in range(stripes.size()):
		var c: Color = stripes[i]
		if not GameState.is_morning():
			c = c.darkened(0.34)
		draw_rect(Rect2(x - 38.0, y + float(i) * 4.0, 76.0, 4.0), c)
	draw_rect(Rect2(x - 40.0, y - 3.0, 80.0, 4.0), Color(0, 0, 0, 0.20))
	for i in range(5):
		draw_circle(Vector2(x - 26.0 + float(i) * 13.0, y - 6.0), 5.0,
			Color(0.749, 0.612, 0.290) if GameState.is_morning()
			else Color(0.749, 0.612, 0.290).darkened(0.34))


func solids() -> Array:
	var out: Array = []
	if district == "rodriguez" or district == "elalto":
		out.append(Rect2(604.0, CA.PAVE_TOP + 12.0, 132.0, 30.0))    # stall
		out.append(Rect2(420.0, CA.PAVE_TOP + 18.0, 68.0, 24.0))     # crates
		out.append(Rect2(262.0, CA.PAVE_TOP + 26.0, 76.0, 24.0))     # aguayo
		out.append(Rect2(808.0, CA.PAVE_TOP + 26.0, 76.0, 24.0))     # aguayo
	else:
		out.append(Rect2(368.0, CA.PAVE_TOP + 12.0, 24.0, 32.0))     # bin
		out.append(Rect2(614.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))     # bollard
		out.append(Rect2(654.0, CA.PAVE_TOP + 16.0, 12.0, 28.0))     # bollard
	if district == "irpavi":
		for tx in [140.0, 330.0, 640.0, 880.0]:
			out.append(Rect2(float(tx) - 14.0, CA.PAVE_TOP - 20.0, 28.0, 26.0))
	return out


# Where the street's cats are.
#
# They used to be painted into the plate, which made them as touchable as a
# bollard. Interactables turns this list into real StreetCats you can sit down
# next to. Declared here, beside the furniture, for the same reason solids()
# is: two descriptions of one object drift apart the week either moves.
# tools/check_cats.py holds this equal to what the draw code used to place.
func cats() -> Array:
	if district == "elalto":
		return []
	return [
		[Vector2(470.0, CA.PAVE_TOP + 6.0), 0, 0],
	]
