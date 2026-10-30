extends SceneTree

# Plays the whole spine and checks that the player is never left with nothing.
#
# The complaint this exists for was "after the hotel room there's no quest and
# the player has no idea what to do next", and the only way to be sure that is
# fixed is to walk the entire game — every gate, all eight cities — and assert
# after EVERY step that the log is asking for exactly one thing and that the
# thing has somewhere the arrow can point.
#
#   cp tools/thread.gd thread.gd
#   <godot> --path . --script res://thread.gd
#   rm thread.gd

var _fails: int = 0
var _steps: int = 0


func _initialize() -> void:
	var gs = root.get_node_or_null("GameState")
	var st = root.get_node_or_null("Story")
	if gs == null or st == null:
		print("no autoloads")
		quit(1)
		return

	# ── the intro, as the game itself runs it ──────────────────────────────
	gs.city = "berlin"
	gs.visit_region("kiez")
	# Kiez.gd opens this one on arrival, with its two targets.
	gs.start_quest("first_trade", "What do these do?",
		["Watch someone else do it first", "Buy the bread"],
		["res://scenes/world/Kiez.tscn", "res://scenes/world/Kiez.tscn"])
	gs.complete_quest_step("first_trade", 0)
	_check(gs, "the intro is running")
	gs.money = 40
	gs.world_flags["renate_met"] = true
	gs.buy_bread()
	gs.receive_map()
	_check(gs, "map in hand")
	for i in range(4):
		gs.complete_quest_step("find_bed", i)
	_check(gs, "the room is booked and slept in")

	# ── work ──────────────────────────────────────────────────────────────
	_want(gs, "earn_keep", "after the hotel room")
	gs.accept_job("sweep")
	gs.finish_job("sweep", 12, 1)
	_check(gs, "a day's work done")

	# ── the eight, in the order the list gives ────────────────────────────
	for city: String in st.MANDATORY:
		gs.city = city
		var lang: String = String(gs.CITIES.get(city, {}).get("language", ""))
		gs.visit_region(String(gs.CITY_REGIONS[city][0]))
		_check(gs, city + ": just arrived")
		_want(gs, "learn_" + city, city + ": cannot be heard yet")
		# Learn the language up to the gate.
		var need: int = int(gs.FLUENCY_STEPS[st.MEET_AT - 1])
		for i in range(need + 2):
			var w: String = "w%d" % i
			for _r in range(9):
				gs.expose(lang, w, "used")
		_check(gs, city + ": fluent enough")
		_want(gs, "meet_" + city, city + ": they are audible now")
		st.mark_met(city)
		_check(gs, city + ": met them")
		# Two rounds, then the errand, then the third. A player cannot reach
		# the friendship without going and doing the thing they were asked
		# for, so neither can this.
		st.add_round(city)
		st.add_round(city)
		_check(gs, city + ": asked for something")
		_want(gs, "errand_" + city, city + ": the errand is the thread")
		var er: Dictionary = st.errand_of(city)
		gs.world_flags["spot_" + String(er.get("region", ""))] = true
		st.guide()
		_check(gs, city + ": errand run")
		st.add_round(city)
		_check(gs, city + ": friends")
		_want(gs, "holiday_" + city, city + ": invited")
		st.mark_holiday(city)
		_check(gs, city + ": holiday walked")

	# ── the twelve, which nothing walked ──────────────────────────────────
	#
	# Every optional city with a person has the same arc as the eight - meet,
	# two rounds, an errand, a third round, a holiday - and until now nothing
	# in this suite touched a single step of it. That is how Zurich came to
	# ship with a designed character, a trade, an errand and a holiday behind
	# a door that could not open: can_meet() tested MANDATORY, so Beat was
	# permanently invisible, and every checker was green.
	#
	# So the twelve get walked too. The rule this enforces from here on: if a
	# city is in PEOPLE it has words, a place to stand, its own terminal, and
	# a complete arc - and it still cannot touch the ending.
	var LINES := load("res://scenes/npc/KeyLines.gd")
	var could_end: bool = st.can_end()
	for city2: String in st.PEOPLE.keys():
		if st.is_mandatory(city2):
			continue
		print("")
		print("-- ", city2, ", which is optional")

		# Written before walked. A person with no lines is the fault this
		# whole block exists to make loud.
		_ok(LINES.STANDING.has(city2), city2 + ": has three rungs of standing")
		_ok(Array(LINES.STANDING.get(city2, [])).size() == st.ROUNDS,
			city2 + ": one rung per round")
		_ok(Array(LINES.rounds_for(city2)).size() == st.ROUNDS,
			city2 + ": has all %d conversations" % st.ROUNDS)
		_ok(not Array(LINES.holiday_reel(city2)).is_empty(),
			city2 + ": the day itself is written")
		_ok(not st.errand_of(city2).is_empty(), city2 + ": is asked for something")

		# Somewhere to stand and somewhere to fly from. The arrow cannot
		# point at a scene that is not on disk, and _fly() reads AIRPORT by
		# the city you are IN - so a missing entry sent the player to Berlin
		# Brandenburg from wherever in the world they happened to be.
		var scene2: String = st.path(String(st.SCENE.get(city2, "")))
		_ok(st.SCENE.has(city2) and ResourceLoader.exists(scene2),
			city2 + ": their district is a real scene")
		_ok(st.AIRPORT.has(city2)
			and ResourceLoader.exists(st.path(String(st.AIRPORT[city2]))),
			city2 + ": has its own terminal to leave from")

		# And now the arc, exactly as the eight are walked.
		gs.city = city2
		var lang2: String = String(gs.CITIES.get(city2, {}).get("language", ""))
		gs.visit_region(String(gs.CITY_REGIONS[city2][0]))
		_ok(not st.can_meet(city2), city2 + ": not audible yet")
		var need2: int = int(gs.FLUENCY_STEPS[st.MEET_AT - 1])
		for i2 in range(need2 + 2):
			for _r2 in range(9):
				gs.expose(lang2, "z%d" % i2, "used")
		_ok(st.can_meet(city2), city2 + ": audible once the language lands")
		st.guide()
		_want(gs, "meet_" + city2, city2 + ": the log knows they are there")
		st.mark_met(city2)
		_check(gs, city2 + ": met them")
		st.add_round(city2)
		st.add_round(city2)
		_want(gs, "errand_" + city2, city2 + ": asked for something")
		gs.world_flags["spot_" + String(
			st.errand_of(city2).get("region", ""))] = true
		st.guide()
		st.add_round(city2)
		_ok(st.is_friend(city2), city2 + ": friends")
		_want(gs, "holiday_" + city2, city2 + ": invited")
		st.mark_holiday(city2)
		_check(gs, city2 + ": holiday walked")

		# The whole reason MANDATORY is a constant of its own.
		_ok(st.can_end() == could_end,
			city2 + ": changed nothing about the ending")
	gs.city = "berlin"
	st.guide()

	# ── the people who come to you ────────────────────────────────────────
	#
	# An encounter is the one kind of conversation the player cannot decline,
	# so every way it can be wrong is a way the player can be stuck: a person
	# with no design, an option gated on an item that does not exist, a flag
	# that never gets set. None of that is visible from a render, because the
	# fault is that the thing never happens.
	var ENC := load("res://scenes/npc/Encounters.gd")
	var ROSTER := load("res://scenes/npc/CastRoster.gd")
	var items: Node = root.get_node_or_null("Items")
	for eid: String in ENC.ALL.keys():
		var e: Dictionary = ENC.ALL[eid]
		_ok(gs.CITIES.has(String(e.get("city", ""))),
			eid + ": is in a real city")
		_ok(ROSTER.PEOPLE.has(String(e.get("look", ""))),
			eid + ": has a design")
		_ok(not String(e.get("flag", "")).is_empty(),
			eid + ": can be finished")
		var lines: Array = e.get("lines", [])
		_ok(not lines.is_empty(), eid + ": has something to say")
		var settles: bool = false
		for entry: Dictionary in lines:
			for r: Dictionary in entry.get("responses", []):
				var item: String = String(r.get("requires_item", ""))
				if not item.is_empty():
					var known: bool = items != null and (
						Dictionary(items.get("ITEMS")).has(item)
						or Dictionary(items.get("SPOT_ITEMS")).has(item))
					_ok(known, eid + ": '" + item + "' is a real thing")
				if String(r.get("action", "")).begins_with("flag:"):
					settles = true
		_ok(settles, eid + ": at least one answer settles it")
		# And it happens once. pending() is what stops the same man walking
		# into the same room every time the player opens the door.
		gs.world_flags[String(e.get("flag", ""))] = false
		_ok(ENC.pending(eid), eid + ": waiting before it happens")
		gs.world_flags[String(e.get("flag", ""))] = true
		_ok(not ENC.pending(eid), eid + ": over afterwards")

	# ── the ending ────────────────────────────────────────────────────────
	_want(gs, "the_name", "all eight done")
	gs.visit_region("wreck")
	_check(gs, "back in the field")
	st.set_namer("istanbul")
	print("named: ", st.given_name())

	print("")
	_districts()
	print("%d checks, %d failures" % [_steps, _fails])
	quit(1 if _fails > 0 else 0)


