extends "res://tools/title_review.gd"

const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
var CHAR: Script
var CUT_ART: Script
var PLAYER: Script
var SS: Script


func click(button: Button) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		root.push_input(event, true)
		await frames()


func _run() -> void:
	CHAR = load("res://scenes/npc/CharacterArt.gd")
	CUT_ART = load("res://scenes/ui/CutsceneArt.gd")
	PLAYER = load("res://scenes/player/Player.gd")
	SS = load("res://scenes/world/Streetside.gd")
	out = "res://.build/character-review"
	DirAccess.make_dir_recursive_absolute(out)
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("character-review")
	root.get_node("Loc").set_language("en")
	var gs := root.get_node("GameState")
	gs.reset()
	gs.money = 73
	gs.world_flags["creator_cancel_sentinel"] = true
	change_scene_to_file("res://scenes/title/CharacterCreator.tscn")
	await frames()
	var creator := current_scene
	await click(creator._choices.skin[1])
	check(creator._draft.skin == 1, "actual mouse chooses skin")
	check(gs.alien_appearance == APPEARANCE.DEFAULT and gs.money == 73, "draft does not mutate a running journey")
	creator._back()
	await create_timer(0.8).timeout
	check(gs.money == 73 and gs.world_flags.has("creator_cancel_sentinel"), "cancel preserves existing progress")
	check(current_scene.scene_file_path.ends_with("TitleScreen.tscn"), "cancel returns to title")
	current_scene._on_new_game()
	await create_timer(0.8).timeout
	creator = current_scene
	var custom := {"skin": 1, "coat": 2, "accent": 4, "eyes": 1, "boots": 1, "antenna": 3, "outfit": 2}
	for key: String in custom:
		creator._choose(key, custom[key])
	await frames()
	await capture("appearance-custom")
	creator._select_tab(1)
	await frames()
	await capture("clothing-custom")
	for key: String in creator._choices:
		for button: Button in creator._choices[key]:
			check(button.get_global_rect().end.y < 860, "clothing controls clear footer")
	creator._rotate(1)
	check(creator._preview.facing == 1, "turn preview")
	creator._walk()
	check(creator._preview.walking, "walk preview")
	creator._randomize()
	check(APPEARANCE.sanitize(creator._draft) == creator._draft, "randomization stays in valid choices")
	creator._reset()
	check(creator._draft == APPEARANCE.DEFAULT, "reset restores original alien")
	for key: String in custom:
		creator._choose(key, custom[key])
	for dimensions: Vector2i in [Vector2i(1280,720), Vector2i(1024,768), Vector2i(2560,1080)]:
		root.content_scale_size = dimensions
		if DisplayServer.get_name() != "headless": root.size = dimensions
		await frames()
		check(Rect2(Vector2.ZERO, creator.size).encloses(creator._begin.get_global_rect()), "creator fits " + str(dimensions))
		await capture("creator-%dx%d" % [dimensions.x, dimensions.y])
	root.content_scale_size = Vector2i(1920,1080)
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1920,1080)
	await frames()
	# Every authored animation is recolored; the original remains byte-exact.
	var animations: Array = PLAYER.ANIMS.keys() + ["read_down"]
	for animation: String in animations:
		var original := load(PLAYER.STRIP_DIR + animation + ".png") as Texture2D
		var legacy := APPEARANCE.strip(animation, {})
		check(legacy == original, "default retains authored strip " + animation)
		for antenna in range(4):
			var variant := custom.duplicate()
			variant.antenna = antenna
			var rendered := APPEARANCE.strip(animation, variant).get_image()
			check(rendered.get_size() == Vector2i(original.get_size()), "frame grid retained " + animation)
			check(rendered.get_data() != original.get_image().get_data(), "custom pixels present " + animation)
	check(APPEARANCE.sanitize(null) == APPEARANCE.DEFAULT, "invalid appearance defaults")
	var bad := APPEARANCE.sanitize({"skin": 999, "eyes": "bad", "coat": -2, "outfit": []})
	check(bad.skin == 7 and bad.eyes == 0 and bad.coat == 0 and bad.outfit == 0, "malformed choices sanitized")
	await click(creator._begin)
	await create_timer(0.85).timeout
	check(current_scene.scene_file_path.ends_with("IntroCutscene.tscn"), "confirm enters intro")
	check(gs.alien_appearance == custom and gs.money == 0, "confirm commits appearance and starts fresh journey")
	var intro := current_scene
	check(intro._stage._alien.appearance == custom, "opening uses customized actor")
	intro.set_process(false)
	intro._time = 21.8
	intro._present()
	await frames()
	await capture("customized-opening")
	intro._go_to_game()
	await create_timer(0.85).timeout
	check(current_scene.scene_file_path.ends_with("Kiez.tscn"), "customized opening reaches Kiez")
	var player: Node = current_scene.get_node("Player")
	var frame: AtlasTexture = player._sprite.sprite_frames.get_frame_texture("idle_down", 0)
	check(frame.atlas.get_image().get_data() == APPEARANCE.strip("idle_down", custom).get_image().get_data(), "gameplay renders saved appearance")
	await capture("customized-kiez")
	saves.save_game(0)
	saves.checkpoint()
	gs.alien_appearance = APPEARANCE.DEFAULT.duplicate()
	check(saves.load_game(0) and gs.alien_appearance == custom, "manual save round trip")
	gs.alien_appearance = APPEARANCE.DEFAULT.duplicate()
	check(saves.load_game(-1) and gs.alien_appearance == custom, "checkpoint round trip")
	check(CHAR.alien_look().appearance == custom and CUT_ART.alien_look().appearance == custom, "shared story/activity cutscene renderer uses appearance")
	# Render an actual existing activity, not a substitute character mockup.
	var reel: Dictionary = SS.reel("berlin", "kiez", 5)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920,1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var cut := CanvasLayer.new()
	cut.set_script(load("res://scenes/ui/Cutscene.gd"))
	viewport.add_child(cut)
	cut.play("berlin", reel.shots)
	await frames(10)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png(out.path_join("customized-activity.png")) == OK, "rendered existing activity")
	cut._close()
	viewport.queue_free()
	paused = false
	# Older saves and malformed optional cosmetic data remain loadable.
	var path: String = saves.storage_dir + "slot_0.json"
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data.erase("alien_appearance")
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	check(saves.load_game(0) and gs.alien_appearance == APPEARANCE.DEFAULT, "old save restores original alien")
	data.alien_appearance = "invalid"
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	check(saves.load_game(0) and gs.alien_appearance == APPEARANCE.DEFAULT, "corrupt cosmetics do not break otherwise valid save")
	_finish()
