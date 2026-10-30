extends Node2D

# Downtown Berlin — pixel art from design_handoff_world.
#   "west": the shipped plate (mitte_dawn/morning) with everything baked in.
#   "ost":  composed per the handoff — ground tiles + the Ost facades
#           (Markthalle, Apotheke, Café, Biergarten) on the same street bands.
# Facade positions keep the old vector layout so exits, pigeons and map
# labels stay true.

@export var district: String = "west"

const VW  := 1152.0
const VH  := 648.0
const EXT := 4000.0
const C_VOID := Color(0.043, 0.039, 0.110)

# Far skyline for the composed Ost district: [x, height]
const _FAR := [
	[0, 120], [70, 158], [150, 132], [230, 170], [310, 128],
	[390, 148], [470, 118], [545, 165], [625, 135], [700, 155],
	[780, 125], [855, 162], [935, 140], [1010, 150], [1085, 128],
]
const _FAR_W := [64, 74, 70, 78, 66, 72, 68, 76, 64, 74, 70, 78, 68, 72, 70]

var _t: float = 0.0


# Berlin's Ost facades are shipped pixel art, so this street takes the fascia
# from each door but NOT the generic frontage — painting one over the plates
# would bury the handoff artwork under a drawn shopfront.
const IA_B := preload("res://scenes/world/InteriorArt.gd")

var _doors: Array = []


func _collect_doors() -> void:
	_doors.clear()
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		var label: Variant = child.get("sign_text")
		if label == null or String(label).is_empty() or not (child is Node2D):
			continue
		_doors.append({"x": (child as Node2D).position.x, "label": String(label)})


func _draw_door_signs() -> void:
	for d in _doors:
		IA_B.fascia(self, float(d["x"]), 214.0, String(d["label"]),
			Color(0.86, 0.84, 0.78), Color(0.10, 0.10, 0.12),
			not GameState.is_morning())


func _process(delta: float) -> void:
	if district == "ost":
		_t += delta
		queue_redraw()


func _ready() -> void:
	_collect_doors()
	if district == "west":
		WorldArt.sprite(self, WorldArt.tex("scenes/mitte_%s.png" % WorldArt.mode()),
			Vector2.ZERO, 1)
	else:
		_build_ost()


func _build_ost() -> void:
	# Facades (z 2). The block between the market hall and the café is the
	# Polizeiwache — its entrance is at world x≈600.
	WorldArt.sprite(self, WorldArt.mode_tex("facades/markthalle"), Vector2(60, 30), 2)
	WorldArt.sprite(self, WorldArt.mode_tex("facades/block"),      Vector2(250, 34), 2)
	WorldArt.sprite(self, WorldArt.mode_tex("facades/cafe"),       Vector2(390, 54), 2)
	WorldArt.sprite(self, WorldArt.mode_tex("facades/biergarten"), Vector2(480, 80), 2)
	# Props (z 3)
	WorldArt.sprite(self, WorldArt.mode_tex("props/string_lights"), Vector2(470, 68), 3)
	WorldArt.sprite(self, WorldArt.tex("props/table_set.png"), Vector2(410, 150), 3)
	WorldArt.sprite(self, WorldArt.tex("props/fence.png"),     Vector2(492, 146), 3)
	WorldArt.sprite(self, WorldArt.tex("props/fence.png"),     Vector2(526, 146), 3)
	WorldArt.sprite(self, WorldArt.tex("props/bush.png"),      Vector2(470, 150), 3)
	WorldArt.sprite(self, WorldArt.tex("props/bush.png"),      Vector2(558, 150), 3)
	WorldArt.sprite(self, WorldArt.tex("props/bench.png"),     Vector2(196, 270), 3)
	WorldArt.sprite(self, WorldArt.tex("props/tree.png"),      Vector2(96, 258), 3)
	WorldArt.sprite(self, WorldArt.tex("props/tree.png"),      Vector2(430, 264), 3)


