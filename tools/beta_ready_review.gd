extends "res://tools/title_review.gd"

const BUILD := preload("res://autoload/BuildInfo.gd")

func _run() -> void:
	out = "res://.build/beta-ready-review"
	DirAccess.make_dir_recursive_absolute(out)
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("beta-ready")
	root.get_node("Loc").set_language("en")
	for language: Array in root.get_node("Loc").LANGS:
		check(not root.get_node("Loc").support_notice(language[0]).is_empty(), "language scope disclosed " + language[0])
	var gs := root.get_node("GameState")
	gs.reset()
	var controls := root.get_node("Controls")
	controls.rebind("interact", KEY_F)
	saves.settings["key_binds"] = {}
	saves.load_settings()
	controls.rebuild()
	check(controls.keys_for("interact") == [KEY_F], "rebound keys survive settings reload")
	controls.rebind("interact", KEY_W)
	saves.settings["key_binds"] = {}
	saves.load_settings()
	controls.rebuild()
	check(not controls.keys_for("walk_up").has(KEY_W), "displaced binding persists")
	check(saves._valid_bindings({"interact":["bad", -1], "injected":[42]}).is_empty(), "invalid bindings discarded")
	controls.reset_binds()
	check(controls.keys_for("interact").has(KEY_E), "defaults restored")
	var world := Node2D.new()
	world.scene_file_path = "res://scenes/world/Kiez.tscn"
	root.add_child(world)
	current_scene = world
	gs.money = 17
	check(saves.save_game(0), "manual save succeeds")
	check(saves.save_game(-1), "checkpoint succeeds")
	var valid: Dictionary = saves._read_json(saves._slot_path(0))
	check(valid.schema == BUILD.SAVE_SCHEMA and valid.build_id == BUILD.BUILD_ID, "schema and build separate")
	var future := valid.duplicate(true)
	future.schema = 999
	check(saves._save_issue(future).contains("newer version"), "future schema clearly rejected")
	gs.money = 21
	check(saves.save_game(0), "existing slot replaced atomically")
	check(saves._read_json(saves._slot_path(0)).money == 21, "replacement contains new state")
	gs.money = 17
	check(saves.save_game(0), "manual overwrite succeeds")
	gs.money = 99
	check(saves.load_game(0) and gs.money == 17, "valid save restores progress")
	var legacy := valid.duplicate(true)
	legacy.erase("schema")
	legacy.erase("build_id")
	legacy["version"] = "0.2.0-beta"
	check(saves._save_issue(legacy).is_empty(), "legacy save accepted")
	for value: Variant in [null, [], {}, {"schema":999}, {"inventory":[]}, {"familiarity":{"german":[]}}, {"wallet":{"EUR":"bad"}}, {"scene":"res://scenes/title/TitleScreen.tscn"}, {"place_position":["bad", 2]}]:
		check(not saves._save_issue(value).is_empty(), "reject invalid save " + str(value))
	var corrupt := FileAccess.open(saves._slot_path(1), FileAccess.WRITE)
	corrupt.store_string("{interrupted")
	corrupt.close()
	gs.money = 63
	check(not saves.load_game(1) and gs.money == 63, "damaged load leaves current state intact")
	check(not saves.get_save_slots()[1].valid, "damaged slot remains visible but unloadable")
	var old_settings_path: String = saves.settings_path
	saves.settings_path = saves.storage_dir.path_join("missing/settings.json")
	check(not saves.save_settings() and not saves.last_error.is_empty(), "settings I/O failure reported")
	saves.settings_path = old_settings_path
	check(not saves.save_game(9), "invalid slot rejected")
	var payload: Dictionary = root.get_node("BetaSession").report("review")
	check(payload.build_id == BUILD.BUILD_ID, "feedback identifies build")
	world.queue_free()
	await frames()
	current_scene = null
	for dimensions: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,768)]:
		root.content_scale_size = dimensions
		if DisplayServer.get_name() != "headless": root.size = dimensions
		var settings: Control = load("res://scenes/title/SettingsMenu.tscn").instantiate()
		root.add_child(settings)
		await frames()
		for tab in range(6):
			settings._tabs.current_tab = tab
			await frames()
			check(settings._frame.get_global_rect().encloses(settings._frame.back.get_global_rect()), "back fits settings viewport")
			if tab == 5:
				var credits: Array[Node] = settings._page.find_children("*", "RichTextLabel", false, false)
				check(credits.size() == 1 and credits[0].text == load("res://scenes/title/ReleaseCredits.gd").TEXT, "credits tab uses current release credits")
			if dimensions.x == 1920 or (dimensions.x == 1280 and tab == 3):
				await capture("settings-%d-%d" % [dimensions.x,tab])
		settings.queue_free()
		await frames()
		var load_ui: Control = load("res://scenes/title/LoadScreen.tscn").instantiate()
		root.add_child(load_ui)
		await frames()
		check(load_ui._slots_container.get_child_count() == 6, "checkpoint plus five slots")
		await capture("journeys-%d" % dimensions.x)
		load_ui._on_delete(0)
		await frames()
		check(FileAccess.file_exists(saves._slot_path(0)), "opening delete preserves save")
		check(load_ui._confirm.get_cancel_button().has_focus(), "delete defaults to safe action")
		load_ui._confirm.hide()
		load_ui._confirm.canceled.emit()
		check(FileAccess.file_exists(saves._slot_path(0)), "cancel deletion preserves save")
		load_ui.queue_free()
		await frames()
	root.content_scale_size = Vector2i(1920,1080)
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1920,1080)
	var feedback: Control = load("res://scenes/ui/BetaFeedback.gd").new()
	root.add_child(feedback)
	await frames()
	check(feedback._show_file.disabled, "no stale file button before export")
	feedback._note.text = "I recognised a word in a different place."
	feedback._request_close()
	await frames()
	check(feedback._discard.visible, "unsaved feedback guarded")
	feedback._discard.hide()
	feedback._save()
	check(not feedback._path.is_empty() and not feedback._show_file.disabled, "feedback export available")
	await capture("feedback")
	feedback.queue_free()
	await frames()
	change_scene_to_file("res://scenes/world/Kiez.tscn")
	await frames(8)
	var pause := current_scene.get_node("UILayer/EscapeMenu")
	pause._open()
	pause._on_settings()
	await frames()
	check(paused and is_instance_valid(pause._settings), "pause owns settings overlay")
	check(pause._settings.size.x >= root.get_visible_rect().size.x, "in-game settings fills viewport")
	pause._settings._go_back()
	await frames()
	check(paused and pause._settings == null, "settings closes without resuming world")
	pause._show_save_panel()
	pause._on_save_to_slot(0)
	await frames()
	check(pause._confirm.visible and pause._confirm.get_cancel_button().has_focus(), "overwrite asks and focuses safe choice")
	pause._confirm.hide()
	pause._confirm.confirmed.emit()
	await frames()
	check(pause._notice.visible and pause._notice.title == "Journey saved", "successful save confirmed")
	pause._notice.hide()
	pause._on_resume()
	check(not paused, "pause restores movement")
	current_scene.queue_free()
	current_scene = null
	await frames()
	check(saves.delete_save(0) and not FileAccess.file_exists(saves._slot_path(0)), "confirmed delete succeeds")
	check(FileAccess.file_exists(saves._slot_path(-1)), "deleting slot preserves checkpoint")
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames(8)
	var title_ui: Control = current_scene
	title_ui._on_settings()
	await frames()
	check(title_ui._overlay._frame.back.has_focus(), "title settings has one focused Back control")
	check(not title_ui._overlay_back.visible, "legacy Back does not overlap menu frame")
	title_ui._overlay._go_back()
	await frames()
	check(title_ui._buttons[2].has_focus(), "settings returns focus to centered title action")
	title_ui._on_load_game()
	await frames()
	title_ui._overlay.back_requested.emit()
	await frames()
	check(title_ui._buttons[1].has_focus(), "Continue returns focus to centered title action")
	var notices := load("res://scenes/title/ReleaseCredits.gd").notices() as String
	check(notices.contains("SIL OPEN FONT LICENSE") and notices.contains("Permission is hereby granted"), "font and engine license text present")
	title_ui.queue_free()
	current_scene = null
	await frames()
	_finish()
