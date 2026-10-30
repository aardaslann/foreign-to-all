extends SceneTree

# Exercises the real input handler, dialogue responses and quest effects.
# Run with a disposable APPDATA directory, as with the other design tools.
const SS := preload("res://scenes/world/Streetside.gd")
var failures: Array[String] = []
var scene: Node
var player: Node2D

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
	print("PASS " if ok else "FAIL ", message)

func settle(at: Vector2) -> void:
	player.position = at
	for i in range(8):
		await process_frame

func press_interact() -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = "interact"
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func _test_first_trade() -> void:
	var gs = root.get_node("GameState")
	gs.city = "berlin"
	gs.time_of_day = "morning"
	gs.world_flags.clear()
	gs.quests.clear()
	gs.inventory.clear()
	gs.region_visits.clear()
	gs.money = 0
	gs.last_scene = ""
	gs.spawn_tag = ""
	scene = load("res://scenes/world/Kiez.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	player.set_physics_process(false)
	await settle(Vector2(507, 584))
	check(not scene.has_node("CoinPouch"), "walking over the pouch collects it without an interaction key")
	check(not scene.get_node("LocalSpot").player_nearby, "pouch and activity have separate interaction space")
	check(gs.money == 5 and gs.world_flags.get("kiez_pouch_taken", false), "walking picks up the five coins")
	var pickup := get_first_node_in_group("pickup")
	if pickup != null and pickup.visible:
		pickup.call("_close")
	paused = false
	await settle(Vector2(737, 550))
	check(scene.get_node("NPC").player_nearby, "Lukas can be spoken to from the customer side of the stall")
	check(not scene.get_node("LocalSpot").player_nearby, "apple activity does not cover Lukas's counter")
	await press_interact()
	var dialogue := get_first_node_in_group("dialogue_box")
	check(dialogue.visible and dialogue.get("_name_label").text == "Lukas", "interact opens Lukas's actual dialogue")
	if dialogue.visible:
		var entries: Array = dialogue.get("_entries")
		dialogue.call("_on_response", entries[0]["responses"][1])
		var purchase: Dictionary = {}
		for response: Dictionary in entries[1]["responses"]:
			if response.get("action", "") == "buy_bread":
				purchase = response
		check(not purchase.is_empty(), "paid bread response is present")
		if not purchase.is_empty():
			dialogue.call("_on_response", purchase)
	check(gs.money == 3 and gs.world_flags.get("bread_bought", false), "paying Lukas spends two coins and records the trade")
	check(gs.quests["first_trade"]["completed"], "first_trade completes")
	check(gs.quests.has("get_map"), "the map quest unlocks")
	var activity: Dictionary = SS.reel("berlin", "kiez", 5)
	var gifts: Array = []
	for beat: Dictionary in activity["owed"]:
		if beat.has("item"):
			gifts.append(beat["item"])
	check(gifts == ["apple"] and activity["spent"] == 0, "the separate activity gives the free apple, with no competing bread trade")

func _run() -> void:
	await _test_first_trade()
	print("FIRST_TRADE: ", failures.size(), " failures")
	paused = false
	scene.free()
	quit(0 if failures.is_empty() else 1)
