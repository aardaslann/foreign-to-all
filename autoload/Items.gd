extends Node

const ITEM_ART := preload("res://scenes/world/ItemArt.gd")

# Everything the player can end up holding, and what it is CALLED where he
# picked it up.
#
# The registry used to live in Inventory.gd as ITEM_DEFS, which meant the only
# thing that knew what a loaf was called was the panel that listed it. Buying
# something is now an event with a word in it, so the word has to be somewhere
# both the pickup and the panel can read.
#
# Two facts per item:
#
#   what it IS          one line, in the alien's own voice - what he thinks he
#                       is holding, which is not always right
#   what it is CALLED   per language, because a ticket is a Fahrkarte in Berlin
#                       and a bilet in Istanbul and that IS the game
#
# Every word is Latin script. A word he cannot sound out is a box rather than a
# word, and the whole point of a pickup is that he can now say it.

const ITEMS := {
	"bread": {
		"name": "Bread", "color": Color(0.64, 0.48, 0.24), "eat": true, "shape": "round",
		"read": "Round, heavy, still warm underneath. I watched three people " +
			"in front of me buy exactly this and none of them looked at it.",
	},
	"cheese": {
		"name": "Cheese", "color": Color(0.82, 0.74, 0.38), "eat": true, "shape": "wedge",
		"read": "Pale, dense, and it smells like it has been decided about.",
	},
	"karte": {
		"name": "Map", "color": Color(0.75, 0.68, 0.50), "eat": false, "shape": "card",
		"read": "A folded paper of streets. It knows where things are, which " +
			"makes it the most powerful object I have been given.",
	},
	"ticket_ubahn": {
		"name": "Ticket", "color": Color(0.45, 0.70, 0.62), "eat": false, "shape": "card",
		"read": "A stiff paper rectangle. Permission to be carried somewhere.",
	},
	"zimmerkarte": {
		"name": "Room card", "color": Color(0.70, 0.62, 0.86), "eat": false,
		"shape": "card", "label": GameState.HOTEL_ROOM,
		"read": "A stiff card with three digits pressed into it: 3 0 4. " +
			"She said those three sounds at me twice and pointed up. It " +
			"opens exactly one door out of all the doors.",
	},
	"lost_parcel": {
		"name": "Paper parcel", "color": Color(0.72, 0.66, 0.52), "eat": false, "shape": "block",
		"read": "Signed for in triplicate, at a counter that would not look at " +
			"me until the form was right.",
	},
	"police_bag": {
		"name": "Evidence bag", "color": Color(0.58, 0.62, 0.72), "eat": false, "shape": "block",
		"read": "Sealed, numbered, and handed back by a man who never did " +
			"decide what I was.",
	},
	"hospital_dish": {
		"name": "Kidney dish", "color": Color(0.78, 0.82, 0.84), "eat": false, "shape": "wedge",
		"read": "They took something out of my side and gave me the dish it " +
			"landed in.",
	},
	"money": {
		"name": "Money", "color": Color(0.82, 0.68, 0.28), "eat": false,
		"shape": "round",
		"read": "Flat metal discs, stamped with faces and numbers. The " +
			"vendor was tapping discs like these on his counter this " +
			"morning. They must be what you trade here.

How many of " +
			"these is a lot? No idea.",
	},
	"charm_eye": {
		"name": "Glass eye", "color": Color(0.35, 0.58, 0.85), "eat": false, "shape": "round",
		"read": "Blue glass, off a cord above a doorway. He took it down " +
			"himself, which was the part that mattered.",
	},
}


