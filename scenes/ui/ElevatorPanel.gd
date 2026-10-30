extends CanvasLayer

# Floor picker for the hotel elevator, styled like the rest of the UI.
# The alien reads the digits fine — it's everything else that's a mystery.

const LOBBY_SCENE := "res://scenes/world/HotelLobby.tscn"
const FLOOR_SCENE := "res://scenes/world/HotelFloor.tscn"

var _ui_root:    Control
var _panel_root: Control
var _btn_box:    VBoxContainer
var _current:    int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("elevator_panel")
	_ui_root = $UIRoot
	_build_ui()


func open_for(current_floor: int) -> void:
	if _panel_root.visible or get_tree().paused:
		return
	_current = current_floor
	_populate()
	_panel_root.show()
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if _panel_root.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	_panel_root.hide()
	get_tree().paused = false


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
	panel.anchor_left = 0.36; panel.anchor_right  = 0.64
	panel.anchor_top  = 0.16; panel.anchor_bottom = 0.84
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.055, 0.048, 0.118, 0.98)
	sb.border_color = Color(0.30, 0.28, 0.50, 0.55)
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
		outer.add_theme_constant_override("margin_" + k, 34)
	outer.add_theme_constant_override("margin_top", 26)
	outer.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	outer.add_child(vbox)

	var title := Label.new()
	title.text = "The moving room"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "buttons with numbers — which row of doors?"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.78))
	vbox.add_child(sub)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	_btn_box = VBoxContainer.new()
	_btn_box.add_theme_constant_override("separation", 8)
	_btn_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_btn_box)

	var foot := Label.new()
	foot.text = "Esc — step back out"
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 12)
	foot.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.55))
	vbox.add_child(foot)

	_panel_root.hide()


func _populate() -> void:
	for child in _btn_box.get_children():
		_btn_box.remove_child(child)
		child.queue_free()

	# Top floor first, lobby last — like a real panel
	for f in [4, 3, 2, 1, 0]:
		var btn := Button.new()
		var label := "0  —  the big room below" if f == 0 else "%d" % f
		if f == _current:
			label += "      · you are here"
		btn.text = label
		UIStyles.style_menu_btn(btn)
		btn.custom_minimum_size = Vector2(0, 46)
		if f == _current:
			btn.disabled = true
			btn.modulate.a = 0.55
		else:
			btn.pressed.connect(_go_to_floor.bind(f))
		_btn_box.add_child(btn)


func _go_to_floor(f: int) -> void:
	GameState.hotel_floor = f
	GameState.spawn_tag = "from_elevator"
	_close()
	TransitionManager.go(LOBBY_SCENE if f == 0 else FLOOR_SCENE)
