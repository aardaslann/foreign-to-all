extends CanvasLayer

# Unified HUD: money chip + square icon buttons for Journal (J), Inventory (I)
# and Intentions/quests (Q). Sits top-right; hides whenever the game is paused
# (dialogue, overlays, menus) so it never fights other UI for attention.

const BTN := 50.0

var _ui_root:     Control
var _bar:         HBoxContainer
var _money_label: Label
var _foreign_label: Label
var _foreign_chip: PanelContainer
var _map_btn:     Button
var _clock_chip: PanelContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_root = $UIRoot
	_build()


func _process(_delta: float) -> void:
	_ui_root.visible = not get_tree().paused
	_money_label.text = "%s %d" % [GameState.symbol(), GameState.money]
	# What is still in the other pockets. Travelling changes which one the
	# chip above is reading; it does not empty any of them, and a player
	# who has just flown needs to be able to see that.
	var held: Array = GameState.foreign_holdings()
	if held.is_empty():
		_foreign_chip.visible = false
	else:
		var bits: Array = []
		for row: Dictionary in held.slice(0, 3):
			bits.append("%s %d" % [GameState.currency_symbol(String(row["cur"])),
				int(row["amount"])])
		if held.size() > 3:
			bits.append("+%d" % (held.size() - 3))
		_foreign_label.text = "  ".join(bits)
		_foreign_chip.visible = true
	_map_btn.visible = GameState.world_flags.get("has_map", false)
	_bar.position = Vector2(_ui_root.size.x - _bar.size.x - 14.0, 14.0)


func _build() -> void:
	_clock_chip = PanelContainer.new()
	_clock_chip.name = "LocalClock"
	_clock_chip.position = Vector2(14, 14)
	var clock_style := _panel_sb(false)
	clock_style.set_corner_radius_all(4)
	_clock_chip.add_theme_stylebox_override("panel", clock_style)
	_clock_chip.add_child(preload("res://scenes/ui/ClockIndicator.gd").new())
	_ui_root.add_child(_clock_chip)
	_bar = HBoxContainer.new()
	_bar.add_theme_constant_override("separation", 8)
	_ui_root.add_child(_bar)

	# Money chip
	var chip := PanelContainer.new()
	var chip_sb := _panel_sb(false)
	chip_sb.content_margin_left  = 16.0
	chip_sb.content_margin_right = 16.0
	chip_sb.content_margin_top    = 13.0
	chip_sb.content_margin_bottom = 13.0
	chip.add_theme_stylebox_override("panel", chip_sb)
	_money_label = Label.new()
	_money_label.text = "€ 0"   # replaced every frame by _process
	_money_label.add_theme_font_size_override("font_size", 16)
	_money_label.add_theme_color_override("font_color", Color(0.90, 0.76, 0.38))
	chip.add_child(_money_label)
	_bar.add_child(chip)

	# The other pockets, in smaller cooler type so the money he can spend
	# here still reads first.
	var fchip := PanelContainer.new()
	var fsb := _panel_sb(false)
	fsb.content_margin_left = 12.0
	fsb.content_margin_right = 12.0
	fsb.content_margin_top = 13.0
	fsb.content_margin_bottom = 13.0
	fchip.add_theme_stylebox_override("panel", fsb)
	_foreign_label = Label.new()
	_foreign_label.text = ""
	_foreign_label.custom_minimum_size.x = 160
	_foreign_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_foreign_label.add_theme_font_size_override("font_size", 14)
	_foreign_label.add_theme_color_override("font_color",
		Color(0.62, 0.64, 0.74))
	fchip.add_child(_foreign_label)
	fchip.visible = false
	_bar.add_child(fchip)
	_foreign_chip = fchip

	_bar.add_child(_icon_button("J", _icon_book(),   "journal"))
	_bar.add_child(_icon_button("I", _icon_pouch(),  "inventory"))
	_bar.add_child(_icon_button("Q", _icon_scroll(), "quest_log"))
	_map_btn = _icon_button("M", _icon_map(), "map_view")
	_map_btn.visible = false
	_bar.add_child(_map_btn)


