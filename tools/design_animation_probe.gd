extends SceneTree

# Compare an activity's animated set with the same plate without its patches.
func _initialize() -> void:
	root.size = Vector2i(1152,648)
	root.content_scale_size = Vector2i(1152,648)
	_run.call_deferred()

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var out := args[0]
	DirAccess.make_dir_recursive_absolute(out)
	root.get_node("GameState").time_of_day = "morning"
	var plate := Node2D.new()
	plate.set_script(load("res://scenes/world/EnvironmentDesign.gd"))
	plate.set("scene_id", args[1])
	plate.set("staging_only", true)
	root.add_child(plate)
	plate.set_process(false)
	var design: Dictionary = plate.get("design")
	var patches: Array = design.get("animation_patches",[]).duplicate(true)
	print("PATCHES ", JSON.stringify(patches))
	design["animation_patches"] = []
	plate.queue_redraw()
	for i in range(20): await process_frame
	await RenderingServer.frame_post_draw
	var bare: Image = root.get_texture().get_image()
	design["animation_patches"] = patches
	var changed := 0
	for phase: float in [0.0,1.25,5.0]:
		plate.set("_clock",phase)
		plate.queue_redraw()
		for i in range(3): await process_frame
		await RenderingServer.frame_post_draw
		var frame: Image = root.get_texture().get_image()
		frame.save_png(out.path_join("phase-"+str(phase)+".png"))
		changed=0
		for y in range(648):
			for x in range(1152):
				if not bare.get_pixel(x,y).is_equal_approx(frame.get_pixel(x,y)): changed+=1
		print("PHASE ",phase," changed=",changed)
	quit(0 if changed>30 else 1)
