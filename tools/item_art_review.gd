extends "res://tools/title_review.gd"


func _run() -> void:
	out = "res://.build/item-review"
	DirAccess.make_dir_recursive_absolute(out)
	root.get_node("SaveManager").use_test_storage("item-art-review")
	root.get_node("Loc").set_language("en")
	var items := root.get_node("Items")
	check(ResourceLoader.exists("res://scenes/world/ItemArt.gd"), "dedicated pixel item art exists")
	if failures > 0:
		quit(1)
		return
	var art = load("res://scenes/world/ItemArt.gd")
	var hashes: Dictionary = {}
	for id: String in items._all:
		check(art.has_icon(id), "dedicated icon: " + id)
		var picture: Image = art.texture(id).get_image()
		check(picture.get_size() == Vector2i(32, 32), "32-pixel canvas: " + id)
		check(picture.get_used_rect().has_area(), "visible sprite: " + id)
		check(picture.get_used_rect().position.x > 0 and picture.get_used_rect().end.x < 32,
			"complete silhouette: " + id)
		check(picture.get_used_rect().position.y > 0 and picture.get_used_rect().end.y < 32,
			"top and bottom stay inside canvas: " + id)
		var fingerprint := picture.get_data().hex_encode().sha256_text()
		# Two fortunes depict the same paper object, with different folds/marks.
		check(not hashes.has(fingerprint), "unique artwork: " + id)
		hashes[fingerprint] = id
	await _gallery(art, items._all.keys())
	await _prop_gallery(art)
	await _money_walkover()
	await _locations()
	print("ITEM ART: ", checks, " checks, ", failures, " failures")
	quit(0 if failures == 0 else 1)


