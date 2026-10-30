extends SceneTree

var checks := 0
var failures := 0
var out := ""

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("PACKAGE: " + message)

func frames(count := 4) -> void:
	for i in range(count): await process_frame

func wait_scene(suffix: String) -> void:
	for i in range(100):
		if current_scene != null and current_scene.scene_file_path.ends_with(suffix): return
		await create_timer(0.05).timeout

func shot(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(not picture.is_empty(), "rendered " + name)
	check(picture.save_png(out.path_join(name + ".png")) == OK, "captured " + name)

func _run() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	var editor_host := OS.get_cmdline_user_args().has("--editor-host")
	if not editor_host: check(not OS.is_debug_build(), "real release template")
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("packaged-smoke")
	root.get_node("Loc").set_language("en")
	await frames()
	if not editor_host: check(root.get_node_or_null("DevConsole") == null, "no developer console in release")
	check(not DirAccess.dir_exists_absolute("res://tools"), "tools absent from package")
	check(not DirAccess.dir_exists_absolute("res://art/environments/review"), "review captures absent")
	for file: String in ["layouts", "fullsize", "berlin-gameplay", "istanbul-gameplay", "city-gameplay", "object-geometry", "lettering", "activity-world", "activity-plates", "city-activity-plates", "activity-staging", "city-activity-staging", "activity-sets", "activity-direction"]:
		check(FileAccess.file_exists("res://art/environments/" + file + ".json"), "runtime data bundled " + file)
	check(FileAccess.file_exists("res://audio/voice/manifest.json"), "voice manifest bundled")
	for city: String in root.get_node("GameState").CITIES:
		check(ResourceLoader.exists("res://audio/music/" + city + ".ogg"), "city music bundled " + city)
	check(load("res://scenes/title/ReleaseCredits.gd").notices().contains("SIL OPEN FONT LICENSE"), "font notices bundled")
	var credits_text: String = load("res://scenes/title/ReleaseCredits.gd").TEXT.to_lower()
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames(12)
	await shot("title")
	current_scene._on_settings()
	await frames()
	await shot("settings")
	current_scene._overlay._tabs.current_tab = 5
	await frames()
	var credit_labels: Array[Node] = current_scene._overlay._page.find_children("*", "RichTextLabel", false, false)
	check(credit_labels.size() == 1 and credit_labels[0].text.to_lower() == credits_text, "packaged credits tab uses current text")
	await shot("credits")
	current_scene._overlay._go_back()
	await frames()
	current_scene._on_new_game()
	await wait_scene("CharacterCreator.tscn")
	check(current_scene.scene_file_path.ends_with("CharacterCreator.tscn"), "creator entered")
	current_scene._choose("skin", 2)
	current_scene._choose("coat", 4)
	await shot("creator")
	current_scene._confirm()
	await wait_scene("IntroCutscene.tscn")
	await create_timer(0.9).timeout
	check(current_scene.scene_file_path.ends_with("IntroCutscene.tscn"), "opening entered")
	await shot("opening")
	current_scene._go_to_game()
	await wait_scene("Kiez.tscn")
	await frames(8)
	check(current_scene.scene_file_path.ends_with("Kiez.tscn"), "playable opening entered")
	check(root.get_node("GameState").alien_appearance.skin == 2, "custom alien survives release opening")
	check(saves.save_game(0) and saves.load_game(0), "release save round-trip")
	var state := root.get_node("GameState")
	check(state.clock_text().length() == 5, "packaged 24-hour clock")
	state.set_process(false)
	state.clock_minutes = 1380
	check(saves.save_game(0) and saves.load_game(0) and state.clock_minutes == 1380, "packaged night save round-trip")
	check(current_scene.get_node_or_null("DayNightLighting") != null, "packaged shared world lighting")
	check(current_scene.get_node("UILayer/HudBar")._clock_chip != null, "packaged top-left clock")
	await shot("kiez")
	var story := root.get_node("Story")
	for city: String in story.MANDATORY:
		var scene: String = story.path(story.SCENE[city])
		check(ResourceLoader.exists(scene), "core street bundled " + city)
		change_scene_to_file(scene)
		await frames(8)
		check(current_scene != null and current_scene.scene_file_path == scene, "core street instantiates " + city)
	var places: Dictionary = load("res://scenes/world/ActivityPlaces.gd").catalog().get("places", {})
	check(places.size() == 44, "all 44 activity locations in release data")
	for id: String in places:
		check(ResourceLoader.exists("res://scenes/world/activities/" + id + ".tscn"), "activity bundled " + id)
	change_scene_to_file("res://scenes/world/activities/ActivityBerlinSpati.tscn")
	await frames(8)
	await shot("spati")
	change_scene_to_file("res://scenes/world/Airport.tscn")
	await frames(8)
	root.get_node("Services")._airport_desk()
	get_first_node_in_group("world_map")._close("istanbul")
	await frames()
	var flight := get_first_node_in_group("flight_cutscene")
	check(flight != null, "airport confirmation opens the packaged flight")
	if flight != null:
		flight._process(3.0)
		check(flight._stage.SKY != null and flight._stage.PLANE != null, "flight artwork bundled")
		await shot("flight")
		flight._request_finish()
		await wait_scene("IstanbulHavalimani.tscn")
		await frames(8)
		check(current_scene.scene_file_path.ends_with("IstanbulHavalimani.tscn"), "packaged flight reaches destination airport")
		check(get_first_node_in_group("flight_cutscene") == null, "packaged flight releases overlay")
		check(saves.load_game(-1) and saves.pending_scene.ends_with("IstanbulHavalimani.tscn"), "packaged flight checkpoint loads at airport")
		change_scene_to_file(saves.pending_scene)
		await frames(8)
		var wallet: Dictionary = root.get_node("GameState").wallet.duplicate(true)
		await shot("arrival-terminal")
		current_scene.get_node("Exit")._go()
		await wait_scene("IstanbulMetro.tscn")
		await create_timer(0.5).timeout
		root.get_node("Services")._ubahn_travel()
		await frames()
		var cp := get_first_node_in_group("choice_panel")
		check(cp._open, "packaged included transfer offers stops")
		cp._close("carsi")
		await wait_scene("IstanbulCarsi.tscn")
		await create_timer(0.5).timeout
		check(current_scene.scene_file_path.ends_with("IstanbulCarsi.tscn"), "packaged transfer reaches town")
		check(root.get_node("GameState").wallet == wallet, "packaged airport transfer is free")
		check(root.get_node("GameState").alien_appearance.skin == 2, "custom alien survives airport and transfer")
		check(root.get_node("TransitionManager")._overlay.color.a < 0.01, "packaged arrival revealed despite modal thought")
		await shot("arrival-town")
	paused = false
	current_scene.queue_free()
	current_scene = null
	await frames()
	print("PACKAGE: ", checks, " checks; ", failures, " failures; editor host=", editor_host)
	quit(1 if failures else 0)