# What each thing is called, per language. Latin script throughout: where a
# language does not use it, this is how the word SOUNDS, because that is what
# he is actually learning. A ticket is the clearest case in the game - twenty
# cities, twenty words, one identical stiff paper rectangle.
const WORDS := {
	"ticket_ubahn": {
		"german": "Fahrkarte",   "swissgerman": "Billett",  "english": "ticket",
		"turkish": "bilet",      "french": "ticket",        "italian": "biglietto",
		"russian": "bilet",      "spanish_mx": "boleto",    "spanish_bo": "pasaje",
		"portuguese": "bilhete", "japanese": "kippu",       "korean": "pyo",
		"hindi": "tikat",        "vietnamese": "ve",        "wolof": "tiket",
		"georgian": "bileti",
	},
	# The first word the game teaches by handing you the thing. He finds a
	# pouch of coins in the grass before he has met anybody, and until now the
	# game told him what it was FOR without ever telling him what it is
	# CALLED - which is the one thing this game is supposed to do.
	"money": {
		"german": "Geld",        "swissgerman": "Gald",     "english": "money",
		"turkish": "para",       "french": "argent",        "italian": "soldi",
		"russian": "dengi",      "spanish_mx": "dinero",    "spanish_bo": "plata",
		"portuguese": "dinheiro", "japanese": "okane",      "korean": "don",
		"hindi": "paisa",        "vietnamese": "tien",      "wolof": "xaalis",
		"georgian": "puli",
	},
	# Four things handed over a counter in whatever city you are standing in.
	# All four came out grey and captioned "nobody here has a word for it",
	# in twenty cities, which is a real answer for exactly none of them.
	"lost_parcel": {
		"german": "Paket",       "swissgerman": "Paket",    "english": "parcel",
		"turkish": "paket",      "french": "colis",         "italian": "pacco",
		"russian": "posylka",    "spanish_mx": "paquete",   "spanish_bo": "paquete",
		"portuguese": "pacote",  "japanese": "kozutsumi",   "korean": "sopo",
		"hindi": "parcel",       "vietnamese": "buu kien",  "wolof": "paket",
		"georgian": "amanati",
	},
	"police_bag": {
		"german": "Beutel",      "swissgerman": "Sackli",   "english": "bag",
		"turkish": "torba",      "french": "sachet",        "italian": "busta",
		"russian": "paket",      "spanish_mx": "bolsa",     "spanish_bo": "bolsa",
		"portuguese": "saco",    "japanese": "fukuro",      "korean": "bongtu",
		"hindi": "thaila",       "vietnamese": "tui",       "wolof": "mbuus",
		"georgian": "parki",
	},
	"hospital_dish": {
		"german": "Schale",      "swissgerman": "Schale",   "english": "dish",
		"turkish": "kase",       "french": "cuvette",       "italian": "vaschetta",
		"russian": "lotok",      "spanish_mx": "riñonera",  "spanish_bo": "bandeja",
		"portuguese": "cuba",    "japanese": "toray",       "korean": "jaengban",
		"hindi": "tashtari",     "vietnamese": "khay",      "wolof": "plato",
		"georgian": "tasi",
	},
	"charm_eye": {
		"german": "Nazar",       "swissgerman": "Nazar",    "english": "eye charm",
		"turkish": "nazar boncugu", "french": "oeil",       "italian": "occhio",
		"russian": "amulet",     "spanish_mx": "ojo",       "spanish_bo": "ojo",
		"portuguese": "olho",    "japanese": "omamori",     "korean": "bujeok",
		"hindi": "nazar",        "vietnamese": "bua",       "wolof": "teere",
		"georgian": "tvali",
	},
	"bread": {
		"german": "Brot",        "swissgerman": "Brot",     "english": "bread",
		"turkish": "ekmek",      "french": "pain",          "italian": "pane",
		"russian": "khleb",      "spanish_mx": "pan",       "spanish_bo": "pan",
		"portuguese": "pao",     "japanese": "pan",         "korean": "ppang",
		"hindi": "pav",          "vietnamese": "banh mi",   "wolof": "mburu",
		"georgian": "puri",
	},
	"cheese": {
		"german": "Kase",        "swissgerman": "Chas",     "english": "cheese",
		"turkish": "peynir",     "french": "fromage",       "italian": "formaggio",
		"russian": "syr",        "spanish_mx": "queso",     "spanish_bo": "queso",
		"portuguese": "queijo",  "japanese": "chiizu",      "korean": "chijeu",
		"hindi": "paneer",       "vietnamese": "pho mai",   "wolof": "fromaas",
		"georgian": "qveli",
	},
	"karte": {
		"german": "Karte",       "swissgerman": "Charte",   "english": "map",
		"turkish": "harita",     "french": "plan",          "italian": "mappa",
		"russian": "karta",      "spanish_mx": "mapa",      "spanish_bo": "mapa",
		"portuguese": "mapa",    "japanese": "chizu",       "korean": "jido",
		"hindi": "naksha",       "vietnamese": "ban do",    "wolof": "kart",
		"georgian": "ruka",
	},
	"zimmerkarte": {
		"german": "Zimmerkarte", "swissgerman": "Zimmercharte", "english": "room key",
		"turkish": "oda karti",  "french": "cle",           "italian": "chiave",
		"russian": "klyuch",     "spanish_mx": "llave",     "spanish_bo": "llave",
		"portuguese": "chave",   "japanese": "kagi",        "korean": "yeolsoe",
		"hindi": "chaabi",       "vietnamese": "chia khoa", "wolof": "kle",
		"georgian": "gasaghebi",
	},
}


