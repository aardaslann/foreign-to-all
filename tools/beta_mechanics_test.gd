extends SceneTree

var gs: Node
var sm: Node
var dlg: Node
var completed := false
var failures := 0
var checks := 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("BETA MECHANICS: " + message)


func _run() -> void:
	sm = root.get_node("SaveManager")
	gs = root.get_node("GameState")
	sm.use_test_storage("beta-mechanics")
	dlg = load("res://scenes/dialogue/DialogueBox.tscn").instantiate()
	root.add_child(dlg)
	var counters: Script = load("res://scenes/dialogue/CounterEncounter.gd")
	gs.reset()
	check(gs.phrase_for({"gesture": "Step back, out of her way"}) == "Step back, out of her way", "English gesture cannot be mistaken for unknown German")
	gs.expose("german", "pfand", "hear")
	check(not gs.word_guess("german", "pfand").contains("deposit"), "hearing does not disclose the glossary")
	gs.misunderstand("german", "pfand", "a bottle company")
	var before: int = gs.get_familiarity("german", "pfand")
	gs.misunderstand("german", "pfand", "a bottle company")
	check(gs.get_familiarity("german", "pfand") == before, "same first guess cannot farm exposure")
	gs.understand("german", "pfand", "deposit", "the bottle and the coin")
	check(gs.word_guess("german", "pfand").contains("deposit"), "demonstration reveals meaning")
	check(gs.first_guess("german", "pfand") == "a bottle company", "notebook retains original misunderstanding")
	var journey := root.get_node("Journey")
	journey.learn("berlin", ["Hilfst du mir?", "", "Can you help me?", ["hilfst"]], "test-reading")
	var notes: Dictionary = gs.world_flags["word_observations"]["german"]["hilfst"]
	check(notes.get("hear", 0) == 1 and not notes.has("used") and not notes.has("pointed"), "chapter reading grants hearing only")
	for city: String in counters.LINES:
		for route in range(3):
			gs.reset()
			gs.city = city
			gs.current_region = root.get_node("Story").person(city)["region"]
			gs.world_flags["has_map"] = true
			gs.money = 0
			await counter("room", route)
			check(gs.room_booked_here() == (route != 2), city + " room completion follows choice")
			check(gs.money >= 0, city + " booking never requires earning money")
			var word: String = counters.LINES[city][1]
			check(gs.understanding(gs.local_language(), word).has("meaning") == (route != 2), city + " room meaning follows receiving the key")
			if route == 1:
				check(gs.understanding(gs.local_language(), word).has("first"), city + " mistaken room request is repairable")
			gs.money = 0
			await counter("ticket", route)
			check(gs.has_item("ticket_ubahn") == (route != 2), city + " ticket available immediately after purchase")
			check(gs.money >= 0, city + " travel never overdraws a pocket")
			if route == 2:
				check(gs.money == 0, city + " cancelling spends nothing and does not refill wallet")
			else:
				var paid: int = gs.money
				await counter("ticket", route)
				check(gs.money == paid, city + " already-held ticket is not purchased again")
	# Restore person-specific feedback in every beta city, preserving boundaries.
	for city: String in counters.LINES:
		gs.reset()
		gs.city = city
		gs.current_region = root.get_node("Story").person(city)["region"]
		var options := [{"gesture": "Accept", "style": "direct", "rep": 1},
			{"gesture": "Decline", "style": "formal", "rep": 0}]
		var prepared: Array = dlg._prepare(options)
		check(prepared.all(func(x): return int(x.get("rep", 0)) >= 0), city + " no invented country-wide losing answer")
		dlg.show_dialogue([{"silent": true, "words": [], "responses": [{"gesture": "No, thank you", "ritual": "decline", "rep": -3}]}], "A host", "", Color.WHITE, true, gs.current_region)
		dlg._on_response(dlg._entries[0]["responses"][0])
		check(gs.city_reputation() == 0, city + " genuine refusal never costs standing")
	gs.reset()
	gs.city = "berlin"
	gs.current_region = "mitte"
	dlg.show_dialogue([{"silent": true, "words": [], "responses": [{"gesture": "Point at the bread"}]}], "A person", "", Color.WHITE)
	dlg._on_response(dlg._entries[0]["responses"][0])
	check(not Dictionary(gs.world_flags.get("word_observations", {}).get("german", {})).has("brot"), "pointing is not recorded as speaking")
	# Feedback files stay beneath the same throwaway root as saves and settings.
	var telemetry := root.get_node("BetaSession")
	sm.settings["beta_session_notes"] = false
	check(not telemetry.report("test").has("session_seconds"), "timing excluded without opt-in")
	var path: String = telemetry.export_report("I misunderstood the ticket.")
	check(path.begins_with(ProjectSettings.globalize_path(sm.storage_dir)), "feedback export isolated from real saves")
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	check(report["note"] == "I misunderstood the ticket." and not report.has("wallet"), "report contains submitted context, not a save dump")
	var feedback: Control = load("res://scenes/ui/BetaFeedback.gd").new()
	root.add_child(feedback)
	await process_frame
	feedback._note.text = "A useful mistake"
	feedback._save()
	check(not feedback._path.is_empty(), "feedback UI exports successfully")
	feedback.queue_free()
	var audio := root.get_node("AudioManager")
	var review: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/beta-language-review/spoken-lines.json"))
	for row: Dictionary in review["lines"]:
		check(audio.has_voice(row["voice"], row["text"]), "speech exists: " + row["voice"] + " / " + row["text"])
		check(audio.voice_seconds(row["voice"], row["text"]) > 0.1, "speech decodes: " + row["text"])
	audio.say("counter_london", "A room?")
	check(audio.say("missing", "This has never been recorded.") == 0.0 and not audio.voice_playing(), "unrecorded line never reuses stale speech")
	check(audio.replay() == 0.0, "replay does not play a different line")
	dlg.queue_free()
	await process_frame
	print("BETA MECHANICS: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)


func counter(kind: String, route: int) -> void:
	completed = false
	start_counter(kind)
	var turn := 0
	var frames := 0
	while not completed and frames < 150:
		frames += 1
		await process_frame
		if not dlg.visible:
			continue
		var options: Array = dlg._entries[dlg._index]["responses"]
		var choice: String = "leave" if route == 2 else ("repair" if route == 1 and turn == 0 else "one")
		for option: Dictionary in options:
			if option.get("choice", "") == choice:
				dlg._on_response(option)
				turn += 1
				break
	check(completed, kind + " counter returns control")


func start_counter(kind: String) -> void:
	var services := root.get_node("Services")
	if kind == "room":
		await services._hotel_desk()
	else:
		await services._ubahn_ticket()
	completed = true
