extends Node2D

# Hotel corridor — a row of numbered doors, wall lamps between them, a
# runner carpet down the middle, and a window at the far end letting in
# the dawn. Door numbers come from GameState.hotel_floor.

const VW  := 1152.0
const VH  := 648.0
const WALL := 305.0
const EXT := 4000.0

const C_VOID    := Color(0.030, 0.026, 0.058)
const C_CEIL    := Color(0.055, 0.045, 0.075)
const C_WALL    := Color(0.150, 0.105, 0.125)
const C_STRIPE  := Color(0.170, 0.120, 0.140)
const C_WAINSCOT:= Color(0.105, 0.070, 0.058)
const C_FLOOR   := Color(0.195, 0.095, 0.092)
const C_RUNNER  := Color(0.240, 0.125, 0.105)
const C_DOOR    := Color(0.200, 0.130, 0.075)
const C_DOOR_D  := Color(0.140, 0.088, 0.050)
const C_WARM    := Color(0.92, 0.72, 0.34)
const C_METAL   := Color(0.34, 0.35, 0.42)

const DOOR_XS := [252.0, 452.0, 652.0, 852.0]

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)

	# Ceiling + wallpaper + wainscot
	draw_rect(Rect2(0, 0, VW, 50), C_CEIL)
	draw_rect(Rect2(0, 48, VW, 3), Color(0.09, 0.07, 0.10))
	draw_rect(Rect2(0, 50, VW, WALL - 50), C_WALL)
	for i in range(int(VW / 46.0) + 1):
		draw_rect(Rect2(float(i) * 46.0, 50, 20, WALL - 50), C_STRIPE)
	draw_rect(Rect2(0, WALL - 44, VW, 44), C_WAINSCOT)
	draw_rect(Rect2(0, WALL - 44, VW, 3), Color(0.16, 0.11, 0.09))

	_draw_elevator()
	_draw_doors()
	_draw_lamps()
	_draw_end_window()
	_draw_floor()
	_draw_shell()


func _draw_shell() -> void:
	var c_side := Color(0.112, 0.078, 0.092)
	var c_edge := Color(0.068, 0.045, 0.055)
	draw_rect(Rect2(0, 40, 44, 608), c_side)
	draw_rect(Rect2(40, 40, 4, 608), c_edge)
	draw_rect(Rect2(1108, 40, 44, 608), c_side)
	draw_rect(Rect2(1108, 40, 4, 608), c_edge)
	draw_rect(Rect2(0, 606, VW, 42), Color(0.082, 0.055, 0.066))
	draw_rect(Rect2(0, 606, VW, 4), Color(0.132, 0.090, 0.105))
	draw_rect(Rect2(44, WALL, 4, 302), Color(0.145, 0.098, 0.082))
	draw_rect(Rect2(1104, WALL, 4, 302), Color(0.145, 0.098, 0.082))


func _draw_elevator() -> void:
	var ex := 58.0
	draw_rect(Rect2(ex - 8, 88, 118, WALL - 88 + 2), Color(0.10, 0.08, 0.09))
	draw_rect(Rect2(ex, 96, 102, WALL - 98), Color(0.16, 0.16, 0.20))
	for i in range(2):
		var px := ex + 5.0 + float(i) * 47.0
		draw_rect(Rect2(px, 102, 44, WALL - 108), C_METAL)
		draw_rect(Rect2(px + 4, 108, 36, WALL - 120),
			Color(C_METAL.r * 1.12, C_METAL.g * 1.12, C_METAL.b * 1.12))
	draw_rect(Rect2(ex + 50, 102, 2, WALL - 108), Color(0.08, 0.08, 0.10))
	# Floor indicator shows this floor's number
	draw_rect(Rect2(ex + 28, 74, 46, 14), Color(0.06, 0.05, 0.07))
	draw_string(ThemeDB.fallback_font, Vector2(ex + 46, 85),
		str(GameState.hotel_floor), HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
		Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.90))


