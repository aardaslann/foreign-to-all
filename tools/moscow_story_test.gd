extends SceneTree

const SCRIPT := preload("res://scenes/story/moscow/MoscowScript.gd")
var gs: Node
var world: Node
var failures := 0
var checks := 0
var finished := false
var strategy := 0
var capture_done := {}
var captures := false
var cancelled := false
var cancel_carry := false
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/moscow-story-review"


func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("MOSCOW STORY: " + message)

func _run() -> void:
	gs = root.get_node("GameState")
	root.get_node("SaveManager").use_test_storage("moscow-story")
	captures = OS.get_cmdline_user_args().has("--capture")
	DirAccess.make_dir_recursive_absolute(out)
	for chapter: String in SCRIPT.CHAPTERS:
		var labels := {}
		for step: Dictionary in SCRIPT.CHAPTERS[chapter]:
			if step.get("do", "") == "label":
				check(not labels.has(step["name"]), chapter + " unique label " + step["name"])
				labels[step["name"]] = true
		for step: Dictionary in SCRIPT.CHAPTERS[chapter]:
			var destinations: Array = []
			if step.get("do", "") == "goto":
				destinations.append(step["to"])
			if step.get("do", "") == "if":
				destinations.append(step["then"])
				destinations.append(step["else"])
			for option: Dictionary in step.get("options", []):
				destinations.append(option.get("go", ""))
			for destination: String in destinations:
				check(destination.is_empty() or labels.has(destination), chapter + " valid branch " + destination)
	for route in range(3):
		gs.reset()
		gs.city = "moscow"
		gs.world_flags["moscow_arrived"] = true
		gs.quests["find_bed"] = {"completed": true, "steps": []}
		strategy = route
		await load_world()
		for chapter in range(4):
			if chapter >= 1:
				gs.world_flags["spot_izmaylovo"] = true
			if chapter >= 2:
				gs.world_flags["spot_basmanny"] = true
				gs.world_flags["spot_arbat"] = true
			await play(chapter)
			check(gs.world_flags.get("moscow_story", {}).get("done", {}).get(str(chapter), false), "route %d chapter %d complete" % [route, chapter])
		check(root.get_node("Story").holiday_seen("moscow"), "celebration complete")
		var flags: Dictionary = gs.world_flags["moscow_story"]["flags"]
		check(bool(flags.get("new_clasp", false)) == (route < 2), "repair decision retained across chapters")
		var reel: Array = root.get_node("Journey").holiday_reel("moscow")
		check(("wider clasp" in String(reel[4]["say"])) == (route < 2), "closing matches the actual repair")
		check(gs.understanding("russian", "pochinit").has("meaning"), "repair discovered by selecting the physical brooch")
		check(gs.understanding("russian", "lichnoye").has("meaning"), "personal boundary understood")
		check(gs.understanding("russian", "udobneye").has("meaning"), "owner tests ease of use")
		check(world.get_meta("street_story_moscow", {}).get("props", {}).has("plain"), "celebration plates survive conversation")
		if route == 0:
			check(not String(gs.understanding("russian", "pochinit").get("first", "")).is_empty(), "first wrong guess retained")
		check(world.get_node("KeyViktor").visible and world.get_node("KeyViktor").collision_layer != 0, "original Viktor restored after stage")
		check(get_first_node_in_group("player").is_physics_processing(), "movement restored")
		print("MOSCOW ROUTE ", route, " complete")
	# A cancelled answer must not earn a round, and resume must recreate props.
	gs.reset()
	gs.city = "moscow"
	gs.world_flags["moscow_arrived"] = true
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	await load_world()
	cancelled = true
	await play(0)
	check(root.get_node("Story").rounds_done("moscow") == 0, "cancelled question has no friendship award")
	await load_world()
	await play(0)
	check(root.get_node("Story").rounds_done("moscow") == 1, "cancelled question resumes")
	# Leave during a physical pointing choice, then reload an actual checkpoint.
	gs.reset()
	gs.city = "moscow"
	gs.world_flags["moscow_arrived"] = true
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	await load_world()
	strategy = 0
	cancel_carry = true
	await play(0)
	world.queue_free()
	await process_frame
	check(not root.get_node("Journey").busy, "scene exit releases conversation lock")
	check(gs.carrying.is_empty(), "temporary load cleared on scene exit")
	var sm := root.get_node("SaveManager")
	check(sm.load_game(-1), "isolated chapter checkpoint loads")
	await load_world()
	await play(0)
	check(root.get_node("Story").rounds_done("moscow") == 1, "interrupted pointing chapter resumes without duplicate awards")
	world.queue_free()
	await process_frame
	print("MOSCOW STORY: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

func load_world() -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load("res://scenes/world/MoscowBasmanny.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(6):
		await process_frame
	get_first_node_in_group("player").position = Vector2(284, 615)

func play(chapter: int) -> void:
	finished = false
	start()
	var frames := 0
	while not finished and frames < 2200:
		frames += 1
		await process_frame
		var dialog := get_first_node_in_group("dialogue_box")
		if preload("res://tools/StoryTestUI.gd").discovery(self): continue
		var thought := get_first_node_in_group("thought_box")
		var cinema := get_first_node_in_group("cutscene")
		if dialog.visible:
			if captures and not capture_done.has(str(chapter) + "-dialog"):
				await capture(str(chapter) + "-dialog")
			if cancelled:
				cancelled = false
				dialog._close()
			else:
				var options: Array = dialog._entries[dialog._index]["responses"]
				dialog._on_response(options[mini(strategy, options.size()-1)])
		elif thought.visible:
			thought.hide()
			paused = false
		elif cinema._open:
			cinema._advance()
		else:
			var director := get_first_node_in_group("story_director")
			if director == null:
				continue
			if not director._frozen:
				var visitor := world.get_node_or_null("Encounter")
				if visitor != null and not capture_done.has("encounter-check"):
					capture_done["encounter-check"] = true
					var before: Vector2 = visitor.position
					visitor._physics_process(2.0)
					check(visitor.position == before and visitor._state != "talking", "forced encounter waits during a physical story beat")
				if captures and not capture_done.has(str(chapter)+"-carry"):
					await capture(str(chapter)+"-carry")
				var player := get_first_node_in_group("player") as Node2D
				var targets: Array = []
				for prop in director.props.values():
					if is_instance_valid(prop) and prop.pointable and prop.visible:
						targets.append(prop)
				if not targets.is_empty():
					if cancel_carry:
						cancel_carry = false
						check(gs.carrying.is_empty(), "pointing does not create a load")
						return
					var wanted: String = "new" if strategy == 0 else "old"
					if chapter == 3:
						wanted = "jam" if strategy == 0 else "plain"
					var prop: Node2D = targets[0]
					for candidate in targets:
						if candidate.id == wanted:
							prop = candidate
					player.set_physics_process(false)
					var approach: Vector2 = prop.position + Vector2(0, 29)
					# Walk along the clear near side, then approach the chosen tray.
					var target: Vector2 = approach
					if absf(player.position.x - approach.x) > 20:
						target = Vector2(player.position.x, 615) if player.position.y < 614 else Vector2(approach.x, 615)
					player.move_and_collide(player.position.direction_to(target) * minf(3.0, player.position.distance_to(target)))
					if player.position.distance_to(prop.position) <= 42:
						prop._process(0.01)
						var event := InputEventAction.new()
						event.action = "interact"
						event.pressed = true
						prop._unhandled_input(event)

			else:
				for actor in director.actors.values():
					if is_instance_valid(actor) and actor.is_walking():
						actor._process(10)
				director._process(30)
	if not finished:
		print("Stalled at ", get_first_node_in_group("player").position, " carrying ", gs.carrying,
			" checkpoint ", gs.world_flags.get("moscow_story", {}).get("resume", {}))
	check(finished, "chapter %d returns control" % chapter)
	if not finished:
		quit(1)
		await process_frame
	await process_frame

func start() -> void:
	await root.get_node("Journey").talk("moscow")
	finished = true

func capture(label: String) -> void:
	capture_done[label] = true
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + label + ".png")
