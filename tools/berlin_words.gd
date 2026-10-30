extends SceneTree
# Every word the Berlin story says, and which of them the notebook has no guess
# for. Loaded at runtime rather than preloaded, because a --script tool is
# compiled before the autoloads the story scripts talk to exist.
# Run: godot --headless --path . --script res://tools/berlin_words.gd
func _initialize() -> void:
	var story = load("res://scenes/story/berlin/BerlinStory.gd")
	var late = load("res://scenes/story/berlin/BerlinScriptLate.gd")
	var early = load("res://scenes/story/berlin/BerlinScript.gd")
	var director = load("res://scenes/story/StoryDirector.gd")
	var gs = root.get_node("GameState")
	var words := {}
	var chapters: Array = early.CHAPTERS.keys() + late.CHAPTERS.keys()
	for ch in chapters:
		for s: Dictionary in story.steps(ch):
			if String(s.get("language", "")) == "english":
				continue
			var said: String = String(s.get("say", ""))
			if said.is_empty():
				continue
			for pair in director.pairs_of(said):
				words[String(pair[1])] = true
	for line in late.AFTER:
		for pair in director.pairs_of(line):
			words[String(pair[1])] = true
	var missing: Array = []
	for w in words:
		if String(w).is_empty():
			continue
		if gs.word_guess("german", w).is_empty():
			missing.append(w)
	missing.sort()
	print("BERLIN WORDS ", words.size(), " missing ", missing.size())
	print("MISSING: ", " ".join(missing))
	quit()
