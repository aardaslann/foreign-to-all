extends Node

# Fired when a word crosses into a higher familiarity tier (glimpsed/partial/known).
signal word_tier_changed(language: String, word: String, new_tier: int)
# London only. Fired when your ear for one particular person improves — which
# is a different thing from learning a word, and the whole of the second act.
signal speaker_tier_changed(speaker_id: String, new_tier: int)
signal money_changed(amount: int)
signal item_changed(item: String, count: int)
signal quest_updated(quest_id: String)
signal job_changed(job_id: String)

const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
const CLOCK := preload("res://autoload/JourneyClock.gd")
var clock_minutes: float = CLOCK.START
var alien_appearance: Dictionary = APPEARANCE.DEFAULT.duplicate()

# What the alien thinks the words mean. Two files only because one of six
# hundred entries is past the size this project allows; between them they cover
# every language the game can teach, which the three tables that used to live
# in this file did not - anything that was not German, English or Turkish was
# looked up in the German notebook and came back empty.
const GUESSES := preload("res://autoload/Guesses.gd")
const WORD_HINTS := preload("res://autoload/WordHints.gd")
const GUESSES_WORLD := preload("res://autoload/GuessesWorld.gd")

const BREAD_PRICE := 2
const ROOM_PRICE  := 1
const HOTEL_ROOM  := "304"   # the room on the card
const ROOM_FLOOR  := 3

# A single ride, in the money of the city you are standing in. A flat 3 was
# three euros in Berlin and about a hundredth of a cent in Hanoi.
const UBAHN_FARES := {
	"berlin": 3,       "zurich": 4,       "hanoi": 8000,     "london": 3,
	"tokyo": 180,      "rome": 2,         "moscow": 60,      "mexico": 5,
	"saopaulo": 5,     "dakar": 500,      "tbilisi": 1,      "seoul": 1400,
	"mumbai": 10,      "istanbul": 20,    "lapaz": 3,
	"paris": 2,        "sydney": 4,
	"honolulu": 3,     "newyork": 3,      "toronto": 4,
}
const UBAHN_FARE  := 3       # the fallback, for a city without an entry
const FLIGHT_FARE := 15      # per the brief; the fallback for an unpriced city

# What a seat costs, in the currency of the city you are LEAVING — priced the
# same way as ROOM_PRICES, because a fare is a local number. Istanbul's looks
# enormous and is roughly the same flight: at RATES["TRY"] = 35 it is about
# fifteen euros, and the player has to work that out at the exchange.
const FLIGHT_FARES := {
	"berlin": 15,      "zurich": 16,      "hanoi": 420000,   "london": 13,
	"tokyo": 2600,     "rome": 15,        "moscow": 1500,    "mexico": 320,
	"saopaulo": 95,    "dakar": 10000,    "tbilisi": 48,     "seoul": 23000,
	"mumbai": 1400,    "istanbul": 520,   "lapaz": 120,
	"paris": 14,       "sydney": 24,
	"honolulu": 30,    "newyork": 26,     "toronto": 24,
}

# ── The pod's navigation core ────────────────────────────────────────────────
# It shattered on impact and the pieces were scavenged. Recovering all of them
# is the spine of the game; each one is held by someone who has their own
# reason for keeping it.

# ── Cities ───────────────────────────────────────────────────────────────────
const CITIES := {
	"berlin":     {"name": "Berlin",        "country": "Germany",          "currency": "EUR",
		"symbol": "€",   "language": "german"},
	"zurich":     {"name": "Zürich",        "country": "Switzerland",      "currency": "CHF",
		"symbol": "Fr",  "language": "swissgerman"},
	"hanoi":      {"name": "Hanoi",         "country": "Vietnam",          "currency": "VND",
		"symbol": "₫",   "language": "vietnamese"},
	"london":     {"name": "London",        "country": "United Kingdom",   "currency": "GBP",
		"symbol": "£",   "language": "english"},
	"tokyo":      {"name": "Tokyo",         "country": "Japan",            "currency": "JPY",
		"symbol": "¥",   "language": "japanese"},
	"rome":       {"name": "Rome",          "country": "Italy",            "currency": "EUR",
		"symbol": "€",   "language": "italian"},
	"moscow":     {"name": "Moscow",        "country": "Russia",           "currency": "RUB",
		"symbol": "₽",   "language": "russian"},
	"mexico":     {"name": "Mexico City",   "country": "Mexico",           "currency": "MXN",
		"symbol": "$",   "language": "spanish_mx"},
	"saopaulo":   {"name": "São Paulo",     "country": "Brazil",           "currency": "BRL",
		"symbol": "R$",  "language": "portuguese"},
	"dakar":      {"name": "Dakar",         "country": "Senegal",          "currency": "XOF",
		"symbol": "F",   "language": "wolof"},
	"tbilisi":    {"name": "Tbilisi",       "country": "Georgia",          "currency": "GEL",
		"symbol": "₾",   "language": "georgian"},
	"seoul":      {"name": "Seoul",         "country": "South Korea",      "currency": "KRW",
		"symbol": "₩",   "language": "korean"},
	"mumbai":     {"name": "Mumbai",        "country": "India",            "currency": "INR",
		"symbol": "₹",   "language": "hindi"},
	"istanbul":   {"name": "İstanbul",      "country": "Türkiye",          "currency": "TRY",
		"symbol": "₺",   "language": "turkish"},
	"lapaz":      {"name": "La Paz",        "country": "Bolivia",          "currency": "BOB",
		"symbol": "Bs",  "language": "spanish_bo"},
	"paris":      {"name": "Paris",         "country": "France",           "currency": "EUR",
		"symbol": "€",   "language": "french"},
	"sydney":     {"name": "Sydney",        "country": "Australia",        "currency": "AUD",
		"symbol": "$",   "language": "english"},
	"honolulu":   {"name": "Honolulu",      "country": "Hawaiʻi, USA",     "currency": "USD",
		"symbol": "$",   "language": "english"},
	"newyork":    {"name": "New York",      "country": "USA",              "currency": "USD",
		"symbol": "$",   "language": "english"},
	"toronto":    {"name": "Toronto",       "country": "Canada",           "currency": "CAD",
		"symbol": "$",   "language": "english"},
}

# Exchange rates against the euro, plus the cut the booth takes. Roughly
# real, rounded to numbers a player can hold in their head — the point is
# that the SHAPE of the number changes when you land, not that it trades.
const RATES := {
	"EUR": 1.0,     "GBP": 0.85,    "CHF": 0.95,    "TRY": 35.0,
	"JPY": 165.0,   "RUB": 95.0,    "MXN": 20.0,    "BRL": 6.0,
	"XOF": 656.0,   "GEL": 3.0,     "KRW": 1450.0,  "INR": 92.0,
	"BOB": 7.5, "AUD": 1.65, "USD": 1.08, "CAD": 1.47,     "VND": 27000.0,
}
const EXCHANGE_FEE := 0.10


# How much the booth changes in one go, in whatever you happen to be
# holding. This used to be a flat 40 — which is forty euros in Berlin and
# about a seventh of a cent in Hanoi — so it is priced as roughly forty
# euros of THIS instead. The digits change; the sum does not.
func exchange_step(cur: String) -> int:
	return maxi(1, int(round(40.0 * float(RATES.get(cur, 1.0)))))