func _gallery(art: Script, ids: Array) -> void:
	var gallery := Node2D.new()
	gallery.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(gallery)
	gallery.draw.connect(func():
		gallery.draw_rect(Rect2(0, 0, 1920, 1080), Color8(34, 38, 43))
		var font := ThemeDB.fallback_font
		for i in range(ids.size()):
			var at := Vector2(140 + (i % 9) * 205, 84 + (i / 9) * 169)
			gallery.draw_texture_rect(art.texture(ids[i]), Rect2(at - Vector2(48,48), Vector2(96,96)), false)
			gallery.draw_string(font, at + Vector2(-83,75), ids[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color8(221,226,213))
	)
	await frames()
	await capture("item-catalog")
	gallery.free()


func _prop_gallery(art: Script) -> void:
	var objects = load("res://scenes/ui/ActivityObjects.gd")
	var character = load("res://scenes/npc/CharacterArt.gd")
	var kinds := ["apple_crate","fish_stall","simit_cart","market_stall","card_machine",
		"bread","cheese","fruit","produce","books","fabric_folded","sewing",
		"workbench","bench","bicycle","flowers","kiosk","crate","map","griddle"]
	var gallery := Node2D.new()
	root.add_child(gallery)
	gallery.draw.connect(func():
		gallery.draw_rect(Rect2(0,0,1920,1080),Color8(37,40,43))
		for i in range(kinds.size()):
			var at := Vector2(190+(i%5)*380,205+(i/5)*218)
			objects.draw(gallery,kinds[i],at,2.5,1.0,"berlin")
			gallery.draw_string(ThemeDB.fallback_font,at+Vector2(-82,37),kinds[i],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color8(220,225,211))
	)
	await frames()
	await capture("standalone-props")
	gallery.free()
	var story = load("res://scenes/story/StoryProp.gd")
	var story_gallery := Node2D.new()
	root.add_child(story_gallery)
	story_gallery.draw.connect(func():
		story_gallery.draw_rect(Rect2(0,0,1920,1080),Color8(37,40,43))
		for i in range(story.KINDS.size()):
			var at := Vector2(160+(i%6)*315,215+(i/6)*245)
			story.draw_kind(story_gallery,at,story.KINDS[i],3.5)
			story_gallery.draw_string(ThemeDB.fallback_font,at+Vector2(-75,37),story.KINDS[i],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color8(220,225,211))
	)
	await frames()
	await capture("story-props")
	story_gallery.free()
	for id: String in character.PROPS:
		check(art.PROPS.has(id),"held prop has artwork: "+id)
		check(art.texture(art.PROPS[id]).get_image().get_used_rect().has_area(),"held prop renders: "+id)


func _money_walkover() -> void:
	var gs := root.get_node("GameState")
	gs.reset()
	gs.money = 0
	change_scene_to_file("res://scenes/world/Kiez.tscn")
	await frames(8)
	var scene := current_scene
	var player := scene.get_node("Player") as CharacterBody2D
	player.set_physics_process(false)
	check(gs.money == 0 and scene.has_node("CoinPouch"), "arrival does not automatically collect distant money")
	await capture("kiez-ground-objects")
	var pouch := scene.get_node("CoinPouch")
	if pouch == null:
		paused = false
		return
	var bystander := CharacterBody2D.new()
	pouch._on_body_entered(bystander)
	check(gs.money == 0, "non-player cannot collect money")
	bystander.free()
	var start: Vector2 = player.position
	for step in range(18):
		if not paused:
			player.move_and_collide(start.lerp(Vector2(507,584),float(step)/17.0) - player.position)
		await physics_frame
		await process_frame
	check(gs.money == 5, "walking into money awards five coins without input")
	check(gs.world_flags.get("kiez_pouch_taken", false), "money collection persists in world flags")
	check(not scene.has_node("CoinPouch"), "collected pouch disappears")
	check(not gs.inventory.has("money"), "money goes to wallet, not inventory")
	var pickup := get_first_node_in_group("pickup")
	check(pickup.showing and pickup._item == "money", "money still presents local word")
	await create_timer(1.5).timeout
	await capture("money-word")
	pickup._close()
	await _dropped_items(scene,player,pickup)
	var inv := get_first_node_in_group("inventory")
	gs.add_item("zimmerkarte")
	if inv != null:
		inv._open()
		await frames()
		await capture("inventory-icons")
		check(inv.find_children("ItemIcon","Control",true,false).size() >= 3,"inventory uses object icons")
		inv._close()
	var saves := root.get_node("SaveManager")
	saves.save_game(0)
	gs.world_flags.erase("kiez_pouch_taken")
	gs.money = 0
	check(saves.load_game(0) and gs.world_flags.get("kiez_pouch_taken",false) and gs.money == 5,
		"saved money and collection flag restore together")
	change_scene_to_file("res://scenes/world/Kiez.tscn")
	await frames(8)
	check(not current_scene.has_node("CoinPouch") and gs.money == 5, "returning cannot duplicate money")
	paused = false
	current_scene.free()


func _locations() -> void:
	var gs := root.get_node("GameState")
	gs.active_job = "crates"
	gs.job_progress = 0
	gs.carrying = ""
	gs.spawn_tag = ""
	change_scene_to_file("res://scenes/world/Kiez.tscn")
	await frames(12)
	var player := current_scene.get_node("Player") as CharacterBody2D
	player.set_physics_process(false)
	player.position = Vector2(235,585)
	await capture("job-crates")
	var job := current_scene.get_node("JobSpot1")
	check(job.is_live(),"crate job remains available")
	job._use()
	check(gs.carrying == "crate","crate job still gives a carried load")
	var thought := get_first_node_in_group("thought_box")
	if thought != null: thought.hide()
	paused = false
	await capture("carried-crate")
	current_scene.free()
	gs.reset()
	gs.city = "berlin"
	var streetside = load("res://scenes/world/Streetside.gd")
	var reel: Dictionary = streetside.reel("berlin","kiez",5)
	var cut := CanvasLayer.new()
	cut.set_script(load("res://scenes/ui/Cutscene.gd"))
	root.add_child(cut)
	cut.play("berlin",reel.shots)
	await frames(10)
	await capture("staged-apple-crate")
	check(paused,"original activity starts normally")
	cut._close()
	cut.free()
	paused = false


func _dropped_items(scene: Node, player: Node2D, pickup: Node) -> void:
	var dropped = load("res://scenes/world/DroppedItem.gd")
	var gs := root.get_node("GameState")
	var first = dropped.new()
	first.item = "apple"
	first.position = player.position
	scene.add_child(first)
	var second = dropped.new()
	second.item = "bread"
	second.position = player.position
	scene.add_child(second)
	await frames(6)
	check(gs.inventory.size() == 1,"simultaneous drops wait their turn instead of losing an item")
	check(pickup.showing,"walk-over item presents its word")
	pickup._close()
	await frames(6)
	check(gs.inventory.get("apple",0) == 1 and gs.inventory.get("bread",0) == 1,"both overlapping drops are collected exactly once")
	pickup._close()
