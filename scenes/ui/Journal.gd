extends CanvasLayer

const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")

const GLYPHS_FULL   := "◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡"
const GLYPHS_SIMPLE := "▲▼●■◆★▸◀▴▾"

const BG_COLOR := Color(0.055, 0.048, 0.118, 0.98)
const BDR_CLR  := Color(0.30, 0.28, 0.50, 0.55)

const TIER_CLR := [
	Color(0.38, 0.36, 0.68),   # unknown
	Color(0.55, 0.52, 0.88),   # glimpsed
	Color(0.28, 0.72, 0.62),   # partial
	Color(0.24, 0.96, 0.80),   # familiar
]
const TIER_NAMES := ["half-caught", "glimpsed", "partial", "familiar"]
const WORD_CLR := [
	Color(0.58, 0.54, 0.86),   # unknown  — glyph color
	Color(0.70, 0.66, 0.95),   # glimpsed — glyph color
	Color(0.84, 0.82, 1.00),   # partial
	Color(0.95, 0.93, 1.00),   # familiar
]

# Word meaning guesses live in autoload/Guesses.gd and GuessesWorld.gd, reached
# through GameState.word_guess(language, word) - one notebook per language, all
# sixteen of them, and this panel shows every notebook the player has written
# anything in. Shared with the dialogue box, which shows the same guesses as
# hover tooltips over recognised words.

# _ui_root is a full-viewport Control added directly to the CanvasLayer.
# The HUD button lives in the shared HudBar layer, which opens this overlay
# via the "journal" group.
var _ui_root:    Control
var _panel_root: Control
var _word_list:  VBoxContainer
var _subtitle:   Label
var _page := "Words"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("journal")
	_ui_root = $UIRoot
	_build_ui()
	GameState.word_tier_changed.connect(_on_word_tier_changed)


func _process(delta: float) -> void:
	_update_toasts(delta)


func open_from_hud() -> void:
	if not _panel_root.visible and not get_tree().paused:
		_open()


func _unhandled_input(event: InputEvent) -> void:
	# Actions rather than keycodes, so this opens on a controller and on
	# whatever the player has rebound it to. The InputEventKey guard goes with
	# them: a pad button is not one.
	if event.is_action_pressed("journal"):
		get_viewport().set_input_as_handled()
		if _panel_root.visible:
			_close()
		elif not get_tree().paused:
			_open()
	elif event.is_action_pressed("back") and _panel_root.visible:
		get_viewport().set_input_as_handled()
		_close()


func _open() -> void:
	_populate()
	_panel_root.show()
	get_tree().paused = true


func _close() -> void:
	_panel_root.hide()
	get_tree().paused = false


# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	# _ui_root is the UIRoot Control node defined in Journal.tscn — already sized to viewport.

	# ── Journal overlay (hidden until opened) ─────────────────────────────────
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
	panel.anchor_left   = 0.07; panel.anchor_right  = 0.93
	panel.anchor_top    = 0.05; panel.anchor_bottom = 0.95
	var sb := StyleBoxFlat.new()
	sb.bg_color     = BG_COLOR
	sb.border_color = BDR_CLR
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0, 0, 0, 0.50)
	sb.shadow_size  = 20
	panel.add_theme_stylebox_override("panel", sb)
	_panel_root.add_child(panel)

	var outer := MarginContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	var margins := {"left": 52, "right": 52, "top": 38, "bottom": 34}
	for k: String in margins:
		outer.add_theme_constant_override("margin_" + k, margins[k])
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	outer.add_child(vbox)

	vbox.add_child(_build_header())
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 12)
	for page: String in ["Words", "Journey", "Phrases", "Memories", "History"]:
		var tab := Button.new()
		tab.text = page
		UIStyles.style_menu_btn(tab)
		tab.pressed.connect(func():
			_page = page
			_populate())
		tabs.add_child(tab)
	vbox.add_child(tabs)
	vbox.add_child(_build_subtitle_row())
	vbox.add_child(_build_divider())
	vbox.add_child(_build_scroll())
	vbox.add_child(_build_footer())

	_panel_root.hide()


