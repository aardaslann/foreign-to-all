extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("MAP: " + message)

func _run() -> void:
	root.get_node("SaveManager").use_test_storage("map-review")
	var path := "res://scenes/ui/MapAtlas.gd"
	check(ResourceLoader.exists(path), "scene-backed atlas exists")
	if not ResourceLoader.exists(path):
		quit(1)
		return
	var atlas: Script = load(path)
	var places: Script = load("res://scenes/world/ActivityPlaces.gd")
	var catalog: Dictionary = atlas.catalog()
	for id: String in places.catalog().places:
		var scene: String = places.scene_path(id)
		check(catalog.has(scene), id + " included")
		if not catalog.has(scene): continue
		check(catalog[scene].title == places.location(id).title, id + " honest title")
		check(atlas.route(scene, places.location(id).parent).size() == 2, id + " direct return")
		check(atlas.route(places.location(id).parent, scene).size() == 2, id + " direct entrance")
	for city: String in root.get_node("GameState").CITIES:
		check(atlas.city_places(city).size() >= 5, city + " actual locations")
	for path2: String in catalog:
		check(not catalog[path2].title.is_empty() and catalog[path2].title != "Somewhere", path2 + " named")
		check(ResourceLoader.exists(catalog[path2].design.texture), path2 + " actual art resource")
	check(atlas.route("res://scenes/world/Kiez.tscn", "res://scenes/world/activities/ActivityBerlinSpati.tscn") == ["res://scenes/world/Kiez.tscn", "res://scenes/world/Mitte.tscn", "res://scenes/world/activities/ActivityBerlinSpati.tscn"], "Spati route follows Mitte")
	check(atlas.route("res://scenes/world/TokyoAsakusa.tscn", "res://scenes/world/activities/ActivityTokyoOmikuji.tscn").size() == 4, "shrine sequence is not flattened")
	check(atlas.route("res://scenes/world/Kiez.tscn", "res://scenes/world/TokyoYanaka.tscn").is_empty(), "no invented intercity walking route")
	if DisplayServer.get_name() != "headless": await _graphical(atlas)
	print("MAP: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func frames(count := 5) -> void:
	for i in range(count): await process_frame

func _graphical(atlas: Script) -> void:
	var gs := root.get_node("GameState")
	gs.reset()
	gs.world_flags.has_map = true
	gs.time_of_day = "morning"
	root.get_node("Loc").set_language("en")
	root.get_node("SaveManager").settings.reduced_motion = true
	var out := "res://.build/map-review"
	DirAccess.make_dir_recursive_absolute(out)
	var scenes := ["Kiez", "Mitte", "IstanbulCarsi", "LondonHighStreet", "ParisMarais", "MoscowKitayGorod", "MumbaiBhuleshwar", "TokyoAsakusa", "MexicoMerced"]
	if OS.get_cmdline_user_args().has("--quick"): scenes = ["Kiez", "Mitte"]
	for id: String in scenes:
		change_scene_to_file("res://scenes/world/" + id + ".tscn")
		await frames(8)
		var thought := get_first_node_in_group("thought_box")
		if paused and thought != null: thought._close()
		await frames(2)
		var map := current_scene.get_node("UILayer/MapView")
		check(map.has_method("_select"), id + " atlas compiles")
		if not map.has_method("_select"): continue
		var flags: Dictionary = gs.world_flags.duplicate(true)
		var visits: Dictionary = gs.region_visits.duplicate(true)
		var wallet: Dictionary = gs.wallet.duplicate(true)
		map._open()
		await frames(10)
		check(paused and map._panel_root.visible, id + " opens and pauses")
		check(map._board.pins.size() > 0, id + " live landmarks")
		for pin: Dictionary in map._board.pins:
			var node := current_scene.get_node_or_null(NodePath(pin.node)) as Node2D
			check(node != null and pin.pos.distance_to(node.position) < 0.1, id + " live position: " + pin.node)
			if node != null and node.get("target_scene") != null:
				check(pin.target == node.get("target_scene"), id + " entrance target " + pin.node)
		await RenderingServer.frame_post_draw
		_assert_plate(map, id)
		root.get_texture().get_image().save_png(out + "/" + id + "-place.png")
		map._set_mode(true)
		await frames(3)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out + "/" + id + "-city.png")
		check(map._board._graph.size() == atlas.city_places(gs.city).size(), id + " city sheet includes all places")
		for link: Dictionary in map._board._links:
			var avoids := true
			for other: String in map._board._graph:
				if other == link.from or other == link.to: continue
				var area: Rect2 = Rect2(map._board._graph[other], map._board.TILE_SIZE)
				for point: Vector2 in link.points:
					if area.has_point(point): avoids = false
			check(avoids, id + " route ink avoids unrelated places")
		map._set_mode(false)
		if id == "Mitte": await _interaction(map, atlas, out)
		for path: String in atlas.city_places(gs.city):
			map._select(path)
			await frames(2)
			check(map._selected == path and map._board._plate != null, id + " preview " + path.get_file())
			check(not map._board.pins.is_empty(), id + " remote entrance markers " + path.get_file())
		check(flags == gs.world_flags and visits == gs.region_visits and wallet == gs.wallet, id + " browsing cannot mutate journey")
		map._close()
		check(not paused and not map._panel_root.visible, id + " close resumes")
		await frames(2)
	if not OS.get_cmdline_user_args().has("--quick"):
		await _locations_review(atlas, out)
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	await frames(3)