# Flights land inside terminals. Street entry points remain separate for tools.
const ARRIVALS := {
	"berlin": "res://scenes/world/Airport.tscn",
	"istanbul": "res://scenes/world/IstanbulHavalimani.tscn",
	"london": "res://scenes/world/LondonAirport.tscn",
	"paris": "res://scenes/world/ParisAirport.tscn",
	"moscow": "res://scenes/world/MoscowAirport.tscn",
	"mumbai": "res://scenes/world/MumbaiAirport.tscn",
	"tokyo": "res://scenes/world/TokyoAirport.tscn",
	"mexico": "res://scenes/world/MexicoAirport.tscn",
	"zurich": "res://scenes/world/ZurichAirport.tscn",
	"hanoi": "res://scenes/world/HanoiAirport.tscn",
	"rome": "res://scenes/world/RomeAirport.tscn",
	"saopaulo": "res://scenes/world/SaoPauloAirport.tscn",
	"dakar": "res://scenes/world/DakarAirport.tscn",
	"tbilisi": "res://scenes/world/TbilisiAirport.tscn",
	"seoul": "res://scenes/world/SeoulAirport.tscn",
	"lapaz": "res://scenes/world/LaPazAirport.tscn",
	"sydney": "res://scenes/world/SydneyAirport.tscn",
	"honolulu": "res://scenes/world/HonoluluAirport.tscn",
	"newyork": "res://scenes/world/NewYorkAirport.tscn",
	"toronto": "res://scenes/world/TorontoAirport.tscn",
}

const CITY_ENTRIES := {
	"berlin":     "res://scenes/world/Mitte.tscn",
	"zurich":     "res://scenes/world/ZurichNiederdorf.tscn",
	"hanoi":      "res://scenes/world/HanoiPhoCo.tscn",
	"london":     "res://scenes/world/LondonTerrace.tscn",
	"tokyo":      "res://scenes/world/TokyoYanaka.tscn",
	"rome":       "res://scenes/world/RomeTestaccio.tscn",
	"moscow":     "res://scenes/world/MoscowKitayGorod.tscn",
	"mexico":     "res://scenes/world/MexicoMerced.tscn",
	"saopaulo":   "res://scenes/world/SaoPauloLiberdade.tscn",
	"dakar":      "res://scenes/world/DakarMedina.tscn",
	"tbilisi":    "res://scenes/world/TbilisiSololaki.tscn",
	"seoul":      "res://scenes/world/SeoulEuljiro.tscn",
	"mumbai":     "res://scenes/world/MumbaiBhuleshwar.tscn",
	"istanbul":   "res://scenes/world/IstanbulCarsi.tscn",
	"lapaz":      "res://scenes/world/LaPazElAlto.tscn",
	"paris":      "res://scenes/world/ParisChampDeMars.tscn",
	"sydney":     "res://scenes/world/SydneyCircularQuay.tscn",
	"honolulu":   "res://scenes/world/HonoluluWaikiki.tscn",
	"newyork":    "res://scenes/world/NewYorkMidtown.tscn",
	"toronto":    "res://scenes/world/TorontoDowntown.tscn",
}

# Which reputation buckets belong to which city. The endings read this.
const CITY_REGIONS := {
	"berlin":     ["kiez", "mitte", "prenzlberg", "kreuzberg"],
	"zurich":     ["niederdorf", "langstrasse", "zurichwest", "seefeld", "oerlikon"],
	"hanoi":      ["phoco", "longbien", "badinh", "tayho", "dongda"],
	"london":     ["terrace", "highstreet", "docklands", "soho", "brixton"],
	"tokyo":      ["yanaka", "jinbocho", "shinbashi", "asakusa", "ueno"],
	"rome":       ["testaccio", "esquilino", "trastevere", "monti", "garbatella"],
	"moscow":     ["kitaygorod", "basmanny", "izmaylovo", "zamoskvorechye", "arbat"],
	"mexico":     ["merced", "juarez", "coyoacan", "roma", "condesa"],
	"saopaulo":   ["liberdade", "bixiga", "mercadao", "vilamadalena", "paulista"],
	"dakar":      ["medina", "sandaga", "ouakam", "yoff", "plateau"],
	"tbilisi":    ["sololaki", "dezerter", "avlabari", "saburtalo", "chugureti"],
	"seoul":      ["euljiro", "jongno", "mangwon", "seongsu", "hongdae"],
	"mumbai":     ["bhuleshwar", "chorbazaar", "byculla", "bandra", "colaba"],
	"istanbul":   ["carsi", "han", "karakoy", "beyoglu", "kadikoy"],
	"lapaz":      ["elalto", "rodriguez", "sopocachi", "irpavi", "sanpedro"],
	"paris":      ["champdemars", "marais", "montmartre", "belleville", "ladefense"],
	"sydney":     ["circularquay", "cbd", "newtown", "bondi", "cabramatta"],
	"honolulu":   ["waikiki", "chinatown", "kakaako", "manoa", "northshore"],
	"newyork":    ["midtown", "lowereast", "harlem", "williamsburg", "jacksonheights"],
	"toronto":    ["downtown", "kensington", "gerrard", "distillery", "scarborough"],
}


# ── What a district is CALLED ────────────────────────────────────────────────
#
# The ids above are keys and they stay keys: they are load-bearing in
# `reputation`, in CITY_REGIONS and in reset(), and renaming one silently
# orphans a save. What was wrong was showing them to the player, which three
# places did by calling region.capitalize() - so the game said "Carsi",
# "Phoco", "Elalto", "Champdemars", "Lowereast" and "Kitaygorod", none of which
# is the name of anywhere.
#
# Three of the ids are also not places at all. `terrace`, `highstreet` and
# `carsi` are TYPES - a terraced street, a shopping street, a covered market -
# in a game whose whole claim is that places are specific and that being unable
# to name one is what it is like to be new. They get real names here: Nunhead
# and Rye Lane, a real pair a fifteen-minute walk apart, and the Kapalicarsi,
# which is the actual covered market Arda runs tea through.
#
# Latin script with the local marks dropped the way the rest of the game writes
# them, so that everything the player reads can be sounded out.
const DISTRICT_NAMES := {
	# Berlin
	"kiez": "the Kiez", "mitte": "Mitte", "prenzlberg": "Prenzlauer Berg",
	"kreuzberg": "Kreuzberg",
	# Zurich
	"niederdorf": "Niederdorf", "langstrasse": "Langstrasse",
	"zurichwest": "Zurich West", "seefeld": "Seefeld", "oerlikon": "Oerlikon",
	# Hanoi
	"phoco": "Pho Co", "longbien": "Long Bien", "badinh": "Ba Dinh",
	"tayho": "Tay Ho", "dongda": "Dong Da",
	# London
	"terrace": "Nunhead", "highstreet": "Rye Lane",
	"docklands": "the Docklands", "soho": "Soho", "brixton": "Brixton",
	# Tokyo
	"yanaka": "Yanaka", "jinbocho": "Jinbocho", "shinbashi": "Shinbashi",
	"asakusa": "Asakusa", "ueno": "Ueno",
	# Rome
	"testaccio": "Testaccio", "esquilino": "Esquilino",
	"trastevere": "Trastevere", "monti": "Monti", "garbatella": "Garbatella",
	# Moscow
	"kitaygorod": "Kitay-gorod", "basmanny": "Basmanny",
	"izmaylovo": "Izmaylovo", "zamoskvorechye": "Zamoskvorechye",
	"arbat": "the Arbat",
	# Mexico City
	"merced": "La Merced", "juarez": "Juarez", "coyoacan": "Coyoacan",
	"roma": "Roma", "condesa": "Condesa",
	# Sao Paulo
	"liberdade": "Liberdade", "bixiga": "Bixiga", "mercadao": "the Mercadao",
	"vilamadalena": "Vila Madalena", "paulista": "Paulista",
	# Dakar
	"medina": "the Medina", "sandaga": "Sandaga", "ouakam": "Ouakam",
	"yoff": "Yoff", "plateau": "the Plateau",
	# Tbilisi
	"sololaki": "Sololaki", "dezerter": "the Dezerter Bazaar",
	"avlabari": "Avlabari", "saburtalo": "Saburtalo", "chugureti": "Chugureti",
	# Seoul
	"euljiro": "Euljiro", "jongno": "Jongno", "mangwon": "Mangwon",
	"seongsu": "Seongsu", "hongdae": "Hongdae",
	# Mumbai
	"bhuleshwar": "Bhuleshwar", "chorbazaar": "Chor Bazaar",
	"byculla": "Byculla", "bandra": "Bandra", "colaba": "Colaba",
	# Istanbul
	"carsi": "the Kapalicarsi", "han": "the han", "karakoy": "Karakoy",
	"beyoglu": "Beyoglu", "kadikoy": "Kadikoy",
	# La Paz
	"elalto": "El Alto", "rodriguez": "the Rodriguez market",
	"sopocachi": "Sopocachi", "irpavi": "Irpavi", "sanpedro": "San Pedro",
	# Paris
	"champdemars": "the Champ de Mars", "marais": "the Marais",
	"montmartre": "Montmartre", "belleville": "Belleville",
	"ladefense": "La Defense",
	# Sydney
	"circularquay": "Circular Quay", "cbd": "the CBD", "newtown": "Newtown",
	"bondi": "Bondi", "cabramatta": "Cabramatta",
	# Honolulu
	"waikiki": "Waikiki", "chinatown": "Chinatown", "kakaako": "Kakaako",
	"manoa": "Manoa", "northshore": "the North Shore",
	# New York
	"midtown": "Midtown", "lowereast": "the Lower East Side",
	"harlem": "Harlem", "williamsburg": "Williamsburg",
	"jacksonheights": "Jackson Heights",
	# Toronto
	"downtown": "Downtown", "kensington": "Kensington Market",
	"gerrard": "the Gerrard India Bazaar",
	"distillery": "the Distillery District", "scarborough": "Scarborough",
}


