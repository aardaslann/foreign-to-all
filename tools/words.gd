extends SceneTree

# Does every word this game can teach have a guess under it?
#
#   <godot> --headless --path . --script res://tools/words.gd
#
# The journal is the only place the player is ever told what a word might
# mean, and for thirteen of the sixteen languages it told them nothing: three
# tables existed, GameState.word_guesses() returned the German one for
# everything else, and a Japanese word was looked up in a notebook of German
# and came back empty. That was invisible from the code and invisible from a
# render, because the panel looked perfectly fine - it was simply blank in the
# places that mattered.
#
# This walks the tables the running game actually loads, so it catches a word
# added to a dialogue tomorrow with no guess written for it.

# What a street says, and when.
const CHATTER := preload("res://scenes/npc/Chatter.gd")

var _fails: int = 0
var _checked: int = 0


func _initialize() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		print("no GameState; run with --path .")
		quit(1)
		return

	print("")
	print("Foreign to All - the notebook")
	print("")

	# 1. Every language a city speaks has a table at all. Read off CITIES at
	#    run time, so a city added later cannot quietly go uncovered.
	var cities: Dictionary = gs.get("CITIES")
	var langs: Array = []
	for c: String in cities.keys():
		var lang: String = String(Dictionary(cities[c]).get("language", ""))
		if not lang.is_empty() and not langs.has(lang):
			langs.append(lang)
	langs.sort()
	for lang2: String in langs:
		var table: Dictionary = gs.call("guesses_for", lang2)
		_check(not table.is_empty(), "%s has a notebook" % lang2,
			"%d words" % table.size())

	# 2. A word looked up in its own language comes back with something.
	for lang3: String in langs:
		var table2: Dictionary = gs.call("guesses_for", lang3)
		if table2.is_empty():
			continue
		var sample: String = String(table2.keys()[0])
		var got: String = String(gs.call("word_guess", lang3, sample))
		_check(not got.is_empty(), "%s: '%s' has a guess" % [lang3, sample], got)

	# 3. Case does not matter. expose() lower-cases; a dialogue may not.
	var up: String = String(gs.call("word_guess", "german", "BROT"))
	_check(not up.is_empty(), "lookup is case-insensitive", up)

	# 4. Learning a word in one language does not put it on another's page.
	gs.call("expose", "turkish", "ekmek", "hear")
	var fam: Dictionary = gs.get("familiarity")
	_check(Dictionary(fam.get("turkish", {})).has("ekmek"),
		"a Turkish word lands in the Turkish notebook", "")
	_check(not Dictionary(fam.get("german", {})).has("ekmek"),
		"and not in the German one", "")

	# 5. A word heard once is at least glimpsed, so it reaches the journal.
	#    The journal lists tier 1 and up; a word that landed below that would
	#    be learned and invisible, which is the fault that was reported.
	gs.call("expose", "japanese", "sumimasen", "hear")
	# A long word heard once scores below the glimpsed threshold on purpose -
	# three encounters is what glimpsing one costs. What must be true is that
	# it is WRITTEN DOWN, because the journal lists everything with a score
	# against it, not only the ones that crossed a line.
	var score: int = int(gs.call("get_familiarity", "japanese", "sumimasen"))
	_check(score > 0, "one hearing puts a word on the page",
		"score %d, tier %d" % [score,
			int(gs.call("get_tier", "japanese", "sumimasen"))])
	var jguess: String = String(gs.call("word_guess", "japanese", "sumimasen"))
	_check(not jguess.is_empty(), "and it has a guess when it gets there",
		jguess)

	# ── What a street says ───────────────────────────────────────────────
	#
	# Two friends in Berlin said "Guten Morgen" to each other at five in the
	# morning under a black sky and went on saying it at every hour the game
	# has, because the greeting was one of three fixed fragments and nothing
	# in the game knew what time it was.
	gs.set("time_of_day", "dawn")
	_check(String(gs.call("day_part")) == "night",
		"before he has slept, it is night", String(gs.call("day_part")))
	gs.set("time_of_day", "morning")
	_check(String(gs.call("day_part")) != "night",
		"after he has slept, it is not", String(gs.call("day_part")))

	var night_de: Array = CHATTER.greetings("german", "night")
	var said: String = ""
	for snip: Array in night_de:
		for pair: Array in snip:
			said += String(pair[1]) + " "
	_check(not said.contains("morgen"),
		"nobody says good morning at night", said.strip_edges())

	# And every city has more than the three fragments it used to have.
	for lang4: String in langs:
		var pool: Array = CHATTER.lines(lang4, "afternoon")
		_check(pool.size() >= 8, "%s has enough to say" % lang4,
			"%d lines" % pool.size())
		# Each with a greeting for every hour, so no hour falls back.
		for part: String in ["night", "morning", "afternoon", "evening"]:
			_check(not CHATTER.greetings(lang4, part).is_empty(),
				"%s greets at %s" % [lang4, part], "")

	# ── every word anybody actually says ─────────────────────────────────
	#
	# The docstring at the top of this file has claimed since the day it was
	# written that it "catches a word added to a dialogue tomorrow with no
	# guess written for it". It did not. It sampled one key per table and
	# checked that the lookup worked, which tests the plumbing and nothing
	# about the content - so a word written into a conversation with no
	# entry under it sailed straight through and showed up as a blank line
	# in the journal, which is the exact fault this file was created for.
	#
	# It cost two rounds of writing on 2026-09-10 alone: thirty English
	# words across Docklands, and three Turkish ones filed under the wrong
	# key entirely - "Dort" sitting on top of the guess for iki, which would
	# have taught the player that four is two.
	#
	# So: walk every line of dialogue the game can put on screen, and look
	# each word up for real.
	var sources: Array = [
		load("res://scenes/npc/CityNPCs.gd"),
		load("res://scenes/npc/CityNPCsWorld.gd"),
		load("res://scenes/npc/CityNPCsAmerica.gd"),
		load("res://scenes/npc/KeyLines.gd"),
		load("res://scenes/npc/Encounters.gd"),
	]
	var seen: Dictionary = {}
	for src: Object in sources:
		_walk(src, seen)
	var blanks: Array = []
	for key: String in seen.keys():
		var bits: PackedStringArray = key.split("/")
		if String(gs.call("word_guess", bits[0], bits[1])).is_empty():
			blanks.append(key)
	blanks.sort()
	_check(blanks.is_empty(),
		"every word said out loud has a guess under it",
		"%d words, %d blank" % [seen.size(), blanks.size()])
	for b: String in blanks:
		print("        no guess: %s" % b)

	print("")
	print("%d checks, %d failures" % [_checked, _fails])
	quit(1 if _fails > 0 else 0)


# Every {"word": ..., "language": ...} anywhere inside a roster's constants,
# however deeply the rounds happen to be nested.
func _walk(src: Object, out: Dictionary) -> void:
	if src == null or not src is GDScript:
		return
	var consts: Dictionary = (src as GDScript).get_script_constant_map()
	for k: String in consts.keys():
		_dig(consts[k], out)


func _dig(v: Variant, out: Dictionary) -> void:
	if v is Array:
		for item: Variant in v:
			_dig(item, out)
	elif v is Dictionary:
		var d: Dictionary = v
		var w: String = String(d.get("word", ""))
		var lang: String = String(d.get("language", ""))
		if not w.is_empty() and not lang.is_empty():
			out[lang + "/" + w.to_lower()] = true
		for k2: Variant in d.keys():
			_dig(d[k2], out)


func _check(ok: bool, what: String, detail: String) -> void:
	_checked += 1
	if not ok:
		_fails += 1
	var mark: String = "  ok  " if ok else " FAIL "
	print("%s%-46s %s" % [mark, what, detail])
