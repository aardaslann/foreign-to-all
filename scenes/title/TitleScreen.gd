extends Control

const SettingsMenuScene := preload("res://scenes/title/SettingsMenu.tscn")
const LoadScreenScene := preload("res://scenes/title/LoadScreen.tscn")
const FRAME := Vector2(1920, 1080)
const PAPER := Color8(239, 232, 255)
const LAVENDER := Color8(179, 163, 219)
# "A stranger in every tongue", said in the languages of the cities ahead. In
# most of them the same word also means foreigner, which is rather the point.
const STRANGER := ["Fremder", "yabancı", "stranger", "étranger", "чужой", "अजनबी",
	"異邦人", "forastero", "straniero", "estrangeiro", "người lạ", "이방인", "უცხო", "malihini"]
const STRANGER_EVERY := 0.5        # quick, but long enough to read each word

var _content: Control
var _stranger: Label
var _stranger_at := 0
var _buttons: Array[Button] = []
var _overlay: Control
var _overlay_back: Button
var _picker: CanvasLayer
var _return_focus: Button
var _leaving := false


func _ready() -> void:
	_build()
	Loc.language_changed.connect(_retitle)
	_retitle()
	AudioManager.title_music()
	AudioManager.set_ambience("none")
	resized.connect(_fit)
	_fit()
	if not Loc.has_picked():
		_content.hide()
		_picker = CanvasLayer.new()
		_picker.set_script(preload("res://scenes/title/LanguagePicker.gd"))
		_picker.picked.connect(_language_picked)
		add_child(_picker)
		var languages := _picker.find_children("*", "Button", true, false)
		if not languages.is_empty():
			(languages[0] as Button).grab_focus()
	else:
		_reveal()


func _build() -> void:
	_content = Control.new()
	_content.name = "Content"
	_content.size = FRAME
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)
	var wordmark := HBoxContainer.new()
	wordmark.position = Vector2(0, 233)
	wordmark.size = Vector2(FRAME.x, 98)
	wordmark.alignment = BoxContainer.ALIGNMENT_CENTER
	wordmark.add_theme_constant_override("separation", 0)
	wordmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(wordmark)
	for part: Array in [["F O R E I G N", 72, PAPER], ["  \u00b7  to  \u00b7  ", 30, LAVENDER], ["A L L", 72, PAPER]]:
		var label := _label(part[0], Vector2.ZERO, Vector2.ZERO, part[1], part[2])
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.reparent(wordmark)
	_stranger = _label("", Vector2(560, 352), Vector2(800, 36), 19, LAVENDER, UIStyles.reading_font)
	_stranger.name = "Stranger"
	_stranger.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_show_stranger(0)
	var cycle := create_tween().set_loops()
	cycle.tween_interval(STRANGER_EVERY)
	cycle.tween_callback(_next_stranger)
	var tagline := _label("a stranger in every tongue", Vector2(560, 401), Vector2(800, 34), 22, Color8(165, 159, 205))
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var line := ColorRect.new()
	line.color = Color8(110, 92, 155)
	line.position = Vector2(928, 463)
	line.size = Vector2(64, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content.add_child(line)
	var names := ["NewJourneyButton", "ContinueButton", "SettingsButton", "QuitButton"]
	var actions := [_on_new_game, _on_load_game, _on_settings, _on_quit]
	for i in range(4):
		var button := Button.new()
		button.name = names[i]
		button.position = Vector2(705, 498 + i * 69 + (12 if i == 3 else 0))
		button.size = Vector2(510, 60)
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		_style_button(button)
		button.pressed.connect(actions[i])
		_content.add_child(button)
		_buttons.append(button)
		for side in [0, 1]:
			var ornament := Label.new()
			ornament.name = "WingLeft" if side == 0 else "WingRight"
			ornament.text = "\u25c8"
			ornament.position = Vector2(18 if side == 0 else 463, 11)
			ornament.add_theme_font_size_override("font_size", 25)
			ornament.add_theme_color_override("font_color", LAVENDER)
			ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ornament.hide()
			button.add_child(ornament)
		button.mouse_entered.connect(_highlight.bind(button))
		button.mouse_exited.connect(_highlight.bind(button))
		button.focus_entered.connect(_highlight.bind(button))
		button.focus_exited.connect(_highlight.bind(button))
	for i in range(_buttons.size()):
		var button: Button = _buttons[i]
		button.focus_neighbor_top = button.get_path_to(_buttons[posmod(i - 1, 4)])
		button.focus_neighbor_bottom = button.get_path_to(_buttons[(i + 1) % 4])
	var version := _label("Eight-city beta  /  " + preload("res://autoload/BuildInfo.gd").LABEL, Vector2(560, 1008), Vector2(800, 32), 17, Color8(163, 150, 187))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_back = Button.new()
	_overlay_back.name = "OverlayBack"
	_overlay_back.size = Vector2(180, 48)
	_style_button(_overlay_back)
	_overlay_back.add_theme_font_size_override("font_size", 22)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := _overlay_back.get_theme_stylebox(state).duplicate() as StyleBoxFlat
		box.content_margin_left = 12
		box.content_margin_right = 12
		_overlay_back.add_theme_stylebox_override(state, box)
	_overlay_back.pressed.connect(_back_from_overlay)
	_overlay_back.hide()
	add_child(_overlay_back)


func _label(caption: String, at: Vector2, dimensions: Vector2, font_size: int,
		color: Color, font: Font = null) -> Label:
	var label := Label.new()
	label.text = caption
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color8(9, 6, 19, 200))
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font != null:
		label.add_theme_font_override("font", font)
	_content.add_child(label)
	return label


