extends SceneTree

const SG := preload("res://scenes/world/SceneGraph.gd")
var berlin: GDScript
var gs: Node
var story: Node
var saves: Node
var world: Node2D
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("GUIDANCE EDGE: " + message)

func fresh() -> void:
	gs.reset()
	gs.quests["find_bed"] = {"completed":true, "steps":[]}

func go(city: String) -> void:
	gs.city = city
	gs.current_region = story.person(city)["region"]
	world.scene_file_path = story.path(story.SCENE[city])
	story.guide()

func complete_city(city: String) -> void:
	gs.world_flags["story_rounds_" + city] = 3
	if city == "berlin":
		for chapter: String in ["1", "2", "3", "3b", "4"]:
			berlin.state()["done"][chapter] = true
	story.mark_holiday(city)

func all_cities() -> void:
	fresh()
	for city: String in story.MANDATORY:
		go(city)
		complete_city(city)

func open_legs() -> int:
	var count := 0
	for id: String in gs.quests:
		if id.begins_with("onward_") and not gs.quests[id].completed: count += 1
	return count

func legacy_ending() -> Dictionary:
	return {"title":"You have never had a name", "completed":false,
		"steps":[{"text":"Go back to the field you landed in", "done":false, "target":"res://scenes/world/WreckSite.tscn"},
			{"text":"Ask one of the eight to name you", "done":false, "target":"res://scenes/world/WreckSite.tscn"}]}

func frames(count := 8) -> void:
	for i in range(count): await process_frame

func _run() -> void:
	saves = root.get_node("SaveManager")
	saves.use_test_storage("quest-guidance-edges")
	gs = root.get_node("GameState")
	story = root.get_node("Story")
	berlin = load("res://scenes/story/berlin/BerlinStory.gd")
	world = Node2D.new()
	root.add_child(world)
	current_scene = world
	fresh()
	go("berlin")
	root.get_node("Services").open_job_quest("crates")
	complete_city("berlin")
	var previous_leg: String = gs.tracked_quest_id()
	for city: String in ["tokyo", "paris", "london"]:
		go(city)
		gs.world_flags["story_rounds_" + city] = 1
		story.guide()
		check(gs.tracked_quest_id() == "journey_" + city, city + " local chapter takes priority")
		check(gs.quests[previous_leg].completed, "arrival completes previous travel leg")
		var previous: Dictionary = gs.quests[previous_leg].duplicate(true)
		go("berlin")
		var next_leg: String = gs.tracked_quest_id()
		check(next_leg.begins_with("onward_") and next_leg != previous_leg, "early return opens a new onward leg")
		check(gs.quest_target() == story.path("Airport.tscn"), "early return targets local airport")
		check(not SG.route(world.scene_file_path, gs.quest_target()).is_empty(), "onward guidance is reachable")
		check(gs.quests[previous_leg] == previous, "completed leg stays in history unchanged")
		check(story.rounds_done(city) == 1, "partial story progress survives leaving")
		check(open_legs() == 1, "one active onward leg even with optional work")
		var total: int = gs.quests.size()
		for i in range(5): story.guide()
		check(gs.quests.size() == total and gs.tracked_quest_id() == next_leg, "repeated guidance does not create more legs")
		previous_leg = next_leg
	check(saves.save_game(0), "early-return state saves")
	gs.reset()
	check(saves.load_game(0), "early-return state reloads")
	story.guide()
	check(gs.tracked_quest_id() == previous_leg and open_legs() == 1, "reload retains the existing active leg")
	check(gs.quest_target() == story.path("Airport.tscn"), "reload preserves local guidance")
	go("tokyo")
	complete_city("tokyo")
	var tokyo_leg: String = gs.tracked_quest_id()
	go("berlin")
	check(gs.tracked_quest_id() == tokyo_leg and open_legs() == 1, "finished-city detour reuses the active leg")
	check(gs.quest_target() == story.path("Airport.tscn"), "finished-city detour retargets airport")

	# The opening visit must not count as the final return, even on old saves.
	all_cities()
	gs.region_visits["kiez"] = 1
	gs.quests["the_name"] = legacy_ending()
	go("berlin")
	check(not gs.quests["the_name"].steps[0].done, "legacy opening visit is not a final return")
	check(gs.quest_target() == story.FIELD, "legacy quest in Mitte still directs player to field")
	go("tokyo")
	check(not gs.quests["the_name"].steps[0].done, "airport handoff does not complete field visit")
	check(gs.quest_target() == story.path("TokyoAirport.tscn"), "legacy finale abroad targets local airport")
	# The name itself proves the finale happened, including a previously stuck save.
	for baseline: bool in [false, true]:
		gs.quests["the_name"] = legacy_ending()
		if baseline: gs.quests["the_name"]["field_visits"] = 1
		story.set_namer("tokyo")
		story.guide()
		check(gs.quests["the_name"].completed, "already named save closes all ending steps")
		check(gs.tracked_quest_id() != "the_name", "already named save does not retrack finale")

	# Actually reload the Kiez and use the naming UI, not a simulated visit.
	all_cities()
	gs.city = "berlin"
	gs.current_region = "kiez"
	gs.region_visits["kiez"] = 2
	gs.quests["first_trade"] = {"completed":true, "steps":[]}
	gs.quests["the_name"] = legacy_ending()
	world.scene_file_path = story.FIELD
	check(saves.save_game(0), "legacy finale state saves")
	gs.reset()
	check(saves.load_game(0), "legacy finale loads without corruption")
	change_scene_to_file(saves.pending_scene)
	await frames(12)
	check(gs.region_visits.kiez == 2, "loading did not increment visits")
	check(gs.quests["the_name"].steps[0].done, "loaded player already in field gets naming step without leaving")
	check(not gs.quests["the_name"].completed, "field visit alone does not finish naming")
	var naming := get_first_node_in_group("naming")
	naming.play("tokyo")
	naming._process(3.0)
	naming._advance()
	naming._advance()
	check(gs.world_flags.get("ending_seen", false), "real naming sequence completes")
	check(gs.quests["the_name"].completed, "real naming closes legacy finale")
	check(gs.tracked_quest_id() != "the_name", "completed game no longer requests a field return")
	check(saves.load_game(-1), "naming checkpoint reloads")
	check(gs.quests["the_name"].completed and story.namer() == "tokyo", "checkpoint retains completed finale and name")
	print("QUEST GUIDANCE EDGES: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)
