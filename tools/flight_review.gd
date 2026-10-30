extends "res://tools/title_review.gd"

func _run() -> void:
	out = "res://.build/flight-review"
	DirAccess.make_dir_recursive_absolute(out)
	var saves := root.get_node("SaveManager")
	var gs := root.get_node("GameState")
	var services := root.get_node("Services")
	saves.use_test_storage("flight-review")
	root.get_node("Loc").set_language("en")
	check(ResourceLoader.exists("res://scenes/cutscene/FlightCutscene.gd"), "flight film exists")
	if failures:
		_finish()
		return
	if OS.get_cmdline_user_args().has("--movie"):
		root.content_scale_size = Vector2i(1280,720)
		root.size = Vector2i(1280,720)
		gs.reset()
		change_scene_to_file("res://scenes/world/Airport.tscn")
		await frames(10)
		services._board_flight("istanbul", gs.flight_fare())
		await create_timer(9.0).timeout
		await _arrive("istanbul")
		await create_timer(0.5).timeout
		current_scene.queue_free()
		current_scene = null
		await frames()
		_finish()
		return
	gs.reset()
	gs.alien_appearance = {"skin":3, "eyes":2, "antenna":2, "coat":4, "accent":4}
	var appearance: Dictionary = gs.alien_appearance.duplicate(true)
	change_scene_to_file("res://scenes/world/Airport.tscn")
	await frames(10)
	gs.money = 80
	var fare: int = gs.flight_fare()
	services._airport_desk()
	await frames()
	var map := get_first_node_in_group("world_map")
	check(map._open, "airport opens the actual destination map")
	map._close("")
	await frames()
	check(get_first_node_in_group("flight_cutscene") == null and gs.money == 80, "cancelling does not fly or spend")
	services._airport_desk()
	map._close("istanbul")
	await frames()
	var film := get_first_node_in_group("flight_cutscene")
	check(film != null, "confirmed route plays film before arrival")
	if film == null:
		_finish()
		return
	check(paused and gs.city == "berlin" and gs.money == 80, "world held without an intermediate charged save")
	check(film.origin == "berlin" and film.destination == "istanbul", "film knows the selected route")
	film.set_process(false)
	film._request_finish()
	check(not film._done, "boarding input cannot immediately skip")
	services._board_flight("london", fare)
	check(get_nodes_in_group("flight_cutscene").size() == 1, "duplicate boarding ignored")
	film._process(1.0)
	film._toggle_pause()
	var held: float = film.elapsed
	film._process(1.0)
	check(film.elapsed == held and film._paused, "pause holds the film")
	film._toggle_pause()
	film._process(1.0)
	check(film.elapsed > held, "resume advances the film")
	film._pause.grab_focus()
	var accept := InputEventJoypadButton.new()
	accept.button_index = JOY_BUTTON_A
	accept.pressed = true
	root.push_input(accept, true)
	accept = InputEventJoypadButton.new()
	accept.button_index = JOY_BUTTON_A
	accept.pressed = false
	root.push_input(accept, true)
	check(film._paused and not film._done, "controller accept activates focused Pause instead of skipping")
	if film._done:
		await _arrive("istanbul")
		current_scene.queue_free()
		current_scene = null
		await frames()
		_finish()
		return
	var start := InputEventJoypadButton.new()
	start.button_index = JOY_BUTTON_START
	start.pressed = true
	root.push_input(start, true)
	check(not film._paused, "controller Start resumes")
	for size: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,768), Vector2i(2560,1080)]:
		root.content_scale_size = size
		if DisplayServer.get_name() != "headless": root.size = size
		await frames()
		film.elapsed = 3.6
		film._present()
		await frames()
		check(root.get_visible_rect().encloses(film._skip.get_global_rect()), "skip fits " + str(size))
		check(root.get_visible_rect().encloses(film._pause.get_global_rect()), "pause fits " + str(size))
		await capture("cruise-" + str(size.x))
	root.content_scale_size = Vector2i(1280,720)
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280,720)
	for t: float in [0.9, 2.0, 4.8, 6.6]:
		film.elapsed = t
		film._present()
		await capture("flight-" + str(t))
	film._stage.reduced_motion = true
	film._present()
	await capture("reduced-motion")
	if DisplayServer.get_name() != "headless":
		var plane: Image = film._stage.PLANE.get_image()
		check(plane.get_pixel(0, 0).a < 0.01, "plane asset has genuine transparent surroundings")
		film._stage.reduced_motion = false
		film.elapsed = 2.8
		film._present()
		await RenderingServer.frame_post_draw
		var before: Image = root.get_texture().get_image()
		var before_pose: Dictionary = film._stage.plane_pose()
		film.elapsed = 4.5
		film._present()
		await RenderingServer.frame_post_draw
		var after: Image = root.get_texture().get_image()
		check(hash(before.get_data()) != hash(after.get_data()) and before_pose != film._stage.plane_pose(), "rendered flight and aircraft position move")
		check(after.get_pixel(640, 310).r > 0.4 and after.get_pixel(1080, 180).r < 0.4, "aircraft rendered distinctly against the sky")
	root.get_node("Controls").rebind("interact", KEY_F)
	var skip := InputEventKey.new()
	skip.physical_keycode = KEY_F
	skip.pressed = true
	root.push_input(skip, true)
	check(film._done, "rebound interact skips")
	film._request_finish()
	await create_timer(0.25).timeout
	var journal_key := InputEventAction.new()
	journal_key.action = "journal"
	journal_key.pressed = true
	root.push_input(journal_key, true)
	check(not paused, "notebook input cannot freeze the arrival fade")
	var journal := get_first_node_in_group("journal")
	if journal != null and journal._panel_root.visible: journal._close()
	await _arrive("istanbul")
	check(gs.wallet.get("EUR", -1) == 80 - fare, "one fare from the departure wallet")
	check(gs.alien_appearance == appearance, "flight preserves custom alien")
	check(gs.world_flags.get("ticket_istanbul", false) and gs.world_flags.get("left_berlin", false), "flight keeps travel flags")
	check(saves.load_game(-1) and saves.pending_scene == gs.ARRIVALS.istanbul, "checkpoint resumes at destination, never in film")
	root.get_node("Controls").reset_binds()
	# The same entry point serves every core city, including returning to Berlin.
	for city: String in ["london", "paris", "moscow", "mumbai", "tokyo", "mexico", "berlin"]:
		gs.money = 0
		saves.settings["reduce_motion"] = city == "london"
		services._board_flight(city, gs.flight_fare())
		await frames()
		film = get_first_node_in_group("flight_cutscene")
		check(film != null, "film exists for " + city)
		if film == null: continue
		if city == "london":
			check(film._stage.reduced_motion, "reduced motion follows saved setting")
			var still: Dictionary = film._stage.plane_pose()
			film._stage.elapsed = 2.0
			check(film._stage.plane_pose() == still, "reduced motion has no flying or camera drift")
		film._process(3.1 if city == "london" else film.DURATION + 0.1)
		await _arrive(city)
		check(gs.money >= 0, "allowance still covers flight to " + city)
	var money: int = gs.money
	for invalid: String in ["berlin", "sydney", "missing"]:
		services._board_flight(invalid, gs.flight_fare())
		await frames()
		check(get_first_node_in_group("flight_cutscene") == null and gs.money == money, "invalid route changes nothing: " + invalid)
	current_scene.queue_free()
	current_scene = null
	await frames()
	_finish()


func _arrive(city: String) -> void:
	for i in range(160):
		if not root.get_node("Services")._boarding: break
		await create_timer(0.025).timeout
	await frames(3)
	check(current_scene.scene_file_path == root.get_node("GameState").ARRIVALS[city], "correct arrival " + city)
	check(current_scene.scene_file_path == root.get_node("Story").path(root.get_node("Story").AIRPORT[city]), "arrival is independently the city's airport " + city)
	var gs := root.get_node("GameState")
	check(gs.entered_from.is_empty() and not gs.world_flags.has("transit_from"), "flight clears previous city return links " + city)
	check(gs.world_flags.get("airport_transfer", "") == city, "flight includes onward transfer " + city)
	check(not root.get_node("Services")._boarding and get_first_node_in_group("flight_cutscene") == null, "flight cleaned up " + city)
	# Some cities immediately open their authored arrival thought; close it first.
	var thought := get_first_node_in_group("thought_box")
	if thought != null and thought.visible: thought._close()
	check(not paused, "movement restored " + city)
