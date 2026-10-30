extends "res://tools/design_boundary_routes.gd"


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("kiez-refresh")
	await load_world("Kiez")
	await create_timer(0.4).timeout
	var background := scene.get_node("WreckageBackground")
	check(background.design.texture.ends_with("Kiez-refined.png"), "new material pass installed")
	check(background._texture.get_size() == background._source.size, "source region matches generated plate without clipping")
	for row in [["arrival",Vector2(405,578)], ["wreck-behind",Vector2(268,382)],
		["stall-front",Vector2(737,550)], ["stall-behind",Vector2(684,443)],
		["notice-behind",Vector2(980,462)], ["notice-front",Vector2(980,550)],
		["mailbox-front",Vector2(1074,610)], ["mailbox-behind",Vector2(1074,548)],
		["rock-behind",Vector2(538,535)], ["rock-front",Vector2(538,600)]]:
		await capture(row[0],row[1])
	await sweep("wreck grounds at its original base",Vector2(267,515),Vector2(267,390),true)
	await sweep("stall counter blocks feet",Vector2(737,585),Vector2(737,480),true)
	await sweep("mailbox post blocks feet",Vector2(1074,610),Vector2(1074,563),true)
	await sweep("loose rock blocks feet",Vector2(538,610),Vector2(538,535),true)
	await sweep("front of stall is walkable",Vector2(610,573),Vector2(850,573),false)
	await sweep("mailbox side passage stays open",Vector2(1115,610),Vector2(1115,540),false)
	player.position = Vector2(640,585)
	check(await walk_to(Vector2(640,518)), "walk onto original stone strip")
	check(await walk_to(Vector2(850,518)), "walk past stall along strip")
	await capture("stone-strip",player.position)
	check(await walk_to(Vector2(1115,518)), "walk to street exit")
	for i in range(5): await physics_frame
	check(scene.get_node("ExitToMitte").player_nearby, "street exit remains accessible")
	print("KIEZ REFRESH: ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