func _build_header() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var deco := Label.new()
	deco.text = "◈⟟  "
	deco.add_theme_font_size_override("font_size", 20)
	deco.add_theme_color_override("font_color", Color(0.55, 0.52, 0.85, 0.55))
	deco.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(deco)

	var title := Label.new()
	title.text = tr("jr.title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 1.00))
	hbox.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "×  close"
	close_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UIStyles.style_menu_btn(close_btn)
	close_btn.pressed.connect(_close)
	hbox.add_child(close_btn)

	return hbox


func _build_subtitle_row() -> Control:
	_subtitle = Label.new()
	_subtitle.text = ""
	_subtitle.add_theme_font_size_override("font_size", 14)
	_subtitle.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.78))
	return _subtitle


func _build_divider() -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	var line := ColorRect.new()
	line.color = Color(0.28, 0.26, 0.46, 0.40)
	line.custom_minimum_size = Vector2(0, 1)
	margin.add_child(line)
	return margin


func _build_scroll() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	_word_list = VBoxContainer.new()
	_word_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_list.add_theme_constant_override("separation", 5)
	scroll.add_child(_word_list)

	return scroll


func _build_footer() -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 8)
	var lbl := Label.new()
	lbl.text = "J  ·  Esc — " + tr("jr.close")
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.36, 0.34, 0.58, 0.55))
	margin.add_child(lbl)
	return margin


# ── Word tier-up toasts ───────────────────────────────────────────────────────

const TOAST_LIFE := 4.2    # seconds on screen
const TOAST_FADE := 0.55   # fade-out portion at the end

var _toasts: Array = []    # [{ "p": PanelContainer, "age": float }]


# Every language, not only German. This filter is the reason a player who
# learned a word in Istanbul got no notification that they had: the toast was
# written when the game had one city and never revisited when it got twenty.
#
# Only moments that mean something get one. A tier change from passive hearing -
# every "die" said within earshot - used to announce itself, and a notification
# for everything is a notification for nothing: the player learns to ignore the
# corner of the screen, and with it the words. What is left is a word he has
# engaged with getting stronger, a word he worked out, and a word he worked out
# coming back to him somewhere new (scenes/ui/Notebook.gd).
func _on_word_tier_changed(language: String, word: String, new_tier: int) -> void:
	for director in get_tree().get_nodes_in_group("story_director"):
		if director.running():
			return # Watch the acted consequence; the notebook still records it.
	if not NOTEBOOK.noticed(language, word) or NOTEBOOK.found(language, word):
		return
	var titles := ["Noticed", "Noticed", "Sound becoming familiar", "Recognised by ear"]
	_toast("%s — %s" % [titles[new_tier], word.capitalize()],
		GameState.word_guess(language, word).trim_prefix("— "), TIER_CLR[new_tier])


func toast_understood(language: String, word: String, meaning: String) -> void:
	_toast("Worked out — " + word.capitalize(), meaning, FOUND_CLR)


# Throttled: a street can say "Kaffee" four times in a minute, and the second
# meeting is the one worth marking, not the fifth.
var _recognised_at: Dictionary = {}
var _last_recognition: float = -99.0


func toast_recognised(language: String, word: String) -> void:
	var now: float = GameState.play_time
	var key: String = language + ":" + word
	if now - _last_recognition < 4.0 or now - float(_recognised_at.get(key, -999.0)) < 90.0:
		return
	_last_recognition = now
	_recognised_at[key] = now
	_toast("Recognised — " + word.capitalize(), NOTEBOOK.meaning(language, word), FOUND_CLR)


const FOUND_CLR := Color(0.953, 0.835, 0.541)
# Fixed, and given to the text as well as the panel. A word-wrapping label with
# no width of its own is laid out at zero and wraps after every letter, which
# is how a two-line notification became a panel the height of the screen.
const TOAST_W := 320.0
const TOAST_TEXT_W := TOAST_W - 30.0   # 14px margins and a 1px border each side


