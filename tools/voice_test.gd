extends SceneTree

# Everybody who speaks has a voice, and gets it. Every line in the speech
# census (tools/export_all_speech.gd) resolves to an ElevenLabs clip the game
# can load; the crowd and the notebook are recorded; and each kind of person
# hands their own voice to the dialogue box rather than speaking in silence.
#
# Run: godot --headless --path . --script res://tools/voice_test.gd

var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("VOICES: " + message)


func _json(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


func _eleven(path: String) -> bool:
	return path.get_file().begins_with("el_") and ResourceLoader.exists(path)


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("voice")
	var audio: Node = root.get_node("AudioManager")
	var manifest: Dictionary = audio._manifest

	# Every line, in the voice of the person who says it - apart from the
	# speakers the cast documents as `unvoiced` (the two children, whose voices
	# the designer refuses to make), who are reported rather than failed.
	var cast: Dictionary = _json("res://tools/voice_cast.json").get("voices", {})
	var missing: Array = []
	var excused: Array = []
	for line: Dictionary in _json("res://docs/beta-language-review/all-speech.json").get("lines", []):
		var path: String = String(Dictionary(manifest.get("lines", {})).get(
			audio.voice_key(String(line["voice"]), String(line["text"])), ""))
		if _eleven(path):
			continue
		if Dictionary(cast.get(String(line["voice"]), {})).has("unvoiced"):
			excused.append(String(line["voice"]))
		else:
			missing.append(String(line["voice"]) + "|" + String(line["text"]))
	check(missing.is_empty(), "every spoken line has its character's recording (%d without: %s)" % [
		missing.size(), str(missing.slice(0, 6))])
	if not excused.is_empty():
		print("VOICES: silent by documented exception: ", ", ".join(excused))

	# The street: every fragment in two passers-by's voices.
	var thin: Array = []
	for row: Dictionary in _json("res://docs/beta-language-review/chatter-lines.json").get("lines", []):
		var paths: Array = Dictionary(manifest.get("chatter", {})).get(
			audio.voice_key(String(row["language"]), String(row["text"])), [])
		if paths.filter(func(p): return _eleven(String(p))).size() < 2:
			thin.append(String(row["text"]))
	check(thin.is_empty(), "every crowd fragment has two voices (%d short: %s)" % [thin.size(), str(thin.slice(0, 4))])

	# The notebook's words.
	var unsaid: Array = []
	for w: Dictionary in _json("res://docs/beta-language-review/key-words.json").get("words", []):
		var p: String = String(Dictionary(manifest.get("words", {})).get(
			audio.voice_key(String(w["language"]), String(w["word"]).to_lower()), ""))
		if not _eleven(p):
			unsaid.append(String(w["word"]))
	check(unsaid.is_empty(), "every notebook word is recorded (%d not: %s)" % [unsaid.size(), str(unsaid.slice(0, 6))])

	# A clip really decodes, and has the length of a sentence rather than a click.
	check(audio.voice_seconds("kerstin", "Mensch, die Kisten.") > 0.4, "a recording decodes and has a real length")

	# Each kind of person speaks in their own voice when you talk to them.
	var gs: Node = root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await _frames(8)
	var dlg: Node = get_first_node_in_group("dialogue_box")
	var people := [
		["res://scenes/npc/CityNPC.tscn", {"npc_id": "hartmut", "city": "berlin"}, "berlin_hartmut", "_start_dialogue"],
		["res://scenes/npc/NPC.tscn", {}, "lukas", "_start_dialogue"],
		["res://scenes/npc/BusStopNPC.tscn", {}, "renate", "_start_dialogue"],
		["res://scenes/npc/Receptionist.tscn", {}, "weber", "_start_dialogue"],
		["res://scenes/npc/Encounter.tscn", {"encounter": "berlin_room"}, "neumann", "_talk"],
	]
	for spec: Array in people:
		var person: Node = load(String(spec[0])).instantiate()
		for k: String in Dictionary(spec[1]):
			person.set(k, spec[1][k])
		world.add_child(person)
		await _frames(3)
		person.call(String(spec[3]))
		await _frames(3)
		check(dlg.visible and String(dlg._voice_id) == String(spec[2]),
			"%s speaks as %s (got '%s')" % [String(spec[0]).get_file(), spec[2], dlg._voice_id])
		check(dlg._hear_again.visible, "%s is heard, not just read" % String(spec[2]))
		dlg._close()
		person.queue_free()
		await _frames(2)

	world.queue_free()
	await process_frame
	print("VOICES: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)


func _frames(n: int) -> void:
	for i in range(n):
		await process_frame