# What to call a district on screen. Never the id.
func region_name(region: String) -> String:
	if region.is_empty():
		return city_name()
	return String(DISTRICT_NAMES.get(region, region.capitalize()))


# Every district in the game, flat. reset(), the reputation dict and the
# wallet all build from these — keeping hand-written copies of the same
# list in sync is exactly how eight reputation buckets went missing once.
static func all_regions() -> Array:
	var out: Array = []
	for c in CITY_REGIONS.keys():
		for r in CITY_REGIONS[c]:
			out.append(String(r))
	return out


static func fresh_reputation() -> Dictionary:
	var out: Dictionary = {}
	for r in all_regions():
		out[String(r)] = 0
	return out


# One pocket per currency in the game.
static func fresh_wallet() -> Dictionary:
	var out: Dictionary = {}
	for cur in RATES.keys():
		out[String(cur)] = 0
	return out




var play_time: float = 0.0
var current_region: String = "kiez"

# Cash in the CURRENT city's currency. Backed by `wallet` so every existing
# `money -= price` still works, but travelling changes which pocket it reads.
var money: int:
	get:
		return int(wallet.get(currency(), 0))
	set(value):
		wallet[currency()] = value

var inventory: Dictionary = {}       # item_id -> count
var region_visits: Dictionary = {}   # region -> times entered
var world_flags: Dictionary = {}     # one-shot world state, e.g. "kiez_pouch_taken"

# quests[id] = {"title": String, "steps": [{"text": String, "done": bool}], "completed": bool}
# Insertion order doubles as display order.
var quests: Dictionary = {}

# Which hotel floor the player is on (0 = lobby); set before floor transitions
var hotel_floor: int = 0

# ── Travel, currency, story ──────────────────────────────────────────────────
var city: String = "berlin"
var wallet: Dictionary = fresh_wallet()

var active_job: String = ""          # job_id currently accepted, "" if none
var job_progress: int = 0
var jobs_done: Dictionary = {}       # job_id -> times completed

# Legacy tools/backgrounds still use these two lighting keys.
var time_of_day: String:
	get:
		return "morning" if is_morning() else "dawn"
	set(value):
		clock_minutes = floorf((clock_minutes + CLOCK.offset(city)) / 1440.0) * 1440.0 \
			+ (480.0 if value == "morning" else CLOCK.START) - CLOCK.offset(city)
		if clock_minutes < 0.0: clock_minutes += 1440.0


# How far to step clear of a doorway when arriving through it, so the player
# does not spawn inside the exit's own trigger area and immediately bounce back.
const DOOR_STEP := Vector2(0, 58)


# Where to stand when arriving through a door. Stepping straight down works for
# a door in a building frontage, but an interior's door is on the LEFT wall, so
# stepping down just puts you against that wall — which is what "it spawns me
# near a wall close to the door" was. Step away from whichever edge the door is
# against, so you always arrive facing into the room.
func _step_off_door(door: Vector2) -> Vector2:
	# Deliberately close — you should arrive standing IN the door's trigger, so
	# the "E" prompt is already showing and the door is behind you rather than
	# somewhere you have to go and find.
	if door.x < 200.0:
		return door + Vector2(38.0, 26.0)      # door on the left wall
	if door.x > 960.0:
		return door + Vector2(-38.0, 26.0)     # door on the right wall
	return door + Vector2(0.0, 30.0)           # door in the frontage ahead


# Put the player at the door that leads back where they just came from.
#
# Every SceneExit records the scene it was in before the transition, so the
# destination can find its matching door by target_scene and stand the player
# in front of it. This is why leaving the hotel puts you on the hotel's step
# rather than wherever the scene's default spawn happens to sit — and it keeps
# working when a door is added, which a hand-written spawn table does not.
func place_at_return_door(root: Node, player: Node2D) -> bool:
	if last_scene.is_empty() or player == null or root == null:
		return false
	var doors: Array = []
	var marked: Node2D = null
	for child in root.get_children():
		var t: Variant = child.get("target_scene")
		if t == null or not (child is Node2D):
			continue
		doors.append(child)
		if bool(child.get("is_return")):
			marked = child as Node2D
		if String(t) == last_scene:
			player.position = _step_off_door((child as Node2D).position)
			return true
	# No door declares the scene we just left, which is the normal case for
	# a hub: a transit hall serves four districts and cannot name them all.
	# The door marked as the way back is the one we came in through, and
	# failing that, a room with exactly one door has only one answer.
	if marked != null:
		player.position = _step_off_door(marked.position)
		return true
	if doors.size() == 1:
		player.position = _step_off_door((doors[0] as Node2D).position)
		return true
	return false


func is_morning() -> bool:
	var hour := CLOCK.local_minute(clock_minutes, city) / 60.0
	return hour >= 7.0 and hour < 20.0


func day_part() -> String:
	return CLOCK.day_part(clock_minutes, city)


func clock_text() -> String:
	return CLOCK.text_at(clock_minutes, city)


func advance_clock(minutes: float) -> void:
	if not is_finite(minutes) or minutes <= 0.0: return
	var previous := clock_minutes
	clock_minutes = minf(clock_minutes + minutes, CLOCK.MAX_MINUTES)
	# Berlin's appointments become ready at 08:00 and never expire.
	if floorf((previous - 480.0) / 1440.0) != floorf((clock_minutes - 480.0) / 1440.0):
		Story.guide()


func clock_can_run() -> bool:
	var scene := get_tree().current_scene
	if scene == null or not scene.scene_file_path.begins_with("res://scenes/world/"): return false
	if get_tree().paused or TransitionManager._busy or Journey.busy: return false
	if not get_tree().get_nodes_in_group("flight_cutscene").is_empty(): return false
	for group: String in ["dialogue_box", "thought_box"]:
		var overlay := get_tree().get_first_node_in_group(group)
		if overlay != null and overlay.visible: return false
	var film := get_tree().get_first_node_in_group("cutscene")
	if film != null and film._open: return false
	for director in get_tree().get_nodes_in_group("story_director"):
		if director.running(): return false
	return true


