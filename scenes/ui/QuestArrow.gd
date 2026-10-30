extends CanvasLayer

# Optional guidance, toggled by the player and remembered across scenes.
#
# Where "there" is comes from SceneGraph, so the target is a scene anywhere in
# the world and what the arrow points at is the way out of THIS one: the
# station door when the place is across the city, the platform once you are
# down in the station, the shop door when you are on its street.

# Preloaded rather than reached for by class_name: global class names live in
# a cache the editor writes, and this project's tools all run headless with
# --script, where that cache is stale. Services preloads Streetside for the
# same reason.
const SG := preload("res://scenes/world/SceneGraph.gd")
const ATLAS := preload("res://scenes/ui/MapAtlas.gd")

const ORBIT := 66.0                        # how far from the player it floats
const CLR   := Color(0.929, 0.353, 0.302)
const EDGE  := Color(0.10, 0.05, 0.07, 0.80)

var _t: float = 0.0
var _aim: Vector2 = Vector2.ZERO
var _on: bool = false
var _canvas: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 11
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_arrow)
	add_child(_canvas)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quest_arrow") and not event.is_echo() and GameState.clock_can_run():
		get_viewport().set_input_as_handled()
		SaveManager.settings["quest_arrow"] = not bool(SaveManager.settings.get("quest_arrow", false))
		SaveManager.save_settings()


func _process(delta: float) -> void:
	_t += delta
	var was: bool = _on
	_on = false
	# The clock uses the same exploration boundaries: no menus, dialogue,
	# staged scenes or transitions. Process while paused to clear the drawing.
	if bool(SaveManager.settings.get("quest_arrow", false)) and GameState.clock_can_run():
		_aim = _way()
		_on = _aim != Vector2.ZERO
	if _on or was:
		_canvas.queue_redraw()


# The point in this scene to head for, in world space, or ZERO for none.
func _way() -> Vector2:
	var target: String = GameState.quest_target()
	if target.is_empty():
		return Vector2.ZERO
	var here: String = _here()
	# Standing in it already. The step is about doing something here, not
	# about getting here, and an arrow would be pointing at your own feet.
	if here.is_empty() or here == target:
		return Vector2.ZERO
	var next: String = SG.route(here, target)
	if next.is_empty(): return Vector2.ZERO
	var current := get_tree().current_scene
	if current != null and current.scene_file_path == here:
		# Authored scenery can relocate an exit or platform after scene loading.
		for pin: Dictionary in ATLAS.live_markers(current):
			if pin.target == next or next in pin.get("destinations", []):
				return pin.pos
	return SG.way_to(here, target)


# Which scene this arrow is standing in.
#
# `current_scene` is the answer in a running game and is null when a tool
# renders a district into its own SubViewport - which is exactly the situation
# in which somebody is looking at the arrow to see whether it works. Falling
# back to the branch this UI was instanced into means the render tells the
# truth instead of quietly showing nothing.
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
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var xf: Transform2D = get_viewport().get_canvas_transform()
	var from: Vector2 = xf * player.global_position
	var to: Vector2 = xf * _aim
	var dir: Vector2 = to - from
	if dir.length() < 2.0:
		return
	dir = dir.normalized()

	# It bobs along its own axis rather than sitting still, so it reads as
	# "this way" instead of as a marker parked in the air.
	# Still fades in and out so it reads as live, but stops travelling.
	var beat: float = 0.5 + 0.5 * sin(_t * 3.2) * SaveManager.motion()
	var c: Vector2 = from + dir * (ORBIT + beat * 6.0)
	var n: Vector2 = Vector2(-dir.y, dir.x)
	var a: float = 0.60 + 0.40 * beat

	var tip: Vector2 = c + dir * 12.0
	var lf: Vector2 = c - dir * 5.0 + n * 9.5
	var rt: Vector2 = c - dir * 5.0 - n * 9.5
	# A dark pass first, a little larger. Half the streets in this game are
	# dark and half are pale, and a flat red triangle disappears into one of
	# them without it.
	_canvas.draw_colored_polygon(PackedVector2Array([
		c + dir * 15.5, c - dir * 7.5 + n * 12.5, c - dir * 7.5 - n * 12.5,
	]), Color(EDGE.r, EDGE.g, EDGE.b, EDGE.a * a))
	_canvas.draw_colored_polygon(PackedVector2Array([tip, lf, rt]),
		Color(CLR.r, CLR.g, CLR.b, a))
	# A short tail, so at a glance it is a direction and not a caret.
	_canvas.draw_line(c - dir * 4.0, c - dir * 14.0,
		Color(CLR.r, CLR.g, CLR.b, a * 0.75), 3.0)
