class_name Streetside
extends Object

# What a district is FOR.
#
# The audit that produced this file found thirty-three districts holding one
# door — the way back to the station — and nothing else. You could walk into
# Asakusa, Paulista, Yoff or Izmaylovo and there was nothing there but the
# exit. The art was finished; the place was empty.
#
# A district earns its place by having the thing that district actually has in
# the real world. Not a generic shop: the specific institution people in that
# neighbourhood use. Ameyoko is the one market in Tokyo where strangers shout
# prices at you. The nasoni in Trastevere squirt upward when you cover the
# spout. Yoff is where the pirogues land and you buy the fish off the boat.
# Vernisage in Izmaylovo sells Soviet lapel badges by the tray.
#
# Each entry is a ChoicePanel: a title, a line of framing, and two or three
# things you can actually do, each with a consequence. The consequences stay
# small — a coin, a point of standing — because the game's currency is
# understanding, and a district should teach you how a place works rather than
# hand you a prize for turning up.
#
# Data lives in ten files, split by region, to keep any one of them from
# running past the size this project allows. This one only knows how to
# find the right entry.

const EAST := preload("res://scenes/world/StreetsideEast.gd")
const PACIFIC := preload("res://scenes/world/StreetsidePacific.gd")
const SOUTH := preload("res://scenes/world/StreetsideSouth.gd")
const NORTH := preload("res://scenes/world/StreetsideNorth.gd")
const AMERICA := preload("res://scenes/world/StreetsideAmerica.gd")
const WEST := preload("res://scenes/world/StreetsideWest.gd")
const NORTHWEST := preload("res://scenes/world/StreetsideNorthWest.gd")
const EASTTWO := preload("res://scenes/world/StreetsideEastTwo.gd")
const SOUTHTWO := preload("res://scenes/world/StreetsideSouthTwo.gd")
const EUROPETWO := preload("res://scenes/world/StreetsideEuropeTwo.gd")
const DIRECTION := preload("res://scenes/world/ActivityDirection.gd")


# The spot for a district, or {} where a district has no streetside institution
# — which is a real answer, not a gap: some districts are doors and people.
static func spot(city: String, region: String) -> Dictionary:
	var key: String = city + ":" + region
	for table in [EAST.SPOTS, PACIFIC.SPOTS, SOUTH.SPOTS, NORTH.SPOTS,
		AMERICA.SPOTS, WEST.SPOTS, NORTHWEST.SPOTS, EASTTWO.SPOTS,
		SOUTHTWO.SPOTS, EUROPETWO.SPOTS]:
		if table.has(key):
			return DIRECTION.stage(key, table[key])
	# The city was wrong, not the district. Every one of the ninety-nine
	# districts has an activity, so a miss here means the two got out of step
	# - and the player should get the activity that district actually has
	# rather than being told the street wants nothing from them.
	var tail: String = ":" + region
	for table2 in [EAST.SPOTS, PACIFIC.SPOTS, SOUTH.SPOTS, NORTH.SPOTS,
		AMERICA.SPOTS, WEST.SPOTS, NORTHWEST.SPOTS, EASTTWO.SPOTS,
		SOUTHTWO.SPOTS, EUROPETWO.SPOTS]:
		for k in table2.keys():
			if String(k).ends_with(tail):
				return DIRECTION.stage(String(k), table2[k])
	return {}


# ── Building the reel ─────────────────────────────────────────────────────────
#
# Walking a beat graph into a list of shots used to be written twice: once in
# Services._local() for the game and once in tools/playreel.gd for the preview.
# They had already drifted — the tool ignored cost and always took the first
# toss — so the sheet you looked at was not the reel the player got, which
# makes looking at it worthless. It is written here, once.
#
#   purse  what he can spend; -1 to ignore price entirely (the tool)
#   pick   how a `toss` resolves: <0 random (the game), otherwise that index
#
# Returns {"shots": Array, "owed": Array, "spent": int} — owed is every beat
# walked, so the caller can apply their effects after the reel has run rather
# than while it is running.
const BEAT_LIMIT := 24


