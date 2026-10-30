extends CanvasLayer

const SPEECH := preload("res://scenes/dialogue/Speech.gd")
const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")

# ── Making a word stick ──────────────────────────────────────────────────────
#
# Three moments, all on the line itself rather than in a notification:
#   the word being worked out is spelled out in amber while he decides - a
#     guess about a shape cannot be remembered, a guess about a word can
#   when his reading is borne out, it turns gold with its meaning beside it
#   a word he has found is gold whenever it is said again, and saying so once
const FOUND_CLR := "#f3d58a"
const TARGET_CLR := "#f0c77a"
const WORD_BG := "#514677"
var _fresh_discoveries: Array = []
var _targets: Dictionary = {}
var _revealing: bool = false
var _reveal_skip: bool = false
var _recognised: Label
const CHARACTER := preload("res://scenes/npc/CharacterArt.gd")

const GLYPHS_FULL   := "◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡"
const GLYPHS_SIMPLE := "▲▼●■◆★▸◀▴▾"
const ANIM_INTERVAL := 0.18   # seconds between glyph shuffles for first-time words

const STYLE_COLORS: Dictionary = {
	"formal":   Color(0.32, 0.30, 0.80),
	"direct":   Color(0.10, 0.58, 0.50),
	"gesture":  Color(0.72, 0.42, 0.10),
	"indirect": Color(0.18, 0.44, 0.72),
}

const TEXT_SIZES := [[16, 14], [20, 17], [25, 21]]

# The box is a shared overlay. `closed` is how a caller that opened it can wait
# for it without polling its visibility, and ask() is the one-exchange form a
# staged scene uses: show a line, wait, get back what he did.
signal closed
var _answer:          Dictionary = {}
# Who is speaking, for the voice. Empty for the many conversations in the game
# that have not been recorded, which then stay silent as they always were.
var _voice_id:        String     = ""
var _hear_again:      Label

var _entries:         Array      = []
var _index:           int        = 0
var _current_words:   Array      = []
# The local words in the sentence he is answering. He may echo any of them
# whether or not he knows what they mean - see GameState.can_say().
var _heard:           Array      = []
# Who he is talking to. Only `build` is read, and only by register.
var _speaker:         Dictionary = {}
# Set when a conversation moved what this person expects to be called. Shown
# once the box is out of the way, because it is a thing he notices afterwards.
# Whatever he works out on the way out of the conversation: a register that
# moved, a correction he was given, or what a silence turned out to mean.
var _after_thought:   String     = ""

# ── Timing, and the dance ────────────────────────────────────────────────────
var _patience_bar:    ColorRect
var _patience:        float      = 0.0    # seconds left before silence answers
var _patience_max:    float      = 0.0
var _timed:           bool       = false
# How many times he has said no in this conversation. Some cities want one.
var _declines:        int        = 0

# How well somebody has to think of him before they will bother telling him he
# has got it wrong. "The newcomer" - the first rung above being nobody.
const CORRECT_AT := 10
var _animating_words: Dictionary = {}   # "lang:word" keys for first-time words
var _has_anim_words:  bool       = false
var _anim_timer:      float      = 0.0
var _grant_exposure:  bool       = true   # false on repeat talks — no familiarity farming
var _region:          String     = ""     # reputation region for this conversation

var _avatar_panel:   Panel
var _main_panel: Panel
var _portrait_look: Dictionary = {}
var _option_scroll: ScrollContainer
var _name_label:     Label
var _rel_label:      Label
var _standing_label: Label
var _text_label:     RichTextLabel
var _resp_box:       VBoxContainer
var _legend:         Label

var _tooltip:       PanelContainer
var _tooltip_word:  Label
var _tooltip_guess: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialogue_box")
	_build_ui()
	_build_tooltip()
	_text_label.meta_underlined = false
	_text_label.meta_hover_started.connect(_on_word_hover_started)
	_text_label.meta_hover_ended.connect(_on_word_hover_ended)
	hide()


func _process(delta: float) -> void:
	if not visible:
		return
	if _tooltip.visible:
		_position_tooltip()
	# The silence, running out. Runs while the tree is paused, which is why
	# this node has always been PROCESS_MODE_ALWAYS.
	if _timed:
		_patience -= delta
		if _patience_max > 0.0:
			_patience_bar.size_flags_stretch_ratio = maxf(
				_patience / _patience_max, 0.001)
			_patience_bar.color.a = 0.12 + 0.26 * clampf(
				_patience / _patience_max, 0.0, 1.0)
			_patience_bar.custom_minimum_size = Vector2(
				_resp_box.size.x * clampf(_patience / _patience_max, 0.0, 1.0),
				2)
		if _patience <= 0.0:
			_on_silence()
			return
	if not _has_anim_words:
		return
	_anim_timer += delta
	if _anim_timer >= ANIM_INTERVAL:
		_anim_timer = 0.0
		_text_label.text = _compose(_current_words)


func _build_ui() -> void:
	var main := Panel.new()
	_main_panel = main
	main.anchor_left   = 0.0
	main.anchor_top    = 1.0
	main.anchor_right  = 1.0
	main.anchor_bottom = 1.0
	main.offset_top    = -490.0
	main.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color         = Color(0.07, 0.06, 0.13, 0.97)
	panel_sb.border_width_top = 1
	panel_sb.border_color     = Color(0.30, 0.28, 0.48, 0.55)
	panel_sb.shadow_color     = Color(0, 0, 0, 0.4)
	panel_sb.shadow_size      = 12
	panel_sb.shadow_offset    = Vector2(0, -4)
	main.add_theme_stylebox_override("panel", panel_sb)
	add_child(main)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	main.add_child(hbox)

	hbox.add_child(_build_npc_column())

	var sep := VSeparator.new()
	sep.add_theme_color_override("color", Color(0.24, 0.22, 0.40, 0.50))
	hbox.add_child(sep)

	var content := _build_content_column()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(content)


func _build_npc_column() -> Control:
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(220, 0)
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	margin.add_theme_constant_override("margin_top",    28)
	margin.add_theme_constant_override("margin_bottom", 18)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)

	_avatar_panel = Panel.new()
	_avatar_panel.custom_minimum_size   = Vector2(96, 96)
	_avatar_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_avatar_panel.add_theme_stylebox_override("panel", _avatar_style(Color(0.85, 0.52, 0.42)))

	_avatar_panel.draw.connect(func():
		if not _portrait_look.is_empty():
			CHARACTER.draw_figure(_avatar_panel, Vector2(48, 89), 3.0,
				_portrait_look, "stand", 0.0, 0))
	col.add_child(_avatar_panel)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 17)
	_name_label.add_theme_color_override("font_color", Color(0.90, 0.88, 1.00))
	col.add_child(_name_label)

	_rel_label = Label.new()
	_rel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rel_label.custom_minimum_size = Vector2(160, 0)
	_rel_label.add_theme_font_size_override("font_size", 14)
	_rel_label.add_theme_color_override("font_color", Color(0.50, 0.78, 0.56))
	col.add_child(_rel_label)

	# How this part of town currently sees the player — the only visible
	# face of the hidden reputation number
	_standing_label = Label.new()
	_standing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_standing_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_standing_label.custom_minimum_size = Vector2(160, 0)
	_standing_label.add_theme_font_size_override("font_size", 12)
	_standing_label.add_theme_color_override("font_color", Color(0.60, 0.58, 0.85, 0.75))
	col.add_child(_standing_label)

	return margin


