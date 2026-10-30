extends SceneTree

# Real scenes and collision movement; isolated saves/settings. Run with -- CITY
# and optionally --capture. Choices cover misunderstandings, help and refusal.
const SPECS := {
	"mumbai":{"scene":"MumbaiBhuleshwar", "key":"KeyOmkar", "script":"MumbaiScript", "spawn":[625,615], "outings":["chorbazaar", "bhuleshwar", "colaba"], "language":"hindi", "words":["raasta", "baad", "theek", "thoda"], "point_chapter":1, "wrong":"phone", "right":"sketch", "misread":"baad", "prop":"chair"},
	"tokyo":{"scene":"TokyoUeno", "key":"KeySetsuko", "script":"TokyoScript", "spawn":[476,615], "outings":["asakusa", "ueno", "yanaka"], "language":"japanese", "words":["mochiyasui", "daijoubu", "hikui", "musunde"], "point_chapter":0, "wrong":"slim", "right":"wide", "misread":"mochiyasui", "prop":"bamboo"},
	"mexico":{"scene":"MexicoCoyoacan", "key":"KeyRocio", "script":"MexicoScript", "spawn":[560,615], "outings":["merced", "coyoacan", "roma"], "language":"spanish_mx", "words":["esa", "taza", "nombre", "tapar"], "point_chapter":0, "wrong":"flowers", "right":"cup", "misread":"esa", "prop":"table"}
}
var city := "mumbai"
var spec: Dictionary
var chapters: Dictionary
var gs: Node
var world: Node
var failures := 0
var checks := 0
var finished := false
var strategy := 0
var capture_done := {}
var captures := false
var cancelled := false
var interrupt_point := false
var out: String

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(city.to_upper() + " STORY: " + message)

