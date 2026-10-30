extends SceneTree

# Run it:
#   cp tools/verify_scenes.gd verify_scenes.gd
#   <godot> --path . --script res://verify_scenes.gd
#   rm verify_scenes.gd
#
# Godot only runs --script from inside the project, hence the copy. This is the
# only check in the suite that uses the actual engine, and it is the one that
# found the crash: `const CA := CityArt` passes every static check and the
# editor class scan, then refuses to load at runtime.

# Load and run every world scene for a few frames, in ONE engine launch, and
# report anything the engine complains about. Relaunching Godot per scene took
# longer than the whole rest of the check suite.

# ── And every script, before any of that ─────────────────────────────────────
#
# This tool used to print "201 scenes instantiated and stepped" while
# DialogueBox.gd - the file every conversation in the game runs through - had a
# parse error in it and would not load at all. Two separate faults let that
# happen, and both are fixed here:
#
#   * a scene whose script fails to compile still instantiates. The node is
#     there, it simply has no behaviour, so the sweep counted it as fine
#   * nothing ever set an exit code. The tool printed its complaints into the
#     log and exited 0, so a run that had found a broken game still reported
#     success to anybody reading the last line - or anything reading $?
#
# static_check.py says in its own header that it cannot see parse errors and
# that only the engine can. This is the engine. It should be the thing that
# looks, and it should fail out loud when it finds something.

var _queue: Array = []
var _current: Node = null
var _frames: int = 0
var _done: int = 0
var _fails: int = 0


func _initialize() -> void:
	_compile_every_script()
	var d := DirAccess.open("res://scenes/world")
	for f in d.get_files():
		if f.ends_with(".tscn"):
			_queue.append("res://scenes/world/" + f)
	_queue.sort()
	print("VERIFY: %d scenes" % _queue.size())


# Every .gd in the project, compiled. A GDScript that will not parse comes back
# from load() as null, which is the whole test - and it is a test nothing in the
# suite was doing, because the eight python checkers read source and the engine
# was only ever asked about scenes.
func _compile_every_script() -> void:
	var scripts: Array = []
	_gather("res://", scripts)
	scripts.sort()
	var broken: Array = []
	for path: String in scripts:
		# load() hands back a GDScript object even when the source will not
		# parse - it is simply an empty one - so a non-null result proves
		# nothing. reload() is the call that actually compiles and reports,
		# but reloading the LIVE resource fails for anything with instances
		# alive: the eleven autoloads, and this file, which is running.
		#
		# So compile a fresh copy of the source instead. Nothing is attached to
		# it, so nothing refuses, and every preload in this project is an
		# absolute res:// path and resolves exactly as it would in the game.
		# A file that will not parse still comes back from load() as a GDScript,
		# so a non-null result proves nothing. can_instantiate() is the honest
		# question - the engine will not make one of something it could not
		# compile - and asking it constructs nothing.
		#
		# Three other ways were tried and every one is worse:
		#
		#   GDScript.new() + source_code + reload() detects everything this
		#   does, leaves 168 ad-hoc script objects registered with the engine,
		#   and segfaults the process on shutdown. A verifier that reports
		#   correctly and then exits 139 is not a verifier: the exit code is
		#   the whole point of it.
		#
		#   ResourceLoader.load() with CACHE_MODE_IGNORE takes a different
		#   argument shape in this build and errors on the call itself.
		#
		#   Checking source_code for emptiness does not work at all: a broken
		#   script comes back with its source intact and only its compiled
		#   form missing.
		var res: Resource = load(path)
		if res == null or not (res is GDScript):
			broken.append(path)
			continue
		var gd := res as GDScript
		if not gd.can_instantiate():
			broken.append(path)
	print("VERIFY: %d scripts compiled, %d broken"
		% [scripts.size(), broken.size()])
	for b: String in broken:
		print("  WILL NOT COMPILE: " + b)
	_fails += broken.size()


func _gather(dir: String, out: Array) -> void:
	# .godot is the import cache and holds nothing authored here.
	if dir.contains("/.godot"):
		return
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		if sub.begins_with("."):
			continue
		_gather(dir.path_join(sub), out)


func _process(_delta: float) -> bool:
	if _current != null:
		_frames += 1
		if _frames < 3:
			return false
		_current.free()
		_current = null
	if _queue.is_empty():
		print("VERIFY: %d scenes instantiated and stepped, %d failures"
			% [_done, _fails])
		if _fails > 0:
			quit(1)
		return true
	var path: String = _queue.pop_front()
	var ps: PackedScene = load(path)
	if ps == null:
		print("LOAD FAILED: " + path)
		_fails += 1
		return false
	_current = ps.instantiate()
	if _current == null:
		print("INSTANTIATE FAILED: " + path)
		_fails += 1
		return false
	root.add_child(_current)
	_frames = 0
	_done += 1
	return false
