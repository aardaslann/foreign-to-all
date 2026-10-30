class_name CharacterArt
extends Object

const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
const ITEM_ART := preload("res://scenes/world/ItemArt.gd")

# Every person in this game, drawn once.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# There were three of them. CityNPC.gd drew the street with circles and
# rectangles; CutsceneArt.gd drew the cast with tapering polygons; and the
# player was authored pixel art. Three drawings of the same species, so a
# cutscene looked like a different game from the street it was shot on, and
# both looked like a different game from the man walking through them.
#
# ── Where the grid comes from ────────────────────────────────────────────────
#
# Not invented. ALIEN below was read out of art/player/strips/idle_down.png a
# pixel at a time - 26 rows of 16, twelve colours, nothing approximated. The
# human grid is that same silhouette with a human head in it, so the two
# cannot drift: they are the same drawing with a different top.
#
#     rows  0-3    antennae            the alien only; a person is blank here,
#                                      so he is 26 tall and they are 22
#     rows  4-14   head and hair       eleven rows, half the figure, and the
#                                      whole character language of this game
#     rows 15-22   a coat and a collar no arms; they stay inside it
#     rows 23-25   two stub legs
#
# One unit is 2 screen pixels on the street, because the sprite is drawn at 2x
# there. A cutscene passes whatever unit makes the figure the height it wants.

const W := 16
const H := 26
const FEET := 25          # the row the soles sit on
const BODY := 22          # soles to crown, antennae excluded

# Hair, clothes and the marks a named person has on their face. Preloaded
# rather than reached for by class_name, like everything else in this project:
# the global class cache is the editor's, and every tool here runs headless.
const WARDROBE := preload("res://scenes/npc/Wardrobe.gd")

# ── The player, straight off the sheet ───────────────────────────────────────
const ALIEN := [
	'....g......g....', '...XS......SX...', '...XSS....SSX...',
	'....XXXXXXXX....', '...XLLLLLSSSX...', '..XLLLLLSSSSSX..',
	'.XLLLLLSSSSSSHX.', '.XSLWEESSWEESHX.', '.XSLEEESSEEESHX.',
	'.XSLEEESSEEESHX.', '.XSLEEESSEEESHX.', '.XSSSSSSSSSSSHX.',
	'.XSSSSSHHSSSSHX.', '..XSSSSSSSSHHX..', '....XHHHHHHX....',
	'..OCCCCggCCCCO..', '.OCCCCCggCCCDDO.', '.OCCCCCCCCCDDDO.',
	'OCCCCCCCCCCDDDDO', 'OCCCCCCCCCDDDDDO', 'OCCCCCCCCDDDDDDO',
	'ODDDDDDDDDDDDDDO', 'OOOOOOOOOOOOOOOO', '....BBB..BBB....',
	'....BBB..BBB....', '....KKK..KKK....',
]

# ── Everybody else ───────────────────────────────────────────────────────────
#
# This is the figure off the design canvas "Foreign to All Key
# Characters", restated on the game's own 26-row grid. Rows 0-2 stay empty,
# because that is where the alien's antennae are and a person is measured
# against him.
#
# ── What it fixes, and why it is worth a whole renderer ──────────────────────
#
# The previous human was the ALIEN's body with a human head dropped into it:
# the same flaring coat, the same diagonal two-tone shading, the same three
# rows of boot. It matched the player sprite exactly, which was the argument
# for it - and it did not match the sheet the eight were designed on, which is
# what anybody holding the two up together sees first. Four things were wrong
# against that sheet, and every one of them is noticed before a coat colour is:
#
#   the head    seven rows of skull above the eyes, not three. Half the figure
#               is head; that is the visual language, and a person drawn with
#               a thin cap of hair and the eyes up under it reads as somebody
#               from a different game standing in this one
#   the eyes    mirrored, white with a pupil in it, whites to the outside. The
#               canvas is explicit - "two black rectangles read as goggles" -
#               and the old grid had both eyes facing the same way, which is
#               exactly what they read as
#   the coat    flat, straight-sided, one collar accent. The bell shape and
#               the diagonal shade were the alien's, and on a person they made
#               a shopkeeper look like a lamp
#   the feet    two stub legs and then shoes, rather than three rows of the
#               same dark block. Her shoes are half of who Nadia is
#
# ── The letters ──────────────────────────────────────────────────────────────
#
# The canvas names its colours differently to this game. Its shapes are kept
# and this game's letters are used, so every palette already written - the
# eight in Cast.gd, the fifty in CastRoster.gd, the crowd in look() - carries
# over without being retyped:
#
#   canvas H hair    -> R      canvas A collar  -> g
#   canvas c cuff    -> D      canvas L legs    -> B
#   canvas B shoes   -> K      canvas X, S, E, W, M unchanged
#
# Two letters stop being used by the base: L and H, the light and shadow skin
# of the old shaded face. The canvas face is flat, which is a large part of
# why it reads as drawn rather than as rendered. They stay in the palettes
# because a garment or a cut may still ask for them.
const HUMAN := [
	'................', '................', '................',
	'....XXXXXXXX....', '..XXRRRRRRRRXX..', '.XRRRRRRRRRRRRX.',
	'.XRRRRRRRRRRRRX.', '.XRRSSSSSSSSRRX.', '.XRSSSSSSSSSSRX.',
	'.XSSSSSSSSSSSSX.', '.XSSWESSSSEWSSX.', '.XSSWESSSSEWSSX.',
	'.XSSSSSSSSSSSSX.', '.XSSSSSMMSSSSSX.', '..XSSSSSSSSSSX..',
	'...XXSSSSSSXX...', '..XCCCCCCCCCCX..', '.XCCCCggggCCCCX.',
	'.XCCCCCCCCCCCCX.', '.XCCCCCCCCCCCCX.', '.XCCCCCCCCCCCCX.',
	'.XDDCCCCCCCCDDX.', '.XDCCCCCCCCCCDX.', '..XBBBX..XBBBX..',
	'..XKKKX..XKKKX..', '..XKKKX..XKKKX..',
]