func _toast(title_text: String, sub_text: String, tc: Color) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(TOAST_W, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(0.055, 0.048, 0.120, 0.96)
	sb.border_color = Color(tc.r, tc.g, tc.b, 0.55)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(9)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size  = 8
	panel.add_theme_stylebox_override("panel", sb)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left",   14)
	margin.add_theme_constant_override("margin_right",  14)
	margin.add_theme_constant_override("margin_top",     9)
	margin.add_theme_constant_override("margin_bottom",  9)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = title_text
	title.custom_minimum_size.x = TOAST_TEXT_W
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.94, 0.92, 1.00))
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = sub_text
	sub.custom_minimum_size.x = TOAST_TEXT_W
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.max_lines_visible = 2
	sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sub.add_theme_font_size_override("font_size", 12)
	var sub_c: Color = tc
	sub_c.a = 0.75
	sub.add_theme_color_override("font_color", sub_c)
	vbox.add_child(sub)

	panel.modulate.a = 0.0
	_ui_root.add_child(panel)
	_toasts.append({"p": panel, "age": 0.0})

	# Keep the stack short — drop the oldest if it gets crowded
	while _toasts.size() > 2:
		var old: Dictionary = _toasts.pop_front()
		(old["p"] as PanelContainer).queue_free()


func _update_toasts(delta: float) -> void:
	var dialogue := get_tree().get_first_node_in_group("dialogue_box")
	var covered: bool = get_tree().paused or (dialogue != null and dialogue.visible)
	for toast: Dictionary in _toasts:
		(toast["p"] as PanelContainer).visible = not covered
	if covered:
		return
	for i in range(_toasts.size() - 1, -1, -1):
		_toasts[i]["age"] = float(_toasts[i]["age"]) + delta
		if float(_toasts[i]["age"]) >= TOAST_LIFE:
			(_toasts[i]["p"] as PanelContainer).queue_free()
			_toasts.remove_at(i)

	# Stack below the HUD button, sliding in from the right
	var y := 64.0
	for t in _toasts:
		var p: PanelContainer = t["p"]
		var age: float = t["age"]
		var slide := minf(1.0, age / 0.25)
		slide = 1.0 - pow(1.0 - slide, 3.0)   # ease-out
		var fade_out := clampf((TOAST_LIFE - age) / TOAST_FADE, 0.0, 1.0)
		p.modulate.a = minf(slide, fade_out)
		# Never wider than it was built, and never off the left of the screen,
		# whatever a label decided about its size this frame.
		p.size = Vector2(TOAST_W, minf(p.size.y, 96.0))
		p.position = Vector2(maxf(8.0,
			_ui_root.size.x - TOAST_W - 14.0 + (1.0 - slide) * 46.0), y)
		y += p.size.y + 8.0


# ── Population ────────────────────────────────────────────────────────────────

func _populate() -> void:
	for child in _word_list.get_children():
		_word_list.remove_child(child)
		child.queue_free()
	if _page != "Words":
		_populate_journey()
		return

	# Every language the player has heard anything in, the one outside the
	# window first. It used to read GameState.familiarity["german"] and nothing
	# else, so a player in Istanbul who had spent an hour learning Turkish
	# opened this and was told they had discovered no words - the words were
	# all there, in a language the panel never looked at.
	var langs: Array = _languages()
	if langs.is_empty():
		_word_list.add_child(_empty_note(tr("jr.empty")))
		_subtitle.text = tr("jr.empty")
		return

	# Sorted by what he DID with each word, not by how often it went past him
	# (scenes/ui/Notebook.gd). The words he worked out come first and get the
	# whole row - meaning, first guess, the moment, how often he has recognised
	# it since, and its sound. Words he only overheard are one line at the end.
	var found_n: int = 0
	var noticed_n: int = 0
	var ear_n: int = 0
	for lang: String in langs:
		var s: Dictionary = NOTEBOOK.sections(lang)
		var engaged: int = s["found"].size() + s["noticed"].size()
		if engaged + s["by_ear"].size() + int(s["sounds"]) == 0:
			continue
		found_n += s["found"].size()
		noticed_n += s["noticed"].size()
		ear_n += s["by_ear"].size()
		_word_list.add_child(_language_header(lang, engaged))
		if not s["found"].is_empty():
			_word_list.add_child(_group_header("WORKED OUT", s["found"].size(), FOUND_CLR))
			for entry: Dictionary in s["found"]:
				_word_list.add_child(_word_row(lang, String(entry["word"]), int(entry["score"]),
					GameState.get_tier(lang, String(entry["word"]))))
		if not s["noticed"].is_empty():
			_word_list.add_child(_group_header("NOTICED - STILL WORKING THESE OUT",
				s["noticed"].size(), TIER_CLR[2]))
			for entry2: Dictionary in s["noticed"]:
				_word_list.add_child(_word_row(lang, String(entry2["word"]), int(entry2["score"]),
					GameState.get_tier(lang, String(entry2["word"]))))
		if not s["by_ear"].is_empty():
			_word_list.add_child(_group_header("PICKED UP BY EAR", s["by_ear"].size(), TIER_CLR[1]))
			var heard: PackedStringArray = []
			for entry3: Dictionary in s["by_ear"]:
				heard.append(String(entry3["word"]))
			_word_list.add_child(_ear_line(", ".join(heard)))
		if int(s["sounds"]) > 0:
			_word_list.add_child(_ear_line("...and %d more sounds you have caught but cannot pin down yet. A word becomes yours when you act on a guess about it, say it, or are shown it." % int(s["sounds"])))

	if found_n + noticed_n + ear_n == 0:
		_word_list.add_child(_empty_note(tr("jr.listen")))
		_subtitle.text = tr("jr.empty")
		return
	_subtitle.text = "%d worked out  ·  %d noticed  ·  %d by ear" % [found_n, noticed_n, ear_n]


