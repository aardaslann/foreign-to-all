extends Node2D

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

# Two friends on an early-morning walk along the street. They chat in short
# bursts; if the player is close enough to overhear, each word counts as a
# one-time "hear" exposure — the street itself teaches, but can't be farmed.

const PATH_LEFT  := 160.0
const PATH_RIGHT := 980.0
const SPEED      := 38.0
const EARSHOT    := 170.0
const GLYPHS     := "◈⟟⬡◉⟢⟣⋄⟤⟥⬢⬣⬟⬠⟦⟧⟡"

# What they say to each other, from the same table the crowd uses, so the two
# of them cannot drift out of step with the street they are walking down. It
# used to be six German fragments in this file, the first of which was
# "Guten Morgen!" - said at five in the morning, under a black sky, and again
# every time they turned round.
const CHATTER := preload("res://scenes/npc/Chatter.gd")


func _snippets() -> Array:
	return CHATTER.lines(GameState.local_language(), GameState.day_part())



var npc_name:     String = "Ayşe & Jonas"
var npc_color:    Color  = Color(0.48, 0.36, 0.24)
var relationship: String = "Fremde"
var region:       String = "mitte"

# Spoken when the player stops them for a chat
const _DIALOGUE: Array = [
	{
		# Two people, two voices: Ayse greets, Jonas has the news about the bus.
		"voice": "ayse",
		"words": [
			{"text": "Guten",   "word": "guten",  "language": "german"},
			{"text": "Morgen!", "word": "morgen", "language": "german"},
			{"text": "Wie",     "word": "wie",    "language": "german"},
			{"text": "geht's?", "word": "geht",   "language": "german"},
		],
		"responses": [
			{"text": "Wave back cheerfully",                 "style": "gesture", "rep": 1},
			# Butchering "guten Morgen" out loud — they crack up, delighted.
			# Trying badly beats not trying at all
			{"text": "Try to copy their greeting sounds",    "style": "direct", "rep": 1},
			# Polite nothing — they move on and forget you existed
			{"text": "Smile and nod, keep it vague",         "style": "indirect"},
		]
	},
	{
		"voice": "jonas",
		"words": [
			{"text": "Der",    "word": "der",    "language": "german"},
			{"text": "Bus",    "word": "bus",    "language": "german"},
			{"text": "kommt",  "word": "kommen", "language": "german"},
			{"text": "heute",  "word": "heute",  "language": "german"},
			{"text": "nicht!", "word": "nicht",  "language": "german"},
		],
		"responses": [
			# You KNOW about the bus saga — you're in on the neighbourhood joke
			{"text": "Point toward the bus stop and shrug",       "style": "gesture", "rep": 1},
			{"text": "Laugh along — you have no idea why",        "style": "indirect"},
			{"text": "Spread your hands: 'what can you do?'",     "style": "gesture"},
		]
	},
]

var _t:          float = 0.0
var _dir:        float = 1.0
var _pause_t:    float = 0.0
var _bubble_i:   int   = -1     # active snippet, -1 = none
var _bubble_t:   float = 0.0
var _spoken: Array = []
var _bubble_who: int   = 0      # 0 = left friend, 1 = right friend
var _next_chat:  float = 3.0
var _snip_cycle: int   = 0
var _exposed:    Dictionary = {}

var player_nearby      := false
var _talked_this_visit := false
var _looks: Dictionary = {}


func _process(delta: float) -> void:
	_t += delta

	# Proximity check against the pair's midpoint
	player_nearby = false
	var player := get_tree().get_first_node_in_group("player")
	if player is Node2D:
		var d := (global_position + Vector2(27, 0)).distance_to(
			(player as Node2D).global_position)
		player_nearby = d < 58.0

	if _pause_t > 0.0:
		_pause_t -= delta
	elif player_nearby:
		pass   # they politely stop while you're standing with them
	else:
		position.x += SPEED * _dir * delta
		if position.x > PATH_RIGHT:
			_dir = -1.0
			_pause_t = 1.4
		elif position.x < PATH_LEFT:
			_dir = 1.0
			_pause_t = 1.4
		elif fmod(_t, 12.0) < delta:
			_pause_t = 2.6   # stop to make a point, as friends do

	_next_chat -= delta * (0.55 if GameState.day_part() == "night" else 1.0)
	if _bubble_i >= 0:
		_bubble_t -= delta
		if _bubble_t <= 0.0:
			_bubble_i = -1
	elif _next_chat <= 0.0:
		var pool: Array = _snippets()
		_next_chat = 6.5
		if not pool.is_empty():
			_bubble_i = _snip_cycle % pool.size()
			_snip_cycle += 1
			_bubble_who = _snip_cycle % 2
			_bubble_t = 2.8
			_spoken = pool[_bubble_i]
			_try_expose(_spoken)

	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_start_dialogue()


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	_bubble_i = -1          # drop any ambient bubble
	_pause_t = 2.5          # linger a moment after the conversation ends
	dlg.show_dialogue(_dialogue_now(), npc_name, relationship, npc_color,
		not _talked_this_visit, region)
	_talked_this_visit = true


func _dialogue_now() -> Array:
	var result := _DIALOGUE.duplicate(true)
	if GameState.day_part() != "morning":
		result[0]["words"] = []
		for pair: Array in CHATTER.GREET.german[GameState.day_part()][0]:
			result[0]["words"].append({"text": pair[0], "word": pair[1], "language": "german"})
		result[0]["voice"] = "chatter:german"
	return result


func _try_expose(snip: Array) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not (player is Node2D):
		return
	if global_position.distance_to((player as Node2D).global_position) > EARSHOT:
		return
	var lang: String = GameState.local_language()
	var said: PackedStringArray = []
	for part in snip:
		said.append(String(part[0]))
	AudioManager.murmur(lang, " ".join(said), global_position)
	for pair in snip:
		var wkey: String = String(pair[1])
		var key: String = lang + ":" + wkey
		if not _exposed.has(key):
			_exposed[key] = true
			GameState.expose(lang, wkey, "hear")


func _draw() -> void:
	_draw_friend(0.0)
	_draw_friend(54.0)
	if _bubble_i >= 0:
		_draw_bubble()
	if player_nearby:
		draw_string(ThemeDB.fallback_font, Vector2(-12.0, -66.0), "[E] Talk",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.86, 0.84, 1.00, 0.90))


# Drawn by CharacterArt, like everybody else. This was a stack of rectangles
# from before that renderer existed, and next to the crowd walking past them
# the two friends were visibly older art.
func _draw_friend(ox: float) -> void:
	if not _looks.has(ox):
		# Ayse and Jonas, each designed, rather than two hashes of an x offset
		# re-tinted with a coat colour passed in from the caller.
		_looks[ox] = ROSTER.look("ayse" if ox < 1.0 else "jonas",
			GameState.city)
	var act: String = "stand" if _pause_t > 0.0 or player_nearby else "walk"
	CHAR.draw_figure(self, Vector2(ox, 22.0), maxf(2.0, roundf(CHAR.world_unit(self) * 0.85)), _looks[ox], act, _t,
		int(ox) + 3)


# Keep the words that were actually spoken through an hour boundary.
func _line() -> Array:
	return _spoken if _bubble_i >= 0 else []


func _draw_bubble() -> void:
	var cx: float = 0.0 if _bubble_who == 0 else 54.0
	CHAR.speech(self, Vector2(cx, -46.0),
		CHAR.snippet_text(_line(), GameState.local_language()))
