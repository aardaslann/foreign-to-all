extends CanvasLayer

const BG_COLOR := Color(0.055, 0.048, 0.118, 0.98)
const BDR_CLR  := Color(0.30, 0.28, 0.50, 0.55)

const TOAST_LIFE := 2.8
const TOAST_FADE := 0.45

# What a thing is, asked of the one place that knows.
#
# This panel used to carry its own copy of the item table, which meant the only
# thing in the game that knew what a loaf was called was the list that
# displayed it, and nothing else could say the word out loud. The registry is
# autoload/Items.gd now, and the pickup card and this list cannot disagree.
#
# The local word comes first where there is one: the same stiff rectangle is a
# Fahrkarte in Berlin and a bilet in Istanbul, and seeing that in a list is the
# argument of the whole game in one line.
func _def(item: String) -> Dictionary:
	var base: String = Items.display_name(item)
	var word: String = Items.word_for(item)
	return {
		"name": (word + "   " + base) if not word.is_empty() else base,
		"desc": Items.reading(item),
		"color": Items.colour(item),
		"eatable": Items.eatable(item),
	}


var _ui_root:    Control
var _panel_root: Control
var _item_list:  VBoxContainer
var _money_line: Label

var _toasts:       Array      = []   # [{ "p": PanelContainer, "age": float }]
var _known_money:  int        = 0
var _known_counts: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("inventory")
	_ui_root = $UIRoot
	_build_ui()
	_known_money = GameState.money
	_known_counts = GameState.inventory.duplicate()
	GameState.money_changed.connect(_on_money_changed)
	GameState.item_changed.connect(_on_item_changed)


func _process(delta: float) -> void:
	_update_toasts(delta)


func open_from_hud() -> void:
	if not _panel_root.visible and not get_tree().paused:
		_open()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if _panel_root.visible:
			_close()
		elif not get_tree().paused:
			_open()
	elif event.is_action_pressed("back") and _panel_root.visible:
		get_viewport().set_input_as_handled()
		_close()


func _open() -> void:
	_populate()
	_panel_root.show()
	get_tree().paused = true


func _close() -> void:
	_panel_root.hide()
	get_tree().paused = false


# ── Overlay panel ─────────────────────────────────────────────────────────────

func _build_ui() -> void:
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
	panel.anchor_left = 0.22; panel.anchor_right  = 0.78
	panel.anchor_top  = 0.12; panel.anchor_bottom = 0.88
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
	var margins := {"left": 42, "right": 42, "top": 32, "bottom": 28}
	for k: String in margins:
		outer.add_theme_constant_override("margin_" + k, margins[k])
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	outer.add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = tr("inv.title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	header.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "×  close"
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UIStyles.style_menu_btn(close_btn)
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)
	vbox.add_child(header)

	# Money line
	_money_line = Label.new()
	_money_line.add_theme_font_size_override("font_size", 14)
	_money_line.add_theme_color_override("font_color", Color(0.82, 0.68, 0.30, 0.90))
	vbox.add_child(_money_line)

	# Divider
	var div_margin := MarginContainer.new()
	div_margin.add_theme_constant_override("margin_top", 8)
	div_margin.add_theme_constant_override("margin_bottom", 6)
	var line := ColorRect.new()
	line.color = Color(0.28, 0.26, 0.46, 0.40)
	line.custom_minimum_size = Vector2(0, 1)
	div_margin.add_child(line)
	vbox.add_child(div_margin)

	# Item list
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_item_list = VBoxContainer.new()
	_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_item_list)
	vbox.add_child(scroll)

	# Footer
	var foot_margin := MarginContainer.new()
	foot_margin.add_theme_constant_override("margin_top", 8)
	var foot := Label.new()
	foot.text = "I  ·  Esc — " + tr("inv.close")
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 12)
	foot.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.55))
	foot_margin.add_child(foot)
	vbox.add_child(foot_margin)

	_panel_root.hide()


func _populate() -> void:
	for child in _item_list.get_children():
		child.queue_free()

	var other := []
	for cur: String in ["EUR", "GBP", "TRY"]:
		if cur != GameState.currency() and GameState.cash(cur) > 0:
			other.append("%d %s" % [GameState.cash(cur), cur])
	var carried: String = ""
	if other.size() > 0:
		carried = "\nalso carried: " + ", ".join(other)
	_money_line.text = "%s %d  —  round metal discs, stamped with faces. They trade these.%s" % [
		GameState.symbol(), GameState.money, carried]

	if GameState.inventory.is_empty():
		var lbl := Label.new()
		lbl.text = tr("inv.empty")
		lbl.add_theme_font_size_override("font_size", 15)
		lbl.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.65))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_item_list.add_child(lbl)
		return

	for item: String in GameState.inventory:
		_item_list.add_child(_item_row(item, int(GameState.inventory[item])))


