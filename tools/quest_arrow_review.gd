extends "res://tools/title_review.gd"

var gs: Node
var saves: Node
var controls: Node
var arrow: Node
var log_ui: Node

func key(code: int, echo := false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	root.push_input(event, true)
	await frames()
	event = InputEventKey.new()
	event.physical_keycode = code
	root.push_input(event, true)
	await frames()

func enter(path: String) -> void:
	change_scene_to_file(path)
	await frames(12)
	arrow = current_scene.get_node("UILayer/QuestArrow")
	log_ui = current_scene.get_node("UILayer/QuestLog")
	log_ui._tracker_hold = 0.0

func _run() -> void:
	out = "res://.build/quest-arrow-review"
	DirAccess.make_dir_recursive_absolute(out)
	saves = root.get_node("SaveManager")
	saves.use_test_storage("quest-arrow-review")
	controls = root.get_node("Controls")
	controls.reset_binds()
	root.get_node("Loc").set_language("en")
	gs = root.get_node("GameState")
	gs.reset()
	var defaults: Node = saves.get_script().new()
	check(defaults.settings.get("quest_arrow", false) == false, "new preference defaults off")
	defaults.free()
	check(controls.ACTIONS.has("quest_arrow"), "quest arrow has its own rebindable action")
	if not controls.ACTIONS.has("quest_arrow"):
		_finish()
		return
	saves.settings.quest_arrow = false
	await enter("res://scenes/world/Kiez.tscn")
	gs.quests.clear()
	gs.start_quest("arrow_review", "A friend in Mitte", ["Find the hotel"], ["res://scenes/world/Mitte.tscn"])
	log_ui._tracker_hold = 0.0
	await frames()
	arrow._process(120.0)
	check(not arrow._on, "waiting two minutes never enables the arrow")
	check(log_ui._arrow_hint.visible and log_ui._arrow_hint.text.contains("G"), "binding appears below active intention")
	check(log_ui._arrow_hint.position.y > log_ui._tracker.get_rect().end.y, "hint clears tracker bottom")
	await capture("arrow-off")
	await key(KEY_G)
	check(saves.settings.quest_arrow and arrow._on, "actual G press shows route immediately")
	check(log_ui._arrow_hint.text.contains("ON"), "hint reports enabled state")
	await capture("arrow-on")
	await key(KEY_G, true)
	check(saves.settings.quest_arrow, "keyboard repeat does not toggle repeatedly")
	gs.start_quest("other_review", "Another intention", ["Look around"])
	await frames()
	check(saves.settings.quest_arrow and arrow._on, "quest updates do not reset preference")
	await enter("res://scenes/world/MitteOst.tscn")
	check(saves.settings.quest_arrow and arrow._on, "door transitions retain arrow choice")
	gs.world_flags["has_map"] = true
	await key(KEY_TAB)
	check(paused and current_scene.get_node("UILayer/MapView")._panel_root.visible, "Tab still opens the map")
	check(saves.settings.quest_arrow and not arrow._on, "map suppresses arrow without changing preference")
	await key(KEY_ESCAPE)
	check(not paused and arrow._on, "closing map restores enabled arrow")
	paused = true
	await frames()
	check(not arrow._on and not log_ui._arrow_hint.visible, "pause hides arrow and hint")
	await key(KEY_G)
	check(saves.settings.quest_arrow, "paused input does not alter arrow choice")
	paused = false
	await frames()
	var dialogue := get_first_node_in_group("dialogue_box")
	dialogue.show()
	await frames()
	check(not arrow._on, "dialogue hides arrow")
	await key(KEY_G)
	check(saves.settings.quest_arrow, "dialogue input does not toggle arrow")
	dialogue.hide()
	await frames()
	check(arrow._on, "arrow resumes after dialogue")
	root.get_node("Journey").busy = true
	await frames()
	check(not arrow._on and not log_ui._arrow_hint.visible, "staged story hides arrow and hint")
	await key(KEY_G)
	check(saves.settings.quest_arrow, "story input cannot change preference")
	root.get_node("Journey").busy = false
	root.get_node("TransitionManager")._busy = true
	await frames()
	check(not arrow._on, "transition hides arrow")
	root.get_node("TransitionManager")._busy = false
	controls.rebind("quest_arrow", KEY_H)
	await frames()
	check(log_ui._arrow_hint.text.begins_with("H"), "hint follows rebound key")
	await key(KEY_G)
	check(saves.settings.quest_arrow, "old binding is inactive")
	await key(KEY_H)
	check(not saves.settings.quest_arrow and not arrow._on, "rebound key hides arrow")
	var pad := InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_RIGHT_STICK
	pad.pressed = true
	root.push_input(pad, true)
	await frames()
	pad = InputEventJoypadButton.new()
	pad.button_index = JOY_BUTTON_RIGHT_STICK
	root.push_input(pad, true)
	await frames()
	check(saves.settings.quest_arrow and arrow._on, "right-stick press toggles arrow")
	saves.settings.quest_arrow = false
	saves.load_settings()
	check(saves.settings.quest_arrow, "preference persists in isolated settings")
	check(saves.save_game(0) and saves.load_game(0), "journey saves remain compatible")
	check(saves.settings.quest_arrow, "loading journey preserves preference")
	var settings: Control = load("res://scenes/title/SettingsMenu.tscn").instantiate()
	root.add_child(settings)
	settings._show_page(3)
	check(settings._bind_buttons.has("quest_arrow"), "toggle is available in control settings")
	settings.queue_free()
	await frames()
	gs.quests["arrow_review"].steps[0].target = current_scene.scene_file_path
	await frames()
	check(not arrow._on and log_ui._arrow_hint.text.contains("here"), "destination reached hides arrow with clear hint")
	gs.quests["arrow_review"].steps[0].target = ""
	await frames()
	check(not arrow._on and log_ui._arrow_hint.text.contains("no route"), "non-location step does not invent a direction")
	gs.quests.erase("other_review")
	gs.quests["arrow_review"].completed = true
	gs.quests["arrow_review"].steps[0].done = true
	log_ui._last_completed = "arrow_review"
	log_ui._fade_t = 6.0
	log_ui._refresh_tracker()
	await frames()
	check(log_ui._tracker.visible and not log_ui._arrow_hint.visible, "completed intention lingers without a toggle hint")
	gs.quests.clear()
	log_ui._fade_t = -1.0
	log_ui._refresh_tracker()
	await frames()
	check(not arrow._on and not log_ui._arrow_hint.visible, "no quest leaves no arrow or hint")
	controls.reset_binds()
	check(controls.keys_for("district_map") == [KEY_TAB, KEY_M], "map shortcuts retained")
	check(controls.keys_for("quest_arrow") == [KEY_G], "reset restores G")
	gs.quests.clear()
	gs.start_quest("arrow_layout", "A friend in Mitte", ["Find the hotel and ask at the reception desk"], ["res://scenes/world/Mitte.tscn"])
	log_ui._tracker_hold = 0.0
	for dimensions: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,768)]:
		root.content_scale_size = dimensions
		if DisplayServer.get_name() != "headless": root.size = dimensions
		for text_size in range(3):
			saves.settings.text_size = text_size
			log_ui._refresh_tracker()
			await frames(8)
			check(log_ui._arrow_hint.position.y > log_ui._tracker.get_rect().end.y, "hint clears quest at %s text %d" % [dimensions, text_size])
			check(root.get_visible_rect().encloses(log_ui._arrow_hint.get_global_rect()), "hint stays within viewport")
		await capture("hint-%dx%d" % [dimensions.x, dimensions.y])
	_finish()
