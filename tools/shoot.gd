extends SceneTree

# Render world scenes to PNG so the plates can actually be looked at.
# Autoloads only exist by _initialize(), not _init().
#
#   cp tools/shoot.gd shoot.gd
#   <godot> --path . --script res://shoot.gd -- <scene.tscn> <out.png> [more pairs]
#   rm shoot.gd

var _jobs: Array = []
var _vp: SubViewport = null
var _inst: Node = null
var _wait: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	# --morning / --city=<name> for the rooms that colour themselves from
	# GameState rather than from the scene.
	var gs = root.get_node_or_null("GameState")
	if gs != null:
		for a in args:
			if String(a) == "--morning":
				gs.set("time_of_day", "morning")
			elif String(a).begins_with("--city="):
				gs.set("city", String(a).substr(7))
	var pairs: Array = []
	for a2 in args:
		if not String(a2).begins_with("--"):
			pairs.append(String(a2))
	for i in range(0, pairs.size() - 1, 2):
		_jobs.append([pairs[i], pairs[i + 1]])
	_vp = SubViewport.new()
	_vp.size = Vector2i(1152, 648)
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
		print("FAILED TO LOAD ", job[0])
		_next()
		return
	_inst = packed.instantiate()
	# Drop the player (it carries the camera) and the UI, so the plate
	# renders flat at authoring coordinates instead of through a lens.
	for child in _inst.get_children():
		if child.name in ["Player", "UILayer"]:
			_inst.remove_child(child)
			child.queue_free()
	_vp.add_child(_inst)
	# Long enough for deferred work to land AND draw. Interactables attaches
	# every Glow with call_deferred, so a four-frame wait could catch a
	# street before its lights were on. A render that is not what the player
	# sees is worse than no render.
	_wait = 14
	set_meta("out", String(job[1]))


func _process(_delta: float) -> bool:
	if _inst == null:
		return false
	_wait -= 1
	if _wait > 0:
		return false
	var img: Image = _vp.get_texture().get_image()
	img.save_png(String(get_meta("out")))
	print("shot ", get_meta("out"))
	_next()
	return false
