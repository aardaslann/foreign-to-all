extends SceneTree

# Real-time gameplay footage for the Steam page, recorded with Godot's movie
# writer (fixed 30 fps, so every frame is the game's own render at real pace).
#   <godot> --path . --write-movie out.avi --fixed-fps 30 \
#     --script res://tools/steam_film_capture.gd -- berlin
#   ... -- walk <scene.tscn> <local hour> <seconds> <spawn x> <direction>
# "berlin" plays chapter 1 (route 0) the way a player would: it reads each
# line, walks to the crates with the walk actions and carries them, and holds
# on every word-discovery panel before and after the meaning.

const FPS := 30
const ARRIVE := 14.0
var gs: Node
var world: Node
var stage: Node
var exited := false

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	root.get_node("SaveManager").use_test_storage("steam-film")
	gs = root.get_node("GameState")
	gs.reset()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	if args[0] == "berlin":
		await berlin()
	else:
		await walk(args[1], float(args[2]), float(args[3]), float(args[4]), float(args[5]))
	quit(0)

func hold(seconds: float) -> void:
	for i in range(int(seconds * FPS)):
		await process_frame

func load_street(path: String, local_hour := -1.0) -> void:
	world = load(path).instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	if local_hour >= 0.0:
		var clock: Script = load("res://autoload/JourneyClock.gd")
		var offset: float = clock.offset(gs.city)
		var base := floorf((gs.clock_minutes + offset) / 1440.0) * 1440.0
		gs.clock_minutes = base + local_hour * 60.0 - offset
	for i in range(6):
		await process_frame

func walk(path: String, hour: float, seconds: float, x: float, direction: float) -> void:
	await load_street(path, hour)
	var player := get_first_node_in_group("player") as Node2D
	player.position.x = x
	await hold(0.6)
	var thought := get_first_node_in_group("thought_box")
	if thought != null and thought.visible:
		await hold(3.4)
		thought.hide()
		paused = false
		await hold(0.3)
	var action := "walk_right" if direction > 0.0 else "walk_left"
	Input.action_press(action)
	await hold(seconds)
	Input.action_release(action)
	await hold(0.8)

func berlin() -> void:
	var story: Script = load("res://scenes/story/berlin/BerlinStory.gd")
	await load_street(story.MITTE, 7.5)
	stage = get_first_node_in_group("berlin_stage")
	await hold(1.5)
	exited = false
	finish_play("1")
	var frames := 0
	while not exited and frames < FPS * 240:
		frames += 1
		await process_frame
		var panel := get_first_node_in_group("word_discovery")
		if panel != null and panel._open:
			release_walk()
			await hold(2.8)
			panel.reveal()
			await hold(3.4)
			panel._process(0.25)
			panel._advance()
			continue
		var dialog := get_first_node_in_group("dialogue_box")
		var thought := get_first_node_in_group("thought_box")
		var cinema := get_first_node_in_group("cutscene")
		if dialog.visible:
			release_walk()
			await hold(3.6)
			if dialog.visible:
				var options: Array = dialog._entries[dialog._index]["responses"]
				dialog._on_response(options[0])
				await hold(0.4)
		elif thought.visible:
			release_walk()
			await hold(3.5)
			thought.hide()
			paused = false
		elif cinema._open:
			await hold(2.0)
			cinema._advance()
		elif stage.busy():
			var director: Node = stage.get_child(stage.get_child_count() - 1)
			if director.has_method("running") and not director._frozen:
				steer(director)
			else:
				release_walk()
	release_walk()
	await hold(2.0)

# Walk the way a player would: towards the next crate, or to the drop zone
# while carrying one, pressing interact on arrival.
func steer(director: Node) -> void:
	var player := get_first_node_in_group("player") as Node2D
	var target := Vector2.INF
	var prop: Node = null
	if gs.carrying.is_empty():
		for p in director.props.values():
			if is_instance_valid(p) and p.carryable and p.visible:
				prop = p
				target = p.position
				break
	else:
		for node in world.get_children():
			if node.get_script() == load("res://scenes/story/StoryZone.gd"):
				target = node.position
				break
	if target == Vector2.INF:
		release_walk()
		return
	var to := target - player.position
	if to.length() <= ARRIVE:
		release_walk()
		if prop != null:
			prop._process(0.01)
			var event := InputEventAction.new()
			event.action = "interact"
			event.pressed = true
			prop._unhandled_input(event)
		else:
			player.position = target
		return
	var d := to.normalized()
	press("walk_right", maxf(d.x, 0.0))
	press("walk_left", maxf(-d.x, 0.0))
	press("walk_down", maxf(d.y, 0.0))
	press("walk_up", maxf(-d.y, 0.0))

func press(action: String, strength: float) -> void:
	if strength > 0.05:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)

func release_walk() -> void:
	for a in ["walk_left", "walk_right", "walk_up", "walk_down"]:
		Input.action_release(a)

func finish_play(chapter: String) -> void:
	await stage.play(chapter)
	exited = true
