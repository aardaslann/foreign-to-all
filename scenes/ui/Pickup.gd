extends CanvasLayer

# Getting something is an event.
#
# Shaped after the way Hollow Knight hands you an ability: the world stops, the
# thing lifts off the ground and hangs there, light goes out of it in rings,
# and only then are you told what you are holding. Nothing here is on a timer
# you cannot see - it holds until you press something, because the whole point
# is the word, and a word you did not finish reading is not a word you learned.
#
# What is different, and is the reason this exists at all: the card does not
# say what the object DOES. It says what it is CALLED here, and underneath it,
# what he thinks he is holding. Those two are frequently not the same thing.

signal finished

const GOLD  := Color(0.886, 0.706, 0.361)
const PAPER := Color(0.949, 0.914, 0.847)
const DIM   := Color(0.031, 0.027, 0.063)

# The beats, in seconds from the start.
const T_LIFT  := 0.18     # it starts to rise
const T_BURST := 0.62     # light goes out of it
const T_WORD  := 0.86     # the word lands
const T_READ  := 1.24     # what he thinks it is
const T_INPUT := 1.45     # the earliest he may dismiss it

# Read by Inventory: while this is up, the corner toast stays down, because
# the card IS the notification and two of them is a mess.
var showing: bool = false

var _open: bool = false
var _t: float = 0.0
var _item: String = ""
var _word: String = ""

var _root: Control
var _canvas: Control
var _word_lbl: Label
var _trans_lbl: Label
var _lang_lbl: Label
var _read_lbl: Label
var _hint: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 14
	add_to_group("pickup")
	_build()
	_root.hide()


# `keep` is false for a thing that is not an object you carry. Money is the
# case that matters: he finds a pouch of coins in the grass in the first two
# minutes of the game, and the card is how he is told what the stuff is
# CALLED. It should not then appear in his belongings as an item named
# "Money" - it goes in his pocket, which is the HUD, and the word goes in the
# journal, which is the point.
func play(item: String, keep: bool = true) -> void:
	if _open:
		return
	_item = item
	_word = Items.word_for(item)
	var lang: String = GameState.local_language()
	var key: String = lang + ":" + item
	var revealed: Dictionary = GameState.world_flags.get("pickup_reveals", {})
	if revealed.has(key):
		# Inventory supplies the small object toast; repeated finds never pause.
		if keep: GameState.add_item(item)
		Items.learn(item)
		finished.emit.call_deferred()
		return
	_open = true
	showing = true
	_t = 0.0

	# The world state changes now, not at the end: he is holding it while he
	# looks at it. The journal entry lands with the word on screen.
	if keep:
		GameState.add_item(item)
	Items.learn(item)
	# This card explicitly pairs a visible object and its translated name.
	# Ordinary exposure through Items.learn must not grant this evidence.
	if not _word.is_empty() and GameState.understanding(lang, _word).get("meaning", "").is_empty():
		GameState.understand(lang, _word, Items.display_name(item).to_lower(),
			"Held the " + Items.display_name(item).to_lower() + " and read its name.")
	revealed[key] = true
	GameState.world_flags["pickup_reveals"] = revealed
	var mine: String = Items.translated_name(item)
	if _word.is_empty():
		_word_lbl.text = mine
		_trans_lbl.text = ""
		_lang_lbl.text = tr("pick.noword")
	else:
		_word_lbl.text = _word
		# The same thing in the player's own language, dimmer, so which is
		# which is never in doubt. Hidden when they are the same word.
		_trans_lbl.text = "" if mine.to_lower() == _word.to_lower() else mine
		_lang_lbl.text = lang.replace("_", " ")
	_read_lbl.text = Items.reading(item)
	_hint.text = "[%s]  Continue" % Controls.label_for("interact")

	_root.show()
	get_tree().paused = true


func _process(delta: float) -> void:
	if not _open:
		return
	_t += delta
	_word_lbl.modulate.a = _fade(T_WORD, 0.30)
	_trans_lbl.modulate.a = _fade(T_WORD + 0.16, 0.34) * 0.62
	_lang_lbl.modulate.a = _fade(T_WORD + 0.12, 0.30) * 0.75
	_read_lbl.modulate.a = _fade(T_READ, 0.40)
	_hint.modulate.a = _fade(T_INPUT + 0.35, 0.5) * 0.8
	_canvas.queue_redraw()


