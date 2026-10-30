extends SceneTree

# The quest guidance between cities and at the end, from the beta readiness
# review of 2026-10-03 (docs/beta-readiness-review-2026-10-03.md):
#   1. after a city, the log names no single next country, and its arrow aims
#      at the airport of the city the player is actually in;
#   2. the ending leads back through the local airport to Berlin's field,
#      which is the Kiez - a scene the route graph can reach;
#   3. an optional job left unfinished never hides the ending or the way on.
# Built from the earlier quest_flow_probe, with each observation made a check.

const SG := preload("res://scenes/world/SceneGraph.gd")
var berlin: GDScript
var gs: Node
var story: Node
var services: Node
var world: Node2D
var checks := 0
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("QUEST GUIDANCE: " + description)


func fresh() -> void:
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}


func go(city: String) -> void:
	gs.city = city
	world.scene_file_path = story.path(story.SCENE[city])
	gs.current_region = story.person(city)["region"]
	story.guide()


func complete_city(city: String) -> void:
	gs.world_flags["story_rounds_" + city] = 3
	if city == "berlin":
		for chapter: String in ["1", "2", "3", "3b", "4"]:
			berlin.state()["done"][chapter] = true
	story.mark_holiday(city)
	story.guide()


func tracked() -> Dictionary:
	return gs.quests.get(gs.tracked_quest_id(), {})


func step_text(i: int) -> String:
	return String(tracked().get("steps", [{}, {}])[i].get("text", ""))


func reachable() -> bool:
	return not SG.route(world.scene_file_path, gs.quest_target()).is_empty()


func open_named_flights() -> int:
	var n := 0
	for id: String in gs.quests:
		if id.begins_with("on_to_") and not bool(gs.quests[id].get("completed", false)):
			n += 1
	return n


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("quest-guidance")
	gs = root.get_node("GameState")
	story = root.get_node("Story")
	services = root.get_node("Services")
	berlin = load("res://scenes/story/berlin/BerlinStory.gd")
	world = Node2D.new()
	root.add_child(world)
	current_scene = world

	# 1. Onward travel names every city still waiting, from the local airport.
	fresh()
	go("berlin")
	complete_city("berlin")
	var first_leg: String = gs.tracked_quest_id()
	check(first_leg.begins_with("onward_"), "after Berlin the thread is the journey onward, not %s" % first_leg)
	check(open_named_flights() == 0, "no quest names one country as the next chapter")
	check(step_text(1).contains("London") and step_text(1).contains("Tokyo"),
		"the onward step names the cities still waiting: %s" % step_text(1))
	check(gs.quest_target() == story.path("Airport.tscn"), "in Berlin the arrow aims at Berlin's airport")
	check(reachable(), "Berlin's airport is reachable from Mitte")
	go("tokyo")
	check(bool(gs.quests[first_leg].get("completed", false)), "landing in an unfinished city completes the leg")
	check(gs.tracked_quest_id() == "journey_tokyo", "Tokyo's own story follows a flight the log never suggested")
	complete_city("tokyo")
	var second_leg: String = gs.tracked_quest_id()
	check(second_leg.begins_with("onward_") and second_leg != first_leg, "a new leg opens after Tokyo")
	check(not step_text(1).contains("Tokyo"), "a finished city is no longer listed")
	check(gs.quest_target() == story.path("TokyoAirport.tscn"), "after a detour the arrow aims at Tokyo's airport, not Berlin's")
	check(reachable(), "Tokyo's airport is reachable from Ueno")
	go("berlin")
	check(gs.quest_target() == story.path("Airport.tscn"), "back in a finished Berlin, the same leg re-aims at Berlin's airport")

	# Saves from before this change: a named flight is retired, not followed.
	fresh()
	gs.start_quest("on_to_london", "London cannot hear you yet", ["Get to the airport", "Fly to London"],
		[story.path("Airport.tscn"), story.path("Airport.tscn")])
	go("berlin")
	complete_city("berlin")
	check(open_named_flights() == 0, "an old save's named flight is closed")
	check(gs.tracked_quest_id().begins_with("onward_"), "an old save follows the journey onward")

	# 2. The ending leads home through the local airport, then to the Kiez.
	fresh()
	for city: String in story.MANDATORY:
		go(city)
		complete_city(city)
	check(story.can_end(), "all eight celebrations unlock the ending")
	go("tokyo")
	check(gs.tracked_quest_id() == "the_name", "the ending is the thread")
	check(step_text(0).contains("Berlin"), "the first step says the field is in Berlin")
	check(gs.quest_target() == story.path("TokyoAirport.tscn"), "outside Berlin the ending starts at the local airport")
	check(reachable(), "that airport is reachable")
	go("berlin")
	check(gs.quest_target() == story.path("Kiez.tscn"), "in Berlin the ending aims at the Kiez, where the pod lies")
	check(reachable(), "the Kiez is reachable from Mitte")
	check(not bool(gs.quests["the_name"]["steps"][0].get("done", false)), "the opening's visit to the field does not count as going back")
	gs.visit_region("kiez")
	check(bool(gs.quests["the_name"]["steps"][0].get("done", false)), "standing in the field again completes the first step")

	# 3. An optional job never sits over the ending or the way onward.
	fresh()
	go("berlin")
	gs.accept_job("crates")
	services.open_job_quest("crates")
	check(gs.quests.has("job_crates"), "the optional job is in the log")
	complete_city("berlin")
	check(gs.tracked_quest_id().begins_with("onward_"), "the way onward outranks an unfinished job")
	for city: String in story.MANDATORY:
		go(city)
		complete_city(city)
	go("mexico")
	check(gs.tracked_quest_id() == "the_name", "the ending outranks an unfinished job")
	check(gs.quests.has("job_crates") and not bool(gs.quests["job_crates"].get("completed", false)),
		"the job stays open in the log")

	print("QUEST GUIDANCE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