func _group_header(text: String, count: int, tc: Color) -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 4)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)
	var dot := ColorRect.new()
	dot.color = tc
	dot.custom_minimum_size = Vector2(8, 8)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(dot)
	var lbl := Label.new()
	lbl.text = "%s  (%d)" % [text, count]
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", tc.lightened(0.08))
	hbox.add_child(lbl)
	var line := ColorRect.new()
	line.color = Color(tc.r, tc.g, tc.b, 0.18)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(line)
	return margin


func _ear_line(text: String) -> Control:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(600, 0)
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.62, 0.60, 0.86, 0.80))
	return lbl


# The language of the city you are standing in comes first, because that is
# the one you are working on. Everything else follows in the order it was met.
func _populate_journey() -> void:
	var ledger: Dictionary = Journey.ledger()
	_subtitle.text = "Your journey · " + Journey.VERSION + " · Story milestones and choices are checkpointed. Manual save slots stay separate."
	match _page:
		"Journey":
			_journey_card("Take your time", "Your allowance covers essential purchases. You still ask for the room or choose the ticket; work is optional. Point, ask for help, and try the words. There are no fluency or money gates between the eight cities.\n\nFollow the intention for your local friend and explore at your own pace. Berlin's story continues after resting at the hotel. Escape leaves story scenes ready to resume from their last milestone.\n\nBeta feedback is in the pause menu. Playtime notes are optional and stay on your computer.")
			var refill := Button.new()
			refill.text = "Top up pocket money · optional shopping, no work required"
			UIStyles.style_menu_btn(refill)
			refill.pressed.connect(func():
				Journey.refill_pocket()
				refill.text = "Pocket money ready · " + GameState.symbol() + str(GameState.money))
			_word_list.add_child(refill)
			for city: String in Story.MANDATORY:
				var status: String = "Celebration shared" if Story.holiday_seen(city) else "%d / 3 shared conversations" % mini(Story.rounds_done(city), 3)
				_journey_card(String(GameState.CITIES[city]["name"]) + " · " + Story.person_name(city), status + "\n" + Journey.next_step(city))
			if Story.can_end():
				_journey_card("A name, when you are ready", "Return to the field outside Berlin and ask one of your friends to name you. Your memories may help you choose.")
		"Phrases":
			var discoveries: int = 0
			for language: String in GameState.world_flags.get("understood", {}):
				for phrase: String in GameState.world_flags["understood"][language]:
					var found: Dictionary = GameState.understanding(language, phrase)
					if String(found.get("meaning", "")).is_empty():
						continue
					var context: String = String(found.get("moment", ""))
					var first: String = String(found.get("first", ""))
					var detail: String = String(found["meaning"])
					if not String(found.get("reflection", "")).is_empty():
						detail += "\nMy reading: " + String(found.reflection)
					if not first.is_empty():
						detail += "\nAt first I thought: " + first
					if not context.is_empty():
						detail += "\nFound out: " + context
					_journey_card(phrase + " · " + language.capitalize(), detail)
					discoveries += 1
			for phrase: Dictionary in ledger["phrases"].values():
				var text: String = String(phrase["reading"])
				if text == phrase["native"]:
					text = ""
				_journey_card(String(phrase["native"]), text + "\n" + String(phrase["meaning"]) + "\n" + Story.person_name(phrase["city"]) + " · " + String(GameState.CITIES[phrase["city"]]["name"]))
			if Dictionary(ledger["phrases"]).is_empty() and discoveries == 0:
				_journey_card("A phrase belongs to a moment", "Meanings appear here after you find them out with someone. Your first guess and the moment that changed it stay together.")
		"Memories":
			for city: String in Story.MANDATORY:
				if ledger["memories"].has(city):
					_journey_card(Story.person_name(city), String(ledger["memories"][city]))
			if Dictionary(ledger["memories"]).is_empty():
				_journey_card("People, not rules", "Shared moments will be remembered here. These are observations about people you meet, not instructions for an entire country.")
		"History":
			var history: Array = ledger["history"].duplicate()
			history.reverse()
			for entry: Dictionary in history:
				_journey_card(String(entry["title"]), String(entry["text"]))
			if history.is_empty():
				_journey_card("Nothing to catch up on yet", "Your recent conversations, chosen responses and activity decisions will appear here.")


