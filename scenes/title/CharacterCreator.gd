extends Control

const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
const PREVIEW := preload("res://scenes/title/AlienPreview.gd")
const BACKDROP := preload("res://art/title/berlin-night.png")
const FRAME := Vector2(1920, 1080)
const INK := Color8(16, 13, 32)
const PAPER := Color8(239, 232, 255)
const GOLD := Color8(226, 180, 92)

var _draft: Dictionary = APPEARANCE.DEFAULT.duplicate()
var _frame: Control
var _preview: Control
var _options: VBoxContainer
var _tabs: Array[Button] = []
var _tab := 0
var _choices: Dictionary = {}
var _leaving := false
var _begin: Button
var _states := _make_states()


func _ready() -> void:
	_build()
	resized.connect(_fit)
	_fit()
	_build_options()
	_tabs[0].grab_focus()


func _build() -> void:
	var background := TextureRect.new()
	background.texture = BACKDROP
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color8(57, 48, 79)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_frame = Control.new()
	_frame.size = FRAME
	add_child(_frame)
	_label(tr("cc.title"), Vector2(112, 78), 48, PAPER)
	var subtitle := _label("FOREIGN TO ALL", Vector2(115, 141), 16, Color8(160, 143, 190))
	subtitle.name = "Brand"
	_preview = PREVIEW.new()
	_preview.position = Vector2(180, 200)
	_preview.size = Vector2(650, 680)
	_frame.add_child(_preview)
	var left := _button("\u2190", Vector2(365, 741), Vector2(56, 52), _rotate.bind(-1))
	left.tooltip_text = tr("cc.left")
	var right := _button("\u2192", Vector2(579, 741), Vector2(56, 52), _rotate.bind(1))
	right.tooltip_text = tr("cc.right")
	var walk := _button(tr("cc.walk"), Vector2(437, 741), Vector2(126, 52), _walk)
	walk.name = "Walk"
	walk.toggle_mode = true
	for i in range(2):
		var tab := _button(tr(["cc.appearance", "cc.clothing"][i]), Vector2(946 + i * 304, 192), Vector2(286, 57), _select_tab.bind(i))
		tab.toggle_mode = true
		_tabs.append(tab)
	_options = VBoxContainer.new()
	_options.position = Vector2(946, 283)
	_options.size = Vector2(626, 580)
	_options.add_theme_constant_override("separation", 20)
	_frame.add_child(_options)
	_button(tr("cc.random"), Vector2(946, 860), Vector2(220, 54), _randomize)
	_button(tr("cc.reset"), Vector2(1182, 860), Vector2(180, 54), _reset)
	_button(tr("menu.back"), Vector2(112, 972), Vector2(205, 56), _back)
	var onward := "\u2190" if Loc.is_rtl() else "\u2192"
	_begin = _button(tr("cc.begin") + "  " + onward, Vector2(1375, 958), Vector2(345, 70), _confirm)
	_begin.add_theme_color_override("font_color", GOLD)


