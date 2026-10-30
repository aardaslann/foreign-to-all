extends Control

signal closed
const FRAME := preload("res://scenes/title/MenuFrame.gd")
var _note: TextEdit
var _status: Label
var _path := ""
var _frame: Control
var _show_file: Button
var _discard: ConfirmationDialog
var _saved_note := ""


func _ready() -> void:
	_fit_viewport()
	get_viewport().size_changed.connect(_fit_viewport)
	_frame = FRAME.new()
	_frame.build(self, "A note from your journey", "Beta feedback")
	_frame.back.pressed.connect(_request_close)
	var column := FRAME.scroll_column(_frame.body, 1180)
	var location := FRAME.label(GameState.city_name() + " / " + GameState.region_name(GameState.current_region), 22, FRAME.GOLD)
	column.add_child(location)
	_note = TextEdit.new()
	_note.custom_minimum_size.y = 240
	_note.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_note.placeholder_text = "What happened? What were you expecting?"
	_note.add_theme_font_override("font", UIStyles.reading_font)
	_note.add_theme_font_size_override("font_size", 23)
	column.add_child(_note)
	var privacy: Label = FRAME.label("Saved on this computer with the build and current location. Nothing is uploaded.", 18, FRAME.MUTED)
	privacy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(privacy)
	var timing := CheckBox.new()
	timing.text = "Include optional local playtime notes"
	timing.add_theme_font_size_override("font_size", 20)
	timing.button_pressed = bool(SaveManager.settings.get("beta_session_notes", false))
	timing.toggled.connect(func(on: bool):
		SaveManager.settings["beta_session_notes"] = on
		if not SaveManager.save_settings(): _status.text = SaveManager.last_error)
	column.add_child(timing)
	_status = FRAME.label("", 19, FRAME.GOLD)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	column.add_child(buttons)
	var save := FRAME.button("Save feedback")
	save.pressed.connect(_save)
	buttons.add_child(save)
	_show_file = FRAME.button("Show saved file")
	_show_file.disabled = true
	_show_file.pressed.connect(func():
		if OS.shell_show_in_file_manager(_path) != OK: _status.text = "Saved file: " + _path)
	buttons.add_child(_show_file)
	_discard = ConfirmationDialog.new()
	_discard.title = "Leave this note?"
	_discard.dialog_text = "Your unsaved changes will be discarded."
	_discard.ok_button_text = "Discard changes"
	_discard.cancel_button_text = "Keep writing"
	_discard.confirmed.connect(func(): closed.emit())
	_discard.canceled.connect(func(): _note.grab_focus())
	add_child(_discard)
	_note.grab_focus.call_deferred()


func _fit_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size


func _save() -> void:
	if _note.text.strip_edges().is_empty():
		_status.text = "Add a short note before saving."
		return
	_path = BetaSession.export_report(_note.text)
	_show_file.disabled = _path.is_empty()
	if _path.is_empty():
		_status.text = "Could not save. Your note is still here; check disk space and folder permissions."
	else:
		_saved_note = _note.text
		_status.text = "Saved. Share this file with the person who supplied your beta."


func _request_close() -> void:
	if not _note.text.strip_edges().is_empty() and _note.text != _saved_note:
		_discard.popup_centered(Vector2i(500, 170))
		_discard.get_cancel_button().grab_focus()
	else:
		closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _discard.visible:
		get_viewport().set_input_as_handled()
		_request_close()