func rest_until(hour: int = 8) -> void:
	advance_clock(CLOCK.next_hour(clock_minutes, city, hour) - clock_minutes)
var spawn_tag: String = ""           # set by SceneExit before a transition
var last_scene: String = ""          # the scene we just left, for return spawns
# Where the player was standing when they walked into the room they are in
# now. `last_scene` is cleared the moment a scene finishes arriving; this
# survives the whole visit, so a door marked as the way back knows where
# back is. A transit hall used to send everyone out into the one district
# its exit happened to name, whichever of the four they had come in from.
var entered_from: String = ""

# Set by SaveManager.load_game so the first scene _ready after loading doesn't
# count as a fresh visit (which would advance NPC dialogue rounds on load).
var skip_next_visit_count: bool = false

# familiarity[language][word] = 0-100
var familiarity: Dictionary = {}

func _process(delta: float) -> void:
	play_time += delta
	advance_exploration(delta, get_tree().root.has_focus())


func advance_exploration(delta: float, focused: bool) -> void:
	if focused and clock_can_run():
		advance_clock(minf(delta, 1.0) * CLOCK.MINUTES_PER_SECOND)

const TIER_UNKNOWN  = 0
const TIER_GLIMPSED = 1
const TIER_PARTIAL  = 2
const TIER_KNOWN    = 3

# What one encounter with a word is worth, out of the 100 that is fluency.
#
# Two things were wrong with the first numbers. The smaller one is that they
# were too mean: a six-letter word heard in conversation moved 4 points, so it
# took twenty separate hearings to reach the journal, and no player hears one
# word twenty times in a city they are passing through. Most vocabulary in the
# game was therefore unreachable in normal play.
#
# The larger one is that "see" was not a key here. Every district activity
# teaches its words with expose(..., "see") - a hundred and ten `learn` entries
# across the ninety-nine spots - and .get() returned 0 for all of them, so the
# single richest source of vocabulary in the game granted nothing at all.
#
# Tuned so that a word met in an ordinary way lands: about three encounters to
# glimpse it, five to read it, seven to know it.
const EXPOSURE_GAIN = {
	"hear":    12,   # somebody said it near you
	"read":    14,   # it was written on something
	"see":     16,   # a district showed you the thing and named it
	"used":    20,   # you said it, and were understood
	"pointed": 26,   # somebody pointed at the object and said the word
	# You acted on what you thought it meant and the world confirmed it. The
	# strongest encounter there is: nobody told you, you found out.
	"understood": 34,
	# A found word, met again somewhere new and recognised (scenes/ui/Notebook).
	"recalled": 14,
}

# An exposure type nobody declared. It used to be worth nothing, silently,
# which is how "see" went unnoticed for ninety-nine districts. Now it is worth
# a hearing and says so in the log.
const EXPOSURE_FALLBACK := 12

# Reputation per region: -100 to +100. The raw number is never shown —
# the player only ever sees the level name via reputation_level().
# Reputation per region: -100 to +100. The raw number is never shown — the
# player only ever sees the level name via reputation_level(). Built from
# CITY_REGIONS, so a new district cannot be forgotten here.
var reputation: Dictionary = fresh_reputation()


# How the neighbourhood talks about you, from their side of the counter
const REP_LEVELS := [
	[60,    "practically a neighbour"],
	[35,    "a friendly face"],
	[15,    "the curious one"],
	[-10,   "a stranger"],
	[-30,   "that odd one"],
	[-9999, "trouble"],
]


func reputation_level(region: String) -> String:
	var r := int(reputation.get(region, 0))
	for lv in REP_LEVELS:
		if r >= int(lv[0]):
			return String(lv[1])
	return "a stranger"


func get_familiarity(language: String, word: String) -> int:
	if not familiarity.has(language):
		return 0
	return familiarity[language].get(word.to_lower(), 0)


func get_tier(language: String, word: String) -> int:
	var score := get_familiarity(language, word)
	if score >= 80:
		return TIER_KNOWN
	elif score >= 50:
		return TIER_PARTIAL
	elif score >= 25:
		return TIER_GLIMPSED
	return TIER_UNKNOWN


func expose(language: String, word: String, exposure_type: String) -> void:
	word = word.to_lower()
	if language.is_empty() or word.is_empty():
		return
	# Familiar sounds and meanings discovered in context are separate evidence.
	# Merely hearing a sentence must not unlock its dictionary translation.
	var observations: Dictionary = world_flags.get("word_observations", {})
	var language_notes: Dictionary = observations.get(language, {})
	var encounters: Dictionary = language_notes.get(word, {})
	encounters[exposure_type] = int(encounters.get(exposure_type, 0)) + 1
	language_notes[word] = encounters
	observations[language] = language_notes
	world_flags["word_observations"] = observations
	if not familiarity.has(language):
		familiarity[language] = {}
	var current: int = familiarity[language].get(word, 0)
	var base_gain: int = EXPOSURE_GAIN.get(exposure_type, 0)
	if base_gain == 0 and not EXPOSURE_GAIN.has(exposure_type):
		push_warning("GameState.expose: unknown exposure type '%s' for '%s'"
			% [exposure_type, word])
		base_gain = EXPOSURE_FALLBACK
	var gain: int = roundi(float(base_gain) * _word_ease(word))
	# The first time a word lands it lands hardest. Noticing a word at all is
	# most of the work, and it is the encounter a player actually remembers.
	if current == 0:
		gain = roundi(float(gain) * 1.4)
	var old_tier := get_tier(language, word)
	familiarity[language][word] = min(100, current + gain)
	var new_tier := get_tier(language, word)
	if new_tier > old_tier:
		word_tier_changed.emit(language, word, new_tier)
		# The word you just learned may be the tenth, which is the one that
		# makes a person in this city audible to you.
		_thread()


func _word_ease(word: String) -> float:
	var n := word.length()
	var ease: float
	if n <= 3:
		ease = 2.0
	elif n <= 5:
		ease = 1.4
	elif n <= 7:
		ease = 1.0
	elif n <= 9:
		ease = 0.85
	else:
		ease = 0.70
	# A long word is harder, not impossible. The old floor of 0.4 meant
	# `Fahrkartenautomat` needed thirty encounters, which is not difficulty,
	# it is a word the game had decided you would never learn.
	for ch: String in ["ä", "ö", "ü", "ß"]:
		if word.contains(ch):
			ease *= 0.85
			break
	return ease


signal reputation_changed(region: String, level: String)


# Create the bucket if it does not exist. It used to require the key to be
# present, and only Berlin's three regions were — so every reputation change in
# London and Istanbul was silently discarded, including the whole Yusuf ladder.
# ── How he addresses people ──────────────────────────────────────────────────
#
# Which rung of a language's ladder he is currently using, per language. Per
# language rather than per person because that is how it actually works: you
# settle into a way of talking to a place, and then one particular person turns
# out to want something else from you.
#
# Saved. It is a habit, not a session.
const REGISTER := preload("res://autoload/Register.gd")
# When a silence stops being a pause, and how many times you say no first.
const RITUAL := preload("res://autoload/Ritual.gd")

var address: Dictionary = {}      # language -> rung id


func register_for(language: String = "") -> String:
	var lang: String = language if not language.is_empty() else local_language()
	if not REGISTER.has_ladder(lang):
		return ""
	var cur: String = String(address.get(lang, ""))
	if cur.is_empty() or REGISTER.index_of(lang, cur) < 0:
		# Where a stranger starts. Not where the city is warmest.
		return REGISTER.default_rung(lang)
	return cur


func set_register(rung: String, language: String = "") -> void:
	var lang: String = language if not language.is_empty() else local_language()
	if not REGISTER.has_ladder(lang) or REGISTER.index_of(lang, rung) < 0:
		return
	address[lang] = rung


