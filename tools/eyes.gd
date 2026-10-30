extends SceneTree

# What the player actually sees.
#
# shoot.gd renders the PLATE: 1152x648, flat, no camera, no interface. That is
# the right tool for judging a drawing and the wrong one for judging anything
# else, because the game does not look like that. It runs at 1920x1080 through
# a camera zoomed 1.667x with the interface on top, and a thing can be perfect
# on the plate and wrong on the screen - text is the obvious case, since a
# glyph rasterised at twelve pixels and then blown up by two thirds is a
# smear, and the plate never shows it.
#
#   cp tools/eyes.gd eyes.gd
#   <godot> --path . --script res://eyes.gd -- <scene.tscn> <out.png> [more pairs]
#   rm eyes.gd
#
# --morning / --city=<name> as shoot.gd. --at=x,y moves the player first, so a
# corner of a plate can be looked at without walking there. --job=<id> accepts
# a job before the scene is built, so the piles a job puts in the world are
# actually there to be looked at - they are invisible when nobody is doing it.

var _jobs: Array = []
var _vp: SubViewport = null
var _inst: Node = null
var _wait: int = 0
var _at: Vector2 = Vector2.ZERO
var _has_at: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var gs = root.get_node_or_null("GameState")
	for a: String in args:
		if a.begins_with("--job="):
			var jid: String = a.substr(6)
			if gs != null:
				gs.call("accept_job", jid)
			var sv = root.get_node_or_null("Services")
			if sv != null:
				sv.call("open_job_quest", jid)
	var pairs: Array = []
	for a in args:
		var s: String = String(a)
		if s == "--morning" and gs != null:
			gs.set("time_of_day", "morning")
		elif s.begins_with("--city=") and gs != null:
			gs.set("city", s.substr(7))
		elif s.begins_with("--at="):
			var xy: PackedStringArray = s.substr(5).split(",")
			if xy.size() == 2:
				_at = Vector2(float(xy[0]), float(xy[1]))
				_has_at = true
		elif not s.begins_with("--"):
			pairs.append(s)
	for i in range(0, pairs.size() - 1, 2):
		_jobs.append([pairs[i], pairs[i + 1]])
	_vp = SubViewport.new()
	_vp.size = Vector2i(1920, 1080)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	_next()


func _next() -> void:
	if _inst != null:
		_inst.queue_free()
		_inst = null
	if _jobs.is_empty():
		quit(0)
		return
	var job: Array = _jobs.pop_front()
	var packed: PackedScene = load(String(job[0]))
	if packed == null:
		print("FAILED ", job[0])
		_next()
		return
	_inst = packed.instantiate()
	_vp.add_child(_inst)
	if _has_at:
		var p: Node = _inst.get_node_or_null("Player")
		if p != null and p is Node2D:
			(p as Node2D).position = _at
	_wait = 64
	set_meta("out", String(job[1]))


func _process(_delta: float) -> bool:
	if _inst == null:
		return false
	_wait -= 1
	if _wait > 0:
		return false
	_vp.get_texture().get_image().save_png(String(get_meta("out")))
	print("shot ", get_meta("out"))
	_next()
	return false