func _label(text: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(label)
	return label


func _button(text: String, at: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = at
	button.custom_minimum_size = dimensions
	button.size = dimensions
	button.add_theme_font_override("font", UIStyles.reading_font)
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", PAPER)
	button.add_theme_color_override("font_hover_color", PAPER)
	button.add_theme_color_override("font_focus_color", PAPER)
	button.add_theme_color_override("font_pressed_color", GOLD)
	button.add_theme_color_override("font_hover_pressed_color", GOLD)
	for state: String in _states:
		button.add_theme_stylebox_override(state, _states[state])
	button.pressed.connect(action)
	_frame.add_child(button)
	return button


# Chosen and focused are different things - a tab stays chosen while the
# cursor is elsewhere - so they must not look alike. Chosen is warm with a
# gold edge; focus is a pale outline just outside the edge, drawn over either.
static func _make_states() -> Dictionary:
	var states := {}
	for state: String in ["normal", "hover", "pressed", "hover_pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(3)
		match state:
			"normal":
				style.bg_color = Color8(36, 29, 56, 215)
				style.border_color = Color8(91, 75, 121)
				style.set_border_width_all(1)
			"hover":
				style.bg_color = Color8(52, 41, 76, 230)
				style.border_color = Color8(150, 128, 190)
				style.set_border_width_all(1)
			"pressed", "hover_pressed":
				style.bg_color = Color8(74, 56, 50) if state == "pressed" else Color8(88, 66, 56)
				style.border_color = GOLD
				style.set_border_width_all(2)
			"focus":
				style.draw_center = false
				style.border_color = Color8(232, 224, 255, 220)
				style.set_border_width_all(2)
				style.set_expand_margin_all(4)
		states[state] = style
	return states


func _select_tab(index: int) -> void:
	_tab = index
	_build_options()


func _build_options() -> void:
	for child in _options.get_children():
		_options.remove_child(child)
		child.queue_free()
	_choices.clear()
	for i in range(_tabs.size()):
		_tabs[i].button_pressed = i == _tab
	if _tab == 0:
		_swatches("skin", tr("cc.skin"))
		_swatches("eyes", tr("cc.eyes"))
		_thumbnails("antenna", tr("cc.antennae"), [tr("cc.twin"), tr("cc.round"), tr("cc.crest"), tr("cc.sprout")])
	else:
		_swatches("coat", tr("cc.coat"))
		_swatches("accent", tr("cc.details"))
		_swatches("boots", tr("cc.boots"))
		_thumbnails("outfit", tr("cc.pattern"), [tr("cc.plain"), tr("cc.bands"), tr("cc.stitches")])
	_refresh()


func _row(key: String, caption: String) -> HBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 13)
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color8(201, 188, 220))
	section.add_child(label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	section.add_child(row)
	_options.add_child(section)
	_choices[key] = []
	return row


func _swatches(key: String, caption: String) -> void:
	var row := _row(key, caption)
	var colors: Array = APPEARANCE.COLORS[key]
	for i in range(colors.size()):
		var button := _button("", Vector2.ZERO, Vector2(62, 58), _choose.bind(key, i))
		button.reparent(row)
		button.toggle_mode = true
		button.tooltip_text = "%s %d" % [caption, i + 1]
		var swatch := ColorRect.new()
		swatch.color = colors[i]
		swatch.position = Vector2(9, 9)
		swatch.size = Vector2(44, 40)
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(swatch)
		var mark := Label.new()
		mark.name = "Selected"
		mark.text = "\u2713"
		mark.position = Vector2(21, 12)
		mark.add_theme_font_size_override("font_size", 24)
		mark.add_theme_color_override("font_color", Color.WHITE)
		mark.add_theme_color_override("font_outline_color", INK)
		mark.add_theme_constant_override("outline_size", 5)
		button.add_child(mark)
		_choices[key].append(button)


func _thumbnails(key: String, caption: String, names: Array) -> void:
	var row := _row(key, caption)
	for i in range(names.size()):
		var button := _button(names[i], Vector2.ZERO, Vector2(135, 132), _choose.bind(key, i))
		button.reparent(row)
		button.toggle_mode = true
		button.add_theme_font_size_override("font_size", 18)
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 78)
		_choices[key].append(button)


func _choose(key: String, index: int) -> void:
	_draft[key] = index
	_refresh()


func _refresh() -> void:
	_preview.appearance = _draft.duplicate()
	_preview.refresh()
	for key: String in _choices:
		for i in range(_choices[key].size()):
			var button: Button = _choices[key][i]
			button.button_pressed = int(_draft[key]) == i
			var mark := button.get_node_or_null("Selected")
			if mark != null:
				mark.visible = button.button_pressed
			else:
				var option := _draft.duplicate()
				option[key] = i
				var texture := AtlasTexture.new()
				texture.atlas = APPEARANCE.strip("idle_down", option)
				texture.region = Rect2(0, 0, 32, 32)
				button.icon = texture


func _rotate(direction: int) -> void:
	_preview.facing = posmod(_preview.facing + direction, 4)
	_preview.refresh()


func _walk() -> void:
	_preview.walking = not _preview.walking
	_preview.refresh()


func _randomize() -> void:
	for key: String in APPEARANCE.DEFAULT:
		var count: int = APPEARANCE.COLORS[key].size() if APPEARANCE.COLORS.has(key) else (4 if key == "antenna" else 3)
		_draft[key] = randi_range(0, count - 1)
	_refresh()


func _reset() -> void:
	_draft = APPEARANCE.DEFAULT.duplicate()
	_refresh()


func _confirm() -> void:
	if _leaving:
		return
	_leaving = true
	_begin.disabled = true
	GameState.reset()
	GameState.alien_appearance = APPEARANCE.sanitize(_draft)
	TransitionManager.go("res://scenes/cutscene/IntroCutscene.tscn")


func _back() -> void:
	if not _leaving:
		_leaving = true
		TransitionManager.go("res://scenes/title/TitleScreen.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back()


func _fit() -> void:
	if _frame == null:
		return
	var factor := minf(size.x / FRAME.x, size.y / FRAME.y)
	_frame.scale = Vector2.ONE * factor
	_frame.position = (size - FRAME * factor) * 0.5
