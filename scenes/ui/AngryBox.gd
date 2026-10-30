extends CanvasLayer

# A muffled voice through a closed door — not a conversation, just a wall of
# hostile sound. No responses to pick; any key or click makes you back away.
# The panel trembles slightly, because so does the door.

const GLYPHS_FULL   := "◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡"
const GLYPHS_SIMPLE := "▲▼●■◆★▸◀▴▾"

var _ui_root:  Control
var _panel:    PanelContainer
var _src_lbl:  Label
var _text_lbl: Label
var _hint_lbl: Label
var _t: float = 0.0
var _open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("angry_box")
	_ui_root = $UIRoot
	_build_ui()


func _process(delta: float) -> void:
	if not _open:
		return
	_t += delta
	# Tremble — sharp and small, decaying over the first moments
	var decay := maxf(0.35, 1.0 - _t * 0.7)
	var jx := sin(_t * 61.0) * 2.2 * decay
	var jy := cos(_t * 47.0) * 1.4 * decay
	_panel.position = Vector2(
		(_ui_root.size.x - _panel.size.x) * 0.5 + jx,
		96.0 + jy)


func show_angry(words: Array, source: String) -> void:
	if _open:
		return
	_src_lbl.text  = source
	_text_lbl.text = _render(words) + "!!"
	_t = 0.0
	_open = true
	_panel.modulate.a = 0.0
	_panel.show()
	var tw := create_tween()
	tw.tween_property(_panel, "modulate:a", 1.0, 0.12)
	get_tree().paused = true


func _close() -> void:
	_open = false
	_panel.hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not _open:
		return
	var pressed: bool = false
	if event is InputEventKey and event.pressed and not event.echo:
		pressed = true
	elif event is InputEventMouseButton and event.pressed:
		pressed = true
	if pressed:
		get_viewport().set_input_as_handled()
		_close()


func _render(words: Array) -> String:
	var parts: PackedStringArray = []
	for w in words:
		var wkey: String = w.get("word", "")
		var disp: String = w.get("text", "")
		if GameState.get_tier("german", wkey) >= GameState.TIER_PARTIAL:
			parts.append(disp)
		else:
			parts.append(_to_glyphs(wkey) + _trailing_punct(disp))
	return " ".join(parts)


func _trailing_punct(disp: String) -> String:
	var out := ""
	for i in range(disp.length() - 1, -1, -1):
		var ch: String = disp[i]
		if ch in ["!", "?", ".", ","]:
			out = ch + out
		else:
			break
	return out


func _to_glyphs(word: String) -> String:
	var g := GLYPHS_SIMPLE if SaveManager.settings.get("simplified_glyph_set", false) else GLYPHS_FULL
	var out := ""
	for i in range(word.length()):
		out += g[word.unicode_at(i) % g.length()]
	return out


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(380, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.110, 0.040, 0.048, 0.97)
	sb.border_color = Color(0.72, 0.24, 0.20, 0.75)
	sb.border_width_left = 2; sb.border_width_right  = 2
	sb.border_width_top  = 2; sb.border_width_bottom = 2
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0.30, 0.02, 0.02, 0.45)
	sb.shadow_size  = 16
	sb.content_margin_left  = 28.0
	sb.content_margin_right = 28.0
	sb.content_margin_top    = 16.0
	sb.content_margin_bottom = 14.0
	_panel.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)

	_src_lbl = Label.new()
	_src_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_src_lbl.add_theme_font_size_override("font_size", 12)
	_src_lbl.add_theme_color_override("font_color", Color(0.85, 0.48, 0.42, 0.80))
	col.add_child(_src_lbl)

	_text_lbl = Label.new()
	_text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_lbl.add_theme_font_size_override("font_size", 22)
	_text_lbl.add_theme_color_override("font_color", Color(1.00, 0.86, 0.82))
	col.add_child(_text_lbl)

	_hint_lbl = Label.new()
	_hint_lbl.text = "…back away  (any key)"
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_font_size_override("font_size", 11)
	_hint_lbl.add_theme_color_override("font_color", Color(0.70, 0.42, 0.38, 0.60))
	col.add_child(_hint_lbl)

	_panel.hide()
	_ui_root.add_child(_panel)
