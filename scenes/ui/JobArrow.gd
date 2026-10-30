extends CanvasLayer

# Where this crate goes.
#
# ── Why this is not QuestArrow ───────────────────────────────────────────────
#
# QuestArrow is player-toggled and points toward another scene. This gold
# work marker stays immediate: a man holding a crate is not lost, he is holding a
# crate, and "which corner of this yard does it go in" is not a question the
# game gains anything by withholding. Work is legible to the person doing it.
# Nobody hands you a load and then makes you search.
#
# So this one is immediate, and it points at the exact end of the loop he needs
# next - the pile when his hands are empty, the shelf when they are not. When
# that end is on screen the JobSpot draws its own marker and this stays out of
# the way; this is for when it is off the edge, or in another district
# entirely, in which case it points at the way out of this one.

const SG := preload("res://scenes/world/SceneGraph.gd")

const CLR  := Color(0.886, 0.706, 0.361)
const EDGE := Color(0.10, 0.08, 0.05, 0.85)

# How far in from the edge of the screen the arrow rides.
const INSET := 54.0
# A spot this close to the edge counts as off it: an arrow that vanishes the
# instant the target's shadow appears reads as a glitch.
const MARGIN := 40.0

var _t: float = 0.0
var _canvas: Control
var _aim: Vector2 = Vector2.ZERO
var _on: bool = false
var _label: String = ""


func _ready() -> void:
	layer = 11
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_arrow)
	add_child(_canvas)


func _process(delta: float) -> void:
	_t += delta
	var was: bool = _on
	_on = false
	_aim = Vector2.ZERO
	if not GameState.active_job.is_empty():
		_aim = _where()
		_on = _aim != Vector2.ZERO
	if _on or was:
		_canvas.queue_redraw()


# The point to head for, in world space, or ZERO for "say nothing".
func _where() -> Vector2:
	var spot: Node2D = _live_spot()
	if spot != null:
		# On screen already, and it is drawing its own marker. Two things
		# pointing at one crate is worse than one.
		if _on_screen(spot.global_position):
			return Vector2.ZERO
		_label = Services.job_step()
		return spot.global_position
	# Not in this district. The job knows which one it is in; SceneGraph knows
	# which door leads there from here.
	var want: String = Services.job_scene(GameState.active_job)
	if want.is_empty():
		return Vector2.ZERO
	var here: String = _here()
	if here.is_empty() or here == want:
		return Vector2.ZERO
	_label = Services.job_title(GameState.active_job)
	return SG.way_to(here, want)


# The end of the loop he needs next. JobSpot.is_live() already encodes it - a
# take-pile with his hands full is not it, and neither is a give-shelf with his
# hands empty - so there is at most one of these at a time.
func _live_spot() -> Node2D:
	for n in get_tree().get_nodes_in_group("job_spot"):
		var spot := n as Node2D
		if spot == null or not is_instance_valid(spot):
			continue
		if spot.has_method("is_live") and bool(spot.call("is_live")):
			return spot
	return null


func _on_screen(world: Vector2) -> bool:
	var xf: Transform2D = get_viewport().get_canvas_transform()
	var at: Vector2 = xf * world
	var size: Vector2 = get_viewport().get_visible_rect().size
	if at.x <= MARGIN or at.y <= MARGIN:
		return false
	return at.x < size.x - MARGIN and at.y < size.y - MARGIN


# Which scene this arrow is standing in. Same fallback as QuestArrow: in a tool
# render there is no current_scene, and the render is exactly when somebody is
# looking to see whether the arrow works.
func _here() -> String:
	var cur := get_tree().current_scene
	if cur != null and not cur.scene_file_path.is_empty():
		return cur.scene_file_path
	var n: Node = self
	while n != null:
		var f: String = n.scene_file_path
		if f.contains("/scenes/world/"):
			return f
		n = n.get_parent()
	return ""


func _draw_arrow() -> void:
	if not _on:
		return
	var size: Vector2 = _canvas.size
	var xf: Transform2D = get_viewport().get_canvas_transform()
	var to: Vector2 = xf * _aim
	var mid: Vector2 = size * 0.5
	var dir: Vector2 = to - mid
	if dir.length() < 2.0:
		return
	dir = dir.normalized()

	# Parked at the edge of the screen in the direction of the thing, rather
	# than orbiting the player: a load has a destination, and the destination
	# is off that way, past the edge.
	var half: Vector2 = mid - Vector2(INSET, INSET)
	var span_x: float = half.x / maxf(absf(dir.x), 0.0001)
	var span_y: float = half.y / maxf(absf(dir.y), 0.0001)
	var c: Vector2 = mid + dir * minf(span_x, span_y)

	var beat: float = 0.5 + 0.5 * sin(_t * 3.0) * SaveManager.motion()
	var a: float = 0.65 + 0.35 * beat
	var n: Vector2 = Vector2(-dir.y, dir.x)
	# Dark pass first: half the streets in this game are pale and half are
	# dark, and a flat gold triangle disappears into one of them.
	_canvas.draw_colored_polygon(PackedVector2Array([
		c + dir * 17.0, c - dir * 8.0 + n * 13.0, c - dir * 8.0 - n * 13.0,
	]), Color(EDGE.r, EDGE.g, EDGE.b, EDGE.a * a))
	_canvas.draw_colored_polygon(PackedVector2Array([
		c + dir * 13.0, c - dir * 5.0 + n * 10.0, c - dir * 5.0 - n * 10.0,
	]), Color(CLR.r, CLR.g, CLR.b, a))

	if _label.is_empty():
		return
	# The words sit inboard of the arrow, so they are never half off the screen.
	var font: Font = ThemeDB.fallback_font
	var w: float = font.get_string_size(_label, HORIZONTAL_ALIGNMENT_LEFT,
		-1, 13).x
	var at: Vector2 = c - dir * 26.0 - Vector2(w * 0.5, -5.0)
	at.x = clampf(at.x, 12.0, maxf(12.0, size.x - w - 12.0))
	at.y = clampf(at.y, 24.0, maxf(24.0, size.y - 16.0))
	_canvas.draw_string(font, at + Vector2(1.0, 1.0), _label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(EDGE.r, EDGE.g, EDGE.b, a))
	_canvas.draw_string(font, at, _label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
		Color(0.98, 0.94, 0.86, a))
