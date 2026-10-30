extends "res://tools/design_services.gd"

# Use the real service inputs, dialogue responses and scene transitions in a
# disposable save. Geometry sweeps are complementary, not a substitute.
func _run() -> void:
	var gs = root.get_node("GameState")
	var services = root.get_node("Services")
	gs.city = "paris"
	gs.time_of_day = "morning"
	gs.world_flags.clear()
	gs.inventory.clear()
	gs.quests.clear()
	gs.region_visits.clear()
	gs.wallet = gs.fresh_wallet()
	gs.money = 500
	gs.last_scene = ""
	gs.spawn_tag = ""
	for flag: String in ["arrived_paris","story_met_paris","intro_shown"]:
		gs.world_flags[flag] = true
	await load_room("ParisMarais")
	await process_frame
	await process_frame
	var encounter: Node2D = scene.get_node_or_null("Encounter")
	check(encounter != null,"Paris greeting encounter exists on first visit")
	if encounter != null:
		await settle(encounter.position-Vector2(120,0))
		await close_reading()
		for tick in range(600):
			if encounter.get("_state")=="talking": break
			await physics_frame
		check(encounter.get("_state")=="talking","shopkeeper reaches the player for the greeting")
		await answer_dialogue("flag:enc_paris_bonjour")
		for tick in range(900):
			if not is_instance_valid(encounter): break
			await physics_frame
		check(not is_instance_valid(encounter),"shopkeeper leaves along the clear street")
	await load_room("ParisHotel")
	gs.money=0
	await use_node("Point")
	check(row_button(0)==null,"hotel blocks an unaffordable room")
	await click_row(2)
	gs.money=500
	var price: int=gs.room_price()
	await use_node("Point")
	await click_row(0)
	check(gs.room_booked_here() and gs.money==500-price,"hotel charges and books one room")
	await use_node("Point")
	await close_reading()
	check(gs.money==500-price,"reception does not charge twice")
	gs.wallet=gs.fresh_wallet()
	gs.wallet["GBP"]=1000
	var expected: int=gs.convert_preview(1000,"GBP",gs.currency())
	await load_room("ParisExchange")
	await use_node("Point")
	await click_row(0)
	check(gs.money==expected and gs.cash("GBP")==0,"exchange converts the actual foreign balance")
	for stop: Array in services.METRO_LINES["paris"]:
		gs.last_scene=""
		gs.spawn_tag=""
		gs.world_flags.erase("transit_from")
		gs.inventory.erase("ticket_ubahn")
		await load_room("ParisTransit")
		gs.money=0
		await use_node("Machine")
		check(row_button(0)==null,"Métro blocks an unaffordable ticket")
		await click_row(1)
		gs.money=500
		await use_node("Machine")
		await click_row(0)
		await collect_drop("ticket_ubahn")
		check(gs.money==500-gs.transit_fare(),"Métro charges the fare once")
		await use_node("Platform")
		await choose(stop[0])
		await changed_to(String(stop[4]).get_file().get_basename())
		check(not gs.has_item("ticket_ubahn"),"travel consumes the ticket to "+stop[0])
	for room: String in ["ParisChampDeMars","ParisMarais","ParisMontmartre","ParisBelleville","ParisLaDefense"]:
		gs.last_scene=""
		gs.spawn_tag=""
		await load_room(room)
		await use_node("LocalSpot")
		await finish_activity()
		check(not paused,room+" activity returns control")
	gs.last_scene=""
	gs.spawn_tag=""
	await load_room("ParisAirport")
	await use_node("Point")
	var map := get_first_node_in_group("world_map")
	check(map!=null and map.get("_open"),"Paris check-in opens the live flight map")
	if map!=null and map.get("_open"): map.call("_close","")
	await close_reading()
	print("PARIS_SERVICES ",failures.size()," failures")
	if is_instance_valid(scene): scene.free()
	quit(0 if failures.is_empty() else 1)
