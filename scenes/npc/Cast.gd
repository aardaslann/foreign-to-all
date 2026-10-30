extends Object

# Every key character, drawn as they were designed.
#
# The constant was called EIGHT and held eight, which was true until the
# twelve optional cities were given the same depth as the mandatory ones. A
# name that counts is a name that goes stale; this one describes what it is
# instead.
#
# ── Where this comes from ────────────────────────────────────────────────────
#
# These are not invented here. Every colour below is lifted verbatim out of the
# design canvas the eight were drawn in - "Foreign to All Key
# Characters", the sheet with the twenty-two-unit skeleton and one card per
# person - and the geometry is the same design re-stated on this game's own
# grid, which is twenty-six rows rather than twenty-two because the player has
# antennae and everybody is measured against him.
#
# The canvas said the thing this file exists to keep true:
#
#   > Built on the game's own 22-unit skeleton, measured off
#   > art/player/alien_sheet.png - head is the top eleven rows, which is half
#   > the figure and the whole character language of this game. Dress is
#   > researched per city, age and trade, never inferred from age.
#
# ── What was wrong before ────────────────────────────────────────────────────
#
# Story.PEOPLE carried a `look` of five integers - {"cut": "crop", "skin": 0,
# "hair": 5, "coat": 1, "accent": 3} - indexing the same shared palettes the
# anonymous crowd is drawn from. So Kerstin, who has run a Spati since 1998
# and wears a fleece over a work shirt, was a coat in COATS[1]; Setsuko, who
# is seventy-four and stands in a work apron with sleeve guards on
# Kappabashi-dori, was a coat in COATS[2]. Eight people the whole game is
# about, drawn out of the crowd's own wardrobe.
#
# ── The other half: an idle loop ─────────────────────────────────────────────
#
# A design that only exists standing still is half a design. Each of the eight
# has the loop their trade actually is - Viktor mends, Odile does not move,
# Arda carries a tray that is never set down - and where they hold something,
# they hold it.

const CH := preload("res://scenes/npc/CharacterArt.gd")

