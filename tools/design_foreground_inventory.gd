extends "res://tools/design_object_review.gd"

# Source artwork beside its complete depth layer. Review crowns, tabletop
# items and open gaps as well as ground contact; feet-only cards miss these.
func _run() -> void:
	var data: Dictionary = load("res://scenes/world/EnvironmentDesign.gd").catalog()
	RenderingServer.set_default_clear_color(Color("d788c8"))
	for id: String in data:
		if not data[id].has("objects"): continue
		if OS.get_cmdline_user_args().size()>1 and id not in OS.get_cmdline_user_args().slice(1): continue
		await load_world(id)
		for n in scene.get_children():
			if n is CanvasItem and not str(n.name).begins_with("Object_") and n.get("scene_id")==null:
				n.hide()
			if n.get("npc_id")!=null or n.name==&"Crowd": n.set_process(false)
		await process_frame
		await RenderingServer.frame_post_draw
		var source := root.get_texture().get_image()
		for n in scene.get_children():
			if n.get("scene_id")!=null: n.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var matte := root.get_texture().get_image()
		source.resize(1152,648,Image.INTERPOLATE_NEAREST)
		matte.resize(1152,648,Image.INTERPOLATE_NEAREST)
		var sheet := Image.create(1152,1296,false,Image.FORMAT_RGBA8)
		sheet.blit_rect(source,Rect2i(0,0,1152,648),Vector2i.ZERO)
		sheet.blit_rect(matte,Rect2i(0,0,1152,648),Vector2i(0,648))
		sheet.save_png(out.path_join(id+".png"))
	print("FOREGROUND_INVENTORY complete")
	quit()
