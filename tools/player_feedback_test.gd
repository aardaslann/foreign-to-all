extends SceneTree

var checks := 0
var failures := 0
var gs: Node
var services: Node
var journey: Node

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("PLAYER FEEDBACK: " + message)

func _run() -> void:
	root.get_node("SaveManager").use_test_storage("player-feedback")
	gs = root.get_node("GameState")
	services = root.get_node("Services")
	journey = root.get_node("Journey")
	gs.reset()
	var words := {"german":["ich", "und", "fur"], "turkish":["ben", "ve", "icin"],
		"english":["me", "and", "for"], "french":["je", "et", "pour"],
		"russian":["ya", "i", "dlya"], "hindi":["main", "aur", "ke"],
		"japanese":["watashi", "to", "wa"], "spanish_mx":["yo", "y", "para"]}
	for lang: String in words:
		for word: String in words[lang]:
			gs.expose(lang, word, "hear")
			var guess: String = gs.word_guess(lang, word)
			check(not guess.is_empty() and not "still a question" in guess, lang + ": " + word + " has a tentative meaning after hearing")
			check(gs.understanding(lang, word).is_empty(), "a hint is not an earned discovery: " + word)
	check(ResourceLoader.exists("res://scenes/ui/WordDiscovery.gd"), "player-paced word discovery exists")
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var story := root.get_node("Story")
	for city: String in story.MANDATORY:
		if city == "berlin": continue
		gs.reset()
		gs.city = city
		gs.quests["find_bed"] = {"completed":true, "steps":[]}
		world.scene_file_path = gs.ARRIVALS[city]
		journey.guide(city)
		var step: String = gs.quests["journey_" + city].steps[0].text
		var destination: String = story.path(story.SCENE[city])
		var stop: Array = services.destination_stop(city, destination)
		var station: String = "" if stop.is_empty() else String(stop[2])
		check(not station.is_empty() and station in step, city + " quest names the actual destination station")
		check(String(story.WHERE[city]) in step, city + " quest includes the local landmark")
		check(ResourceLoader.exists("res://scenes/celebrations/" + city + ".tscn"), city + " has a dedicated event scene")
	check(ResourceLoader.exists("res://scenes/celebrations/berlin.tscn"), "Berlin has a dedicated event scene")
	world.queue_free()
	await process_frame
	print("PLAYER FEEDBACK: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