# What the person in front of him expects, out of their age and how well this
# city thinks of him. None of it is authored per person: the roster already
# carries everybody's build and the world already carries the standing.
func register_expected(who: Dictionary, language: String = "") -> String:
	var lang: String = language if not language.is_empty() else local_language()
	# A person can simply want something the average of their age and this
	# city's opinion of him would not predict. Kerstin has said du to everybody
	# who has ever come into the Späti; Emil keeps Sie until he offers otherwise.
	# That difference between two neighbours is the lesson, so it is authored.
	var wants: String = String(who.get("wants", ""))
	if not wants.is_empty() and REGISTER.index_of(lang, wants) >= 0:
		return wants
	return REGISTER.expected(lang, who, city_reputation())


# ── What he has actually worked out ──────────────────────────────────────────
#
# Familiarity is how often a word has gone past him. This is different: the
# words whose meaning he tested - by acting on a guess and watching what the
# world did - and found out. It is what the journal shows as understood, and
# it keeps the wrong first guess, because the wrong guess is usually how the
# word was learned.
#
# Kept in world_flags so it saves with everything else:
#   world_flags["understood"][language][word] = {meaning, moment, first}

func understand(language: String, word: String, meaning: String,
		moment: String = "") -> bool:
	word = word.to_lower()
	var book: Dictionary = world_flags.get("understood", {})
	var shelf: Dictionary = book.get(language, {})
	var entry: Dictionary = shelf.get(word, {})
	var fresh: bool = String(entry.get("meaning", "")).is_empty()
	entry["meaning"] = meaning
	if fresh or String(entry.get("moment", "")).is_empty():
		entry["moment"] = moment
	if fresh:
		# When, so hearing it again a minute from now counts as meeting it
		# again, and hearing it in the same breath does not.
		entry["found_at"] = play_time
	shelf[word] = entry
	book[language] = shelf
	world_flags["understood"] = book
	if fresh:
		expose(language, word, "understood")
	return fresh


# He acted on a wrong guess. Remembered, not scored: the first wrong reading is
# kept only if nothing has been understood about this word yet.
func misunderstand(language: String, word: String, thought: String) -> void:
	word = word.to_lower()
	var book: Dictionary = world_flags.get("understood", {})
	var shelf: Dictionary = book.get(language, {})
	var entry: Dictionary = shelf.get(word, {})
	if String(entry.get("first", "")).is_empty():
		entry["first"] = thought
		expose(language, word, "hear")
	shelf[word] = entry
	book[language] = shelf
	world_flags["understood"] = book


func understanding(language: String, word: String) -> Dictionary:
	var book: Dictionary = world_flags.get("understood", {})
	return Dictionary(book.get(language, {})).get(word.to_lower(), {})


# How far off he is, and which way. Zero is right; positive is too formal and
# negative too familiar. They are different mistakes and they cost differently.
func register_slip(who: Dictionary, language: String = "") -> int:
	var lang: String = language if not language.is_empty() else local_language()
	if not REGISTER.has_ladder(lang):
		return 0
	var want: String = register_expected(who, lang)
	var used: String = register_for(lang)
	if want.is_empty() or used.is_empty():
		return 0
	return REGISTER.index_of(lang, used) - REGISTER.index_of(lang, want)


func change_reputation(region: String, delta: int) -> void:
	if region.is_empty():
		return
	var before: String = reputation_level(region)
	var cur: int = int(reputation.get(region, 0))
	reputation[region] = clampi(cur + delta, -100, 100)
	var after: String = reputation_level(region)
	if after != before:
		reputation_changed.emit(region, after)


# ── Standing, per city ────────────────────────────────────────────────────────
# You arrive a stranger everywhere and climb separately in each place. Being
# practically a neighbour in Berlin buys you nothing in Istanbul, which is the
# entire joke of arriving somewhere new for the third time.

const CITY_REP_LEVELS := [
	[70,   "one of us"],
	[45,   "a regular"],
	[25,   "a familiar face"],
	[10,   "the newcomer"],
	[-10,  "a stranger"],
	[-30,  "the odd one"],
	[-9999, "not welcome"],
]


# A city's standing is the average of its regions, so being loved in the han and
# resented in the çarşı leaves you merely tolerated in Istanbul.
func city_reputation(c: String = "") -> int:
	var target: String = c if not c.is_empty() else city
	var regions: Array = CITY_REGIONS.get(target, [])
	if regions.is_empty():
		return 0
	var total: int = 0
	for r in regions:
		total += int(reputation.get(String(r), 0))
	return int(round(float(total) / float(regions.size())))


func city_rep_level(c: String = "") -> String:
	var r: int = city_reputation(c)
	for lv in CITY_REP_LEVELS:
		if r >= int(lv[0]):
			return String(lv[1])
	return "a stranger"


# ── Fluency ───────────────────────────────────────────────────────────────────
# What the player can actually say, which decides whether a dialogue option is
# offered as a gesture, a bare word, a fragment, or a whole sentence.
#
#   0  mute      — no words at all. Every option is something you do with your
#                  body, because that is all you have.
#   1  words     — a handful known. You can name a thing and point.
#   2  fragments — enough to stack two or three words and be understood badly.
#   3  sentences — you can say it properly, and be wrong about the tone instead.
#
# Counted from words at partial or better, because a word you can only half-read
# is not a word you can say.

const FLUENCY_MUTE      := 0
const FLUENCY_WORDS     := 1
const FLUENCY_FRAGMENTS := 2
const FLUENCY_SENTENCES := 3

const FLUENCY_STEPS := [3, 10, 22]   # words needed for tier 1, 2, 3


# What a dialogue option actually says, given what the player can say today.
#
# A response carries up to four versions of itself. Early on the alien has no
# words, so every option is something it does with its body; later the same
# intention comes out as a naming, then a stack of words, then a sentence — and
# by then the difficulty has moved from "can I say it" to "is this the right
# thing to say", which is the whole game.
#
#   gesture — mute. what you do with your hands, face, posture
#   words   — you can name the thing and point at it
#   frag    — two or three words stacked, understood badly
#   say     — a whole sentence, correct or incorrectly pitched
#
# Missing tiers fall back down to the richest one you do have, so a response
# only needs the variants that are actually different.
const PHRASE_TIERS := ["gesture", "words", "frag", "say"]


# ── The words in an option have to be words he has ───────────────────────────
#
# Fluency is a COUNT, and a count cannot tell you WHICH words. So a player who
# had picked up twenty-two words of anything was offered
#
#     "Bir ekmek alabilir miyim, abla?"
#
# whether or not one of those five words had ever been said to them - a whole
# sentence in a language the alien had, at that moment, no way of knowing. That
# is the one thing this game must never do. The subject is what it is like to
# not have the words; handing them over because a counter passed twenty-two
# undoes the subject.
#
# So a phrasing is only offered when he can actually say it. There are two ways
# to have a word:
#
#   learned    it is in the notebook at partial or better - the same threshold
#              that stops the street glyphing it, so the moment you can READ a
#              word is the moment you can SAY it
#   just said  it was in the sentence he is answering. Echoing a sound somebody
#              made at you a second ago takes no vocabulary at all, and it is
#              how most first words are actually acquired - so "Wiesn?" stays
#              available to somebody who has never heard the word before now.
#
# Anything the language has no notebook entry for - English, a name, a place -
# is not a word this game teaches and is not gated. English is never gated at
# all: he can read English, which is the joke London is built on.
const SPEECH_WORDS := preload("res://scenes/dialogue/Speech.gd")