func _build_content_column() -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	margin.add_theme_constant_override("margin_top",    24)
	margin.add_theme_constant_override("margin_bottom", 18)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	margin.add_child(col)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.scroll_active  = false
	_text_label.autowrap_mode  = TextServer.AUTOWRAP_WORD_SMART
	_text_label.fit_content    = true
	_text_label.add_theme_font_size_override("normal_font_size", TEXT_SIZES[1][0])
	_text_label.add_theme_font_override("normal_font", UIStyles.reading_font)
	_text_label.add_theme_constant_override("text_highlight_h_padding", 0)
	col.add_child(_text_label)

	var legend := Label.new()
	legend.text = ""
	# Set per conversation — London's rules are not Berlin's, so a fixed
	# glyph legend was describing a mechanic that city does not use.
	_legend = legend
	legend.add_theme_font_size_override("font_size", 13)
	legend.add_theme_color_override("font_color", Color(0.42, 0.40, 0.62, 0.75))
	col.add_child(legend)

	# "Noch mal?" - the most useful thing you can say in a language you do not
	# have, offered for free on every line that was recorded.
	_hear_again = Label.new()
	_hear_again.text = "R  ·  hear it again"
	_hear_again.mouse_filter = Control.MOUSE_FILTER_STOP
	_hear_again.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_hear_again.add_theme_font_size_override("font_size", 13)
	_hear_again.add_theme_color_override("font_color", Color(0.886, 0.706, 0.361, 0.80))
	_hear_again.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			AudioManager.replay())
	_hear_again.visible = false
	col.add_child(_hear_again)

	# A found word, said again: "you know this one". And the word he has just
	# found, with what it turned out to mean.
	_recognised = Label.new()
	_recognised.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_recognised.add_theme_font_size_override("font_size", 14)
	_recognised.add_theme_color_override("font_color", Color(0.953, 0.835, 0.541, 0.92))
	_recognised.visible = false
	col.add_child(_recognised)

	# How long this city will let a silence run. Deliberately quiet: two pixels
	# of warm line that shortens. A countdown bar with a colour on it turns a
	# conversation into a quick-time event, and the point of the mechanic is
	# the opposite - not answering is an ANSWER, and a perfectly good one in
	# Tokyo and in Dakar. It should read as a moment passing, not as a fuse.
	_patience_bar = ColorRect.new()
	_patience_bar.color = Color(0.886, 0.706, 0.361, 0.30)
	_patience_bar.custom_minimum_size = Vector2(0, 2)
	_patience_bar.size_flags_horizontal = Control.SIZE_FILL
	_patience_bar.visible = false
	col.add_child(_patience_bar)

	_option_scroll = ScrollContainer.new()
	_option_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_option_scroll.follow_focus = true
	_option_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_option_scroll)
	_resp_box = VBoxContainer.new()
	_resp_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resp_box.add_theme_constant_override("separation", 10)
	_option_scroll.add_child(_resp_box)

	return margin


# ── Public API ────────────────────────────────────────────────────────────────

# One exchange, for a scene that is being staged in the street: show what they
# said, wait for what he did, and hand that back. {} means he stepped away.
#
#   who     name, relationship, color, region, voice, grant, and `person` - the
#           register dictionary (build, and optionally the rung they `wants`)
func ask(entry: Dictionary, who: Dictionary) -> Dictionary:
	_answer = {}
	var person: Dictionary = Dictionary(who.get("person", {})).duplicate(true)
	person["look"] = who.get("look", {})
	show_dialogue([entry], String(who.get("name", "Somebody")),
		String(who.get("relationship", "")),
		who.get("color", Color(0.85, 0.52, 0.42)), bool(who.get("grant", true)),
		String(who.get("region", "")), person,
		String(who.get("voice", "")))
	await closed
	return _answer


func show_dialogue(entries: Array, npc_name: String, relationship: String,
		npc_color: Color, grant_exposure: bool = true, region: String = "",
		speaker: Dictionary = {}, voice: String = "") -> void:
	_voice_id = voice
	_answer = {}
	_grant_exposure = grant_exposure
	_region  = region
	# Who is being spoken to, for the one thing register needs to know about
	# them: roughly how old they are. Defaulted, so the callers that do not
	# pass it get an adult and nothing breaks.
	_speaker = speaker if not speaker.is_empty() else {"build": "adult"}
	_portrait_look = _speaker.get("look", {})
	_avatar_panel.visible = not _portrait_look.is_empty()
	_avatar_panel.queue_redraw()
	_declines = 0
	_timed = false
	_entries = entries
	_index   = 0
	_name_label.text = npc_name
	_rel_label.text  = relationship
	_update_standing()
	_update_legend()

	_avatar_panel.add_theme_stylebox_override("panel", _avatar_style(npc_color))

	var ts: int = clampi(SaveManager.settings.get("text_size", 1), 0, TEXT_SIZES.size() - 1)
	_text_label.add_theme_font_size_override("normal_font_size", TEXT_SIZES[ts][0])

	show()
	get_tree().paused = true
	_display_entry(_entries[0])


# What the marks on screen mean, in this city's terms.
func _update_legend() -> void:
	if _legend == null:
		return
	var lang: String = GameState.local_language()
	if lang == "english":
		_legend.text = "you can read all of it  ·  ° = a meaning you worked out in context"
	else:
		_legend.text = "~ unfamiliar  ·  letters = familiar  ·  gold = worked out"
		# The amber mark only means something when there is one on screen.
		if not _targets.is_empty():
			_legend.text += "  ·  amber = what this turns on"
	# And which "you" he is currently using. It is never marked right or wrong
	# here - only stated - because whether it is right is the thing the player
	# is supposed to be working out.
	if GameState.REGISTER.has_ladder(lang) 			and GameState.fluency(lang) >= GameState.FLUENCY_WORDS:
		_legend.text += "  ·  saying it as %s" % GameState.REGISTER.shown(
			lang, GameState.register_for(lang))


