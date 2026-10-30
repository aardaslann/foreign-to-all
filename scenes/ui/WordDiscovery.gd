extends CanvasLayer

signal finished

const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")
const CHARACTER := preload("res://scenes/npc/CharacterArt.gd")
var _open := false
var _revealed := false
var _was_paused := false
var _previous_focus: Control
var _words: Array = []
var _root: Control
var _panel: PanelContainer
var _title: Label
var _context: Label
var _question: Label
var _guess: LineEdit
var _meaning: Label
var _comparison: Label
var _primary: Button
var _skip: Button
var _voice: Button
var _scroll: ScrollContainer
var _age := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 28
	add_to_group("word_discovery")
	_build()
	_root.hide()

func _process(delta: float) -> void:
	if _open: _age += delta

func _label(parent: Node, size: int, color: Color) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", UIStyles.reading_font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size.y = 48
	UIStyles.style_menu_btn(button)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.055, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(shade)
	_panel = PanelContainer.new()
	_panel.anchor_left = 0.24
	_panel.anchor_right = 0.76
	_panel.anchor_top = 0.21
	_panel.anchor_bottom = 0.79
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17282c")
	style.border_color = Color("d7b46e")
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	style.content_margin_left = 28
	style.content_margin_right = 28
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	_panel.add_theme_stylebox_override("panel", style)
	_root.add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_panel.add_child(column)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	column.add_child(header)
	var portrait := Control.new()
	portrait.custom_minimum_size = Vector2(54, 60)
	portrait.draw.connect(func(): CHARACTER.draw_figure(portrait, Vector2(27, 57), 2.4, CHARACTER.alien_look(), "look", 0.0, 0))
	header.add_child(portrait)
	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	_label(title_box, 14, Color("8ec9bb")).text = "A WORD TO KEEP"
	_title = _label(title_box, 32, Color("f1d18d"))
	_voice = _button(header, "\u25b6", _pronounce)
	_voice.custom_minimum_size = Vector2(52, 48)
	_voice.tooltip_text = "Hear the word"
	column.add_child(HSeparator.new())
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.follow_focus = true
	column.add_child(_scroll)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 16)
	_scroll.add_child(body)
	_context = _label(body, 22, Color("dce4df"))
	_question = _label(body, 20, Color("f1d18d"))
	_question.text = "What might it mean here?"
	_guess = LineEdit.new()
	_guess.placeholder_text = "My guess..."
	_guess.max_length = 80
	_guess.custom_minimum_size.y = 50
	_guess.add_theme_font_override("font", UIStyles.reading_font)
	_guess.add_theme_font_size_override("font_size", 22)
	_guess.text_submitted.connect(func(_text: String): reveal())
	body.add_child(_guess)
	_comparison = _label(body, 19, Color("8ec9bb"))
	_meaning = _label(body, 24, Color("f1d18d"))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	column.add_child(actions)
	_skip = _button(actions, "Show the meaning", reveal)
	_skip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_primary = _button(actions, "Keep my guess", _advance)
	_primary.size_flags_horizontal = Control.SIZE_EXPAND_FILL

# The tools that run whole stories headlessly retain their fast path. Tests of
# this UI use open_words directly, so its real waiting behavior is exercised.
func present(words: Array, context: String, speaker: String = "") -> void:
	if DisplayServer.get_name() == "headless" and not has_meta("interactive_test"): return
	open_words(words, context, speaker)
	if _open: await finished

func open_words(words: Array, context: String, speaker: String = "") -> void:
	if _open or words.is_empty(): return
	_words = words.duplicate(true)
	_was_paused = get_tree().paused
	_previous_focus = get_viewport().gui_get_focus_owner()
	_open = true
	_revealed = false
	_age = 0.0
	_title.text = String(_words[0].word)
	var prefix := speaker + "\n" if not speaker.is_empty() else ""
	_context.text = prefix + context
	_guess.text = ""
	_guess.show()
	_question.show()
	_comparison.hide()
	_meaning.hide()
	_skip.show()
	_primary.text = "Keep my guess"
	_primary.disabled = false
	_voice.visible = AudioManager.has_word(String(_words[0].language), String(_words[0].word))
	var size_index := clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)
	_context.add_theme_font_size_override("font_size", [19, 22, 26][size_index])
	_meaning.add_theme_font_size_override("font_size", [21, 24, 28][size_index])
	for button: Button in [_primary, _skip]:
		button.add_theme_font_size_override("font_size", [18, 20, 23][size_index])
	_scroll.scroll_vertical = 0
	_root.show()
	get_tree().paused = true
	# Controller players need no keyboard and are never required to type.
	_skip.grab_focus()

func reveal() -> void:
	if not _open or _revealed: return
	_revealed = true
	var guess := _guess.text.strip_edges()
	var descriptions := PackedStringArray()
	for word: Dictionary in _words:
		descriptions.append("%s\n%s" % [String(word.word), String(word.meaning)])
	if not guess.is_empty():
		NOTEBOOK.keep_guess(String(_words[0].language), String(_words[0].word), guess, _context.text)
		_comparison.text = "My reading: " + guess
		_comparison.show()
	_meaning.text = "\n\n".join(descriptions)
	_meaning.show()
	_guess.hide()
	_question.hide()
	_skip.hide()
	_primary.text = "Keep the word and continue"
	_primary.grab_focus()
	_scroll.scroll_vertical = 0
	_age = 0.0

func _advance() -> void:
	if not _open: return
	if not _revealed:
		reveal()
	elif _age >= 0.15:
		close()

func _pronounce() -> void:
	if not _words.is_empty():
		AudioManager.say_word(String(_words[0].language), String(_words[0].word))

func close() -> void:
	if not _open: return
	_open = false
	_root.hide()
	get_tree().paused = _was_paused
	if is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()
	finished.emit()

func _input(event: InputEvent) -> void:
	if not _open: return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not _revealed: reveal()
		elif _age >= 0.15: close()
	elif event.is_action_pressed("hear_again") and not _guess.has_focus():
		get_viewport().set_input_as_handled()
		_pronounce()

func _exit_tree() -> void:
	if _open: get_tree().paused = _was_paused
