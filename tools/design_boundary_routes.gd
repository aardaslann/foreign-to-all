extends "res://tools/design_object_review.gd"

# Walk the reported routes. An interaction area's far edge overlapping a
# reachable cell does not prove that its visible marker can be approached.
func walk_to(at: Vector2) -> bool:
	for frame in range(360):
		await physics_frame
		var step: Vector2 = at-player.position
		if step.length()<1.0: return true
		player.move_and_collide(step.limit_length(2.0))
	return false

func clear_at(at: Vector2) -> bool:
	var shape := player.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape.shape
	query.transform = Transform2D(0.0,at+shape.position)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	return player.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()

func capture(name: String, at: Vector2, phase: float = 1.0) -> Image:
	check(clear_at(at),name+" capture stands on clear floor")
	return await super.capture(name,at,phase)

func sweep(name: String, start: Vector2, target: Vector2, blocked: bool) -> void:
	check(clear_at(start),name+" starts on clear floor")
	player.position=start
	await physics_frame
	var hit := player.move_and_collide(target-start)
	check((hit!=null)==blocked,name)
	if hit!=null: check(hit.get_collider().name==&"Solids",name+" hits an object, not the world border")

func _run() -> void:
	await load_world("Mitte")
	# Let TransitionManager's startup fade finish before comparing exact colors.
	await create_timer(0.4).timeout
	player.set_process(false)
	for child in player.get_children():
		if child is AnimatedSprite2D:
			child.pause()
	var post := scene.get_node("Object_bollard_east")
	var visible_post: Image = await capture("mitte-bollard-behind",Vector2(234,438))
	post.hide()
	var hidden_post: Image = await capture("mitte-bollard-mask-probe",Vector2(234,438))
	# These strips lie beside the photographed shaft, within its old
	# rectangular crop. They must retain the exact same player pixels.
	check(changed_pixels(visible_post,hidden_post,Rect2(226,437,3,14))==0,
		"left of bollard shaft does not erase the player's coat")
	check(changed_pixels(visible_post,hidden_post,Rect2(240,437,3,14))==0,
		"right of bollard shaft does not erase the player's coat")
	check(changed_pixels(visible_post,hidden_post,Rect2(231,437,6,14))>0,
		"the actual shaft still occludes the player")
	post.show()
	await capture("mitte-bollard-front",Vector2(234,510))
	await sweep("bollard base blocks feet",Vector2(234,510),Vector2(234,438),true)
	for row: Array in [["IstanbulHan","YusufDoor"],["IstanbulHavalimani","Exit"],
		["IstanbulMetro","Exit"],["IstanbulMetro","ToAirport"]]:
		await load_world(row[0])
		var at: Vector2 = scene.get_node(row[1]).position-Vector2(0,20)
		check(clear_at(at),row[0]+"/"+row[1]+" marker is clear")
		await capture(row[0]+"-"+row[1],at)
	await load_world("IstanbulKarakoy")
	await capture("ferry-fixtures-edge",Vector2(104,414))
	await capture("ferry-fixtures-front",Vector2(172,461))
	await load_world("Kiez")
	player.position=Vector2(603,573)
	check(await walk_to(Vector2(603,528)),"walk around left edge of stall")
	check(await walk_to(Vector2(609,528)),"approach left edge without entering masonry")
	await capture("kiez-stall-left",player.position)
	await capture("kiez-stall-front",Vector2(737,573))
	await capture("kiez-mailbox-front",Vector2(1074,609))
	player.position=Vector2(1115,610)
	check(await walk_to(Vector2(1115,548)),"walk beside mailbox")
	check(await walk_to(Vector2(1074,548)),"walk behind mailbox")
	await capture("kiez-mailbox-behind",player.position)
	check(clear_at(player.position),"behind mailbox capture is a valid standing position")
	await sweep("mailbox post blocks feet",Vector2(1074,610),Vector2(1074,563),true)
	await sweep("stall counter still blocks feet",Vector2(737,585),Vector2(737,480),true)
	# Stand between the apple crate and the separately collidable loose rock.
	await sweep("apple crate blocks feet",Vector2(548,535),Vector2(548,480),true)
	await sweep("front of stall is walkable",Vector2(610,573),Vector2(850,573),false)
	await sweep("mailbox side passage is walkable",Vector2(1115,610),Vector2(1115,540),false)
	player.position=Vector2(640,585)
	check(await walk_to(Vector2(640,518)),"walk up onto the original stone strip")
	await capture("kiez-stone-left",player.position)
	check(await walk_to(Vector2(850,518)),"walk along stone strip past the stall")
	await capture("kiez-stone-middle",player.position)
	check(await walk_to(Vector2(1115,518)),"walk the original strip to its right end")
	await capture("kiez-stone-right",player.position)
	await sweep("fence behind the path still blocks feet",Vector2(1115,518),Vector2(1115,470),true)
	player.position=Vector2(1115,610)
	var arrived: bool = await walk_to(Vector2(1115,518))
	check(arrived,"walk upward onto the stone path at the visible Kiez exit")
	await capture("kiez-exit-approach",player.position)
	if arrived:
		for i in range(5): await physics_frame
		check(scene.get_node("ExitToMitte").player_nearby,"the exit activates at its visible marker")
		var event := InputEventAction.new()
		event.action="interact"
		event.pressed=true
		Input.parse_input_event(event)
		for i in range(150):
			await process_frame
			if current_scene != null and current_scene.name==&"Mitte": break
		check(current_scene != null and current_scene.name==&"Mitte","walking to the exit and pressing E reaches Mitte")
	print("BOUNDARY_ROUTES ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