func _draw_doors() -> void:
	var floor_n := GameState.hotel_floor
	for i in range(DOOR_XS.size()):
		var dx: float = DOOR_XS[i]
		# Frame
		draw_rect(Rect2(dx - 6, 138, 96, WALL - 138 + 2), Color(0.10, 0.07, 0.05))
		# Door
		draw_rect(Rect2(dx, 144, 84, WALL - 146), C_DOOR)
		draw_rect(Rect2(dx + 8, 154, 68, 58), C_DOOR_D)
		draw_rect(Rect2(dx + 8, 222, 68, 66), C_DOOR_D)
		# Handle
		draw_circle(Vector2(dx + 72, 240), 4.0, Color(0.62, 0.52, 0.26))
		# Number plate
		var num := "%d0%d" % [floor_n, i + 1]
		draw_rect(Rect2(dx + 24, 120, 36, 16), Color(0.30, 0.22, 0.12))
		draw_rect(Rect2(dx + 26, 122, 32, 12), Color(0.07, 0.055, 0.05))
		draw_string(ThemeDB.fallback_font, Vector2(dx + 31, 132), num,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.78, 0.55))


func _draw_lamps() -> void:
	# Warm sconces between the doors
	for lx in [200.0, 400.0, 600.0, 800.0, 1000.0]:
		draw_rect(Rect2(lx - 3, 126, 6, 15), Color(0.10, 0.08, 0.07))
		var gl := 0.85 + 0.15 * sin(_t * 2.9 + lx * 0.1)
		draw_circle(Vector2(lx, 122), 11.0, Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.10 * gl))
		draw_circle(Vector2(lx, 122), 4.0,  Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.55 * gl))


func _draw_end_window() -> void:
	# Dawn through the corridor-end window
	var wx := 1030.0
	var morning := GameState.is_morning()
	draw_rect(Rect2(wx - 6, 108, 76, 170), Color(0.10, 0.07, 0.06))
	if morning:
		draw_rect(Rect2(wx, 114, 64, 112), Color(0.42, 0.58, 0.74))
		draw_rect(Rect2(wx, 226, 64, 20), Color(0.72, 0.72, 0.62, 0.85))
		draw_rect(Rect2(wx, 246, 64, 26), Color(0.30, 0.44, 0.26))
	else:
		draw_rect(Rect2(wx, 114, 64, 158), Color(0.072, 0.058, 0.148))
		draw_rect(Rect2(wx, 190, 64, 36), Color(0.160, 0.090, 0.182))
		draw_rect(Rect2(wx, 226, 64, 20), Color(0.380, 0.200, 0.158, 0.80))
		draw_rect(Rect2(wx, 246, 64, 26), Color(0.092, 0.162, 0.116))
	draw_rect(Rect2(wx + 30, 114, 3, 158), Color(0.10, 0.07, 0.06))
	draw_rect(Rect2(wx, 186, 64, 3), Color(0.10, 0.07, 0.06))
	# Light pooling in from the window
	var pts := PackedVector2Array()
	for s in range(20):
		var a := float(s) / 20.0 * TAU
		pts.append(Vector2(wx + 32 + cos(a) * 110.0, 420.0 + sin(a) * 60.0))
	var pool := Color(0.72, 0.72, 0.55, 0.07) if morning else Color(0.380, 0.200, 0.158, 0.05)
	draw_colored_polygon(pts, pool)


func _draw_floor() -> void:
	# Tiled floors from the handoff tileset (mode-aware: dawn/morning)
	WorldArt.draw_tiles(self, WorldArt.TILE_CARPET, Rect2(40, WALL, 1072, 610 - WALL))
	draw_rect(Rect2(40, WALL, 1072, 4), Color(0.09, 0.05, 0.05))
	WorldArt.draw_tiles(self, WorldArt.TILE_RUNNER, Rect2(44, 400, 1064, 128))
	draw_rect(Rect2(44, 400, 1064, 2), Color(0.30, 0.17, 0.12))
	draw_rect(Rect2(44, 526, 1064, 2), Color(0.30, 0.17, 0.12))