# Which rows are what, once, so nothing has to count them again.
const ROW_EYES := 10         # and 11
const ROW_NECK := 15         # the last row that moves with the head
const ROW_LEGS := 23

# ── Hair, as overrides on the head rows ──────────────────────────────────────
# No bald: an unbroken egg reads as a figure somebody forgot to finish. The
# base already carries a full head of hair down to row 8, so a cut is what is
# DIFFERENT about this one - what sits above the crown, what hangs beside the
# face, or what is on the head instead of hair.
const CUTS := {
	"crop": {},
	"bob": {
		9: '.XRSSSSSSSSSSRX.', 10: '.XRSWESSSSEWSRX.', 11: '.XRSWESSSSEWSRX.',
		12: '.XRSSSSSSSSSSRX.',
	},
	"long": {
		9: '.XRSSSSSSSSSSRX.', 10: '.XRSWESSSSEWSRX.', 11: '.XRSWESSSSEWSRX.',
		12: '.XRSSSSSSSSSSRX.', 13: '.XRSSSSMMSSSSRX.',
		14: '..XRSSSSSSSSRX..',
	},
	"tied": {
		2: '.....RRRR.......', 3: '....XRRRRRRX....',
	},
	"cap": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..', 5: '.XPPPPPPPPPPPPX.',
		6: '.XPPPPPPPPPPPPX.', 7: '.XppSSSSSSSSppX.',
	},
	"wrap": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..', 5: '.XPPPPPPPPPPPPX.',
		6: '.XPPPPPPPPPPPPX.', 7: '.XPPSSSSSSSSPPX.', 8: '.XPSSSSSSSSSSPX.',
		9: '.XPSSSSSSSSSSPX.',
	},
	"scarf": {
		3: '....XPPPPPPX....', 4: '..XXPPPPPPPPXX..', 5: '.XPPPPPPPPPPPPX.',
		6: '.XPPPPPPPPPPPPX.', 14: '..XPSSSSSSSSPX..',
		15: '...XXPPPPPPXX...',
	},
}


# ── Colour, by role ──────────────────────────────────────────────────────────
# The alien's own, out of art/player/alien.gpl, by name.
const A_PAL := {
	"X": Color8(92, 76, 126),  "S": Color8(195, 178, 222),
	"L": Color8(222, 210, 240), "H": Color8(147, 127, 184),
	"E": Color8(42, 35, 64),   "W": Color8(244, 239, 255),
	"O": Color8(36, 71, 68),   "C": Color8(71, 131, 124),
	"D": Color8(53, 100, 94),  "g": Color8(226, 180, 92),
	"B": Color8(138, 98, 68),  "K": Color8(86, 64, 44),
	"R": Color8(92, 76, 126),  "M": Color8(120, 92, 150),
	"P": Color8(226, 180, 92),
}

# Skin as the triad the sprites use: mid, light, shadow.
const SKINS := [
	[Color8(240, 208, 180), Color8(250, 228, 206), Color8(206, 166, 134)],
	[Color8(232, 185, 138), Color8(244, 208, 166), Color8(192, 138, 92)],
	[Color8(226, 182, 148), Color8(240, 208, 180), Color8(188, 140, 104)],
	[Color8(216, 168, 120), Color8(236, 196, 152), Color8(176, 128, 80)],
	[Color8(200, 148, 104), Color8(224, 176, 136), Color8(160, 108, 68)],
	[Color8(168, 120, 80),  Color8(192, 148, 104), Color8(132, 88, 56)],
	[Color8(128, 88, 60),   Color8(158, 114, 80),  Color8(96, 62, 40)],
]