func _display_entry(entry: Dictionary) -> void:
	_tooltip.hide()
	# Street scenes act in the lower half of the viewport. Keep their people,
	# hands and props visible while the player considers a response.
	var staged: bool = bool(entry.get("in_world", false))
	_main_panel.anchor_top = 0.0 if staged else 1.0
	_main_panel.anchor_bottom = _main_panel.anchor_top
	_main_panel.offset_top = 24.0 if staged else -490.0
	_main_panel.offset_bottom = 544.0 if staged else 0.0
	var words: Array = entry.get("words", [])
	_current_words = words

	# What he has just been told, in the language of the street he is on. An
	# answer may repeat any of it back: a sound you heard a second ago is
	# available to you in a way a word out of a notebook is not.
	_heard.clear()
	var here: String = GameState.local_language()
	for w in words:
		if String(w.get("language", "")) == here:
			var k: String = String(w.get("word", "")).to_lower()
			if not k.is_empty() and not _heard.has(k):
				_heard.append(k)

	# Identify first-time words BEFORE exposing them
	_animating_words.clear()
	for w in words:
		var lang: String     = w.get("language", "")
		var word_key: String = w.get("word", "")
		if GameState.get_familiarity(lang, word_key) == 0:
			_animating_words[lang + ":" + word_key] = true

	_has_anim_words = not _animating_words.is_empty()
	_anim_timer     = 0.0

	# Expose words for this entry — but only on the first talk of a visit,
	# so replaying the conversation can't farm familiarity
	if _grant_exposure:
		for w in words:
			GameState.expose(w.get("language", ""), w.get("word", ""), "hear")

	_stage = String(entry.get("stage", ""))
	_targets = _targets_of(entry)
	_update_legend()
	_recognise(words)
	_text_label.text = _compose(words)
	_render_options(entry)
	_speak_line(entry, words)

	# Does this moment have a clock on it? Opt-in per entry, because making
	# every exchange in the game timed would turn a conversation into a test,
	# and most conversations are not one. The author decides which moments are
	# about when he speaks rather than what he says.
	_timed = bool(entry.get("timed", false)) 			and bool(SaveManager.settings.get("timed_choices", true))
	if _timed:
		_patience_max = GameState.RITUAL.patience(GameState.city)
		_patience = _patience_max
		_patience_bar.visible = true
	else:
		_patience_bar.visible = false


# The words this exchange is about: whatever an answer to it would confirm or
# get wrong. Only those not yet found are marked - the rest are just talk.
func _targets_of(entry: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var lang: String = GameState.local_language()
	for resp: Dictionary in entry.get("responses", []):
		for key: String in ["confirm", "misread"]:
			for w: String in Dictionary(resp.get(key, {})):
				if not NOTEBOOK.found(String(resp.get("language", lang)), w):
					out[w.to_lower()] = true
	return out


# A word he has found, said to him again somewhere new. Said in the box itself,
# once per sentence: the moment of "I know that one" is the one worth having.
func _recognise(words: Array) -> void:
	_recognised.visible = false
	if not _grant_exposure:
		return
	var said: PackedStringArray = []
	for w: Dictionary in words:
		said.append(String(w.get("text", "")))
	var context: String = _name_label.text + "|" + " ".join(said)
	var known: PackedStringArray = []
	for w2: Dictionary in words:
		var lang: String = String(w2.get("language", ""))
		var key: String = String(w2.get("word", ""))
		if NOTEBOOK.recall(lang, key, context):
			known.append("%s — %s" % [String(w2.get("text", key)).trim_suffix(".").trim_suffix(",").trim_suffix("?").trim_suffix("!"), NOTEBOOK.meaning(lang, key)])
	if not known.is_empty():
		_recognised.text = "You know this one:  " + "   ·   ".join(known)
		_recognised.visible = true


# What he can SEE, above what he hears. The whole of the deciphering in this
# game is the gap between the two: a hand on a crate, a look at the door, and
# a sentence made of shapes he cannot read yet. The stage line is never a
# translation. It is the evidence.
var _stage: String = ""


func _compose(words: Array) -> String:
	var said: String = _render_words(words)
	if _stage.is_empty():
		return said
	var seen: String = "[color=#a4a2cc][i]" + _stage + "[/i][/color]"
	return seen if said.is_empty() else seen + "\n\n" + said


# The line out loud, in the speaker's voice. `tts` exists for the rare line
# whose spelling on screen would mislead a synthesiser; otherwise it is exactly
# the words shown, so what is heard and what is read never disagree.
func _speak_line(entry: Dictionary, words: Array) -> void:
	_hear_again.visible = false
	var voice: String = String(entry.get("voice", _voice_id))
	if voice.is_empty():
		return
	var spoken: String = String(entry.get("tts", ""))
	if spoken.is_empty():
		var parts: PackedStringArray = []
		for w: Dictionary in words:
			parts.append(String(w.get("text", "")))
		spoken = " ".join(parts)
	if spoken.strip_edges().is_empty():
		return
	if AudioManager.say(voice, spoken) > 0.0:
		_hear_again.visible = true


# The options, on their own, because changing how he is addressing somebody
# redraws them and must NOT re-run the exposure above: re-reading the same
# sentence four times while trying registers would teach its words four times.
func _render_options(entry: Dictionary) -> void:
	for child in _resp_box.get_children():
		_resp_box.remove_child(child)
		child.queue_free()
	var responses: Array = _prepare(entry.get("responses", []),
		bool(entry.get("keep", false)))
	var shown: Array = []
	for i in range(responses.size()):
		var resp: Dictionary = responses[i]
		# Money-gated responses only appear when the player can afford them
		if not Journey.core() and int(resp.get("requires_money", 0)) > GameState.money:
			continue
		# An answer that draws on another country only exists if he has been
		# there. Cities can be visited in any order, so nothing may assume one.
		var been: String = String(resp.get("needs_city", ""))
		if not been.is_empty() and not bool(GameState.world_flags.get("visited_" + been, false)):
			continue
		# And item-gated ones only when he is carrying the thing. Showing the
		# room card to the man standing in your room is not an option if you
		# have not got the room card - and offering it greyed out would tell
		# the player the answer.
		var needs: String = String(resp.get("requires_item", ""))
		if not needs.is_empty() and not GameState.has_item(needs):
			continue
		# And an option that IS one particular word - "say the one word you
		# are sure of" - is not an option at all until he is sure of it. The
		# tier fallback cannot rescue these: dropping to the description would
		# leave him promising to say a word he has never heard.
		var needs_word: String = String(resp.get("requires_word", "")).to_lower()
		if not needs_word.is_empty() and not _has_word(needs_word):
			continue
		shown.append(resp)
	# Never leave him with nothing to say. If every option turned out to be
	# gated - which should not happen, and would be a data fault rather than a
	# state the player deserves - the unfiltered list is better than a dead box.
	if shown.is_empty():
		shown = responses
	for i in range(shown.size()):
		_resp_box.add_child(_make_response_row(shown[i], i))
	_add_register_rows(entry)
	_option_scroll.scroll_vertical = 0
	_focus_first.call_deferred()


func _focus_first() -> void:
	if not visible or _resp_box.get_child_count() == 0:
		return
	var row: Node = _resp_box.get_child(0)
	for child in row.get_children():
		if child is Button:
			child.grab_focus()
			return


# ── Which "you" he is using ──────────────────────────────────────────────────
#
# Not a response. It changes nothing about what he says and does not advance
# the conversation - it changes how he is addressing the person he is saying it
# to, which is a different axis entirely and is the one the game was missing.
#
# Only offered once he has words at all. A mute alien choosing between du and
# Sie is choosing between two things he cannot pronounce.
func _add_register_rows(entry: Dictionary) -> void:
	var lang: String = GameState.local_language()
	if not GameState.REGISTER.has_ladder(lang):
		return
	# Every answer here is something he does with his hands. There is no "you"
	# in carrying a crate, so there is nothing to pitch.
	if bool(entry.get("silent", false)):
		return
	if GameState.fluency(lang) < GameState.FLUENCY_WORDS:
		return
	var here: String = GameState.register_for(lang)
	for rung: String in GameState.REGISTER.rung_ids(lang):
		if rung == here:
			continue
		_resp_box.add_child(_make_register_row(entry, lang, rung))


func _make_register_row(entry: Dictionary, lang: String,
		rung: String) -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(0, 46)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _register_sb(false))
	wrap.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)

	var lbl := Label.new()
	lbl.text = "Say it as %s" % GameState.REGISTER.shown(lang, rung)
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", Color(0.80, 0.84, 0.96))
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(lbl)

	# What that rung is FOR. The player is never told which one is correct -
	# only what each one means - because working out which of them this person
	# wants is the whole of the mechanic.
	var sub := Label.new()
	sub.text = GameState.REGISTER.gloss(lang, rung)
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", Color(0.56, 0.58, 0.76))
	sub.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbox.add_child(sub)

	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	for state in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	btn.mouse_entered.connect(func(): panel.add_theme_stylebox_override("panel", _register_sb(true)))
	btn.mouse_exited.connect(func():  panel.add_theme_stylebox_override("panel", _register_sb(false)))
	btn.focus_entered.connect(func(): panel.add_theme_stylebox_override("panel", _register_sb(true)))
	btn.focus_exited.connect(func(): panel.add_theme_stylebox_override("panel", _register_sb(false)))
	btn.pressed.connect(_on_register.bind(entry, lang, rung))
	wrap.add_child(btn)
	return wrap


