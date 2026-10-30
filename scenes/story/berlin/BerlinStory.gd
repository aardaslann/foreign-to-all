extends RefCounted

# Berlin's story: who is in it, where the player is up to, and the things the
# script asks for that are not just people moving and talking.
#
# The chapters are data (BerlinScript.gd, BerlinScriptLate.gd) and the street
# they happen in is BerlinStage.gd. This is the part between: the cast, the
# state in world_flags, the quest log's sentence about it, and the cues.
#
# ── The shape of it ──────────────────────────────────────────────────────────
#
#   1   Leergut      the crates, Pfand, a name he does not have     Mitte
#       - he has to sleep: "Morgen" is the gate, and a word he has to read
#   2   Kaffee       coffee, Rika's English, the Wall, a bag for Emil  Mitte
#   3   Für Emil     the bench, pride, a knee, du offered            Prenzlauer Berg
#   3b  Und?         what he carried back                           Mitte
#       - he has to sleep again: it is Saturday tomorrow
#   4   Samstag      the dirndl, Emil, the chair, the Wiesn         Mitte, then the reel
#
# Friendship rounds are Story's, so everything that reads them - the holiday
# decorations, the naming ending, the journal - keeps working: 1, 2 and 3b each
# add one, 3 is the errand, and 4 is the holiday.

const SCRIPT := preload("res://scenes/story/berlin/BerlinScript.gd")
const LATE := preload("res://scenes/story/berlin/BerlinScriptLate.gd")
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const LINES := preload("res://scenes/npc/KeyLines.gd")
const KEY := "berlin_story"
const QUEST := "journey_berlin"
const MITTE := "res://scenes/world/Mitte.tscn"
const PRENZLBERG := "res://scenes/world/BerlinPrenzlberg.tscn"

var stage: Node


# ── State ─────────────────────────────────────────────────────────────────────

static func state() -> Dictionary:
	if not GameState.world_flags.has(KEY):
		GameState.world_flags[KEY] = {"done": {}, "resume": {}, "flags": {},
			"memories": [], "seen": {}, "night_at": {}, "stages": {}}
		# Retain earned friendship/holiday progress from the earlier chapter UI.
		var previous: Dictionary = GameState.world_flags[KEY]
		var rounds: int = Story.rounds_done("berlin")
		for pair: Array in [[1, "1"], [2, "2"], [3, "3"], [3, "3b"]]:
			if rounds >= pair[0]:
				previous["done"][pair[1]] = true
		if Story.holiday_seen("berlin"):
			for chapter: String in ["1", "2", "3", "3b", "4"]:
				previous["done"][chapter] = true
		if rounds >= 2 and rounds < 3:
			previous["flags"]["bag"] = true
	if not GameState.world_flags[KEY].has("stages"):
		GameState.world_flags[KEY]["stages"] = {}
	if not GameState.world_flags[KEY].has("morning_at"):
		var deadlines := {}
		for chapter: String in GameState.world_flags[KEY].get("done", {}):
			deadlines[chapter] = GameState.CLOCK.next_hour(GameState.clock_minutes, "berlin", 8)
		GameState.world_flags[KEY]["morning_at"] = deadlines
	return GameState.world_flags[KEY]


static func done(chapter: String) -> bool:
	return bool(Dictionary(state()["done"]).get(chapter, false))


static func flag(k: String):
	return Dictionary(state()["flags"]).get(k, null)


static func nights() -> int:
	return int(GameState.world_flags.get("nights", 0))


static func slept_since(chapter: String) -> bool:
	var s := state()
	return nights() > int(Dictionary(s["night_at"]).get(chapter, -1)) \
		or GameState.clock_minutes >= float(s["morning_at"].get(chapter, INF))


static func understood(word: String) -> bool:
	return not String(GameState.understanding("german", word).get("meaning", "")).is_empty()


# What Kerstin has to say next, from where the story is.
static func due_kerstin() -> String:
	if not done("1"):
		return "1"
	if not done("2"):
		return "2" if slept_since("1") else "wait_morgen"
	if not done("3"):
		return "wait_emil"
	if not done("3b"):
		return "3b"
	if not done("4"):
		return "4" if slept_since("3b") else "wait_saturday"
	return "after"


# Emil is on his bench from the moment somebody has been sent to him until the
# Saturday he comes back to the Späti. After that he sits there instead.
static func due_emil() -> String:
	if not done("2"):
		return ""
	if not done("3"):
		return "3"
	if not done("4"):
		return "emil_waiting"
	return ""


