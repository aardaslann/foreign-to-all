extends CanvasLayer

signal finished

const STAGE := preload("res://scenes/cutscene/FlightStage.gd")
const MENU := preload("res://scenes/title/MenuFrame.gd")
const DURATION := 7.6
const INPUT_DELAY := 0.6
const FRAME := Vector2(1152, 648)

var origin := "berlin"
var destination := "istanbul"
var elapsed := 0.0
var _done := false
var _paused := false
var _owns_pause := false
var _was_paused := false
var _root: Control
var _frame: Control
var _stage: Node2D
var _pause: Button
var _skip: Button
var _route: Label
var _destination: Label
var _caption: Label
var _black: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	add_to_group("flight_cutscene")
	_was_paused = get_tree().paused
	_owns_pause = true
	get_tree().paused = true
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var backing := ColorRect.new()
	backing.color = Color("0b1820")
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(backing)
	_frame = Control.new()
	_frame.size = FRAME
	_frame.clip_contents = true
	_root.add_child(_frame)
	_stage = STAGE.new()
	_stage.reduced_motion = SaveManager.motion() < 0.5
	_stage.departure_tint = GameState.CLOCK.tint(GameState.clock_minutes, origin)
	var arrival := GameState.clock_minutes + GameState.CLOCK.flight_minutes(origin, destination)
	_stage.arrival_tint = GameState.CLOCK.tint(arrival, destination)
	_frame.add_child(_stage)
	_route = _label(_city_name(origin).to_upper() + "   /   " + _city_name(destination).to_upper(), 18, Vector2(44, 60), Vector2(1064, 30))
	var arrival_label := _label("ARRIVAL  " + GameState.CLOCK.text_at(arrival, destination) + " LOCAL", 14, Vector2(44, 95), Vector2(670, 24))
	arrival_label.modulate = Color("c5d2c9")
	_caption = _label("NEXT STOP", 14, Vector2(44, 563), Vector2(670, 22))
	_caption.modulate = Color("afc8c6")
	_destination = _label(_city_name(destination), 34, Vector2(42, 584), Vector2(670, 45))
	_pause = _button("II", Vector2(900, 582), Vector2(52, 44), _toggle_pause)
	_pause.tooltip_text = "Pause flight"
	_skip = _button("Skip", Vector2(968, 582), Vector2(140, 44), _request_finish)
	_skip.tooltip_text = "Continue to " + _city_name(destination)
	_pause.focus_neighbor_right = _pause.get_path_to(_skip)
	_skip.focus_neighbor_left = _skip.get_path_to(_pause)
	_black = ColorRect.new()
	_black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_black.color = Color("0b1820")
	_black.modulate.a = 0
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_black)
	_root.resized.connect(_fit)
	_fit()
	_present()
	# Keep the existing airport score; no new hiss or interruption of the music.
	AudioManager.stop_voice()


func _city_name(city: String) -> String:
	return String(GameState.CITIES.get(city, {}).get("name", city.capitalize()))


func _label(text: String, font_size: int, at: Vector2, dimensions: Vector2) -> Label:
	var label := MENU.label(text, font_size, Color("f2ead8"))
	label.position = at
	label.size = dimensions
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(label)
	return label


func _button(text: String, at: Vector2, dimensions: Vector2, callback: Callable) -> Button:
	var button := MENU.button(text)
	button.custom_minimum_size = dimensions
	button.position = at
	button.size = dimensions
	button.pressed.connect(callback)
	_frame.add_child(button)
	return button


func _fit() -> void:
	var factor := minf(_root.size.x / FRAME.x, _root.size.y / FRAME.y)
	_frame.scale = Vector2.ONE * factor
	_frame.position = ((_root.size - FRAME * factor) * 0.5).round()


func _process(delta: float) -> void:
	if _done or _paused: return
	elapsed += delta
	_present()
	if elapsed >= (3.0 if _stage.reduced_motion else DURATION): _request_finish()


func _present() -> void:
	_stage.elapsed = elapsed
	_stage.queue_redraw()
	var can_skip: bool = elapsed >= INPUT_DELAY and not _done
	var newly_enabled: bool = _skip.disabled and can_skip
	_pause.disabled = not can_skip
	_skip.disabled = not can_skip
	if newly_enabled: _skip.grab_focus()
	_route.modulate.a = smoothstep(0.6, 1.5, elapsed)
	_caption.text = "ARRIVING" if elapsed > 5.4 or _stage.reduced_motion else "NEXT STOP"
	if _paused: _caption.text = "PAUSED"


func _toggle_pause() -> void:
	if _done or elapsed < INPUT_DELAY: return
	_paused = not _paused
	_pause.text = ">" if _paused else "II"
	_pause.tooltip_text = "Resume flight" if _paused else "Pause flight"
	_present()


func _input(event: InputEvent) -> void:
	# The film remains above the world through the arrival fade. A menu opened
	# in that brief handoff would pause the shared scene-transition tween.
	for action: String in ["journal", "inventory", "quest_log", "district_map", "hear_again"]:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			return
	if _done and (event.is_action_pressed("interact") or event.is_action_pressed("back") \
			or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	if (event is InputEventKey and event.pressed and event.physical_keycode == KEY_P) \
			or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START):
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.is_action_pressed("interact"):
		# Controls maps controller A to interact; it need not also be ui_accept.
		if _pause.has_focus(): _toggle_pause()
		else: _request_finish()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("back") or event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		_request_finish()
		get_viewport().set_input_as_handled()


func _request_finish() -> void:
	if _done or elapsed < INPUT_DELAY: return
	_done = true
	_pause.disabled = true
	_skip.disabled = true
	var fade := create_tween()
	fade.tween_property(_black, "modulate:a", 1.0, 0.22)
	await fade.finished
	_release_pause()
	finished.emit()


func _release_pause() -> void:
	if _owns_pause:
		_owns_pause = false
		get_tree().paused = _was_paused


func _exit_tree() -> void:
	_release_pause()
