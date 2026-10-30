extends "res://tools/design_object_review.gd"

# Inventory every installed Berlin/Istanbul scene against its actual artwork.
# Green: collider footprint. Cyan: foreground silhouette. Red: world boundary.
func _run() -> void:
	var data: Dictionary = load("res://scenes/world/EnvironmentDesign.gd").catalog()
	for id: String in data:
		if not data[id].has("objects"): continue
		if OS.get_cmdline_user_args().size()>1 and id not in OS.get_cmdline_user_args().slice(1): continue
		await load_world(id)
		for n in scene.get_children():
			if n == player or n.get("npc_id") != null or n.get("encounter") != null or n.name == &"Crowd":
				if n is CanvasItem: n.hide()
		var overlay := Node2D.new()
		overlay.z_index=50
		scene.add_child(overlay)
		var row: Dictionary = data[id]
		overlay.draw.connect(func():
			overlay.draw_line(Vector2(0,row["floor"]),Vector2(1152,row["floor"]),Color.RED,2)
			var index := 0
			for obj: Dictionary in row["objects"]:
				for p: Array in obj.get("polygons",[]):
					var points := PackedVector2Array()
					for xy: Array in p: points.append(Vector2(xy[0],xy[1]))
					points.append(points[0])
					overlay.draw_polyline(points,Color(0,1,1,.7),.8)
				for f: Array in obj.get("footprints",[]):
					var r := Rect2(f[0],f[1],f[2],f[3])
					overlay.draw_rect(r,Color(0,1,0,.25))
					overlay.draw_rect(r,Color.GREEN,false,1)
				if not obj.get("footprints",[]).is_empty():
					var f: Array = obj["footprints"][0]
					overlay.draw_string(ThemeDB.fallback_font,Vector2(f[0],f[1]), str(index)+" "+obj["id"],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color.WHITE)
				index+=1
		)
		overlay.queue_redraw()
		for i in range(5): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(id+".png"))
	print("INVENTORY complete")
	quit()
