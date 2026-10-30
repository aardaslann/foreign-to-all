extends RefCounted

# Normalized bounds of exterior views in the approved core hotel/terminal
# plates. Furniture is redrawn by its existing foreground silhouettes. These
# are visual apertures only: no collision or navigation geometry is changed.
const WINDOWS := {
	"HotelRoom": [[0.573,0.065,0.664,0.378], [0.674,0.065,0.764,0.378]],
	"LondonHotel": [[0.110,0.128,0.215,0.233], [0.116,0.233,0.215,0.405]],
	"IstanbulOtel": [[0.839,0.053,0.963,0.575]],
	"ParisHotel": [[0.088,0.220,0.160,0.541], [0.793,0.095,0.925,0.431]],
	"MoscowHotel": [[0.792,0.180,0.851,0.244], [0.792,0.260,0.851,0.513]],
	"MumbaiHotel": [[0.656,0.220,0.800,0.423], [0.058,0.313,0.076,0.609]],
	"TokyoHotel": [[0.771,0.310,0.796,0.635], [0.808,0.310,0.959,0.635], [0.971,0.310,1.0,0.635]],
	"MexicoHotel": [[0.310,0.125,0.644,0.478], [0.399,0.478,0.556,0.548]],
	"Airport": [[0.045,0.083,0.107,0.299], [0.114,0.083,0.453,0.595]],
	"LondonAirport": [[0.044,0.125,0.270,0.613], [0.295,0.410,0.341,0.613]],
	"IstanbulHavalimani": [[0.0,0.0,1.0,0.535]],
	"ParisAirport": [[0.0,0.16,1.0,0.706]],
	"MoscowAirport": [[0.0,0.087,1.0,0.625]],
	"MumbaiAirport": [[0.0,0.16,1.0,0.615]],
	"TokyoAirport": [[0.0,0.158,1.0,0.565]],
	"MexicoAirport": [[0.0,0.272,0.041,0.566], [0.088,0.272,0.136,0.566], [0.174,0.272,0.341,0.566], [0.398,0.272,0.576,0.566], [0.608,0.272,0.712,0.566]],
}
# Indoor fittings in front of the glass retain electric light. Foreground
# furniture is already restored by EnvironmentObject; these are wall fittings.
const INDOOR := {
	"IstanbulHavalimani": [[0.298,0.087,0.668,0.200], [0.773,0.105,1.0,0.387]],
	"ParisAirport": [[0.387,0.167,0.667,0.417], [0.769,0.172,0.987,0.318], [0.738,0.330,0.991,0.507], [0.846,0.513,0.991,0.573]],
	"MoscowAirport": [[0.622,0.128,0.973,0.433]],
	"MumbaiAirport": [[0.217,0.193,0.475,0.379], [0.548,0.193,0.817,0.409], [0.852,0.193,1.0,0.389]],
	"TokyoAirport": [[0.431,0.178,0.746,0.297], [0.519,0.411,0.757,0.688], [0.545,0.347,1.0,0.410]],
}


static func draw(background: Node2D, texture: Texture2D, source: Rect2, scene: String, staged: bool) -> void:
	if not WINDOWS.has(scene): return
	var outside := GameState.CLOCK.tint(GameState.clock_minutes, GameState.city)
	var inside := GameState.CLOCK.tint(GameState.clock_minutes, GameState.city, true)
	var tint := outside if staged else Color(outside.r / inside.r, outside.g / inside.g, outside.b / inside.b)
	for aperture: Array in WINDOWS[scene]:
		_patch(background, texture, source, aperture, tint)
	for fitting: Array in INDOOR.get(scene, []):
		_patch(background, texture, source, fitting, inside if staged else Color.WHITE)
	if scene == "IstanbulOtel": _wall_clock(background, Vector2(812,150), Vector2.ONE, inside if staged else Color.WHITE)
	if scene == "MumbaiHotel": _wall_clock(background, Vector2(81,137), Vector2(0.67,1.03), inside if staged else Color.WHITE)


static func _patch(background: Node2D, texture: Texture2D, source: Rect2, bounds: Array, tint: Color) -> void:
	var unit := Rect2(bounds[0], bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1])
	background.draw_texture_rect_region(texture, Rect2(unit.position * Vector2(1152,648), unit.size * Vector2(1152,648)),
		Rect2(source.position + unit.position * source.size, unit.size * source.size), tint)


static func _wall_clock(ci: Node2D, at: Vector2, dimensions: Vector2, tint: Color) -> void:
	ci.draw_set_transform(at, 0.0, dimensions)
	var outline := PackedVector2Array()
	for i in range(24): outline.append((Vector2.from_angle(float(i) * TAU / 24.0) * 20).round())
	ci.draw_colored_polygon(outline, Color("f1e7d2") * tint)
	for i in range(12):
		var direction := Vector2.from_angle(float(i) * TAU / 12.0)
		ci.draw_line((direction * 16).round(), (direction * 18).round(), Color("433e37") * tint, 2, false)
	var minute := GameState.CLOCK.local_minute(GameState.clock_minutes, GameState.city)
	var long_hand := Vector2.from_angle(minute / 60.0 * TAU - PI / 2.0) * 14
	var short_hand := Vector2.from_angle(minute / 720.0 * TAU - PI / 2.0) * 10
	ci.draw_line(Vector2.ZERO, long_hand.round(), Color("332d29") * tint, 2, false)
	ci.draw_line(Vector2.ZERO, short_hand.round(), Color("332d29") * tint, 3, false)
	ci.draw_rect(Rect2(-1,-1,3,3), Color("332d29") * tint)
	ci.draw_set_transform(Vector2.ZERO)
