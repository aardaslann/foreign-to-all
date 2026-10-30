extends SceneTree

var checks := 0
var failures := 0
var out := ""
var gs: Node
var words: Node

class CancellationProbe extends RefCounted:
	var advanced := false
	func moment(_chapter: String) -> String:
		return "A neighbour pointed to a spare chair."
	func set_flag(_key: String, _value: Variant) -> void:
		advanced = true

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FEEDBACK UI: " + message)

func frames(count := 4) -> void:
	for i in range(count): await process_frame

func capture(name: String) -> void:
	if out.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name + ".png"))

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out = args[0]
		DirAccess.make_dir_recursive_absolute(out)
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("feedback-ui")
	gs = root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(10)
	words = get_first_node_in_group("word_discovery")
	check(words != null, "world supplies discovery UI")
	words.set_meta("interactive_test", true)
	var dlg := get_first_node_in_group("dialogue_box")
	var entry := {"words":[{"text":"Setz", "word":"setz", "language":"german"},
		{"text":"dir.", "word":"dir", "language":"german"}],
		"stage":"Kerstin pulls out an empty chair, pats its seat and waits.", "keep":true, "in_world":true,
		"responses":[{"gesture":"Sit down on the offered chair", "confirm":{"setz":"sit down - Kerstin was offering you a seat"}}]}
	dlg.show_dialogue([entry], "Kerstin", "", Color.WHITE)
	await frames()
	dlg._on_response(entry.responses[0])
	await frames()
	check(words._open and dlg.visible, "response pauses on its first discovery")
	check(paused and not gs.clock_can_run(), "time and movement stay paused")
	check(not words._meaning.visible and words._context.text.contains("chair"), "context before the answer")
	check(words._context.text.contains("Sit down"), "chosen action stays visible")
	check(words._context.text.contains("«Setz dir.»"), "the sentence the word was said in is quoted")
	words._process(10.0)
	check(words._open and not words._revealed, "guess does not disappear on a timer")
	await capture("01-guess")
	words._guess.text = "[color=red]sit[/color]"
	words.reveal()
	check(words._meaning.visible and words._meaning.text.contains("sit down"), "meaning is explicit after the guess")
	check(words._comparison.text.contains("[color=red]"), "typed markup is plain text, never rich-text code")
	words._process(10.0)
	check(words._open, "meaning also waits for explicit continuation")
	check(gs.understanding("german", "setz").reflection == "[color=red]sit[/color]", "own guess saved separately from the meaning")
	await capture("02-meaning")
	words._advance()
	await frames()
	check(not words._open and not dlg.visible and not paused, "one continuation returns cleanly to play")
	check(saves.save_game(0), "reflection saves")
	gs.world_flags.understood = {}
	check(saves.load_game(0), "reflection save loads")
	check(gs.understanding("german", "setz").reflection.contains("sit"), "reflection persists on reload")
	gs.skip_next_visit_count = false
	dlg.show_dialogue([entry], "Kerstin", "", Color.WHITE)
	dlg._on_response(entry.responses[0])
	await frames()
	check(not words._open and not dlg.visible, "repeated confirmation does not quiz again")
	var director: Node = load("res://scenes/story/StoryDirector.gd").new()
	world.add_child(director)
	director.host = world
	director._last_context = "Tom\u00e1s traces the handle of the familiar cup."
	director._last_speaker = "Tom\u00e1s"
	director._understand({"language":"spanish_mx", "word":"esa", "meaning":"that particular one"})
	director._understand({"language":"spanish_mx", "word":"taza", "meaning":"cup"})
	director._show_discoveries()
	await frames()
	check(words._open and words._words.size() == 2, "adjacent staged discoveries share one interruption")
	words.reveal()
	check(words._meaning.text.contains("esa") and words._meaning.text.contains("taza"), "every meaning in the batch is visible")
	check(not words._comparison.visible, "no-typing path works")
	words._process(1.0)
	words._advance()
	director.queue_free()
	await frames()
	check(not paused, "staged discovery releases its pause")
	var cancelled: Node = load("res://scenes/story/StoryDirector.gd").new()
	var probe := CancellationProbe.new()
	world.add_child(cancelled)
	cancelled.host = world
	cancelled.story = probe
	cancelled.run([{"do":"understand", "language":"french", "word":"chaise", "meaning":"chair"},
		{"do":"set", "flag":"advanced", "value":true}], "", "cancellation")
	await frames()
	check(words._open, "cancellation test reaches the actual discovery wait")
	cancelled.cancel()
	await frames()
	check(not probe.advanced, "leaving during reflection cannot execute the next story step")
	check(not words._open and not paused and not cancelled.running(), "cancellation unwinds UI and director")
	cancelled.queue_free()
	var discovery := [{"language":"german", "word":"setz", "meaning":"sit down - Kerstin pats the chair and leaves it for you."}]
	for size: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,640)]:
		root.size = size
		saves.settings.text_size = 2
		words.open_words(discovery, entry.stage, "Kerstin")
		await frames(10)
		check(words._panel.get_global_rect().end.x <= root.get_visible_rect().end.x + 1, "panel fits viewport " + str(size))
		check(words._primary.get_global_rect().end.y <= root.get_visible_rect().end.y + 1, "continue stays on screen " + str(size))
		await capture("03-large-text-%d" % size.x)
		words.reveal()
		words._process(1.0)
		words._advance()
	root.size = Vector2i(1600,900)
	saves.settings.text_size = 1
	var cinema := get_first_node_in_group("cutscene")
	var events: Script = load("res://scenes/celebrations/Celebrations.gd")
	var journey := root.get_node("Journey")
	var story := root.get_node("Story")
	for city: String in story.MANDATORY:
		gs.city = city
		gs.current_region = String(story.person(city).region)
		var source: Array = journey.holiday_reel(city)
		var original: Array = source.duplicate(true)
		cinema.play(city, source, true)
		if city == "berlin": cinema._advance()
		await frames(12)
		cinema._t = 2.0
		cinema._canvas.queue_redraw()
		await frames()
		check(cinema._plate.scene_file_path == events.scene_path(city), city + " uses its actual dedicated packed scene")
		check(cinema._plate.background != null, city + " background imported")
		check(cinema._shots[cinema._at].ground[0] >= 0.7, city + " feet staged in open foreground")
		check(source == original, city + " original story choices not mutated")
		check(cinema._shots[cinema._at].say == original[cinema._at].say, city + " narration preserved")
		check(not story.holiday_seen(city), city + " opening does not complete celebration")
		await capture("04-celebration-" + city)
		while cinema._open: cinema._advance()
		check(cinema.completed and not paused, city + " celebration completes without leaving a pause")
		check(not story.holiday_seen(city), city + " completion remains the story caller's responsibility")
		if city == "berlin": check(not cinema._plate_key.begins_with("celebration:"), "Berlin goes home after the fair")
	world.queue_free()
	await frames()
	gs.reset()
	gs.city = "mexico"
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	gs.world_flags["airport_transfer"] = "mexico"
	for place: String in ["MexicoAirport", "MexicoJuarez", "MexicoTransit", "MexicoCoyoacan"]:
		change_scene_to_file("res://scenes/world/" + place + ".tscn")
		await frames(20)
		var thought := get_first_node_in_group("thought_box")
		if thought != null and thought.visible: thought._close()
		journey.guide("mexico")
		var log := get_first_node_in_group("quest_log")
		log._tracker_hold = 0.0
		log._banner_t = -1.0
		log._banner.hide()
		log._refresh_tracker()
		await frames(10)
		var text := ""
		for label in log._tracker_box.get_children():
			if label is Label: text += label.text
		if place == "MexicoCoyoacan":
			check("flower rows" in text and not "Take Linea" in text, "at the destination, guidance is local, not another metro ride")
		else:
			check("Viveros/Derechos Humanos" in text and "Coyoacan" in text, place + " tracker names station and district")
		check(log._tracker.get_global_rect().end.y < root.get_visible_rect().size.y, place + " directions fit")
		await capture("05-" + place)
	current_scene.queue_free()
	await frames()
	print("FEEDBACK UI: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
