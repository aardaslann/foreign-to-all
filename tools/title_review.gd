extends SceneTree

var checks := 0
var failures := 0
var out := "res://.build/title-review"
var title: Control


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("TITLE: " + message)


func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame


func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(not picture.is_empty(), "rendered " + name)
	check(picture.save_png(out.path_join(name + ".png")) == OK, "saved " + name)


func _run() -> void:
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("title-review")
	var loc := root.get_node("Loc")
	loc.set_language("en")
	DirAccess.make_dir_recursive_absolute(out)
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames()
	title = current_scene
	await create_timer(2.8).timeout
	if OS.get_cmdline_user_args().has("--baseline"):
		await capture("before")
		_finish()
		return
	if OS.get_cmdline_user_args().has("--movie"):
		await create_timer(12.0).timeout
		check(current_scene == title, "title remains interactive during idle animation")
		_finish()
		return
	await _checks(saves, loc)
	_finish()


func _checks(saves: Node, loc: Node) -> void:
	check(title._buttons.size() == 4, "four original menu actions")
	check(root.gui_get_focus_owner() == title._buttons[0], "initial keyboard/controller focus")
	var down := InputEventAction.new()
	down.action = "ui_down"
	down.pressed = true
	root.push_input(down, true)
	await frames()
	down = InputEventAction.new()
	down.action = "ui_down"
	down.pressed = false
	root.push_input(down, true)
	check(root.gui_get_focus_owner() == title._buttons[1], "directional input moves menu focus")
	title._buttons[0].grab_focus()
	check(title._buttons[0].text == tr("menu.new"), "localized new journey")
	await capture("title-1920x1080")
	var original_text: String = title._buttons[0].text
	var original_size: Vector2 = title._buttons[0].size
	title._buttons[0].mouse_entered.emit()
	await frames()
	check(title._buttons[0].text == original_text and title._buttons[0].size == original_size,
		"hover never rewrites or resizes a menu label")
	title._buttons[2].grab_focus()
	await frames()
	check(title._buttons[2].get_node("WingLeft").visible and title._buttons[2].get_node("WingRight").visible, "classic ornaments show for keyboard/controller focus")
	await capture("settings-focus")
	var hover := InputEventMouseMotion.new()
	hover.position = title._buttons[1].get_global_rect().get_center()
	root.push_input(hover, true)
	await frames()
	check(title._buttons[1].get_node("WingLeft").visible, "actual pointer hover shows classic ornament")
	title._buttons[2].pressed.emit()
	await frames()
	check(is_instance_valid(title._overlay), "settings opens")
	check(not title._content.visible, "title content is hidden behind overlay")
	check(title._overlay._frame.back.visible, "mouse-accessible back control")
	saves.settings["reduce_motion"] = true
	loc.set_language("tr")
	title._overlay._frame.back.pressed.emit()
	await frames()
	check(title._overlay == null and title._content.visible, "settings returns to title")
	check(root.gui_get_focus_owner() == title._buttons[2], "focus restored to settings")
	check(title._buttons[0].text == tr("menu.new"), "labels refresh after language change")
	var decor: Control = title.get_node("TitleDecorations")
	var frozen: float = decor._t
	await create_timer(0.15).timeout
	check(decor._t == frozen, "reduced motion freezes ambient animation")
	await capture("turkish-reduced-motion")
	# Every supported localization must fit the same stable control bounds.
	for row: Array in loc.LANGS:
		loc.set_language(String(row[0]))
		await frames(1)
		for button: Button in title._buttons:
			var font := button.get_theme_font("font")
			var font_size := button.get_theme_font_size("font_size")
			check(font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= button.size.x - 56,
				"label fits " + String(row[0]) + " / " + button.name)
	loc.set_language("ar")
	await frames()
	await capture("arabic")
	loc.set_language("en")
	saves.settings["reduce_motion"] = false
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(2560, 1080), Vector2i(1024, 768)]:
		root.content_scale_size = dimensions
		if DisplayServer.get_name() != "headless":
			root.size = dimensions
		await frames()
		var screen := Rect2(Vector2.ZERO, title.size)
		for button: Button in title._buttons:
			check(screen.encloses(button.get_global_rect()), "menu fits " + str(dimensions))
		check(not title._buttons[2].get_global_rect().intersects(title._buttons[3].get_global_rect()), "no menu overlap")
		await capture("layout-%dx%d" % [dimensions.x, dimensions.y])
	root.content_scale_size = Vector2i(1920, 1080)
	if DisplayServer.get_name() != "headless":
		root.size = Vector2i(1920, 1080)
	await frames()
	title._buttons[1].pressed.emit()
	await frames()
	check(title._overlay.get_script().resource_path.ends_with("LoadScreen.gd"), "Continue still opens save slots")
	check(title._overlay._slots_container.get_child_count() == saves.MAX_SLOTS, "empty slots remain available")
	title._overlay.back_requested.emit()
	await frames()
	check(root.gui_get_focus_owner() == title._buttons[1], "load screen restores focus")
	# The first-run language choice must own input, then hand focus to the menu.
	loc._picked = false
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames()
	title = current_scene
	check(is_instance_valid(title._picker) and not title._content.visible, "first-run picker gates the menu")
	check(root.gui_get_focus_owner() != null and title._picker.is_ancestor_of(root.gui_get_focus_owner()), "first-run language picker owns keyboard/controller focus")
	title._picker._choose("en")
	await frames()
	check(title._content.visible and title._picker == null, "language choice reveals menu")
	check(root.gui_get_focus_owner() == title._buttons[0], "language choice restores menu focus")
	title._buttons[0].pressed.emit()
	await create_timer(0.85).timeout
	check(current_scene.scene_file_path.ends_with("CharacterCreator.tscn"), "New Journey opens character creator")
	await capture("creator-default")
	check(root.get_node("GameState").familiarity.is_empty(), "title creates no language progress")


func _finish() -> void:
	print("REVIEW: ", checks, " checks, ", failures, " failures; ", ProjectSettings.globalize_path(out))
	quit(1 if failures else 0)
