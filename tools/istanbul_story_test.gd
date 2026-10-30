extends SceneTree

const SCRIPT := preload("res://scenes/story/istanbul/IstanbulScript.gd")
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
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/istanbul-story-review"


func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ISTANBUL STORY: " + message)

func _run() -> void:
	gs = root.get_node("GameState")
	root.get_node("SaveManager").use_test_storage("istanbul-story")
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
			for option: Dictionary in step.get("options", []):
				destinations.append(option.get("go", ""))
			for destination: String in destinations:
				check(destination.is_empty() or labels.has(destination), chapter + " valid branch " + destination)
	for route in range(3):
		gs.reset()
		gs.city = "istanbul"
		gs.world_flags["han_seen"] = true
		gs.quests["find_bed"] = {"completed": true, "steps": []}
		strategy = route
		await load_world()
		for chapter in range(4):
			if chapter >= 1:
				gs.world_flags["spot_carsi"] = true
			if chapter >= 2:
				gs.world_flags["spot_han"] = true
				gs.world_flags["spot_karakoy"] = true
			await play(chapter)
			check(gs.world_flags.get("istanbul_story", {}).get("done", {}).get(str(chapter), false), "route %d chapter %d complete" % [route, chapter])
		check(root.get_node("Story").holiday_seen("istanbul"), "celebration complete")
		check(gs.understanding("turkish", "misafir").has("meaning"), "guest discovered in context")
		check(gs.understanding("turkish", "bekleyebilir").has("meaning"), "asking to wait is repaired or understood")
		check(world.get_node("KeyArda").visible and world.get_node("KeyArda").collision_layer != 0, "original Arda restored after stage")
		check(get_first_node_in_group("player").is_physics_processing(), "movement restored")
		print("ISTANBUL ROUTE ", route, " complete")
	# A cancelled answer must not earn a round, and resume must recreate props.
	gs.reset()
	gs.city = "istanbul"
	gs.world_flags["han_seen"] = true
	gs.quests["find_bed"] = {"completed":true, "steps":[]}
	await load_world()
	cancelled = true
	await play(0)
	check(root.get_node("Story").rounds_done("istanbul") == 0, "cancelled question has no friendship award")
	await load_world()
	await play(0)
	check(root.get_node("Story").rounds_done("istanbul") == 1, "cancelled question resumes")
	world.queue_free()
	await process_frame
	print("ISTANBUL STORY: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

func load_world() -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load("res://scenes/world/IstanbulHan.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(6):
		await process_frame
	get_first_node_in_group("player").position = Vector2(844, 590)

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
				if captures and not capture_done.has(str(chapter)+"-carry"):
					await capture(str(chapter)+"-carry")
				var player := get_first_node_in_group("player") as Node2D
				if gs.carrying.is_empty():
					for prop in director.props.values():
						if is_instance_valid(prop) and prop.carryable and prop.visible:
							player.set_physics_process(false)
							var approach: Vector2 = prop.position + Vector2(-42, 12)
							player.move_and_collide(player.position.direction_to(approach) * minf(3.0, player.position.distance_to(approach)))
							if player.position.distance_to(prop.position) > 44.0:
								break
							prop._process(0.01)
							var event := InputEventAction.new()
							event.action = "interact"
							event.pressed = true
							prop._unhandled_input(event)
							break
				else:
					for node in world.get_children():
						if node.get_script() == load("res://scenes/story/StoryZone.gd"):
							player.set_physics_process(false)
							player.move_and_collide(player.position.direction_to(node.position) * minf(3.0, player.position.distance_to(node.position)))
			else:
				for actor in director.actors.values():
					if is_instance_valid(actor) and actor.is_walking():
						actor._process(10)
				director._process(30)
	if not finished:
		print("Stalled at ", get_first_node_in_group("player").position, " carrying ", gs.carrying,
			" checkpoint ", gs.world_flags.get("istanbul_story", {}).get("resume", {}))
	check(finished, "chapter %d returns control" % chapter)
	if not finished:
		quit(1)
		await process_frame
	await process_frame

func start() -> void:
	await root.get_node("Journey").talk("istanbul")
	finished = true

func capture(label: String) -> void:
	capture_done[label] = true
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + label + ".png")
