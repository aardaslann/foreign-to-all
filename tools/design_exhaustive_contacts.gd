extends "res://tools/design_boundary_routes.gd"

# Every reachable 6px floor cell is visited with the real body. For each
# object, walk to eight surrounding approaches and capture the actual contact.
const STEP := 6
const CARD := Vector2i(256,192)
var nav: AStarGrid2D
var reachable: Dictionary
var row: Dictionary
var report: Array = []
var moved_cells := 0
var board: Image
var labels: Array[String]

func _run() -> void:
	var data: Dictionary=load("res://scenes/world/EnvironmentDesign.gd").catalog()
	for id: String in data:
		if not data[id].has("objects"): continue
		if OS.get_cmdline_user_args().size()>1 and id not in OS.get_cmdline_user_args().slice(1): continue
		await load_world(id)
		row=data[id]
		# People remain in the physics world, but do not cover the reviewed
		# contact silhouettes. NPC motion has its own longer simulation audit.
		for node in scene.get_children():
			if node==player: continue
			if node.get("npc_id")!=null or node.get("encounter")!=null or node.name in [&"Crowd",&"WalkingFriends",&"BusStopNPC"]:
				node.set_process(false)
				if node is CanvasItem: node.hide()
		await create_timer(.4).timeout
		_build_floor()
		var start := Vector2i(roundi(player.position.x/STEP),roundi(player.position.y/STEP))
		if nav.is_point_solid(start):
			var best := INF
			for y in range(nav.region.position.y,nav.region.end.y):
				for x in range(nav.region.position.x,nav.region.end.x):
					var cell := Vector2i(x,y)
					var distance := Vector2(cell*STEP).distance_squared_to(player.position)
					if not nav.is_point_solid(cell) and distance<best:
						best=distance
						start=cell
		check(player.move_and_collide(Vector2(start*STEP)-player.position)==null,id+" reaches starting floor cell")
		reachable={start:true}
		var stack: Array[Vector2i]=[start]
		var directions := [Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]
		var edge_hits := 0
		while not stack.is_empty():
			var cell: Vector2i = stack.back()
			var next: Vector2i = cell
			for direction: Vector2i in directions:
				var candidate: Vector2i=cell+direction
				if nav.region.has_point(candidate) and not nav.is_point_solid(candidate) and not reachable.has(candidate):
					next=candidate
					break
			if next==cell:
				stack.pop_back()
				if stack.is_empty(): break
				next=stack.back()
			else:
				reachable[next]=true
				stack.append(next)
			var hit := player.move_and_collide(Vector2(next*STEP)-player.position)
			if hit!=null:
				edge_hits+=1
				# Exclude a crossed thin obstacle even if both cell centres are free.
				nav.set_point_solid(next,true)
				reachable.erase(next)
				if stack.back()==next: stack.pop_back()
				player.move_and_collide(Vector2(cell*STEP)-player.position)
			moved_cells+=1
			if moved_cells%2500==0: await process_frame
		var free_cells := 0
		var pockets: Array = []
		for y in range(nav.region.position.y,nav.region.end.y):
			for x in range(nav.region.position.x,nav.region.end.x):
				var cell := Vector2i(x,y)
				if not nav.is_point_solid(cell):
					free_cells+=1
					if not reachable.has(cell): pockets.append([x*STEP,y*STEP])
		var record := {"scene":id,"reachable_cells":reachable.size(),"disconnected_cells":free_cells-reachable.size(),"pockets":pockets,"thin_edges":edge_hits,"objects":[]}
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(id+"-full.png"))
		for object: Dictionary in row["objects"]:
			var bounds := Rect2()
			for f: Array in object["footprints"]:
				var box := Rect2(f[0],f[1],f[2],f[3])
				bounds=box if bounds.size==Vector2.ZERO else bounds.merge(box)
			var center := bounds.get_center()
			var poses: Array = []
			for direction: Vector2 in [Vector2.UP,Vector2(1,-1),Vector2.RIGHT,Vector2(1,1),Vector2.DOWN,Vector2(-1,1),Vector2.LEFT,Vector2(-1,-1)]:
				var ideal := center+direction*(bounds.size*.5+Vector2(22,12))-Vector2(0,20)
				var nearest := Vector2i(-1,-1)
				var best := INF
				for cell: Vector2i in reachable:
					var d := Vector2(cell*STEP).distance_squared_to(ideal)
					if d<best:
						best=d
						nearest=cell
				poses.append({"cell":nearest,"distance":sqrt(best),"direction":direction})
			board=Image.create(CARD.x*4,CARD.y*2,false,Image.FORMAT_RGBA8)
			board.fill(Color8(17,15,27))
			labels=[]
			var object_record := {"id":object["id"],"poses":[]}
			for index in range(poses.size()):
				var pose: Dictionary=poses[index]
				var cell: Vector2i=pose["cell"]
				var current := Vector2i(roundi(player.position.x/STEP),roundi(player.position.y/STEP))
				var path := nav.get_point_path(current,cell)
				var walked := not path.is_empty()
				for step: Vector2 in path:
					if player.move_and_collide(step-player.position)!=null:
						walked=false
						break
				var approach := player.position
				# Contact inward only when the selected position actually lies
				# beside this object, rather than on another side of a wall.
				if pose["distance"]<18 and walked:
					player.move_and_collide(-pose["direction"].normalized()*24)
				var at := player.position
				player.velocity=-pose["direction"]*120
				for i in range(3): await process_frame
				await RenderingServer.frame_post_draw
				var full := root.get_texture().get_image()
				if object["id"]=="fountain": full.save_png(out.path_join(id+"-full-"+str(index)+".png"))
				var factor := Vector2(full.get_size())/Vector2(1152,648)
				var crop := Rect2i(Vector2i((at-Vector2(77,89))*factor),Vector2i(Vector2(154,108)*factor))
				var picture := full.get_region(crop)
				picture.resize(CARD.x,CARD.y-24,Image.INTERPOLATE_NEAREST)
				board.blit_rect(picture,Rect2i(Vector2i.ZERO,picture.get_size()),Vector2i(index%4,index/4)*CARD)
				var tag: String = ["BACK","NE","RIGHT","SE","FRONT","SW","LEFT","NW"][index]
				labels.append(tag+" "+str(Vector2i(at))+ (" distant" if pose["distance"]>=18 else ""))
				object_record["poses"].append({"side":tag,"x":at.x,"y":at.y,"walked":walked,"distance_to_ideal":pose["distance"]})
				check(walked,id+"/"+object["id"]+" "+tag+" continuous approach")
				# Retrace the contact stroke, then align to the same navigation cell.
				player.move_and_collide(approach-player.position)
			await _save_card(id+"--"+object["id"])
			record["objects"].append(object_record)
		report.append(record)
		FileAccess.open(out.path_join("report.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
		print("SCENE ",id," objects=",row["objects"].size()," cells=",reachable.size()," disconnected=",free_cells-reachable.size())
	print("EXHAUSTIVE_CONTACTS ",report.size()," scenes, ",moved_cells," movement steps, ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)

func _build_floor() -> void:
	nav=AStarGrid2D.new()
	nav.region=Rect2i(2,int(row["floor"]-22)/STEP,188,(644-int(row["floor"])+22)/STEP)
	nav.cell_size=Vector2(STEP,STEP)
	nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	nav.update()
	for y in range(nav.region.position.y,nav.region.end.y):
		for x in range(nav.region.position.x,nav.region.end.x):
			var cell := Vector2i(x,y)
			nav.set_point_solid(cell,not clear_at(Vector2(cell*STEP)))

func _save_card(label: String) -> void:
	# Godot draws the labels on a small offscreen viewport; no game art changes.
	var viewport := SubViewport.new()
	viewport.size=board.get_size()
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var painter := Node2D.new()
	viewport.add_child(painter)
	var texture := ImageTexture.create_from_image(board)
	painter.draw.connect(func():
		painter.draw_texture(texture,Vector2.ZERO)
		for i in range(labels.size()):
			painter.draw_string(ThemeDB.fallback_font,Vector2(i%4*CARD.x+4,(i/4+1)*CARD.y-7),labels[i],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
	)
	for i in range(2): await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(out.path_join(label+".png"))
	viewport.queue_free()
