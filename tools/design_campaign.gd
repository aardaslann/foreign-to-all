extends "res://tools/design_first_trade.gd"

# Uses actual input, live response dictionaries, transitions and sleep tweens.
# APPDATA must point to disposable test storage.
func close_reading() -> void:
	for group: String in ["dialogue_box", "thought_box", "pickup", "angry_box"]:
		var box := get_first_node_in_group(group)
		if box != null and box.visible and box.has_method("_close"):
			box.call("_close")
	paused = false
	await process_frame

func load_room(id: String) -> void:
	await close_reading()
	if is_instance_valid(scene):
		scene.free()
	await process_frame
	scene = load("res://scenes/world/" + id + ".tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	player.set_physics_process(false)
	for i in range(6):
		await physics_frame

func use_node(name: String) -> void:
	await close_reading()
	var host: Node2D = scene.get_node(name)
	var area := host.get_node_or_null("InteractionArea") as Node2D
	var pos: Vector2 = area.global_position if area != null else host.global_position
	# Service triggers overlap the player's feet, which are 20px below origin.
	await settle(pos - Vector2(0, 10))
	for i in range(3):
		await physics_frame
	check(host.get("player_nearby") == true, String(scene.name)+"/"+name+" has an active real interaction")
	await press_interact()

func answer_dialogue(action: String = "") -> void:
	var dlg := get_first_node_in_group("dialogue_box")
	check(dlg != null and dlg.visible, "the expected conversation is visible")
	if dlg == null or not dlg.visible:
		return
	var entries: Array = dlg.get("_entries").duplicate(true)
	var found: bool = action.is_empty()
	for entry: Dictionary in entries:
		var choices: Array = entry.get("responses", [])
		if choices.is_empty():
			continue
		var chosen: Dictionary = choices[0]
		for response: Dictionary in choices:
			if not action.is_empty() and response.get("action", "") == action:
				chosen = response
				found = true
		dlg.call("_on_response", chosen)
		await process_frame
	check(found, "conversation contains requested action: " + action)
	await close_reading()

func choose(id: String) -> void:
	var cp := get_first_node_in_group("choice_panel")
	check(cp != null and cp.get("_open") == true, "a live choice panel is waiting for " + id)
	if cp != null and cp.get("_open") == true:
		cp.call("_close", id)
	await process_frame
	await close_reading()

func changed_to(id: String) -> void:
	await create_timer(0.85).timeout
	scene = current_scene
	check(scene != null and scene.scene_file_path.ends_with("/"+id+".tscn"), "transition arrives in " + id)
	if scene != null:
		player = scene.get_node("Player")
		player.set_physics_process(false)

func walk_to(at: Vector2) -> void:
	var body := player as CharacterBody2D
	for i in range(350):
		if body.position.distance_to(at) < 3:
			break
		body.velocity = body.position.direction_to(at) * 120
		body.move_and_slide()
		await physics_frame
	body.velocity = Vector2.ZERO
	check(body.position.distance_to(at) < 4, "player walks through collision to " + str(at))

func finish_activity() -> void:
	var cs := get_first_node_in_group("cutscene")
	check(cs != null and cs.get("_open") == true, "activity opens in the live Cutscene renderer")
	if cs != null and cs.get("_open") == true:
		# The same close path as the player's skip key, including finished signal.
		cs.call("_close")
	await process_frame
	await close_reading()

func collect_drop(item: String) -> void:
	var found: bool = false
	for child in scene.get_children():
		if child.get_script() != null and child.get_script().resource_path.ends_with("/DroppedItem.gd") and child.get("item") == item:
			found = true
			await settle(child.global_position)
			await close_reading()
			break
	check(found and root.get_node("GameState").has_item(item), "walk over and collect the physical " + item)

func _run() -> void:
	await _test_first_trade()
	await close_reading()
	var gs = root.get_node("GameState")
	await settle(Vector2(471,604))
	await walk_to(Vector2(737,604))
	await walk_to(Vector2(737,550))
	check(not scene.get_node("LocalSpot").player_nearby, "walking to Lukas does not enter the free activity")
	await use_node("LocalSpot")
	await finish_activity()
	await collect_drop("apple")
	check(gs.has_item("apple") and gs.money == 3, "free apple activity preserves paid trade and wallet")
	await use_node("ExitToMitte")
	await changed_to("Mitte")
	await use_node("BusStopNPC")
	await answer_dialogue()
	await use_node("BusStopNPC")
	await answer_dialogue("give_map")
	check(gs.world_flags.get("has_map",false) and gs.quests["get_map"]["completed"], "Renate gives the map and completes its quest")
	await use_node("HotelEntrance")
	await changed_to("HotelLobby")
	await use_node("Receptionist")
	await answer_dialogue("book_room")
	check(gs.world_flags.get("room_booked",false) and gs.money == 2, "Frau Weber books the room for one coin")
	await use_node("Elevator")
	var elevator := get_first_node_in_group("elevator_panel")
	check(elevator.get("_panel_root").visible, "elevator floor selector opens")
	elevator.call("_go_to_floor",3)
	await changed_to("HotelFloor")
	check(scene.get_node("Door4").call("_room_number") == gs.HOTEL_ROOM, "third-floor door matches the room key")
	await use_node("Door4")
	await changed_to("HotelRoom")
	await use_node("BedRest")
	await create_timer(8.0).timeout
	check(gs.rested_here() and gs.quests["find_bed"]["completed"], "sleep completes Berlin's hotel quest")
	await use_node("ExitToCorridor")
	await changed_to("HotelFloor")
	check(player.position.distance_to(scene.get_node("Door4").position) < 65, "leaving the room returns beside its actual door")

	# Istanbul starts with its own wallet and rest state. Imported game saves are never used.
	gs.city = "istanbul"
	gs.money = 1500
	gs.world_flags["arrived_istanbul"] = true
	gs.last_scene = ""
	gs.spawn_tag = ""
	await load_room("IstanbulOtel")
	await use_node("StairsToRoom")
	check(not scene.get_node("StairsToRoom").get("_resting") and not gs.rested_here(), "Istanbul rooms require a key before sleeping")
	await use_node("Desk")
	await choose("book")
	check(gs.room_booked_here() and gs.money == 1240, "Istanbul reception takes the correct room payment")
	await use_node("StairsToRoom")
	await create_timer(8.0).timeout
	check(gs.rested_here() and not paused, "Istanbul sleep completes and returns control")
	await load_room("IstanbulYusuf")
	for choice: String in ["take","sit","eat","refuse","take"]:
		await use_node("Yusuf")
		await choose(choice)
	await collect_drop("charm_eye")
	check(gs.has_item("charm_eye"), "Yusuf's entire five-stage hospitality sequence can finish")
	await use_node("Exit")
	await changed_to("IstanbulHan")
	await use_node("LocalSpot")
	await finish_activity()
	check(gs.world_flags.get("spot_han",false), "Han activity completes independently of Yusuf and Arda")
	await use_node("BackToCarsi")
	await changed_to("IstanbulCarsi")
	await use_node("LocalSpot")
	await finish_activity()
	check(gs.world_flags.get("spot_carsi",false), "bakery activity records its story errand")
	await use_node("MetroEntrance")
	await changed_to("IstanbulMetro")
	await use_node("ToAirport")
	await changed_to("IstanbulHavalimani")
	check(root.get_node("Services").call("_flight_block","berlin").is_empty(), "airport permits a funded return flight after Istanbul sleep")
	await use_node("Exit")
	await changed_to("IstanbulMetro")
	check(player.position.y < 608, "airport return lands clear of the bottom wall")
	print("CAMPAIGN: ",failures.size()," failures")
	paused = false
	if is_instance_valid(scene):
		scene.free()
	quit(0 if failures.is_empty() else 1)
