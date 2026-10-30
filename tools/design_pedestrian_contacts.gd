extends "res://tools/design_boundary_routes.gd"

# Ten simulated minutes per authored street, sampled at 60Hz. The crowd uses
# its actual movement code; no relocation or test-only obstacle avoidance.
func _run() -> void:
	var data: Dictionary=load("res://scenes/world/EnvironmentDesign.gd").catalog()
	var people := 0
	var samples := 0
	for id: String in data:
		if not data[id].has("objects") or not data[id].has("district"): continue
		await load_world(id)
		var crowd := scene.get_node_or_null("Crowd")
		if crowd==null: continue
		crowd.set_process(false)
		var folk: Array=crowd.get("_folk")
		var solids: Array=crowd.get("_solids")
		var hits := 0
		var jumps := 0
		var travelled: Array[float]=[]
		travelled.resize(folk.size())
		people+=folk.size()
		for frame in range(36000):
			for index in range(folk.size()):
				var f: Dictionary=folk[index]
				var before := Vector2(f["x"],f["y"])
				if not f["stand"]: crowd.call("_walk_clear_route",f,1.0/60.0)
				var at := Vector2(f["x"],f["y"])
				var distance := at.distance_to(before)
				travelled[index]+=distance
				if distance>float(f["speed"])/60.0+.001: jumps+=1
				var feet := Rect2(at-Vector2(18,5),Vector2(36,10))
				for solid: Rect2 in solids:
					if solid.intersects(feet): hits+=1
				samples+=1
			if frame%1800==0: await process_frame
		check(hits==0,id+" pedestrians never overlap furniture ("+str(hits)+")")
		check(jumps==0,id+" pedestrians have continuous movement")
		for i in range(folk.size()):
			check(folk[i]["stand"] or travelled[i]>1000,id+" walker "+str(i)+" completes repeated routes: "+str(int(travelled[i])))
		crowd.call("_update_visuals")
		await capture(id+"-crowd",player.position)
	# A valid narrow passage position must also survive loading an older save.
	for pose in [["Mitte",Vector2(790,421)],["Mitte",Vector2(936,420)],
		["IstanbulHan",Vector2(448,474)]]:
		await load_world(pose[0])
		player.position=pose[1]
		for node in scene.get_children():
			if node.has_method("_settle_legacy_spawn"): node.call("_settle_legacy_spawn")
		check(player.position.distance_to(pose[1])<.01,pose[0]+" narrow passage survives saved-position validation")
	for pose in [["HotelRoom",Vector2(1100,396)],["IstanbulOtel",Vector2(582,370)]]:
		await load_world(pose[0])
		player.position=pose[1]
		for node in scene.get_children():
			if node.has_method("_settle_legacy_spawn"): node.call("_settle_legacy_spawn")
		check(player.position.distance_to(pose[1])>8 and clear_at(player.position),pose[0]+" old save recovers from isolated furniture pocket")
	print("PEDESTRIAN_CONTACTS ",people," people, ",samples," samples, ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