func _draw() -> void:
	# The node's own drawing sits behind its positive-z children
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)
	if district != "ost":
		return

	var morning := GameState.is_morning()

	# Sky bands
	if morning:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.42, 0.58, 0.74))
		draw_rect(Rect2(0, 190, VW, 102), Color(0.52, 0.64, 0.77))
	else:
		draw_rect(Rect2(0, 0, VW, 292), Color(0.045, 0.040, 0.105))
		draw_rect(Rect2(0, 45, VW, 180), Color(0.072, 0.058, 0.148))
		draw_rect(Rect2(0, 180, VW, 70), Color(0.160, 0.090, 0.182))
		draw_rect(Rect2(0, 250, VW, 42), Color(0.300, 0.160, 0.135))

	# Far skyline
	var bldg_c := Color(0.30, 0.34, 0.44) if morning else Color(0.046, 0.042, 0.088)
	var rim_c  := Color(0.86, 0.80, 0.62, 0.55) if morning else Color(0.095, 0.082, 0.165, 0.35)
	for i in range(_FAR.size()):
		var bx: float = float(_FAR[i][0])
		var bh: float = float(_FAR[i][1])
		var bw: float = float(_FAR_W[i % _FAR_W.size()])
		draw_rect(Rect2(bx, 292 - bh, bw, bh + 4), bldg_c)
		draw_rect(Rect2(bx, 292 - bh, bw, 2), rim_c)

	_draw_ost_signage()
	_draw_berlin_culture()
	_draw_door_signs()

	# Street bands from the tileset (world px; 1× bands ×2)
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 292, VW, 80))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT,  Rect2(0, 372, VW, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_ASPHALT_D, Rect2(0, 436, VW, 32))
	WorldArt.draw_tiles(self, WorldArt.TILE_CROSSWALK, Rect2(64, 372, 128, 144))
	WorldArt.draw_tiles(self, WorldArt.TILE_SIDEWALK, Rect2(0, 516, VW, 132))


# ── Berlin, specifically ──────────────────────────────────────────────────────
# London got chimney stacks and basement areas. Istanbul got cumbas and cable.
# Berlin's own vocabulary is narrower and stranger, and all of it is civic:
# a television tower nobody can avoid seeing, a walking green man left over
# from a country that no longer exists, an advertising column, a U on a blue
# square, and graffiti on absolutely everything at arm's height.

func _draw_berlin_culture() -> void:
	_draw_fernsehturm(958.0)
	_draw_litfass(232.0)
	_draw_ampelmann(742.0)
	_draw_u_sign(496.0)
	_draw_graffiti()
	_draw_pfand(858.0)


# The Fernsehturm. Every Berlin skyline has it whether it wants it or not, and
# the sphere is the single most recognisable silhouette in the city.
func _draw_fernsehturm(x: float) -> void:
	var morning: bool = GameState.is_morning()
	var shaft: Color = Color(0.34, 0.37, 0.44) if morning else Color(0.075, 0.070, 0.130)
	var sphere: Color = Color(0.52, 0.56, 0.62) if morning else Color(0.115, 0.105, 0.175)
	draw_rect(Rect2(x - 7.0, 40.0, 14.0, 252.0), shaft)
	draw_rect(Rect2(x - 4.0, 40.0, 4.0, 252.0), shaft.lightened(0.12))
	draw_circle(Vector2(x, 128.0), 26.0, sphere)
	draw_rect(Rect2(x - 26.0, 124.0, 52.0, 5.0), sphere.lightened(0.18))
	# The antenna, and the red lamp on it that blinks all night
	draw_rect(Rect2(x - 2.0, -20.0, 4.0, 62.0), shaft)
	if not morning:
		var blink: float = 0.35 + 0.65 * sin(_t * 1.7)
		draw_circle(Vector2(x, -18.0), 3.5, Color(0.95, 0.25, 0.20, blink))
		# The sphere throws the "Pope's revenge" cross when the sun is on it —
		# at dusk it is just lit windows in a ring
		for i in range(10):
			var a: float = float(i) * TAU / 10.0
			draw_circle(Vector2(x + cos(a) * 19.0, 128.0 + sin(a) * 19.0), 1.6,
				Color(0.98, 0.88, 0.62, 0.75))


