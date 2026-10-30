extends SceneTree

var STORY: Script
const SCRIPT := preload("res://scenes/story/berlin/BerlinScript.gd")
const LATE := preload("res://scenes/story/berlin/BerlinScriptLate.gd")
var gs: Node
var world: Node
var stage: Node
var failures := 0
var checks := 0
var driving := false
var exited := false
var strategy := 0
var captures := false
var capture_done: Dictionary = {}
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/berlin-story-review"

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("BERLIN STORY: " + message)

func _run() -> void:
	STORY = load("res://scenes/story/berlin/BerlinStory.gd")
	root.get_node("SaveManager").use_test_storage("berlin-story")
	gs = root.get_node("GameState")
	captures = OS.get_cmdline_user_args().has("--capture")
	DirAccess.make_dir_recursive_absolute(out)
	for chapter: String in SCRIPT.CHAPTERS.keys() + LATE.CHAPTERS.keys():
		var steps: Array = STORY.steps(chapter)
		var labels := {}
		for step: Dictionary in steps:
			if step.get("do", "") == "label":
				check(not labels.has(step["name"]), chapter + " unique label " + step["name"])
				labels[step["name"]] = true
		for step: Dictionary in steps:
			var destinations: Array = []
			if step.get("do", "") == "goto":
				destinations.append(step.get("to", ""))
			if step.get("do", "") == "if":
				destinations.append(step.get("then", ""))
				destinations.append(step.get("else", ""))
			for option: Dictionary in step.get("options", []):
				destinations.append(option.get("go", ""))
			for destination: String in destinations:
				check(destination.is_empty() or labels.has(destination), chapter + " destination " + destination)
	for branch in range(3):
		strategy = branch
		gs.reset()
		gs.quests["find_bed"] = {"completed": true, "steps": []}
		await load_street(STORY.MITTE)
		await play("1")
		check(STORY.done("1"), "physical crates finish the introduction")
		check(gs.understanding("german", "pfand").has("meaning"), "Pfand confirmed through demonstration")
		check(root.get_node("Story").rounds_done("berlin") == 1, "one friendship round")
		check(STORY.due_kerstin() == "wait_morgen", "tomorrow is an intelligible transition")
		gs.world_flags["nights"] = 1
		await play("2")
		check(STORY.done("2"), "second chapter completes")
		check(STORY.flag("bag") == true, "actual errand entrusted")
		await load_street(STORY.PRENZLBERG)
		await play("3")
		check(STORY.done("3"), "Emil receives the bag")
		check(gs.carrying.is_empty(), "bag removed from the player's hands")
		await load_street(STORY.MITTE)
		await play("3b")
		check(STORY.done("3b"), "message can be carried back correctly or repaired")
		gs.world_flags["nights"] = 2
		await play("4")
		check(STORY.done("4") and root.get_node("Story").holiday_seen("berlin"), "Saturday reaches the holiday ending")
		check(gs.quests["journey_berlin"]["steps"].size() == 5, "Berlin intention has the right step count")
		check(get_first_node_in_group("player").is_physics_processing(), "player regains control")
		print("BERLIN ROUTE ", branch, " complete")
	# Old menu-chapter saves must not repeat earned story rounds or leave a sixth step.
	gs.reset()
	gs.world_flags["story_rounds_berlin"] = 3
	gs.world_flags["story_holiday_berlin"] = true
	gs.start_quest("journey_berlin", "old", ["a", "b", "c", "d", "e", "f"])
	STORY.guide()
	check(STORY.done("4") and gs.quests["journey_berlin"]["completed"], "completed old saves migrate")
	check(gs.quests["journey_berlin"]["steps"].size() == 5, "old sixth step removed")
	# Resume from a physical checkpoint, including a fresh scene instance.
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	await load_street(STORY.MITTE)
	var director: Node = load("res://scenes/story/StoryDirector.gd").new()
	stage.add_child(director)
	director.host = world
	director.story = stage.story
	director.cast = stage.story.cast()
	director.actors = stage._people.duplicate()
	director.props = stage._things.duplicate()
	stage.story.save_stage("1", director.snapshot())
	stage.story.checkpoint("1", "carry")
	director._freeze(true)
	director.queue_free()
	await process_frame
	check(get_first_node_in_group("player").is_physics_processing(), "director teardown restores player movement")
	await load_street(STORY.MITTE)
	await play("1")
	check(STORY.done("1"), "carry checkpoint resumes with props reconstructed")
	world.queue_free()
	await process_frame
	print("BERLIN STORY: ", checks, " checks; ", failures, " failures")
	quit(1 if failures else 0)

func load_street(path: String) -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load(path).instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(5):
		await process_frame
	stage = get_first_node_in_group("berlin_stage")

func play(chapter: String) -> void:
	driving = true
	exited = false
	finish_play(chapter)
	var frames := 0
	while not exited and frames < 2200:
		frames += 1
		await process_frame
		var dialog := get_first_node_in_group("dialogue_box")
		if preload("res://tools/StoryTestUI.gd").discovery(self): continue
		var thought := get_first_node_in_group("thought_box")
		var cinema := get_first_node_in_group("cutscene")
		if dialog.visible:
			if captures and not capture_done.has(chapter + "-dialog"):
				await capture(chapter + "-dialog")
			var options: Array = dialog._entries[dialog._index]["responses"]
			dialog._on_response(options[mini(strategy, options.size() - 1)])
		elif thought.visible:
			thought.hide()
			paused = false
		elif cinema._open:
			cinema._advance()
		elif stage.busy():
			var director: Node = stage.get_child(stage.get_child_count() - 1)
			if not director.has_method("running"):
				continue
			if not director._frozen:
				if captures and not capture_done.has(chapter + "-carry"):
					await capture(chapter + "-carry")
				var player := get_first_node_in_group("player") as Node2D
				if gs.carrying.is_empty():
					for prop in director.props.values():
						if is_instance_valid(prop) and prop.carryable and prop.visible:
							player.position = prop.position
							prop._process(0.01)
							var event := InputEventAction.new()
							event.action = "interact"
							event.pressed = true
							prop._unhandled_input(event)
							break
				else:
					for node in world.get_children():
						if node.get_script() == load("res://scenes/story/StoryZone.gd"):
							player.position = node.position
			else:
				for actor in director.actors.values():
					if is_instance_valid(actor) and actor.is_walking():
						actor._process(10.0)
				director._process(30.0)
	check(exited, "chapter " + chapter + " finishes without a stuck wait")
	if not exited:
		push_error("Timed out chapter " + chapter)
		quit(1)
		await process_frame
	driving = false
	await process_frame

func finish_play(chapter: String) -> void:
	await stage.play(chapter)
	exited = true

func capture(label: String) -> void:
	capture_done[label] = true
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/" + label + ".png")