func _on_register(entry: Dictionary, lang: String, rung: String) -> void:
	GameState.set_register(rung, lang)
	_update_legend()
	_render_options(entry)


# Deliberately not the response row's style: this is a thing he does with his
# mouth rather than a thing he says, and it should not look like a fourth
# answer to a question with three.
func _register_sb(hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.10, 0.13, 0.20, 0.72) if hovered else Color(0.07, 0.09, 0.14, 0.55)
	sb.border_color = Color(0.40, 0.52, 0.70, 0.60) if hovered else Color(0.22, 0.28, 0.42, 0.40)
	sb.border_width_left = 3
	sb.border_width_right = 1
	sb.border_width_top  = 1
	sb.border_width_bottom = 1
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 16; sb.content_margin_right  = 14
	sb.content_margin_top  = 8;  sb.content_margin_bottom = 8
	return sb


# ── The silence, once it has stopped being a pause ───────────────────────────
#
# Nothing here is a failure state. He said nothing, and saying nothing is an
# answer that means something different in every city on the itinerary - in
# Tokyo it is the best one available and in Dakar it is simply how this is
# done. The conversation moves on exactly as it would have.
func _on_silence() -> void:
	_timed = false
	_patience_bar.visible = false
	var city: String = GameState.city
	var rep: int = GameState.RITUAL.silence_rep(city)
	if _grant_exposure and rep != 0 and not _region.is_empty():
		var before: String = GameState.city_rep_level()
		GameState.change_reputation(_region, rep)
		var toast := get_tree().get_first_node_in_group("rep_toast")
		if toast != null:
			toast.show_change(rep, "", _name_label.text, _region, before,
				"the pause read as " + GameState.RITUAL.silence_reads(city))
	if _after_thought.is_empty():
		_after_thought = GameState.RITUAL.silence_note(city)
	_update_standing()
	_index += 1
	if _index >= _entries.size():
		_close()
	else:
		_display_entry(_entries[_index])


# Whether he has a particular local word to hand: learned, or just said to him.
func _has_word(word: String) -> bool:
	if _heard.has(word):
		return true
	var lang: String = GameState.local_language()
	return GameState.get_tier(lang, word) >= GameState.TIER_PARTIAL


# ── Giving every exchange a real choice ──────────────────────────────────────
#
# Two faults, both systemic, and both in the data rather than in any one line:
#
#   * The best option was FIRST in 94% of the game's 128 exchanges, so the
#     winning strategy was to press the top button and never read anything.
#   * 88% offered no full spread - no option that clearly costs you standing,
#     or none that is simply neutral - so most "choices" were one right answer
#     and some filler.
#
# Both are fixed here, at the moment the options are shown, rather than by
# rewriting a hundred and twenty-eight hand-written exchanges and hoping none
# of them drifted.
#
# The rep an option is worth, where the author did not say, comes from its
# STYLE and the CITY it is spoken in - which is the whole argument of this
# game. Being direct is warmth in Berlin and rudeness in Tokyo. Being formal
# is respect in Paris and a refusal of hospitality in Istanbul. Effusiveness
# reads as idiocy in Moscow and as ordinary manners in Sao Paulo.
const STYLE_REP := {
	"berlin":   {"direct": 2, "casual": 1, "indirect": -1, "formal": -1, "gesture": 0},
	"zurich":   {"direct": 1, "casual": 0, "indirect": 1, "formal": 2, "gesture": -1},
	"london":   {"direct": -1, "casual": 2, "indirect": 1, "formal": -2, "gesture": 0},
	"paris":    {"direct": -2, "casual": -1, "indirect": 1, "formal": 2, "gesture": 0},
	"moscow":   {"direct": 2, "casual": -2, "indirect": 0, "formal": 1, "gesture": 0},
	"istanbul": {"direct": 1, "casual": 2, "indirect": 0, "formal": -2, "gesture": 1},
	"mumbai":   {"direct": 1, "casual": 2, "indirect": 0, "formal": -2, "gesture": 1},
	"tokyo":    {"direct": -2, "casual": 0, "indirect": 2, "formal": 1, "gesture": -1},
	"seoul":    {"direct": -1, "casual": 0, "indirect": 1, "formal": 2, "gesture": -1},
	"mexico":   {"direct": -1, "casual": 2, "indirect": 1, "formal": 0, "gesture": 1},
	"lapaz":    {"direct": -1, "casual": 1, "indirect": 2, "formal": 0, "gesture": 1},
	"saopaulo": {"direct": 0, "casual": 2, "indirect": 1, "formal": -2, "gesture": 1},
	"rome":     {"direct": 2, "casual": 1, "indirect": -1, "formal": -1, "gesture": 1},
	"hanoi":    {"direct": -1, "casual": 1, "indirect": 2, "formal": 0, "gesture": 0},
	"dakar":    {"direct": -2, "casual": 1, "indirect": 2, "formal": 1, "gesture": 0},
	"tbilisi":  {"direct": 1, "casual": 2, "indirect": 0, "formal": -1, "gesture": 1},
	"newyork":  {"direct": 2, "casual": 1, "indirect": -2, "formal": -1, "gesture": 0},
	"toronto":  {"direct": 0, "casual": 1, "indirect": 2, "formal": 1, "gesture": 0},
	"sydney":   {"direct": 1, "casual": 2, "indirect": -1, "formal": -2, "gesture": 0},
	"honolulu": {"direct": -1, "casual": 2, "indirect": 1, "formal": -1, "gesture": 1},
}


