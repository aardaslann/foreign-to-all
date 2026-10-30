extends CanvasLayer

signal finished

const STAGE := preload("res://scenes/ui/NamingStage.gd")
const FRAME := preload("res://scenes/title/MenuFrame.gd")
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const VOICES := {"berlin":"kerstin", "istanbul":"arda", "london":"nadia", "paris":"odile",
	"moscow":"viktor", "mumbai":"omkar", "tokyo":"setsuko", "mexico":"rocio"}
const GOLD := Color("e7c580")
const PAPER := Color("f1eedc")
const T_SAY := 0.8
const T_OUT := 2.6

# These are the chosen person's use of the word, not a national definition.
const TEMPERATURE := {
	"berlin": "Kerstin chooses Fremd: unfamiliar, from elsewhere. Not a word from a form. She says it plainly, without pretending you have stopped being different.",
	"london": "Foreign. Nadia does not translate it. The word on the page was readable before you knew her; now it sounds like the person who drew a place for you.",
	"paris": "Étranger can mean stranger or foreigner. Odile pauses over that overlap. Coming from elsewhere and being unknown are no longer the same thing between you.",
	"moscow": "Chuzhoy: not one's own, a stranger. Viktor sets it beside svoy, one's own. He gives you a word with distance in it, but his hand stays open.",
	"istanbul": "Yabancı: a stranger, someone from elsewhere. Arda uses an everyday word. The unusual part, to him, is that you asked him to make it yours.",
	"mumbai": "Pardesi: someone from another land. Omkar repeats it with a little rise in his voice. A word about being far from home becomes something you can answer to here.",
	"tokyo": "Gaijin: outside person. It can keep a distance between people. Setsuko gives it here because you asked, beside the wish you were allowed to leave unwritten. The word does not settle where you belong.",
	"mexico": "Extranjero: a foreigner. Rocío says it carefully, as if placing something in your hands. She has already made room for the person who will carry it."
}

var _open := false
var _t := 0.0
var _city := ""
var _phase := 0
var _spoken := false
var _root: Control
var _stage: Control
var _who: Label
var _name: Label
var _line: Label
var _hint: Label
var _actions: HBoxContainer
var _continue: Button
var _credits: Button
var _feedback: Button
var _replay: Button
var _scroll: ScrollContainer
var _overlay: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 15
	add_to_group("naming")
	_build()
	_root.hide()


func play(city: String) -> void:
	if _open or not TEMPERATURE.has(city): return
	_city = city
	_open = true
	_t = 0.0
	_phase = 0
	_spoken = false
	var p: Dictionary = Story.person(city)
	_stage.friend = Story.look_for(city)
	_stage.alien = CHAR.alien_look()
	_stage.elapsed = 0.0
	Story.set_namer(city)
	GameState.world_flags["ending_chosen"] = true
	_who.text = "%s  /  %s" % [p.name, GameState.CITIES[city].name]
	_name.text = p.gives
	var memory: String = Journey.ledger().memories.get(city, "")
	_line.text = TEMPERATURE[city]
	if not memory.is_empty(): _line.text += "\n\n" + memory
	_line.add_theme_font_size_override("font_size", [18,22,26][clampi(int(SaveManager.settings.get("text_size",1)),0,2)])
	_continue.text = "Stay a moment"
	_continue.disabled = true
	_credits.hide()
	_feedback.hide()
	_hint.text = "[%s]  Continue" % Controls.label_for("interact")
	_scroll.scroll_vertical = 0
	Story.guide()
	SaveManager.checkpoint()
	_root.show()
	get_tree().paused = true
	_stage.queue_redraw()


func _process(delta: float) -> void:
	if not _open or is_instance_valid(_overlay): return
	_t += delta
	_stage.elapsed = _t
	_stage.queue_redraw()
	_who.modulate.a = clampf((_t - 0.25) / 0.45, 0, 1)
	_name.modulate.a = clampf((_t - T_SAY) / 0.7, 0, 1)
	_line.modulate.a = clampf((_t - 1.5) / 0.65, 0, 1)
	_actions.modulate.a = clampf((_t - T_OUT) / 0.4, 0, 1)
	if _t >= T_SAY and not _spoken:
		_spoken = true
		AudioManager.say(VOICES[_city], Story.person(_city).gives)
	if _t >= T_OUT and _continue.disabled:
		_continue.disabled = false
		_continue.grab_focus()