# One interactive beat, preserving the authored placement through each choice.
static func render_beat(beat: Dictionary, id: String, previous: Dictionary) -> Dictionary:
	var context: Dictionary = previous.duplicate(true)
	context.merge(beat.get("staging", {}), true)
	var shots: Array = []
	for source: Dictionary in beat.get("film", []):
		var shot: Dictionary = source.duplicate(true)
		shots.append(shot)
		context = shot.duplicate(true)
		context.erase("say")
		context.erase("secs")
		context.erase("act")
	if shots.is_empty() and not String(beat.get("text", "")).is_empty():
		var held: Dictionary = context.duplicate(true)
		held["say"] = beat["text"]
		held["set"] = context.get("set", "street")
		held["cast"] = held_cast(context.get("cast", []), id)
		shots.append(held)
	return {"shots": shots, "context": context}


static func decision_text(beat: Dictionary, filmed: bool) -> String:
	if filmed:
		return String(beat.get("prompt", "What do you do?"))
	return String(beat.get("text", "What do you do?"))


static func reel(city: String, region: String, purse: int = -1,
		again: bool = false, pick: int = -1) -> Dictionary:
	var out: Dictionary = {"shots": [], "owed": [], "spent": 0}
	var data: Dictionary = spot(city, region)
	if data.is_empty():
		return out

	var beats: Dictionary = data.get("beats", {})
	var at: String = String(data.get("start", "start"))
	if again:
		var back: String = String(data.get("again", ""))
		if not back.is_empty():
			at = back

	var shots: Array = []
	var owed: Array = []
	var spent: int = 0
	var steps: int = 0
	var seen: Dictionary = {}
	var last_set: String = "street"
	var last_cast: Array = []
	var last_direction: Dictionary = {}

	while steps < BEAT_LIMIT and beats.has(at) and not seen.has(at):
		steps += 1
		seen[at] = true
		var beat: Dictionary = beats[at]
		owed.append(beat)
		var staging: Dictionary = beat.get("staging", {})
		last_direction.merge(staging, true)
		last_set = String(staging.get("set", last_set))
		last_cast = Array(staging.get("cast", last_cast))
		var filmed: bool = false
		for sh: Dictionary in beat.get("film", []):
			shots.append(sh)
			# Keep authored set/prop placement through action and result lines.
			# A new shot replaces this context, so a cup does not survive a cut
			# from the ferry deck into the fish market.
			last_direction = sh.duplicate(true) if sh.has("object") or sh.has("ground") or sh.has("bg_scene") else {}
			for field: String in ["say", "secs", "act", "cast", "set"]:
				last_direction.erase(field)
			filmed = true
			last_set = String(sh.get("set", last_set))
			if not Array(sh.get("cast", [])).is_empty():
				last_cast = Array(sh.get("cast", []))
		# The beat's own line becomes a shot ONLY where the beat was not
		# filmed, held on whatever the reel was last looking at and with
		# whoever was last in it.
		#
		# `text` is the panel's prose and a beat's `film` is that same moment
		# shown, so appending both played one sentence twice in different
		# words over one picture — "A parade square with nothing in it at all,
		# and a low grey building at the far end of the nothing" and then "A
		# parade square with nothing in it, a low grey building at the far
		# end". That is what being confused clicking through a reel was.
		var line: String = String(beat.get("text", ""))
		if not line.is_empty() and not filmed:
			var held_shot: Dictionary = last_direction.duplicate(true)
			held_shot.merge({"set": last_set, "say": line,
				"cast": held_cast(last_cast, at)}, true)
			shots.append(held_shot)
		var toss: Array = beat.get("toss", [])
		if not toss.is_empty():
			var t: int = (randi() % toss.size()) if pick < 0 else (pick % toss.size())
			at = String(toss[t])
			continue
		var nxt: String = ""
		var took: Dictionary = {}
		for r: Dictionary in beat.get("rows", []):
			var price: int = int(r.get("cost", 0))
			if purse >= 0 and spent + price > purse:
				continue
			var to: String = String(r.get("to", ""))
			if to.is_empty():
				continue
			spent += price
			nxt = to
			took = r
			break
		if nxt.is_empty():
			break
		# What he DID, between what he saw and what came of it. The rows are
		# the only thing joining one beat to the next and the reel never
		# showed them, so every cut looked like a non sequitur: a queue, and
		# then a guard lifting your wrist out of your pocket, with the
		# decision that caused it invisible. See → do → what came of it.
		var did: String = did_line(took)
		if not did.is_empty():
			var transition_staging: Dictionary = took.get("staging", {})
			last_direction.merge(transition_staging, true)
			last_set = String(transition_staging.get("set", last_set))
			last_cast = Array(transition_staging.get("cast", last_cast))
			var action_shot: Dictionary = last_direction.duplicate(true)
			action_shot.merge({"set": last_set, "say": did, "act": true,
				"cast": held_cast(last_cast, at + ">" + nxt)}, true)
			shots.append(action_shot)
		at = nxt

	out["shots"] = shots
	out["owed"] = owed
	out["spent"] = spent
	return out


