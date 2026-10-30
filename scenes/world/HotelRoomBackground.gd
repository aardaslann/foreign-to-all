extends Node2D

# Room 304 — small, warm, quiet. A bed with a teal blanket, dawn through the
# curtained window, a radiator ticking below it, a lamp on the nightstand.
# The first safe place on this planet.

const VW  := 1152.0
const VH  := 648.0
const WALL := 305.0
const EXT := 4000.0

const C_VOID   := Color(0.030, 0.026, 0.058)
const C_CEIL   := Color(0.055, 0.045, 0.075)
const C_WALL   := Color(0.140, 0.110, 0.130)
const C_STRIPE := Color(0.155, 0.122, 0.142)
const C_FLOOR  := Color(0.185, 0.120, 0.080)   # wooden boards
const C_BOARD  := Color(0.160, 0.100, 0.065)
const C_WOOD   := Color(0.240, 0.155, 0.090)
const C_WOOD_D := Color(0.170, 0.105, 0.060)
const C_WARM   := Color(0.92, 0.72, 0.34)

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-EXT, -EXT, VW + EXT * 2, VH + EXT * 2), C_VOID)

	# Ceiling + walls
	draw_rect(Rect2(0, 0, VW, 46), C_CEIL)
	draw_rect(Rect2(0, 44, VW, 3), Color(0.09, 0.07, 0.10))
	draw_rect(Rect2(0, 46, VW, WALL - 46), C_WALL)
	for i in range(int(VW / 52.0) + 1):
		draw_rect(Rect2(float(i) * 52.0, 46, 24, WALL - 46), C_STRIPE)
	draw_rect(Rect2(0, WALL - 10, VW, 10), Color(0.105, 0.075, 0.062))

	_draw_window()
	_draw_door()
	_draw_floor()
	_draw_rug()
	_draw_bed()
	_draw_nightstand()
	_draw_dresser()
	_draw_shell()


func _draw_shell() -> void:
	var c_side := Color(0.108, 0.085, 0.100)
	var c_edge := Color(0.062, 0.048, 0.058)
	draw_rect(Rect2(0, 36, 44, 612), c_side)
	draw_rect(Rect2(40, 36, 4, 612), c_edge)
	draw_rect(Rect2(1108, 36, 44, 612), c_side)
	draw_rect(Rect2(1108, 36, 4, 612), c_edge)
	draw_rect(Rect2(0, 606, VW, 42), Color(0.080, 0.060, 0.072))
	draw_rect(Rect2(0, 606, VW, 4), Color(0.128, 0.098, 0.112))
	draw_rect(Rect2(44, WALL, 4, 302), Color(0.140, 0.105, 0.088))
	draw_rect(Rect2(1104, WALL, 4, 302), Color(0.140, 0.105, 0.088))


