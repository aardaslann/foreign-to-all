extends SceneTree

# Does the register ladder hold?
#
#   <godot> --headless --path . --script res://tools/register.gd
#
# Register is the half of this game's thesis that used to be a lookup table:
# you can know every word in a sentence and still choose the wrong "you", and
# the failure has nothing to do with vocabulary. Because the expectation is
# DERIVED rather than authored - out of somebody's age and how well a city
# thinks of you - there is no data file to proof-read, and the only way to know
# it behaves is to walk every combination it can be in.
#
# So this walks all of them: every language a city speaks, every build a person
# can have, and standing from hated to one-of-us.

const REG := preload("res://autoload/Register.gd")

const BUILDS := ["child", "youth", "adult", "elder"]
const STANDINGS := [-100, -30, 0, 20, 34, 35, 50, 69, 70, 100]

var _fails: int = 0
var _checked: int = 0


func _initialize() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		print("no autoloads; run with --path .")
		quit(1)
		return

	print("")
	print("Foreign to All - how he addresses people")
	print("")

	var cities: Dictionary = gs.get("CITIES")
	var langs: Dictionary = {}
	for c: String in cities.keys():
		var row: Dictionary = cities[c]
		var lang: String = String(row.get("language", ""))
		if not lang.is_empty():
			langs[lang] = true

	_table(langs)
	_derivation(langs)
	_warming(langs)
	_age_axis()
	_prose(langs)

	print("")
	print("%d checks, %d failures" % [_checked, _fails])
	quit(1 if _fails > 0 else 0)


# 1. Every language a city speaks is described, and described consistently.
func _table(langs: Dictionary) -> void:
	print("-- the table")
	for lang: String in langs.keys():
		_check(REG.LADDERS.has(lang),
			"%s: the table knows this language" % lang, "")
		if not REG.LADDERS.has(lang):
			continue
		var ids: Array = REG.rung_ids(lang)
		# An empty ladder is a legitimate answer - English has no grammatical
		# second person to get wrong - but it has to be a stated one.
		if ids.is_empty():
			_check(not REG.note(lang).is_empty(),
				"%s: no ladder, and says why" % lang,
				REG.note(lang).substr(0, 38))
			continue
		var seen: Dictionary = {}
		var dupes: bool = false
		for id: String in ids:
			if seen.has(id):
				dupes = true
			seen[id] = true
		_check(not dupes, "%s: no rung is named twice" % lang,
			", ".join(PackedStringArray(ids)))
		_check(ids.has(REG.default_rung(lang)),
			"%s: the default is one of its own rungs" % lang,
			REG.default_rung(lang))
		_check(REG.axis(lang) == "distance" or REG.axis(lang) == "age",
			"%s: says what its rungs are about" % lang, REG.axis(lang))
		for id2: String in ids:
			_check(not REG.gloss(lang, id2).is_empty(),
				"%s/%s: says what it is for" % [lang, id2],
				REG.gloss(lang, id2).substr(0, 32))
	print("")


# 2. Whatever the world is doing, the expectation is a rung that exists.
func _derivation(langs: Dictionary) -> void:
	print("-- every combination lands on a real rung")
	for lang: String in langs.keys():
		if not REG.has_ladder(lang):
			continue
		var ids: Array = REG.rung_ids(lang)
		var bad: String = ""
		for b: String in BUILDS:
			for s: int in STANDINGS:
				var got: String = REG.expected(lang, {"build": b}, s)
				if not ids.has(got):
					bad = "%s @ %d -> '%s'" % [b, s, got]
		_check(bad.is_empty(),
			"%s: %d combinations, all valid"
				% [lang, BUILDS.size() * STANDINGS.size()], bad)
	print("")


