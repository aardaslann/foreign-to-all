extends "res://tools/design_object_review.gd"

# Render actual counter staff and animate only the independently moving parts.
func _run() -> void:
	for id: String in ["LondonHotel","LondonExchange","LondonHospital","LondonPolice","LondonCaff","LondonAirport","ParisHotel","ParisExchange","ParisAirport"]:
		await load_world(id)
		for node in scene.get_children():
			if String(node.name).begins_with("Clerk_"):
				var desk_found := false
				var at: Vector2 = node.position + Vector2(0,22)
				for object in scene.get_children():
					if not String(object.name).begins_with("Object_"): continue
					var spec: Dictionary = object.get("spec")
					for bounds: Array in spec["footprints"]:
						if at.x >= bounds[0] and at.x <= bounds[0]+bounds[2] and absf(at.y-float(spec["sort_y"]))<145:
							if node.position.y < object.position.y: desk_found = true
				check(desk_found,id+" staff sort behind their counter")
		await capture(id+"-staff",player.position)
	await load_world("ParisAirport")
	var a: Image = await frozen_capture("carousel-0",0.0)
	var b: Image = await frozen_capture("carousel-2",2.0)
	check(changed_pixels(a,b,Rect2(345,500,447,20))>100,"Paris carousel belt visibly moves above the object layer")
	check(changed_pixels(a,b,Rect2(380,552,320,12))==0,"Paris carousel steel rim stays fixed")
	await load_world("ParisChampDeMars")
	a = await frozen_capture("drinking-water-0",0.0)
	b = await frozen_capture("drinking-water-1",0.45)
	check(changed_pixels(a,b,Rect2(584,400,6,38))>5,"Paris drinking water moves above the fountain silhouette")
	check(changed_pixels(a,b,Rect2(574,459,21,13))==0,"Paris fountain base stays fixed")
	for spec: Array in [["ActivityLondonDLRFront",Rect2(467,299,192,57)], ["ActivityLondonBinLid",Rect2(414,407,38,35)], ["ActivityParisPortrait",Rect2(572,353,67,79)]]:
		if scene != null: scene.free()
		scene = Node2D.new()
		root.add_child(scene)
		var plate := Node2D.new()
		plate.set_script(load("res://scenes/world/EnvironmentDesign.gd"))
		plate.set("scene_id",spec[0])
		plate.set("staging_only",true)
		scene.add_child(plate)
		plate.set_process(false)
		a = await frozen_capture(spec[0]+"-0",0)
		b = await frozen_capture(spec[0]+"-4",4)
		check(changed_pixels(a,b,spec[1])>20,spec[0]+" animation visibly progresses")
		check(changed_pixels(a,b,Rect2(50,50,160,140))==0,spec[0]+" architecture stays still")
	print("CITY_DETAIL ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)

func frozen_capture(label: String, phase: float) -> Image:
	for node in scene.get_children():
		node.set_process(false)
		if node.get("scene_id") != null: node.set("_clock",phase)
		if node is CanvasItem: node.queue_redraw()
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var picture: Image = root.get_texture().get_image()
	picture.save_png(out.path_join(label+".png"))
	return picture


