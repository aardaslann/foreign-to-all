extends SceneTree

# Isolated intro review: rendered shot evidence plus the actual new-game,
# pause, skip and automatic handoff paths. --movie runs the unbroken opening.
var checks := 0
var failures := 0
var out := "res://.build/intro-review"
var gs: Node
var saves: Node


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, detail: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("INTRO: " + detail)


func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame


func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	check(img != null and not img.is_empty(), "rendered " + name)
	check(img.save_png(out.path_join(name + ".png")) == OK, "saved " + name)


func new_intro() -> Node:
	change_scene_to_file("res://scenes/cutscene/IntroCutscene.tscn")
	await frames()
	return current_scene


func _run() -> void:
	gs = root.get_node("GameState")
	saves = root.get_node("SaveManager")
	saves.use_test_storage("intro-review")
	root.get_node("Loc").set_language("en")
	gs.reset()
	var args := OS.get_cmdline_user_args()
	for arg: String in args:
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(out)
	if args.has("--movie"):
		await new_intro()
		await create_timer(29.5).timeout
		check(current_scene.scene_file_path == "res://scenes/world/Kiez.tscn", "unbroken opening reaches the street")
		_finish()
		return
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames()
	current_scene._on_new_game()
	await create_timer(0.85).timeout
	check(current_scene.scene_file_path.ends_with("CharacterCreator.tscn"), "New Journey enters creator first")
	current_scene._confirm()
	await create_timer(0.85).timeout
	var intro: Node = current_scene
	check(intro.scene_file_path.ends_with("IntroCutscene.tscn"), "New Journey enters intro")
	check(intro.get_script().can_instantiate(), "intro compiles")
	check(intro._stage.get_script().can_instantiate(), "stage compiles")
	check(intro._audio.bus == "SFX", "sound obeys effects volume")
	check(absf(intro._audio.stream.get_length() - intro.DURATION) < 0.05, "audio covers the timeline")
	check(gs.familiarity.is_empty(), "intro awards no vocabulary")
	check(gs.quests.is_empty(), "intro does not start or complete quests")
	intro._time = 0.2
	intro._go_to_game()
	check(not intro._done, "menu input cannot immediately dismiss opening")
	intro._time = 2.0
	intro._present()
	intro._pause_button.pressed.emit()
	var frozen: float = intro._time
	await create_timer(0.15).timeout
	check(intro._time == frozen and intro._audio.stream_paused, "pause freezes animation and sound")
	intro._pause_button.pressed.emit()
	await frames()
	check(intro._time > frozen and not intro._audio.stream_paused, "resume restores animation and sound")
	intro.set_process(false)
	intro._audio.stop()
	var shots := {"01-orbit": 2.8, "02-entry": 5.9, "03-berlin": 8.4,
		"04-descent": 10.2, "05-wreck": 13.3, "06-emerge": 16.7,
		"07-approach": 19.0, "08-connection": 21.8, "09-chapter": 25.3}
	for name: String in shots:
		intro._time = float(shots[name])
		intro._present()
		await frames()
		await capture(name)
	# Expanded or narrower windows preserve the full composition and controls.
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(2560, 1080), Vector2i(1024, 768)]:
		root.content_scale_size = dimensions
		if DisplayServer.get_name() != "headless":
			root.size = dimensions
		await frames()
		intro._fit()
		var frame: Control = intro._frame
		check(frame.position.x >= -1 and frame.position.y >= -1, "frame begins on screen " + str(dimensions))
		check(frame.position.x + frame.size.x * frame.scale.x <= intro.size.x + 1, "frame fits width " + str(dimensions))
		check(frame.position.y + frame.size.y * frame.scale.y <= intro.size.y + 1, "frame fits height " + str(dimensions))
		check(not intro._pause_button.get_rect().intersects(intro._skip_button.get_rect()), "controls do not overlap")
		await capture("layout-%dx%d" % [dimensions.x, dimensions.y])
	root.content_scale_size = Vector2i(1920, 1080)
	if DisplayServer.get_name() != "headless":
		root.size = Vector2i(1920, 1080)
	await frames()
	saves.settings["reduce_motion"] = true
	intro = await new_intro()
	check(intro._stage.reduced_motion, "reduced motion follows existing setting")
	intro.set_process(false)
	intro._time = 21.8
	intro._present()
	await frames()
	await capture("reduced-motion")
	var pause_event := InputEventJoypadButton.new()
	pause_event.button_index = JOY_BUTTON_START
	pause_event.pressed = true
	intro._unhandled_input(pause_event)
	check(intro._paused, "controller Start pauses")
	var skip := InputEventJoypadButton.new()
	skip.button_index = JOY_BUTTON_A
	skip.pressed = true
	intro._unhandled_input(skip)
	check(intro._done, "controller can skip while paused")
	intro._go_to_game()
	await create_timer(0.8).timeout
	check(current_scene.scene_file_path == "res://scenes/world/Kiez.tscn", "skip reaches playable Kiez exactly once")
	check(not paused, "game is not left paused")
	check(gs.quests.has("first_trade"), "normal opening quest starts on the street")
	check(gs.familiarity.is_empty(), "skip does not grant language progress")
	var player := current_scene.get_node("Player")
	var background := current_scene.get_node("WreckageBackground")
	var expected := Vector2(405, remap(560.0, 300.0, 640.0, background.floor_y() + 6.0, 636.0))
	check(player.position.distance_to(expected) < 5, "player retains authored safe arrival: " + str(player.position))
	await capture("handoff-kiez")
	saves.settings["reduce_motion"] = false
	intro = await new_intro()
	intro._time = intro.DURATION - 0.01
	intro._process(0.02)
	await create_timer(0.8).timeout
	check(current_scene.scene_file_path == "res://scenes/world/Kiez.tscn", "automatic end reaches playable Kiez")
	_finish()


func _finish() -> void:
	print("INTRO REVIEW: ", checks, " checks, ", failures, " failures; ", ProjectSettings.globalize_path(out))
	quit(1 if failures else 0)