func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if SPECS.has(arg):
			city = arg
	spec = SPECS[city]
	chapters = load("res://scenes/story/%s/%s.gd" % [city,spec.script]).CHAPTERS
	gs = root.get_node("GameState")
	root.get_node("SaveManager").use_test_storage(city + "-story")
	captures = OS.get_cmdline_user_args().has("--capture")
	out = "C:/Users/Arda/Documents/ForeignToAll/work/beta/" + city + "-story-review"
	DirAccess.make_dir_recursive_absolute(out)
	if city == "mexico":
		var pairs: Array = load("res://scenes/story/StoryDirector.gd").pairs_of("¿Dónde? ¡Aquí!")
		check(pairs[0][1] == "dónde" and pairs[1][1] == "aquí", "Spanish punctuation does not change learned word keys")
	for chapter: String in chapters:
		var labels := {}
		for step: Dictionary in chapters[chapter]:
			if step.get("do", "") == "label":
				check(not labels.has(step["name"]), chapter + " unique label " + step["name"])
				labels[step["name"]] = true
		for step: Dictionary in chapters[chapter]:
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
		fresh()
		strategy = route
		await load_world()
		for chapter in range(4):
			unlock(chapter)
			await play(chapter)
			check(gs.world_flags.get(city + "_story", {}).get("done", {}).get(str(chapter), false), "route %d chapter %d complete" % [route,chapter])
		check(root.get_node("Story").holiday_seen(city), "celebration completes")
		for word: String in spec.words:
			check(gs.understanding(spec.language, word).has("meaning"), "meaning discovered: " + word)
		if route == 0:
			check(not String(gs.understanding(spec.language, spec.misread).get("first", "")).is_empty(), "first mistaken interpretation retained")
		check(world.get_meta("street_story_" + city, {}).get("props", {}).has(spec.prop), "placed object survives conversation")
		check(world.get_node(spec.key).visible and world.get_node(spec.key).collision_layer != 0, "original friend restored")
		check(get_first_node_in_group("player").is_physics_processing(), "movement restored")
		verify_callback(route)
		print(city.to_upper(), " ROUTE ", route, " complete")
	fresh()
	await load_world()
	cancelled = true
	await play(0)
	check(root.get_node("Story").rounds_done(city) == 0, "cancelled answer has no friendship award")
	await load_world()
	await play(0)
	check(root.get_node("Story").rounds_done(city) == 1, "question resumes after cancellation")
	# Test departure while the player has control of a physical choice.
	fresh()
	await load_world()
	strategy = 0
	for chapter in range(int(spec.point_chapter)):
		unlock(chapter)
		await play(chapter)
	unlock(int(spec.point_chapter))
	interrupt_point = true
	await play(int(spec.point_chapter))
	world.queue_free()
	await process_frame
	check(not root.get_node("Journey").busy, "scene departure releases conversation lock")
	check(gs.carrying.is_empty(), "scene departure clears temporary load")
	check(root.get_node("SaveManager").load_game(-1), "isolated checkpoint loads")
	await load_world()
	await play(int(spec.point_chapter))
	check(root.get_node("Story").rounds_done(city) == int(spec.point_chapter) + 1, "pointing resumes without duplicate awards")
	world.queue_free()
	await process_frame
	print(city.to_upper(), " STORY: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

func fresh() -> void:
	gs.reset()
	gs.city = city
	gs.world_flags[city + "_arrived"] = true
	gs.quests["find_bed"] = {"completed":true, "steps":[]}

func unlock(chapter: int) -> void:
	if chapter >= 1:
		gs.world_flags["spot_" + String(spec.outings[0])] = true
	if chapter >= 2:
		for district: String in spec.outings:
			gs.world_flags["spot_" + district] = true

func verify_callback(route: int) -> void:
	var flags: Dictionary = gs.world_flags[city + "_story"]["flags"]
	var reel: Array = root.get_node("Journey").holiday_reel(city)
	if city == "mumbai":
		check(bool(flags.get("picture_notice", false)) == (route == 2), "readers' notice decision retained")
		check(bool(flags.get("helped_chair", false)) == (route == 0), "chair help or refusal retained")
		check(("large time" in String(reel[1]["say"])) == (route == 2), "ending remembers notice")
		check(("welcome someone" in String(reel[3]["say"])) == (route > 0), "ending remembers participation preference")
	elif city == "tokyo":
		check(String(flags.get("wish", "")) == ["home","return","blank"][route], "own wish retained")
		check(bool(flags.get("public_wish", false)) == (route == 0), "display permission retained")
		check(("low branch" in String(reel[2]["say"])) == (route == 0), "ending remembers display permission")
		check(["towards home","returning arrow","still blank"][route] in String(reel[4]["say"]), "ending remembers own wish")
	elif city == "mexico":
		check(bool(flags.get("portrait", false)) == (route == 0), "portrait preference retained")
		check(bool(flags.get("record_flowers", false)) == (route == 2), "specific recording permission retained")
		check(bool(flags.get("carried_flowers", false)) == (route == 0), "physical help or refusal retained")
		check(("Rocío and me" in String(reel[2]["say"])) == (route == 0), "ending remembers portrait preference")
		check(("little clip" in String(reel[3]["say"])) == (route == 2), "ending remembers the offered recording")

func load_world() -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load("res://scenes/world/" + String(spec.scene) + ".tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(6):
		await process_frame
	get_first_node_in_group("player").position = Vector2(spec.spawn[0],spec.spawn[1])

func play(chapter: int) -> void:
	finished = false
	start()
	var frames := 0
	while not finished and frames < 2600:
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
				dialog._on_response(options[mini(strategy,options.size()-1)])
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
				if captures and not capture_done.has(str(chapter) + "-action"):
					await capture(str(chapter) + "-action")
				var player := get_first_node_in_group("player") as CharacterBody2D
				player.set_physics_process(false)
				var targets: Array = []
				for prop in director.props.values():
					if is_instance_valid(prop) and (prop.pointable or prop.carryable) and prop.visible:
						targets.append(prop)
				if not targets.is_empty() and gs.carrying.is_empty():
					if interrupt_point and targets[0].pointable:
						interrupt_point = false
						return
					var wanted: String = spec.wrong if strategy == 0 else spec.right
					var prop: Node2D = targets[0]
					for candidate in targets:
						if candidate.id == wanted:
							prop = candidate
					move_towards(player, prop.position + Vector2(0,29))
					if player.position.distance_to(prop.position) <= 42:
						prop._process(0.01)
						var event := InputEventAction.new()
						event.action = "interact"
						event.pressed = true
						prop._unhandled_input(event)
				elif not gs.carrying.is_empty():
					for node in world.get_children():
						if node.get_script() == load("res://scenes/story/StoryZone.gd"):
							move_towards(player, node.position)
			else:
				for actor in director.actors.values():
					if is_instance_valid(actor) and actor.is_walking():
						actor._process(10)
				director._process(30)
	if not finished:
		print("Stalled at ", get_first_node_in_group("player").position, " carrying ", gs.carrying, " checkpoint ", gs.world_flags.get(city + "_story", {}).get("resume", {}))
	check(finished, "chapter %d returns control" % chapter)
	if not finished:
		quit(1)
		await process_frame
	await process_frame

func move_towards(player: CharacterBody2D, destination: Vector2) -> void:
	var target := destination
	# Approach from the near-side lane in small real collision steps.
	if absf(player.position.x - destination.x) > 20:
		target = Vector2(player.position.x,615) if player.position.y < 614 else Vector2(destination.x,615)
	player.move_and_collide(player.position.direction_to(target) * minf(3.0,player.position.distance_to(target)))

func start() -> void:
	await root.get_node("Journey").talk(city)
	finished = true

func capture(label: String) -> void:
	capture_done[label] = true
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + label + ".png")