# Anything you could put in your mouth. Kept as a list rather than a column,
# because a cone of spice and a cone of shave ice are the same shape and only
# one of them is dinner.
const FOOD := ["api", "apple", "arepa", "banh_mi", "bec", "bread", "cheese",
	"churchkhela", "cider", "falafel", "fruit_crate", "kebab", "menchi_katsu",
	"mortadela", "pastel", "potatoes", "quinto_quarto", "shave_ice", "simit",
	"sulguni", "tomatoes", "tostada", "yoff_fish"]

# The two tables, flattened into one at startup. The core items are written
# out longhand because they carry a word in every language; the district items
# are rows, because forty-one of them are not.
var _all: Dictionary = {}
var _all_words: Dictionary = {}


func _ready() -> void:
	_all = ITEMS.duplicate(true)
	_all_words = WORDS.duplicate(true)
	for id: String in SPOT_ITEMS.keys():
		var row: Array = SPOT_ITEMS[id]
		_all[id] = {
			"name": String(row[0]), "shape": String(row[1]),
			"color": row[2], "eat": FOOD.has(id), "read": String(row[5]),
		}
		var per: Dictionary = _all_words.get(id, {})
		per[String(row[3])] = String(row[4])
		_all_words[id] = per
	for id2: String in _all.keys():
		if FOOD.has(id2):
			_all[id2]["eat"] = true


func has(item: String) -> bool:
	return _all.has(item)


func info(item: String) -> Dictionary:
	return _all.get(item, {})


func display_name(item: String) -> String:
	var d: Dictionary = _all.get(item, {})
	return String(d.get("name", item.capitalize().replace("_", " ")))


func colour(item: String) -> Color:
	var d: Dictionary = _all.get(item, {})
	return d.get("color", Color(0.66, 0.62, 0.70))


func eatable(item: String) -> bool:
	var d: Dictionary = _all.get(item, {})
	return bool(d.get("eat", false))


# The alien's own reading of the thing, which is the only description in the
# game and is sometimes wrong on purpose.
func reading(item: String) -> String:
	var d: Dictionary = _all.get(item, {})
	return String(d.get("read", ""))


# What it is called where he is standing. Empty when nobody here has a word for
# it - which is a real answer for a kidney dish, and the pickup says so.
func word_for(item: String, language: String = "") -> String:
	var lang: String = language if not language.is_empty() else GameState.local_language()
	var per: Dictionary = _all_words.get(item, {})
	return String(per.get(lang, ""))


# The word plus the language it belongs to, for the journal. The journal is
# keyed by language, so an item picked up in Istanbul teaches Turkish even
# though the same object taught German in Berlin.
func learn(item: String) -> void:
	var lang: String = GameState.local_language()
	var word: String = word_for(item, lang)
	if word.is_empty():
		return
	# A word you were handed, with the object in your hands and somebody
	# pointing at it, is the strongest kind of exposure there is.
	GameState.expose(lang, word, "pointed")


# What is printed on it, if anything. A room card carries the one number the
# player has to remember, and it was said out loud exactly once, in a language
# they could not read at the time.
func label(item: String) -> String:
	var d: Dictionary = _all.get(item, {})
	return String(d.get("label", ""))


# The digits, drawn as blocks rather than as text. A font rasterised at four
# pixels and scaled up is a smear, which this project has already learned once
# - and three digits on a card is not a typography problem, it is five bars.
const DIGITS := {
	"0": ["111", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"],
	"5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"],
	"7": ["111", "001", "010", "010", "010"],
	"8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"],
}


func _stamp(ci: CanvasItem, at: Vector2, u: float, text: String,
		col: Color) -> void:
	var px: float = u * 0.42
	if px < 0.9:
		return
	var wide: float = float(text.length()) * 4.0 * px
	var x: float = at.x - wide * 0.5
	for i in range(text.length()):
		var rows: Array = DIGITS.get(text[i], [])
		for r in range(rows.size()):
			var row: String = String(rows[r])
			for cx in range(row.length()):
				if row[cx] == "1":
					ci.draw_rect(Rect2(x + float(cx) * px,
						at.y + float(r) * px, px, px), col)
		x += 4.0 * px