# Which bands a crowd is drawn from. Ranges, not values: every city on this
# itinerary is more mixed than one number would admit.
const PALETTE := {
	"berlin":   [0, 1, 2, 4],   "zurich":   [0, 0, 1, 2],
	"hanoi":    [1, 1, 2, 2],   "london":   [0, 1, 3, 5],
	"tokyo":    [0, 1, 1, 2],   "rome":     [1, 1, 2, 3],
	"moscow":   [0, 0, 1, 1],   "mexico":   [2, 3, 3, 4],
	"saopaulo": [0, 2, 4, 6],   "dakar":    [5, 5, 6, 6],
	"tbilisi":  [1, 1, 2, 2],   "seoul":    [0, 1, 1, 2],
	"mumbai":   [2, 3, 4, 5],   "istanbul": [1, 2, 2, 3],
	"lapaz":    [3, 3, 4, 4],   "paris":    [0, 1, 4, 5],
	"honolulu": [1, 2, 3, 4],   "newyork":  [0, 2, 4, 5],
	"toronto":  [0, 1, 3, 5],   "sydney":   [0, 1, 2, 5],
}

const HAIRS := [
	Color8(28, 24, 30), Color8(58, 44, 30), Color8(122, 84, 100),
	Color8(96, 64, 40), Color8(156, 122, 74), Color8(112, 108, 104),
	Color8(44, 36, 52), Color8(20, 18, 22),
]

const COATS := [
	Color8(92, 84, 116), Color8(60, 84, 120), Color8(42, 68, 64),
	Color8(107, 52, 72), Color8(176, 106, 46), Color8(150, 62, 52),
	Color8(78, 96, 74),  Color8(64, 62, 70),
]

const ACCENTS := [
	Color8(216, 180, 106), Color8(196, 88, 72), Color8(110, 140, 150),
	Color8(186, 178, 162), Color8(140, 108, 156), Color8(120, 156, 118),
]

const CUT_NAMES := ["crop", "crop", "bob", "long", "tied", "cap", "crop", "wrap",
	"scarf", "bob", "long", "crop"]

# How tall, and how they hold themselves. A crowd of one height is a crowd of
# clones, and it was the first thing anybody noticed about the new cast.
const BUILDS := ["adult", "adult", "adult", "youth", "elder", "adult",
	"youth", "elder", "adult", "child"]
const BUILD_H := {"child": 0.68, "youth": 0.93, "adult": 1.0, "elder": 0.92}

# A face is the cheapest way to tell two people apart at this size, and this
# art has room for exactly four of them.
const FACES := ["", "", "glasses", "", "moustache", "", "beard", "glasses",
	"", "moustache"]

# Rows the face marks overwrite. Kept here rather than inline so the grid
# stays one description of a person.
# Row 9 is the brow, 10-11 the eyes, 13 the mouth, 14-15 the jaw and neck.
const FACE_ROWS := {
	"glasses":   {9: ".XSKKKKSSKKKKSX."},
	"moustache": {12: ".XSSSMMMMMMSSSX."},
	"beard":     {12: ".XSSMMMMMMMMSSX.", 13: ".XSMMMMMMMMMMSX.",
		14: "..XMMMMMMMMMMX.."},
}


# What the people on a street have on, per city.
#
# The crowd wore one coat everywhere. Twenty cities, four seasons of climate
# between them, and Dakar's pavement and Moscow's looked identical because the
# only thing that changed was a hex triple. These are the garments actually on
# those streets, as a pool per city, picked per person - so a crowd is mixed,
# which every one of these places is, while still being recognisably ITS crowd.
const STREETWEAR := {
	"berlin":   ["coat", "puffer", "fleece", "hoodie", "coat"],
	"zurich":   ["goodcoat", "coat", "puffer", "suit", "coat"],
	"london":   ["puffer", "coat", "hoodie", "blazer", "coat"],
	"paris":    ["goodcoat", "coat", "coat", "suit", "puffer"],
	"moscow":   ["quilted", "puffer", "coat", "quilted", "housecoat"],
	"rome":     ["coat", "goodcoat", "openshirt", "coat", "suit"],
	"istanbul": ["coat", "tee", "shopcoat", "housecoat", "openshirt"],
	"tokyo":    ["coat", "suit", "shopcoat", "coat", "blazer"],
	"seoul":    ["puffer", "coat", "hoodie", "suit", "coat"],
	"mumbai":   ["kurta", "sari", "openshirt", "tee", "kurta"],
	"hanoi":    ["openshirt", "tee", "tracksuit", "apron", "openshirt"],
	"dakar":    ["boubou", "boubou", "openshirt", "kurta", "boubou"],
	"mexico":   ["tee", "openshirt", "marketapron", "coat", "tee"],
	"saopaulo": ["tee", "openshirt", "hoodie", "shopcoat", "tee"],
	"lapaz":    ["pollera", "coat", "quilted", "coat", "pollera"],
	"tbilisi":  ["coat", "housecoat", "openshirt", "coat", "quilted"],
	"honolulu": ["openshirt", "tee", "openshirt", "tee", "apron"],
	"newyork":  ["puffer", "coat", "hoodie", "suit", "coat"],
	"toronto":  ["puffer", "coat", "puffer", "hoodie", "coat"],
	"sydney":   ["tee", "openshirt", "hivis", "coat", "tee"],
}