func _advance() -> void:
	if not _open or _t < T_OUT or is_instance_valid(_overlay): return
	if _phase == 1:
		_close()
		return
	_phase = 1
	GameState.world_flags["ending_seen"] = true
	SaveManager.checkpoint()
	_who.text = "EIGHT CITIES  /  A NAME OF YOUR OWN"
	_line.text = "Somebody said it to me on purpose. That is the difference.\n\nThe journey is complete. The people and places are still here."
	var count := 0
	var memories: Dictionary = Journey.ledger().memories
	for city: String in memories:
		if city == _city or not Story.MANDATORY.has(city): continue
		_line.text += "\n\n" + Story.person_name(city) + " / " + GameState.CITIES[city].name + "\n" + String(memories[city])
		count += 1
		if count == 2: break
	_scroll.scroll_vertical = 0
	_continue.text = "Continue exploring"
	_credits.show()
	_feedback.show()
	_hint.text = "Journey complete"
	_continue.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not _open or is_instance_valid(_overlay): return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()
	elif event.is_action_pressed("back") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_t = maxf(_t, T_OUT)
		_advance()


func _close() -> void:
	if not _open: return
	_open = false
	_root.hide()
	AudioManager.stop_voice()
	get_tree().paused = false
	finished.emit()


func _exit_tree() -> void:
	if _open:
		get_tree().paused = false
		AudioManager.stop_voice()


func _show_credits() -> void:
	_overlay = Control.new()
	_root.add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var frame := FRAME.new()
	frame.build(_overlay, "Foreign to All", "Credits")
	frame.back.pressed.connect(_close_overlay)
	var column := FRAME.scroll_column(frame.body)
	var text := FRAME.label(preload("res://scenes/title/ReleaseCredits.gd").TEXT, 22)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(text)
	frame.back.grab_focus()


func _show_feedback() -> void:
	_overlay = preload("res://scenes/ui/BetaFeedback.gd").new()
	_root.add_child(_overlay)
	_overlay.closed.connect(_close_overlay)


func _close_overlay() -> void:
	if is_instance_valid(_overlay): _overlay.queue_free()
	_overlay = null
	_continue.grab_focus.call_deferred()


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	_stage = STAGE.new()
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_stage)
	var mast := VBoxContainer.new()
	mast.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	mast.offset_top = 18
	mast.add_theme_constant_override("separation", 2)
	_root.add_child(mast)
	_who = FRAME.label("", 18, GOLD)
	_who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mast.add_child(_who)
	_name = FRAME.label("", 64, PAPER)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_constant_override("outline_size", 5)
	_name.add_theme_color_override("font_outline_color", Color("12171c"))
	mast.add_child(_name)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.anchor_top = 0.68
	for side: String in ["left", "right"]: margin.add_theme_constant_override("margin_" + side, 38)
	for side: String in ["top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 12)
	_root.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.follow_focus = true
	column.add_child(_scroll)
	_line = FRAME.label("", 22, PAPER)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_line)
	_actions = HBoxContainer.new()
	_actions.add_theme_constant_override("separation", 12)
	column.add_child(_actions)
	_hint = FRAME.label("", 16, Color("bcc7c7"))
	_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_actions.add_child(_hint)
	_replay = FRAME.button("▶")
	_replay.custom_minimum_size.x = 44
	_replay.tooltip_text = "Hear your name again"
	_replay.pressed.connect(func(): AudioManager.say(VOICES[_city], Story.person(_city).gives))
	_actions.add_child(_replay)
	_credits = FRAME.button("Credits")
	_credits.pressed.connect(_show_credits)
	_actions.add_child(_credits)
	_feedback = FRAME.button("Beta feedback")
	_feedback.pressed.connect(_show_feedback)
	_actions.add_child(_feedback)
	_continue = FRAME.button("Stay a moment")
	_continue.pressed.connect(_advance)
	_actions.add_child(_continue)
