extends "res://tools/design_boundary_routes.gd"

# Contact sheets from the actual renderer, with a valid standing position
# on either side of each revised narrow street object. No source-art edits.
func _run() -> void:
	var data: Dictionary = load("res://scenes/world/EnvironmentDesign.gd").catalog()
	var panel := 0
	var page := 0
	var sheet := Image.create(960,1040,false,Image.FORMAT_RGBA8)
	sheet.fill(Color8(20,24,29))
	var hud := CanvasLayer.new()
	hud.layer=100
	root.add_child(hud)
	var label := Label.new()
	label.add_theme_font_size_override("font_size",9)
	label.add_theme_color_override("font_outline_color",Color.BLACK)
	label.add_theme_constant_override("outline_size",3)
	hud.add_child(label)
	for id: String in ["Mitte","MitteOst","BerlinPrenzlberg","IstanbulKarakoy","IstanbulBeyoglu","IstanbulKadikoy"]:
		await load_world(id)
		player.set_process(false)
		player.get_node("Sprite").pause()
		for obj: Dictionary in data[id]["objects"]:
			var name: String = obj["id"]
			if not ("bollard" in name or "pole" in name or name in ["lamp","signpost"]): continue
			var f: Array = obj["footprints"][0]
			var center: float = float(f[0])+float(f[2])*.5
			for side: String in ["behind","front"]:
				var at := Vector2(center,float(f[1])-33 if side=="behind" else float(f[1])+float(f[3])-7)
				if not clear_at(at):
					print("NO_STANDING ",id,"/",name," ",side," ",at)
					continue
				player.position=at
				var origin := Vector2(clampf(at.x-72,0,1008),clampf(at.y-118,0,492))
				label.position=origin+Vector2(3,2)
				label.text=id+"\n"+name+" / "+side
				for i in range(3): await process_frame
				await RenderingServer.frame_post_draw
				var frame: Image = root.get_texture().get_image()
				var ratio := Vector2(frame.get_size())/Vector2(1152,648)
				var crop := frame.get_region(Rect2i(Vector2i(origin*ratio),Vector2i(Vector2(144,156)*ratio)))
				crop.resize(240,260,Image.INTERPOLATE_NEAREST)
				sheet.blit_rect(crop,Rect2i(0,0,240,260),Vector2i((panel%4)*240,(panel/4)*260))
				panel+=1
				if panel==16:
					sheet.save_png(out.path_join("posts-%d.png"%page))
					page+=1
					panel=0
					sheet.fill(Color8(20,24,29))
	if panel>0: sheet.save_png(out.path_join("posts-%d.png"%page))
	print("POST_REVIEW ",page*16+panel," physically clear capture positions")
	quit(0)
