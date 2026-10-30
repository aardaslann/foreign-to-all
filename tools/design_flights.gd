extends "res://tools/design_campaign.gd"

# Airports must complete an actual transition, not only report an open route.
# Funded, rested repeat visits isolate this check from the twenty-city story.
func click_destination(map: Node, destination: String) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = map.call("_project", map.CITY_POS[destination])
	map.call("_on_canvas_input", event)
	await process_frame

func _run() -> void:
	var gs = root.get_node("GameState")
	gs.world_flags.clear()
	gs.quests.clear()
	gs.inventory.clear()
	gs.wallet = gs.fresh_wallet()
	gs.familiarity.clear()
	gs.last_scene = ""
	gs.spawn_tag = ""
	for city: String in ["berlin", "istanbul"]:
		gs.world_flags["visited_" + city] = true
		gs.world_flags["arrived_" + city] = true
	for city: String in ["berlin", "istanbul"]:
		var destination: String = "istanbul" if city == "berlin" else "berlin"
		gs.city = city
		gs.money = 10000
		gs.last_scene = ""
		gs.spawn_tag = ""
		gs.world_flags.erase("rested_" + city)
		await load_room("Airport" if city == "berlin" else "IstanbulHavalimani")
		var desk: String = "CheckIn" if city == "berlin" else "BagDrop"
		await use_node(desk)
		var map := get_first_node_in_group("world_map")
		check(map != null and map.get("_open"), city + " check-in opens the departure map")
		check(not map.get("_routes")[destination]["ok"], city + " blocks travel before sleeping")
		map.call("_close", "")
		await close_reading()
		gs.world_flags["rested_" + city] = true
		if city == "berlin":
			await use_node(desk)
			map = get_first_node_in_group("world_map")
			check(not map.get("_routes")[destination]["ok"], "Berlin desk requires usable German words")
			map.call("_close", "")
			await close_reading()
			gs.familiarity["german"] = {}
			var words: Dictionary = gs.guesses_for("german")
			for word: String in words.keys().slice(0, 12):
				gs.familiarity["german"][word] = 100
		gs.money = 0
		await use_node(desk)
		map = get_first_node_in_group("world_map")
		check(not map.get("_routes")[destination]["ok"], city + " blocks an unaffordable flight")
		await click_destination(map, destination)
		check(map.get("_open") and gs.city == city, "clicking a blocked destination keeps the player at the airport")
		map.call("_close", "")
		await close_reading()
		gs.money = 10000
		var currency: String = gs.currency()
		var fare: int = gs.flight_fare()
		await use_node(desk)
		map = get_first_node_in_group("world_map")
		check(map.get("_routes")[destination]["ok"], city + " offers the funded repeat-visit route")
		await click_destination(map, destination)
		await changed_to("IstanbulCarsi" if destination == "istanbul" else "Mitte")
		var thought := get_first_node_in_group("thought_box")
		if thought != null and thought.visible:
			await press_interact()
			check(not thought.visible, "arrival thought closes through the normal input handler")
		check(gs.city == destination and not paused, "flight arrives with player control in " + destination)
		check(gs.cash(currency) == 10000 - fare, "fare comes from the departing currency exactly once")
		check(gs.world_flags.get("left_" + city, false), "departure records the city left")
	print("FLIGHTS: ", failures.size(), " failures")
	if is_instance_valid(scene):
		scene.free()
	quit(0 if failures.is_empty() else 1)
