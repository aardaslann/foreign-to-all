extends SceneTree

# The two follow-ups to the player-feedback work of 2026-10-04:
#   1. Kerstin and Emil's small words are hinted as they actually say them
#      (ick, nich, dit, wat ...), not only in their standard German forms;
#   2. a staged discovery quotes the sentence its word was spoken in, even
#      when the last choice belonged to an earlier moment of the scene.

var checks := 0
var failures := 0
var gs: Node


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("WORD CONTEXT: " + message)


func frames(n := 3) -> void:
	for i in range(n):
		await process_frame


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("word-context")
	gs = root.get_node("GameState")
	gs.reset()

	# 1. Berlin speech is hinted; the words Berlin teaches are still earned.
	for word: String in ["ick", "nich", "dit", "wat", "nee", "wa", "na", "jut", "denn", "keen", "ooch", "is"]:
		gs.expose("german", word, "hear")
		var guess: String = gs.word_guess("german", word)
		check(not guess.is_empty() and not "still a question" in guess, "Berlin '%s' has a tentative meaning" % word)
		check(gs.understanding("german", word).is_empty(), "a hint is not a discovery: " + word)
	for taught: String in ["pfand", "morgen", "anfassen", "hoch", "neue"]:
		check(gs.WORD_HINTS.meaning("german", taught).is_empty(), "'%s' is left for the story to teach" % taught)

	# Every other city got the same: its own story lines' most frequent small
	# words are hinted, and the words its story teaches are still earned.
	var small := {"turkish": ["olsun", "tabii", "abi", "tamam", "lütfen"],
		"french": ["on", "ça", "mon", "votre", "maintenant"],
		"russian": ["vot", "chto", "nado", "zdes", "kak"],
		"hindi": ["kya", "hoon", "toh", "bas", "aaj"],
		"japanese": ["ii", "demo", "kudasai", "mada", "koko"],
		"spanish_mx": ["se", "así", "entonces", "aquí", "todavía"]}
	var taught_elsewhere := {"turkish": ["kutlu", "çay", "açık", "izin"], "french": ["bonjour", "merci", "voila", "peut-être"],
		"russian": ["pochinit", "lichnoye", "spasibo"], "hindi": ["dheere", "thoda", "yahaan"],
		"japanese": ["mochiyasui", "daijoubu", "mata"], "spanish_mx": ["taza", "esa", "dónde", "tapar"]}
	for lang: String in small:
		for word: String in small[lang]:
			check(not gs.WORD_HINTS.meaning(lang, word).is_empty(), "%s '%s' has a tentative meaning" % [lang, word])
		for word: String in taught_elsewhere[lang]:
			check(gs.WORD_HINTS.meaning(lang, word).is_empty(), "%s '%s' is left for the story to teach" % [lang, word])

	# 2. The staged discovery quotes the line, not only the last choice.
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var panel: Node = load("res://scenes/ui/WordDiscovery.gd").new()
	panel.set_meta("interactive_test", true)
	world.add_child(panel)
	var director: Node = load("res://scenes/story/StoryDirector.gd").new()
	world.add_child(director)
	director.host = world
	await frames()
	director._last_context = "She has one end of a crate of empty bottles off the ground."
	director._last_speaker = "Kerstin"
	director._remember_line("Kerstin", "Na? Kannste ma mit anfassen?")
	director._remember_line("Kerstin", "Pfand. Leere Flasche, Jeld zurück.")
	director._remember_line("Emil", "Wat soll dit?")
	director._understand({"language": "german", "word": "pfand", "meaning": "a deposit"})
	director._show_discoveries()
	await frames()
	check(panel._open, "the discovery opens")
	var text: String = panel._context.text
	check(text.contains("«Pfand. Leere Flasche, Jeld zurück.»"), "the sentence Pfand was said in is quoted: " + text)
	check(text.begins_with("Kerstin\n"), "the quote is credited to the person who said it")
	check(text.contains("crate of empty bottles"), "the moment's context still follows the quote")
	check(not text.contains("Wat soll dit"), "a later line without the word is not quoted")
	panel.reveal()
	panel._process(1.0)
	panel._advance()
	await frames()

	# A word nobody said aloud keeps the old context alone.
	director._understand({"language": "german", "word": "mauer", "meaning": "a wall"})
	director._show_discoveries()
	await frames()
	check(panel._open and not panel._context.text.contains("«"), "with no spoken line, nothing is invented")
	panel.close()
	await frames()

	# Only the last dozen lines are kept.
	for i in range(30):
		director._remember_line("Kerstin", "Zeile %d" % i)
	check(director._heard.size() == director.HEARD_KEPT, "the remembered lines stay bounded")

	world.queue_free()
	await frames()
	print("WORD CONTEXT: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