func shape(item: String) -> String:
	var d: Dictionary = _all.get(item, {})
	return String(d.get("shape", "block"))


# The object itself, drawn once for the whole game.
#
# It is drawn on the pavement where it lands and again, six times up, on the
# card that names it. Those were two copies of the same rectangle for about an
# hour, which is how a loaf ends up being a ticket in a different colour.
#
# `u` is one unit: the object is about 18 units across, so pass 1.0 on the
# street and 10.0 for the card.
func draw_item(ci: CanvasItem, at: Vector2, u: float, item: String) -> void:
	ITEM_ART.draw(ci, at, u, item)
	var mark := label(item)
	if not mark.is_empty():
		_stamp(ci, at + Vector2(2.4 * u, 2.6 * u), u, mark, Color("51445f"))


# ── What the districts hand over ─────────────────────────────────────────────
#
# Sixty-three grants across the ninety-nine spots, none of which were in the
# registry - so a loaf bought from a market stall came out grey and captioned
# "nobody here has a word for it", in Berlin, four steps from the man who
# sells it as Brot.
#
# One row per thing, because forty-two dictionaries of six keys is a wall
# nobody reads:
#
#   id: [ name, shape, colour, language, the local word, what he thinks it is ]
#
# The language is the one spoken where the district is, so the word he learns
# is the word he was actually handed.
const SPOT_ITEMS := {
"ameyoko_box":   ["Box of something", "block", Color8(186, 142, 84), "japanese", "hako",
	"Sold to me without being opened. Everyone around me bought one the same way."],
"api":           ["Purple drink", "round", Color8(112, 52, 108), "spanish_bo", "api",
	"Hot, purple, and made of corn, which I had understood to be a solid."],
"apple":         ["Apple", "round", Color8(176, 54, 48), "german", "Apfel",
	"He turned it over once before he let me have it. There was nothing wrong with either side."],
"arepa":         ["Arepa", "round", Color8(226, 200, 132), "english", "arepa",
	"Split and filled while I watched, by somebody having a different conversation."],
"banh_mi":       ["Filled roll", "block", Color8(214, 176, 118), "vietnamese", "banh mi",
	"A French loaf with a Vietnamese inside it, in Australia. Nobody found this remarkable."],
"bec":           ["Foil parcel", "block", Color8(196, 190, 176), "english", "bacon egg and cheese",
	"Ordered in four syllables by the man in front. I said all four and it worked."],
"brass_thing":   ["Brass object", "block", Color8(182, 142, 62), "hindi", "peetal",
	"Heavy, cold, and old enough that nobody in the lane could tell me what it had been for."],
"brixton_bag":   ["Carrier bag", "block", Color8(196, 76, 92), "english", "bag",
	"Handed over with both hands, which I have since learned was him being quick, not solemn."],
"causeway_thing":["Souvenir", "block", Color8(180, 96, 72), "hindi", "saaman",
	"The price started at four hundred and finished at ninety, and both of us were satisfied."],
"churchkhela":   ["Nut string", "block", Color8(126, 66, 74), "georgian", "churchkhela",
	"Nuts on a thread, dipped in grape until it set. It looks like a candle and is not one."],
"cider":         ["Cider", "card", Color8(198, 148, 56), "english", "cider",
	"Apples again, but argued with until they stopped being apples."],
"cloth":         ["Cut of cloth", "wedge", Color8(190, 82, 118), "english", "cloth",
	"Measured against her forearm rather than a rule, twice, and the two came out the same."],
"coat":          ["Coat", "block", Color8(62, 70, 92), "english", "coat",
	"Somebody else wore this out and somebody else again decided it was still a coat."],
"falafel":       ["Falafel", "round", Color8(146, 132, 62), "french", "falafel",
	"The queue went round the corner and everybody in it was patient, which in this city is the surprise."],
"fruit_crate":   ["Crate of fruit", "block", Color8(198, 148, 62), "vietnamese", "trai cay",
	"Carried on the front of a bicycle by somebody who could see none of the road."],
"kebab":         ["Kebab", "block", Color8(184, 108, 62), "swissgerman", "Kebab",
	"Open until four, in a city that closes at six. It is the only door still lit."],
"kermel_flowers":["Flowers", "round", Color8(206, 84, 108), "wolof", "toor-toor",
	"Bought for somebody else's house, because arriving at it without them is not done."],
"lei":           ["Lei", "round", Color8(224, 148, 172), "english", "lei",
	"Put over my head rather than into my hands, so refusing it was never offered."],
"market_bag":    ["Market bag", "block", Color8(150, 168, 116), "english", "bag",
	"Everybody in the hall had one and nobody had bought one today."],
"menchi_katsu":  ["Fried patty", "round", Color8(198, 142, 74), "japanese", "menchi katsu",
	"Handed over so hot it had to be held by its paper, which is how it is designed."],
"mortadela":     ["Sandwich", "block", Color8(212, 138, 142), "portuguese", "mortadela",
	"Enough meat in it for three people, sold to one, at eleven in the morning."],
"old_book":      ["Old book", "card", Color8(158, 124, 88), "japanese", "hon",
	"Every shopfront on that street faces north. Sunlight takes the colour out of a spine."],
"omikuji_bad":   ["Paper fortune", "card", Color8(216, 210, 194), "japanese", "omikuji",
	"A bad one. You tie it to the frame and leave it, so it stays with the shrine and not with you."],
"omikuji_good":  ["Paper fortune", "card", Color8(228, 224, 210), "japanese", "omikuji",
	"A good one. This one you keep, which is the only difference between them."],
"pastel":        ["Fried pastry", "wedge", Color8(220, 178, 96), "portuguese", "pastel",
	"Ordered by pointing at the one in front of me, which turned out to be the correct method."],
"portrait":      ["Portrait", "card", Color8(198, 186, 158), "french", "portrait",
	"He drew me in eleven minutes without once asking what I was."],
"potatoes":      ["Potatoes", "round", Color8(158, 122, 82), "spanish_bo", "papas",
	"She named four kinds and they were all potatoes, and she was right about all four."],
"quinto_quarto": ["Offal cut", "wedge", Color8(150, 62, 62), "italian", "quinto quarto",
	"The fifth quarter: what was left after the other four were paid out as wages."],
"shave_ice":     ["Shave ice", "round", Color8(150, 206, 224), "english", "shave ice",
	"Snow, in a place that has never had any, with syrup poured through it."],
"simit":         ["Sesame ring", "round", Color8(196, 142, 74), "turkish", "simit",
	"Off a glass cart, off the top of a head, off a tray on a pole. Never off a shelf."],
"soviet_badge":  ["Lapel badge", "round", Color8(180, 62, 58), "russian", "znachok",
	"Out of a tray of four hundred, all of a country that stopped existing before the seller did."],
"spice_cone":    ["Cone of spice", "wedge", Color8(198, 118, 48), "italian", "spezie",
	"Twisted shut at the top by a hand that has done it eleven thousand times."],
"spray_can":     ["Spray can", "card", Color8(96, 168, 176), "english", "spray can",
	"Given to me by somebody painting a wall that will be painted over next year, on purpose."],
"sulguni":       ["Cheese braid", "wedge", Color8(228, 220, 196), "georgian", "sulguni",
	"Plaited, salted, and squeaking against itself. It was cut off a larger plait with a wire."],
"tomatoes":      ["Tomatoes", "round", Color8(188, 62, 52), "german", "Tomaten",
	"I picked them up myself and was told off, and then shown which ones I should have picked."],
"tostada":       ["Tostada", "round", Color8(214, 176, 104), "spanish_mx", "tostada",
	"Flat, fried, and loaded past what it can carry, which appears to be the intention."],
"tower_charm":   ["Keyring", "round", Color8(174, 178, 186), "french", "porte-cle",
	"A very small copy of the very large thing behind the man selling it."],
"transit_card":  ["Transit card", "card", Color8(62, 118, 170), "turkish", "Istanbulkart",
	"One blue card for the tram, the boat, the funicular and the bus. I had been buying four things."],
"wax_cloth":     ["Wax print", "wedge", Color8(64, 132, 148), "wolof", "wax",
	"Sold by the six yards, never by the metre, so the pattern matches across all three pieces."],
"wax_votive":    ["Wax offering", "round", Color8(226, 216, 186), "hindi", "batti",
	"Lit, put down, and left burning by somebody who did not stay to watch it."],
"yoff_fish":     ["Fish", "wedge", Color8(150, 168, 184), "wolof", "jen",
	"Off the boat, up the beach, and into my hands before it had been weighed."],
}