func _journey_card(title: String, text: String) -> void:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.09, 0.18)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	var heading := Label.new()
	heading.add_theme_font_override("font", UIStyles.reading_font)
	heading.text = title
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_theme_font_size_override("font_size", 25)
	heading.add_theme_color_override("font_color", Color(0.43, 0.89, 0.77))
	box.add_child(heading)
	var body := Label.new()
	body.add_theme_font_override("font", UIStyles.reading_font)
	body.text = text.strip_edges()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", [18, 22, 26][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)])
	body.add_theme_color_override("font_color", Color(0.91, 0.90, 0.98))
	box.add_child(body)
	_word_list.add_child(panel)


func _languages() -> Array:
	var here: String = GameState.local_language()
	var out: Array = []
	if GameState.familiarity.has(here):
		out.append(here)
	for lang: String in GameState.familiarity.keys():
		if lang != here and not Dictionary(GameState.familiarity[lang]).is_empty():
			out.append(lang)
	return out


func _empty_note(text: String) -> Control:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.44, 0.42, 0.68, 0.65))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl


# Which notebook this section is. The journal holds all of them now, so it has
# to say which page you are looking at.
const LANG_NAMES := {
	"german": "German", "swissgerman": "Swiss German", "english": "English",
	"french": "French", "italian": "Italian", "russian": "Russian",
	"turkish": "Turkish", "japanese": "Japanese", "korean": "Korean",
	"hindi": "Hindi", "vietnamese": "Vietnamese", "wolof": "Wolof",
	"georgian": "Georgian", "spanish_mx": "Spanish", "spanish_bo": "Spanish",
	"portuguese": "Portuguese",
}


func _language_header(lang: String, count: int) -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 2)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var lbl := Label.new()
	var name_of: String = String(LANG_NAMES.get(lang, lang.capitalize()))
	if lang == GameState.local_language():
		name_of += "   —   spoken here"
	lbl.text = name_of
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color(0.95, 0.93, 1.00))
	hbox.add_child(lbl)

	var n := Label.new()
	n.text = "%d" % count
	n.add_theme_font_size_override("font_size", 14)
	n.add_theme_color_override("font_color", Color(0.55, 0.52, 0.85, 0.70))
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(n)

	var line := ColorRect.new()
	line.color = Color(0.55, 0.52, 0.85, 0.30)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(line)
	return margin


# ── Widget builders ───────────────────────────────────────────────────────────

func _section_header(tier: int, count: int) -> Control:
	var tc: Color = TIER_CLR[tier]
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top",    18)
	margin.add_theme_constant_override("margin_bottom",  4)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	margin.add_child(hbox)

	var dot := ColorRect.new()
	dot.color = tc
	dot.custom_minimum_size = Vector2(8, 8)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(dot)

	var lbl := Label.new()
	lbl.text = "%s  (%d)" % [TIER_NAMES[tier].to_upper(), count]
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", tc.lightened(0.08))
	hbox.add_child(lbl)

	var line := ColorRect.new()
	line.color = Color(tc.r, tc.g, tc.b, 0.18)
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.size_flags_vertical   = Control.SIZE_SHRINK_CENTER
	hbox.add_child(line)

	return margin