static func steps(chapter: String) -> Array:
	if SCRIPT.CHAPTERS.has(chapter):
		return SCRIPT.CHAPTERS[chapter]
	return LATE.CHAPTERS.get(chapter, [])


# ── The cast ──────────────────────────────────────────────────────────────────
#
# Voices are the keys tools/build_voices.py records them under. Kerstin is the
# game's own design from Cast.gd; Emil and Rika are drawn from the city's crowd
# tables and then dressed as themselves.

static func look_of(id: String, outfit: String = "") -> Dictionary:
	match id:
		"kerstin":
			var k: Dictionary = Story.look_for("berlin").duplicate(true)
			if outfit == "dirndl":
				k["wear"] = "apron"
				var pal: Dictionary = k.get("pal", {}).duplicate()
				pal["C"] = Color8(46, 94, 66)
				pal["D"] = Color8(32, 70, 48)
				pal["a"] = Color8(238, 234, 224)
				pal["g"] = Color8(246, 242, 236)
				pal["n"] = Color8(176, 52, 56)
				k["pal"] = pal
			return k
		"emil":
			var e: Dictionary = CHAR.look(4471, "berlin")
			e["build"] = "elder"
			e["wear"] = "coat"
			e["cut"] = "flatcap"
			e["mark"] = "greybeard"
			e["idle"] = "still"
			return e
		"rika":
			var r: Dictionary = CHAR.look(1987, "berlin")
			r["build"] = "adult"
			r["wear"] = "hoodie"
			r["cut"] = "topknot"
			return r
	return {}


func cast() -> Dictionary:
	return {
		"kerstin": {"name": "Kerstin", "voice": "kerstin", "language": "german",
			"look": look_of("kerstin"), "region": "mitte",
			"color": Color(0.36, 0.44, 0.56)},
		"emil": {"name": "Emil", "voice": "emil", "language": "german",
			"look": look_of("emil"), "region": "prenzlberg",
			"color": Color(0.46, 0.40, 0.34)},
		"rika": {"name": "Rika", "voice": "rika", "language": "german",
			"look": look_of("rika"), "region": "mitte",
			"color": Color(0.56, 0.36, 0.52)},
	}


func look(id: String, outfit: String) -> Dictionary:
	return look_of(id, outfit)


# Who expects which "you". This is the whole of the person-specific culture in
# one place: the Späti is du from the first crate, and Emil is Sie until he
# holds his hand out.
func person(id: String) -> Dictionary:
	match id:
		"kerstin":
			return {"build": "adult", "wants": "du"}
		"emil":
			return {"build": "elder", "wants": "du" if flag("emil_du") == true else "sie"}
		"rika":
			return {"build": "youth", "wants": "du"}
	return {"build": "adult"}


func relationship(id: String) -> String:
	match id:
		"kerstin":
			return LINES.standing("berlin", mini(Story.rounds_done("berlin"), 2))
		"emil":
			return "somebody he knows" if flag("emil_du") == true else "a man on a bench"
		"rika":
			return "Kerstin's niece"
	return ""


# ── What the director asks of the story ──────────────────────────────────────

func checkpoint(chapter: String, label: String) -> void:
	state()["resume"][chapter] = label
	SaveManager.checkpoint()


func save_stage(chapter: String, value: Dictionary) -> void:
	state()["stages"][chapter] = value


func saved_stage(chapter: String) -> Dictionary:
	return state()["stages"].get(chapter, {})


func resume_label(chapter: String) -> String:
	return String(Dictionary(state()["resume"]).get(chapter, ""))


func allows(option: Dictionary) -> bool:
	var need: Dictionary = option.get("if", {})
	for k: String in need:
		if flag(k) != need[k]:
			return false
	var against: Dictionary = option.get("unless", {})
	for k2: String in against:
		if flag(k2) == against[k2]:
			return false
	return true


func test(step: Dictionary) -> bool:
	if step.has("flag"):
		var v = flag(String(step["flag"]))
		return v != null and v != false
	if step.has("register"):
		return GameState.register_for("german") == String(step["register"])
	if step.has("understood"):
		return understood(String(step["understood"]))
	return false


func set_flag(k: String, v) -> void:
	state()["flags"][k] = v


func first_time(key: String) -> bool:
	var seen: Dictionary = state()["seen"]
	if seen.has(key):
		return false
	seen[key] = true
	return true


