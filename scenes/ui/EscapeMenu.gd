extends CanvasLayer

const SettingsMenuScene := preload("res://scenes/title/SettingsMenu.tscn")
var _feedback: Control
var _settings: Control
var _confirm: ConfirmationDialog
var _save_slot := -2
var _notice: AcceptDialog


func _ready() -> void:
	_relabel()
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_style_panel()
	_style_buttons()
	_confirm = ConfirmationDialog.new()
	_confirm.title = "Replace this save?"
	_confirm.dialog_text = "The journey in this slot will be replaced. Other slots are kept."
	_confirm.ok_button_text = "Replace save"
	_confirm.cancel_button_text = "Keep existing save"
	_confirm.confirmed.connect(func(): _save_now(_save_slot))
	_confirm.canceled.connect(func(): $SavePanel/Margin/VBox/CancelSaveButton.grab_focus())
	add_child(_confirm)
	_notice = AcceptDialog.new()
	add_child(_notice)
	SaveManager.operation_failed.connect(_storage_error)

	$Panel/Margin/VBox/ResumeButton.pressed.connect(_on_resume)
	$Panel/Margin/VBox/SettingsButton.pressed.connect(_on_settings)
	$Panel/Margin/VBox/SaveButton.pressed.connect(_on_save)
	$Panel/Margin/VBox/MainMenuButton.pressed.connect(_on_main_menu)
	$Panel/Margin/VBox/QuitButton.pressed.connect(get_tree().quit)
	$SavePanel/Margin/VBox/CancelSaveButton.pressed.connect(_hide_save_panel)
	var feedback_button := Button.new()
	feedback_button.text = "Beta feedback"
	UIStyles.style_title_btn(feedback_button, 19)
	$Panel/Margin/VBox.add_child(feedback_button)
	$Panel/Margin/VBox.move_child(feedback_button, 5)
	feedback_button.pressed.connect(_on_feedback)


func _style_panel() -> void:
	for panel: Panel in [$Panel, $SavePanel]:
		var sb := StyleBoxFlat.new()
		sb.bg_color     = Color(0.050, 0.042, 0.112, 0.97)
		sb.border_color = Color(0.30, 0.26, 0.50, 0.55)
		sb.border_width_top    = 1; sb.border_width_bottom = 1
		sb.border_width_left   = 1; sb.border_width_right  = 1
		sb.set_corner_radius_all(4)
		sb.shadow_color  = Color(0.0, 0.0, 0.0, 0.60)
		sb.shadow_size   = 20
		sb.shadow_offset = Vector2(0, 4)
		panel.add_theme_stylebox_override("panel", sb)


func _style_buttons() -> void:
	for btn_name in ["ResumeButton", "SettingsButton", "SaveButton", "MainMenuButton", "QuitButton"]:
		UIStyles.style_title_btn($Panel/Margin/VBox.get_node(btn_name), 19)
	UIStyles.style_menu_btn($SavePanel/Margin/VBox/CancelSaveButton)


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_feedback) or is_instance_valid(_settings) or _confirm.visible or _notice.visible:
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg and dlg.visible:
		return
	if get_tree().paused and not visible:
		return
	get_viewport().set_input_as_handled()
	if visible:
		if $SavePanel.visible: _hide_save_panel()
		else: _on_resume()
	else:
		_open()


func _open() -> void:
	show()
	get_tree().paused = true
	$Panel/Margin/VBox/ResumeButton.grab_focus()


func _on_feedback() -> void:
	$Panel.hide()
	_feedback = load("res://scenes/ui/BetaFeedback.gd").new()
	add_child(_feedback)
	_feedback.closed.connect(func():
		_feedback.queue_free()
		$Panel.show()
		$Panel/Margin/VBox/ResumeButton.grab_focus())


func _on_resume() -> void:
	_hide_save_panel()
	hide()
	get_tree().paused = false


func _on_settings() -> void:
	if is_instance_valid(_settings): return
	$Panel.hide()
	_settings = SettingsMenuScene.instantiate()
	_settings.back_requested.connect(func():
		_settings.queue_free()
		_settings = null
		$Panel.show()
		_relabel()
		$Panel/Margin/VBox/SettingsButton.grab_focus())
	add_child(_settings)
	_settings._frame.back.grab_focus()


func _on_save() -> void:
	_show_save_panel()


func _on_main_menu() -> void:
	get_tree().paused = false
	TransitionManager.go("res://scenes/title/TitleScreen.tscn")


func _show_save_panel() -> void:
	$Panel.hide()
	var container := $SavePanel/Margin/VBox/SlotsContainer
	for child in container.get_children():
		child.queue_free()
	for slot_data in SaveManager.get_save_slots():
		var btn := Button.new()
		if slot_data.empty:
			btn.text = "Slot %d  —  Empty" % (slot_data.slot + 1)
		elif not slot_data.valid:
			btn.text = "Slot %d - Unavailable save" % (slot_data.slot + 1)
		else:
			var d: Dictionary = slot_data.data
			btn.text = "Slot %d  —  %s  (%s)" % [
				slot_data.slot + 1,
				GameState.region_name(String(d.get("region", ""))),
				d.get("timestamp", "?")
			]
		UIStyles.style_menu_btn(btn)
		btn.pressed.connect(_on_save_to_slot.bind(slot_data.slot))
		container.add_child(btn)
	$SavePanel.show()
	$SavePanel/Margin/VBox/CancelSaveButton.grab_focus()


func _hide_save_panel() -> void:
	$SavePanel.hide()
	$Panel.show()
	$Panel/Margin/VBox/SaveButton.grab_focus()


func _on_save_to_slot(slot: int) -> void:
	_save_slot = slot
	if not SaveManager.get_save_slots()[slot].empty:
		_confirm.popup_centered(Vector2i(520, 170))
		_confirm.get_cancel_button().grab_focus()
	else:
		_save_now(slot)


func _save_now(slot: int) -> void:
	if SaveManager.save_game(slot):
		_hide_save_panel()
		_notice.title = "Journey saved"
		_notice.dialog_text = "Your journey is saved in slot %d." % (slot + 1)
		_notice.popup_centered()


func _storage_error(message: String) -> void:
	if is_instance_valid(_settings): return
	_notice.title = "Could not save"
	_notice.dialog_text = message
	_notice.popup_centered(Vector2i(580, 180))


# In whatever language was chosen. The labels are in the .tscn, so they are
# replaced here rather than being literal English in the scene file.
func _relabel() -> void:
	var labels := {
		"ResumeButton": "menu.resume", "SettingsButton": "menu.settings",
		"SaveButton": "menu.save", "MainMenuButton": "menu.main",
		"QuitButton": "menu.quit", "CancelSaveButton": "menu.back",
	}
	for n: String in labels.keys():
		var b := find_child(n, true, false)
		if b != null and "text" in b:
			b.set("text", tr(String(labels[n])))
	var p := find_child("PausedLabel", true, false)
	if p != null and "text" in p:
		p.set("text", tr("menu.paused"))