# Rounded-rect helper for soft furniture shapes
func _rrect(r: Rect2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var cs := [
		Vector2(r.position.x + rad, r.position.y + rad),
		Vector2(r.end.x - rad,      r.position.y + rad),
		Vector2(r.end.x - rad,      r.end.y - rad),
		Vector2(r.position.x + rad, r.end.y - rad),
	]
	var a0 := [PI, PI * 1.5, 0.0, PI * 0.5]
	for i in range(4):
		for s in range(7):
			var a: float = a0[i] + float(s) / 6.0 * (PI * 0.5)
			pts.append(cs[i] + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, col)


func _draw_window() -> void:
	var wx := 660.0
	# Curtains
	draw_rect(Rect2(wx - 40, 60, 36, 230), Color(0.24, 0.14, 0.16))
	draw_rect(Rect2(wx + 244, 60, 36, 230), Color(0.24, 0.14, 0.16))
	for cx in [wx - 40.0, wx + 244.0]:
		for f in range(3):
			draw_rect(Rect2(cx + 6 + float(f) * 10.0, 60, 4, 230), Color(0.20, 0.11, 0.13))
	# Frame + the sky — dawn before sleeping, bright morning after
	var morning := GameState.is_morning()
	draw_rect(Rect2(wx - 8, 66, 256, 218), Color(0.10, 0.07, 0.06))
	if morning:
		draw_rect(Rect2(wx, 74, 240, 202), Color(0.44, 0.62, 0.78))
		draw_rect(Rect2(wx, 74, 240, 60), Color(0.38, 0.56, 0.75))
		# Morning sun with a soft halo
		draw_circle(Vector2(wx + 178, 124), 26.0, Color(1.0, 0.94, 0.72, 0.35))
		draw_circle(Vector2(wx + 178, 124), 15.0, Color(1.0, 0.96, 0.80, 0.95))
		# Rooftops catching the light
		for b in [[10.0, 26.0], [64.0, 40.0], [128.0, 22.0], [180.0, 34.0]]:
			draw_rect(Rect2(wx + float(b[0]), 234.0 - float(b[1]), 44.0, float(b[1])),
				Color(0.30, 0.34, 0.44))
			draw_rect(Rect2(wx + float(b[0]), 234.0 - float(b[1]), 44.0, 4.0),
				Color(0.86, 0.78, 0.58))
	else:
		draw_rect(Rect2(wx, 74, 240, 202), Color(0.072, 0.058, 0.148))
		draw_rect(Rect2(wx, 158, 240, 48), Color(0.160, 0.090, 0.182))
		draw_rect(Rect2(wx, 206, 240, 28), Color(0.380, 0.200, 0.158, 0.85))
		draw_rect(Rect2(wx, 234, 240, 42), Color(0.046, 0.042, 0.088))
		for b in [[10.0, 26.0], [64.0, 40.0], [128.0, 22.0], [180.0, 34.0]]:
			draw_rect(Rect2(wx + float(b[0]), 234.0 - float(b[1]), 44.0, float(b[1])),
				Color(0.040, 0.036, 0.078))
		# A star still hanging on
		draw_rect(Rect2(wx + 186, 96, 2, 2), Color(0.88, 0.86, 1.0, 0.8))
	# Mullions
	draw_rect(Rect2(wx + 117, 74, 4, 202), Color(0.10, 0.07, 0.06))
	draw_rect(Rect2(wx, 172, 240, 4), Color(0.10, 0.07, 0.06))
	# Radiator under the window — ribs and a slow tick of warmth
	draw_rect(Rect2(wx + 20, WALL - 52, 200, 44), Color(0.11, 0.10, 0.12))
	for r in range(9):
		draw_rect(Rect2(wx + 26 + float(r) * 21.0, WALL - 48, 14, 36),
			Color(0.17, 0.16, 0.19))
	# Light falling into the room — warm at dawn, bright in the morning
	var pts := PackedVector2Array()
	for s in range(22):
		var a := float(s) / 22.0 * TAU
		pts.append(Vector2(wx + 120 + cos(a) * 190.0, 430.0 + sin(a) * 70.0))
	var pool := Color(0.95, 0.90, 0.65, 0.09) if morning else Color(0.380, 0.200, 0.158, 0.05)
	draw_colored_polygon(pts, pool)


func _draw_door() -> void:
	# The door back to the corridor, on the left wall
	var dx := 56.0
	draw_rect(Rect2(dx - 6, 120, 96, WALL - 120 + 2), Color(0.10, 0.07, 0.05))
	draw_rect(Rect2(dx, 126, 84, WALL - 128), Color(0.200, 0.130, 0.075))
	draw_rect(Rect2(dx + 8, 136, 68, 62), C_WOOD_D)
	draw_rect(Rect2(dx + 8, 208, 68, 70), C_WOOD_D)
	draw_circle(Vector2(dx + 72, 226), 4.0, Color(0.62, 0.52, 0.26))


func _draw_bed() -> void:
	# Classic angled-top-down bed: headboard → pillows → folded sheet → quilt
	var bx := 292.0
	var by := 240.0
	var bw := 226.0

	# Soft shadow around the base
	_rrect(Rect2(bx - 6, by + 20, bw + 12, 172), 14.0, Color(0, 0, 0, 0.22))
	# Wooden frame
	_rrect(Rect2(bx, by + 12, bw, 176), 10.0, Color(0.115, 0.075, 0.045))
	# Headboard
	_rrect(Rect2(bx + 2, by, bw - 4, 34), 9.0, C_WOOD_D)
	_rrect(Rect2(bx + 10, by + 6, bw - 20, 22), 6.0, C_WOOD)
	# Mattress / sheet
	_rrect(Rect2(bx + 8, by + 30, bw - 16, 150), 8.0, Color(0.88, 0.84, 0.76))
	# Pillows — two puffy layers each
	_rrect(Rect2(bx + 18, by + 38, 90, 30), 10.0, Color(0.80, 0.76, 0.68))
	_rrect(Rect2(bx + 21, by + 40, 84, 24), 9.0, Color(0.96, 0.93, 0.87))
	_rrect(Rect2(bx + 118, by + 38, 90, 30), 10.0, Color(0.80, 0.76, 0.68))
	_rrect(Rect2(bx + 121, by + 40, 84, 24), 9.0, Color(0.96, 0.93, 0.87))
	# Folded top sheet band
	draw_rect(Rect2(bx + 8, by + 76, bw - 16, 12), Color(0.96, 0.93, 0.87))
	draw_rect(Rect2(bx + 8, by + 86, bw - 16, 3), Color(0.74, 0.70, 0.62))
	# Quilt — teal, the player's colour: this bed is claimed
	_rrect(Rect2(bx + 8, by + 89, bw - 16, 91), 8.0, Color(0.115, 0.46, 0.41))
	# Quilt stitching grid
	for i in range(3):
		draw_rect(Rect2(bx + 8, by + 110.0 + float(i) * 24.0, bw - 16, 1.5),
			Color(0.085, 0.36, 0.32, 0.85))
	for i in range(4):
		draw_rect(Rect2(bx + 34.0 + float(i) * 44.0, by + 89, 1.5, 91),
			Color(0.085, 0.36, 0.32, 0.85))
	# Side shading + bottom hem
	draw_rect(Rect2(bx + 8, by + 89, 6, 91), Color(0.080, 0.34, 0.30, 0.75))
	draw_rect(Rect2(bx + bw - 14, by + 89, 6, 91), Color(0.080, 0.34, 0.30, 0.75))
	draw_rect(Rect2(bx + 8, by + 170, bw - 16, 10), Color(0.080, 0.33, 0.29))
	# Footboard
	draw_rect(Rect2(bx + 2, by + 182, bw - 4, 8), C_WOOD_D)
	draw_rect(Rect2(bx + 2, by + 182, bw - 4, 2), Color(0.30, 0.20, 0.11))


func _draw_nightstand() -> void:
	var nx := 540.0
	var ny := 268.0
	draw_rect(Rect2(nx - 4, ny - 4, 64, 58), C_WOOD_D)
	draw_rect(Rect2(nx, ny, 56, 50), C_WOOD)
	draw_rect(Rect2(nx + 8, ny + 10, 40, 14), C_WOOD_D)
	draw_circle(Vector2(nx + 28, ny + 17), 2.0, Color(0.62, 0.52, 0.26))
	# Lamp — on at dawn, switched off once it's morning
	draw_rect(Rect2(nx + 24, ny - 26, 6, 24), Color(0.10, 0.08, 0.07))
	draw_rect(Rect2(nx + 14, ny - 38, 26, 14), Color(0.35, 0.14, 0.12))
	if not GameState.is_morning():
		var gl := 0.85 + 0.15 * sin(_t * 2.1)
		draw_circle(Vector2(nx + 27, ny - 28), 20.0, Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.10 * gl))
		draw_circle(Vector2(nx + 27, ny - 28), 7.0,  Color(C_WARM.r, C_WARM.g, C_WARM.b, 0.35 * gl))


