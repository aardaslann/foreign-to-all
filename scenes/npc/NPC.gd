extends StaticBody2D

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const COUNTER := preload("res://scenes/npc/Counters.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

var npc_name:     String = "Lukas"
var _look: Dictionary = {}
var _t: float = 0.0
var npc_color:    Color  = Color(0.30, 0.44, 0.68)
var region:       String = "kiez"

var player_nearby := false
var _talked_this_visit := false   # repeat talks replay the round without exposure

# ── Relationship label per round ──────────────────────────────────────────────
const _RELATIONSHIPS := ["Fremder", "Bekannt", "Stammgast", "Stammgast"]

# ── Four rotating dialogue rounds ─────────────────────────────────────────────
# Round 0  — first meeting, nothing is familiar yet
# Round 1  — re-hearing guten/morgen/ich reinforces them; new: wie, geht, auch, heute
# Round 2  — Lukas recognises the player; new: kommen, jeden, das, ist, sehr
# Round 3+ — richer sentences; reinforces most words; new: kalt, nacht, oder, empfehlen
const _ROUNDS: Array = [
	# ── Round 0 ──────────────────────────────────────────────────────────────
	[
		{
			"words": [
				{"text": "Guten",   "word": "guten",  "language": "german"},
				{"text": "Morgen!", "word": "morgen", "language": "german"},
				{"text": "Kann",    "word": "kann",   "language": "german"},
				{"text": "ich",     "word": "ich",    "language": "german"},
				{"text": "Ihnen",   "word": "ihnen",  "language": "german"},
				{"text": "helfen?", "word": "helfen", "language": "german"},
			],
			"responses": [
				# A bow is theatrical for a Berlin market — harmless, but odd
				{"text": "Bow slightly, hands clasped",       "style": "formal"},
				{"text": "Point at yourself and shrug",       "style": "gesture"},
				# Directness lands well here — reads as confidence, not threat
				{"text": "Nod and hold steady eye contact",   "style": "direct", "rep": 1},
			]
		},
		{
			"words": [
				{"text": "Ich",      "word": "ich",   "language": "german"},
				{"text": "habe",     "word": "habe",  "language": "german"},
				{"text": "frisches", "word": "frisch","language": "german"},
				{"text": "und",      "word": "und",   "language": "german"},
				{"text": "gutes",    "word": "gut",   "language": "german"},
				{"text": "Brot.",    "word": "brot",  "language": "german"},
			],
			"responses": [
				# Buying carries its own +2 inside buy_bread()
				{"text": "Hold out the metal discs, point at the bread  (€2)",
					"style": "direct", "action": "buy_bread", "requires_money": 2},
				# Interest in his bread is interest in him
				{"text": "Point at the bread eagerly",            "style": "direct", "rep": 1},
				{"text": "Hold up two fingers and smile",         "style": "gesture"},
				# Walking off mid-pitch stings — he got up at four for this bread
				{"text": "Turn away — too many sounds, too early", "style": "indirect", "rep": -1},
			]
		},
	],
	# ── Round 1 ──────────────────────────────────────────────────────────────
	[
		{
			"words": [
				{"text": "Guten",   "word": "guten",  "language": "german"},
				{"text": "Morgen!", "word": "morgen", "language": "german"},
				{"text": "Wie",     "word": "wie",    "language": "german"},
				{"text": "geht",    "word": "geht",   "language": "german"},
				{"text": "es",      "word": "es",     "language": "german"},
				{"text": "Ihnen?",  "word": "ihnen",  "language": "german"},
			],
			"responses": [
				{"text": "Bow — you remember this greeting now",  "style": "formal"},
				# He asked how you are — an actual answer, however clumsy, delights him
				{"text": "Point at yourself and shrug: 'fine?'",  "style": "gesture", "rep": 1},
				{"text": "Hold both palms open — universal 'ok'", "style": "gesture"},
			]
		},
		{
			"words": [
				{"text": "Ich",      "word": "ich",   "language": "german"},
				{"text": "habe",     "word": "habe",  "language": "german"},
				{"text": "auch",     "word": "auch",  "language": "german"},
				{"text": "heute",    "word": "heute", "language": "german"},
				{"text": "frisches", "word": "frisch","language": "german"},
				{"text": "Brot.",    "word": "brot",  "language": "german"},
			],
			"responses": [
				{"text": "Offer the discs, point at the bread  (€2)",
					"style": "direct", "action": "buy_bread", "requires_money": 2},
				{"text": "Point at the bread immediately",        "style": "direct"},
				{"text": "Hold up one finger — just one",         "style": "gesture"},
				# Complimenting the bread is the way to a baker's heart
				{"text": "Sniff the air and nod approvingly",     "style": "indirect", "rep": 1},
			]
		},
	],
	# ── Round 2 ──────────────────────────────────────────────────────────────
	[
		{
			"words": [
				{"text": "Sie",      "word": "sie",    "language": "german"},
				{"text": "kommen",   "word": "kommen", "language": "german"},
				{"text": "jeden",    "word": "jeden",  "language": "german"},
				{"text": "Morgen!",  "word": "morgen", "language": "german"},
				{"text": "Ich",      "word": "ich",    "language": "german"},
				{"text": "bin",      "word": "bin",    "language": "german"},
				{"text": "Lukas.",   "word": "lukas",  "language": "german"},
			],
			"responses": [
				# He just gave you his NAME. Reciprocating is the biggest
				# social step the alien has taken on this planet
				{"text": "Touch your chest — your turn to introduce yourself", "style": "gesture", "rep": 2},
				{"text": "Nod slowly — morgen is familiar now",                "style": "direct"},
				{"text": "Smile. You recognise more than he thinks.",           "style": "indirect"},
			]
		},
		{
			"words": [
				{"text": "Das",      "word": "das",     "language": "german"},
				{"text": "Brot",     "word": "brot",    "language": "german"},
				{"text": "ist",      "word": "ist",     "language": "german"},
				{"text": "sehr",     "word": "sehr",    "language": "german"},
				{"text": "frisch",   "word": "frisch",  "language": "german"},
				{"text": "heute.",   "word": "heute",   "language": "german"},
				{"text": "Möchten",  "word": "möchten", "language": "german"},
				{"text": "Sie?",     "word": "sie",     "language": "german"},
			],
			"responses": [
				{"text": "Pay with the discs — you know this dance now  (€2)",
					"style": "direct", "action": "buy_bread", "requires_money": 2},
				{"text": "Hold out your hand — yes please",           "style": "direct", "rep": 1},
				{"text": "Point at the bread, hold up two fingers",   "style": "gesture"},
				# He asked a question. An empty nod fools no one who sells
				# to tourists — mild disappointment
				{"text": "Nod and try to look like you understood",   "style": "indirect", "rep": -1},
			]
		},
	],
	# ── Round 3 (repeating) ───────────────────────────────────────────────────
	[
		{
			"words": [
				{"text": "Schöner",  "word": "schöner", "language": "german"},
				{"text": "Morgen!",  "word": "morgen",  "language": "german"},
				{"text": "Kalt",     "word": "kalt",    "language": "german"},
				{"text": "in",       "word": "in",      "language": "german"},
				{"text": "der",      "word": "der",     "language": "german"},
				{"text": "Nacht,",   "word": "nacht",   "language": "german"},
				{"text": "oder?",    "word": "oder",    "language": "german"},
			],
			"responses": [
				# Small talk about weather — participating means belonging
				{"text": "Hug yourself — yes, it was cold",          "style": "gesture", "rep": 1},
				{"text": "Nod: morgen is a word you know now",       "style": "direct"},
				{"text": "Look toward the sky. Say nothing.",         "style": "indirect"},
			]
		},
		{
			"words": [
				{"text": "Ich",          "word": "ich",       "language": "german"},
				{"text": "kann",         "word": "kann",      "language": "german"},
				{"text": "Ihnen",        "word": "ihnen",     "language": "german"},
				{"text": "das",          "word": "das",       "language": "german"},
				{"text": "gute",         "word": "gut",       "language": "german"},
				{"text": "Brot",         "word": "brot",      "language": "german"},
				{"text": "empfehlen.",   "word": "empfehlen", "language": "german"},
			],
			"responses": [
				{"text": "Buy the bread he recommends  (€2)",
					"style": "direct", "action": "buy_bread", "requires_money": 2},
				{"text": "Point at both items — two fingers",        "style": "gesture"},
				# Trusting him with an actual need — that's what regulars do
				{"text": "Put your hand on your stomach: hungry",    "style": "indirect", "rep": 1},
				{"text": "Hold out whatever you have to offer",      "style": "direct", "rep": 1},
			]
		},
	],
]

var relationship: String = _RELATIONSHIPS[0]

const _OUT  := Color(0.06, 0.05, 0.08)
const _SKIN := Color(0.90, 0.76, 0.62)
const _HAIR := Color(0.18, 0.14, 0.10)
const _SHRT := Color(0.28, 0.38, 0.60)
const _APRN := Color(0.75, 0.63, 0.44)

var _head_out:  PackedVector2Array
var _head_fill: PackedVector2Array
var _body_out:  PackedVector2Array
var _body_fill: PackedVector2Array
var _cap_out:   PackedVector2Array
var _cap_fill:  PackedVector2Array


func _ready() -> void:
	# Octagonal head — slightly rounder/friendlier than the player
	_head_out = PackedVector2Array([
		Vector2(-9, -26),  Vector2(9, -26),
		Vector2(13, -21),  Vector2(13, -5),
		Vector2(9, -1),    Vector2(-9, -1),
		Vector2(-13, -5),  Vector2(-13, -21),
	])
	_head_fill = PackedVector2Array([
		Vector2(-7, -24), Vector2(7, -24),
		Vector2(11, -19), Vector2(11, -6),
		Vector2(7, -3),   Vector2(-7, -3),
		Vector2(-11, -6), Vector2(-11, -19),
	])
	# Body wider than head (stocky vendor build)
	_body_out = PackedVector2Array([
		Vector2(-12, -3),  Vector2(12, -3),
		Vector2(15, 22),   Vector2(-15, 22),
	])
	_body_fill = PackedVector2Array([
		Vector2(-10, -1), Vector2(10, -1),
		Vector2(13, 20),  Vector2(-13, 20),
	])
	# Cap dome — narrow trapezoid, sits above head
	_cap_out = PackedVector2Array([
		Vector2(-9, -24), Vector2(9, -24),
		Vector2(5, -39),  Vector2(-5, -39),
	])
	_cap_fill = PackedVector2Array([
		Vector2(-7, -22), Vector2(7, -22),
		Vector2(3, -37),  Vector2(-3, -37),
	])
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_start_dialogue()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


# The round is fixed per scene visit: it advances only when the player leaves
# and comes back. Repeat talks in the same visit replay the same conversation
# and grant no familiarity, so there is nothing to farm by spamming E.
func _round_for_visit() -> int:
	return clampi(int(GameState.region_visits.get(region, 1)) - 1, 0, _ROUNDS.size() - 1)


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var round_i := _round_for_visit()
	relationship = _RELATIONSHIPS[round_i]
	dlg.show_dialogue(_ROUNDS[round_i], npc_name, relationship, npc_color,
		not _talked_this_visit, region, {}, "lukas")
	_talked_this_visit = true


# ── Body ─────────────────────────────────────────────────────────────────────
# Drawn by scenes/npc/CharacterArt.gd, the grid read out of the player's own
# sprite. This was hand-drawn shapes from before that renderer existed, which
# is why Lukas still looked like the first week of the project.
func _draw() -> void:
	if _look.is_empty():
		# The bread man's own design, from the roster.
		_look = ROSTER.look("lukas", GameState.city)
	var unit: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, unit)
	CHAR.draw_figure(self, st["offset"], unit, _look, "stand", _t,
		absi(npc_name.hash()), int(st["clip"]))


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