func moment(chapter: String) -> String:
	return String({
		"1": "carrying Kerstin's crates", "2": "coffee at the Späti",
		"3": "Emil's bench, Kollwitzplatz", "3b": "back at the Späti",
		"4": "the Saturday of the Wiesn",
	}.get(chapter, "Berlin"))


func remember(title: String, text: String) -> void:
	var memories: Array = state()["memories"]
	for m: Dictionary in memories:
		if String(m.get("title", "")) == title:
			return
	memories.append({"title": title, "text": text})
	# The naming ending and the journey page both read one line per city.
	Journey.ledger()["memories"]["berlin"] = text


func delivered(_chapter: String, _kind: String, _count: int, _director: Node) -> void:
	pass


func cue(name: String, step: Dictionary, director: Node):
	match name:
		"stack":
			director._prop({"id": "stack", "kind": "crate", "at": [240, 468], "label": "PFAND"})
		"give_bag":
			if not done("3") and GameState.carrying != "story_bag":
				GameState.carry_load("story_bag")
			set_flag("bag", true)
		"take_bag":
			if GameState.carrying == "story_bag":
				GameState.carrying = ""
				GameState.job_changed.emit(GameState.active_job)
			set_flag("bag", false)
		"chapter_done":
			_finish(director.chapter)
		"errand_done":
			if done("3"):
				return null
			state()["done"]["3"] = true
			state()["resume"].erase("3")
			GameState.world_flags["berlin_errand_done"] = true
			GameState.change_reputation("prenzlberg", 4)
			guide()
			SaveManager.checkpoint()
		"holiday":
			var cs := director.get_tree().get_first_node_in_group("cutscene")
			if cs != null:
				cs.play("berlin", reel(), true)
				await cs.finished
				if not cs.completed:
					return "__left__"
		"holiday_done":
			if done("4"):
				return null
			state()["done"]["4"] = true
			state()["resume"].erase("4")
			Story.mark_holiday("berlin")
			GameState.change_reputation("mitte", 6)
			SaveManager.checkpoint()
		"after_line":
			var said: String = String(LATE.AFTER[randi() % LATE.AFTER.size()])
			await director._line({"id": "kerstin", "say": said, "act": "wave"})
	return null


func _finish(chapter: String) -> void:
	if done(chapter):
		return
	state()["done"][chapter] = true
	state()["resume"].erase(chapter)
	state()["night_at"][chapter] = nights()
	state()["morning_at"][chapter] = GameState.CLOCK.next_hour(GameState.clock_minutes, "berlin", 8)
	if chapter in ["1", "2", "3b"]:
		Story.add_round("berlin")
	else:
		guide()
	SaveManager.checkpoint()


# ── The quest log ─────────────────────────────────────────────────────────────
#
# One quest, five steps, and each step is written in terms of what he actually
# worked out. If he read "Morgen" as a greeting, the log does not know better
# than he does; if Kerstin drew him a map, the log has the map.

static func guide() -> void:
	for old: String in ["earn_keep", "learn_berlin", "meet_berlin", "errand_berlin",
			"holiday_berlin", "on_to_berlin"]:
		if GameState.quests.has(old) and not bool(GameState.quests[old].get("completed", false)):
			for st: Dictionary in GameState.quests[old].get("steps", []):
				st["done"] = true
			GameState.quests[old]["completed"] = true
			GameState.quest_updated.emit(old)
	var texts: Array = step_texts()
	var targets: Array = [MITTE, MITTE, PRENZLBERG, MITTE, MITTE]
	var states: Array = [done("1"), done("2"), done("3"), done("3b"), done("4")]
	GameState.start_quest(QUEST, "Der Neue", texts, targets)
	var q: Dictionary = GameState.quests[QUEST]
	if q["steps"].size() != texts.size():
		q["steps"] = []
		for i in range(texts.size()):
			q["steps"].append({"text": texts[i], "target": targets[i], "done": states[i]})
		GameState.quest_updated.emit(QUEST)
	var changed: bool = false
	for i in range(mini(q["steps"].size(), texts.size())):
		var st2: Dictionary = q["steps"][i]
		if st2["done"] != states[i] or st2["text"] != texts[i] or st2["target"] != targets[i]:
			st2["done"] = states[i]
			st2["text"] = texts[i]
			st2["target"] = targets[i]
			changed = true
	if bool(q["completed"]) != done("4"):
		q["completed"] = done("4")
		changed = true
	if changed:
		GameState.quest_updated.emit(QUEST)


