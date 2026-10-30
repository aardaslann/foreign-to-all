extends Control

const BG_CLR    := Color(0.055, 0.048, 0.118)
const CLR_DIM   := Color(0.38,  0.34,  0.62)
const CLR_MID   := Color(0.50,  0.46,  0.80)
const CLR_MAIN  := Color(0.96,  0.94,  1.00)
const CLR_HINT  := Color(0.30,  0.28,  0.50)

var _time:             float = 0.0
var _ready_for_input:  bool  = false
var _done:             bool  = false

var _chapter_lbl:  Label
var _sep_left:     ColorRect
var _sep_right:    ColorRect
var _location_lbl: Label
var _glyph_lbl:    Label
var _hint_lbl:     Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _process(delta: float) -> void:
	if _done:
		return
	_time += delta

	# Staggered fade-ins using absolute times from scene start
	_chapter_lbl.modulate.a  = _ease_in(_time, 0.5,  0.55)
	_sep_left.modulate.a     = _ease_in(_time, 0.95, 0.40)
	_sep_right.modulate.a    = _ease_in(_time, 0.95, 0.40)
	_location_lbl.modulate.a = _ease_in(_time, 1.15, 0.65)
	_glyph_lbl.modulate.a    = _ease_in(_time, 1.65, 0.50)
	_hint_lbl.modulate.a     = _ease_in(_time, 2.30, 0.55)

	if _time >= 1.9:
		_ready_for_input = true

	if _time >= 6.0:
		_advance()


func _ease_in(t: float, start: float, dur: float) -> float:
	return clampf((t - start) / dur, 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _ready_for_input or _done:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_advance()


func _advance() -> void:
	if _done:
		return
	_done = true
	TransitionManager.go("res://scenes/world/Kiez.tscn")


# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Background fill
	var bg := ColorRect.new()
	bg.color = BG_CLR
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Vertical-centred content block
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	center.add_child(vbox)

	# — CHAPTER I —
	_chapter_lbl = Label.new()
	_chapter_lbl.text = "C H A P T E R   I"
	_chapter_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chapter_lbl.add_theme_font_size_override("font_size", 12)
	_chapter_lbl.add_theme_color_override("font_color", CLR_MID)
	_chapter_lbl.modulate.a = 0.0
	vbox.add_child(_chapter_lbl)

	# Separator row (two lines with location label between them)
	var sep_margin := MarginContainer.new()
	sep_margin.add_theme_constant_override("margin_top",    22)
	sep_margin.add_theme_constant_override("margin_bottom", 22)
	vbox.add_child(sep_margin)

	var sep_row := HBoxContainer.new()
	sep_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sep_row.add_theme_constant_override("separation", 20)
	sep_margin.add_child(sep_row)

	_sep_left = ColorRect.new()
	_sep_left.color = Color(CLR_DIM.r, CLR_DIM.g, CLR_DIM.b, 0.55)
	_sep_left.custom_minimum_size = Vector2(90, 1)
	_sep_left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sep_left.modulate.a = 0.0
	sep_row.add_child(_sep_left)

	# — Berlin, Germany —
	_location_lbl = Label.new()
	_location_lbl.text = "Berlin, Germany"
	_location_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_location_lbl.add_theme_font_size_override("font_size", 52)
	_location_lbl.add_theme_color_override("font_color", CLR_MAIN)
	_location_lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_location_lbl.modulate.a = 0.0
	sep_row.add_child(_location_lbl)

	_sep_right = ColorRect.new()
	_sep_right.color = Color(CLR_DIM.r, CLR_DIM.g, CLR_DIM.b, 0.55)
	_sep_right.custom_minimum_size = Vector2(90, 1)
	_sep_right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sep_right.modulate.a = 0.0
	sep_row.add_child(_sep_right)

	# Alien glyph ornament
	_glyph_lbl = Label.new()
	_glyph_lbl.text = "◈  ⟟  ⬡  ⟟  ◈"
	_glyph_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_glyph_lbl.add_theme_font_size_override("font_size", 14)
	_glyph_lbl.add_theme_color_override("font_color", CLR_DIM)
	_glyph_lbl.modulate.a = 0.0
	vbox.add_child(_glyph_lbl)

	# Hint label anchored near bottom of screen (not in vbox)
	_hint_lbl = Label.new()
	_hint_lbl.text = "press any key to continue"
	_hint_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_lbl.offset_top    = -46
	_hint_lbl.offset_bottom = -16
	_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_lbl.add_theme_font_size_override("font_size", 12)
	_hint_lbl.add_theme_color_override("font_color", CLR_HINT)
	_hint_lbl.modulate.a = 0.0
	add_child(_hint_lbl)
