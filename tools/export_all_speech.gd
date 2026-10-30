extends SceneTree

# Every line a person in the game says out loud, with who says it, for casting
# and recording the voices (tools/voice_cast.json, tools/build_voices.py
# --eleven). Read-only. Writes docs/beta-language-review/all-speech.json.
#
# A line is keyed exactly as AudioManager looks it up - speaker id and the text
# as spoken - so a line recorded here is found in the game without any second
# table. Where a line carries `tts` (the native-script reading of a romanised
# line) that is what is spoken and keyed.
#
# Run: godot --headless --path . --script res://tools/export_all_speech.gd

var gs: Node
var lines: Dictionary = {}
var speakers: Dictionary = {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	gs = root.get_node("GameState")
	_story()
	_city_rosters()
	_key_rounds()
	_encounters()
	_hand_built()
	_counters()
	var folder := "res://docs/beta-language-review"
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder + "/all-speech.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"speakers": speakers, "lines": lines.values()}, "\t"))
	file.close()
	_report()
	quit()


# ── Sources ──────────────────────────────────────────────────────────────────

func _story() -> void:
	var dir := DirAccess.open("res://scenes/story")
	for city: String in dir.get_directories():
		var sub := DirAccess.open("res://scenes/story/" + city)
		for name: String in sub.get_files():
			if not (name.ends_with(".gd") and name.contains("Script")):
				continue
			var consts: Dictionary = load("res://scenes/story/%s/%s" % [city, name]).get_script_constant_map()
			for chapter: String in Dictionary(consts.get("CHAPTERS", {})):
				for step: Dictionary in consts["CHAPTERS"][chapter]:
					if String(step.get("do", "")) not in ["line", "ask"]:
						continue
					var id: String = String(step.get("id", ""))
					var spoken: String = String(step.get("tts", step.get("say", "")))
					_add(id, city, String(step.get("language", _lang(city))), spoken,
						"story", String(step.get("stage", "")))
			for idle: String in consts.get("AFTER", []):
				_add("kerstin", city, _lang(city), idle, "story", "a greeting after the story")
		# The holiday reel: a shot may carry the one sentence somebody in it
		# says, as [speaker, words] (scenes/ui/Cutscene.gd plays it).
		for name2: String in sub.get_files():
			if not name2.ends_with("Story.gd"):
				continue
			var story: Script = load("res://scenes/story/%s/%s" % [city, name2])
			if not story.get_script_method_list().any(func(m): return m["name"] == "reel"):
				continue
			for shot: Dictionary in story.call("reel"):
				var said: Array = shot.get("voice", [])
				if said.size() == 2:
					_add(String(said[0]), city, _lang(city), String(said[1]), "story", "the holiday reel")


# Roster voices are city-qualified, as CityNPC passes them: two cities can
# each have a Lucia, and they are not the same woman.
func _city_rosters() -> void:
	var rosters: Script = load("res://scenes/npc/CityNPCs.gd")
	for city: String in gs.CITIES:
		var roster: Dictionary = rosters.roster(city)
		for npc: String in roster:
			var data: Dictionary = roster[npc]
			var id: String = city + "_" + npc
			_speaker(id, city, String(data.get("name", npc)), String(data.get("role", "")))
			for entry: Dictionary in _entries(data.get("rounds", [])):
				_add_entry(id, city, entry, "roster")


func _key_rounds() -> void:
	var key: Script = load("res://scenes/npc/KeyLines.gd")
	var story: Script = load("res://autoload/Story.gd")
	var people: Dictionary = story.get_script_constant_map()["PEOPLE"]
	for city: String in key.ROUNDS:
		var person: Dictionary = people.get(city, {})
		var id: String = _id(String(person.get("name", city)))
		_speaker(id, city, String(person.get("name", id)), "%s, %s" % [
			str(person.get("age", "")), String(person.get("trade", ""))])
		for entry: Dictionary in _entries(key.ROUNDS[city]):
			_add_entry(id, city, entry, "key_rounds")


func _encounters() -> void:
	var enc: Script = load("res://scenes/npc/Encounters.gd")
	for k: String in enc.ALL:
		var data: Dictionary = enc.ALL[k]
		var id: String = String(data.get("look", k))
		var city: String = String(data.get("city", ""))
		_speaker(id, city, String(data.get("name", id)), _note(id))
		for entry: Dictionary in _entries(data.get("lines", [])):
			_add_entry(id, city, entry, "encounter")


# Berlin's people from before the roster: Lukas, Renate, the walking pair and
# the hotel desk.
func _hand_built() -> void:
	# The walking pair name their speaker on each line ("voice"), so the id
	# here is only the fallback.
	var sources := {
		"lukas": ["res://scenes/npc/NPC.gd", ["_ROUNDS"]],
		"renate": ["res://scenes/npc/BusStopNPC.gd", ["_DIALOGUE", "_MAP_DIALOGUE"]],
		"ayse": ["res://scenes/npc/WalkingFriends.gd", ["_DIALOGUE"]],
		"weber": ["res://scenes/npc/Receptionist.gd", ["_GREET", "_EARLY", "_BOOKED"]],
	}
	for id: String in sources:
		var consts: Dictionary = load(String(sources[id][0])).get_script_constant_map()
		for c: String in sources[id][1]:
			for entry: Dictionary in _entries(consts.get(c, [])):
				_add_entry(id, "berlin", entry, "hand_built")


func _counters() -> void:
	var counters: Script = load("res://scenes/dialogue/CounterEncounter.gd")
	for city: String in counters.LINES:
		for index in [0, 2, 3]:
			_add("counter_" + city, city, _lang(city), String(counters.LINES[city][index]),
				"counter", "a room or a ticket")


# ── Helpers ──────────────────────────────────────────────────────────────────

# Every dictionary with a `words` list, however deep: rounds of entries,
# entries with branches, whatever shape a source happens to use.
func _entries(node: Variant) -> Array:
	var out: Array = []
	if node is Dictionary:
		if node.has("words") and node["words"] is Array:
			out.append(node)
		for v: Variant in node.values():
			out.append_array(_entries(v))
	elif node is Array:
		for v2: Variant in node:
			out.append_array(_entries(v2))
	return out


# `silent` only spares a line the register judgement; it is still said aloud.
func _add_entry(id: String, city: String, entry: Dictionary, source: String) -> void:
	var parts: PackedStringArray = []
	var language: String = ""
	for w: Variant in entry["words"]:
		if w is Dictionary:
			parts.append(String(w.get("text", "")))
			if language.is_empty():
				language = String(w.get("language", ""))
	var spoken: String = String(entry.get("tts", " ".join(parts)))
	_add(String(entry.get("voice", id)), city, language if not language.is_empty() else _lang(city),
		spoken, source, String(entry.get("stage", "")))


func _add(id: String, city: String, language: String, text: String, source: String, context: String) -> void:
	var spoken: String = " ".join(text.strip_edges().split(" ", false))
	if id.is_empty() or spoken.is_empty():
		return
	var key: String = id + "|" + spoken
	if lines.has(key):
		return
	lines[key] = {"voice": id, "text": spoken, "language": language, "city": city,
		"source": source, "context": context}
	if not speakers.has(id):
		_speaker(id, city, id.capitalize(), _note(id))


func _speaker(id: String, city: String, name: String, role: String) -> void:
	if speakers.has(id):
		return
	speakers[id] = {"name": name, "city": city, "language": _lang(city), "role": role}


func _note(id: String) -> String:
	var roster: Script = load("res://scenes/npc/CastRoster.gd")
	return String(Dictionary(roster.PEOPLE.get(id, {})).get("note", ""))


func _lang(city: String) -> String:
	return String(Dictionary(gs.CITIES.get(city, {})).get("language", "english"))


func _id(name: String) -> String:
	return name.to_lower().replace("í", "i").replace("é", "e").replace(" ", "_")


func _report() -> void:
	var core: Array = root.get_node("Story").MANDATORY
	var totals: Dictionary = {}
	for line: Dictionary in lines.values():
		var scope: String = "core" if core.has(String(line["city"])) else "other"
		for k: String in [scope, scope + "/" + String(line["source"])]:
			var t: Array = totals.get(k, [0, 0])
			totals[k] = [int(t[0]) + 1, int(t[1]) + String(line["text"]).length()]
	var keys: Array = totals.keys()
	keys.sort()
	for k2: String in keys:
		print("%-24s %5d lines %7d chars" % [k2, totals[k2][0], totals[k2][1]])
	print("speakers: ", speakers.size(), "  lines: ", lines.size())