# Anywhere the game has not been told about. A coat is the one garment that
# does not claim anything about a place it might be wrong about.
const STREETWEAR_DEFAULT := ["coat", "coat", "puffer", "hoodie"]

# Everything about a person that is not their pose, worked out from their id so
# the same person is the same person in every shot and on every street.
static func look(seed_i: int, city: String) -> Dictionary:
	var h: int = absi(seed_i * 2654435761) % 100003
	var band: Array = PALETTE.get(city, [1, 2, 3])
	var skin: Array = SKINS[int(band[h % band.size()])]
	var coat: Color = COATS[(h >> 3) % COATS.size()]
	var build: String = String(BUILDS[(h >> 21) % BUILDS.size()])
	var hair_i: int = (h >> 9) % HAIRS.size()
	# Grey by the time you are old, and children do not have beards.
	if build == "elder":
		hair_i = 5
	var face: String = String(FACES[(h >> 25) % FACES.size()])
	if build == "child" or build == "youth":
		face = "" if face != "glasses" else "glasses"
	var wardrobe: Array = STREETWEAR.get(city, STREETWEAR_DEFAULT)
	return {
		"alien": false,
		"build": build,
		"wear": String(wardrobe[(h >> 11) % wardrobe.size()]),
		"face": face,
		"cut": "crop" if build == "child" else String(CUT_NAMES[(h >> 6) % CUT_NAMES.size()]),
		"pal": {
			"X": Color8(38, 30, 46),
			"S": skin[0], "L": skin[1], "H": skin[2],
			"E": Color8(34, 28, 40), "W": Color8(246, 242, 250),
			# The mouth doubles as facial hair, so a beard or a moustache is
			# the hair colour rather than a very large lip.
			"M": Color8(150, 92, 88) if face == "" else HAIRS[hair_i],
			"R": HAIRS[hair_i],
			"O": coat.darkened(0.42), "C": coat, "D": coat.darkened(0.22),
			"g": ACCENTS[(h >> 13) % ACCENTS.size()],
			"P": ACCENTS[(h >> 17) % ACCENTS.size()],
			# The four a garment asks for. Without them the crowd could not
			# wear anything out of the wardrobe at all: an unknown letter is
			# skipped, so an apron on somebody with no `a` is a hole.
			"a": ACCENTS[(h >> 13) % ACCENTS.size()],
			"n": Color8(214, 208, 196),
			"j": Color8(186, 162, 104),
			"p": Color(ACCENTS[(h >> 17) % ACCENTS.size()]).darkened(0.30),
			"B": Color8(58, 46, 42), "K": Color8(38, 30, 28),
		},
	}


static func alien_look() -> Dictionary:
	var choice := APPEARANCE.current()
	return {"alien": true, "cut": "", "pal": APPEARANCE.palette(choice), "appearance": choice}


# ── Drawing ──────────────────────────────────────────────────────────────────

# Where the eyes look. The only acting these characters have, and it does most
# of the work: shifting two units is the difference between a person watching
# you and a person waiting for a bus.
const GAZE := {
	"watch": 1, "queue": 0, "stand": 0, "wait": 0, "look": 1, "read": -1,
	"talk": 0, "haggle": 1, "sit": 0, "eat": -1, "cut": -1, "pour": -1,
	"count": -1, "point": 1, "walk": 0, "carry": 0,
}

const SIT_ACTS := ["sit", "kneel", "squat"]

# How this art says "doing something".
#
# Read straight off interact_down.png against idle_down.png: the head and the
# antennae drop exactly one pixel and NOTHING else moves. That is the entire
# vocabulary the game has for action, and it is enough - a one-unit dip is
# unmistakable at any size, and it cannot look like a different game because
# it is precisely what the game already does. Arms were never an option: they
# stay inside the coat in every frame of every strip.
const DIP := {
	"interact": 1, "offer": 1, "hand_over": 1, "take": 1, "point": 1,
	"carry": 1, "reach": 1, "drink": 1, "haul": 1, "cut": 1, "pour": 1,
	"count": 1, "eat": 1, "read": 1, "haggle": 1, "push": 1, "queue": 0,
	"pray": 2, "bow": 2, "kneel": 1,
	"recoil": -1, "wave": -1, "look": -1, "watch": 0,
}

