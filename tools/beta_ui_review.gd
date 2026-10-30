extends SceneTree

var gs: Node
var journey: Node
var cp: Node
var journal: Node
var failures := 0
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/review"

func _initialize() -> void:
	_run.call_deferred()

func frame(path: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + path + ".png")

func _run() -> void:
	root.get_node("SaveManager").use_test_storage("beta_ui_review")
	DirAccess.make_dir_recursive_absolute(out)
	gs = root.get_node("GameState")
	journey = root.get_node("Journey")
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var world: Node = load("res://scenes/world/BerlinPrenzlberg.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(10):
		await process_frame
	cp = get_first_node_in_group("choice_panel")
	journal = get_first_node_in_group("journal")
	for city: String in ["berlin", "istanbul", "mumbai", "tokyo"]:
		gs.city = city
		var entry: Dictionary = journey.CHAPTERS.CITIES[city]["chapters"][0][0]
		var phrase: Array = entry["phrase"]
		var rows: Array = []
		for i in range(entry["choices"].size()):
			rows.append({"id": str(i), "label": entry["choices"][i][0]})
		cp.open(entry["title"], entry["text"] + "\n\n" + String(phrase[0]) + " · " + String(phrase[1]) + "\n" + String(phrase[2]), rows)
		await frame(city + "-choice")
		if root.gui_get_focus_owner() == null:
			failures += 1
		cp._close("")
		journey.learn(city, phrase, "visual-review")
		journey.ledger()["memories"][city] = entry["choices"][0][1]
	gs.city = "berlin"
	for page: String in ["Journey", "Phrases", "Memories"]:
		journal._page = page
		journal._open()
		await frame("journal-" + page)
		journal._close()
	# Real UI input guard: cancelling the chooser must not open Pause over it.
	cp.open("An interrupted conversation", "Escape should return to the world.", [{"id": "ok", "label": "Continue"}])
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	root.push_input(escape)
	await process_frame
	if paused or bool(cp.get("_open")):
		failures += 1
	# Check the new save location twice, then load it through the real manager.
	var save: Node = root.get_node("SaveManager")
	save.checkpoint()
	journey.ledger()["test"] = 123
	save.checkpoint()
	if not save.load_game(-1) or journey.ledger().get("test", 0) != 123:
		failures += 1
	print("BETA UI: ", failures, " failures; screenshots ", out)
	quit(1 if failures else 0)
