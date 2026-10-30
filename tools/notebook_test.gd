extends SceneTree

# The notebook and the three moments that make a word stick (scenes/ui/
# Notebook.gd, DialogueBox): a target marked while he decides, the decode when
# his reading is borne out, a found word recognised later somewhere new - and
# no notification at all for words that only went past him.
#
# Run: godot --path . --script res://tools/notebook_test.gd [-- <capture dir>]
# Headless runs check; a windowed run with a directory also saves captures.

var checks := 0
var failures := 0
var gs: Node
var notebook: Script


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("NOTEBOOK: " + message)


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("notebook")
	gs = root.get_node("GameState")
	notebook = load("res://scenes/ui/Notebook.gd")
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else ""
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(8):
		await process_frame
	var journal := get_first_node_in_group("journal")
	var dlg := get_first_node_in_group("dialogue_box")

	# Overheard filler: readable in time, never a notification, never "noticed".
	var before: int = journal._toasts.size()
	for n in range(6):
		for w in ["die", "und", "ja", "hier"]:
			gs.expose("german", w, "hear")
	check(journal._toasts.size() == before, "overheard words raise no notification")
	check(not notebook.noticed("german", "die"), "hearing alone is not noticing")
	check(gs.get_tier("german", "die") >= gs.TIER_PARTIAL, "overheard words still become readable")
	gs.expose("german", "pfand", "pointed")
	check(notebook.noticed("german", "pfand"), "being shown a word is noticing it")

	# A target is marked while he decides; the right reading decodes it.
	var entry := {"words": [{"text": "Na?", "word": "na", "language": "german"},
			{"text": "Kannste", "word": "kannste", "language": "german"},
			{"text": "anfassen?", "word": "anfassen", "language": "german"}],
		"stage": "She lifts one end of a crate.", "keep": true, "in_world": true,
		"responses": [{"gesture": "Take hold of the other end", "go": "carry",
			"confirm": {"anfassen": "take hold of - lend a hand"}},
			{"gesture": "Step back", "misread": {"anfassen": "get out of the way"}}]}
	dlg.show_dialogue([entry], "Kerstin", "", Color(0.4, 0.4, 0.5))
	await _frames(4)
	check(dlg._targets.has("anfassen"), "the word being worked out is marked")
	check(dlg._text_label.text.contains(dlg.WORD_BG) and dlg._text_label.text.contains(dlg.TARGET_CLR), "the boxed amber word is visible in the line")
	check(dlg._text_label.text.contains("anfassen?"), "the marked word is spelled out, not glyphs")
	await _capture(out, "1-target")
	dlg._on_response(entry["responses"][0])
	await _frames(3)
	var discovery := get_first_node_in_group("word_discovery")
	if discovery != null and discovery._open:
		discovery.reveal()
		await _frames(3)
	await _capture(out, "2-reveal")
	if discovery != null and discovery._open:
		discovery._process(0.25)
		discovery._advance()
	var waited := 0
	while dlg.visible and waited < 600:
		waited += 1
		await process_frame
	check(not dlg.visible, "the decode ends and the exchange closes")
	check(notebook.found("german", "anfassen"), "the confirmed reading is found")
	check(dlg._render_words(entry["words"]).contains("anfassen?"), "a found word reads as letters")

	# Words heard for the first time flicker, but the line never moves: every
	# frame is exactly as wide as the last, and as the glyphs it settles into.
	var fresh := {"words": [{"text": "Feierabend", "word": "feierabend", "language": "german"},
			{"text": "Quatsch,", "word": "quatsch", "language": "german"},
			{"text": "Donnerwetter!", "word": "donnerwetter", "language": "german"}],
		"responses": [{"gesture": "Nod"}]}
	var settings: Dictionary = root.get_node("SaveManager").settings
	for simple: bool in [false, true]:
		settings["simplified_glyph_set"] = simple
		var glyph_set: String = "simplified glyphs" if simple else "glyphs"
		dlg.show_dialogue([fresh], "Kerstin", "", Color(0.4, 0.4, 0.5), false)
		await _frames(3)
		check(dlg._has_anim_words, "first-time words flicker (%s)" % glyph_set)
		var widths := {}
		var frames := {}
		for i in range(24):
			dlg._text_label.text = dlg._compose(dlg._current_words)
			await process_frame
			widths[dlg._text_label.get_content_width()] = true
			frames[dlg._text_label.text] = true
		dlg._animating_words.clear()
		dlg._text_label.text = dlg._compose(dlg._current_words)
		await process_frame
		widths[dlg._text_label.get_content_width()] = true
		check(widths.size() == 1, "the flickering line never changes width (%s): %s" % [glyph_set, widths.keys()])
		check(frames.size() > 1, "the flicker still changes glyphs (%s)" % glyph_set)
		dlg._close()
	settings["simplified_glyph_set"] = false

	# Met again, later, somewhere else: recognised once per sentence.
	gs.play_time += 120.0
	var later := {"words": [{"text": "Hier.", "word": "hier", "language": "german"},
			{"text": "Anfassen.", "word": "anfassen", "language": "german"}],
		"responses": [{"gesture": "Lift"}]}
	dlg.show_dialogue([later], "Kerstin", "", Color(0.4, 0.4, 0.5))
	await _frames(4)
	check(dlg._recognised.visible and dlg._recognised.text.contains("take hold"), "a found word said again is recognised in the box")
	check(notebook.recalled("german", "anfassen") == 1, "recognition is counted")
	await _capture(out, "3-recognised")
	dlg._close()
	check(not notebook.recall("german", "anfassen", "Kerstin|Hier. Anfassen."), "the same sentence is not a second recognition")
	check(notebook.recall("german", "anfassen", "street|Anfassen, bitte."), "a new sentence is")

	# The notebook, sorted by what he did.
	var s: Dictionary = notebook.sections("german")
	check(s["found"].size() == 1 and s["found"][0]["word"] == "anfassen", "found section")
	check(s["noticed"].size() == 1 and s["noticed"][0]["word"] == "pfand", "noticed section")
	check(s["by_ear"].size() >= 3, "by-ear section holds the readable filler")
	await _frames(20)
	journal._open()
	await _frames(6)
	await _capture(out, "4-notebook")
	journal._close()

	# Toasts: a fixed width, on screen, whatever the text.
	journal.toast_understood("german", "kuckucksuhr", "a clock with a bird in it, which she says she looks like, at considerable length and more than once")
	await _frames(20)
	for toast: Dictionary in journal._toasts:
		var p: Control = toast["p"]
		check(p.size.x <= journal.TOAST_W + 1.0 and p.position.x >= 8.0 and p.size.y <= 96.0, "toast stays small and on screen")
	await _capture(out, "5-toast")

	world.queue_free()
	await process_frame
	print("NOTEBOOK: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)


func _frames(n: int) -> void:
	for i in range(n):
		await process_frame


func _capture(out: String, label: String) -> void:
	if out.is_empty() or DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(label + ".png"))