func can_say(text: String, language: String = "", heard: Array = []) -> bool:
	var lang: String = language if not language.is_empty() else local_language()
	if lang.is_empty() or lang == "english" or text.is_empty():
		return true
	for w: String in SPEECH_WORDS.vocabulary_in(text, lang):
		if heard.has(w):
			continue
		if get_tier(lang, w) < TIER_PARTIAL:
			return false
	return true


func phrase_for(resp: Dictionary, heard: Array = []) -> String:
	var f: int = clampi(fluency(), 0, PHRASE_TIERS.size() - 1)
	var lang: String = local_language()
	for i in range(f, -1, -1):
		var key: String = String(PHRASE_TIERS[i])
		if not resp.has(key):
			continue
		var line: String = String(resp[key])
		# A gesture is an instruction in the player's language. Scanning it as
		# German hid "Step back" because "back" is also a German word.
		if key == "gesture" or can_say(line, lang, heard):
			return line
	# Nothing written for him that he can say yet. `text` is what he MEANT, in
	# his own terms, and Speech fills the local words into it as he learns them
	# - so the sentence above arrives one word at a time instead of all at once.
	return String(resp.get("text", resp.get("gesture", "Listen and look again")))


func words_usable(language: String) -> int:
	if not familiarity.has(language):
		return 0
	var n: int = 0
	for w in familiarity[language].keys():
		if int(familiarity[language][w]) >= 50:
			n += 1
	return n


# Everything the player can actually say, across every language they have
# touched. The endings read this: it is the difference between somebody who
# learned four hundred words and somebody who learned how to be understood.
# How many of the cities you have actually stood in. The ending used to
# count pieces of a machine; it counts places now, until the storyline
# that replaces the pod lands and gives it something better to count.
func cities_visited() -> int:
	var n: int = 0
	for id: String in CITIES.keys():
		if bool(world_flags.get("visited_" + id, false)):
			n += 1
	return n


func words_known() -> int:
	var n: int = 0
	for lang in familiarity.keys():
		n += words_usable(String(lang))
	return n


# The city that thinks best of you, and what it thinks. Returns ["", 0] if you
# have not managed to be anybody anywhere, which is a real outcome.
func best_city() -> Array:
	var top: String = ""
	var score: int = -101
	for c in CITIES.keys():
		if not bool(world_flags.get("visited_" + String(c), false)) 				and String(c) != "berlin":
			continue
		var r: int = city_reputation(String(c))
		if r > score:
			score = r
			top = String(c)
	return [top, maxi(score, 0)]


func fluency(language: String = "") -> int:
	var lang: String = language if not language.is_empty() else local_language()
	var n: int = words_usable(lang)
	var tier: int = FLUENCY_MUTE
	for i in range(FLUENCY_STEPS.size()):
		if n >= int(FLUENCY_STEPS[i]):
			tier = i + 1
	return tier


# ── Money & inventory ─────────────────────────────────────────────────────────

# Which city a district belongs to. Built from CITY_REGIONS so it cannot
# disagree with it.
static func city_of_region(region: String) -> String:
	for c in CITY_REGIONS.keys():
		if Array(CITY_REGIONS[c]).has(region):
			return String(c)
	return ""


func visit_region(region: String) -> int:
	# Standing in a district settles which city you are in.
	#
	# The dev console's `goto` loads any scene without touching `city`, so
	# teleporting to Karakoy left the game believing it was in Berlin - and
	# every lookup keyed on city:region missed, which is why the street said
	# it wanted nothing from you. Anything else that moves the player without
	# going through the airport had the same hole.
	var owner_city: String = city_of_region(region)
	if not owner_city.is_empty() and owner_city != city:
		city = owner_city
	return _visit_region(region)


func _visit_region(region: String) -> int:
	region_visits[region] = int(region_visits.get(region, 0)) + 1
	# Standing somewhere new can be the thing that finishes a step, and it is
	# also the moment the player most needs the log to say what is next.
	_thread()
	current_region = region
	return region_visits[region]


func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)


const DROPPED_ITEM := preload("res://scenes/world/DroppedItem.gd")