func _item_row(item: String, count: int) -> Control:
	var def: Dictionary = _def(item)
	var ic: Color  = def.get("color", Color(0.5, 0.5, 0.6))
	var iname: String = def.get("name", item.capitalize())

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(ic.r * 0.13, ic.g * 0.13, ic.b * 0.13, 0.82)
	sb.border_color = Color(ic.r, ic.g, ic.b, 0.22)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", sb)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	var icon := Control.new()
	icon.name = "ItemIcon"
	icon.custom_minimum_size = Vector2(54, 54)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func(): Items.draw_item(icon, Vector2(27,27), 2.25, item))
	hbox.add_child(icon)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 2)
	hbox.add_child(col)

	var nlbl := Label.new()
	nlbl.text = "%s  ×%d" % [iname, count]
	nlbl.add_theme_font_size_override("font_size", 18)
	nlbl.add_theme_color_override("font_color", Color(0.94, 0.92, 1.00))
	col.add_child(nlbl)

	var dlbl := Label.new()
	dlbl.text = def.get("desc", "")
	dlbl.add_theme_font_size_override("font_size", 12)
	var dc: Color = ic
	dc.a = 0.60
	dlbl.add_theme_color_override("font_color", dc)
	col.add_child(dlbl)

	if bool(def.get("eatable", false)):
		var eat := Button.new()
		eat.text = tr("inv.eat")
		eat.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		UIStyles.style_menu_btn(eat)
		eat.pressed.connect(_eat_item.bind(item))
		hbox.add_child(eat)

	return panel


func _eat_item(item: String) -> void:
	if not GameState.remove_item(item):
		return
	_close()
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		# What it was, not what the loaf was. Every food in the game shared
		# one line written for bread, so an apple in Berlin tasted "dense,
		# chewy and warm" and so did a shave ice in Honolulu.
		tb.show_thought(Items.eat_line(item))


# ── Pickup toasts (top-left) ──────────────────────────────────────────────────

func _on_money_changed(amount: int) -> void:
	var delta := amount - _known_money
	_known_money = amount
	if delta != 0:
		_notify("%s %+d" % [GameState.symbol(), delta])


func _on_item_changed(item: String, count: int) -> void:
	var prev: int = int(_known_counts.get(item, 0))
	_known_counts[item] = count
	var delta := count - prev
	if delta == 0:
		return
	# A pickup card is already on screen saying what this is, at size, with the
	# word. A toast in the corner saying "+1" over the top of it is noise.
	var pk := get_tree().get_first_node_in_group("pickup")
	if pk != null and bool(pk.get("showing")):
		return
	var def: Dictionary = _def(item)
	var iname: String = def.get("name", item.capitalize())
	_notify("%+d  %s" % [delta, iname])


func _notify(text: String) -> void:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.055, 0.048, 0.120, 0.94)
	sb.border_color = Color(0.62, 0.52, 0.24, 0.55)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", sb)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left",   12)
	margin.add_theme_constant_override("margin_right",  12)
	margin.add_theme_constant_override("margin_top",     6)
	margin.add_theme_constant_override("margin_bottom",  6)
	panel.add_child(margin)

	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.92, 0.84, 0.58))
	margin.add_child(lbl)

	panel.modulate.a = 0.0
	_ui_root.add_child(panel)
	_toasts.append({"p": panel, "age": 0.0})

	while _toasts.size() > 3:
		var old: Dictionary = _toasts.pop_front()
		(old["p"] as PanelContainer).queue_free()


func _update_toasts(delta: float) -> void:
	for i in range(_toasts.size() - 1, -1, -1):
		_toasts[i]["age"] = float(_toasts[i]["age"]) + delta
		if float(_toasts[i]["age"]) >= TOAST_LIFE:
			(_toasts[i]["p"] as PanelContainer).queue_free()
			_toasts.remove_at(i)

	# Stack below the quest tracker when it's showing
	var y := 14.0
	var tracker := get_tree().get_first_node_in_group("quest_tracker")
	if tracker is Control and (tracker as Control).visible:
		y = (tracker as Control).size.y + 26.0
	for t in _toasts:
		var p: PanelContainer = t["p"]
		var age: float = t["age"]
		var slide := minf(1.0, age / 0.22)
		slide = 1.0 - pow(1.0 - slide, 3.0)
		var fade_out := clampf((TOAST_LIFE - age) / TOAST_FADE, 0.0, 1.0)
		p.modulate.a = minf(slide, fade_out)
		p.position = Vector2(14.0 - (1.0 - slide) * 30.0, y)
		y += p.size.y + 8.0