# `keep` is for a staged exchange whose consequences are written out beat by
# beat. There the "something must be lost" rule is wrong on purpose: a wrong
# reading is not a penalty, it is a different scene, and forcing a -2 onto it
# would punish exactly the experimenting the scene exists to invite. Such an
# exchange is still shuffled - the right reading is never simply the top one.
func _prepare(src: Array, keep: bool = false) -> Array:
	if src.size() < 2:
		return src
	var out: Array = []
	var by_city: Dictionary = STYLE_REP.get(GameState.city, STYLE_REP["berlin"])
	var authored: bool = false
	for r: Dictionary in src:
		var row: Dictionary = r.duplicate()
		if row.has("rep"):
			authored = true
		out.append(row)
	if keep or Journey.core():
		# Authored reactions belong to this person. Do not invent a losing
		# answer from a country-wide directness stereotype.
		return _shuffled(out)

	# Where nobody said, the city decides.
	if not authored:
		for row2: Dictionary in out:
			row2["rep"] = int(by_city.get(String(row2.get("style", "")), 0))

	# There must be something to lose. An exchange where no answer costs you
	# anything is not a choice, it is a formality with buttons on it.
	var reps: Array = []
	for row3: Dictionary in out:
		reps.append(int(row3.get("rep", 0)))
	if reps.max() <= 0:
		out[reps.find(reps.max())]["rep"] = 2
		reps[reps.find(reps.max())] = 2
	if reps.min() >= 0:
		# the option the city likes least becomes the one that costs you
		var worst: int = 0
		var worst_v: int = 99
		for i in range(out.size()):
			var v: int = int(by_city.get(String(out[i].get("style", "")), 0))
			if int(reps[i]) <= reps.max() - 1 and v < worst_v:
				worst_v = v
				worst = i
		out[worst]["rep"] = -2
	# and something in between, so the spread is genuinely three-way
	var has_zero: bool = false
	for row4: Dictionary in out:
		if int(row4.get("rep", 0)) == 0:
			has_zero = true
	if not has_zero and out.size() >= 3:
		for row5: Dictionary in out:
			var v2: int = int(row5.get("rep", 0))
			if v2 > 0 and v2 < 2:
				row5["rep"] = 0
				break

	return _shuffled(out)


# And they are not in the order they were written. Deterministically per
# exchange, so re-reading the same conversation does not reshuffle under the
# player - but the winning answer is no longer always the first one. Seeded on
# which exchange this is and who is speaking, so the order is fixed for a given
# conversation and does not reshuffle while they are reading it.
func _shuffled(out: Array) -> Array:
	var first: String = ""
	if not out.is_empty():
		first = String(Dictionary(out[0]).get("gesture", Dictionary(out[0]).get("text", "")))
	var seed_s: String = _name_label.text + ":" + str(_index) + ":" + str(out.size()) + ":" + first
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(seed_s.hash())
	for i2 in range(out.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i2)
		var tmp = out[i2]
		out[i2] = out[j]
		out[j] = tmp
	return out


# What the alien manages to say out loud, marked so it can be hovered.
#
# A word only comes out in the language once it is at least half learned;
# below that the alien is still thinking it in its own terms. TIER_PARTIAL is
# the same threshold the NPC's speech uses to stop glyphing a word, so the
# moment you can READ a word on the street is the moment you can SAY it.
func _speak(phrase: String) -> String:
	var lang: String = GameState.local_language()
	var out: String = ""
	for piece: Dictionary in SPEECH.pieces(phrase, lang, GameState.TIER_PARTIAL):
		var word: String = String(piece.get("word", ""))
		var shown: String = String(piece.get("text", ""))
		if word.is_empty():
			# Still English as far as the swap goes - but the author may have
			# written the local word in directly, and that one is hoverable
			# too. Same colour, because to the player they are the same thing:
			# a word of theirs that he managed to get out.
			for lp: Dictionary in SPEECH.local_pieces(shown, lang):
				var lw: String = String(lp.get("word", ""))
				var lt: String = String(lp.get("text", ""))
				if lw.is_empty():
					out += lt
				else:
					out += _wrap_guess(lw, "[color=#cfe6d8]" + lt + "[/color]")
			continue
		out += _wrap_guess(word, "[color=#cfe6d8]" + shown + "[/color]")
	return out