# And a step to one side, for the few acts that are about where you are
# standing rather than what your hands are doing.
const LEAN := {"recoil": -1, "point": 1, "reach": 1, "bow": 0, "haul": -1}


# ── Idle loops ───────────────────────────────────────────────────────────────
#
# A person standing at their own counter for eleven months is not a statue,
# and every named person in this game was one. The DIP vocabulary already had
# everything needed to fix that - it just had no way to say "and then, four
# seconds later, do it again".
#
# A loop is [[act, seconds], ...] and it repeats. Deliberately slow: the whole
# vocabulary is a one-unit dip, and a one-unit dip four times a second is a
# person having a seizure rather than a person working. Nothing here is
# faster than about one beat a second, and most of it is far slower.
#
# The loops are written per TRADE rather than per person, because two people
# doing the same job do look the same doing it, and then a person is given
# the one their job actually involves.
const IDLE := {
	# Behind a counter, dealing with somebody who is not you.
	"serve":   [["stand", 3.4], ["hand_over", 0.9], ["stand", 2.2],
		["count", 1.1]],
	# Wiping it down, which is what you do when nobody is buying.
	"wipe":    [["stand", 2.6], ["reach", 0.8], ["reach", 0.7],
		["stand", 1.9], ["reach", 0.8]],
	# Fixing something small, close to your face, for a long time.
	"mend":    [["interact", 0.7], ["stand", 0.5], ["interact", 0.6],
		["stand", 0.4], ["interact", 0.9], ["look", 1.4]],
	# Carrying, which is the whole job: pick up, walk, set down.
	"haul":    [["carry", 2.8], ["stand", 0.6], ["haul", 1.6],
		["stand", 0.5]],
	# Sorting stock with both hands, unhurried.
	"sort":    [["reach", 1.0], ["stand", 0.7], ["reach", 1.1],
		["count", 1.3], ["stand", 1.6]],
	# Cooking: the same three motions, and a look at the door.
	"cook":    [["cut", 1.2], ["cut", 1.0], ["pour", 1.1], ["look", 1.0],
		["stand", 1.4]],
	# Waiting. Genuinely nothing to do, and doing it visibly.
	"wait":    [["stand", 4.2], ["look", 1.6], ["stand", 3.1],
		["watch", 1.8]],
	# Watching the street go past, which is a job in most of these cities.
	"watch":   [["watch", 3.0], ["stand", 2.2], ["look", 1.4],
		["stand", 2.8]],
	# Reading, and looking up when somebody comes in.
	"read":    [["read", 4.0], ["stand", 0.8], ["read", 3.4], ["look", 1.2]],
	# Talking, to whoever is nearest, about anything.
	"talk":    [["talk", 1.6], ["stand", 0.7], ["talk", 2.1],
		["point", 0.8], ["stand", 1.2]],
	# A child, who cannot stand still and should not be drawn as if they can.
	"fidget":  [["stand", 0.9], ["look", 0.6], ["point", 0.5],
		["stand", 0.7], ["recoil", 0.4], ["watch", 1.1]],
	# Standing very still on purpose. Odile, and nobody else.
	"still":   [["stand", 9.0]],
	# Holding a tray level while walking a han's stairs.
	"tray":    [["carry", 2.4], ["stand", 0.9], ["carry", 2.7],
		["offer", 1.0]],
	# Praying, or paying respects. Slow, and it holds at the bottom.
	"bow":     [["stand", 3.6], ["bow", 2.4], ["stand", 2.0]],
	# Music in your ears and nobody watching.
	"nod":     [["stand", 0.5], ["interact", 0.4], ["stand", 0.5],
		["interact", 0.4]],
}


# Which pose an idle loop is in at time `t`. `seed_i` offsets the phase, so two
# people on the same loop are never in step - a row of market traders all
# reaching at the same instant is worse than a row of statues.
static func _idle_act(loop: String, t: float, seed_i: int) -> String:
	if loop.is_empty() or not IDLE.has(loop):
		return "stand"
	var beats: Array = IDLE[loop]
	var total: float = 0.0
	for b: Array in beats:
		total += float(b[1])
	if total <= 0.01:
		return "stand"
	var at: float = fposmod(t + float(seed_i % 97) * 0.37, total)
	for b2: Array in beats:
		at -= float(b2[1])
		if at <= 0.0:
			return String(b2[0])
	return "stand"