# 3. A culture that warms actually warms, and one that does not, does not.
#    This is the whole of the Paris line - "politer and it is now wrong" - and
#    the whole of what makes Zurich different from Berlin.
func _warming(langs: Dictionary) -> void:
	print("-- standing moves the expectation, where the culture allows it")
	for lang: String in langs.keys():
		if not REG.has_ladder(lang) or REG.axis(lang) != "distance":
			continue
		var cold: String = REG.expected(lang, {"build": "adult"}, 0)
		var warm: String = REG.expected(lang, {"build": "adult"}, 100)
		var moved: bool = cold != warm
		if REG.warms(lang):
			_check(moved, "%s: being known changes what they call you" % lang,
				"%s -> %s" % [cold, warm])
			# And it moves toward the familiar, never away from it.
			_check(REG.index_of(lang, warm) <= REG.index_of(lang, cold),
				"%s: it warms rather than cooling" % lang,
				"%s -> %s" % [cold, warm])
		else:
			_check(not moved,
				"%s: the distance is the respect, and it stays" % lang,
				"%s at every standing" % cold)
		# A child is never addressed formally, in any of them.
		var ids: Array = REG.rung_ids(lang)
		_check(REG.expected(lang, {"build": "child"}, 0) == String(ids[0]),
			"%s: nobody is formal at a child" % lang, "")
	print("")


# 4. The one that is not about distance at all. Vietnamese decides by relative
#    age, so no amount of being liked may move it - you do not get promoted out
#    of being younger than somebody.
func _age_axis() -> void:
	print("-- the age ladder ignores standing entirely")
	for lang: String in REG.LADDERS.keys():
		if REG.axis(lang) != "age":
			continue
		for b: String in BUILDS:
			var at_worst: String = REG.expected(lang, {"build": b}, -100)
			var at_best: String = REG.expected(lang, {"build": b}, 100)
			_check(at_worst == at_best,
				"%s/%s: how old they are does not depend on being liked"
					% [lang, b], at_worst)
		# And the rungs are actually reachable.
		var reached: Dictionary = {}
		for b2: String in BUILDS:
			reached[REG.expected(lang, {"build": b2}, 0)] = true
		_check(reached.size() >= 3,
			"%s: the builds spread across the ladder" % lang,
			"%d of %d rungs" % [reached.size(), REG.rung_ids(lang).size()])
	print("")


# 5. Too formal and too familiar are different mistakes and must read as such,
#    because the toast is the only feedback the player gets on this axis.
func _prose(langs: Dictionary) -> void:
	print("-- getting it wrong says which way it was wrong")
	for lang: String in langs.keys():
		if not REG.has_ladder(lang):
			continue
		var ids: Array = REG.rung_ids(lang)
		if ids.size() < 2:
			continue
		var familiar: String = String(ids[0])
		var formal: String = String(ids[ids.size() - 1])
		var too_formal: String = REG.misread(lang, formal, familiar)
		var too_close: String = REG.misread(lang, familiar, formal)
		_check(not too_formal.is_empty() and not too_close.is_empty(),
			"%s: both mistakes have something to say" % lang, "")
		_check(too_formal != too_close,
			"%s: and they are not the same thing" % lang, too_formal)
		_check(REG.misread(lang, formal, formal).is_empty(),
			"%s: getting it right says nothing" % lang, "")
		# And when the expectation MOVES he has to be told, or the mechanic is
		# an unmarked rule that punishes him for yesterday's correct answer.
		var warmed: String = REG.moved(lang, formal, familiar)
		var cooled: String = REG.moved(lang, familiar, formal)
		_check(not warmed.is_empty() and not cooled.is_empty(),
			"%s: he notices when it moves, both ways" % lang, "")
		_check(warmed != cooled,
			"%s: being let in does not read like being shut out" % lang, "")
		_check(REG.moved(lang, formal, formal).is_empty(),
			"%s: nothing to notice when nothing moved" % lang, "")
		# Somebody who likes him tells him. Both directions, in the language,
		# with his own reading of it under it.
		var told_formal: Array = REG.correction(lang, 1)
		var told_close: Array = REG.correction(lang, -1)
		_check(told_formal.size() == 2 and told_close.size() == 2,
			"%s: has a correction for both mistakes" % lang,
			"" if told_formal.size() != 2 else String(told_formal[0]))
		if told_formal.size() == 2 and told_close.size() == 2:
			_check(String(told_formal[0]) != String(told_close[0]),
				"%s: and they are not the same sentence" % lang, "")
			_check(not String(told_formal[1]).is_empty()
					and not String(told_close[1]).is_empty(),
				"%s: and he makes something of each" % lang, "")
		_check(REG.correction(lang, 0).is_empty(),
			"%s: nobody corrects him when he was right" % lang, "")
	print("")


func _check(ok: bool, what: String, detail: String) -> void:
	_checked += 1
	if not ok:
		_fails += 1
	var mark: String = "  ok  " if ok else " FAIL "
	print("%s%-56s %s" % [mark, what, detail])
