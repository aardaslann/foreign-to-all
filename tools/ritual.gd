extends SceneTree

# When he speaks, and how many times he says no first.
#
#   <godot> --headless --path . --script res://tools/ritual.gd
#
# Two mechanics that can be got wrong while understanding every word, and both
# derived from tables rather than authored per exchange - so the only way to
# know they behave is to walk every city through every case.

const RIT := preload("res://autoload/Ritual.gd")

var _fails: int = 0
var _checked: int = 0


func _initialize() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		print("no autoloads; run with --path .")
		quit(1)
		return

	print("")
	print("Foreign to All - timing, and the dance")
	print("")

	var cities: Dictionary = gs.get("CITIES")
	_patience(cities)
	_hospitality(cities)
	_scoring(cities)
	_tagged()

	print("")
	print("%d checks, %d failures" % [_checked, _fails])
	quit(1 if _fails > 0 else 0)


# 1. Every city says how long it will wait, and what the waiting means.
func _patience(cities: Dictionary) -> void:
	print("-- how long a silence is allowed to be")
	for c: String in cities.keys():
		_check(RIT.PATIENCE.has(c), "%s: has a patience" % c, "")
		if not RIT.PATIENCE.has(c):
			continue
		var secs: float = RIT.patience(c)
		# Long enough to read three options and think; short enough that the
		# pause is a real decision rather than a thing that never happens.
		_check(secs >= 5.0 and secs <= 20.0,
			"%s: the window is a usable length" % c, "%.0fs" % secs)
		_check(not RIT.silence_reads(c).is_empty(),
			"%s: says what the silence is taken for" % c, RIT.silence_reads(c))
		_check(not RIT.silence_note(c).is_empty(),
			"%s: and he makes something of it" % c, "")
		# Never catastrophic. Saying nothing is a different answer rather than
		# a failure state, and the mechanic dies the moment it becomes one.
		_check(RIT.silence_rep(c) >= -2 and RIT.silence_rep(c) <= 1,
			"%s: silence costs little, and is sometimes worth having" % c,
			"%d" % RIT.silence_rep(c))
	print("")


# 2. Every city says how many times you say no, including the ones where the
#    answer is none - which is a real answer and has to be a stated one.
func _hospitality(cities: Dictionary) -> void:
	print("-- how many times he says no first")
	var zero: int = 0
	for c: String in cities.keys():
		_check(RIT.HOSPITALITY.has(c), "%s: has a custom" % c, "")
		if not RIT.HOSPITALITY.has(c):
			continue
		var want: int = RIT.refusals_wanted(c)
		_check(want >= 0 and want <= 2,
			"%s: expects a plausible number of refusals" % c, "%d" % want)
		if want == 0:
			zero += 1
		var row: Dictionary = RIT.HOSPITALITY[c]
		_check(not String(row.get("right", "")).is_empty(),
			"%s: says what getting it right is like" % c, "")
		_check(not String(row.get("late", "")).is_empty(),
			"%s: and what refusing once too often is like" % c, "")
		# A city that wants no refusals has no "accepted too early" case and
		# must not pretend to one.
		if want == 0:
			_check(String(row.get("early", "")).is_empty(),
				"%s: nothing to be early for where none is wanted" % c, "")
		else:
			_check(not String(row.get("early", "")).is_empty(),
				"%s: says what taking it at once is like" % c, "")
	# The table is not allowed to be all ceremony. If every city wanted a
	# refusal it would be a difficulty tax rather than a fact about places.
	_check(zero >= 4, "some cities simply want a yes", "%d of them" % zero)
	print("")


# 3. The scoring. Right is worth having, wrong is survivable, and the two ways
#    of being wrong are told apart.
func _scoring(cities: Dictionary) -> void:
	print("-- what it is worth")
	for c: String in cities.keys():
		if not RIT.HOSPITALITY.has(c):
			continue
		var want: int = RIT.refusals_wanted(c)
		var right: Array = RIT.accepted(c, want)
		_check(int(right[0]) > 0 and not String(right[1]).is_empty(),
			"%s: doing it correctly is worth something" % c,
			"+%d" % int(right[0]))
		var late: Array = RIT.accepted(c, want + 2)
		_check(int(late[0]) < 0, "%s: refusing too often costs" % c,
			"%d" % int(late[0]))
		_check(int(late[0]) >= -3, "%s: and not more than gracelessness" % c,
			"%d" % int(late[0]))
		if want > 0:
			var early: Array = RIT.accepted(c, 0)
			_check(int(early[0]) < 0 and String(early[1]) != String(right[1]),
				"%s: taking it at once is its own thing" % c, "")
	print("")


# 4. The tags in the world. A ritual response with no partner is a dance with
#    one dancer: an exchange that can be declined must be acceptable somewhere,
#    or the player is holding a no they can never turn into a yes.
func _tagged() -> void:
	print("-- the exchanges that are tagged")
	var files: Array = ["res://scenes/npc/CityNPCs.gd",
		"res://scenes/npc/CityNPCsWorld.gd",
		"res://scenes/npc/CityNPCsAmerica.gd",
		"res://scenes/npc/KeyLines.gd", "res://scenes/npc/Encounters.gd"]
	var declines: int = 0
	var accepts: int = 0
	for f: String in files:
		var src: String = FileAccess.get_file_as_string(f)
		declines += src.count("\"ritual\": \"decline\"")
		accepts += src.count("\"ritual\": \"accept\"")
	_check(accepts > 0, "something in the world can be accepted",
		"%d" % accepts)
	_check(declines > 0, "and something can be declined first",
		"%d" % declines)
	_check(accepts >= declines,
		"every no has a yes available after it",
		"%d yes, %d no" % [accepts, declines])
	print("")


func _check(ok: bool, what: String, detail: String) -> void:
	_checked += 1
	if not ok:
		_fails += 1
	var mark: String = "  ok  " if ok else " FAIL "
	print("%s%-58s %s" % [mark, what, detail])