# Litfaßsäule — the fat cylindrical advertising column. A Berlin invention, and
# still the only thing on the pavement that is round.
func _draw_litfass(x: float) -> void:
	var top: float = 292.0 - 118.0
	draw_rect(Rect2(x - 26.0, top, 52.0, 118.0), Color(0.145, 0.130, 0.155))
	draw_rect(Rect2(x - 26.0, top, 10.0, 118.0), Color(0.175, 0.158, 0.185))
	draw_rect(Rect2(x + 16.0, top, 10.0, 118.0), Color(0.105, 0.095, 0.115))
	# Posters, layered, torn back to the ones underneath
	var hues := [Color(0.62, 0.18, 0.22), Color(0.16, 0.30, 0.52),
		Color(0.72, 0.58, 0.16)]
	for i in range(3):
		var py: float = top + 12.0 + float(i) * 34.0
		draw_rect(Rect2(x - 22.0, py, 44.0, 28.0),
			hues[i % hues.size()].darkened(0.25))
		draw_rect(Rect2(x - 18.0, py + 4.0, 36.0, 3.0), Color(1, 1, 1, 0.30))
		draw_rect(Rect2(x - 18.0, py + 11.0, 26.0, 2.0), Color(1, 1, 1, 0.18))
	# Domed cap and the ring of dirt at the base
	draw_rect(Rect2(x - 30.0, top - 8.0, 60.0, 10.0), Color(0.095, 0.085, 0.105))
	draw_rect(Rect2(x - 28.0, 288.0, 56.0, 6.0), Color(0, 0, 0, 0.28))


# The Ampelmännchen. He is not a generic pedestrian signal — he has a hat, he
# leans forward, and he is the one piece of the DDR that everybody kept.
func _draw_ampelmann(x: float) -> void:
	var y: float = 292.0 - 152.0
	draw_rect(Rect2(x - 3.0, y, 6.0, 152.0), Color(0.09, 0.09, 0.10))
	draw_rect(Rect2(x - 15.0, y - 62.0, 30.0, 66.0), Color(0.075, 0.075, 0.085))
	var walk: bool = fmod(_t, 8.0) < 5.0
	# Standing red man, arms out
	var red: Color = Color(0.92, 0.22, 0.18, 0.30 if walk else 0.95)
	draw_circle(Vector2(x, y - 46.0), 4.0, red)
	draw_rect(Rect2(x - 8.0, y - 50.0, 16.0, 3.0), red)      # hat brim
	draw_rect(Rect2(x - 2.0, y - 42.0, 4.0, 12.0), red)
	draw_rect(Rect2(x - 9.0, y - 40.0, 18.0, 3.0), red)      # arms out flat
	# Walking green man, striding, hat on
	var grn: Color = Color(0.30, 0.85, 0.32, 0.95 if walk else 0.28)
	draw_circle(Vector2(x + 1.0, y - 22.0), 4.0, grn)
	draw_rect(Rect2(x - 7.0, y - 26.0, 16.0, 3.0), grn)
	draw_rect(Rect2(x - 1.0, y - 18.0, 4.0, 10.0), grn)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 1, y - 8), Vector2(x + 3, y - 8),
		Vector2(x + 8, y - 1), Vector2(x + 4, y - 1),
	]), grn)
	draw_colored_polygon(PackedVector2Array([
		Vector2(x - 1, y - 8), Vector2(x + 2, y - 8),
		Vector2(x - 5, y - 1), Vector2(x - 8, y - 1),
	]), grn)
	draw_rect(Rect2(x - 8.0, y - 17.0, 14.0, 3.0), grn)


# The U. White on a blue square, and it means the ground opens here.
func _draw_u_sign(x: float) -> void:
	var y: float = 292.0 - 96.0
	draw_rect(Rect2(x - 2.5, y, 5.0, 96.0), Color(0.10, 0.10, 0.11))
	draw_rect(Rect2(x - 24.0, y - 46.0, 48.0, 48.0), Color(0.05, 0.22, 0.55))
	draw_rect(Rect2(x - 24.0, y - 46.0, 48.0, 48.0), Color(0.85, 0.88, 0.92), false, 2.0)
	# The U itself, drawn as strokes so it reads at any size
	draw_rect(Rect2(x - 12.0, y - 38.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x + 6.0, y - 38.0, 6.0, 22.0), Color(0.94, 0.96, 0.98))
	draw_rect(Rect2(x - 12.0, y - 20.0, 24.0, 6.0), Color(0.94, 0.96, 0.98))


