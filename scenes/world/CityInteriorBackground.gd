extends Node2D

# One interior script for the twelve cities added after Berlin.
#
# Berlin, London and İstanbul each got their own interior background, and the
# three files say the same thing in three palettes. Twelve more copies would be
# twelve more places for a room to drift. So this branches on GameState.city
# for the colour and on `room` for the dressing — the same call the airport desk
# makes, for the same reason.
#
# What actually differs between one country's counter and another is not the
# furniture. It is the light, the wall material, and what the state thinks a
# waiting room should feel like. That is what PALETTE encodes.
#
# Geometry is InteriorArt's and is not negotiable: CEIL 46 · WALL 305 ·
# NEAR 606 · SIDE 44, walkable floor x 44-1108, y 305-606.

const IA := preload("res://scenes/world/InteriorArt.gd")

@export var room: String = "exchange"

var _t: float = 0.0

# wall · trim · accent · floor tile · lamp warmth
#
# Taken from the streetscape research per city, then pulled one notch toward
# neutral, because an interior is lit by whatever is screwed to its ceiling
# rather than by its country.
const PALETTE := {
	"zurich": {
		"wall": Color(0.827, 0.812, 0.776), "trim": Color(0.286, 0.216, 0.161),
		"accent": Color(0.678, 0.145, 0.169), "tile": WorldArt.TILE_SIDEWALK,
		"warm": 0.86,
	},
	"hanoi": {
		"wall": Color(0.792, 0.686, 0.451), "trim": Color(0.196, 0.353, 0.318),
		"accent": Color(0.780, 0.196, 0.161), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 1.0,
	},
	"tokyo": {
		"wall": Color(0.839, 0.827, 0.796), "trim": Color(0.243, 0.204, 0.169),
		"accent": Color(0.145, 0.239, 0.451), "tile": WorldArt.TILE_SIDEWALK,
		"warm": 0.78,
	},
	"rome": {
		"wall": Color(0.831, 0.702, 0.510), "trim": Color(0.792, 0.769, 0.706),
		"accent": Color(0.192, 0.322, 0.243), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 1.0,
	},
	"moscow": {
		"wall": Color(0.780, 0.788, 0.729), "trim": Color(0.918, 0.910, 0.882),
		"accent": Color(0.639, 0.145, 0.145), "tile": WorldArt.TILE_SIDEWALK,
		"warm": 0.70,
	},
	"mexico": {
		"wall": Color(0.878, 0.808, 0.694), "trim": Color(0.502, 0.243, 0.204),
		"accent": Color(0.129, 0.310, 0.549), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 1.0,
	},
	"saopaulo": {
		"wall": Color(0.741, 0.741, 0.729), "trim": Color(0.898, 0.898, 0.886),
		"accent": Color(0.180, 0.482, 0.310), "tile": WorldArt.TILE_SIDEWALK,
		"warm": 0.88,
	},
	"dakar": {
		"wall": Color(0.859, 0.780, 0.639), "trim": Color(0.933, 0.925, 0.898),
		"accent": Color(0.106, 0.427, 0.416), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 1.0,
	},
	"tbilisi": {
		"wall": Color(0.671, 0.545, 0.463), "trim": Color(0.353, 0.278, 0.212),
		"accent": Color(0.451, 0.129, 0.192), "tile": WorldArt.TILE_WOOD,
		"warm": 0.92,
	},
	"seoul": {
		"wall": Color(0.808, 0.816, 0.812), "trim": Color(0.400, 0.416, 0.427),
		"accent": Color(0.145, 0.478, 0.353), "tile": WorldArt.TILE_SIDEWALK,
		"warm": 0.72,
	},
	"mumbai": {
		"wall": Color(0.678, 0.741, 0.698), "trim": Color(0.310, 0.231, 0.169),
		"accent": Color(0.867, 0.494, 0.129), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 1.0,
	},
	"lapaz": {
		"wall": Color(0.722, 0.514, 0.400), "trim": Color(0.639, 0.647, 0.659),
		"accent": Color(0.898, 0.612, 0.129), "tile": WorldArt.TILE_SIDEWALK_B,
		"warm": 0.94,
	},
}

const FALLBACK := {
	"wall": Color(0.780, 0.765, 0.729), "trim": Color(0.310, 0.278, 0.243),
	"accent": Color(0.545, 0.353, 0.243), "tile": WorldArt.TILE_SIDEWALK,
	"warm": 0.90,
}


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _pal() -> Dictionary:
	var p: Variant = PALETTE.get(GameState.city, null)
	if p == null:
		return FALLBACK
	return p


