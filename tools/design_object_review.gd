extends SceneTree

# Reproduce the reported silhouette failures using the actual Player and scene.
# Captures both sides/edges; the physics checks query the live collision world.
var scene: Node2D
var player: CharacterBody2D
var failures: Array[String] = []
var out: String

func _initialize() -> void:
	out = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1152,648)
	root.content_scale_size = Vector2i(1152,648)
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	print("PASS " if ok else "FAIL ", message)
	if not ok: failures.append(message)

func load_world(id: String) -> void:
	if scene != null:
		scene.free()
		await process_frame
	paused = false
	var gs = root.get_node("GameState")
	var layouts: Dictionary = load("res://scenes/world/EnvironmentDesign.gd").catalog()
	gs.city = String(layouts[id]["city"])
	gs.time_of_day = "morning"
	gs.world_flags.clear()
	gs.world_flags["arrived_"+gs.city] = true
	gs.world_flags["story_met_"+gs.city] = true
	gs.world_flags["intro_shown"] = true
	gs.world_flags["room_booked"] = true
	gs.spawn_tag = ""
	gs.last_scene = ""
	scene = load("res://scenes/world/"+id+".tscn").instantiate()
	var ui := scene.get_node_or_null("UILayer")
	if ui != null: ui.free()
	var camera := scene.get_node_or_null("Player/Camera2D")
	if camera != null: camera.set("enabled",false)
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player")
	player.set_physics_process(false)
	for node in scene.get_children():
		if node.get("encounter") != null: node.set_physics_process(false)
	for i in range(8): await physics_frame

func capture(name: String, at: Vector2, phase: float = 1.0) -> Image:
	player.position = at
	player.velocity = Vector2.ZERO
	for node in scene.get_children():
		if node.get("scene_id") != null: node.set("_clock",phase)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	picture.save_png(out.path_join(name+".png"))
	return picture

func changed_pixels(a: Image, b: Image, area: Rect2) -> int:
	var factor := Vector2(a.get_size()) / Vector2(1152,648)
	var changed := 0
	for y in range(int(area.position.y*factor.y),int(area.end.y*factor.y)):
		for x in range(int(area.position.x*factor.x),int(area.end.x*factor.x)):
			if a.get_pixel(x,y) != b.get_pixel(x,y): changed += 1
	return changed

func sweep(name: String, start: Vector2, target: Vector2, blocked: bool) -> void:
	player.position = start
	await physics_frame
	var hit: KinematicCollision2D = player.move_and_collide(target-start)
	check((hit != null) == blocked, name+" collision="+str(hit != null))

func _run() -> void:
	await load_world("Mitte")
	await capture("shelter-behind",Vector2(790,437))
	await capture("shelter-front",Vector2(790,503))
	await capture("shelter-edge",Vector2(885,443))
	await capture("bicycle-behind",Vector2(484,436))
	await sweep("shelter bench blocks feet",Vector2(790,510),Vector2(790,438),true)
	await sweep("bollard blocks feet",Vector2(234,510),Vector2(234,449),true)
	await sweep("stairwell blocks feet",Vector2(599,516),Vector2(599,403),true)
	await load_world("UBahnStation")
	await capture("bench-behind",Vector2(440,485))
	await capture("bench-edge",Vector2(520,495))
	await capture("bench-front",Vector2(440,610))
	await sweep("bench blocks feet",Vector2(360,610),Vector2(360,470),true)
	await sweep("bin blocks feet",Vector2(618,610),Vector2(618,495),true)
	await sweep("passage beside bench stays clear",Vector2(546,604),Vector2(546,460),false)
	await load_world("IstanbulBeyoglu")
	await capture("lamp-behind",Vector2(314,477))
	await capture("lamp-front",Vector2(314,531))
	await sweep("lamp base blocks feet",Vector2(314,540),Vector2(314,476),true)
	await load_world("Hospital")
	await capture("wheelchair-behind",Vector2(1111,390))
	await capture("waiting-bench-behind",Vector2(260,468))
	await sweep("hospital seats block feet",Vector2(260,562),Vector2(260,455),true)
	await load_world("IstanbulHan")
	var fountain_a: Image = await capture("fountain-behind",Vector2(574,491),1)
	var fountain_b: Image = await capture("fountain-motion",Vector2(574,491),1.45)
	check(changed_pixels(fountain_a,fountain_b,Rect2(558,455,29,60))>30,"fountain jet changes across time")
	check(changed_pixels(fountain_a,fountain_b,Rect2(512,578,32,12))==0,"fountain stone rim stays fixed")
	await sweep("fountain basin blocks feet",Vector2(574,611),Vector2(574,490),true)
	await load_world("IstanbulYusuf")
	await capture("tea-behind",Vector2(513,474))
	await capture("tea-edge",Vector2(602,490))
	await sweep("tea table blocks feet",Vector2(514,580),Vector2(514,450),true)
	await load_world("HotelLobby")
	await capture("reception",Vector2(740,484))
	await load_world("HotelRoom")
	player.position = Vector2(700,530)
	var background: Node2D
	for node in scene.get_children():
		if node.get("scene_id") == "HotelRoom": background = node
	var encounter := scene.get_node_or_null("Encounter")
	check(encounter != null,"room encounter exists")
	var saw_open_door := false
	if encounter != null:
		encounter.set("_state","leaving")
		encounter.set_physics_process(true)
		for i in range(1500):
			await physics_frame
			if not is_instance_valid(encounter): break
			if not saw_open_door and background.get("_door_open")>0.8:
				saw_open_door = true
				await capture("room-door-opening",Vector2(700,530))
		check(not is_instance_valid(encounter),"room 304 encounter reaches doorway and leaves")
		if is_instance_valid(encounter):
			print("EXIT_STATE ",encounter.position," leg=",encounter.get("_leg")," aim=",encounter.get("leave_to")," via=",encounter.get("leave_via")," velocity=",encounter.velocity)
			for i in range(encounter.get_slide_collision_count()): print("EXIT_HIT ",encounter.get_slide_collision(i).get_collider().name)
	check(saw_open_door,"room 304 door opens before the visitor leaves")
	await create_timer(1.6).timeout
	check(is_zero_approx(background.get("_door_open")),"room 304 door closes after the visitor leaves")
	await capture("room-after-exit",Vector2(700,530))
	print("OBJECT_REVIEW ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