func _draw_dresser() -> void:
	var dx := 960.0
	var dy := 250.0
	draw_rect(Rect2(dx - 4, dy - 4, 128, 66), C_WOOD_D)
	draw_rect(Rect2(dx, dy, 120, 58), C_WOOD)
	for r in range(2):
		draw_rect(Rect2(dx + 8, dy + 8 + float(r) * 24.0, 104, 18), C_WOOD_D)
		draw_circle(Vector2(dx + 60, dy + 17 + float(r) * 24.0), 2.5, Color(0.62, 0.52, 0.26))
	# Mirror above
	draw_rect(Rect2(dx + 22, dy - 90, 76, 80), Color(0.30, 0.22, 0.12))
	draw_rect(Rect2(dx + 27, dy - 85, 66, 70), Color(0.10, 0.12, 0.16))
	draw_rect(Rect2(dx + 31, dy - 81, 20, 40), Color(0.16, 0.19, 0.24, 0.8))


func _draw_floor() -> void:
	# Wooden boards from the handoff tileset (mode-aware)
	WorldArt.draw_tiles(self, WorldArt.TILE_WOOD, Rect2(40, WALL, 1072, 610 - WALL))
	draw_rect(Rect2(40, WALL, 1072, 4), Color(0.09, 0.06, 0.04))


func _draw_rug() -> void:
	WorldArt.draw_tiles(self, WorldArt.TILE_CARPET, Rect2(330, 470, 300, 110))
	draw_rect(Rect2(330, 470, 300, 110), Color(0.30, 0.17, 0.12, 0.8), false, 2.0)