func _draw() -> void:
	var p: Dictionary = _pal()
	var wall: Color = p["wall"]
	var trim: Color = p["trim"]
	var accent: Color = p["accent"]
	# Night pulls every interior toward its own lamps and away from its walls.
	if not GameState.is_morning():
		wall = wall.darkened(0.30)
		trim = trim.darkened(0.22)
	draw_rect(Rect2(-IA.EXT, -IA.EXT, IA.VW + IA.EXT * 2.0,
		IA.VH + IA.EXT * 2.0), IA.C_VOID)
	IA.shell(self, wall, trim, accent)
	IA.side_walls(self, wall, trim)
	IA.floor_tiles(self, int(p["tile"]))
	IA.exit_door(self, 98.0, trim)

	match room:
		"exchange": _dress_exchange(wall, trim, accent)
		"hotel":    _dress_hotel(wall, trim, accent)
		"airport":  _dress_airport(wall, trim, accent)
		"transit":  _dress_transit(wall, trim, accent)
		_:          _dress_exchange(wall, trim, accent)

	_lights(float(p["warm"]))


# ── The rooms ─────────────────────────────────────────────────────────────────
# Three, because three is what a stranger who has just landed actually needs:
# money, a bed, and the way out again. Everything else a city has to say, it
# says on its street.

func _dress_exchange(wall: Color, trim: Color, accent: Color) -> void:
	IA.counter(self, 600.0, 360.0, 380.0, 84.0, trim, wall.lightened(0.10))
	IA.glass_screen(self, 606.0, 264.0, 368.0, 100.0, trim)
	# The board. Numbers you can read perfectly and still cannot use.
	IA.sign(self, 700.0, 128.0, 200.0, 92.0, Color(0.07, 0.08, 0.09), accent)
	for i in range(5):
		var y: float = 142.0 + float(i) * 17.0
		draw_rect(Rect2(716.0, y, 60.0, 6.0), accent.lightened(0.20))
		draw_rect(Rect2(812.0, y, 72.0, 6.0), Color(0.86, 0.86, 0.80, 0.72))
	IA.notice(self, 250.0, 190.0, 92.0, 62.0, wall.lightened(0.16), trim)
	IA.queue_posts(self, 300.0, 470.0, 3)


func _dress_hotel(wall: Color, trim: Color, accent: Color) -> void:
	IA.counter(self, 620.0, 360.0, 340.0, 84.0, trim, wall.lightened(0.06))
	# The key rack. How many keys are still on it is how full the place is,
	# and it is the one honest number in the building.
	draw_rect(Rect2(700.0, 190.0, 210.0, 78.0), trim.darkened(0.25))
	draw_rect(Rect2(706.0, 196.0, 198.0, 66.0), wall.darkened(0.18))
	for r in range(2):
		for c in range(7):
			var kx: float = 716.0 + float(c) * 27.0
			var ky: float = 208.0 + float(r) * 30.0
			draw_rect(Rect2(kx, ky, 3.0, 12.0), trim.lightened(0.30))
			if ((r * 7 + c) % 3) != 0:
				draw_rect(Rect2(kx - 4.0, ky + 12.0, 11.0, 8.0), accent)
	IA.bench_run(self, 180.0, 470.0, 3, trim, wall.lightened(0.12))
	IA.plant(self, 470.0, 470.0, trim.darkened(0.20))
	IA.sign(self, 300.0, 200.0, 120.0, 44.0, accent.darkened(0.30),
		wall.lightened(0.30))


func _dress_airport(wall: Color, trim: Color, accent: Color) -> void:
	IA.counter(self, 560.0, 360.0, 420.0, 84.0, trim, wall.lightened(0.10))
	# The board that turns over and over. It is the same object in every
	# country, and the only one the alien reads the same way twice.
	# Clear of the window, which the board used to overlap by a third.
	IA.flap_board(self, 476.0, 122.0, 588.0, 6, _t)
	IA.queue_posts(self, 240.0, 470.0, 4)
	# Bigger, and looking at something. At 220 by 130 in the corner the
	# window was too small to tell any two of these terminals apart.
	IA.apron_view(self, 56.0, 138.0, 392.0, 176.0, accent, GameState.city)
	IA.baggage_belt(self, 200.0, 540.0, 420.0, _t)


# The station. Whatever a country calls it and whatever runs through it, the
# shape underneath is the same everywhere: a hard edge, a drop past it, a
# machine that wants exact money, and a barrier that decides whether you have
# paid. The livery on the train is the only thing that changes.
const LIVERY := {
	"zurich": Color(0.678, 0.145, 0.169),   "hanoi": Color(0.176, 0.404, 0.286),
	"tokyo": Color(0.145, 0.290, 0.545),    "rome": Color(0.788, 0.361, 0.145),
	"moscow": Color(0.706, 0.153, 0.145),   "mexico": Color(0.878, 0.318, 0.510),
	"saopaulo": Color(0.145, 0.322, 0.686), "dakar": Color(0.106, 0.451, 0.400),
	"tbilisi": Color(0.729, 0.180, 0.204),  "seoul": Color(0.169, 0.545, 0.318),
	"mumbai": Color(0.780, 0.639, 0.196),   "lapaz": Color(0.780, 0.196, 0.196),
}