# ── What they are holding ────────────────────────────────────────────────────
#
# There are no arms in this art and there never will be - a limb drawn as two
# lines with a joint reads as a sausage with a knot in it, which cost this
# project a whole redesign to learn. A prop therefore floats at the height a
# held object would be, moves with the figure's dip, and is read as held
# because of where it is rather than because of what is gripping it.
#
# Each entry is [width, height, y above the soles, colour, second colour].
const PROPS := {
	"tray":    [ 10.0, 1.6,  8.0, Color8(178, 142, 74),  Color8(226, 200, 120)],
	"flowers": [  6.0,  6.0, 11.0, Color8(226, 140, 34),  Color8(90, 118, 58)],
	"broom": [  1.6, 14.0, 13.0, Color8(126, 96, 62),   Color8(196, 170, 108)],
	"crate": [  8.0, 7.0,  9.0, Color8(150, 116, 74),  Color8(112, 84, 52)],
	"box": [  6.0,  6.0,  9.0, Color8(178, 156, 122), Color8(140, 118, 88)],
	"papers": [  5.0,  5.0,  8.0, Color8(232, 228, 214), Color8(190, 186, 172)],
	"bag": [  5.0,  7.0,  8.0, Color8(90, 96, 108),   Color8(64, 68, 78)],
	"glass": [  3.0,  3.0,  8.0, Color8(196, 96, 48),   Color8(232, 176, 120)],
	"book": [  5.0,  6.0,  9.0, Color8(158, 124, 88),  Color8(206, 190, 158)],
	"phone": [  3.0,  4.0, 11.0, Color8(38, 40, 52),    Color8(120, 160, 190)],
	"loaf": [  6.0,  4.0,  8.0, Color8(186, 138, 78),  Color8(226, 186, 128)],
	"fish": [  7.0, 3.0,  8.0, Color8(158, 172, 186), Color8(196, 206, 216)],
	"cloth": [  6.0,  6.0,  9.0, Color8(190, 82, 118),  Color8(224, 140, 168)],
	"record": [  6.0,  8.0,  9.0, Color8(28, 26, 32),    Color8(198, 154, 62)],
	"brass": [  5.0,  5.0,  8.0, Color8(168, 130, 56),  Color8(214, 182, 104)],
	"basket": [  8.0, 7.0,  9.0, Color8(154, 122, 78),  Color8(190, 160, 112)],
	"broomup": [  1.6, 15.0, 15.0, Color8(126, 96, 62),   Color8(196, 170, 108)],
}


# The prop, drawn beside the figure at the height its owner would hold it.
# `side` is -1 for their left and 1 for their right; `dy` is the figure's own
# dip this frame, so a held thing goes down with the person holding it.
static func draw_prop(ci: CanvasItem, at: Vector2, unit: float, prop: String,
		side: float = 1.0, dy: float = 0.0) -> void:
	if prop.is_empty() or not PROPS.has(prop) or unit <= 0.02:
		return
	var p: Array = PROPS[prop]
	var w: float = float(p[0]) * unit
	var h: float = float(p[1]) * unit
	# Where the hands would be. Side 0 is held in front with both of them - a
	# tea tray, an armful of marigolds - and anything else is tucked against
	# one side, OVERLAPPING the coat rather than floating clear of it. The
	# first version placed props nine units out, which is half a figure's
	# width past the edge, and every one read as an object hanging in the air
	# beside somebody.
	var x: float = at.x - w * 0.5
	if absf(side) > 0.01:
		x = at.x + signf(side) * 4.0 * unit - w * 0.5
	var y: float = at.y - float(p[2]) * unit + dy * unit
	ITEM_ART.draw_fitted(ci, Rect2(Vector2(x,y).round(),Vector2(w,h)),ITEM_ART.PROPS[prop])


static func world_unit(node: Node) -> float:
	var parent: Node = node
	while parent != null:
		if parent is CanvasLayer:
			return 2.0
		if parent.has_meta("character_unit"):
			return float(parent.get_meta("character_unit"))
		parent = parent.get_parent()
	return 2.0


