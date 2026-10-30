extends "res://tools/title_review.gd"

func _run() -> void:
	out = "res://.build/naming-review"
	DirAccess.make_dir_recursive_absolute(out)
	var gs := root.get_node("GameState")
	var saves := root.get_node("SaveManager")
	var story := root.get_node("Story")
	var journey := root.get_node("Journey")
	var audio := root.get_node("AudioManager")
	saves.use_test_storage("naming-review")
	gs.reset()
	gs.alien_appearance = {"skin":3, "eyes":2, "antenna":2, "outfit":1, "accent":4}
	change_scene_to_file("res://scenes/world/Kiez.tscn")
	await frames(8)
	var naming := get_first_node_in_group("naming")
	for city: String in story.MANDATORY:
		journey.ledger().memories[city] = "A remembered afternoon with " + story.person_name(city) + "."
		gs.world_flags["story_holiday_" + city] = true
	for size: Vector2i in [Vector2i(1280,720), Vector2i(1024,768), Vector2i(1920,1080)]:
		root.content_scale_size = size
		root.size = size
		saves.settings["text_size"] = 2
		await frames(5)
		for city: String in story.MANDATORY:
			naming.play(city)
			naming._process(3.0)
			await frames(4)
			check(paused and naming._open, "ending owns input " + city)
			check(naming._line.text.contains(naming.TEMPERATURE[city]) and naming._line.text.contains(journey.ledger().memories[city]), "meaning and memory coexist " + city)
			check(naming._stage.alien.appearance == load("res://scenes/player/AlienAppearance.gd").current(), "custom alien remains the protagonist")
			check(not naming._stage.friend.is_empty(), "selected friend is staged")
			check(audio.has_voice(naming.VOICES[city], story.person(city).gives), "chosen friend has a naming recording " + city)
			check(naming._continue.get_global_rect().end.x <= root.get_visible_rect().size.x + 1, "ending controls fit horizontally")
			check(naming._continue.get_global_rect().end.y <= root.get_visible_rect().size.y + 1, "ending controls fit vertically")
			if city in ["berlin", "tokyo"]: await capture(city + "-" + str(size.x))
			naming._advance()
			await frames(3)
			check(naming._phase == 1 and naming._credits.visible and naming._feedback.visible, "completion offers exploration, credits and feedback")
			check(gs.world_flags.get("ending_seen", false), "completion is saved")
			if city == "berlin":
				await capture("completion-" + str(size.x))
				naming._show_credits()
				await frames(3)
				check(is_instance_valid(naming._overlay) and paused, "credits do not resume the world")
				naming._close_overlay()
				await frames(3)
				naming._show_feedback()
				await frames(3)
				check(is_instance_valid(naming._overlay) and paused, "feedback is accessible after completion")
				naming._overlay._request_close()
				await frames(3)
				check(not is_instance_valid(naming._overlay), "empty feedback returns to completion")
			naming._advance()
			check(not paused and not naming._open, "exploration resumes")
	check(saves.load_game(-1), "completed ending reloads")
	check(gs.world_flags.get("ending_seen", false) and not story.namer().is_empty(), "save retains the chosen name and completion")
	current_scene.queue_free()
	current_scene = null
	await frames(5)
	_finish()
