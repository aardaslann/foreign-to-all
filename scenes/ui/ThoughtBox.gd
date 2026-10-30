extends CanvasLayer

var _panel:      Panel
var _text_label: RichTextLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("thought_box")
	_panel = $Panel
	_style_panel()
	_build_content()
	hide()


func _style_panel() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color            = Color(0.040, 0.032, 0.100, 0.97)
	sb.border_color        = Color(0.40,  0.36,  0.62,  0.55)
	sb.border_width_top    = 1
	sb.border_width_bottom = 1
	sb.border_width_left   = 1
	sb.border_width_right  = 1
	sb.set_corner_radius_all(10)
	sb.shadow_color  = Color(0.0, 0.0, 0.0, 0.55)
	sb.shadow_size   = 14
	sb.shadow_offset = Vector2(0, 4)
	_panel.add_theme_stylebox_override("panel", sb)


func _build_content() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   36)
	margin.add_theme_constant_override("margin_right",  36)
	margin.add_theme_constant_override("margin_top",    26)
	margin.add_theme_constant_override("margin_bottom", 22)
	_panel.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	var ornament := Label.new()
	ornament.text                 = "—  your thoughts  —"
	ornament.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ornament.add_theme_font_size_override("font_size", 13)
	ornament.add_theme_color_override("font_color", Color(0.44, 0.40, 0.70, 0.60))
	col.add_child(ornament)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.scroll_active  = false
	_text_label.autowrap_mode  = TextServer.AUTOWRAP_WORD_SMART
	_text_label.fit_content    = true
	_text_label.add_theme_font_size_override("normal_font_size", 18)
	_text_label.add_theme_color_override("default_color", Color(0.84, 0.80, 1.00, 0.90))
	col.add_child(_text_label)

	var hint := Label.new()
	hint.text                 = "[ E  or  Esc  to close ]"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.44, 0.42, 0.65, 0.55))
	col.add_child(hint)


func show_thought(text: String) -> void:
	_text_label.text = "[i]" + text + "[/i]"
	show()
	get_tree().paused = true
	_fit()


# A box the size of what is in it.
#
# The panel was anchored to a fixed 72% x 60% of the screen, so two lines of
# the alien's own thinking arrived inside twelve hundred pixels of empty dark
# - which reads as a loading screen rather than as a thought, and buries the
# street the thought is about. It is now measured from the text.
const PAD_TOP := 26.0
const PAD_BOTTOM := 22.0
const SIDE := 36.0
const ROWS := 20.0     # the ornament and the close hint
const GAP := 16.0


func _fit() -> void:
	var vp: Vector2 = Vector2(get_viewport().get_visible_rect().size)
	var w: float = clampf(vp.x * 0.46, 420.0, 780.0)
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	_panel.size = Vector2(w, 160.0)
	_text_label.custom_minimum_size.x = w - SIDE * 2.0
	# The label only knows its height once it has been laid out at that width.
	await get_tree().process_frame
	var body: float = maxf(_text_label.get_content_height(), 24.0)
	var h: float = PAD_TOP + ROWS + GAP + body + GAP + ROWS + PAD_BOTTOM
	_panel.size = Vector2(w, minf(h, vp.y * 0.82))
	_panel.position = ((vp - _panel.size) * 0.5).round()


func _close() -> void:
	hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var close_pressed: bool = event.is_action_pressed("ui_cancel") or \
		event.is_action_pressed("interact")
	if close_pressed:
		get_viewport().set_input_as_handled()
		_close()