# One figure, feet on `at`, at `unit` screen pixels per grid unit.
#
# `t` is only used to breathe: a whole unit, slowly, because a pixel figure
# moved by a third of a pixel is a pixel figure with a blurred edge.
# `clip_row` stops the figure being drawn below a given grid row. A clerk
# stands BEHIND a counter, and the counter is background art drawn under
# everything - so without this their legs render on top of the furniture and
# the whole game has people standing on their own counters.
static func draw_figure(ci: CanvasItem, at: Vector2, unit: float,
		who: Dictionary, act: String = "stand", t: float = 0.0,
		seed_i: int = 0, clip_row: int = 99) -> void:
	if unit <= 0.02:
		return
	var alien: bool = bool(who.get("alien", false))
	var pal: Dictionary = who.get("pal", A_PAL)
	var rows: Array = (ALIEN if alien else HUMAN).duplicate()
	if alien:
		APPEARANCE.dress(rows, who.get("appearance", APPEARANCE.current()))

	# Hair, whatever it is wearing, and a face. Wardrobe owns the tables a
	# NAMED person is dressed from; the seven cuts and three marks below are
	# what the anonymous crowd is drawn from, and it reads both.
	if not alien:
		WARDROBE.dress(rows, who, CUTS, FACE_ROWS)
		if bool(who.get("balaclava", false)):
			# An explicit activity garment. Keep the existing eyes together in
			# their opening; the wool follows the head's own movement and grid.
			pal = pal.duplicate()
			pal["q"] = Color8(55, 59, 72)
			pal["v"] = Color8(73, 78, 90)
			for r in range(3, ROW_NECK + 1):
				var covered: String = ""
				for x in range(String(rows[r]).length()):
					var ch: String = String(rows[r])[x]
					var eye_opening: bool = r in [ROW_EYES, ROW_EYES + 1] and x >= 3 and x <= 12
					covered += ch if ch in [".", "X"] or eye_opening else ("v" if r % 3 == 0 else "q")
				rows[r] = covered

	# An idle loop, if this person has one. Standing still is the pose every
	# person in this game is in for most of their life, and one unmoving
	# silhouette per person is what made a street of people read as copies of
	# a coat. A loop belongs to a person: Viktor works at something small and
	# fast, Odile does not move at all, Rocio ties and sets down.
	if act == "stand":
		act = _idle_act(String(who.get("idle", "")), t, seed_i)

	# The two-pixel eyes keep their authored whites and pupils together.
	# A glance belongs to the head pose, never a white pixel sliding over skin.

	# How tall this person is. A crowd of one height is a crowd of clones.
	var build: String = String(who.get("build", "adult"))
	unit = unit * float(BUILD_H.get(build, 1.0))

	var sit: bool = SIT_ACTS.has(act) or bool(who.get("seated", false))
	var phase: float = t * 0.55 + float(seed_i) * 1.7
	# Breathing is the head, not the whole figure: a body that jumps a whole
	# pixel every two seconds is a body on a spring. One unit, on the head,
	# rarely, is a person standing there.
	var breath: int = 1 if (sin(phase) > 0.80 and SaveManager.motion() > 0.5) else 0
	var dip: int = int(DIP.get(act, 0)) + breath
	# An elder carries their head lower and a little forward. It is one unit
	# and it is the difference between an old woman and a short adult.
	if build == "elder":
		dip += 1
	var lean: int = int(LEAN.get(act, 0))
	if build == "elder":
		lean -= 1
	var step: int = 0
	if act == "walk":
		step = int(floor(t * 8.0 + float(seed_i))) % 4

	# The ground it stands on. A clipped figure is behind something, so it
	# gets no shadow: the floor it is standing on is not visible either.
	if clip_row > 90:
		ci.draw_set_transform(at, 0.0, Vector2(1.0, 0.34))
		ci.draw_circle(Vector2.ZERO, 7.0 * unit, Color(0.0, 0.0, 0.0, 0.22))
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Sitting: the legs go, the coat drops, and the whole figure loses three
	# units of height rather than being squashed.
	var bottom: int = rows.size()
	var drop: int = 0
	if sit:
		bottom = ROW_LEGS
		drop = 2
	# Join a raised head to the shoulders. Negative dips otherwise leave a
	# transparent row between the neck and coat during recoil and looking up.
	if dip < 0:
		var neck: Color = pal.get("C" if alien else "S", Color8(160, 128, 105))
		ci.draw_rect(Rect2(at.x - 3.0 * unit,
			at.y + float(ROW_NECK - FEET - 1 + dip) * unit,
			6.0 * unit, float(1 - dip) * unit), neck)

	for r in range(0, mini(bottom, clip_row)):
		var row: String = String(rows[r])
		# The head carries the dip; the coat and the legs do not move.
		var dy: int = drop + (dip if r <= ROW_NECK else 0)
		var y: float = at.y + float(r - FEET - 1 + dy) * unit
		var dx: float = float(lean if r <= ROW_NECK else 0) * unit
		var x: int = 0
		while x < row.length():
			var ch: String = row[x]
			var run: int = 1
			while x + run < row.length() and row[x + run] == ch:
				run += 1
			if ch != "." and pal.has(ch):
				var foot_y: float = y
				if act == "walk" and r >= ROW_LEGS:
					if (x < W / 2 and step == 0) or (x >= W / 2 and step == 2):
						foot_y -= unit
				var color: Color = pal[ch]
				# Explicit activity wardrobe: removing shoes changes the feet,
				# without recoloring trousers or mutating the shared palette.
				if bool(who.get("barefoot", false)) and r >= ROW_LEGS and ch in ["B", "K"]:
					color = pal.get("S", color)
					if ch == "K": color = color.darkened(.18)
				ci.draw_rect(Rect2(at.x + dx + float(x - W / 2) * unit, foot_y,
					float(run) * unit, unit), color)
			x += run
	if sit and clip_row > ROW_LEGS:
		# A seat's worth of coat where the legs were.
		ci.draw_rect(Rect2(at.x - 8.0 * unit, at.y - 3.0 * unit,
			16.0 * unit, 3.0 * unit), pal.get("D", Color(0.2, 0.2, 0.25)))
		# The outline letter, not the old coat-outline O: nothing in the canvas
		# figure has an O in it any more, and a seat drawn in a colour half the
		# cast does not carry is a seat that sometimes vanishes.
		ci.draw_rect(Rect2(at.x - 8.0 * unit, at.y - 1.0 * unit,
			16.0 * unit, 1.0 * unit), pal.get("X", Color(0.1, 0.1, 0.14)))

	# What they are holding, at the height a held thing would be, moving with
	# the dip - so it belongs to this person rather than hovering beside them.
	# Suppressed behind a counter, where the whole lower half of them is not
	# being drawn and a floating tray would be the only thing visible.
	var prop: String = String(who.get("prop", ""))
	if not prop.is_empty() and clip_row > 90:
		draw_prop(ci, at, unit, prop, float(who.get("prop_side", 1.0)),
			float(dip))


