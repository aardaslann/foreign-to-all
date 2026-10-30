extends SceneTree

# Boots real district scenes, runs the "local" service in each, and steps the
# cutscene through every shot the way a player clicking would - so a reel that
# cannot actually play shows up here rather than in front of the player.
#
#   <godot> --path . --script res://reeltest.gd -- <scene.tscn>...

var _jobs: Array = []
var _vp: SubViewport = null
var _inst: Node = null
var _cut: Node = null
var _phase: int = 0
var _wait: int = 0
var _clicks: int = 0
var _fails: int = 0
var _ran: int = 0


func _process(_delta: float) -> bool:
	match _phase:
		0:
			_jobs = Array(OS.get_cmdline_user_args())
			_vp = SubViewport.new()
			_vp.size = Vector2i(1152, 648)
			_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(_vp)
			_phase = 1
		1:
			_next()
		2:
			_wait -= 1
			if _wait > 0:
				return false
			_start()
		3:
			_step()
	return false


func _next() -> void:
	if _inst != null:
		_inst.queue_free()
		_inst = null
	if _jobs.is_empty():
		print("REELPLAY: ", _ran, " scenes, ",
			"CLEAN" if _fails == 0 else str(_fails) + " PROBLEMS")
		quit(0)
		return
	var path: String = String(_jobs.pop_front())
	var packed: PackedScene = load(path)
	if packed == null:
		print("FAILED TO LOAD ", path)
		_fails += 1
		return
	_inst = packed.instantiate()
	_vp.add_child(_inst)
	set_meta("path", path)
	_wait = 10
	_phase = 2


func _start() -> void:
	_cut = get_first_node_in_group("cutscene")
	if _cut == null:
		print("NO CUTSCENE LAYER ", get_meta("path"))
		_fails += 1
		_phase = 1
		return
	var sv = root.get_node_or_null("Services")
	if sv == null:
		print("NO SERVICES")
		_fails += 1
		quit(1)
		return
	sv.call("run", "local", _inst)
	_clicks = 0
	_phase = 3


func _step() -> void:
	if _cut == null or not bool(_cut.get("_open")):
		# Either it never opened (a district with no spot, which is legal) or
		# it has run to the end.
		paused = false
		_ran += 1
		if _clicks > 40:
			print("REEL WOULD NOT END ", get_meta("path"))
			_fails += 1
		_phase = 1
		return
	# Stand in for the player: hold past the read time, then advance.
	_cut.call("_process", 4.0)
	_cut.call("_advance")
	_clicks += 1
	if _clicks > 40:
		print("REEL RUNAWAY ", get_meta("path"))
		_fails += 1
		_cut.call("_close")
