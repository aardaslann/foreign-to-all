extends SceneTree

const WORD_BG := "#514677"
var checks := 0
var failures := 0
var out := ""

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("WORD AFFORDANCE: " + message)

func frames(count := 3) -> void:
	for i in range(count): await process_frame

func capture(name: String) -> void:
	if out.is_empty() or DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name + ".png"))

func boxed(text: String, word: String) -> bool:
	return text.contains("[url=" + word + "]") and text.contains("[bgcolor=" + WORD_BG + "]")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out = args[0]
		DirAccess.make_dir_recursive_absolute(out)
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("word-affordance")
	var gs := root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	await frames(8)
	var dlg := get_first_node_in_group("dialogue_box")
	check(dlg._text_label.get_theme_constant("text_highlight_h_padding") == 0,
		"word backgrounds do not bleed across the spaces between boxes")
	var languages := {
		"berlin":["german", "und"], "istanbul":["turkish", "ve"],
		"paris":["french", "et"], "moscow":["russian", "i"],
		"mumbai":["hindi", "aur"], "tokyo":["japanese", "to"],
		"mexico":["spanish_mx", "y"]}
	for city: String in languages:
		gs.city = city
		var lang: String = languages[city][0]
		var word: String = languages[city][1]
		var entry := {"words":[{"text":word, "word":word, "language":lang}],
			"responses":[{"gesture":"Listen"}]}
		dlg.show_dialogue([entry], "Neighbour", "", Color.WHITE)
		await frames()
		check(gs.get_tier(lang, word) < gs.TIER_PARTIAL, lang + " first exposure is not readable")
		check(not dlg._text_label.get_parsed_text().contains(word), lang + " hinted word starts as glyphs")
		check(not dlg._text_label.text.contains("[url="), lang + " glyph has no premature hover meaning")
		check(not gs.word_guess(lang, word).contains("still a question"), lang + " useful hint is retained")
		while gs.get_tier(lang, word) < gs.TIER_PARTIAL: gs.expose(lang, word, "hear")
		check(boxed(dlg._render_words(entry.words), word), lang + " repeated word gets a purple hover box")
		check(gs.understanding(lang, word).is_empty(), lang + " readability is not earned meaning")
		dlg._close()
	gs.city = "berlin"
	for underline: bool in [false, true]:
		saves.settings["highlight_partial_words"] = underline
		for tier: int in [gs.TIER_PARTIAL, gs.TIER_KNOWN]:
			for word: String in ["und", "xylophon"]:
				check(boxed(dlg._render_word(word, word, tier, false), word),
					"all readable words stay boxed: %s tier %d underline %s" % [word, tier, underline])
		check(not dlg._render_word("und", "und", gs.TIER_GLIMPSED, false).contains("[url="),
			"glimpsed hints remain glyphs")
		check(not dlg._render_word("und", "und", gs.TIER_UNKNOWN, true).contains("[url="),
			"flickering hints remain glyphs")
	gs.understand("german", "pfand", "deposit on a returnable bottle", "Kerstin")
	var found: String = dlg._render_words([{"text":"Pfand.", "word":"pfand", "language":"german"}])
	check(boxed(found, "pfand") and found.contains(dlg.FOUND_CLR), "found word keeps gold letters and purple box")
	dlg._targets = {"anfassen":true}
	var target: String = dlg._render_words([{"text":"Anfassen?", "word":"anfassen", "language":"german"}])
	check(boxed(target, "anfassen") and target.contains(dlg.TARGET_CLR), "active word keeps amber letters and purple box")
	check(target.count("[bgcolor=") == 1, "active word has one consistent box, not nested backgrounds")
	gs.city = "london"
	check(boxed(dlg._render_english("and", "and", gs.TIER_UNKNOWN), "and"), "English stays readable and hoverable")
	gs.understand("english", "alright", "a greeting", "Nadia")
	check(boxed(dlg._render_english("alright", "alright", gs.TIER_KNOWN), "alright"), "found English also stays boxed")
	gs.city = "berlin"
	saves.settings["highlight_partial_words"] = false
	gs.familiarity.german["und"] = 80
	gs.familiarity.german["die"] = 50
	gs.familiarity.german["flaschen"] = 80
	gs.familiarity.german["xylophon"] = 80
	var line := {"words":[{"text":"Die", "word":"die", "language":"german"},
		{"text":"Flaschen", "word":"flaschen", "language":"german"},
		{"text":"und", "word":"und", "language":"german"},
		{"text":"Pfand.", "word":"pfand", "language":"german"},
		{"text":"Anfassen?", "word":"anfassen", "language":"german"},
		{"text":"Donnerwetter!", "word":"donnerwetter", "language":"german"}],
		"stage":"Kerstin lifts one end of the crate and waits.", "keep":true, "in_world":true,
		"responses":[{"gesture":"Take the other end", "confirm":{"anfassen":"take hold of"}}]}
	for size: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 768)]:
		root.size = size
		saves.settings["text_size"] = 2
		dlg.show_dialogue([line], "Kerstin", "", Color.WHITE, false)
		await frames(5)
		check(dlg._text_label.get_content_width() <= dlg._text_label.size.x + 1, "boxed words fit at " + str(size))
		await capture("words-" + str(size.x))
	dlg._text_label.meta_hover_started.emit("und")
	await frames()
	check(dlg._tooltip.visible and dlg._tooltip_guess.text.contains("and"), "readable connector hover shows useful meaning")
	await capture("hover-meaning")
	dlg._text_label.meta_hover_ended.emit("und")
	check(not dlg._tooltip.visible, "hover exit hides meaning")
	dlg._text_label.meta_hover_started.emit("pfand")
	check(dlg._tooltip.visible and dlg._tooltip_guess.text.contains("you worked out"), "found meaning remains distinguished")
	dlg._text_label.meta_hover_ended.emit("pfand")
	dlg._text_label.meta_hover_started.emit("xylophon")
	check(dlg._tooltip.visible, "readable word without authored hint still has a notebook tooltip")
	dlg._close()
	world.queue_free()
	await frames()
	print("WORD AFFORDANCE: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