func _on_response(resp: Dictionary) -> void:
	# The line is still decoding from the last answer; one answer at a time.
	if _revealing:
		return
	_revealing = true
	_timed = false
	# Saying something is the strongest way to learn it, and it is the one
	# exposure the game was not counting: you could ask for bread in Turkish
	# fifty times and "ekmek" would be no more familiar for it. Every word the
	# option is made of is exposed as `used`, whether or not the alien managed
	# to get it out in the language - trying to say a word is how you learn it.
	var said: String = GameState.phrase_for(resp, _heard)
	Journey.ensure_funds(int(resp.get("requires_money", 0)))
	var lang: String = GameState.local_language()
	var gesture_only: bool = said == String(resp.get("gesture", ""))
	_answer = resp
	_learn_from(resp, lang)
	if _grant_exposure and not gesture_only:
		var spoken_words: Array = SPEECH.vocabulary_in(said, lang)
		for piece: Dictionary in SPEECH.pieces(said, lang, GameState.TIER_PARTIAL):
			var key: String = String(piece.get("word", ""))
			if not key.is_empty() and not spoken_words.has(key):
				spoken_words.append(key)
		for word: String in spoken_words:
			GameState.expose(lang, word, "used")
	var action: String = resp.get("action", "")
	if action == "buy_bread":
		GameState.buy_bread()
	elif action == "give_map":
		GameState.receive_map()
	elif action == "book_room":
		GameState.book_room()
	elif action.begins_with("flag:"):
		# Settles an encounter. The flag is what stops the same man walking
		# into the same room the next time the player opens the door.
		GameState.world_flags[action.substr(5)] = true
	elif action.begins_with("give:"):
		GameState.drop_item(action.substr(5))

	# ── What it cost to address them the way he did ──────────────────────────
	#
	# Separate from what he said, because it IS separate: this is the half of
	# the thesis the game could not previously express. He can have every word
	# in the sentence, pick the option that means exactly the right thing, and
	# still get this wrong - and when he does, the reason has nothing to do
	# with vocabulary.
	#
	# Too formal and too familiar are not the same mistake. Keeping a distance
	# somebody has already closed is a coldness; closing one that was not his
	# to close is a presumption, and the second is worse almost everywhere.
	var lang2: String = GameState.local_language()
	var slip: int = GameState.register_slip(_speaker, lang2)
	var reg_note: String = ""
	var reg_delta: int = 0
	var entry: Dictionary = _entries[_index] if _index < _entries.size() else {}
	var wordless: bool = gesture_only or bool(entry.get("silent", false))
	# Staged stories already dramatise their own address choices and repair.
	var scripted: bool = bool(entry.get("keep", false))
	if not wordless and not scripted and _grant_exposure and GameState.REGISTER.has_ladder(lang2) and GameState.fluency(lang2) >= GameState.FLUENCY_WORDS:
		if slip > 0:
			reg_delta = -1 if slip == 1 else -3
		elif slip < 0:
			reg_delta = -2 if slip == -1 else -3
		elif GameState.register_expected(_speaker, lang2) 				!= GameState.REGISTER.default_rung(lang2):
			# Right, and not merely by leaving it where it started. Noticing
			# that a relationship has moved is the skill; the default is not.
			reg_delta = 1
		reg_note = GameState.REGISTER.misread(lang2,
			GameState.register_for(lang2),
			GameState.register_expected(_speaker, lang2))

	# ── The dance ────────────────────────────────────────────────────────────
	#
	# Somebody has put a glass in front of him. Taking it at once is not
	# gratitude and refusing it is not politeness: there is a number of times
	# he is supposed to say no first, and it is one in Istanbul, one in Tokyo
	# for a completely different reason, and zero in Berlin, where a token
	# refusal reads as a man who does not know what he wants.
	#
	# The important part is that a refusal WITHIN the dance is not scored as a
	# refusal. The game has been marking Meryem's "no, I couldn't" at minus
	# three this whole time, because it had no concept of the thing that no is
	# half of.
	var rite: String = String(resp.get("ritual", ""))
	var rite_rep: int = 0
	var answer: Dictionary = resp
	if Journey.core() and _grant_exposure and not rite.is_empty():
		# Invitations are this host's, not a mandatory number of refusals for
		# a whole country. Keep their authored response; boundaries are free.
		_after_thought = String(resp.get("feedback", ""))
	elif _grant_exposure and not rite.is_empty():
		var town: String = GameState.city
		if rite == "decline":
			if _declines < GameState.RITUAL.refusals_wanted(town):
				answer = resp.duplicate()
				answer["rep"] = 0
			_declines += 1
		elif rite == "accept":
			var got: Array = GameState.RITUAL.accepted(town, _declines)
			rite_rep = int(got[0])
			if _after_thought.is_empty():
				_after_thought = String(got[1])

	# Hidden reputation shift — only on the first talk of a visit, so
	# replaying a conversation can't farm goodwill
	var rep_delta := int(answer.get("rep", 0)) + reg_delta + rite_rep
	if Journey.core() and rite == "decline":
		rep_delta = 0 # A personal boundary never costs standing.
	var want_was: String = GameState.register_expected(_speaker, lang2)
	var before: String = GameState.city_rep_level()
	if _grant_exposure and rep_delta != 0 and not _region.is_empty():
		GameState.change_reputation(_region, rep_delta)
		# Did that move what this person expects to be called? If so it is an
		# event and he has to be told, or the next conversation punishes him
		# for a thing that was right yesterday.
		var want_now: String = GameState.register_expected(_speaker, lang2)
		if want_now != want_was:
			_after_thought = GameState.REGISTER.moved(lang2, want_was, want_now)
		# Tell the player what their choice read as. In a game about whether you
		# said the right thing, this is the one number worth being explicit about
		# — though it still never shows the number.
		var toast := get_tree().get_first_node_in_group("rep_toast")
		if toast != null and not bool(entry.get("in_world", false)):
			toast.show_change(rep_delta, String(resp.get("style", "")),
				_name_label.text, _region, before, reg_note)

	# Being told. Only by somebody who already thinks reasonably well of him -
	# below that they simply cool and he is left to work out why, which is both
	# the more common experience of this and the reason it is not a difficulty
	# setting. A correction is a kindness and it has to be earned like one.
	if not wordless and not scripted and _grant_exposure and slip != 0 and _after_thought.is_empty() and GameState.city_reputation() >= CORRECT_AT:
		var told: Array = GameState.REGISTER.correction(lang2, slip)
		if told.size() == 2:
			_after_thought = "“%s”\n\n%s" % [String(told[0]), String(told[1])]
	_update_standing()
	_update_legend()
	if Journey.core():
		var original := ""
		for word: Dictionary in _current_words:
			original += String(word.get("text", "")) + " "
		Journey.record(_name_label.text, original.strip_edges() + "\n\nYou: " + said)

	await _reveal(resp)
	if not visible:
		return   # he stepped away during the reveal; _close() has already run
	_index += 1
	if _index >= _entries.size():
		_close()
	else:
		_display_entry(_entries[_index])


# A first discovery stays until the player has considered it and continued.
# Repeated confirmations do not interrupt the same conversation again.
func _reveal(resp: Dictionary) -> void:
	if _fresh_discoveries.is_empty() or not visible:
		_revealing = false
		return
	for row in _resp_box.get_children():
		row.visible = false
	var discovery := get_tree().get_first_node_in_group("word_discovery")
	if discovery != null:
		# The line the word was said in, above what was happening around it.
		var said: PackedStringArray = []
		for word: Dictionary in _current_words:
			said.append(String(word.get("text", "")))
		var line := " ".join(said).strip_edges()
		var context := ("«%s»\n\n%s" % [line, _stage]) if not line.is_empty() else _stage
		var action := GameState.phrase_for(resp, _heard)
		if not action.is_empty(): context += "\n\nYou: " + action
		await discovery.present(_fresh_discoveries, context.strip_edges(), _name_label.text)
	_text_label.text = _compose(_current_words)
	_revealing = false