func _icon_button(key: String, icon: Control, group: String) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(BTN, BTN)
	btn.add_theme_stylebox_override("normal",  _panel_sb(false))
	btn.add_theme_stylebox_override("hover",   _panel_sb(true))
	btn.add_theme_stylebox_override("pressed", _panel_sb(false))
	btn.add_theme_stylebox_override("focus",   _panel_sb(false))

	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2(16, 13)
	btn.add_child(icon)

	var badge := Label.new()
	badge.text = key
	badge.position = Vector2(BTN - 15.0, BTN - 19.0)
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", Color(0.62, 0.58, 0.90, 0.85))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(badge)

	btn.pressed.connect(func():
		var target := get_tree().get_first_node_in_group(group)
		if target != null and target.has_method("open_from_hud"):
			target.open_from_hud()
	)
	btn.mouse_entered.connect(func(): btn.modulate = Color(1.08, 1.08, 1.12))
	btn.mouse_exited.connect(func():  btn.modulate = Color(1, 1, 1))
	return btn


func _panel_sb(hover: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.16, 0.15, 0.30, 0.92) if hover else Color(0.075, 0.066, 0.150, 0.88)
	sb.border_color = Color(0.55, 0.50, 0.85, 0.70) if hover else Color(0.30, 0.28, 0.50, 0.45)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size  = 6
	sb.shadow_offset = Vector2(0, 2)
	return sb


# ── Icons (18×24 drawn with ColorRects) ───────────────────────────────────────

func _icon_book() -> Control:
	var wrap := Control.new()
	var back := _rect(Color(0.20, 0.18, 0.38), Vector2(2, 2), Vector2(14, 18))
	var front := _rect(Color(0.34, 0.30, 0.60), Vector2(0, 0), Vector2(14, 20))
	var spine := _rect(Color(0.48, 0.44, 0.78), Vector2(0, 0), Vector2(3, 20))
	wrap.add_child(back); wrap.add_child(front); wrap.add_child(spine)
	for i in range(3):
		wrap.add_child(_rect(Color(0.64, 0.60, 0.92, 0.60),
			Vector2(5, 5.0 + float(i) * 4.5), Vector2(7, 1.4)))
	return wrap


func _icon_pouch() -> Control:
	var wrap := Control.new()
	wrap.add_child(_rect(Color(0.44, 0.32, 0.19), Vector2(2, 7), Vector2(14, 13)))
	wrap.add_child(_rect(Color(0.32, 0.22, 0.14), Vector2(6, 3), Vector2(6, 5)))
	wrap.add_child(_rect(Color(0.62, 0.50, 0.28), Vector2(4, 7), Vector2(10, 2)))
	wrap.add_child(_rect(Color(0.88, 0.74, 0.36), Vector2(7, 12), Vector2(4, 4)))
	return wrap


func _icon_scroll() -> Control:
	var wrap := Control.new()
	wrap.add_child(_rect(Color(0.36, 0.32, 0.62), Vector2(1, 2), Vector2(14, 17)))
	wrap.add_child(_rect(Color(0.22, 0.20, 0.42), Vector2(0, 0), Vector2(16, 3)))
	wrap.add_child(_rect(Color(0.22, 0.20, 0.42), Vector2(0, 18), Vector2(16, 3)))
	for i in range(3):
		wrap.add_child(_rect(Color(0.68, 0.64, 0.94, 0.65),
			Vector2(4, 6.0 + float(i) * 4.0), Vector2(8 if i < 2 else 5, 1.4)))
	return wrap


func _icon_map() -> Control:
	var wrap := Control.new()
	# Folded paper map — three panels, alternating light
	wrap.add_child(_rect(Color(0.72, 0.66, 0.50), Vector2(0, 2),  Vector2(6, 18)))
	wrap.add_child(_rect(Color(0.60, 0.54, 0.40), Vector2(6, 2),  Vector2(6, 18)))
	wrap.add_child(_rect(Color(0.72, 0.66, 0.50), Vector2(12, 2), Vector2(6, 18)))
	# Ink road line + the red "you" dot
	wrap.add_child(_rect(Color(0.25, 0.25, 0.33, 0.70), Vector2(2, 10), Vector2(14, 1.6)))
	wrap.add_child(_rect(Color(0.72, 0.20, 0.16), Vector2(8, 7), Vector2(3, 3)))
	return wrap


func _rect(col: Color, pos: Vector2, size: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = col
	r.position = pos
	r.size = size
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
