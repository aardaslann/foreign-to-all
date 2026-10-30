extends Control

signal back_requested
const FRAME := preload("res://scenes/title/MenuFrame.gd")
const BUILD := preload("res://autoload/BuildInfo.gd")
var _frame: Control
var _page: VBoxContainer
var _tabs: TabBar
var _status: Label
var _binding := ""
var _bind_buttons: Dictionary = {}
var _leave_unsaved: ConfirmationDialog


func _ready() -> void:
	_frame = FRAME.new()
	_frame.build(self, tr("set.title"), "Preferences")
	_frame.back.pressed.connect(_go_back)
	_tabs = TabBar.new()
	_tabs.add_theme_font_size_override("font_size", 22)
	for state: String in ["tab_selected", "tab_unselected", "tab_hovered", "tab_focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("282035") if state == "tab_selected" else Color.TRANSPARENT
		style.border_width_bottom = 2 if state == "tab_selected" or state == "tab_focus" else 1
		style.border_color = FRAME.GOLD if state == "tab_selected" or state == "tab_focus" else Color("584966")
		style.content_margin_left = 16
		style.content_margin_right = 16
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		_tabs.add_theme_stylebox_override(state, style)
	for tab: String in ["Display", "Sound", "Comfort", "Controls", "Language", "Credits"]:
		_tabs.add_tab(tab)
	_frame.body.add_child(_tabs)
	_page = FRAME.scroll_column(_frame.body, 1080)
	_status = FRAME.label("", 18, FRAME.GOLD)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_frame.body.add_child(_status)
	_tabs.tab_changed.connect(_show_page)
	SaveManager.operation_failed.connect(_show_error)
	_leave_unsaved = ConfirmationDialog.new()
	_leave_unsaved.title = "Settings could not be saved"
	_leave_unsaved.ok_button_text = "Return without saving"
	_leave_unsaved.cancel_button_text = "Stay here"
	_leave_unsaved.confirmed.connect(func(): back_requested.emit())
	_leave_unsaved.canceled.connect(func(): _frame.back.grab_focus())
	add_child(_leave_unsaved)
	_show_page(0)


func _show_error(message: String) -> void:
	_status.text = message


func _go_back() -> void:
	if SaveManager.save_settings():
		back_requested.emit()
	else:
		_leave_unsaved.dialog_text = SaveManager.last_error + "\nThese settings can still be used for this session."
		_leave_unsaved.popup_centered(Vector2i(600, 200))
		_leave_unsaved.get_cancel_button().grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _leave_unsaved.visible: return
	if not _binding.is_empty():
		_capture_bind(event)
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _show_page(index: int) -> void:
	_binding = ""
	_bind_buttons.clear()
	for child in _page.get_children():
		_page.remove_child(child)
		child.queue_free()
	match index:
		0:
			_option("Window", "window_mode", ["Windowed", "Fullscreen", "Borderless"])
			_option("Resolution", "resolution", ["1280 x 720", "1600 x 900", "1920 x 1080", "2560 x 1440"])
			_option("Frame limit", "max_fps", ["30", "60", "120", "144", "Unlimited"])
			_toggle("V-Sync", "vsync")
		1:
			for pair: Array in [["Master", "master_volume"], ["Music", "music_volume"], ["Effects", "sfx_volume"], ["Speech", "speech_volume"]]:
				_slider(pair[0], pair[1])
		2:
			_option("Text size", "text_size", ["Small", "Medium", "Large"])
			_toggle("Reduce motion", "reduce_motion")
			_toggle("Extra context hints", "extra_context_hints")
			_toggle("Simplified glyph set", "simplified_glyph_set")
			_toggle("Underline partial words", "highlight_partial_words")
			_toggle("Timed replies", "timed_choices")
		3:
			for action: String in Controls.ORDER:
				var row := _row(Controls.NAMES[action])
				var binding := FRAME.button(Controls.label_for(action))
				binding.custom_minimum_size.x = 240
				binding.pressed.connect(_on_bind_click.bind(action))
				_bind_buttons[action] = binding
				row.add_child(binding)
			var reset := FRAME.button("Reset controls")
			reset.size_flags_horizontal = SIZE_SHRINK_BEGIN
			reset.pressed.connect(func():
				Controls.reset_binds()
				_refresh_binds())
			_page.add_child(reset)
		4:
			var notice := FRAME.label(Loc.support_notice(), 20, FRAME.GOLD)
			notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_page.add_child(notice)
			var options := OptionButton.new()
			options.custom_minimum_size.y = 48
			options.add_theme_font_override("font", UIStyles.reading_font)
			options.add_theme_font_size_override("font_size", 22)
			for language: Array in Loc.LANGS:
				options.add_item(language[1] + (" - complete" if language[0] == "en" else " - preview"))
				if language[0] == Loc.locale(): options.select(options.item_count - 1)
			options.item_selected.connect(func(i: int):
				Loc.set_language(Loc.LANGS[i][0])
				notice.text = Loc.support_notice())
			_page.add_child(options)
		5:
			var credits := RichTextLabel.new()
			credits.bbcode_enabled = false
			credits.fit_content = true
			credits.scroll_active = false
			credits.add_theme_font_override("normal_font", UIStyles.reading_font)
			credits.add_theme_font_size_override("normal_font_size", 21)
			credits.text = preload("res://scenes/title/ReleaseCredits.gd").TEXT
			_page.add_child(credits)
			var notices := FRAME.button("Third-party notices")
			notices.size_flags_horizontal = SIZE_SHRINK_BEGIN
			notices.pressed.connect(_show_licenses)
			_page.add_child(notices)


func _row(caption: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 56
	row.add_theme_constant_override("separation", 24)
	var label := FRAME.label(caption)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	_page.add_child(row)
	return row


func _option(caption: String, key: String, choices: Array) -> void:
	var row := _row(caption)
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(260, 46)
	option.add_theme_font_size_override("font_size", 21)
	for choice: String in choices: option.add_item(choice)
	option.select(clampi(int(SaveManager.settings.get(key, 0)), 0, choices.size() - 1))
	option.item_selected.connect(func(i: int):
		SaveManager.settings[key] = i
		# The legacy fullscreen flag must not override an explicit Windowed choice.
		if key == "window_mode": SaveManager.settings["fullscreen"] = i == 1
		SaveManager.apply_settings()
		SaveManager.save_settings())
	row.add_child(option)


func _toggle(caption: String, key: String) -> void:
	var row := _row(caption)
	var toggle := CheckButton.new()
	toggle.button_pressed = bool(SaveManager.settings.get(key, false))
	toggle.custom_minimum_size.x = 70
	toggle.tooltip_text = caption
	toggle.toggled.connect(func(on: bool):
		SaveManager.settings[key] = on
		SaveManager.apply_settings()
		SaveManager.save_settings())
	row.add_child(toggle)


func _slider(caption: String, key: String) -> void:
	var row := _row(caption)
	var slider := HSlider.new()
	slider.custom_minimum_size.x = 300
	slider.size_flags_vertical = SIZE_SHRINK_CENTER
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = SaveManager.settings[key]
	slider.tooltip_text = caption
	var value := FRAME.label("%d%%" % roundi(slider.value * 100), 22, FRAME.GOLD)
	value.custom_minimum_size.x = 72
	slider.value_changed.connect(func(amount: float):
		SaveManager.settings[key] = amount
		SaveManager.apply_settings()
		value.text = "%d%%" % roundi(amount * 100))
	slider.drag_ended.connect(func(_changed: bool): SaveManager.save_settings())
	row.add_child(slider)
	row.add_child(value)


func _on_bind_click(action: String) -> void:
	_binding = action
	_refresh_binds()
	_bind_buttons[action].text = "Press a key..."
	_bind_buttons[action].release_focus()


func _capture_bind(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	get_viewport().set_input_as_handled()
	var action := _binding
	_binding = ""
	if event.physical_keycode != KEY_ESCAPE:
		Controls.rebind(action, event.physical_keycode)
	_refresh_binds()
	_bind_buttons[action].grab_focus()


func _refresh_binds() -> void:
	for action: String in _bind_buttons:
		_bind_buttons[action].text = Controls.label_for(action)


func _show_licenses() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Third-party notices"
	dialog.min_size = Vector2i(760, 500)
	var text := TextEdit.new()
	text.editable = false
	text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text.text = preload("res://scenes/title/ReleaseCredits.gd").notices()
	text.custom_minimum_size = Vector2(720, 430)
	dialog.add_child(text)
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
