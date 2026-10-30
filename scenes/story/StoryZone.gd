extends Node2D

# Where the thing he is carrying goes.
#
# A ring on the pavement and a small chevron over it, the same warm gold the
# game uses for "you did this". Not a glowing quest beacon: the person who
# asked him is standing right there, and this only answers the one question
# her pointing could not - which bit of the pavement.

const RING := Color(0.886, 0.706, 0.361)

var radius: float = 34.0
var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_t * 3.2) * SaveManager.motion()
	draw_set_transform(Vector2(0.0, 22.0), 0.0, Vector2(1.0, 0.36))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(RING, 0.30 + 0.30 * pulse), 3.0)
	draw_circle(Vector2.ZERO, radius * 0.72, Color(RING, 0.06 + 0.05 * pulse))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var y: float = -18.0 - 4.0 * pulse
	draw_colored_polygon(PackedVector2Array([Vector2(-7.0, y), Vector2(7.0, y),
		Vector2(0.0, y + 8.0)]), Color(RING, 0.85))
