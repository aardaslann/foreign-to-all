extends SceneTree

# Is every button in the game actually bound?
#
#   <godot> --headless --path . --script res://tools/controls.gd
#
# The input map is built at runtime by autoload/Controls.gd rather than living
# in project.godot, which keeps it readable and diffable and means nothing can
# corrupt the file the game will not start without - and also means no static
# checker can see it. This is the thing that looks.
#
# The check that matters most is the last one. `is_action_pressed("intract")`
# is valid GDScript, compiles cleanly, and silently never fires: the door just
# does not open and nothing anywhere says why. So every action name written
# anywhere in the source is checked against the map that actually exists.

# NOT preloaded. Controls.gd names the SaveManager autoload, and a preloaded
# copy is compiled in a context where that global does not exist yet - which
# fails the whole tool before it runs. The live node has the same constants
# on its script, and asking it is also a truer test: it proves the autoload
# the GAME loaded is the one being checked.
var CTRL: Dictionary = {}

var _fails: int = 0
var _checked: int = 0


# Deliberately NOT _initialize(). A SceneTree script's _initialize runs before
# the autoloads' _ready() does, so Controls exists as a node but has not built
# anything yet - and every action would read as missing. Checking on the first
# frame instead also means this tests the path the game itself takes rather
# than one the tool arranged.
func _process(_delta: float) -> bool:
	if root.get_node_or_null("Controls") == null:
		print("Controls autoload missing; run with --path .")
		quit(1)
		return true

	print("")
	var scr: GDScript = root.get_node("Controls").get_script()
	CTRL = scr.get_script_constant_map()

	print("Foreign to All - the buttons")
	print("")

	_registered()
	_shape()
	_no_clashes()
	_named()
	_referenced()

	print("")
	print("%d checks, %d failures" % [_checked, _fails])
	quit(1 if _fails > 0 else 0)
	return true


# 1. Everything the table declares made it into the map.
func _registered() -> void:
	print("-- every action exists")
	for action: String in Dictionary(CTRL["ACTIONS"]).keys():
		_check(InputMap.has_action(action), "%s: is in the map" % action, "")
	print("")


# 2. Each one can actually be pressed, on both kinds of hardware. A gamepad
#    could walk around this game on the built-in ui_* defaults and could not
#    open a single door, because interact was a keyboard scancode comparison.
func _shape() -> void:
	print("-- keyboard and pad, for all of them")
	for action: String in Dictionary(CTRL["ACTIONS"]).keys():
		if not InputMap.has_action(action):
			continue
		var keys: int = 0
		var pad: int = 0
		for ev: InputEvent in InputMap.action_get_events(action):
			if ev is InputEventKey:
				keys += 1
			elif ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
				pad += 1
		_check(keys > 0, "%s: has a key" % action, "%d" % keys)
		_check(pad > 0, "%s: has something on a controller" % action,
			"%d" % pad)
	print("")


# 3. No key does two jobs. Two actions on one button is a fault the player
#    cannot see and cannot diagnose.
func _no_clashes() -> void:
	print("-- no key is bound twice")
	var seen: Dictionary = {}
	var clash: String = ""
	for action: String in Dictionary(CTRL["ACTIONS"]).keys():
		if not InputMap.has_action(action):
			continue
		for ev: InputEvent in InputMap.action_get_events(action):
			if not (ev is InputEventKey):
				continue
			var code: int = (ev as InputEventKey).physical_keycode
			if seen.has(code):
				clash = "%s and %s share %s" % [seen[code], action,
					OS.get_keycode_string(code)]
			seen[code] = action
	_check(clash.is_empty(), "every key belongs to one action", clash)
	print("")


# 4. The settings screen can describe all of them.
func _named() -> void:
	print("-- the settings screen can list them")
	var ctrl: Node = root.get_node("Controls")
	for action: String in Dictionary(CTRL["ACTIONS"]).keys():
		_check(Dictionary(CTRL["NAMES"]).has(action),
			"%s: has a name a player would use" % action,
			String(Dictionary(CTRL["NAMES"]).get(action, "")))
		_check(Array(CTRL["ORDER"]).has(action), "%s: is in the listed order" % action,
			"")
		var label: String = String(ctrl.call("label_for", action))
		_check(not label.is_empty() and label != "unbound",
			"%s: shows what it is bound to" % action, label)
	_check(Array(CTRL["ORDER"]).size() == Dictionary(CTRL["ACTIONS"]).size(),
		"the order lists every action and no ghosts",
		"%d of %d" % [Array(CTRL["ORDER"]).size(), Dictionary(CTRL["ACTIONS"]).size()])
	print("")


# 5. Every action NAME written anywhere in the game exists.
#
# This is the one worth having. A typo compiles, runs, and quietly does nothing
# forever - and the symptom is "that door does not work", which is a long way
# from the cause.
func _referenced() -> void:
	print("-- every action the code asks for is real")
	var files: Array = []
	_gather("res://scenes", files)
	_gather("res://autoload", files)
	var wanted: Dictionary = {}
	var re := RegEx.new()
	re.compile("is_action(?:_pressed|_released|_just_pressed)?\\(\"([a-z_]+)\"")
	var vec := RegEx.new()
	vec.compile("get_vector\\(\"([a-z_]+)\", \"([a-z_]+)\", \"([a-z_]+)\", \"([a-z_]+)\"")
	for path: String in files:
		var src: String = FileAccess.get_file_as_string(path)
		for m in re.search_all(src):
			wanted[m.get_string(1)] = path
		for mv in vec.search_all(src):
			for g in range(1, 5):
				wanted[mv.get_string(g)] = path
	for action: String in wanted.keys():
		_check(InputMap.has_action(action),
			"%s: asked for, and exists" % action,
			String(wanted[action]).replace("res://", ""))
	_check(wanted.size() >= 8, "the code actually uses the map",
		"%d distinct actions referenced" % wanted.size())
	print("")


func _gather(dir: String, out: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		if not sub.begins_with("."):
			_gather(dir.path_join(sub), out)


func _check(ok: bool, what: String, detail: String) -> void:
	_checked += 1
	if not ok:
		_fails += 1
	var mark: String = "  ok  " if ok else " FAIL "
	print("%s%-52s %s" % [mark, what, detail])
