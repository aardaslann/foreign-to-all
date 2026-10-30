extends "res://tools/design_boundary_routes.gd"

# Continuous approach routes through the actual Player controller. The old
# long sweep only proved that some collider was hit, not where contact occurred.
func walk_route(label: String, route: Array[Vector2]) -> void:
	check(clear_at(route[0]),label+" starts on clear floor")
	player.position=route[0]
	player.set_physics_process(true)
	for destination: Vector2 in route.slice(1):
		var reached := false
		var still := 0
		for frame in range(360):
			var delta: Vector2 = destination-player.position
			if delta.length()<2.5:
				reached=true
				break
			var previous := player.position
			Input.action_press("walk_right",clampf(delta.x/2.0,0,1))
			Input.action_press("walk_left",clampf(-delta.x/2.0,0,1))
			Input.action_press("walk_down",clampf(delta.y/2.0,0,1))
			Input.action_press("walk_up",clampf(-delta.y/2.0,0,1))
			await physics_frame
			still = still+1 if player.position.distance_to(previous)<.05 else 0
			if still>12: break
		for action in ["walk_left","walk_right","walk_up","walk_down"]: Input.action_release(action)
		check(reached,label+" reaches "+str(destination)+" from "+str(player.position))
		if not reached:
			for i in range(player.get_slide_collision_count()):
				print("CONTACT ",player.get_slide_collision(i).get_collider().name)
			break
	player.set_physics_process(false)
	await capture(label,player.position)

func _run() -> void:
	await load_world("Mitte")
	await create_timer(.4).timeout
	await walk_route("rail-from-left",[Vector2(483,433),Vector2(483,420),Vector2(599,420)])
	await sweep("stairwell front cannot be walked into",Vector2(599,508),Vector2(599,450),true)
	check(player.position.y+20>485.5 and player.position.y+20<491,
		"stairwell contact happens at the pavement edge")
	await capture("stairwell-front-contact",player.position)
	await walk_route("shelter-from-right",[Vector2(990,466),Vector2(985,421),Vector2(922,421),Vector2(790,421)])
	await walk_route("shelter-return-right",[Vector2(790,421),Vector2(922,421),Vector2(985,421),Vector2(990,466)])
	await sweep("poster board blocks crossing between its legs",Vector2(936,466),Vector2(936,420),true)
	await sweep("poster board blocks crossing from behind",Vector2(936,420),Vector2(936,466),true)
	await load_world("IstanbulHan")
	await walk_route("crate-front-left",[Vector2(500,474),Vector2(448,474),Vector2(393,474)])
	await walk_route("crate-front-right",[Vector2(393,474),Vector2(448,474),Vector2(500,474)])
	await capture("crate-front-middle",Vector2(448,474))
	await walk_route("fountain-perimeter",[Vector2(750,505),Vector2(750,570),Vector2(707,590),Vector2(650,616),Vector2(493,616),Vector2(421,588),Vector2(411,520),Vector2(485,474),Vector2(650,474),Vector2(720,474),Vector2(750,505)])
	player.set_process(false)
	player.get_node("Sprite").play("idle_down")
	player.get_node("Sprite").pause()
	for row in [["fountain-east-front",Vector2(750,575),-24.0],
		["fountain-west-front",Vector2(390,575),16.0]]:
		await sweep(row[0]+" contact blocks feet",row[1],Vector2(574,575),true)
		var at := player.position
		# Sample only solid coat pixels; exclude pavement beside its stepped edge.
		var coat := Rect2(at+Vector2(row[2],-15),Vector2(10,18))
		var fountain := scene.get_node("Object_fountain")
		var shown := await capture(row[0],at)
		fountain.hide()
		var hidden := await capture(row[0]+"-probe",at)
		check(changed_pixels(shown,hidden,coat)==0,row[0]+" coat stays in front of the near rim")
		fountain.show()
	print("CONTACT_ROUTES ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