# A plain assertion, for the things that are true or not rather than being a
# state of the log.
# Every district the player can stand in is called something.
#
# The ids are keys and stay keys - they are load-bearing in `reputation`,
# CITY_REGIONS and reset(), and renaming one orphans a save. But three places
# showed them to the player through capitalize(), which produced "Carsi",
# "Phoco", "Elalto", "Champdemars" and "Kitaygorod". A missing name here is
# invisible until somebody reads a toast, so it is checked instead.
func _districts() -> void:
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		return
	print("")
	print("-- every district has a name")
	var regions: Dictionary = gs.get("CITY_REGIONS")
	var names: Dictionary = gs.get("DISTRICT_NAMES")
	var missing: int = 0
	for c: String in regions.keys():
		for r in Array(regions[c]):
			var id: String = String(r)
			if not names.has(id):
				missing += 1
				_fail("%s/%s has no display name" % [c, id])
			elif String(names[id]).is_empty():
				missing += 1
				_fail("%s/%s has an empty display name" % [c, id])
	_ok(missing == 0, "all %d districts are named" % names.size())
	# And nothing named that is not a district, which would be a typo nobody
	# would ever see.
	var flat: Dictionary = {}
	for c2: String in regions.keys():
		for r2 in Array(regions[c2]):
			flat[String(r2)] = true
	var ghosts: int = 0
	for id2: String in names.keys():
		if not flat.has(id2):
			ghosts += 1
			_fail("'%s' is named but is not a district" % id2)
	_ok(ghosts == 0, "no names for places that do not exist")


func _ok(cond: bool, what: String) -> void:
	_steps += 1
	if cond:
		print("  ok  ", what)
	else:
		_fails += 1
		print(" FAIL ", what)


# After every change the log must be asking for exactly one thing, and that
# thing must be somewhere you can walk to.
func _check(gs, where: String, need_target: bool = true) -> void:
	_steps += 1
	var open_ids: Array = []
	for id: String in gs.quests.keys():
		if not bool(Dictionary(gs.quests[id]).get("completed", false)):
			open_ids.append(id)
	if open_ids.is_empty():
		_fail("NOTHING TO DO — " + where)
		return
	if need_target and String(gs.quest_target()).is_empty():
		_fail("no target for the arrow — " + where + "  open: " + str(open_ids))
		return
	print("  ok  %-32s -> %s" % [where, str(open_ids)])


func _want(gs, id: String, where: String) -> void:
	_steps += 1
	if not gs.quests.has(id):
		_fail("expected quest '" + id + "' — " + where)
		return
	print("  ok  %-32s -> %s open" % [where, id])


func _fail(msg: String) -> void:
	_fails += 1
	print("  FAIL  ", msg)
