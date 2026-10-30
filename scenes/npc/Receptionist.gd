extends StaticBody2D

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const COUNTER := preload("res://scenes/npc/Counters.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

# Frau Weber — night receptionist, unshakeably polite at 5 a.m.
# Before booking: greets and offers a room (€1 slid across the desk).
# After booking: points up, three times. Dritter Stock.

var npc_name:     String = "Frau Weber"
var _look: Dictionary = {}
var npc_color:    Color  = Color(0.38, 0.30, 0.55)
var relationship: String = "Empfang"
var region:       String = "mitte"

var player_nearby := false
var _talked: Dictionary = {}

var _t: float = 0.0

const _GREET: Array = [
	{
		"words": [
			{"text": "Guten",       "word": "guten",      "language": "german"},
			{"text": "Morgen!",     "word": "morgen",     "language": "german"},
			{"text": "Willkommen!", "word": "willkommen", "language": "german"},
		],
		"responses": [
			# Here, unlike the market, a bow fits the house style perfectly
			{"text": "Bow — this seems like a bowing place",  "style": "formal", "rep": 1},
			{"text": "Nod, try to look like a normal guest",  "style": "indirect"},
			# One does not wave in a lobby like this. An eyebrow rises
			{"text": "Wave, a little too enthusiastically",   "style": "gesture", "rep": -1},
		]
	},
	{
		"words": [
			{"text": "Ein",     "word": "ein",    "language": "german"},
			{"text": "Zimmer?", "word": "zimmer", "language": "german"},
		],
		"responses": [
			# Payment offered promptly and correctly — book_room adds its own +1
			{"gesture": "Point to yourself, mime sleeping, and offer payment", "words": "Ein Zimmer, bitte.",
				"style": "direct", "action": "book_room"},
			{"text": "Mime sleeping — hands under your cheek", "style": "gesture"},
			# Pointing behind her desk — presumptuous. That is HER key rack
			{"text": "Point at the key rack behind her",       "style": "gesture", "rep": -1},
		]
	},
]

# Before the player has the map (quest order), she's polite but the
# conversation goes nowhere — no room on offer yet.
const _EARLY: Array = [
	{
		"words": [
			{"text": "Guten",       "word": "guten",      "language": "german"},
			{"text": "Morgen!",     "word": "morgen",     "language": "german"},
			{"text": "Willkommen!", "word": "willkommen", "language": "german"},
		],
		"responses": [
			{"text": "Nod politely and look around the lobby",  "style": "indirect"},
			{"text": "Bow — this seems like a bowing place",    "style": "formal"},
			{"text": "Back toward the door — not yet, not yet", "style": "gesture"},
		]
	},
]

const _BOOKED: Array = [
	{
		"words": [
			{"text": "Zimmer",  "word": "zimmer",  "language": "german"},
			{"text": "drei",    "word": "drei",    "language": "german"},
			{"text": "null",    "word": "null",    "language": "german"},
			{"text": "vier.",   "word": "vier",    "language": "german"},
			{"text": "Dritter", "word": "dritter", "language": "german"},
			{"text": "Stock!",  "word": "stock",   "language": "german"},
		],
		"responses": [
			# Presenting the card back: procedure, followed. Deep approval
			{"text": "Show her the card — she nods",            "style": "direct", "rep": 1},
			{"text": "Copy her gesture: three fingers, up",     "style": "gesture"},
			{"text": "Thank her with a deep bow",               "style": "formal"},
		]
	},
]

const _OUT   := Color(0.06, 0.05, 0.08)
const _SKIN  := Color(0.88, 0.72, 0.60)
const _HAIR  := Color(0.42, 0.40, 0.44)
const _VEST  := Color(0.24, 0.16, 0.30)
const _SHIRT := Color(0.80, 0.78, 0.74)


func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		_start_dialogue()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var variant: String
	var entries: Array
	if GameState.world_flags.get("room_booked", false):
		variant = "booked"
		entries = _BOOKED
	elif GameState.world_flags.get("has_map", false):
		variant = "greet"
		entries = _GREET
		Journey.ensure_funds(GameState.room_price())
	else:
		variant = "early"
		entries = _EARLY
	dlg.show_dialogue(entries, npc_name, relationship, npc_color,
		not _talked.has(variant), region, {}, "weber")
	_talked[variant] = true


# ── Body ─────────────────────────────────────────────────────────────────────
# Drawn by scenes/npc/CharacterArt.gd, the grid read out of the player's own
# sprite. This was hand-drawn shapes from before that renderer existed, which
# is why the receptionist still looked like the first week of the project.
func _draw() -> void:
	if _look.is_empty():
		# Her own design, not a hash of her name. See scenes/npc/CastRoster.gd.
		_look = ROSTER.look("weber", GameState.city)
	var unit: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, unit)
	CHAR.draw_figure(self, st["offset"], unit, _look, "interact", _t,
		absi(npc_name.hash()), int(st["clip"]))