# Berlin is written on at hand height, everywhere, permanently. Leaving it out
# would be the single most inaccurate thing this street could do.
func _draw_graffiti() -> void:
	var tags := [
		[70.0, 252.0, 96.0], [206.0, 258.0, 64.0], [330.0, 250.0, 120.0],
		[520.0, 256.0, 78.0], [700.0, 250.0, 104.0], [880.0, 258.0, 88.0],
		[1030.0, 252.0, 70.0],
	]
	var inks := [Color(0.90, 0.92, 0.94, 0.30), Color(0.35, 0.80, 0.85, 0.26),
		Color(0.95, 0.45, 0.25, 0.24), Color(0.75, 0.40, 0.85, 0.22)]
	for i in range(tags.size()):
		var t: Array = tags[i]
		var x: float = float(t[0])
		var y: float = float(t[1])
		var w: float = float(t[2])
		var ink: Color = inks[i % inks.size()]
		# A tag is one continuous gesture, so draw it as linked strokes
		var prev: Vector2 = Vector2(x, y + 14.0)
		for s in range(6):
			var nx: float = x + w * (float(s + 1) / 6.0)
			var ny: float = y + (14.0 if s % 2 == 0 else -6.0) + float((i * 5 + s) % 5)
			draw_line(prev, Vector2(nx, ny), ink, 2.6)
			prev = Vector2(nx, ny)
		draw_line(Vector2(x, y + 20.0), Vector2(x + w * 0.6, y + 21.0),
			Color(ink.r, ink.g, ink.b, ink.a * 0.6), 1.8)


# Pfand. Nobody throws a deposit bottle away; you stand it beside the bin so
# whoever collects them does not have to reach in.
func _draw_pfand(park_x: float) -> void:
	draw_rect(Rect2(park_x - 16.0, 246.0, 32.0, 46.0), Color(0.135, 0.130, 0.120))
	draw_rect(Rect2(park_x - 18.0, 242.0, 36.0, 6.0), Color(0.175, 0.170, 0.158))
	for i in range(4):
		var bx: float = park_x + 20.0 + float(i) * 11.0
		var glass: Color = Color(0.24, 0.42, 0.26, 0.85) if i % 2 == 0 \
			else Color(0.36, 0.30, 0.18, 0.85)
		draw_rect(Rect2(bx, 272.0, 7.0, 20.0), glass)
		draw_rect(Rect2(bx + 2.0, 266.0, 3.0, 7.0), glass)


# Signage the alien can't read, plus the notice board that hands out work.
# Drawn in world px, on top of the facades.
func _draw_ost_signage() -> void:
	# Polizeiwache — the green-and-white band every German station wears
	draw_rect(Rect2(504, 214, 192, 34), Color(0.06, 0.24, 0.15))
	draw_rect(Rect2(504, 214, 192, 4),  Color(0.16, 0.44, 0.28))
	for i in range(5):
		var lx := 522.0 + float(i) * 34.0
		draw_line(Vector2(lx, 224), Vector2(lx + 17, 240),
			Color(0.88, 0.92, 0.86), 3.0)
	# Shield above the door
	var sx := 600.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(sx - 20, 160), Vector2(sx + 20, 160),
		Vector2(sx + 17, 196), Vector2(sx, 208), Vector2(sx - 17, 196),
	]), Color(0.10, 0.30, 0.19))
	draw_rect(Rect2(sx - 7, 172, 14, 16), Color(0.88, 0.92, 0.86))
	# Blue lamp over the entrance
	var pulse := 0.6 + 0.4 * sin(_t * 1.6)
	draw_rect(Rect2(sx - 10, 246, 20, 12), Color(0.10, 0.14, 0.24))
	draw_circle(Vector2(sx, 252), 14.0, Color(0.30, 0.52, 0.95, 0.16 * pulse))
	draw_circle(Vector2(sx, 252), 5.0,  Color(0.55, 0.72, 1.00, 0.85 * pulse))

	# Notice board on the wall by the market hall — the job source
	draw_rect(Rect2(232, 206, 176, 116), Color(0.14, 0.11, 0.08))
	draw_rect(Rect2(238, 212, 164, 104), Color(0.26, 0.19, 0.12))
	for i in range(6):
		var cx := 248.0 + float(i % 3) * 52.0
		var cy := 222.0 + float(i / 3) * 48.0
		var tilt := float((i * 7) % 5) - 2.0
		draw_rect(Rect2(cx, cy + tilt, 44, 38), Color(0.88, 0.85, 0.76))
		for l in range(3):
			draw_rect(Rect2(cx + 5, cy + tilt + 8.0 + float(l) * 8.0,
				32.0 - float((i + l) % 12), 2), Color(0.30, 0.26, 0.22, 0.6))
		draw_circle(Vector2(cx + 22, cy + tilt + 3), 2.5, Color(0.72, 0.24, 0.20))