func _show_stranger(index: int) -> void:
	_stranger_at = index
	_stranger.text = "◈   %s   ◈" % STRANGER[index]


# The word snaps straight to the next language; with reduced motion the line
# holds still.
func _next_stranger() -> void:
	if SaveManager.motion() < 0.5 or not _content.visible:
		return
	_show_stranger((_stranger_at + 1) % STRANGER.size())


func _style_button(button: Button) -> void:
	button.add_theme_font_override("font", UIStyles.reading_font)
	button.add_theme_font_size_override("font_size", 27)
	button.add_theme_color_override("font_color", Color8(197, 184, 222))
	button.add_theme_color_override("font_hover_color", PAPER)
	button.add_theme_color_override("font_focus_color", PAPER)
	button.add_theme_color_override("font_pressed_color", Color8(231, 185, 112))
	button.add_theme_color_override("font_shadow_color", Color8(7, 5, 16))
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_constant_override("shadow_offset_x", 1)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color.TRANSPARENT
		box.content_margin_left = 56
		box.content_margin_right = 56
		button.add_theme_stylebox_override(state, box)


func _highlight(button: Button) -> void:
	var active: bool = button.is_hovered() or button.has_focus()
	var width := button.get_theme_font("font").get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
	button.get_node("WingLeft").position.x = (button.size.x - width) * 0.5 - 47
	button.get_node("WingRight").position.x = (button.size.x + width) * 0.5 + 23
	button.get_node("WingLeft").visible = active
	button.get_node("WingRight").visible = active


func _fit() -> void:
	if _content == null:
		return
	var factor := minf(size.x / FRAME.x, size.y / FRAME.y)
	_content.scale = Vector2.ONE * factor
	_content.position = (size - FRAME * factor) * 0.5
	_overlay_back.position = Vector2(size.x - 205, 16)


func _reveal() -> void:
	_content.show()
	_content.modulate.a = 0.0
	create_tween().tween_property(_content, "modulate:a", 1.0, 0.15 if SaveManager.motion() < 0.5 else 0.85)
	_buttons[0].grab_focus()


func _language_picked() -> void:
	_picker = null
	_retitle()
	_reveal()


func _retitle(_locale: String = "") -> void:
	var keys := ["menu.new", "menu.continue", "menu.settings", "menu.quit"]
	for i in range(_buttons.size()):
		var button: Button = _buttons[i]
		button.text = tr(keys[i])
		button.layout_direction = Control.LAYOUT_DIRECTION_RTL if Loc.is_rtl() else Control.LAYOUT_DIRECTION_LTR
		var font_size := 27
		var font := button.get_theme_font("font")
		while font_size > 17 and font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > 390:
			font_size -= 1
		button.add_theme_font_size_override("font_size", font_size)
		_highlight(button)
	_overlay_back.text = tr("menu.back")


func _on_new_game() -> void:
	if _leaving or is_instance_valid(_picker) or is_instance_valid(_overlay):
		return
	_leaving = true
	TransitionManager.go("res://scenes/title/CharacterCreator.tscn")


func _on_load_game() -> void:
	_open_overlay(LoadScreenScene.instantiate(), _buttons[1])


func _on_settings() -> void:
	_open_overlay(SettingsMenuScene.instantiate(), _buttons[2])


func _on_quit() -> void:
	get_tree().quit()


func _open_overlay(overlay: Control, return_focus: Button) -> void:
	if is_instance_valid(_overlay) or _leaving or is_instance_valid(_picker):
		overlay.queue_free()
		return
	_return_focus = return_focus
	_overlay = overlay
	overlay.back_requested.connect(_on_overlay_closed.bind(overlay))
	add_child(overlay)
	_content.hide()
	move_child(_overlay_back, -1)
	if overlay.get("_frame") != null:
		_overlay_back.hide()
		overlay._frame.back.grab_focus()
	else:
		_overlay_back.show()
		_overlay_back.grab_focus()


func _back_from_overlay() -> void:
	if is_instance_valid(_overlay):
		if _overlay.has_method("_go_back"):
			_overlay._go_back()
		else:
			_on_overlay_closed(_overlay)


func _on_overlay_closed(overlay: Control) -> void:
	if overlay != _overlay:
		return
	overlay.queue_free()
	_overlay = null
	_overlay_back.hide()
	_content.show()
	_retitle()
	_return_focus.grab_focus()
