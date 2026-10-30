extends StaticBody2D

# A person from the roster in CityNPCs.gd. Set `npc_id` in the scene and this
# reads everything else — name, colour, region, rounds — from there, so a new
# character is a data entry rather than a new script.
#
# Berlin's Lukas keeps his own hand-built NPC.gd; he was written before the
# roster existed and his sprite work is bound up in it. This is for everyone
# else, and it draws its body from a build profile instead, so an old woman and
# a nine-year-old are not the same silhouette in different colours.

# Preloaded, not reached for by class_name: the global class cache is the
# editor's, and every tool in this project runs headless with --script.
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const COUNTER := preload("res://scenes/npc/Counters.gd")
# One authored design per named person. Everybody in the roster has one.
const ROSTER := preload("res://scenes/npc/CastRoster.gd")

@export var npc_id: String = ""
@export var city: String = ""
# child | youth | adult | elder — decides height, posture and proportion
@export var build: String = "adult"
@export var facing: String = "down"

var npc_name: String = ""
var npc_color: Color = Color(0.42, 0.46, 0.66)
var region: String = ""
var relationship: String = ""

# From the roster in _ready, with a city-appropriate fallback.
var skin: Color = SKIN[1]
var hair: Color = HAIR[0]
var head: String = "none"

var player_nearby: bool = false
var _walking: bool = false
var _skin_set: bool = false
var _hair_set: bool = false

var _rounds: Array = []
var _relationships: Array = []
var _talked_this_visit: bool = false
var _t: float = 0.0

const C_OUT := Color(0.055, 0.050, 0.090)

# Appearance is roster DATA, never inferred.
#
# It used to be one hardcoded skin colour for every person in the game, and
# headwear picked off the BUILD - so every elder in every country wore the same
# headscarf. That is the exact shape of a stereotype: a visual trait assigned by
# category rather than by person.
#
# So a roster entry may name its own skin, hair and head. Where it does not,
# skin falls back to the city PALETTE below, picked by a hash of the person id -
# a crowd looks like the place it is standing in, without any one person being
# a type. The palettes are ranges, not values, because every city on this
# itinerary is more mixed than one value would admit.
const SKIN := [
	Color(0.914, 0.776, 0.678),
	Color(0.859, 0.702, 0.580),
	Color(0.780, 0.616, 0.490),
	Color(0.678, 0.510, 0.376),
	Color(0.549, 0.388, 0.278),
	Color(0.420, 0.290, 0.212),
	Color(0.310, 0.212, 0.161),
]

const PALETTE := {
	"berlin":   [0, 1, 2, 4],   "zurich":   [0, 0, 1, 2],
	"hanoi":    [1, 1, 2, 2],   "london":   [0, 1, 3, 5],
	"tokyo":    [0, 1, 1, 2],   "rome":     [1, 1, 2, 3],
	"moscow":   [0, 0, 1, 1],   "mexico":   [2, 3, 3, 4],
	"saopaulo": [0, 2, 4, 6],   "dakar":    [5, 5, 6, 6],
	"tbilisi":  [1, 1, 2, 2],   "seoul":    [0, 1, 1, 2],
	"mumbai":   [2, 3, 4, 5],   "istanbul": [1, 2, 2, 3],
	"lapaz":    [3, 3, 4, 4],
	"paris":    [0, 1, 4, 5],
	"honolulu": [1, 2, 3, 4],
	"newyork":  [0, 2, 4, 5],
	"toronto":  [0, 1, 3, 5],
	"sydney":   [0, 1, 2, 5],
}

const HAIR := [
	Color(0.110, 0.094, 0.086), Color(0.200, 0.157, 0.129),
	Color(0.325, 0.243, 0.180), Color(0.502, 0.396, 0.267),
	Color(0.612, 0.596, 0.573), Color(0.812, 0.804, 0.788),
]


func _ready() -> void:
	var data: Dictionary = CityNPCs.get_npc(_city(), npc_id)
	if data.is_empty():
		push_warning("CityNPC: no roster entry for '%s' in '%s'" % [npc_id, _city()])
		return
	npc_name = String(data.get("name", "Somebody"))
	npc_color = data.get("color", npc_color)
	region = String(data.get("region", ""))
	_rounds = data.get("rounds", [])
	_relationships = data.get("relationships", [])
	_read_appearance(data)
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	queue_redraw()


