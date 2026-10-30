extends SceneTree

var failures: Array[String] = []
var cut: CanvasLayer
var output: String

func _initialize() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	_run.call_deferred()

func check(ok: bool, description: String) -> void:
	print("PASS " if ok else "FAIL ",description)
	if not ok: failures.append(description)

func image_at(name: String) -> Image:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
	var result: Image = cut.get_viewport().get_texture().get_image()
	result.save_png(output.path_join(name+".png"))
	return result

func _run() -> void:
	var gs = root.get_node("GameState")
	gs.city = "berlin"
	gs.current_region = "kreuzberg"
	gs.time_of_day = "morning"
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	cut = CanvasLayer.new()
	cut.set_script(load("res://scenes/ui/Cutscene.gd"))
	viewport.add_child(cut)
	var first: Dictionary = load("res://scenes/world/Streetside.gd").reel("berlin","kreuzberg",-1,false,0)["shots"][0].duplicate(true)
	first["cast"] = [{"at":0.27,"act":"watch","z":0.62},{"at":0.70,"act":"carry","z":0.62}]
	first["say"] = "He brings the last crate to the stall."
	var second: Dictionary = first.duplicate(true)
	second["say"] = "A much longer caption leaves the camera in the same place while you read. The stall, paving and actors remain anchored to the same ground, and the vendor has already finished walking over."
	cut.call("play","berlin",[first,second])
	await create_timer(2.6).timeout
	var frame_before: Vector2 = cut.get("_canvas").size
	var age_before: float = cut.get("_actor_elapsed")[1]
	var before: Image = await image_at("activity-before-next-line")
	cut.call("_advance")
	await create_timer(0.55).timeout
	check(cut.get("_actor_elapsed")[1]>age_before,"advancing a caption does not restart the vendor's arrival")
	check(cut.get("_canvas").size==frame_before,"short and long captions use the same picture size")
	var motion: Dictionary = load("res://scenes/ui/ActivityMotion.gd").sample("carry",cut.get("_actor_elapsed")[1],1)
	check(motion["pose"]=="carry" and is_zero_approx(motion["x"]),"the vendor stays at the counter after arriving")
	var after: Image = await image_at("activity-after-next-line")
	# Shop architecture is static: compare a strip above the actors after
	# the fade. Tiny film-grain speckles may change, its geometry may not.
	var changed := 0
	for y in range(45,80):
		for x in range(50,1100):
			var a: Color = before.get_pixel(x,y)
			var b: Color = after.get_pixel(x,y)
			if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>0.12: changed += 1
	check(changed<50,"static architecture stays fixed across the caption cut: "+str(changed)+" changed pixels")
	cut.call("_close")
	print("ACTIVITY_CONTINUITY ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
