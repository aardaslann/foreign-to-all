extends "res://tools/title_review.gd"

var BOOK: Script

func _run() -> void:
	BOOK = load("res://scenes/ui/Notebook.gd")
	out = "res://.build/player-experience-review"
	DirAccess.make_dir_recursive_absolute(out)
	var gs := root.get_node("GameState")
	root.get_node("SaveManager").use_test_storage("player-experience")
	gs.reset()
	change_scene_to_file("res://scenes/world/activities/ActivityBerlinSpati.tscn")
	await frames(8)
	var pickup := get_first_node_in_group("pickup")
	var use: Node
	for node in current_scene.get_children():
		if node.get_script() == load("res://scenes/world/WordUseMoment.gd"): use = node
	check(not use.eligible(), "Rika waits for a real discovery")
	root.get_node("Items").learn("apple")
	check(not BOOK.found("german", "apfel"), "exposure alone is not a confirmed meaning")
	pickup.play("apple")
	check(BOOK.found("german", "apfel") and use.eligible(), "the actual apple reveal unlocks Rika")
	check(pickup.showing and paused, "first object discovery gets its reveal")
	pickup._close()
	var count: int = gs.inventory.get("apple", 0)
	pickup.play("apple")
	check(not pickup.showing and not paused, "repeat pickup does not interrupt walking")
	check(gs.inventory.get("apple", 0) == count + 1, "repeat pickup is awarded exactly once")
	pickup._close()
	check(BOOK.has_method("evidence_label"), "notebook has evidence-based labels")
	if BOOK.has_method("evidence_label"):
		check(BOOK.evidence_label("german", "apfel") == "Meaning found", "meaning is distinct from familiarity")
		BOOK.apply_in_context("german", "apfel", "test", "Packed lunch")
		check(BOOK.evidence_label("german", "apfel") == "Used elsewhere", "application is a distinct step")
	var ss := load("res://scenes/world/Streetside.gd")
	check(ss.has_method("decision_text"), "activities separate decisions from filmed narration")
	if ss.has_method("decision_text"):
		check(ss.decision_text({"text":"Already shown", "film":[{}]}, true) != "Already shown", "filmed prose is not repeated")
		check(ss.decision_text({"text":"New information"}, false) == "New information", "unfilmed prose remains readable")
	var journey := root.get_node("Journey")
	gs.world_flags["story_rounds_moscow"] = 1
	check(journey.ready_for_round("moscow"), "Moscow's first two conversations can share a visit")
	gs.world_flags["story_rounds_mexico"] = 1
	check(journey.ready_for_round("mexico"), "Mexico's family memory does not wait on a sightseeing quota")
	gs.world_flags["story_rounds_london"] = 2
	gs.world_flags["spot_highstreet"] = true
	check(journey.ready_for_round("london"), "London can continue after its requested caff visit")
	var naming := get_first_node_in_group("naming")
	journey.ledger().memories["berlin"] = "A bag brought to Emil, a place kept for me."
	naming.play("berlin")
	check(naming._line.text.contains(naming.TEMPERATURE.berlin), "a saved memory does not overwrite the name's meaning")
	check(naming.get("_stage") != null, "the naming scene stages the friend and customized alien")
	naming._close()
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	await frames()
	_finish()
