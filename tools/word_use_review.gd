extends "res://tools/title_review.gd"

var MOMENT: GDScript
const BOOK := preload("res://scenes/ui/Notebook.gd")

func _run() -> void:
	MOMENT = load("res://scenes/world/WordUseMoment.gd")
	out = "res://.build/word-use-review"
	DirAccess.make_dir_recursive_absolute(out)
	var gs := root.get_node("GameState")
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("word-use")
	root.get_node("Loc").set_language("en")
	var covered: Array = []
	for id: String in MOMENT.MOMENTS:
		var city: String = load("res://scenes/world/ActivityPlaces.gd").location(id).city
		if not covered.has(city): covered.append(city)
	check(covered.size() == 8, "every core city has an independent word-use encounter")
	for id: String in MOMENT.MOMENTS:
		gs.reset()
		var data: Dictionary = MOMENT.MOMENTS[id]
		change_scene_to_file("res://scenes/world/activities/" + id + ".tscn")
		await frames(8)
		var use: Node
		for node in current_scene.get_children():
			if node.get_script() == MOMENT: use = node
		check(use != null and is_instance_valid(use.actor), "existing resident wired " + id)
		check(not use.eligible() and not use.actor.talkable, "unknown meaning does not unlock " + id)
		gs.expose(data.language, data.word, "hear")
		check(not use.eligible(), "hearing alone is not understanding")
		gs.understand(data.language, data.word, "A meaning found earlier", "Original encounter")
		await frames()
		check(use.eligible() and use.actor.talkable, "discovery enables optional encounter")
		var before_money: int = gs.money
		var before_inventory: Dictionary = gs.inventory.duplicate(true)
		var cp := get_first_node_in_group("choice_panel")
		var player := get_first_node_in_group("player") as Node2D
		player.global_position = use.actor.global_position + Vector2(0, 42)
		await frames(4)
		check(use.actor.near_player(), "resident can be approached: %s player=%s actor=%s" % [id, player.global_position, use.actor.global_position])
		var interact := InputEventAction.new()
		interact.action = "interact"
		interact.pressed = true
		root.push_input(interact, true)
		interact = InputEventAction.new()
		interact.action = "interact"
		interact.pressed = false
		root.push_input(interact, true)
		await frames()
		check(cp._open and paused, "encounter opens with owned input")
		await capture(id + "-choice")
		cp._close("leave")
		await frames()
		check(not paused and not use._busy and not use.completed(), "decline is recoverable and optional")
		use._interact()
		await frames()
		cp._close("wrong")
		await frames()
		check(cp._open and not use.completed(), "wrong action offers contextual repair")
		cp._close("retry")
		await frames()
		check(cp._open, "retry returns to encounter")
		cp._close(data.correct)
		await frames()
		check(use.completed() and cp._open, "correct action completes before follow-up")
		check(use.actor.holding == data.hold, "resident visibly uses the chosen object")
		var entry: Dictionary = gs.understanding(data.language, data.word)
		check(entry.applications.has(id) and entry.moment == "Original encounter", "new memory keeps original discovery")
		check(not BOOK.apply_in_context(data.language, data.word, id, "duplicate"), "repeat cannot farm application evidence")
		check(gs.money == before_money and gs.inventory == before_inventory, "no spending or fetch requirement")
		cp._close("continue")
		await frames()
		check(not paused and not use._busy and not use.actor.talkable, "completion releases controls")
		check(saves.load_game(-1), "checkpoint with application loads")
		change_scene_to_file(saves.pending_scene)
		await frames(8)
		for node in current_scene.get_children():
			if node.get_script() == MOMENT: use = node
		check(use.completed() and not use.eligible() and use.actor.holding == data.hold, "saved result is durable")
		await capture(id + "-complete")
		gs.world_flags.erase("word_use_" + id)
		use._interact()
		await frames()
		change_scene_to_file("res://scenes/title/TitleScreen.tscn")
		await frames(5)
		check(not paused, "scene departure releases owned choice")
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	await frames()
	_finish()
