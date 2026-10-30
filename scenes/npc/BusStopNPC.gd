extends StaticBody2D

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const COUNTER := preload("res://scenes/npc/Counters.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

# Renate — waiting at the bus stop, as she apparently has been for a while.
# One short conversation per scene visit; replays grant no exposure.

var npc_name:     String = "Renate"
var _look: Dictionary = {}
var npc_color:    Color  = Color(0.42, 0.34, 0.52)
var relationship: String = "Fremde"
var region:       String = "mitte"

var player_nearby := false
var _talked: Dictionary = {}   # dialogue variant -> already granted exposure

var _t: float = 0.0

const _DIALOGUE: Array = [
	{
		"words": [
			{"text": "Der",    "word": "der",    "language": "german"},
			{"text": "Bus",    "word": "bus",    "language": "german"},
			{"text": "kommt",  "word": "kommen", "language": "german"},
			{"text": "nicht.", "word": "nicht",  "language": "german"},
		],
		"responses": [
			# Shared grievance is the fastest road to a Berliner's heart
			{"text": "Shrug sympathetically",                   "style": "gesture", "rep": 1},
			{"text": "Point at the sign, tilt your head",       "style": "gesture"},
			# Joining the vigil — wordless, complete solidarity
			{"text": "Stand next to her and wait too",          "style": "indirect", "rep": 1},
		]
	},
	{
		"words": [
			{"text": "Zehn",     "word": "zehn",    "language": "german"},
			{"text": "Minuten!", "word": "minuten", "language": "german"},
			{"text": "Zehn!",    "word": "zehn",    "language": "german"},
		],
		"responses": [
			# Echoing her number back — she feels HEARD, finally
			{"text": "Hold up ten fingers, questioning",         "style": "gesture", "rep": 1},
			{"text": "Nod gravely — universal transit grief",    "style": "direct"},
			{"text": "Look down the long, empty street",         "style": "indirect"},
		]
	},
]

const _OUT   := Color(0.06, 0.05, 0.08)
const _SKIN  := Color(0.86, 0.70, 0.58)
const _COAT  := Color(0.28, 0.34, 0.40)
const _BEANIE:= Color(0.55, 0.25, 0.28)
const _SCARF := Color(0.62, 0.50, 0.28)


func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_t += delta
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


# Once the player has met her AND figured out trading, she takes a closer
# look, decides they're clearly not from around here, and offers her map.
const _MAP_DIALOGUE: Array = [
	{
		"words": [
			{"text": "Sie",    "word": "sie",   "language": "german"},
			{"text": "sind",   "word": "sind",  "language": "german"},
			{"text": "nicht",  "word": "nicht", "language": "german"},
			{"text": "von",    "word": "von",   "language": "german"},
			{"text": "hier,",  "word": "hier",  "language": "german"},
			{"text": "oder?",  "word": "oder",  "language": "german"},
		],
		"responses": [
			{"text": "Freeze — how much did she figure out?",      "style": "indirect"},
			# Honesty. She asked straight; you answered straight
			{"text": "Shake your head slowly — no, not from here", "style": "direct", "rep": 1},
			{"text": "Point at the sky, then catch yourself",      "style": "gesture"},
		]
	},
	{
		"words": [
			{"text": "Hier.",  "word": "hier",  "language": "german"},
			{"text": "Eine",   "word": "eine",  "language": "german"},
			{"text": "Karte.", "word": "karte", "language": "german"},
		],
		"responses": [
			# Proper gratitude for a proper gift
			{"text": "Take it with both hands and bow",
				"style": "formal",  "action": "give_map", "rep": 1},
			{"text": "Accept it carefully, like a gift",
				"style": "gesture", "action": "give_map", "rep": 1},
			# Practical, but she barely gets a glance for her trouble
			{"text": "Take it and unfold it immediately",
				"style": "direct",  "action": "give_map"},
		]
	},
]


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var offering: bool = GameState.world_flags.get("bread_bought", false) \
		and GameState.world_flags.get("renate_met", false) \
		and not GameState.world_flags.get("has_map", false)
	var variant := "offer" if offering else "rant"
	var entries: Array = _MAP_DIALOGUE if offering else _DIALOGUE
	dlg.show_dialogue(entries, npc_name, relationship, npc_color,
		not _talked.has(variant), region, {}, "renate")
	_talked[variant] = true
	GameState.world_flags["renate_met"] = true
	GameState.complete_quest_step("get_map", 0)   # no-op until the quest exists


# ── Body ─────────────────────────────────────────────────────────────────────
# Drawn by scenes/npc/CharacterArt.gd, the grid read out of the player's own
# sprite. This was hand-drawn shapes from before that renderer existed, which
# is why the woman at the stop still looked like the first week of the project.
func _draw() -> void:
	if _look.is_empty():
		# Renate's own design. The block that used to be here forced her build
		# to elder, her cut to a headscarf and her hair to HAIRS[5] by hand,
		# which is the whole job CastRoster now does in one place.
		_look = ROSTER.look("renate", GameState.city)
	var unit: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, unit)
	CHAR.draw_figure(self, st["offset"], unit, _look, "wait", _t,
		absi(npc_name.hash()), int(st["clip"]))