# ── Eating it ────────────────────────────────────────────────────────────────
#
# Every food in the game shared one line - "Dense. Chewy. Warm. My first meal
# on this world" - so an apple in Berlin tasted of bread, and so did a fish
# off a boat in Dakar and a shave ice in Honolulu. The line was written for
# the loaf and never moved.
const EAT := {
	"bread": "Dense, chewy, still warm underneath. My first meal on this " +
		"world, and there is no word for this where I come from.",
	"apple": "It breaks with a sound. Cold, and so sharp it is almost a " +
		"mistake, and then it is not.",
	"cheese": "It resists, then gives all at once. Somebody decided this " +
		"was ready and I have to take their word for it.",
	"tomatoes": "Warm from the crate. It goes everywhere and nobody within " +
		"twenty metres thinks that is worth mentioning.",
	"simit": "Sesame, and a crust that shatters. Eaten walking, which " +
		"appears to be the only correct way.",
	"api": "Hot, purple, thick as soup, and made of corn. I was expecting a " +
		"drink and got a meal.",
	"arepa": "Split, filled, and handed over folded in paper. It is bread " +
		"and it is also a plate.",
	"banh_mi": "A French loaf doing something it was never asked to do, and " +
		"doing it far better.",
	"bec": "Foil, then paper, then something enormous. I understood four " +
		"syllables and received all of this.",
	"churchkhela": "Nuts on a thread under a skin of set grape. It looks " +
		"like a candle and is emphatically not one.",
	"cider": "Apples again, argued with until they stopped being apples.",
	"falafel": "Fried, green inside, and worth the queue that goes round " +
		"the corner without anybody complaining.",
	"fruit_crate": "Sweet to the point of being a decision. My hands will " +
		"be sticky for the rest of the day.",
	"kebab": "The only hot thing still being sold in this city, and it " +
		"knows it.",
	"menchi_katsu": "So hot it has to be held by its paper, which is why it " +
		"comes in paper.",
	"mortadela": "Enough meat in one sandwich for three people, sold to one " +
		"person, at eleven in the morning.",
	"pastel": "It shatters, then steams. I pointed at the one in front of " +
		"me and this was the correct method.",
	"potatoes": "She named four kinds and they were all potatoes and she " +
		"was right about every one of them.",
	"quinto_quarto": "The fifth quarter. What was left when the other four " +
		"were paid out as wages, cooked by people who had no choice and " +
		"perfected by people who did.",
	"shave_ice": "Snow, in a place that has never had any, with syrup " +
		"poured down through it.",
	"sulguni": "Salt, and a squeak against my own teeth. It was cut off a " +
		"larger plait with a wire.",
	"tostada": "Flat, fried, and loaded past what it can structurally " +
		"carry. That appears to be the intention.",
	"yoff_fish": "Off the boat, up the beach, onto a fire, into my hands. " +
		"Nothing in that sequence involved a shop.",
}