# A row's label, turned into the thing he actually did.
#
# Labels are imperative — "Watch the queue before joining it" — and the reel's
# voice is second person, so nearly all of them become a sentence by putting
# "You" in front. English makes this safe: outside of `be`, the imperative and
# the second person present are the same form.
#
# The ones that are not verbs are fragments — "Out into the light", "Back to
# the street" — and those already read as a shot, so they are left whole. A
# row may also carry its own `did`, which always wins.
const NOT_A_VERB := ["out", "in", "into", "back", "up", "down", "off", "on",
	"away", "then", "and", "but", "no", "yes", "nothing", "onward", "onwards",
	"home", "straight", "left", "right", "past", "along", "through", "over",
	"under", "one", "two", "three", "another", "the", "a", "an", "it", "that",
	"this", "both", "neither", "either", "enough", "again", "anyway", "still"]


static func did_line(row: Dictionary) -> String:
	if row.is_empty():
		return ""
	var authored: String = String(row.get("did", ""))
	if not authored.is_empty():
		return authored
	var label: String = String(row.get("label", "")).strip_edges()
	if label.is_empty():
		return ""
	var words: PackedStringArray = label.split(" ", false)
	if words.is_empty():
		return ""
	var first: String = String(words[0]).to_lower()
	first = first.trim_suffix(",").trim_suffix(".").trim_suffix(":")
	var body: String = label
	if not NOT_A_VERB.has(first):
		body = "You " + label.substr(0, 1).to_lower() + label.substr(1)
	if body.ends_with(".") or body.ends_with("!") or body.ends_with("?"):
		return body
	return body + "."


# Who is in shot for a line that came with no film of its own.
#
# Whoever was in the last one, preserving their positions and appearance.
# Failing that — a beat that opens with
# nothing but a line — the alien and whoever he is failing to understand.
static func held_cast(last: Array, seed_id: String) -> Array:
	var h: int = absi(seed_id.hash())
	if last.is_empty():
		return [
			{"at": 0.30 + float(h % 7) * 0.012, "act": "watch"},
			{"at": 0.64 + float((h >> 3) % 7) * 0.012, "act": "stand"},
		]
	var out: Array = []
	for i in range(last.size()):
		var who: Dictionary = last[i]
		var held: Dictionary = who.duplicate(true)
		held["at"] = float(who.get("at", 0.5))
		held["act"] = String(who.get("act", "stand"))
		held["z"] = float(who.get("z", 0.78 - float(i) * 0.14))
		out.append(held)
	return out


# Every district that has one, for the checker and for the build log.
static func keys() -> Array:
	var out: Array = []
	for table in [EAST.SPOTS, PACIFIC.SPOTS, SOUTH.SPOTS, NORTH.SPOTS,
		AMERICA.SPOTS, WEST.SPOTS, NORTHWEST.SPOTS, EASTTWO.SPOTS,
		SOUTHTWO.SPOTS, EUROPETWO.SPOTS]:
		for k in table.keys():
			if not out.has(k):
				out.append(k)
	return out