func click(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	root.warp_mouse(at)
	for down: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		await frames(2)

func key(code: Key) -> void:
	for down: bool in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		Input.parse_input_event(event)
		await frames(2)

func _interaction(map: Node, atlas: Script, out: String) -> void:
	var spati := "res://scenes/world/activities/ActivityBerlinSpati.tscn"
	var index := -1
	for i in range(map._board.pins.size()):
		if map._board.pins[i].target == spati: index = i
	check(index >= 0, "Mitte exposes real Spati entrance")
	check(atlas.route(map._here, spati, current_scene).size() == 2, "live route includes service-point entrances")
	if index >= 0:
		var button := map._connections.get_child(index) as Control
		(button.get_parent().get_parent() as ScrollContainer).ensure_control_visible(button)
		await frames()
		await click(button)
		check(map._selected == spati, "actual click previews destination without travel")
		check(current_scene.name == &"Mitte", "preview keeps world scene")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out + "/Spati-route.png")
	await click(map._mode_buttons[1])
	check(map._board.city_mode, "actual city tab click")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + "/Berlin-route.png")
	map._board.change_zoom(99)
	check(map._board.zoom == 3, "zoom maximum")
	map._board.change_zoom(-99)
	check(map._board.zoom == 1, "zoom minimum")
	await click(map._mode_buttons[0])
	map._search.grab_focus()
	map._search.text = "SPÄTI"
	map._search.text_changed.emit(map._search.text)
	await frames()
	check(map._buttons.size() == 1 and map._buttons.has(spati), "search case-insensitive and Unicode")
	await key(KEY_TAB)
	check(root.gui_get_focus_owner() != map._search and map._panel_root.visible, "Tab navigates focused map controls")
	map._search.text = "no-such-place"
	map._search.text_changed.emit(map._search.text)
	check(map._buttons.is_empty(), "empty search results")
	map._search.clear()
	map._search.text_changed.emit("")
	await frames()
	await key(KEY_ESCAPE)
	check(not paused and not map._panel_root.visible, "Escape closes from focused UI")
	await key(KEY_M)
	check(paused and map._panel_root.visible, "M reopens map")
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1024, 768), Vector2i(2560, 1080)]:
		root.content_scale_size = dimensions
		root.size = dimensions
		await frames(8)
		check(map._board.get_global_rect().end.y < dimensions.y, "map stays inside " + str(dimensions))
		check(map._place_scroll.get_global_rect().end.x <= dimensions.x, "index stays inside " + str(dimensions))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out + "/Mitte-%d.png" % dimensions.x)
	root.content_scale_size = Vector2i(1920,1080)
	root.size = Vector2i(1920,1080)
	await frames(5)

func _locations_review(atlas: Script, out: String) -> void:
	var gs := root.get_node("GameState")
	var places: Dictionary = atlas.PLACES.catalog().places
	var paths: Array[String] = []
	for id: String in places: paths.append(atlas.PLACES.scene_path(id))
	paths.append("res://scenes/world/UBahnStation.tscn")
	paths.append("res://scenes/world/HotelFloor.tscn")
	for city: String in gs.CITIES:
		if not city in ["berlin", "istanbul", "london", "paris", "moscow", "mumbai", "tokyo", "mexico"]: paths.append(gs.CITY_ENTRIES[city])
	for path: String in paths:
		paused = false
		gs.last_scene = ""
		gs.entered_from = "res://scenes/world/BerlinKreuzberg.tscn"
		gs.hotel_floor = 3
		gs.world_flags.room_booked = true
		change_scene_to_file(path)
		await frames(5)
		var thought := get_first_node_in_group("thought_box")
		if paused and thought != null: thought._close()
		var map := current_scene.get_node("UILayer/MapView")
		map._open()
		await frames(3)
		check(map._panel_root.visible, path + " map opens")
		var preview: Array = atlas.markers(path)
		for pin: Dictionary in map._board.pins:
			var matched := false
			for other: Dictionary in preview:
				if other.node == pin.node and other.target == pin.target and other.pos.distance_to(pin.pos) < 0.15: matched = true
			if path.ends_with("UBahnStation.tscn") and pin.node == "Exit":
				check(pin.target.ends_with("BerlinKreuzberg.tscn"), "station return is the district actually entered from")
			else: check(matched, path + " remote and live markers agree: " + pin.node)
		if path.ends_with("ActivityTokyoOmikuji.tscn") or path.ends_with("ActivityMumbaiMuseumHall.tscn") or path.ends_with("UBahnStation.tscn"):
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out + "/" + path.get_file().get_basename() + ".png")
		map._close()
		check(not paused, path + " releases pause")

func _assert_plate(map: Node, label: String) -> void:
	var image: Image = map._board._plate.get_texture().get_image()
	var colors := {}
	for y in range(40, image.get_height(), 75):
		for x in range(40, image.get_width(), 100): colors[image.get_pixel(x, y).to_rgba32()] = true
	check(colors.size() > 20, label + " illustrated plate is nonblank")