func _dress_transit(wall: Color, trim: Color, accent: Color) -> void:
	var livery: Color = LIVERY.get(GameState.city, accent)
	# The track side, and the train standing at it. La Paz has no track and no
	# tunnel - the cable car arrives out of open sky - so it gets the doorway
	# without the dark behind it.
	if GameState.city != "lapaz":
		IA.train_at_platform(self, 300.0, 322.0, 560.0, livery, _t)
	else:
		_draw_cabin(430.0, 322.0, livery)
	# The edge. Every station in the game has one and it is always the first
	# thing the alien is warned about in a language it cannot read.
	draw_rect(Rect2(IA.SIDE, 322.0, IA.VW - IA.SIDE * 2.0, 8.0), trim.darkened(0.30))
	draw_rect(Rect2(IA.SIDE, 330.0, IA.VW - IA.SIDE * 2.0, 5.0), accent)
	for i in range(int((IA.VW - IA.SIDE * 2.0) / 22.0)):
		draw_rect(Rect2(IA.SIDE + 6.0 + float(i) * 22.0, 331.0, 11.0, 3.0),
			Color(0.94, 0.92, 0.86, 0.55))
	# The machine, and the barriers you feed it for.
	IA.counter(self, 350.0, 366.0, 92.0, 74.0, trim, wall.lightened(0.12))
	IA.sign(self, 356.0, 292.0, 80.0, 48.0, Color(0.07, 0.08, 0.09), accent)
	for i in range(3):
		draw_rect(Rect2(624.0 + float(i) * 62.0, 372.0, 26.0, 54.0),
			trim.lightened(0.10))
		draw_rect(Rect2(624.0 + float(i) * 62.0, 372.0, 26.0, 5.0), accent)
	IA.bench_run(self, 160.0, 476.0, 3, trim, wall.lightened(0.10))
	IA.notice(self, 900.0, 300.0, 120.0, 74.0, wall.lightened(0.18), trim)


# A cable-car cabin at the platform. Bolivia is the only city on the itinerary
# whose mass transit hangs off a wire, and it should not look like a train.
func _draw_cabin(x: float, y: float, livery: Color) -> void:
	draw_rect(Rect2(0, 120.0, IA.VW, 202.0), Color(0.145, 0.216, 0.298))
	draw_rect(Rect2(0, 120.0, IA.VW, 5.0), Color(0.243, 0.325, 0.396))
	draw_rect(Rect2(x - 90.0, 96.0, 180.0, 6.0), Color(0.35, 0.36, 0.38))
	var bob: float = sin(_t * 0.9) * 2.0
	draw_rect(Rect2(x - 6.0, 100.0, 12.0, 34.0 + bob), Color(0.40, 0.41, 0.43))
	draw_rect(Rect2(x - 58.0, 132.0 + bob, 116.0, 128.0), livery)
	draw_rect(Rect2(x - 58.0, 132.0 + bob, 116.0, 8.0), livery.lightened(0.24))
	draw_rect(Rect2(x - 48.0, 148.0 + bob, 96.0, 74.0), Color(0.278, 0.416, 0.478))
	draw_rect(Rect2(x - 4.0, 148.0 + bob, 8.0, 74.0), livery.darkened(0.20))
	draw_rect(Rect2(x - 58.0, 252.0 + bob, 116.0, 9.0), livery.darkened(0.30))


func _lights(warm: float) -> void:
	var lamp := Color(1.0, 0.92 + 0.06 * warm, 0.78 + 0.16 * warm)
	if GameState.is_morning():
		IA.strip_light(self, 300.0, 560.0, lamp.lightened(0.20), _t)
		return
	IA.ceiling_light(self, 340.0, lamp, _t, 1.0)
	IA.ceiling_light(self, 760.0, lamp, _t, 1.0)


# ── What stops you ────────────────────────────────────────────────────────────
# Declared next to the code that draws it, so the two cannot drift apart.

func solids() -> Array:
	var out: Array = []
	match room:
		"exchange":
			out.append(Rect2(600.0, 360.0, 380.0, 84.0))
		"hotel":
			out.append(Rect2(620.0, 360.0, 340.0, 84.0))
			out.append(Rect2(180.0, 470.0, 190.0, 44.0))    # the bench run
			out.append(Rect2(452.0, 452.0, 44.0, 52.0))     # the plant
		"airport":
			out.append(Rect2(560.0, 360.0, 420.0, 84.0))
		"transit":
			out.append(Rect2(350.0, 366.0, 92.0, 74.0))     # ticket machine
			out.append(Rect2(160.0, 476.0, 190.0, 44.0))    # bench run
			for i in range(3):
				out.append(Rect2(624.0 + float(i) * 62.0, 372.0, 26.0, 54.0))
			out.append(Rect2(200.0, 540.0, 420.0, 40.0))    # baggage belt
		_:
			out.append(Rect2(600.0, 360.0, 380.0, 84.0))
	return out
