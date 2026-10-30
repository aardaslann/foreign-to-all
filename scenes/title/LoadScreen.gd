extends Control

signal back_requested
const FRAME := preload("res://scenes/title/MenuFrame.gd")
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
var _slots_container: VBoxContainer
var _status: Label
var _confirm: ConfirmationDialog
var _delete_slot := -2
var _frame: Control


func _ready() -> void:
	_frame = FRAME.new()
	_frame.build(self, "Continue a journey", "Journeys")
	_frame.back.pressed.connect(func(): back_requested.emit())
	_slots_container = FRAME.scroll_column(_frame.body, 1320)
	_status = FRAME.label("", 18, FRAME.GOLD)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_frame.body.add_child(_status)
	_confirm = ConfirmationDialog.new()
	_confirm.title = "Delete this journey?"
	_confirm.dialog_text = "This permanently removes this save. Other slots are kept."
	_confirm.ok_button_text = "Delete save"
	_confirm.cancel_button_text = "Keep save"
	_confirm.confirmed.connect(_confirm_delete)
	_confirm.canceled.connect(_restore_focus)
	add_child(_confirm)
	_populate_slots()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _confirm.visible:
		get_viewport().set_input_as_handled()
		back_requested.emit()


func _populate_slots() -> void:
	for child in _slots_container.get_children():
		_slots_container.remove_child(child)
		child.queue_free()
	for slot: Dictionary in SaveManager.get_save_slots(true):
		_slots_container.add_child(_make_row(slot))


func _make_row(slot: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 98
	row.add_theme_constant_override("separation", 22)
	var number := FRAME.label("AUTO" if slot.slot == -1 else "%02d" % (slot.slot + 1), 20, FRAME.GOLD)
	number.custom_minimum_size.x = 70
	row.add_child(number)
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(72, 72)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var texture := AtlasTexture.new()
	texture.atlas = APPEARANCE.strip("idle_down", APPEARANCE.sanitize(slot.data.get("alien_appearance", {}) if slot.valid else {}))
	texture.region = Rect2(0, 0, 32, 32)
	portrait.texture = texture
	portrait.modulate.a = 0.25 if slot.empty or not slot.valid else 1.0
	row.add_child(portrait)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(info)
	var title := "An unwritten journey"
	var detail := "Empty slot"
	if not slot.empty:
		if slot.valid:
			var data: Dictionary = slot.data
			title = GameState.CITIES.get(data.get("city", "berlin"), {}).get("name", "Berlin") + " / " + GameState.region_name(data.get("region", "kiez"))
			var seconds := int(data.get("play_time", 0))
			detail = "%dh %02dm   |   %s" % [seconds / 3600, (seconds / 60) % 60, String(data.get("timestamp", "")).replace("T", "  ")]
		else:
			title = "Save unavailable"
			detail = slot.issue
	var title_label := FRAME.label(title, 23)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(title_label)
	var detail_label := FRAME.label(detail, 17, FRAME.MUTED)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(detail_label)
	if not slot.empty:
		var resume := FRAME.button("Continue")
		resume.disabled = not slot.valid
		resume.size_flags_vertical = SIZE_SHRINK_CENTER
		resume.pressed.connect(_on_load.bind(slot.slot))
		row.add_child(resume)
		var remove := FRAME.button("Delete", true)
		remove.size_flags_vertical = SIZE_SHRINK_CENTER
		remove.pressed.connect(_on_delete.bind(slot.slot))
		row.add_child(remove)
	return row


func _on_load(slot: int) -> void:
	if SaveManager.load_game(slot):
		TransitionManager.go(SaveManager.pending_scene)
	else:
		_status.text = SaveManager.last_error


func _on_delete(slot: int) -> void:
	_delete_slot = slot
	_confirm.popup_centered(Vector2i(510, 170))
	_confirm.get_cancel_button().grab_focus()


func _confirm_delete() -> void:
	if SaveManager.delete_save(_delete_slot):
		_status.text = "Save deleted. Your other journeys have been kept."
		_populate_slots()
	else:
		_status.text = SaveManager.last_error
	_restore_focus()


func _restore_focus() -> void:
	_frame.back.grab_focus()