# He acted on a reading of what was said, and the scene is about to show him
# whether it was the right one. `confirm` is {word: meaning} for a reading the
# world bears out; `misread` is {word: what he thought} for one it does not.
# Neither is a score. Understanding is idempotent, so reopening a scene cannot
# farm it, and a misreading is only ever kept as the FIRST thought about a word.
func _learn_from(resp: Dictionary, lang: String) -> void:
	_fresh_discoveries.clear()
	var tongue: String = String(resp.get("language", lang))
	var moment: String = String(resp.get("moment", _name_label.text))
	var confirmed: Dictionary = resp.get("confirm", {})
	for w: String in confirmed:
		if GameState.understand(tongue, w, String(confirmed[w]), moment):
			_fresh_discoveries.append({"language":tongue, "word":w, "meaning":String(confirmed[w])})
	var wrong: Dictionary = resp.get("misread", {})
	for w2: String in wrong:
		GameState.misunderstand(tongue, w2, String(wrong[w2]))


func _update_standing() -> void:
	if _region.is_empty():
		_standing_label.text = ""
		return
	# City standing, not regional. You arrive a stranger in each place and climb
	# separately; being practically a neighbour in Berlin buys nothing here.
	_standing_label.text = "— %s in %s —" % [
		GameState.city_rep_level(), GameState.city_name()]


func _close() -> void:
	hide()
	var discovery := get_tree().get_first_node_in_group("word_discovery")
	if discovery != null and discovery._open: discovery.close()
	_revealing = false
	_has_anim_words = false
	_animating_words.clear()
	_heard.clear()
	_timed = false
	if _patience_bar != null:
		_patience_bar.visible = false
	_tooltip.hide()
	# Said after the conversation rather than during it: this is not something
	# anybody tells him, it is something he works out on the way out.
	if not _after_thought.is_empty():
		var tb := get_tree().get_first_node_in_group("thought_box")
		if tb != null:
			tb.show_thought(_after_thought)
		_after_thought = ""
	get_tree().paused = false
	_hear_again.visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _revealing and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")
			or (event is InputEventMouseButton and event.pressed)):
		get_viewport().set_input_as_handled()
		_reveal_skip = true
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		# Stepping away mid-sentence: she stops talking too.
		AudioManager.stop_voice()
		_close()
	elif event.is_action_pressed("hear_again") and _hear_again.visible:
		get_viewport().set_input_as_handled()
		AudioManager.replay()


# ── Row / tag builders ────────────────────────────────────────────────────────

func _make_response_row(response: Dictionary, _idx: int) -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(0, 64)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _row_sb(false))
	wrap.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var ts: int = clampi(SaveManager.settings.get("text_size", 1), 0, TEXT_SIZES.size() - 1)

	# Not response["text"] — the option is phrased for what the player can
	# currently say, so the same intention reads as a gesture early on and as
	# a sentence once there are words for it. And the words it HAS learned are
	# spoken in the language rather than in English, which is what turns "some
	# of the dialogue options start to be actual sentences" into something you
	# can see happening a word at a time.
	var lbl := RichTextLabel.new()
	lbl.bbcode_enabled = true
	lbl.fit_content    = true
	lbl.scroll_active  = false
	var phrasing: String = GameState.phrase_for(response, _heard)
	lbl.text = phrasing if phrasing == String(response.get("gesture", "")) else _speak(phrasing)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	lbl.add_theme_font_size_override("normal_font_size", TEXT_SIZES[ts][1])
	lbl.add_theme_font_override("normal_font", UIStyles.reading_font)
	lbl.add_theme_color_override("default_color", Color(0.88, 0.86, 1.00))
	lbl.add_theme_constant_override("text_highlight_h_padding", 0)
	# The row's own button sits on top and takes the click; the label only has
	# to see the pointer, so a word can offer its guess.
	lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	lbl.meta_hover_started.connect(_on_word_hover_started)
	lbl.meta_hover_ended.connect(_on_word_hover_ended)
	lbl.meta_underlined = false
	hbox.add_child(lbl)

	var style_name: String = response.get("style", "")
	if not style_name.is_empty():
		hbox.add_child(_make_tag(style_name))

	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	for state in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	btn.mouse_entered.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(true)))
	btn.mouse_exited.connect(func():  panel.add_theme_stylebox_override("panel", _row_sb(false)))
	btn.focus_entered.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(true)))
	btn.focus_exited.connect(func(): panel.add_theme_stylebox_override("panel", _row_sb(false)))
	btn.pressed.connect(_on_response.bind(response))
	wrap.add_child(btn)

	return wrap


func _make_tag(style: String) -> Control:
	var c: Color = STYLE_COLORS.get(style, Color(0.4, 0.4, 0.6))
	var lbl := Label.new()
	lbl.text = style
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(
		minf(c.r + 0.45, 1.0), minf(c.g + 0.45, 1.0), minf(c.b + 0.45, 1.0)))

	var ctr := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(c.r * 0.25, c.g * 0.25, c.b * 0.25, 0.75)
	sb.border_color = Color(c.r, c.g, c.b, 0.85)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10; sb.content_margin_right  = 10
	sb.content_margin_top  = 4;  sb.content_margin_bottom = 4
	ctr.add_theme_stylebox_override("panel", sb)
	ctr.add_child(lbl)
	return ctr


# ── Style helpers ─────────────────────────────────────────────────────────────

func _row_sb(hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.16, 0.14, 0.30, 0.90) if hovered else Color(0.10, 0.09, 0.18, 0.78)
	sb.border_color = Color(0.50, 0.46, 0.78, 0.75) if hovered else Color(0.24, 0.22, 0.40, 0.38)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 18; sb.content_margin_right  = 16
	sb.content_margin_top  = 12; sb.content_margin_bottom = 12
	return sb


func _avatar_style(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(18)
	return sb


# ── Guess tooltip (hover over a recognised word) ──────────────────────────────

func _build_tooltip() -> void:
	_tooltip = PanelContainer.new()
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.050, 0.044, 0.115, 0.97)
	sb.border_color = Color(0.42, 0.38, 0.70, 0.65)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size  = 10
	sb.content_margin_left  = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top    = 8.0
	sb.content_margin_bottom = 8.0
	_tooltip.add_theme_stylebox_override("panel", sb)

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 2)
	_tooltip.add_child(col)

	_tooltip_word = Label.new()
	_tooltip_word.add_theme_font_size_override("font_size", 14)
	_tooltip_word.add_theme_color_override("font_color", Color(0.94, 0.92, 1.00))
	_tooltip_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_tooltip_word)

	_tooltip_guess = Label.new()
	_tooltip_guess.add_theme_font_size_override("font_size", 12)
	_tooltip_guess.add_theme_color_override("font_color", Color(0.55, 0.85, 0.72, 0.90))
	_tooltip_guess.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_tooltip_guess)

	_tooltip.hide()
	add_child(_tooltip)