# One entry per city with a key character in it - the eight the story
# requires and the twelve it does not, which are the same depth and are not
# on the critical path. Keyed the way Story keys everything.
#
#   pal      the palette, verbatim off the canvas
#   cut      hair or headwear                    Wardrobe.CUTS / CharacterArt.CUTS
#   drape    hair that falls over the clothes    same tables, laid after them
#   mark     what is on their face               Wardrobe.MARKS
#   wear     the garment                         Wardrobe.GARMENTS
#   shoes    what is on their feet               Wardrobe.SHOES
#   build    height and posture                  child | youth | adult | elder
#   idle     what they do while standing there   CharacterArt.IDLE
#   prop     what they are holding               CharacterArt.PROPS
const DESIGNS := {

# ── Sao Paulo · Neusa, 61 ────────────────────────────────────────────────────
# Thirty-one years in the salao on the corner in Bixiga. A working apron over
# her own clothes, sleeves pushed up because her hands are wet all day, and
# hoops. The palette is the warmest in the game on purpose: Zurich is a
# half-step colder than Berlin and this is three steps the other way.
#
# Deliberately NOT the market apron Rocio wears in Mexico City. Two women on
# two stalls in two Latin American cities is how twenty cities quietly become
# one, and her trade is the whole reason this city works: a salao is the one
# ordinary job where touching a stranger is the work.
"saopaulo": {
	"build": "elder", "cut": "bun", "mark": "hoops",
	"wear": "apron", "shoes": "trainers", "idle": "offer",
	"prop": "cloth",
	"pal": {
		"X": Color8(38, 28, 30),    "R": Color8(96, 62, 44),
		"S": Color8(214, 158, 116), "L": Color8(232, 184, 142),
		"H": Color8(176, 122, 84),  "E": Color8(46, 30, 34),
		"W": Color8(252, 246, 236), "M": Color8(158, 84, 74),
		"C": Color8(216, 106, 58),  "D": Color8(178, 78, 44),
		"O": Color8(120, 50, 30),   "g": Color8(244, 226, 196),
		"n": Color8(244, 226, 196), "a": Color8(240, 196, 72),
		"j": Color8(198, 172, 140), "P": Color8(150, 122, 96),
		"p": Color8(116, 92, 72),   "B": Color8(58, 44, 40),
		"K": Color8(248, 240, 226),
	},
},
# ── Zurich · Beat, 34 ────────────────────────────────────────────────────────
# A fleece with the kiosk's name on it, wire glasses, clean trainers, and the
# neatest counter in the game. Thirty-four, which puts him between Arda and
# Kerstin and fills a gap the eight had.
#
# The palette is the one thing Zurich gets that Berlin does not: everything a
# half-step more expensive-looking and a half-step colder. Same grey family,
# better wool.
#
# His name is a joke he is not in on. Beat is an ordinary Swiss man's name,
# said BAY-at, and there is no version of this alien's first attempt at it
# that is not wrong.
"zurich": {
	"build": "adult", "cut": "crop", "mark": "wireglasses",
	"wear": "fleece", "shoes": "trainers", "idle": "serve", "prop": "",
	"pal": {
		"X": Color8(30, 32, 40),    "R": Color8(74, 62, 48),
		"S": Color8(238, 204, 176), "L": Color8(248, 224, 202),
		"H": Color8(202, 168, 140), "E": Color8(42, 35, 64),
		"W": Color8(244, 239, 255), "M": Color8(150, 96, 88),
		"C": Color8(62, 72, 68),    "D": Color8(46, 55, 52),
		"O": Color8(28, 36, 42),    "g": Color8(214, 218, 222),
		"n": Color8(214, 218, 222), "a": Color8(198, 132, 44),
		"j": Color8(168, 176, 186), "P": Color8(120, 130, 140),
		"p": Color8(92, 100, 110),  "B": Color8(46, 50, 58),
		"K": Color8(236, 234, 228),
	},
},

# ── Berlin · Kerstin, 57 ─────────────────────────────────────────────────────
# Fleece over a work shirt, dark practical trousers, short greying hair cut
# for convenience, reading glasses pushed up. Berlin does not dress up and she
# dresses less up than Berlin. The glasses are never on her face; that is the
# joke and it is drawn rather than written.
"berlin": {
	"build": "adult", "cut": "crop", "mark": "readers_up",
	"wear": "fleece", "shoes": "", "idle": "wipe", "prop": "",
	"pal": {
		"X": Color8(34, 29, 46),    "R": Color8(150, 143, 136),
		"S": Color8(240, 208, 180), "L": Color8(250, 228, 206),
		"H": Color8(206, 174, 146), "E": Color8(42, 35, 64),
		"W": Color8(244, 239, 255), "M": Color8(154, 98, 88),
		"C": Color8(59, 74, 92),    "D": Color8(44, 56, 70),
		"O": Color8(28, 36, 46),    "g": Color8(207, 214, 220),
		"n": Color8(207, 214, 220), "a": Color8(44, 56, 70),
		"j": Color8(74, 80, 90),    "P": Color8(139, 147, 160),
		"p": Color8(104, 112, 124), "B": Color8(47, 51, 64),
		"K": Color8(35, 36, 44),
	},
},

# ── London · Nadia, 17 ───────────────────────────────────────────────────────
# Black puffer over school uniform with the tie loosened to nothing, hair
# slicked into a bun with the edges laid, big hoops, immaculate white trainers
# she is careful about on wet pavement.
"london": {
	"build": "youth", "cut": "bun", "mark": "hoops",
	"wear": "puffer", "shoes": "trainers", "idle": "nod", "prop": "phone",
	"pal": {
		"X": Color8(13, 12, 18),    "R": Color8(24, 20, 32),
		"S": Color8(125, 82, 54),   "L": Color8(152, 104, 70),
		"H": Color8(94, 60, 38),    "E": Color8(26, 22, 38),
		"W": Color8(239, 231, 245), "M": Color8(94, 54, 48),
		"C": Color8(27, 26, 34),    "D": Color8(18, 17, 24),
		"O": Color8(10, 10, 14),    "g": Color8(46, 43, 56),
		"n": Color8(46, 43, 56),    "a": Color8(46, 43, 56),
		"j": Color8(216, 176, 72),  "P": Color8(24, 20, 32),
		"p": Color8(16, 14, 22),    "B": Color8(35, 34, 42),
		"K": Color8(242, 240, 236),
	},
},

# ── Paris · Odile, 71 ────────────────────────────────────────────────────────
# A good wool coat kept fifteen years, a scarf tied properly rather than
# draped, short grey hair with a proper cut, one pair of small gold earrings,
# low leather shoes. Nothing new, nothing shabby. She does not move.
"paris": {
	"build": "elder", "cut": "crop", "mark": "crowsfeet",
	"wear": "goodcoat", "shoes": "", "idle": "still", "prop": "",
	"pal": {
		"X": Color8(36, 31, 42),    "R": Color8(207, 202, 196),
		"S": Color8(236, 208, 182), "L": Color8(246, 226, 206),
		"H": Color8(202, 172, 146), "E": Color8(42, 35, 64),
		"W": Color8(244, 239, 255), "M": Color8(156, 95, 88),
		"C": Color8(160, 128, 82),  "D": Color8(130, 104, 63),
		"O": Color8(78, 62, 38),    "g": Color8(143, 59, 63),
		"n": Color8(226, 218, 204), "a": Color8(143, 59, 63),
		"j": Color8(200, 173, 106), "P": Color8(143, 59, 63),
		"p": Color8(112, 45, 49),   "B": Color8(58, 52, 64),
		"K": Color8(42, 37, 48),
	},
},

# ── Moscow · Viktor, 46 ──────────────────────────────────────────────────────
# Dark quilted jacket, wool hat indoors and out, hands stained and scarred,
# moustache, and a jeweller's loupe on a string he forgets he is wearing. The
# loop is the trade: something small, close to the face, for a long time.
"moscow": {
	"build": "adult", "cut": "woolhat", "mark": "thickstache",
	"wear": "quilted", "shoes": "boots", "idle": "mend", "prop": "",
	"pal": {
		"X": Color8(24, 26, 34),    "R": Color8(43, 47, 58),
		"S": Color8(231, 195, 160), "L": Color8(242, 214, 186),
		"H": Color8(196, 158, 124), "E": Color8(42, 35, 64),
		"W": Color8(244, 239, 255), "M": Color8(106, 92, 84),
		"C": Color8(47, 53, 66),    "D": Color8(36, 42, 52),
		"O": Color8(22, 26, 34),    "g": Color8(74, 84, 100),
		"n": Color8(74, 84, 100),   "a": Color8(74, 84, 100),
		"j": Color8(185, 160, 92),  "P": Color8(43, 47, 58),
		"p": Color8(34, 37, 45),    "B": Color8(43, 47, 56),
		"K": Color8(29, 31, 38),
	},
},

# ── Istanbul · Arda, 18 ──────────────────────────────────────────────────────
# A cheap printed T-shirt and jeans, white trainers he keeps clean in a
# building with no clean floors, a fade grown out about two weeks, no facial
# hair at all. The tray is never put down, which is why it is a prop and not
# a pose.
"istanbul": {
	"build": "youth", "cut": "fade", "mark": "",
	"wear": "tee", "shoes": "trainers", "idle": "tray", "prop": "tray", "prop_side": 0.0,
	"pal": {
		"X": Color8(26, 21, 32),    "R": Color8(23, 19, 24),
		"S": Color8(216, 171, 124), "L": Color8(236, 198, 158),
		"H": Color8(180, 136, 92),  "E": Color8(36, 28, 44),
		"W": Color8(244, 239, 255), "M": Color8(138, 74, 66),
		"C": Color8(184, 68, 60),   "D": Color8(147, 52, 41),
		"O": Color8(96, 34, 28),    "g": Color8(236, 228, 214),
		"n": Color8(236, 228, 214), "a": Color8(236, 228, 214),
		"j": Color8(198, 168, 96),  "P": Color8(184, 68, 60),
		"p": Color8(147, 52, 41),   "B": Color8(42, 53, 80),
		"K": Color8(232, 228, 220),
	},
},

# ── Mumbai · Omkar, 22 ───────────────────────────────────────────────────────
# Jeans, the mandal's printed T-shirt, rubber slippers, thin gold chain,
# phone in the back pocket, and a thread on his wrist all year. Four
# languages and no accent in any of them.
"mumbai": {
	"build": "adult", "cut": "crop", "mark": "",
	"wear": "mandaltee", "shoes": "sandals", "idle": "nod", "prop": "phone",
	"pal": {
		"X": Color8(23, 19, 32),    "R": Color8(20, 17, 26),
		"S": Color8(169, 116, 74),  "L": Color8(196, 144, 100),
		"H": Color8(132, 86, 52),   "E": Color8(30, 24, 40),
		"W": Color8(244, 239, 255), "M": Color8(107, 60, 48),
		"C": Color8(224, 138, 46),  "D": Color8(185, 108, 30),
		"O": Color8(126, 72, 20),   "g": Color8(242, 233, 216),
		"n": Color8(242, 233, 216), "a": Color8(242, 233, 216),
		"j": Color8(216, 176, 72),  "P": Color8(224, 138, 46),
		"p": Color8(185, 108, 30),  "B": Color8(44, 58, 82),
		"K": Color8(74, 64, 56),
	},
},

# ── Tokyo · Setsuko, 74 ──────────────────────────────────────────────────────
# A work apron over a blouse, sleeve guards, short permed grey hair, glasses
# on a chain, sensible sandals. Stands with one hand on the counter, which
# here is a wipe that keeps returning to the same place.
"tokyo": {
	"build": "elder", "cut": "perm", "mark": "chainglasses",
	"wear": "apron", "shoes": "sandals", "idle": "wipe", "prop": "",
	"pal": {
		"X": Color8(34, 30, 38),    "R": Color8(200, 195, 189),
		"S": Color8(236, 207, 174), "L": Color8(246, 226, 202),
		"H": Color8(200, 168, 134), "E": Color8(42, 35, 64),
		"W": Color8(244, 239, 255), "M": Color8(154, 96, 88),
		"C": Color8(110, 127, 140), "D": Color8(85, 99, 110),
		"O": Color8(52, 62, 70),    "g": Color8(232, 226, 212),
		"n": Color8(220, 214, 200), "a": Color8(232, 226, 212),
		"j": Color8(90, 85, 96),    "P": Color8(200, 195, 189),
		"p": Color8(160, 155, 150), "B": Color8(74, 70, 80),
		"K": Color8(106, 95, 82),
	},
},

# ── Mexico City · Rocio, 45 ──────────────────────────────────────────────────
# Bright blouse, apron with a front pocket heavy with coins, long plait,
# sturdy sandals, forearms stained orange with marigold by the end of
# October. There are no forearms, so the marigold is in her hands instead.
"mexico": {
	"build": "adult", "cut": "crop", "drape": "plait", "mark": "",
	"wear": "marketapron", "shoes": "sandals", "idle": "sort",
	"prop": "flowers", "prop_side": 0.0,
	"pal": {
		"X": Color8(30, 22, 34),    "R": Color8(23, 19, 26),
		"S": Color8(192, 138, 92),  "L": Color8(216, 168, 124),
		"H": Color8(154, 104, 64),  "E": Color8(36, 28, 44),
		"W": Color8(244, 239, 255), "M": Color8(138, 68, 66),
		"C": Color8(200, 66, 92),   "D": Color8(161, 49, 72),
		"O": Color8(104, 30, 46),   "g": Color8(239, 230, 210),
		"n": Color8(239, 230, 210), "a": Color8(239, 230, 210),
		"j": Color8(184, 147, 74),  "P": Color8(23, 19, 26),
		"p": Color8(16, 13, 18),    "B": Color8(59, 50, 66),
		"K": Color8(107, 82, 64),
	},
},
}


# What one of the eight looks like, ready for CharacterArt.draw_figure.
#
# Falls back to the crowd's own generator for a city that has no key
# character, so a caller never has to check first.
static func look(city: String) -> Dictionary:
	if not DESIGNS.has(city):
		return CH.look(int(city.hash()), city)
	var d: Dictionary = DESIGNS[city]
	return {
		"alien": false,
		"build": String(d.get("build", "adult")),
		"cut": String(d.get("cut", "crop")),
		"drape": String(d.get("drape", "")),
		"face": String(d.get("face", "")),
		"mark": String(d.get("mark", "")),
		"wear": String(d.get("wear", "")),
		"shoes": String(d.get("shoes", "")),
		"idle": String(d.get("idle", "")),
		"prop": String(d.get("prop", "")),
		"prop_side": float(d.get("prop_side", 1.0)),
		"pal": Dictionary(d.get("pal", {})).duplicate(),
	}


# Whether this city's person has a design of their own. Used by the render
# tools, so a city added later shows up as missing rather than as a stranger
# in a borrowed coat.
static func designed(city: String) -> bool:
	return DESIGNS.has(city)