# Move both eyes one unit, keeping the whites on the outside so it reads as a
# look rather than as a squint.
static func _shift_eyes(row: String, dir: int) -> String:
	var out: String = row
	var idx: int = out.find("W")
	while idx >= 0:
		var to: int = idx + dir
		if to > 0 and to < out.length() - 1 and out[to] in ["S", "L", "H"]:
			out = out.substr(0, to) + "W" + out.substr(to + 1)
			out = out.substr(0, idx) + "S" + out.substr(idx + 1)
		idx = out.find("W", maxi(idx, to) + 1)
	return out


# ── What a person says as they pass ──────────────────────────────────────────
#
# Lifted out of WalkingFriends so the whole crowd can use it. The mechanic is
# the game in miniature: a word you do not know yet comes out as glyphs, and
# the same word comes out as letters once you have heard it enough. Overheard
# speech is how half the vocabulary in this game gets learned.

const GLYPHS := "\u25c8\u27df\u2b21\u25c9\u27e2\u27e3\u22c4\u27e4\u27e5\u2b22\u2b23\u2b1f\u2b20\u27e6\u27e7\u27e1"


static func to_glyphs(word: String) -> String:
	var out: String = ""
	for i in range(word.length()):
		out += GLYPHS[word.unicode_at(i) % GLYPHS.length()]
	return out


# A snippet is [[what it looks like, the word it is], ...]. Each word is shown
# only once the player can actually read it.
static func snippet_text(snip: Array, language: String) -> String:
	var parts: PackedStringArray = []
	for pair: Array in snip:
		var disp: String = String(pair[0])
		var wkey: String = String(pair[1])
		# A word he has found out reads, however few times he has heard it.
		if GameState.get_tier(language, wkey) >= GameState.TIER_PARTIAL \
				or NOTEBOOK.found(language, wkey):
			parts.append(disp)
		else:
			parts.append(to_glyphs(wkey))
	return " ".join(parts)


# The bubble itself, over `at`, in the CanvasItem's own space.
static func speech(ci: CanvasItem, at: Vector2, text: String,
		fade: float = 1.0) -> void:
	if text.is_empty() or fade <= 0.02:
		return
	var font: Font = ThemeDB.fallback_font
	var sz: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	var bx: float = at.x - sz.x * 0.5
	var by: float = at.y
	var back := Color(0.050, 0.045, 0.110, 0.92 * fade)
	ci.draw_rect(Rect2(bx - 9.0, by - 16.0, sz.x + 18.0, 24.0), back)
	ci.draw_rect(Rect2(bx - 9.0, by - 16.0, sz.x + 18.0, 1.0),
		Color(0.36, 0.33, 0.58, 0.60 * fade))
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(at.x - 4.0, by + 8.0), Vector2(at.x + 4.0, by + 8.0),
		Vector2(at.x, by + 14.0),
	]), back)
	ci.draw_string(font, Vector2(bx, by + 1.0), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(0.86, 0.84, 1.00, 0.95 * fade))
