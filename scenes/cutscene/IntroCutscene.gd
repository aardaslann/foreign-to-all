extends Control

const STAGE := preload("res://scenes/cutscene/IntroStage.gd")
const SOUND := preload("res://audio/intro/arrival.wav")
const DURATION := 28.0
const DESTINATION := "res://scenes/world/Kiez.tscn"
const FRAME := Vector2(1152, 648)

var _time := 0.0
var _done := false
var _paused := false
var _frame: Control
var _stage: Node2D
var _audio: AudioStreamPlayer
var _pause_button: Button
var _skip_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backing := ColorRect.new()
	backing.color = Color8(5, 9, 12)
	backing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backing)
	_frame = Control.new()
	_frame.size = FRAME
	_frame.clip_contents = true
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_stage = STAGE.new()
	_stage.reduced_motion = SaveManager.motion() < 0.5
	_frame.add_child(_stage)
	_pause_button = _button("Pause", Vector2(918, 597), _toggle_pause)
	_skip_button = _button("Skip", Vector2(1026, 597), _go_to_game)
	_pause_button.tooltip_text = "Pause opening"
	_skip_button.tooltip_text = "Skip opening"
	_pause_button.focus_neighbor_right = _pause_button.get_path_to(_skip_button)
	_skip_button.focus_neighbor_left = _skip_button.get_path_to(_pause_button)
	_audio = AudioStreamPlayer.new()
	_audio.stream = SOUND
	_audio.bus = "SFX"
	add_child(_audio)
	AudioManager.stop_music()
	AudioManager.set_ambience("none")
	_audio.play()
	resized.connect(_fit)
	_fit()
	_present()


func _button(caption: String, at: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = at
	button.size = Vector2(96, 36)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color8(206, 218, 216))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.025, 0.04, 0.05, 0.76)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.10, 0.18, 0.19, 0.95)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color8(168, 216, 204)
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(callback)
	_frame.add_child(button)
	return button


func _fit() -> void:
	if _frame == null:
		return
	var factor := minf(size.x / FRAME.x, size.y / FRAME.y)
	_frame.scale = Vector2.ONE * factor
	_frame.position = (size - FRAME * factor) * 0.5


func _process(delta: float) -> void:
	if _done or _paused:
		return
	_time += delta
	_present()
	if _time >= DURATION:
		_go_to_game()


func _present() -> void:
	_stage.elapsed = _time
	_stage.queue_redraw()
	var ready_for_input: bool = _time >= 0.75
	_pause_button.visible = ready_for_input
	_skip_button.visible = ready_for_input


func _toggle_pause() -> void:
	if _done or _time < 0.75:
		return
	_paused = not _paused
	_audio.stream_paused = _paused
	_pause_button.text = "Resume" if _paused else "Pause"
	_pause_button.tooltip_text = "Resume opening" if _paused else "Pause opening"


func _unhandled_input(event: InputEvent) -> void:
	if _done or _time < 0.75 or event.is_echo():
		return
	if (event is InputEventKey and event.pressed and event.physical_keycode == KEY_P) \
			or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START):
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("back") or event.is_action_pressed("ui_accept") \
			or event.is_action_pressed("interact"):
		_go_to_game()
		get_viewport().set_input_as_handled()


func _go_to_game() -> void:
	if _done or _time < 0.75:
		return
	_done = true
	_pause_button.disabled = true
	_skip_button.disabled = true
	_audio.stream_paused = false
	var fade := create_tween()
	fade.tween_property(_audio, "volume_db", -60.0, 0.28)
	TransitionManager.go(DESTINATION)
