extends "res://tools/design_campaign.gd"

# Counter effects and work loops after the layout change. Run with disposable
# APPDATA. Wallets and accepted jobs are fixtures; interactions use real E input
# and the buttons created by ChoicePanel, including disabled-choice guards.
func row_button(index: int) -> Button:
	var cp := get_first_node_in_group("choice_panel")
	if cp == null or not cp.get("_open"):
		return null
	var rows: VBoxContainer = cp.get("_rows")
	if index >= rows.get_child_count():
		return null
	for child in rows.get_child(index).get_children():
		if child is Button:
			return child
	return null

func click_row(index: int) -> void:
	var button := row_button(index)
	check(button != null, "choice row %d has a real enabled button" % index)
	if button != null:
		button.pressed.emit()
	await process_frame
	await close_reading()

func use_job(name: String) -> void:
	await close_reading()
	var spot: Node2D = scene.get_node(name)
	await settle(spot.global_position - Vector2(0, 10))
	check(spot.get("_near") and spot.call("is_live"), String(scene.name) + "/" + name + " offers the next work step")
	await press_interact()
	await close_reading()

func _run() -> void:
	var gs = root.get_node("GameState")
	var services = root.get_node("Services")
	gs.city = "berlin"
	gs.world_flags.clear()
	gs.inventory.clear()
	gs.quests.clear()
	gs.wallet = gs.fresh_wallet()
	gs.money = 30
	gs.last_scene = ""
	gs.spawn_tag = ""
	gs.world_flags["arrived_berlin"] = true
	await load_room("Police")
	await use_node("Desk")
	check(row_button(0) == null, "police proof option is unavailable before the hospital shard")
	await click_row(2)
	await load_room("Hospital")
	await use_node("Reception")
	await click_row(0)
	await collect_drop("hospital_dish")
	await load_room("Police")
	await use_node("Desk")
	await click_row(0)
	await collect_drop("police_bag")
	check(gs.has_item("hospital_dish") and gs.has_item("police_bag"), "hospital proof and police fragment are both collectible")
	await load_room("UBahnStation")
	var before: int = gs.money
	await use_node("LostProperty")
	await click_row(0)
	await collect_drop("lost_parcel")
	check(gs.money == before - 2, "lost property charges its fee once")
	await use_node("LostProperty")
	await close_reading()
	check(gs.money == before - 2, "revisiting lost property does not charge again")
	# A crate contract is seeded so the test isolates its actual physical work.
	gs.accept_job("crates")
	services.open_job_quest("crates")
	await load_room("Kiez")
	before = gs.money
	await use_node("CrateJob")
	await close_reading()
	check(gs.money == before, "the stall does not pay for unfinished crate work")
	for i in range(services.job_reps("crates")):
		await use_job("JobSpot1")
		check(not gs.carrying.is_empty(), "taking crates puts a load in the player's hands")
		await use_job("JobSpot2")
		check(gs.carrying.is_empty() and gs.job_progress == i + 1, "delivery advances exactly one trip")
	await use_node("CrateJob")
	await close_reading()
	check(gs.active_job.is_empty() and gs.money == before + 4, "completed crate work pays four coins at the stall")
	for city: String in ["berlin", "istanbul"]:
		gs.city = city
		gs.last_scene = ""
		gs.spawn_tag = ""
		gs.world_flags["arrived_" + city] = true
		gs.world_flags.erase("transit_from")
		gs.inventory.erase("ticket_ubahn")
		var station: String = "UBahnStation" if city == "berlin" else "IstanbulMetro"
		var machine: String = "TicketMachine" if city == "berlin" else "Machine"
		await load_room(station)
		gs.money = 0
		await use_node(machine)
		check(row_button(0) == null, city + " ticket machine blocks unaffordable purchases")
		await click_row(1)
		gs.money = 500
		await use_node(machine)
		await click_row(0)
		await collect_drop("ticket_ubahn")
		check(gs.money == 500 - gs.transit_fare(), city + " ticket machine charges the local fare")
		await use_node("Platform")
		await click_row(0)
		await changed_to("BerlinPrenzlberg" if city == "berlin" else "IstanbulKarakoy")
		check(not gs.has_item("ticket_ubahn"), city + " travel consumes one ticket")
		await use_node("TransitEntrance")
		await changed_to(station)
		await use_node("Platform")
		check(row_button(0) == null and row_button(1) == null, city + " current stop and ticketless travel are unavailable")
		await click_row(4 if city == "berlin" else 5)
		await use_node("Exit")
		await changed_to("BerlinPrenzlberg" if city == "berlin" else "IstanbulKarakoy")
		# Convert a foreign wallet through the actual booth button.
		gs.wallet = gs.fresh_wallet()
		var foreign: String = "TRY" if city == "berlin" else "EUR"
		gs.wallet[foreign] = 1000
		var expected: int = gs.convert_preview(1000, foreign, gs.currency())
		await load_room("Exchange" if city == "berlin" else "IstanbulDoviz")
		await use_node("Counter" if city == "berlin" else "Booth")
		await click_row(0)
		check(gs.money == expected and gs.cash(foreign) == 0, city + " exchange converts the foreign wallet at the displayed rate")
		gs.accept_job("dishes")
		services.open_job_quest("dishes")
		await load_room("Restaurant" if city == "berlin" else "IstanbulLokanta")
		before = gs.money
		for i in range(services.job_reps("dishes")):
			await use_job("JobSpot1")
			await use_job("JobSpot2")
		await use_node("Kitchen" if city == "berlin" else "Counter")
		await close_reading()
		check(gs.active_job.is_empty() and gs.money == before + int(services.JOBS["dishes"]["pay"]), city + " dishwashing completes and pays at its own restaurant")
	print("SERVICES: ", failures.size(), " failures")
	paused = false
	scene.free()
	quit(0 if failures.is_empty() else 1)
