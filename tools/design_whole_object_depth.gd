extends "res://tools/design_contact_routes.gd"

# Inspect upper and lower portions of the same fixture with a real character.
# A canopy must agree with its pot/trunk about who is in front.
func still() -> void:
	player.set_process(false)
	player.get_node("Sprite").play("idle_down")
	player.get_node("Sprite").pause()
	for n in scene.get_children():
		if n!=player and (n.get("npc_id")!=null or n.name in [&"Crowd",&"WalkingFriends",&"BusStopNPC"]):
			n.set_process(false)
			if n is CanvasItem: n.hide()

func depth_probe(label: String, object_name: String, at: Vector2, area: Rect2) -> void:
	var object := scene.get_node("Object_"+object_name)
	var normal := await capture(label,at)
	object.hide()
	var omitted := await capture(label+"-without-depth",at)
	object.show()
	check(changed_pixels(normal,omitted,area)>5,label+" upper feature occludes the actor")

func gap_probe(label: String, object_name: String, at: Vector2, area: Rect2) -> void:
	var object := scene.get_node("Object_"+object_name)
	var normal := await capture(label,at)
	object.hide()
	var omitted := await capture(label+"-without-depth",at)
	object.show()
	check(changed_pixels(normal,omitted,area)==0,label+" adjacent background does not cut the actor")

func _run() -> void:
	await load_world("IstanbulHan")
	await create_timer(.4).timeout
	still()
	await walk_route("han-display-approach",[Vector2(976,590),Vector2(976,489),Vector2(1035,489)])
	still()
	await depth_probe("han-display-plant-behind","rugs",Vector2(1035,489),Rect2(1018,443,33,39))
	await capture("han-display-front",Vector2(1035,585))
	await capture("han-display-left-edge",Vector2(975,536))
	await capture("han-tree-behind",Vector2(94,482))
	await capture("han-tree-front",Vector2(94,576))
	await load_world("MitteOst")
	still()
	await walk_route("ost-shelter-rear-route",[Vector2(280,500),Vector2(250,430),Vector2(50,430)])
	for x in [28,114,188]:
		await sweep("ost-panel-front-"+str(x),Vector2(x,501),Vector2(x,430),true)
		check(player.position.y>462,"ost front contact is at the panel base")
		await capture("ost-front-contact-"+str(x),player.position)
		await sweep("ost-panel-rear-"+str(x),Vector2(x,430),Vector2(x,501),true)
		check(player.position.y<448,"ost rear contact is at the panel base")
		await capture("ost-rear-contact-"+str(x),player.position)
	await walk_route("ost-shelter-return-route",[Vector2(50,430),Vector2(250,430),Vector2(250,500),Vector2(280,500)])
	still()
	await depth_probe("ost-tree-join","tree_east",Vector2(1121,425),Rect2(1122,329,16,44))
	await capture("ost-tree-front",Vector2(1120,476))
	await load_world("Mitte")
	still()
	for x in [550,571,594,621,640]:
		await capture("mitte-rail-back-"+str(x),Vector2(x,420))
	await capture("mitte-rail-front",Vector2(594,493))
	await capture("mitte-glass-back",Vector2(790,421))
	await capture("mitte-glass-front",Vector2(745,511))
	await gap_probe("mitte-tree-window-gap","tree_west",Vector2(63,430),Rect2(73,365,6,8))
	await load_world("BerlinPrenzlberg")
	still()
	await depth_probe("prenzlberg-tree-branches","tree_mid",Vector2(245,420),Rect2(228,341,16,29))
	await capture("prenzlberg-tree-front",Vector2(230,482))
	await load_world("IstanbulKadikoy")
	still()
	await capture("kadikoy-tree-side",Vector2(113,425))
	await capture("kadikoy-cafe-front",Vector2(815,459))
	print("WHOLE_OBJECT_DEPTH ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
