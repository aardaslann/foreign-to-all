extends RefCounted

# What he actually knows, as opposed to what has gone past him.
#
# Familiarity counts every word said within earshot - every "die", every "ma",
# every fragment a stranger says to somebody else - and for reading that is
# right: sentences should slowly stop being glyphs. But it was also what filled
# the notebook, so the notebook became a list of sounds the player never
# noticed, announced by a notification for each one, and a list you did not
# notice filling is a list you do not remember. People keep the words they paid
# attention to, guessed at, and met again.
#
# So the notebook is split by what the player DID with a word:
#
#   found     he acted on a reading and the world bore it out (understand())
#   noticed   he said it, was shown it, read it, or guessed wrong about it
#   by ear    readable now from sheer repetition, never engaged with
#   sounds    everything else - caught, not yet anything
#
# and a found word that comes back somewhere new is RECOGNISED: counted, shown
# in gold when it is said, and worth a little more familiarity. Meeting a word
# again in a different place is how it stops being a word from one scene.

# Evidence that the player engaged with a word rather than overheard it.
const ENGAGED := ["pointed", "see", "used", "read", "understood"]
# Recognition means meeting it AGAIN, not in the same breath it was learned:
# seconds of play since it was found before a hearing counts as a return.
const RECALL_AFTER := 60.0
const MAX_RECALLS := 24


# The game's state, found at run time rather than named: CharacterArt preloads
# this file, tools preload CharacterArt, and a --script tool is compiled before
# the autoloads it would otherwise name exist.
static func _gs() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node("/root/GameState")

static func _entry(language: String, word: String) -> Dictionary:
	var book: Dictionary = _gs().world_flags.get("understood", {})
	var shelf: Dictionary = book.get(language, {})
	return shelf.get(word.to_lower(), {})


static func meaning(language: String, word: String) -> String:
	return String(_entry(language, word).get("meaning", ""))


static func found(language: String, word: String) -> bool:
	return not meaning(language, word).is_empty()


static func noticed(language: String, word: String) -> bool:
	var entry: Dictionary = _entry(language, word)
	if not String(entry.get("meaning", "")).is_empty() \
			or not String(entry.get("first", "")).is_empty():
		return true
	var notes: Dictionary = _gs().world_flags.get("word_observations", {})
	var seen: Dictionary = Dictionary(notes.get(language, {})).get(word.to_lower(), {})
	for kind: String in ENGAGED:
		if int(seen.get(kind, 0)) > 0:
			return true
	return false


static func recalled(language: String, word: String) -> int:
	return int(_entry(language, word).get("recalled", 0))


static func keep_guess(language: String, word: String, guess: String, context: String) -> void:
	var entry := _entry(language, word)
	if entry.is_empty() or guess.strip_edges().is_empty(): return
	entry["reflection"] = guess.strip_edges().left(80)
	entry["reflection_context"] = context


static func evidence_label(language: String, word: String) -> String:
	if not Dictionary(_entry(language, word).get("applications", {})).is_empty():
		return "Used elsewhere"
	if found(language, word): return "Meaning found"
	if noticed(language, word): return "Noticed"
	return "Recognised by ear"


static func apply_in_context(language: String, word: String, context: String, memory: String) -> bool:
	if not found(language, word): return false
	var entry := _entry(language, word)
	var actions: Dictionary = entry.get("applications", {})
	if actions.has(context): return false
	actions[context] = memory
	entry["applications"] = actions
	# Choosing an object is evidence of understanding, not of speaking aloud.
	_gs().expose(language, word, "pointed")
	return true


# A found word, heard again. `context` is who said it and what they said, so
# the same sentence heard twice is one recognition and the same word in a new
# sentence is another. Returns true the first time for this context.
static func recall(language: String, word: String, context: String) -> bool:
	word = word.to_lower()
	var book: Dictionary = _gs().world_flags.get("understood", {})
	var shelf: Dictionary = book.get(language, {})
	var entry: Dictionary = shelf.get(word, {})
	if String(entry.get("meaning", "")).is_empty():
		return false
	var since: float = _gs().play_time - float(entry.get("found_at", -9999.0))
	if since < RECALL_AFTER:
		return false
	var heard_in: Array = entry.get("recalls", [])
	if heard_in.has(context):
		return false
	heard_in.append(context)
	while heard_in.size() > MAX_RECALLS:
		heard_in.pop_front()
	entry["recalls"] = heard_in
	entry["recalled"] = int(entry.get("recalled", 0)) + 1
	shelf[word] = entry
	book[language] = shelf
	_gs().world_flags["understood"] = book
	_gs().expose(language, word, "recalled")
	return true


# Every word of one language the player has met, sorted into what they did
# with it. Found and noticed words come with their familiarity, most recent
# discoveries of each first by strength; by-ear words are only the readable
# ones - a word you cannot make out is not a word you can write down.
static func sections(language: String) -> Dictionary:
	var out: Dictionary = {"found": [], "noticed": [], "by_ear": [], "sounds": 0}
	var fam: Dictionary = _gs().familiarity.get(language, {})
	for word: String in fam:
		var score: int = int(fam[word])
		if score <= 0:
			continue
		var row: Dictionary = {"word": word, "score": score}
		if found(language, word):
			out["found"].append(row)
		elif noticed(language, word):
			out["noticed"].append(row)
		elif _gs().get_tier(language, word) >= _gs().TIER_PARTIAL:
			out["by_ear"].append(row)
		else:
			out["sounds"] = int(out["sounds"]) + 1
	for key: String in ["found", "noticed", "by_ear"]:
		out[key].sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	return out