# One word, in one language, at whatever tier it has reached.
#
# The two things that changed: it takes the language rather than assuming
# German, and the guess is shown at EVERY tier. A half-caught word with no
# guess under it is a progress bar with a smudge over it, and the guess is the
# only part of this panel that is actually the game.
func _word_row(lang: String, word: String, score: int, tier: int) -> Control:
	var tc: Color = TIER_CLR[tier]
	var body_size: int = [18, 22, 26][clampi(int(SaveManager.settings.get("text_size", 1)), 0, 2)]

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color     = Color(tc.r * 0.13, tc.g * 0.13, tc.b * 0.13, 0.82)
	sb.border_color = Color(tc.r, tc.g, tc.b, 0.20)
	sb.border_width_left = 1; sb.border_width_right  = 1
	sb.border_width_top  = 1; sb.border_width_bottom = 1
	sb.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", sb)

	var margin := MarginContainer.new()
	panel.add_child(margin)
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_bottom", 12)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	var stripe := ColorRect.new()
	stripe.color = tc
	stripe.custom_minimum_size = Vector2(3, 0)
	stripe.size_flags_vertical  = Control.SIZE_FILL
	hbox.add_child(stripe)

	var word_col := VBoxContainer.new()
	word_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_col.alignment = BoxContainer.ALIGNMENT_CENTER
	word_col.add_theme_constant_override("separation", 2)
	hbox.add_child(word_col)

	# The word as he wrote it down. Glyphs are how an unlearned word LOOKS
	# when somebody says it; this is his own notebook, and a word he did not
	# catch well enough to write would not be in it at all.
	var wlbl := Label.new()
	wlbl.add_theme_font_size_override("font_size", body_size + 3)
	wlbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wlbl.add_theme_color_override("font_color", WORD_CLR[tier])
	wlbl.text = word.capitalize()
	word_col.add_child(wlbl)

	var guess: String = GameState.word_guess(lang, word)
	if guess.is_empty():
		# Every word the game teaches has one, so an empty guess means a word
		# reached the journal by a route nothing has written a guess for.
		# Saying so is better than a blank line under it.
		guess = "— no idea yet"
	var glbl := Label.new()
	glbl.text = guess
	var discovery: Dictionary = GameState.understanding(lang, word)
	if not String(discovery.get("reflection", "")).is_empty():
		glbl.text += "\nMy reading: " + String(discovery.reflection)
	if not String(discovery.get("meaning", "")).is_empty():
		var first: String = String(discovery.get("first", ""))
		if not first.is_empty():
			glbl.text += "\nAt first: " + first
		var moment: String = String(discovery.get("moment", ""))
		if not moment.is_empty():
			glbl.text += "\nFound out: " + moment
	var times: int = NOTEBOOK.recalled(lang, word)
	for memory: String in discovery.get("applications", {}).values():
		glbl.text += "\nUsed elsewhere: " + memory
	if times > 0:
		glbl.text += "\nRecognised again %d time%s" % [times, "" if times == 1 else "s"]
	glbl.add_theme_font_size_override("font_size", body_size)
	glbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var gc: Color = FOUND_CLR if NOTEBOOK.found(lang, word) else tc
	gc.a = 0.94 if NOTEBOOK.found(lang, word) else 0.85
	glbl.add_theme_color_override("font_color", gc)
	word_col.add_child(glbl)

	# Its sound. The notebook is where he goes back to a word, and a word you
	# can hear again is one you can say.
	if AudioManager.has_word(lang, word):
		var play := Button.new()
		play.text = "▶"
		play.tooltip_text = "Hear it"
		play.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		UIStyles.style_menu_btn(play)
		play.pressed.connect(func(): AudioManager.say_word(lang, word))
		hbox.add_child(play)

	var evidence := Label.new()
	evidence.text = NOTEBOOK.evidence_label(lang, word)
	evidence.add_theme_font_size_override("font_size", body_size - 2)
	evidence.add_theme_color_override("font_color", FOUND_CLR if NOTEBOOK.found(lang, word) else tc)
	word_col.add_child(evidence)

	return panel


# ── Glyph helpers (mirrors DialogueBox._to_glyphs) ───────────────────────────

func _to_glyphs(word: String) -> String:
	var g := GLYPHS_SIMPLE if SaveManager.settings.get("simplified_glyph_set", false) else GLYPHS_FULL
	var out := ""
	for i in range(word.length()):
		out += g[word.unicode_at(i) % g.length()]
	return out
