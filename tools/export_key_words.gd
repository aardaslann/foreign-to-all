extends SceneTree

# The words the game deliberately teaches, for recording one at a time so the
# notebook can say each of them (AudioManager.say_word). A key word is one a
# story scene confirms or catches him misreading, or one a district activity
# shows him with the thing it names. Writes
# docs/beta-language-review/key-words.json; then run
# python tools/build_voices.py --words.
#
# Display keys stay romanised; recording uses native-script readings from
# tools/notebook_readings.json, never an English reading of those spellings.
#
# Run: godot --headless --path . --script res://tools/export_key_words.gd

const VOICED := ["german", "turkish", "english", "french", "spanish_mx", "russian", "hindi", "japanese"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var gs := root.get_node("GameState")
	var words: Dictionary = {}
	var items := root.get_node("Items")
	for item: String in items._all_words:
		for language: String in items._all_words[item]:
			_add(words, language, items._all_words[item][language])
	_add(words, "german", "danke")
	for city: String in _story_cities():
		var language: String = String(gs.CITIES.get(city, {}).get("language", ""))
		for path: String in _story_scripts(city):
			var script: Script = load(path)
			var constants: Dictionary = script.get_script_constant_map()
			if not constants.has("CHAPTERS"):
				continue
			for chapter: String in constants["CHAPTERS"]:
				for step: Dictionary in constants["CHAPTERS"][chapter]:
					if String(step.get("do", "")) == "understand":
						_add(words, String(step.get("language", language)), String(step.get("word", "")))
					for option: Dictionary in step.get("options", []):
						for key: String in ["confirm", "misread"]:
							for w: String in Dictionary(option.get(key, {})):
								_add(words, String(option.get("language", language)), w)
	var streetside: Script = load("res://scenes/world/Streetside.gd")
	for key2: String in streetside.keys():
		var city2: String = key2.get_slice(":", 0)
		if not root.get_node("Story").MANDATORY.has(city2):
			continue
		var spot: Dictionary = streetside.spot(city2, key2.get_slice(":", 1))
		for beat: Dictionary in Dictionary(spot.get("beats", {})).values():
			for pair: Array in beat.get("learn", []):
				_add(words, String(pair[0]), String(pair[1]))
	var folder := "res://docs/beta-language-review"
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder + "/key-words.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"words": words.values()}, "\t"))
	file.close()
	print("Key word export: ", words.size(), " words")
	quit()


func _add(words: Dictionary, language: String, word: String) -> void:
	word = word.strip_edges().to_lower()
	if word.is_empty() or not VOICED.has(language):
		return
	words[language + "|" + word] = {"language": language, "word": word,
		"context": "a word the story teaches", "review": "pending"}


func _story_cities() -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://scenes/story")
	if dir == null:
		return out
	for name: String in dir.get_directories():
		out.append(name)
	return out


func _story_scripts(city: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://scenes/story/" + city)
	if dir == null:
		return out
	for name: String in dir.get_files():
		if name.ends_with(".gd") and name.contains("Script"):
			out.append("res://scenes/story/%s/%s" % [city, name])
	return out
