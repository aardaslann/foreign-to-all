extends Control

const ART := preload("res://art/title/berlin-night.png")
const BUILD := preload("res://autoload/BuildInfo.gd")
const INK := Color("eee8ff")
const MUTED := Color("b1a4cc")
const GOLD := Color("e9bd7c")
var body: VBoxContainer
var footer: HBoxContainer
var back: Button


func _draw() -> void:
	var ratio := maxf(size.x / ART.get_width(), size.y / ART.get_height())
	var dimensions := ART.get_size() * ratio
	draw_texture_rect(ART, Rect2((size - dimensions) * 0.5, dimensions), false)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.08, 0.86))
	draw_line(Vector2(31, 48), Vector2(31, size.y - 48), Color("71608b"), 1)
	draw_rect(Rect2(28, 48, 7, 7), GOLD)
	draw_rect(Rect2(28, size.y - 55, 7, 7), GOLD)


func build(owner: Control, heading: String, section: String) -> void:
	owner.add_child(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 72)
	for side: String in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 38)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var mast := HBoxContainer.new()
	column.add_child(mast)
	var brand := label("FOREIGN TO ALL   /   " + section.to_upper(), 16, MUTED)
	brand.size_flags_horizontal = SIZE_EXPAND_FILL
	mast.add_child(brand)
	back = button("Back")
	mast.add_child(back)
	column.add_child(label(heading, 36, INK))
	column.add_child(HSeparator.new())
	body = VBoxContainer.new()
	body.size_flags_vertical = SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	column.add_child(body)
	column.add_child(HSeparator.new())
	footer = HBoxContainer.new()
	column.add_child(footer)
	var edition := label("EIGHT-CITY BETA", 14, MUTED)
	edition.size_flags_horizontal = SIZE_EXPAND_FILL
	footer.add_child(edition)
	footer.add_child(label(BUILD.LABEL, 14, MUTED))


static func label(text: String, font_size: int = 22, color: Color = INK) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_override("font", UIStyles.reading_font)
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	return result


static func button(text: String, danger := false) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(112, 44)
	result.add_theme_font_override("font", UIStyles.reading_font)
	result.add_theme_font_size_override("font_size", 20)
	result.add_theme_color_override("font_color", Color("f3b3b5") if danger else INK)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("382840") if danger else Color("272035")
		box.border_color = GOLD if state == "focus" else Color("79648f")
		box.set_border_width_all(2 if state == "focus" else 1)
		if state == "hover": box.bg_color = Color("453553")
		if state == "pressed": box.bg_color = Color("181220")
		box.content_margin_left = 16
		box.content_margin_right = 16
		box.content_margin_top = 8
		box.content_margin_bottom = 8
		result.add_theme_stylebox_override(state, box)
	return result


static func scroll_column(parent: Control, max_width := 0) -> VBoxContainer:
	var host: Control = parent
	if max_width > 0:
		var margin := MarginContainer.new()
		margin.size_flags_vertical = SIZE_EXPAND_FILL
		parent.add_child(margin)
		var fit := func(): margin.add_theme_constant_override("margin_right", maxi(0, int(parent.size.x) - max_width))
		parent.resized.connect(fit)
		fit.call_deferred()
		host = margin
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	host.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 16)
	scroll.add_child(column)
	return column