func _on_word_hover_started(meta: Variant) -> void:
	var word := String(meta)
	var guess: String = GameState.word_guess(GameState.local_language(), word)
	if guess.is_empty():
		return
	_tooltip_word.text  = word.capitalize()
	if guess.begins_with("✓"):
		_tooltip_guess.text = "you worked out: " + guess.trim_prefix("✓ ")
	else:
		_tooltip_guess.text = "your guess: " + guess.trim_prefix("— ")
	_tooltip.reset_size()
	_position_tooltip()
	_tooltip.show()


func _on_word_hover_ended(_meta: Variant) -> void:
	_tooltip.hide()


func _position_tooltip() -> void:
	var mouse := _text_label.get_global_mouse_position()
	var vp := get_viewport().get_visible_rect().size
	var pos := mouse - Vector2(_tooltip.size.x * 0.5, _tooltip.size.y + 18.0)
	pos.x = clampf(pos.x, 8.0, vp.x - _tooltip.size.x - 8.0)
	if pos.y < 8.0:
		pos.y = mouse.y + 22.0
	_tooltip.position = pos


# ── Word rendering ────────────────────────────────────────────────────────────

func _render_words(words: Array) -> String:
	var parts: PackedStringArray = []
	for w in words:
		var lang: String     = w.get("language", "")
		var word_key: String = w.get("word", "")
		var tier     := GameState.get_tier(lang, word_key)
		var is_first := _animating_words.has(lang + ":" + word_key)
		# English is never glyphed. The alien has been surrounded by it since it
		# crashed and can read every word of London — that is the whole premise
		# of the second act, and glyphing it would make London a second Berlin.
		# What it cannot do is tell what those words are being used to mean.
		if lang == "english":
			parts.append(_render_english(w.get("text", ""), word_key, tier))
			continue
		# A word he worked out reads as letters in gold, however few times he
		# has heard it: finding out what it means is knowing it.
		if NOTEBOOK.found(lang, word_key):
			parts.append(_wrap_guess(word_key, "[color=%s]%s[/color]" % [FOUND_CLR, String(w.get("text", ""))]))
			continue
		# The word this exchange turns on is spelled out, whatever his tier:
		# he is about to act on a reading of it, and it is the spelling that
		# the meaning attaches to when the scene bears him out.
		if _targets.has(word_key.to_lower()):
			parts.append(_wrap_guess(word_key, "[color=%s]%s[/color]" % [
				TARGET_CLR, String(w.get("text", ""))]))
			continue
		parts.append(_render_word(w.get("text", ""), word_key, tier, is_first))
	return " ".join(parts)


# London. Always legible, but marked where the alien has worked out that a word
# is not doing what it appears to do. Every readable word shares the hover box.
# A learned one is additionally flagged as slippery, because
# knowing "alright" is a greeting is the actual progress in this city.
func _render_english(display: String, word: String, _tier: int) -> String:
	if not String(GameState.understanding("english", word).get("meaning", "")).is_empty():
		return _wrap_guess(word,
			"[color=#f0eeff]" + display + "[/color][color=#8ea2c8]°[/color]")
	return _wrap_guess(word, "[color=#dcd8f0]" + display + "[/color]")


func _render_word(display: String, word: String, tier: int, first_time: bool) -> String:
	var underline: bool = SaveManager.settings.get("highlight_partial_words", false)
	match tier:
		GameState.TIER_KNOWN:
			return _wrap_guess(word, "[color=#f0eeff]" + display + "[/color]")
		GameState.TIER_PARTIAL:
			if underline:
				return _wrap_guess(word, "[u][color=#d8d4ff]" + display + "[/color][/u]")
			return _wrap_guess(word, "[color=#d8d4ff]" + display + "[/color]")
		GameState.TIER_GLIMPSED:
			return "[color=#b8b4f0]" + _to_glyphs(word) + "[/color]"
		_:  # UNKNOWN
			if first_time:
				return "[color=#e8e4ff]" + _flicker_glyphs(word) + "[/color]"
			return "[color=#e8e4ff]" + _to_glyphs(word) + "[/color]"


# Every readable word keeps the same hover affordance, including confirmed
# meanings. Unknown glyphs never pass through here; hints do not reveal spelling.
func _wrap_guess(word: String, inner: String) -> String:
	if word.is_empty(): return inner
	return "[url=%s][bgcolor=%s] %s [/bgcolor][/url]" % [word, WORD_BG, inner]


func _to_glyphs(word: String) -> String:
	var g := GLYPHS_SIMPLE if SaveManager.settings.get("simplified_glyph_set", false) else GLYPHS_FULL
	var out := ""
	for i in range(word.length()):
		out += g[word.unicode_at(i) % g.length()]
	return out


# A word heard for the first time flickers, but in place. The symbols come from
# whichever fallback font has them and are all different widths, so a word that
# took any glyph at random changed width five times a second and shoved the
# rest of the line back and forth. Each letter now only ever swaps for a glyph
# drawn exactly as wide as the one it settles into, so neither the flicker nor
# the settling can move a word.
func _flicker_glyphs(word: String) -> String:
	var stable := _to_glyphs(word)
	var same: Dictionary = _same_width_glyphs()
	var out := ""
	for i in range(stable.length()):
		var pool: String = String(same.get(stable[i], stable[i]))
		out += pool[randi() % pool.length()]
	return out


var _width_cache: Dictionary = {}   # "glyph set|size" -> {glyph: glyphs as wide}


# Measured in the font and size the line is actually drawn in, because that is
# the only place the widths are true - they differ between machines. A glyph
# measured on its own comes back rounded and with its edges included, which
# put glyphs a fraction of a pixel apart in the same group; the advance it
# takes inside a line is what a hundred of them add over one.
func _same_width_glyphs() -> Dictionary:
	var g := GLYPHS_SIMPLE if SaveManager.settings.get("simplified_glyph_set", false) else GLYPHS_FULL
	var font: Font = _text_label.get_theme_font("normal_font")
	var size: int = _text_label.get_theme_font_size("normal_font_size")
	var key := "%s|%d" % [g, size]
	if _width_cache.has(key):
		return _width_cache[key]
	var by_width: Dictionary = {}
	for i in range(g.length()):
		var one: float = font.get_string_size(g[i], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var many: float = font.get_string_size(g[i].repeat(100), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var w: float = snappedf((many - one) / 99.0, 0.001)
		by_width[w] = String(by_width.get(w, "")) + g[i]
	var same: Dictionary = {}
	for w2: float in by_width:
		for ch: String in String(by_width[w2]):
			same[ch] = by_width[w2]
	_width_cache[key] = same
	return same
