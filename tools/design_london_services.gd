extends "res://tools/design_services.gd"

# Real input and UI effects complement the all-floor collision sweep. Run
# only with disposable APPDATA, never with the player's save directory.
func _run() -> void:
	var gs = root.get_node("GameState")
	var services = root.get_node("Services")
	gs.city = "london"
	gs.time_of_day = "morning"
	gs.world_flags.clear()
	gs.inventory.clear()
	gs.quests.clear()
	gs.region_visits.clear()
	gs.wallet = gs.fresh_wallet()
	gs.money = 500
	gs.last_scene = ""
	gs.spawn_tag = ""
	gs.world_flags["arrived_london"] = true
	gs.world_flags["story_met_london"] = true
	gs.world_flags["intro_shown"] = true
	await load_room("LondonTerrace")
	var encounter: Node2D = scene.get_node_or_null("Encounter")
	check(encounter != null, "London bin encounter exists on first visit")
	if encounter != null:
		await process_frame
		await process_frame
		await settle(encounter.position - Vector2(120,0))
		await close_reading()
		for tick in range(600):
			if encounter.get("_state") == "talking": break
			await physics_frame
		check(encounter.get("_state") == "talking", "bin neighbour walks over and starts the conversation")
		print("ENCOUNTER state=",encounter.get("_state")," pos=",encounter.position," player=",player.position," paused=",paused)
		await answer_dialogue("flag:enc_london_bins")
		for tick in range(900):
			if not is_instance_valid(encounter): break
			await physics_frame
		check(not is_instance_valid(encounter), "bin neighbour follows the street exit and leaves")
	await load_room("LondonHotel")
	gs.money = 0
	await use_node("Desk")
	check(row_button(0) == null, "hotel blocks an unaffordable booking")
	await click_row(2)
	gs.money = 500
	var price: int = gs.room_price()
	await use_node("Desk")
	await click_row(0)
	check(gs.room_booked_here() and gs.money == 500-price, "hotel books a room and charges once")
	await use_node("Desk")
	await close_reading()
	check(gs.money == 500-price, "returning to reception does not charge again")
	gs.wallet = gs.fresh_wallet()
	gs.wallet["EUR"] = 1000
	var converted: int = gs.convert_preview(1000,"EUR",gs.currency())
	await load_room("LondonExchange")
	await use_node("Booth")
	await click_row(0)
	check(gs.money == converted and gs.cash("EUR") == 0, "London exchange converts the actual foreign wallet")
	gs.accept_job("dishes")
	services.open_job_quest("dishes")
	await load_room("LondonCaff")
	var before: int = gs.money
	await use_node("Hatch")
	await close_reading()
	check(gs.money == before, "caff cannot pay before the dishes are done")
	for trip in range(services.job_reps("dishes")):
		await use_job("JobSpot1")
		check(not gs.carrying.is_empty(), "washing-up load enters the player's hands")
		await use_job("JobSpot2")
		check(gs.carrying.is_empty() and gs.job_progress == trip+1, "washing-up advances exactly one trip")
	await use_node("Hatch")
	await close_reading()
	check(gs.active_job.is_empty() and gs.money == before+int(services.JOBS["dishes"]["pay"]), "caff completes and pays the four-trip job")
	await load_room("LondonPolice")
	await use_node("Counter")
	check(row_button(0) == null, "police proof is unavailable before collecting the shard")
	await click_row(2)
	await load_room("LondonHospital")
	await use_node("Triage")
	await click_row(0)
	await collect_drop("hospital_dish")
	await load_room("LondonPolice")
	await use_node("Counter")
	await click_row(0)
	await collect_drop("police_bag")
	for stop: Array in services.METRO_LINES["london"]:
		gs.last_scene = ""
		gs.spawn_tag = ""
		gs.world_flags.erase("transit_from")
		gs.inventory.erase("ticket_ubahn")
		await load_room("LondonUnderground")
		gs.money = 0
		await use_node("Machine")
		check(row_button(0) == null, "ticket purchase requires the local fare")
		await click_row(1)
		gs.money = 500
		await use_node("Machine")
		await click_row(0)
		await collect_drop("ticket_ubahn")
		check(gs.money == 500-gs.transit_fare(), "ticket charges the London fare once")
		await use_node("Platform")
		await choose(stop[0])
		await changed_to(String(stop[4]).get_file().get_basename())
		check(not gs.has_item("ticket_ubahn"), "travel to "+stop[0]+" consumes the ticket")
	for room: String in ["LondonTerrace","LondonHighStreet","LondonSoho","LondonBrixton","LondonDocklands"]:
		gs.last_scene = ""
		gs.spawn_tag = ""
		await load_room(room)
		await use_node("LocalSpot")
		print("ACTIVITY_STATE ",room," paused=",paused," region=",gs.current_region)
		await finish_activity()
		check(not paused, room+" activity returns control")
	gs.last_scene = ""
	gs.spawn_tag = ""
	await load_room("LondonAirport")
	await use_node("BagDrop")
	var map := get_first_node_in_group("world_map")
	check(map != null and map.get("_open"), "London check-in opens the live flight map")
	if map != null and map.get("_open"): map.call("_close", "")
	await close_reading()
	print("LONDON_SERVICES ", failures.size(), " failures")
	if is_instance_valid(scene): scene.free()
	quit(0 if failures.is_empty() else 1)