# A person looks how the roster says they look. Anything left out is drawn from
# the city, deterministically by id, so the same person is the same person
# every time you walk past them.
func _read_appearance(data: Dictionary) -> void:
	head = String(data.get("head", "none"))
	_skin_set = data.has("skin")
	_hair_set = data.has("hair")
	var seed_i: int = absi(hash(npc_id))
	if data.has("skin"):
		skin = data["skin"]
	else:
		var pool: Array = PALETTE.get(_city(), [1, 2])
		skin = SKIN[int(pool[seed_i % pool.size()])]
	if data.has("hair"):
		hair = data["hair"]
	elif build == "elder":
		hair = HAIR[4 + (seed_i % 2)]
	else:
		var young: Array = [0, 0, 1, 1, 2]
		hair = HAIR[int(young[seed_i % young.size()])]


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _city() -> String:
	return city if not city.is_empty() else GameState.city


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or _rounds.is_empty():
		return
	if event.is_action_pressed("interact"):
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


# Fixed per scene visit, like Berlin's: it advances when you leave and come
# back, so re-pressing E replays the same conversation and grants nothing.
func _round_for_visit() -> int:
	return clampi(int(GameState.region_visits.get(region, 1)) - 1,
		0, maxi(_rounds.size() - 1, 0))


func _start_dialogue() -> void:
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var i: int = _round_for_visit()
	if i < _relationships.size():
		relationship = String(_relationships[i])
	# Their own recorded voice, keyed by city as well as id: two cities can
	# each have a Lucia (tools/export_all_speech.gd, audio/voice/manifest.json).
	dlg.show_dialogue(_rounds[i], npc_name, relationship, npc_color,
		not _talked_this_visit, region, {}, _city() + "_" + npc_id)
	_talked_this_visit = true


# ── Body ──────────────────────────────────────────────────────────────────────
#
# Drawn by scenes/npc/CharacterArt.gd, which is the grid read out of the
# player's own sprite. This used to be circles and rectangles with a
# quarter-height head and legs running most of the body - a person from a
# different game standing next to the one you were controlling.
#
# Build only changes how tall they are. It never changes what they wear: an
# elder in a headscarf because they are an elder is a stereotype with a
# sprite on it.
const BUILD_HEIGHT := {
	"child": 0.70, "youth": 0.94, "adult": 1.0, "elder": 0.93,
}

# What the roster calls a hat, and which cut draws it.
const HEAD_CUT := {
	"scarf": "scarf", "wrap": "wrap", "cap": "cap", "hat": "cap",
	"hood": "wrap",
}


# Roster data wins over anything derived. Where the roster says nothing, the
# person is drawn from their own id, so the same person is the same person
# every time you walk past them.
func _look() -> Dictionary:
	# A designed person wins outright. CastRoster holds one authored entry per
	# named character - their age, their trade, where they are actually from -
	# and the fallback below is for somebody who genuinely is one more person
	# on the street rather than somebody the game forgot to draw.
	if ROSTER.has_person(npc_id):
		return ROSTER.look(npc_id, _city())
	var who: Dictionary = CHAR.look(absi(npc_id.hash()), _city())
	var pal: Dictionary = who["pal"]
	if _skin_set:
		pal["S"] = skin
		pal["L"] = skin.lightened(0.20)
		pal["H"] = skin.darkened(0.20)
	if _hair_set:
		pal["R"] = hair
	pal["C"] = npc_color
	pal["O"] = npc_color.darkened(0.42)
	pal["D"] = npc_color.darkened(0.22)
	if HEAD_CUT.has(head):
		who["cut"] = String(HEAD_CUT[head])
	return who


func _draw() -> void:
	# One unit is two screen pixels, because the sprite is drawn at 2x out
	# here. That makes a person 44 pixels from soles to crown - the same 44
	# the player is, which is the whole point.
	# Build height is applied ONCE, inside draw_figure, off the look's own
	# build. It used to be applied here as well, so a child was 0.70 x 0.68 of
	# an adult - a third of the height of the person they are talking to.
	var u: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, u)
	CHAR.draw_figure(self, st["offset"], u, _look(),
		"walk" if _walking else "stand", _t, absi(npc_id.hash()),
		int(st["clip"]))
