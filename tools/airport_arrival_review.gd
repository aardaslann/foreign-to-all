extends "res://tools/design_playability.gd"

var checks := 0
const AIRPORTS := {"berlin":"Airport", "istanbul":"IstanbulHavalimani",
	"london":"LondonAirport", "paris":"ParisAirport", "moscow":"MoscowAirport",
	"mumbai":"MumbaiAirport", "tokyo":"TokyoAirport", "mexico":"MexicoAirport"}


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)


func frames(count: int = 4) -> void:
	for i in range(count): await process_frame


func _run() -> void:
	var gs := root.get_node("GameState")
	var services := root.get_node("Services")
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("airport-arrival-review")
	catalog = load("res://scenes/world/EnvironmentDesign.gd").catalog()
	for city: String in AIRPORTS:
		check(gs.ARRIVALS[city] == "res://scenes/world/" + AIRPORTS[city] + ".tscn", "flight lands at airport: " + city)
	if not failures.is_empty():
		finish()
		return
	for city: String in AIRPORTS:
		gs.reset()
		gs.city = city
		gs.world_flags["airport_transfer"] = city
		gs.world_flags["intro_shown"] = true
		gs.start_quest("unfinished_elsewhere", "An earlier errand", ["Finish it later"], [gs.CITY_ENTRIES.berlin])
		var visits: Dictionary = gs.region_visits.duplicate(true)
		change_scene_to_file(gs.ARRIVALS[city])
		await frames(10)
		scene = current_scene
		player = scene.get_node("Player")
		player.set_physics_process(false)
		check(gs.region_visits == visits, "terminal does not count as neighbourhood exploration: " + city)
		check(not paused, "terminal arrival has no modal street thought: " + city)
		check(gs.city == city, "terminal preserves destination city: " + city)
		var guidance: Dictionary = services.arrival_guidance()
		check(not guidance.is_empty(), "terminal has onward guidance: " + city)
		var door := scene.get_node("Exit")
		check(gs.quest_target() == door.target_scene, "map and tracker guide to actual exit: " + city)
		var arrow := scene.find_child("QuestArrow", true, false)
		if arrow != null:
			check(arrow._way().is_equal_approx(door.position), "arrow uses actual terminal exit position: " + city)
		await capture(city + "-terminal")
		gs.world_flags["has_map"] = true
		var map := get_first_node_in_group("map_view")
		map.open_from_hud()
		await frames()
		check(map._here == gs.ARRIVALS[city] and map._city == city, "atlas opens at the actual airport: " + city)
		check(map._board._plate != null, "airport atlas has its scene art: " + city)
		var route: Array = map.ATLAS.route(map._here, gs.CITY_ENTRIES[city], scene)
		check(not route.is_empty(), "atlas connects airport to story neighbourhood: " + city)
		if city == "istanbul": await capture("istanbul-airport-map")
		map._close()
		check(not paused, "airport atlas closes without trapping input: " + city)
		check(_position_clear(player.position), "arrival stands on clear floor: " + city)
		var required := _targets()
		var reached := _flood(AIRPORTS[city], required)
		for row: Dictionary in required.values():
			check(not row.positions.is_empty(), "reachable terminal interaction: " + city + "/" + row.name)
			if not row.positions.is_empty():
				check(await _walk_route(row.positions[0], reached), "real collision sweep: " + city + "/" + row.name)
				for tick in range(4): await physics_frame
				check(row.host.player_nearby, "real proximity at terminal interaction: " + city + "/" + row.name)
		player.position = walk_start
		saves.checkpoint()
		check(saves.load_game(-1) and saves.pending_scene == gs.ARRIVALS[city], "checkpoint is the terminal: " + city)
		gs.last_scene = "res://scenes/world/LondonTerrace.tscn"
		gs.entered_from = gs.last_scene
		change_scene_to_file(saves.pending_scene)
		await frames(5)
		check(gs.entered_from.is_empty() and gs.last_scene.is_empty(), "terminal reload clears stale return links: " + city)
		door = current_scene.get_node("Exit")
		var wallet: Dictionary = gs.wallet.duplicate(true)
		door._go()
		await create_timer(0.9).timeout
		await frames()
		if services.AIRPORT_RAIL.has(city):
			check(current_scene.scene_file_path == services.AIRPORT_RAIL[city].hall, "exit reaches local platform: " + city)
			check(not services.arrival_guidance().is_empty(), "platform retains transfer guidance: " + city)
			saves.checkpoint()
			check(saves.load_game(-1), "platform checkpoint reloads: " + city)
			change_scene_to_file(saves.pending_scene)
			await frames(5)
			check(gs.entered_from == gs.ARRIVALS[city], "reloaded platform returns to this airport: " + city)
			services._ubahn_travel()
			await frames()
			var cp := get_first_node_in_group("choice_panel")
			check(cp._open, "included transfer opens stops without a ticket purchase: " + city)
			cp._close("")
			await frames()
			check(services.has_airport_transfer() and gs.wallet == wallet, "cancel keeps included transfer: " + city)
			gs.add_item("ticket_ubahn")
			var tickets: int = gs.inventory.get("ticket_ubahn", 0)
			services._ubahn_travel()
			await frames()
			cp._close(services.AIRPORT_RAIL[city].stop)
			await create_timer(0.9).timeout
			await frames()
			check(gs.inventory.get("ticket_ubahn", 0) == tickets, "included ride preserves purchased tickets: " + city)
		check(gs.wallet == wallet, "onward transfer costs nothing: " + city)
		check(current_scene.get("arrival_thought") != null or city in ["berlin", "london", "istanbul"], "transfer reaches a street: " + city)
		check(services.arrival_guidance().is_empty(), "airport guidance clears in town: " + city)
		check(not gs.world_flags.has("airport_transfer"), "transfer entitlement consumed in town: " + city)
		check(root.get_node("TransitionManager")._overlay.color.a < 0.01, "arrival thought is revealed, not frozen under a fade: " + city)
		var thought := get_first_node_in_group("thought_box")
		if thought != null and thought.visible: thought._close()
		check(not paused, "street remains playable after first impression: " + city)
		if city != "berlin":
			check(gs.tracked_quest_id() == "journey_" + city, "local story takes priority over earlier errand: " + city)
		services.first_street_arrival()
		check(thought == null or not thought.visible, "first impression does not replay: " + city)
		check(gs.region_visits.size() > visits.size(), "street exploration begins after transfer: " + city)
		await capture(city + "-street")
		# Returning for a departure must not resurrect the arrivals instruction.
		gs.last_scene = current_scene.scene_file_path
		change_scene_to_file(gs.ARRIVALS[city])
		await frames(5)
		check(services.arrival_guidance().is_empty(), "departure visit keeps normal quest guidance: " + city)
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	await frames()
	finish()


func finish() -> void:
	print("AIRPORT ARRIVALS: %d checks, %d failures" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.build/airport-arrival-review")
	root.get_texture().get_image().save_png("res://.build/airport-arrival-review/" + file + ".png")