static func step_texts() -> Array:
	var morgen: String = "Kerstin said \"morgen\". She pointed at the hotel first - sleep, then come back"
	if understood("morgen") and slept_since("1"):
		morgen = "It is tomorrow. Kerstin is at the Späti"
	elif understood("morgen"):
		morgen = "Come back to the Späti in the morning. You can sleep at the hotel next door"
	var bag: String = "Take the bag to Emil. She pointed north and said \"Kollwitzplatz\", twice"
	if flag("map_drawn") == true:
		bag = "Take the bag to Emil. She drew a U and a 2 on it - the U-Bahn to Prenzlauer Berg"
	elif understood("kollwitzplatz"):
		bag = "Take the bag to Emil, on his bench at Kollwitzplatz in Prenzlauer Berg"
	var saturday: String = "Saturday. Sleep, and then find Kerstin at the Späti"
	if slept_since("3b"):
		saturday = "It is Saturday. Kerstin is waiting at the Späti"
	return ["Somebody at the Späti next to the hotel could use a hand", morgen, bag,
		"Tell Kerstin what Emil said", saturday]


static func next_step() -> String:
	var texts: Array = step_texts()
	var states: Array = [done("1"), done("2"), done("3"), done("3b"), done("4")]
	for i in range(states.size()):
		if not states[i]:
			return String(texts[i])
	return "Kerstin has a chair outside the Späti with your name on it. Or the only name you have."


# ── Saturday ──────────────────────────────────────────────────────────────────
#
# The reel is the original one's argument - the only German thing the world
# can name is Bavarian, and she is standing in it in a borrowed dress - with
# the two people this Berlin was about put back into it: Emil on the chair he
# was carried, and the name on the way home. Cast 0 is always the alien.

static func reel() -> Array:
	var k: Dictionary = look_of("kerstin", "dirndl")
	var e: Dictionary = look_of("emil")
	return [
		{"set": "street", "cast": [{"at": 0.26, "act": "watch"},
				{"at": 0.50, "act": "stand", "appearance": k},
				{"at": 0.70, "act": "stand", "appearance": e}],
			"say": "Kerstin in her sister's dirndl, holding the rail with one hand and her skirt with the other, and the whole carriage dressed as somebody from six hundred kilometres away."},
		{"set": "market", "prop": "glass", "prop_at": 0.66,
			"cast": [{"at": 0.26, "act": "watch"}, {"at": 0.52, "act": "offer"}, {"at": 0.72, "act": "drink"}],
			"say": "A litre of beer in a glass with a handle, which takes two hands to lift. Emil lifts his with one and does not put it down."},
		{"set": "stall", "prop": "board", "prop_at": 0.30,
			"cast": [{"at": 0.30, "act": "look"}, {"at": 0.56, "act": "point"}, {"at": 0.76, "act": "watch"}],
			"say": "Roast almonds, a hoopla stall, a small wheel going round, and a brass band on a flatbed lorry playing a song everybody knows the second line of."},
		{"set": "street", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.54, "act": "stand"}, {"at": 0.74, "act": "look"}],
			"voice": ["kerstin", "Dit is nich unsa. Dit is Bayern."],
			"say": "“Dit is nich unsa. Dit is Bayern.” Not ours, she says. Bavaria's. Emil says she says it every year, and every year she comes."},
		{"set": "market", "cast": [{"at": 0.30, "act": "watch"}, {"at": 0.52, "act": "stand"}, {"at": 0.72, "act": "sit"}],
			"say": "Emil sits on the chair I carried and tells the man beside him that he drove the M10 for thirty-one years. The man has not asked. Emil tells him anyway."},
		{"set": "street", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.58, "act": "bow"}, {"at": 0.74, "act": "stand"}],
			"say": "The only German thing the rest of the world can name comes from a part of the country she has been to twice, and she is standing in it in a borrowed dress. I have spent this whole time being read as a category instead of a person. I know the shape of this exactly."},
		{"set": "street", "cast": [{"at": 0.34, "act": "watch"}, {"at": 0.58, "act": "wave"}, {"at": 0.74, "act": "wave"}],
			"voice": ["kerstin", "Komm, Neuer."],
			"say": "“Komm, Neuer.” On the way home she says it without thinking about it, and it sounds like a name."},
	]
