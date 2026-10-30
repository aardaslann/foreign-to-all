extends CanvasLayer

# Generic chooser used by the U-Bahn, the airport desk, the exchange booth and
# the job board. Open it with a title and a list of rows; the `chosen` signal
# fires with the row's id, or "" if the player backs out.
#
#   var cp := get_tree().get_first_node_in_group("choice_panel")
#   cp.open("Where to?", "the line map is a coloured tangle", rows)
#   var id: String = await cp.chosen
#
# rows: [{ "id", "label", "sub" (optional), "cost" (optional String),
#          "disabled" (optional bool), "note" (optional String) }]

signal chosen(id: String)

const BG_COLOR := Color(0.055, 0.048, 0.118, 0.98)
const BDR_CLR  := Color(0.30, 0.28, 0.50, 0.55)

var _ui_root:    Control
var _panel_root: Control
var _title:      Label
var _subtitle:   Label
var _rows:       VBoxContainer
var _open := false
var _scroll: ScrollContainer
var _first_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("choice_panel")
	_ui_root = $UIRoot
	_build()


func open(title: String, subtitle: String, rows: Array) -> void:
	if _open:
		return
	_open = true
	_title.text = title
	_subtitle.text = subtitle
	_subtitle.add_theme_font_size_override("font_size", [20, 24, 28][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)])
	_populate(rows)
	_panel_root.show()
	get_tree().paused = true
	_scroll.scroll_vertical = 0
	if is_instance_valid(_first_button):
		_first_button.grab_focus.call_deferred()


func _close(id: String) -> void:
	if not _open:
		return
	_open = false
	_panel_root.hide()
	get_tree().paused = false
	chosen.emit(id)


func _unhandled_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close("")


func _populate(rows: Array) -> void:
	_first_button = null
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()

	for r in rows:
		var row: Dictionary = r
		var disabled: bool = bool(row.get("disabled", false))

		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _row_sb(false))
		if disabled:
			panel.modulate.a = 0.45

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left",   18)
		margin.add_theme_constant_override("margin_right",  18)
		margin.add_theme_constant_override("margin_top",    12)
		margin.add_theme_constant_override("margin_bottom", 12)
		panel.add_child(margin)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		margin.add_child(hbox)
		var item: String = String(row.get("item", ""))
		if not item.is_empty():
			var picture := TextureRect.new()
			var art := preload("res://scenes/world/ItemArt.gd")
			picture.texture = art.texture(art.PROPS.get(item, item))
			picture.custom_minimum_size = Vector2(64, 64)
			picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			hbox.add_child(picture)

		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_theme_constant_override("separation", 2)
		hbox.add_child(col)

		var lbl := Label.new()
		lbl.text = String(row.get("label", ""))
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", [19, 22, 26][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)])
		lbl.add_theme_color_override("font_color", Color(0.94, 0.92, 1.00))
		col.add_child(lbl)

		var sub: String = String(row.get("sub", ""))
		if not sub.is_empty():
			var slbl := Label.new()
			slbl.text = sub
			slbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			slbl.add_theme_font_size_override("font_size", 17)
			slbl.add_theme_color_override("font_color", Color(0.60, 0.58, 0.88, 0.75))
			col.add_child(slbl)

		var cost: String = String(row.get("cost", ""))
		if not cost.is_empty():
			var clbl := Label.new()
			clbl.text = cost
			clbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			clbl.add_theme_font_size_override("font_size", 16)
			clbl.add_theme_color_override("font_color",
				Color(0.55, 0.52, 0.62) if disabled else Color(0.90, 0.76, 0.38))
			hbox.add_child(clbl)

		if not disabled:
			var btn := Button.new()
			btn.flat = true
			btn.set_anchors_preset(Control.PRESET_FULL_RECT)
			for st in ["normal", "hover", "pressed", "focus"]:
				btn.add_theme_stylebox_override(st, StyleBoxEmpty.new())
			var id: String = String(row.get("id", ""))
			btn.mouse_entered.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(true)))
			btn.mouse_exited.connect(func():  panel.add_theme_stylebox_override("panel", _row_sb(false)))
			btn.focus_entered.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(true)))
			btn.focus_exited.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(false)))
			btn.pressed.connect(_close.bind(id))
			panel.add_child(btn)
			if _first_button == null:
				_first_button = btn

		_rows.add_child(panel)


func _row_sb(hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.16, 0.14, 0.30, 0.90) if hovered else Color(0.10, 0.09, 0.18, 0.78)
	sb.border_color = Color(0.50, 0.46, 0.78, 0.75) if hovered else Color(0.24, 0.22, 0.40, 0.38)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	return sb


func _build() -> void:
	_panel_root = Control.new()
	_panel_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_root.add_child(_panel_root)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.52)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel_root.add_child(overlay)

	var panel := Panel.new()
	panel.anchor_left = 0.19; panel.anchor_right  = 0.81
	panel.anchor_top  = 0.09; panel.anchor_bottom = 0.91
	var sb := StyleBoxFlat.new()
	sb.bg_color     = BG_COLOR
	sb.border_color = BDR_CLR
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0, 0, 0, 0.50)
	sb.shadow_size  = 20
	panel.add_theme_stylebox_override("panel", sb)
	_panel_root.add_child(panel)

	var outer := MarginContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	for k in ["left", "right"]:
		outer.add_theme_constant_override("margin_" + k, 36)
	outer.add_theme_constant_override("margin_top", 28)
	outer.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	outer.add_child(vbox)

	_title = Label.new()
	_title.add_theme_font_override("font", UIStyles.reading_font)
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	vbox.add_child(_title)

	var div := MarginContainer.new()
	div.add_theme_constant_override("margin_top", 10)
	div.add_theme_constant_override("margin_bottom", 6)
	var line := ColorRect.new()
	line.color = Color(0.28, 0.26, 0.46, 0.40)
	line.custom_minimum_size = Vector2(0, 1)
	div.add_child(line)
	vbox.add_child(div)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 28)
	_scroll.add_child(body)
	_subtitle = Label.new()
	_subtitle.add_theme_font_override("font", UIStyles.reading_font)
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.add_theme_constant_override("line_spacing", 7)
	_subtitle.add_theme_color_override("font_color", Color(0.88, 0.87, 0.95))
	body.add_child(_subtitle)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 8)
	body.add_child(_rows)
	vbox.add_child(_scroll)

	var foot := Label.new()
	foot.text = "Choose at your own pace  ·  Esc / Back — step away"
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 12)
	foot.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.55))
	vbox.add_child(foot)

	_panel_root.hide()