# Put a thing on the ground in front of him instead of into a panel.
#
# Buying used to be a number moving in a list nobody had open. It lands at his
# feet now, and walking over it is what actually hands it to him - which is
# where the word for it gets said. Everything that grants an object goes
# through here; add_item() stays the raw one, for loading a save and for the
# dev console.
#
# Falls back to granting outright when there is nowhere to put it: better a
# silent item than a lost one.
func drop_item(item: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		add_item(item)
		return
	var player := tree.get_first_node_in_group("player") as Node2D
	if player == null:
		add_item(item)
		Items.learn(item)
		return
	# Dropped beside the player, in the player's own branch, rather than into
	# `current_scene`: that is null whenever a scene is built into a viewport
	# rather than swapped in, which is exactly the situation a render tool is
	# in. The player's parent is the district either way.
	var host: Node = player.get_parent()
	if host == null:
		host = tree.current_scene
	if host == null:
		add_item(item)
		Items.learn(item)
		return
	var d: Node2D = DROPPED_ITEM.new()
	d.set("item", item)
	host.add_child(d)
	# A short throw towards the middle of the road, so it never lands inside
	# the counter he just bought it from.
	var side: float = -1.0 if player.global_position.x > 576.0 else 1.0
	d.global_position = player.global_position + Vector2(side * 46.0, 26.0)


func add_item(item: String, n: int = 1) -> void:
	inventory[item] = int(inventory.get(item, 0)) + n
	item_changed.emit(item, inventory[item])


# Whether the player is carrying something. Five services asked this and it
# did not exist, so the Fundbuero, the police desk, the hospital and Yusuf's
# shop all crashed outright the moment you spoke to them. check_calls.py only
# knew about class_name APIs, so an autoload could be missing a method that
# five call sites depended on and nothing said a word.
func has_item(item: String, n: int = 1) -> bool:
	return int(inventory.get(item, 0)) >= n


func remove_item(item: String, n: int = 1) -> bool:
	if int(inventory.get(item, 0)) < n:
		return false
	inventory[item] = int(inventory[item]) - n
	if int(inventory[item]) <= 0:
		inventory.erase(item)
	item_changed.emit(item, int(inventory.get(item, 0)))
	return true


func buy_bread() -> bool:
	Journey.ensure_funds(BREAD_PRICE)
	if money < BREAD_PRICE:
		return false
	money -= BREAD_PRICE
	money_changed.emit(money)
	drop_item("bread")
	# Pointing at the bread while paying is a strong exposure to the word
	expose("german", "brot", "pointed")
	change_reputation("kiez", 2)
	world_flags["bread_bought"] = true
	complete_quest_step("first_trade", 1)
	# The trade worked — next mystery: finding your way around
	if not quests.has("get_map"):
		start_quest("get_map", "Which way is anywhere?", [
			"Find the woman waiting under the yellow H sign",
			"Accept the folded paper she offers — it seems to know the streets",
		], [
			"res://scenes/world/Mitte.tscn",
			"res://scenes/world/Mitte.tscn",
		])
		if world_flags.get("renate_met", false):
			complete_quest_step("get_map", 0)
	return true


# ── Currency & travel ─────────────────────────────────────────────────────────

func currency() -> String:
	return String(CITIES.get(city, {}).get("currency", "EUR"))


func symbol() -> String:
	return String(CITIES.get(city, {}).get("symbol", "€"))


# The symbol and the name of any currency in the game, not just this city's.
# A bureau de change has to be able to say what it is holding out to you, and
# the alien reads the symbol long before he reads the word.
const CURRENCY_NAMES := {
	"EUR": ["€", "euro"],   "GBP": ["£", "pound"],  "CHF": ["Fr", "franc"],
	"TRY": ["₺", "lira"],   "JPY": ["¥", "yen"],    "RUB": ["₽", "rouble"],
	"MXN": ["$", "peso"],   "BRL": ["R$", "real"],  "XOF": ["F", "CFA franc"],
	"GEL": ["₾", "lari"],   "KRW": ["₩", "won"],    "INR": ["₹", "rupee"],
	"BOB": ["Bs", "boliviano"], "AUD": ["$", "Australian dollar"],
	"USD": ["$", "US dollar"], "CAD": ["$", "Canadian dollar"],
	"VND": ["₫", "dong"],
}


func currency_symbol(cur: String) -> String:
	return String(CURRENCY_NAMES.get(cur, ["?", cur])[0])


func currency_label(cur: String) -> String:
	var pair: Array = CURRENCY_NAMES.get(cur, ["", cur])
	return "%s %s" % [String(pair[0]), String(pair[1])]


# Every currency the player is holding that is not this city's, richest first.
# Travelling does not empty a pocket - it only changes which pocket the HUD is
# reading - so this is what is still sitting in the others.
func foreign_holdings() -> Array:
	var here: String = currency()
	var out: Array = []
	for cur: String in wallet.keys():
		if String(cur) == here:
			continue
		var amt: int = int(wallet[cur])
		if amt > 0:
			out.append({"cur": String(cur), "amount": amt})
	out.sort_custom(func(a, b): return _eur_value(a) > _eur_value(b))
	return out


func _eur_value(row: Dictionary) -> float:
	return float(row["amount"]) / float(RATES.get(String(row["cur"]), 1.0))


func city_name() -> String:
	return String(CITIES.get(city, {}).get("name", "Somewhere"))


func local_language() -> String:
	return String(CITIES.get(city, {}).get("language", "german"))


# The player's own guesses, for whichever language is currently baffling them.
# Dialogue tooltips and the journal both read through here rather than reaching
# for a specific table — so arriving in a new city quietly swaps the notebook.
func word_guesses() -> Dictionary:
	return guesses_for(local_language())


# The notebook for one named language, whichever city the player happens to be
# standing in. The journal needs this because it lists every language the
# player has met, not only the one outside the window.
func guesses_for(language: String) -> Dictionary:
	var out: Dictionary = {}
	if GUESSES.has_language(language):
		out = GUESSES.table(language).duplicate()
	else:
		out = GUESSES_WORLD.table(language).duplicate()
	for word: String in WORD_HINTS.WORDS.get(language, {}):
		out[word] = "— " + WORD_HINTS.meaning(language, word)
	return out


# One word's guess, or "" - the single call the journal and the dialogue box
# both want, so neither has to know which of the two tables holds it.
func word_guess(language: String, word: String) -> String:
	# Once he has found a word out, the notebook says what he found, not what
	# he first supposed.
	var found: String = String(understanding(language, word).get("meaning", ""))
	if not found.is_empty():
		return "✓ " + found
	var first: String = String(understanding(language, word).get("first", ""))
	if not first.is_empty():
		return "First thought: " + first
	var support: String = WORD_HINTS.meaning(language, word)
	if not support.is_empty():
		return "— " + support
	var observations: Dictionary = world_flags.get("word_observations", {})
	var evidence: Dictionary = Dictionary(observations.get(language, {})).get(word.to_lower(), {})
	if int(evidence.get("pointed", 0)) + int(evidence.get("see", 0)) > 0:
		return String(guesses_for(language).get(word.to_lower(), ""))
	return "— heard it; the meaning is still a question"


# The first guess, for a word he has since found out. The journal keeps both.
func first_guess(language: String, word: String) -> String:
	var got: Dictionary = understanding(language, word)
	var wrong: String = String(got.get("first", ""))
	if not wrong.is_empty():
		return wrong
	if String(got.get("meaning", "")).is_empty():
		return ""
	return String(guesses_for(language).get(word.to_lower(), "")).trim_prefix("— ")


func cash(cur: String) -> int:
	return int(wallet.get(cur, 0))


# How much of `to` you get for `amount` of `from`, after the booth's cut
func convert_preview(amount: int, from: String, to: String) -> int:
	if amount <= 0 or from == to:
		return 0
	var in_eur := float(amount) / float(RATES.get(from, 1.0))
	var out := in_eur * float(RATES.get(to, 1.0)) * (1.0 - EXCHANGE_FEE)
	return int(floor(out))


func exchange(amount: int, from: String, to: String) -> bool:
	if amount <= 0 or cash(from) < amount:
		return false
	var got := convert_preview(amount, from, to)
	if got <= 0:
		return false
	wallet[from] = cash(from) - amount
	wallet[to] = cash(to) + got
	money_changed.emit(money)
	return true


# A city you can actually land in. Istanbul is written before it is built, so
# the desk must not sell a ticket to a scene that does not exist yet — the
# alternative is a black screen and a lost fare.
func city_reachable(dest_city: String) -> bool:
	if not CITIES.has(dest_city):
		return false
	var scene: String = String(ARRIVALS.get(dest_city, ""))
	if scene.is_empty():
		return false
	return ResourceLoader.exists(scene)


func travel_to(dest_city: String) -> void:
	if not city_reachable(dest_city):
		return
	city = dest_city
	world_flags["visited_" + dest_city] = true
	money_changed.emit(money)


# ── Odd jobs ──────────────────────────────────────────────────────────────────

# ── Doing the work ───────────────────────────────────────────────────────────
#
# Taking a job used to be the whole job. You picked a card off the board, you
# walked to the ServicePoint the card named, and the money appeared - so
# "stack the delivery crates" was a fetch quest with the fetch taken out, and
# the only labour in a game about being a stranger who has to earn a room was
# pressing E in the right district.
#
# `carrying` is what is in his hands right now. It is deliberately NOT saved:
# you cannot be holding a crate across a save file, and a load that survived
# one would be a load with nowhere to put it down.
var carrying: String = ""


func accept_job(id: String) -> void:
	active_job = id
	job_progress = 0
	carrying = ""
	job_changed.emit(id)


# Picking a load up, and setting it down. Both are one line so that the world
# nodes stay about where things are rather than about what state means.
func carry_load(what: String) -> void:
	carrying = what
	job_changed.emit(active_job)


func drop_load() -> void:
	carrying = ""
	job_progress += 1
	job_changed.emit(active_job)


# ── What the work is worth, to the people who watched him do it ──────────────
#
# The other half of the thesis. Everything else in this game earns standing by
# saying something: the right word, the right register, the right number of
# refusals. None of that is available to somebody who has just arrived, and
# arriving is the part the game is about.
#
# Work is. Turning up, carrying the thing, bringing it back and handing it over
# is a way of being known that needs no vocabulary at all, and it was worth a
# flat plus one - the same whether it was the first time or the ninth.
#
# So it compounds. The first job is labour and anybody can do it. The third is
# somebody they ask for by now. Reliability is the only thing in this game that
# accrues without a word being said, and it should be able to carry a
# relationship as far as talking can - including, because standing is what
# moves it, all the way to being called `du`.
const WORK_STANDING := [2, 3, 5, 5, 6]


func work_standing(done_before: int) -> int:
	var i: int = clampi(done_before, 0, WORK_STANDING.size() - 1)
	return int(WORK_STANDING[i])


# `rep` of 0 means "work it out from how many times he has done this before",
# which is what every caller in the game wants. A caller that passes a number
# is asking for that number and gets it.
func finish_job(id: String, pay: int, rep: int = 0) -> void:
	if active_job != id:
		return
	active_job = ""
	job_progress = 0
	carrying = ""
	var done_before: int = int(jobs_done.get(id, 0))
	jobs_done[id] = done_before + 1
	add_money(pay)
	change_reputation(current_region,
		rep if rep != 0 else work_standing(done_before))
	job_changed.emit("")
	_thread()


func receive_map() -> void:
	if world_flags.get("has_map", false):
		return
	world_flags["has_map"] = true
	drop_item("karte")
	expose("german", "karte", "pointed")
	complete_quest_step("get_map", 1)
	# With a map in hand, the next problem is obvious: exhaustion
	if not quests.has("find_bed"):
		start_quest("find_bed", "A place to power down", [
			"Find the tall building with the bed sign",
			"Ask the person at the desk for a room",
			"Find the door that matches the card",
			"Rest",
		], [
			"res://scenes/world/HotelLobby.tscn",
			"res://scenes/world/HotelLobby.tscn",
			"res://scenes/world/HotelFloor.tscn",
			"res://scenes/world/HotelRoom.tscn",
		])


# What a bed costs, in the local currency. Berlin's is a pittance because
# Frau Weber decided it was; London's is not, and that is the point of London.
const ROOM_PRICES := {
	"berlin": 1,       "zurich": 90,      "hanoi": 250000,   "london": 14,
	"tokyo": 3500,     "rome": 30,        "moscow": 2200,    "mexico": 350,
	"saopaulo": 90,    "dakar": 9000,     "tbilisi": 45,     "seoul": 25000,
	"mumbai": 900,     "istanbul": 260,   "lapaz": 90,
	"paris": 34,       "sydney": 70,
	"honolulu": 95,    "newyork": 120,    "toronto": 80,
}


func room_price() -> int:
	return int(ROOM_PRICES.get(city, 1))


# A seat out of `from`, in that city's money. Berlin sells in euros, Istanbul in
# lira, and the number on the board is never comparable to the last one you saw.
# What one ride costs here. La Paz is Bs 3 for the first line and Bs 2 for
# every transfer, which is the real tariff and also a nice joke about a city
# where nothing is one journey.
func transit_fare() -> int:
	return int(UBAHN_FARES.get(city, UBAHN_FARE))


func flight_fare(from: String = "") -> int:
	var depart: String = from if not from.is_empty() else city
	return int(FLIGHT_FARES.get(depart, FLIGHT_FARE))


# Have you slept in this city? Berlin also writes the bare "rested" flag, which
# the find_bed quest and the intro still read; everywhere else only the
# per-city one exists, because sleeping in Berlin should not count in London.
func rested_here(c: String = "") -> bool:
	var target: String = c if not c.is_empty() else city
	return bool(world_flags.get("rested_" + target, false))


func room_booked_here() -> bool:
	if city == "berlin":
		return bool(world_flags.get("room_booked", false))
	return bool(world_flags.get("room_booked_" + city, false))


# Booking away from Berlin. No map quest, no Frau Weber, nobody who knows you —
# just money, and a key handed over without the transaction meaning anything.
func book_room_away() -> bool:
	if room_booked_here():
		return true
	var price: int = room_price()
	Journey.ensure_funds(price)
	if money < price:
		return false
	money -= price
	money_changed.emit(money)
	world_flags["room_booked_" + city] = true
	change_reputation(current_region, 1)
	return true


func book_room() -> bool:
	if world_flags.get("room_booked", false):
		return true
	# No booking until the map quest is done — the story order matters
	if not world_flags.get("has_map", false):
		return false
	Journey.ensure_funds(room_price())
	if money < room_price():
		return false
	money -= room_price()
	money_changed.emit(money)
	world_flags["room_booked"] = true
	change_reputation("mitte", 1)   # a smooth transaction; Frau Weber approves
	drop_item("zimmerkarte")
	expose("german", "zimmer", "pointed")
	complete_quest_step("find_bed", 1)
	return true


# The story thread, asked to look at the world again.
#
# Reached through the tree rather than through the global, because Story is
# registered after this file in project.godot and several of the callers below
# can run while the autoloads are still being created - and a tool that builds
# a scene inside _initialize() runs before any of them are ready. A null here
# is not an error state, it is simply too early to have a story.
func _thread() -> void:
	# Reached off the loop's own root rather than as "/root/Story": an
	# absolute path resolves against the ACTIVE SCENE, and a --script tool has
	# no active scene, so every call from one of those printed an error and
	# did nothing. The tool that walks the whole storyline found this on its
	# first run, which is the entire reason it exists.
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var s: Node = tree.root.get_node_or_null("Story")
	if s != null and s.has_method("guide"):
		s.call("guide")


# ── Quests ────────────────────────────────────────────────────────────────────

# `targets` is optional and parallel to the steps: targets[i] is the scene the
# player has to reach to finish step i. It is what the arrow points at, and a
# step without one simply gets no arrow - some steps are decisions, not places.
func start_quest(id: String, title: String, step_texts: Array,
		targets: Array = []) -> void:
	if quests.has(id):
		return
	var steps := []
	for i in range(step_texts.size()):
		var tgt: String = String(targets[i]) if i < targets.size() else ""
		steps.append({"text": step_texts[i], "done": false, "target": tgt})
	quests[id] = {"title": title, "steps": steps, "completed": false}
	quest_updated.emit(id)


# Where the player is being sent right now: the target of the first unfinished
# step of the first unfinished quest, as a scene path. Empty when nothing in
# the log is asking them to be anywhere, which is most of the time and is not
# a fault - this game is largely about having nowhere in particular to be.
func quest_target() -> String:
	var arrival: Dictionary = Services.arrival_guidance()
	if not arrival.is_empty():
		return String(arrival.steps[0].target)
	var id: String = tracked_quest_id()
	if not id.is_empty():
		for st: Dictionary in quests[id].get("steps", []):
			if not bool(st.get("done", false)):
				return String(st.get("target", ""))
	return ""


func tracked_quest_id() -> String:
	# The story outranks the side of it: the ending once it is open, then this
	# city's chapter, then the way onward. An unfinished chapter elsewhere, a
	# job taken and left, or an old onboarding step stay in the log, in the
	# order they were opened, but never sit over the thread.
	if _quest_open("the_name"):
		return "the_name"
	var local_id: String = "journey_" + city
	if _quest_open(local_id):
		return local_id
	for id: String in quests.keys():
		if id.begins_with("onward_") and _quest_open(id):
			return id
	for id: String in quests.keys():
		if _quest_open(id):
			return id
	return ""


func _quest_open(id: String) -> bool:
	return quests.has(id) and not bool(quests[id].get("completed", false))


func complete_quest_step(id: String, idx: int) -> void:
	if not quests.has(id):
		return
	var q: Dictionary = quests[id]
	var steps: Array = q["steps"]
	if idx < 0 or idx >= steps.size():
		return
	if bool(steps[idx]["done"]):
		return
	steps[idx]["done"] = true
	var all_done := true
	for s in steps:
		if not bool(s["done"]):
			all_done = false
			break
	if all_done:
		q["completed"] = true
	quest_updated.emit(id)
	# Finishing one thing is exactly when the next thing should appear. Story
	# guards against coming back in here, so this cannot run away.
	_thread()


# Tick the final step of a quest by position rather than by literal index.
# Quest step lists are constructed at runtime, so a save made before a quest
# grew an extra step would never complete if the index were hard-coded.
func complete_last_step(id: String) -> void:
	if not quests.has(id):
		return
	var q: Dictionary = quests[id]
	var steps: Array = q["steps"]
	complete_quest_step(id, steps.size() - 1)


func reset() -> void:
	alien_appearance = APPEARANCE.DEFAULT.duplicate()
	play_time = 0.0
	current_region = "kiez"
	familiarity = {}
	address = {}
	reputation = fresh_reputation()
	city = "berlin"
	wallet = fresh_wallet()
	active_job = ""
	job_progress = 0
	carrying = ""
	jobs_done = {}
	inventory = {}
	region_visits = {}
	world_flags = {}
	quests = {}
	hotel_floor = 0
	clock_minutes = CLOCK.START
	spawn_tag = ""
	skip_next_visit_count = false