func eat_line(item: String) -> String:
	if EAT.has(item):
		return String(EAT[item])
	# Never the loaf's line for something that is not the loaf.
	return "I eat the %s. I have no idea whether I did that correctly." \
		% display_name(item).to_lower()


# What the thing is called in the language the PLAYER chose, which is not the
# language of the street they are standing in.
#
# The card shows the local word large - Apfel - and this underneath it, dimmer,
# so it is obvious which one is the thing being learned and which one is the
# translation. Without it the player is handed a word and no way to know what
# it means, which is the one place in this game where that is unhelpful rather
# than the point.
func translated_name(item: String) -> String:
	var ui: String = Loc.locale()
	# The five core objects carry a word in every game language already, and
	# where the player's language is one of them that IS the translation.
	var direct: String = word_for(item, _game_language_for(ui))
	if not direct.is_empty():
		return direct
	return display_name(item)


# The player's interface language, mapped to the language tag the word tables
# use. Most are the same string; a few of the game's tags are regional.
const UI_TO_GAME := {
	"en": "english", "de": "german", "fr": "french", "tr": "turkish",
	"ru": "russian", "es": "spanish_mx", "pt": "portuguese", "ja": "japanese",
	"ko": "korean", "hi": "hindi", "vi": "vietnamese", "it": "italian",
}


func _game_language_for(ui: String) -> String:
	return String(UI_TO_GAME.get(ui, ""))
