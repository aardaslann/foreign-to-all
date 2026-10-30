extends CanvasLayer

# The reputation feedback card.
#
# Reputation used to be entirely invisible — the number moved and the player was
# expected to infer it from an NPC's tone three conversations later. In a game
# about whether you said the right thing, that is the one piece of information
# worth being explicit about. So: a card, immediately, saying what the choice
# read as and what it cost or earned.
#
# It never shows the raw number. It shows the SHAPE of the change and, when it
# matters, the fact that your standing in this city just moved. The number stays
# hidden because "+3" is bookkeeping and "she warmed to that" is a story.

# Seconds fully visible before it starts leaving. 3.2 was not long enough to
# read a two-line card AND look at what it says about your standing, which is
# the only feedback the game gives about a choice you just made; 6.4 outstayed
# it once the card actually held (see _play).
const HOLD := 4.5
const SLIDE := 0.34

# What the register was, in the player's terms rather than the data's
const STYLE_READS := {
	"formal":   "you were formal",
	"casual":   "you were casual",
	"direct":   "you were direct",
	"indirect": "you left it unsaid",
	"gesture":  "you used your hands",
}

const C_GOOD := Color(0.30, 0.82, 0.60)
const C_BAD  := Color(0.92, 0.42, 0.38)
const C_FLAT := Color(0.58, 0.58, 0.72)

var _card:     PanelContainer
var _arrow:    Label
var _headline: Label
var _detail:   Label
var _standing: Label
var _bar:      ColorRect
var _tween:    Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 60          # above the dialogue panel, below transitions
	add_to_group("rep_toast")
	_build()
	_card.modulate.a = 0.0
	_card.hide()


func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_card = PanelContainer.new()
	_card.anchor_left = 1.0
	_card.anchor_right = 1.0
	_card.offset_left = -392.0
	_card.offset_right = -28.0
	_card.offset_top = 34.0
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.075, 0.068, 0.135, 0.97)
	sb.border_color = Color(0.34, 0.32, 0.54, 0.60)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 18
	sb.shadow_offset = Vector2(0, 6)
	sb.content_margin_left = 0.0
	sb.content_margin_right = 18.0
	sb.content_margin_top = 14.0
	sb.content_margin_bottom = 14.0
	_card.add_theme_stylebox_override("panel", sb)
	root.add_child(_card)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_card.add_child(row)

	# A colour bar down the left edge does the emotional work before any
	# reading happens — you know if it went well before you know why.
	_bar = ColorRect.new()
	_bar.custom_minimum_size = Vector2(4, 0)
	_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(_bar)

	_arrow = Label.new()
	_arrow.custom_minimum_size = Vector2(34, 0)
	_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_arrow.add_theme_font_size_override("font_size", 21)
	row.add_child(_arrow)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 3)
	row.add_child(col)

	_headline = Label.new()
	_headline.add_theme_font_size_override("font_size", 15)
	col.add_child(_headline)

	_detail = Label.new()
	_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_theme_font_size_override("font_size", 12)
	_detail.add_theme_color_override("font_color", Color(0.66, 0.64, 0.86, 0.85))
	col.add_child(_detail)

	# Only appears when the change actually crossed a threshold. A card that
	# announced your standing every time would make the ladder meaningless.
	_standing = Label.new()
	_standing.add_theme_font_size_override("font_size", 12)
	_standing.add_theme_color_override("font_color", Color(0.92, 0.86, 0.58))
	_standing.hide()
	col.add_child(_standing)


# delta: the reputation change. style: the register the player used.
# who: the NPC's name, for a line that reads like a person reacted.
# `before` is the standing as it was BEFORE the caller applied the change. It has
# to be passed in: by the time this runs the number has already moved, so reading
# the level here would compare a value against itself and never report a crossing.
func show_change(delta: int, style: String, who: String, region: String,
		before: String, note: String = "") -> void:
	var col: Color = C_FLAT
	var arrow: String = "="
	var head: String = "that landed flat"

	if delta >= 3:
		col = C_GOOD
		arrow = "▲▲"
		head = "%s warmed to that" % (who if not who.is_empty() else "they")
	elif delta > 0:
		col = C_GOOD
		arrow = "▲"
		head = "that went down well"
	elif delta <= -3:
		col = C_BAD
		arrow = "▼▼"
		head = "%s closed off" % (who if not who.is_empty() else "they")
	elif delta < 0:
		col = C_BAD
		arrow = "▼"
		head = "that did not land"

	_bar.color = col
	_arrow.text = arrow
	_arrow.add_theme_color_override("font_color", col)
	_headline.text = head
	_headline.add_theme_color_override("font_color", col.lightened(0.25))

	# The register note goes first when there is one. It is the more specific
	# thing that happened - "kept a distance they had already closed" tells the
	# player something a style tag cannot, and it is the only feedback in the
	# game on an axis they otherwise have to infer entirely.
	var read: String = String(STYLE_READS.get(style, ""))
	if not note.is_empty():
		_detail.text = "%s — in %s" % [note, _region_name(region)]
	elif read.is_empty():
		_detail.text = "in %s" % _region_name(region)
	else:
		_detail.text = "%s — in %s" % [read, _region_name(region)]

	_standing.hide()
	var now: String = GameState.city_rep_level()
	if now != before:
		_standing.text = "You are now %s in %s." % [now, GameState.city_name()]
		_standing.show()

	_play()


# Called when the city standing itself changes, with no dialogue behind it
func show_standing(level: String) -> void:
	_bar.color = C_GOOD
	_arrow.text = "◆"
	_arrow.add_theme_color_override("font_color", C_GOOD)
	_headline.text = "Your standing changed"
	_headline.add_theme_color_override("font_color", C_GOOD.lightened(0.25))
	_detail.text = GameState.city_name()
	_standing.text = "You are now %s." % level
	_standing.show()
	_play()


func _region_name(region: String) -> String:
	# GameState owns the names now. This used to capitalize() the id, which
	# told the player they had gone up in the estimation of "Carsi".
	return GameState.region_name(region)


func _play() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_card.show()
	_card.modulate.a = 0.0
	_card.offset_left = -368.0
	_card.offset_right = -4.0
	# Each phase starts with chain(). A parallel tweener joins the step before
	# it, so the exit used to be added to the HOLD step and ran alongside the
	# hold: the card left the moment it arrived, readable for under half a
	# second, however long HOLD was set to.
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	_tween.tween_property(_card, "modulate:a", 1.0, SLIDE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_card, "offset_left", -392.0, SLIDE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_card, "offset_right", -28.0, SLIDE).set_ease(Tween.EASE_OUT)
	_tween.chain().tween_interval(HOLD)
	_tween.chain().tween_property(_card, "modulate:a", 0.0, SLIDE).set_ease(Tween.EASE_IN)
	_tween.tween_property(_card, "offset_left", -352.0, SLIDE).set_ease(Tween.EASE_IN)
	_tween.tween_property(_card, "offset_right", 12.0, SLIDE).set_ease(Tween.EASE_IN)
	_tween.chain().tween_callback(_card.hide)
