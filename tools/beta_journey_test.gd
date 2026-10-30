extends SceneTree

const DATA := preload("res://scenes/story/CityChapters.gd")
const SS := preload("res://scenes/world/Streetside.gd")
var failures := 0
var checks := 0
var gs: Node
var story: Node
var journey: Node
var choices: AutoChoice
var cinema: AutoCinema

class AutoChoice extends Node:
	signal chosen(id: String)
	var branch := 0
	var calls := 0
	var cancel_at := -1
	var visits: Dictionary = {}
	func open(_title: String, _text: String, rows: Array) -> void:
		calls += 1
		var key: String = _title + JSON.stringify(rows)
		visits[key] = int(visits.get(key, 0)) + 1
		var index: int = mini(branch, rows.size() - 1)
		if int(visits[key]) > 1 and rows.size() > 1:
			index = rows.size() - 1
		var id: String = "" if calls == cancel_at else String(rows[index]["id"])
		chosen.emit.call_deferred(id)

class AutoCinema extends Node:
	signal finished
	var completed := true
	var cancel_next := false
	var shots_seen := 0
	func play(_city: String, shots: Array) -> void:
		shots_seen += shots.size()
		completed = not cancel_next
		cancel_next = false
		finished.emit.call_deferred()

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("BETA: " + message)

func fresh(city: String) -> void:
	gs.reset()
	gs.city = city
	gs.current_region = story.person(city)["region"]
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	choices.calls = 0
	choices.cancel_at = -1
	choices.visits.clear()

func _run() -> void:
	root.get_node("SaveManager").use_test_storage("beta_journey_test")
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	gs = root.get_node("GameState")
	story = root.get_node("Story")
	journey = root.get_node("Journey")
	choices = AutoChoice.new()
	choices.add_to_group("choice_panel")
	root.add_child(choices)
	cinema = AutoCinema.new()
	cinema.add_to_group("cutscene")
	root.add_child(cinema)
	var services: Node = root.get_node("Services")
	check(DATA.CITIES.size() == 8, "exactly eight complete city packs")
	for city: String in story.MANDATORY:
		var pack: Dictionary = DATA.CITIES[city]
		check(journey.rebuilt(city), city + " uses the staged discovery story")
		check(ResourceLoader.exists(story.path(story.SCENE[city])), city + " friend scene exists")
		for outing: Array in pack["outings"]:
			check(ResourceLoader.exists(story.path(outing[1])), city + " outing exists: " + String(outing[1]))
			var activity: Dictionary = SS.spot(city, outing[0])
			check(not activity.is_empty(), city + " activity exists: " + String(outing[0]))
			if activity.is_empty():
				continue
			var beats: Dictionary = activity["beats"]
			for id: String in beats:
				var beat: Dictionary = beats[id]
				var rendered: Dictionary = SS.render_beat(beat, id, {})
				check(JSON.parse_string(JSON.stringify(rendered)) is Dictionary, city + " serializable staging")
				for row: Dictionary in beat.get("rows", []):
					var to: String = row.get("to", "")
					check(to.is_empty() or beats.has(to), city + ":" + id + " valid choice destination")
				for to: String in beat.get("toss", []):
					check(beats.has(to), city + ":" + id + " valid chance destination")
		for branch in range(2):
			fresh(city)
			choices.branch = branch
			check(story.can_meet(city), city + " friend visible with zero vocabulary")
			journey.ensure_funds(gs.room_price() + gs.transit_fare() + gs.flight_fare())
			check(gs.money >= gs.room_price() + gs.transit_fare() + gs.flight_fare(), city + " essential costs funded")
			for dest: String in story.MANDATORY:
				check(services._flight_block(dest).is_empty(), city + " travel to " + dest + " has no work/fluency/sleep gate")
			# Real staged dialogue, movement, awards and interruption are exercised
			# by the city harnesses. This harness owns the shared activity gates.
			gs.world_flags["story_rounds_" + city] = 1
			check(journey.ready_for_round(city) == (journey.OUTING_PLAN[city][0] == 0), city + " reflection follows its city-specific rhythm")
			for i in range(pack["outings"].size()):
				var outing: Array = pack["outings"][i]
				gs.current_region = outing[0]
				await journey.play_activity()
				check(bool(gs.world_flags.get("spot_" + String(outing[0]), false)), city + " activity completes: " + String(outing[0]))
				if i == 0:
					check(journey.ready_for_round(city), city + " first experience opens reflection")
					gs.world_flags["story_rounds_" + city] = 2
					check(journey.ready_for_round(city) == (journey.OUTING_PLAN[city][1] <= 1 and story.errand_done(city)), city + " personal discovery, not a universal quota, opens friendship")
				if i >= 2:
					check(journey.ready_for_round(city) == story.errand_done(city), city + " friendship needs distinct activities and friend's district")
			if city != "berlin":
				check(journey.ready_for_round(city), city + " all experiences release friendship gate")
			else:
				# Berlin's delivery to Emil is its own played street encounter.
				check(not story.errand_done(city), "Berlin activities cannot replace delivering Emil's message")
			var money: int = gs.money
			gs.current_region = pack["outings"][0][0]
			await journey.play_activity()
			check(gs.money == money, city + " revisiting cannot farm rewards")
	# Cancel an actual activity choice, save, reload and resume it. The storage
	# override above covers both manual slot 4 and the automatic checkpoint.
	fresh("berlin")
	gs.current_region = "mitte"
	choices.branch = 0
	choices.cancel_at = 1
	await journey.play_activity()
	check(not bool(gs.world_flags.get("spot_mitte", false)), "cancelled choice does not complete activity")
	var sm: Node = root.get_node("SaveManager")
	sm.save_game(4)
	var saved_flags: Dictionary = gs.world_flags.duplicate(true)
	gs.reset()
	check(sm.load_game(4), "isolated activity save reloads")
	check(gs.world_flags == JSON.parse_string(JSON.stringify(saved_flags)), "activity cursor and applied effects survive JSON")
	choices.cancel_at = -1
	await journey.play_activity()
	check(bool(gs.world_flags.get("spot_mitte", false)), "cancelled activity choice resumes")
	fresh("berlin")
	gs.current_region = "mitte"
	cinema.cancel_next = true
	await journey.play_activity()
	check(not bool(gs.world_flags.get("spot_mitte", false)), "cancelled cinema does not complete activity")
	await journey.play_activity()
	check(bool(gs.world_flags.get("spot_mitte", false)), "cancelled cinema resumes")
	# Whole eight-city ending, including progress retained by older saves.
	for city: String in story.MANDATORY:
		gs.city = city
		gs.world_flags["story_rounds_" + city] = 3
		story.mark_holiday(city)
	check(story.can_end(), "all eight holidays open the naming ending")
	check(gs.quests.has("the_name"), "ending supplies a destination")
	check(not services._flight_block("sydney").is_empty(), "optional cities visibly outside beta")
	print("BETA JOURNEY: ", checks, " checks, ", failures, " failures; ", cinema.shots_seen, " staged shots traversed")
	quit(1 if failures else 0)
