extends CanvasLayer

# The first thing the game asks, and it asks it once.
#
# A game entirely about not being able to read the room should not open by
# handing somebody a menu they have to decode. Twenty languages, each written
# in ITSELF - a picker that lists them in English is the exact joke this game
# is about - and the choice is remembered.

signal picked

const COLS := 4

var _root: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 40
	_build()
	if Loc.has_picked():
		_root.hide()
		queue_free()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var back := ColorRect.new()
	back.color = Color(0.043, 0.039, 0.110, 1.0)
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(back)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -430.0
	box.offset_right = 430.0
	box.offset_top = -250.0
	box.offset_bottom = 250.0
	box.add_theme_constant_override("separation", 10)
	_root.add_child(box)

	# In English AND in the glyphs the game uses for a word he cannot read,
	# because that is the one joke worth making here.
	var glyph := Label.new()
	glyph.text = "\u25c8\u27df\u2b21\u25c9\u27e2\u27e3"
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.add_theme_font_size_override("font_size", 22)
	glyph.add_theme_color_override("font_color", Color(0.42, 0.38, 0.60))
	box.add_child(glyph)

	var title := Label.new()
	title.text = "Choose your language"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.949, 0.914, 0.847))
	box.add_child(title)

	var sub := Label.new()
	sub.text = preload("res://autoload/BuildInfo.gd").LANGUAGE_NOTICE
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_font_override("font", UIStyles.reading_font)
	sub.custom_minimum_size.y = 48
	sub.add_theme_color_override("font_color", Color(0.54, 0.52, 0.70))
	box.add_child(sub)

	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0.0, 22.0)
	box.add_child(pad)

	var grid := GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	box.add_child(grid)

	for row: Array in Loc.LANGS:
		var code: String = String(row[0])
		var b := Button.new()
		b.text = String(row[1]) + (" *" if code != "en" else "")
		b.tooltip_text = Loc.support_notice(code)
		b.focus_entered.connect(func(): sub.text = Loc.support_notice(code))
		b.mouse_entered.connect(func(): sub.text = Loc.support_notice(code))
		b.custom_minimum_size = Vector2(200.0, 46.0)
		b.add_theme_font_size_override("font_size", 17)
		b.pressed.connect(_choose.bind(code))
		grid.add_child(b)


func _choose(code: String) -> void:
	Loc.set_language(code)
	picked.emit()
	_root.hide()
	queue_free()