func _fade(at: float, over: float) -> float:
	return clampf((_t - at) / maxf(over, 0.01), 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _open or _t < T_INPUT:
		return
	var go: bool = event.is_action_pressed("ui_accept") \
		or event.is_action_pressed("interact") \
		or event.is_action_pressed("ui_cancel")
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		go = go or (mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT)
	if go:
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	if not _open:
		return
	_open = false
	showing = false
	_root.hide()
	get_tree().paused = false
	SaveManager.checkpoint()
	finished.emit()


# ── Drawing ───────────────────────────────────────────────────────────────────

func _draw_stage() -> void:
	var w: float = _canvas.size.x
	var h: float = _canvas.size.y
	var cx: float = w * 0.5
	var floor_y: float = h * 0.52
	var rest_y: float = h * 0.30

	# The world goes back, not out. Enough to stop being able to read the
	# street behind it, never so much that he stops standing somewhere.
	_canvas.draw_rect(Rect2(0.0, 0.0, w, h),
		Color(DIM.r, DIM.g, DIM.b, 0.80 * _fade(0.0, 0.22)))

	# It rises out of the floor and holds, easing out so the stop is soft.
	var lift: float = clampf((_t - T_LIFT) / 0.44, 0.0, 1.0)
	lift = 1.0 - pow(1.0 - lift, 3.0)
	var y: float = lerpf(floor_y, rest_y, lift)

	# Light going out of it, in rings, in his own gold. Three, staggered, each
	# expanding and thinning - one ring reads as a bubble, three read as a
	# pulse.
	for i in range(3):
		var at: float = _t - T_BURST - float(i) * 0.09
		if at <= 0.0 or at > 1.1:
			continue
		var k: float = at / 1.1
		_canvas.draw_arc(Vector2(cx, y), 30.0 + k * 340.0, 0.0, TAU, 72,
			Color(GOLD.r, GOLD.g, GOLD.b, (1.0 - k) * 0.55), 3.5 - k * 2.6, true)
	# And a flash on the frame at the moment it goes.
	var flash: float = clampf(1.0 - absf(_t - T_BURST) / 0.16, 0.0, 1.0)
	if flash > 0.0:
		_canvas.draw_rect(Rect2(0.0, 0.0, w, h),
			Color(GOLD.r, GOLD.g, GOLD.b, flash * 0.18))

	# A held glow behind the object so it never sits on the dark unlit.
	for i in range(6):
		var f: float = 1.0 - float(i) / 6.0
		_canvas.draw_circle(Vector2(cx, y), 26.0 + f * 52.0,
			Color(GOLD.r, GOLD.g, GOLD.b, 0.05 * _fade(T_LIFT, 0.4)))

	# The object, the same one that was lying on the pavement, held up.
	Items.draw_item(_canvas, Vector2(cx, y), h / 108.0, _item)

	# A rule under the word, drawn out from the middle as the word arrives.
	var rule: float = _fade(T_WORD + 0.06, 0.42)
	if rule > 0.0:
		var half: float = 210.0 * rule
		_canvas.draw_rect(Rect2(cx - half, h * 0.628, half * 2.0, 1.0),
			Color(GOLD.r, GOLD.g, GOLD.b, 0.45 * rule))


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_stage)
	_root.add_child(_canvas)

	_word_lbl = _label(56, PAPER, 0.545, 0.635)
	_word_lbl.add_theme_constant_override("outline_size", 7)
	_word_lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 0.9))
	_trans_lbl = _label(26, Color(0.58, 0.56, 0.68), 0.638, 0.690)
	_lang_lbl = _label(15, GOLD, 0.700, 0.742)
	_read_lbl = _label(21, Color(0.71, 0.68, 0.83), 0.756, 0.88)
	_read_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_read_lbl.offset_left = 300.0
	_read_lbl.offset_right = -300.0

	_hint = _label(13, Color(0.54, 0.52, 0.70), 0.90, 0.95)
	_hint.text = tr("name.hint")


# One centred band of text between two fractions of the screen height.
func _label(size: int, col: Color, top: float, bottom: float) -> Label:
	var l := Label.new()
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.anchor_top = top
	l.anchor_bottom = bottom
	l.offset_top = 0.0
	l.offset_bottom = 0.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.modulate.a = 0.0
	_root.add_child(l)
	return l
