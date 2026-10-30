extends Object

# Everybody else who has a name.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# Fifty-one people with names, written lines, ages, trades and neighbourhoods,
# and not one of them had an appearance. CharacterArt.look() hashed their id
# into six shared arrays, so what somebody looked like was decided by the
# arithmetic of their id string: Dot, who has run a caff since 1974, and Kai,
# who is sixteen and waiting for a bus, were the same silhouette in whichever
# two colours their names happened to land on.
#
# The roster already knew everything needed to draw them properly. Every entry
# in CityNPCs carries a `role` line with the person's age and trade in it -
# "runs the fish stall by the ferry. Fifty-one. Feeds the cats first" - and
# nothing read it except a checker that made sure the height was not a lie.
#
# So: one designed entry per person, written the same way the eight in Cast.gd
# were, off the same skeleton and out of the same wardrobe.
#
# ── The rule, again ──────────────────────────────────────────────────────────
#
# Researched, not inferred. Nurhan runs a bufe inside the Kapalicarsi and wears
# a basortu; Sevim runs a fish stall by the Kadikoy ferry and does not, because
# Kadikoy is not Carsi and the difference between those two streets is a real
# thing about Istanbul rather than a rule about women of fifty. Ousmane's
# boubou is white with pale blue embroidery because he is a tailor two doors
# from a mosque in the Medina and that is what a tailor there wears; Awa's is
# printed wax in her own six-bolt-deep colours because she sells it.
#
# Skin is an index into CharacterArt.SKINS, chosen per person from where they
# are actually from - which is frequently not the city they are standing in.
# Mr Aggarwal came to London at nineteen; Thuy grew up forty minutes west of
# Sydney; Priya rides a Toronto streetcar. None of them are their city's
# average and none of them should be drawn as it.

const CH := preload("res://scenes/npc/CharacterArt.gd")

# ── One entry per person ─────────────────────────────────────────────────────
#
#   city    where they stand              skin   index into CharacterArt.SKINS
#   build   child | youth | adult | elder  hair   the colour, written out
#   cut     hair or headwear               drape  hair laid over the clothes
#   face    CharacterArt.FACE_ROWS         mark   Wardrobe.MARKS
#   wear    Wardrobe.GARMENTS              shoes  Wardrobe.SHOES
#   coat    the garment's colour           trim   its second colour
#   head    headwear's colour              under  what shows beneath it
#   idle    CharacterArt.IDLE              prop   CharacterArt.PROPS
#   note    who they are, in one line, so the design can be argued with
const PEOPLE := {

# ── London ───────────────────────────────────────────────────────────────────
"dot": {"city": "london", "build": "elder", "skin": 0,
	"hair": Color8(186, 180, 170), "cut": "perm", "wear": "housecoat",
	"coat": Color8(122, 140, 158), "trim": Color8(222, 216, 202),
	"idle": "serve", "note": "71, runs the caff, has said 'love' since 1974"},

"kai": {"city": "london", "build": "youth", "skin": 4,
	"hair": Color8(22, 19, 28), "cut": "fade", "mark": "stud",
	"wear": "tracksuit", "shoes": "trainers",
	"coat": Color8(43, 58, 82), "trim": Color8(216, 221, 228),
	"metal": Color8(214, 214, 220),
	"idle": "wait", "prop": "phone", "note": "16, at a bus stop, talks fast"},

"aggarwal": {"city": "london", "build": "adult", "skin": 4,
	"hair": Color8(74, 64, 72), "cut": "thinning", "mark": "wireglasses",
	"wear": "shopcoat", "coat": Color8(107, 90, 68),
	"under": Color8(207, 196, 174), "metal": Color8(160, 156, 150),
	"idle": "read", "prop": "papers",
	"note": "newsagent, fifties, came here at nineteen"},

"marcus": {"city": "london", "build": "adult", "skin": 6,
	"hair": Color8(43, 38, 32), "cut": "locs", "mark": "greybeard",
	"wear": "openshirt", "coat": Color8(63, 90, 78),
	"under": Color8(224, 214, 192),
	"idle": "sort", "prop": "record",
	"note": "58, record shop under the arches, since it was cheap"},

"esme": {"city": "london", "build": "adult", "skin": 1,
	"hair": Color8(107, 58, 36), "cut": "bun", "wear": "puffer",
	"shoes": "boots", "coat": Color8(44, 47, 62),
	"trim": Color8(176, 86, 47), "sole": Color8(30, 28, 34),
	"idle": "watch", "prop": "papers",
	"note": "34, stage door, six nights a week"},

# ── Istanbul ─────────────────────────────────────────────────────────────────
"meryem": {"city": "istanbul", "build": "elder", "skin": 2,
	"hair": Color8(58, 48, 56), "cut": "basortu", "wear": "housecoat",
	"shoes": "sandals", "head": Color8(126, 90, 134),
	"coat": Color8(106, 74, 112), "trim": Color8(216, 200, 168),
	"idle": "cook", "prop": "glass",
	"note": "seventies, Yusuf's mother, feeds whoever is in the shop"},

"emre": {"city": "istanbul", "build": "child", "skin": 3,
	"hair": Color8(25, 21, 32), "cut": "crop", "wear": "tee",
	"shoes": "trainers", "coat": Color8(58, 122, 176),
	"trim": Color8(232, 228, 220), "sole": Color8(228, 224, 216),
	"idle": "fidget", "note": "nine, in the lane every afternoon"},

"nurhan": {"city": "istanbul", "build": "adult", "skin": 2,
	"hair": Color8(58, 44, 48), "cut": "basortu", "wear": "apron",
	"head": Color8(154, 74, 94), "coat": Color8(122, 80, 100),
	"trim": Color8(216, 207, 192), "under": Color8(228, 222, 208),
	"idle": "serve", "prop": "glass",
	"note": "fifties, runs the bufe in Carsi, calls you oglum"},

"sevim": {"city": "istanbul", "build": "adult", "skin": 2,
	"hair": Color8(68, 48, 56), "cut": "bun", "wear": "apron",
	"shoes": "boots", "coat": Color8(47, 74, 92),
	"trim": Color8(106, 122, 134), "under": Color8(198, 206, 212),
	"idle": "cook", "prop": "fish",
	"note": "51, fish stall by the Kadikoy ferry - no scarf, and that is Kadikoy"},

"altan": {"city": "istanbul", "build": "elder", "skin": 2,
	"hair": Color8(160, 154, 148), "cut": "thinning", "face": "beard",
	"mark": "wireglasses", "wear": "suit", "coat": Color8(74, 68, 80),
	"trim": Color8(138, 106, 74), "under": Color8(214, 208, 196),
	"metal": Color8(168, 164, 158),
	"idle": "read", "prop": "book",
	"note": "63, second-hand books off Istiklal, was a translator"},

# ── Honolulu, New York, Toronto ──────────────────────────────────────────────
"kimo": {"city": "honolulu", "build": "adult", "skin": 5,
	"hair": Color8(36, 28, 24), "cut": "tied", "wear": "openshirt",
	"shoes": "bare", "coat": Color8(47, 122, 134),
	"under": Color8(232, 216, 168),
	"idle": "watch", "note": "keeps two boards and lends one out"},

"lani": {"city": "honolulu", "build": "elder", "skin": 4,
	"hair": Color8(176, 168, 160), "cut": "perm", "wear": "apron",
	"shoes": "sandals", "coat": Color8(122, 106, 134),
	"trim": Color8(226, 192, 204), "under": Color8(236, 230, 216),
	"idle": "sort", "prop": "flowers", "prop_side": 0.0,
	"note": "strings leis on a needle the length of her forearm"},

"marisol": {"city": "newyork", "build": "adult", "skin": 4,
	"hair": Color8(36, 26, 32), "cut": "bun", "mark": "hoops",
	"wear": "hoodie", "shoes": "trainers", "coat": Color8(90, 58, 106),
	"trim": Color8(216, 176, 72), "metal": Color8(216, 176, 72),
	"sole": Color8(228, 226, 220),
	"idle": "serve", "prop": "papers",
	"note": "newsstand on a corner four thousand people an hour go past"},

"dov": {"city": "newyork", "build": "elder", "skin": 1,
	"hair": Color8(168, 162, 154), "cut": "hairnet", "face": "moustache",
	"wear": "apron", "head": Color8(228, 226, 220),
	"coat": Color8(200, 196, 188), "trim": Color8(228, 224, 214),
	"under": Color8(212, 208, 198),
	"idle": "cook", "note": "on the griddle since five, knows what you want"},

"priya": {"city": "toronto", "build": "adult", "skin": 4,
	"hair": Color8(26, 18, 24), "cut": "long", "wear": "puffer",
	"shoes": "boots", "coat": Color8(122, 44, 68),
	"trim": Color8(224, 212, 192),
	"idle": "wait", "prop": "phone",
	"note": "rides the same streetcar twice a day and thanks the driver"},

"wes": {"city": "toronto", "build": "adult", "skin": 1,
	"hair": Color8(74, 58, 44), "cut": "flatcap", "face": "beard",
	"wear": "shopcoat", "shoes": "boots", "head": Color8(74, 68, 58),
	"coat": Color8(74, 90, 58), "under": Color8(216, 200, 160),
	"metal": Color8(176, 172, 164),
	"idle": "sort", "prop": "crate", "prop_side": 0.0,
	"note": "third generation in the same front room in Kensington"},

# ── Sao Paulo, Vila Madalena ─────────────────────────────────────────────────
# On her way somewhere, in what she goes out in. She is not a character in a
# scene about Brazil, she is somebody who has met him once and is pleased
# about it, and the drawing should be that ordinary.
"beijo_woman": {"city": "saopaulo", "build": "adult", "skin": 3,
	"hair": Color8(48, 32, 30), "cut": "bun", "wear": "tee",
	"shoes": "trainers", "mark": "hoops",
	"coat": Color8(198, 84, 96), "trim": Color8(244, 232, 216),
	"under": Color8(232, 220, 206), "sole": Color8(240, 238, 232),
	"idle": "talk", "note": "met him once, which is enough to be kissed hello"},

# ── London, Docklands ────────────────────────────────────────────────────────

# The lobby uniform, which is a suit that belongs to a contract and not to him.
# Immaculate, because it is checked.
"femi": {"city": "london", "build": "youth", "skin": 3,
	"hair": Color8(24, 20, 22), "cut": "fade", "wear": "suit",
	"shoes": "boots",
	"coat": Color8(28, 32, 44), "trim": Color8(232, 232, 236),
	"under": Color8(238, 238, 240), "sole": Color8(30, 28, 28),
	"idle": "wait", "note": "24, nights on the desk, says no without the word"},

# A hi-vis tabard over her own clothes, which is what building services
# actually looks like at five in the morning, and the trolley is hers.
"trish": {"city": "london", "build": "adult", "skin": 0,
	"hair": Color8(150, 118, 96), "cut": "bun", "wear": "hivis",
	"shoes": "trainers", "mark": "crowsfeet",
	"coat": Color8(64, 70, 82), "trim": Color8(228, 206, 72),
	"under": Color8(96, 104, 120), "sole": Color8(232, 230, 226),
	"idle": "wipe", "prop": "broomup", "prop_side": 1.0,
	"note": "52, nineteen years on this floor, has met none of them"},

# ── Istanbul, Karakoy ────────────────────────────────────────────────────────

# A shopcoat with brass dust on it. Deliberately no moustache, for the same
# reason Ercan has none: the drawing must not do the categorising.
"bulent": {"city": "istanbul", "build": "elder", "skin": 2,
	"hair": Color8(148, 142, 134), "cut": "thinning", "wear": "shopcoat",
	"shoes": "boots", "mark": "crowsfeet",
	"coat": Color8(96, 78, 54), "trim": Color8(196, 168, 110),
	"under": Color8(214, 202, 178), "sole": Color8(52, 44, 38),
	"idle": "serve", "prop": "glass", "prop_side": 1.0,
	"note": "63, chandler in Persembe Pazari, will not be paid for the tea"},

# Two streets up and thirty years newer, and she is from four doors away.
# Cooler palette than Bulent's on purpose: same street, different century.
"yasemin": {"city": "istanbul", "build": "adult", "skin": 2,
	"hair": Color8(38, 30, 32), "cut": "bun", "wear": "apron",
	"shoes": "trainers",
	"coat": Color8(56, 74, 76), "trim": Color8(226, 224, 216),
	"under": Color8(206, 210, 208), "sole": Color8(228, 226, 222),
	"idle": "serve", "note": "34, the coffee place, grew up four doors down"},

# ── Berlin ───────────────────────────────────────────────────────────────────
# Prenzlberg and Kreuzberg, who between them are the first roster the starting
# city has ever had.

# Not a costume about being poor. A pensioner in a good warm jacket doing a
# round he has done for years, with the bag he does it with.
"hartmut": {"city": "berlin", "build": "elder", "skin": 0,
	"hair": Color8(196, 192, 184), "cut": "thinning", "wear": "quilted",
	"shoes": "boots", "mark": "crowsfeet",
	"coat": Color8(72, 78, 72), "trim": Color8(180, 176, 166),
	"under": Color8(146, 142, 132), "sole": Color8(52, 48, 44),
	"idle": "count", "prop": "bag", "prop_side": 1.0,
	"note": "68, born in the back building, and the bins are a round"},

# Nine years in Prenzlberg and dressed like it, which is the joke: she has the
# local uniform exactly right and the accent wrong.
"ilka": {"city": "berlin", "build": "adult", "skin": 0,
	"hair": Color8(122, 96, 70), "cut": "bun", "wear": "coat",
	"shoes": "trainers",
	"coat": Color8(84, 74, 96), "trim": Color8(214, 208, 216),
	"under": Color8(232, 228, 232), "sole": Color8(228, 226, 222),
	"idle": "watch", "note": "31, from Stuttgart, still die Wessi to the bench"},

# On the till at the Maybachufer stall. The apron is the stall's, not hers.
"sibel": {"city": "berlin", "build": "adult", "skin": 2,
	"hair": Color8(34, 26, 28), "cut": "bun", "wear": "marketapron",
	"shoes": "trainers", "mark": "hoops",
	"coat": Color8(58, 62, 78), "trim": Color8(226, 168, 92),
	"under": Color8(212, 206, 198), "sole": Color8(232, 230, 226),
	"idle": "count", "note": "26, born on this street, switches without hearing it"},

# A mechanic's coat with forty years of chain oil in it. Deliberately no
# moustache: the drawing should not do the categorising the game is against.
"ercan": {"city": "berlin", "build": "adult", "skin": 2,
	"hair": Color8(78, 70, 66), "cut": "crop", "wear": "shopcoat",
	"shoes": "boots", "mark": "crowsfeet",
	"coat": Color8(52, 60, 64), "trim": Color8(150, 146, 138),
	"under": Color8(186, 180, 168), "sole": Color8(48, 44, 42),
	"idle": "mend", "note": "59, came at nine, four years after his father"},

# ── Zurich ───────────────────────────────────────────────────────────────────
"ruedi": {"city": "zurich", "build": "adult", "skin": 0,
	"hair": Color8(106, 90, 68), "cut": "crop", "wear": "suit",
	"coat": Color8(43, 74, 106), "trim": Color8(184, 62, 52),
	"under": Color8(216, 221, 228),
	"idle": "wait", "note": "46, drives the 4, never thought about how he speaks"},

# Seefeld, first floor. She came down in what she had on indoors, because it
# was going to take thirty seconds - so a good grey quilted jacket and house
# sandals, not a coat. Nothing about her is cross. She is stating a fact she
# assumed he already had, which is the point: he did have it, in writing.
"sunntig_frau": {"city": "zurich", "build": "elder", "skin": 0,
	"hair": Color8(198, 194, 186), "cut": "perm", "wear": "quilted",
	"shoes": "sandals", "mark": "chainglasses",
	"coat": Color8(122, 126, 118), "trim": Color8(228, 226, 220),
	"under": Color8(206, 208, 202), "sole": Color8(96, 92, 88),
	"idle": "nod", "note": "first floor, Seefeld, and it will take thirty seconds"},

# ── Hanoi ────────────────────────────────────────────────────────────────────
"hien": {"city": "hanoi", "build": "adult", "skin": 3,
	"hair": Color8(22, 18, 26), "cut": "nonla", "wear": "apron",
	"shoes": "sandals", "head": Color8(214, 186, 122),
	"coat": Color8(74, 106, 90), "trim": Color8(228, 220, 200),
	"under": Color8(236, 230, 216),
	"idle": "cook", "note": "38, sells bun on a plastic stool, patient about tone"},

"lan": {"city": "hanoi", "build": "adult", "skin": 3,
	"hair": Color8(22, 18, 26), "cut": "nonla", "wear": "openshirt",
	"shoes": "sandals", "head": Color8(214, 186, 122),
	"coat": Color8(122, 90, 138), "under": Color8(232, 224, 204),
	"idle": "serve", "prop": "glass",
	"note": "29, tea from a cart by the metro stairs, repeats you back"},

"duc": {"city": "hanoi", "build": "adult", "skin": 3,
	"hair": Color8(22, 18, 26), "cut": "helmet", "wear": "tracksuit",
	"shoes": "sandals", "head": Color8(58, 62, 74),
	"coat": Color8(58, 74, 106), "trim": Color8(200, 90, 58),
	"idle": "wait", "prop": "phone",
	"note": "24, xe om under the bridge, corrects you for free"},

# ── Tokyo ────────────────────────────────────────────────────────────────────
"iwata": {"city": "tokyo", "build": "elder", "skin": 1,
	"hair": Color8(154, 148, 140), "cut": "thinning", "mark": "wireglasses",
	"wear": "shopcoat", "shoes": "sandals", "coat": Color8(74, 84, 100),
	"under": Color8(208, 200, 184), "metal": Color8(160, 156, 148),
	"idle": "read", "prop": "book",
	"note": "62, second-hand bookshop, third generation, never refuses"},

"sora": {"city": "tokyo", "build": "youth", "skin": 1,
	"hair": Color8(138, 74, 106), "cut": "bob", "mark": "stud",
	"wear": "hoodie", "shoes": "trainers", "coat": Color8(58, 58, 78),
	"trim": Color8(224, 168, 192), "metal": Color8(214, 214, 220),
	"sole": Color8(228, 226, 220),
	"idle": "talk", "note": "19, art student, talks too much and knows it"},

# ── Rome ─────────────────────────────────────────────────────────────────────
"nando": {"city": "rome", "build": "adult", "skin": 2,
	"hair": Color8(74, 62, 52), "cut": "flatcap", "face": "moustache",
	"wear": "apron", "shoes": "boots", "head": Color8(58, 54, 50),
	"coat": Color8(106, 74, 58), "trim": Color8(216, 210, 192),
	"under": Color8(228, 222, 206),
	"idle": "serve", "prop": "crate", "prop_side": 0.0,
	"note": "59, third stall on the left, forty years, talks over everyone"},

"lucia": {"city": "rome", "build": "adult", "skin": 2,
	"hair": Color8(42, 30, 36), "cut": "bun", "wear": "apron",
	"coat": Color8(90, 44, 58), "trim": Color8(232, 226, 212),
	"under": Color8(236, 232, 220),
	"idle": "serve", "prop": "glass",
	"note": "44, runs the bar by the market, serves whoever speaks"},

# ── Moscow ───────────────────────────────────────────────────────────────────
"galina": {"city": "moscow", "build": "adult", "skin": 0,
	"hair": Color8(122, 58, 44), "cut": "perm", "wear": "housecoat",
	"shoes": "boots", "coat": Color8(74, 90, 106),
	"trim": Color8(200, 176, 160),
	"idle": "serve", "note": "57, kiosk by the metro, will help you, unsmiling"},

"artyom": {"city": "moscow", "build": "adult", "skin": 0,
	"hair": Color8(58, 46, 38), "cut": "crop", "wear": "hivis",
	"shoes": "boots", "coat": Color8(42, 48, 64),
	"trim": Color8(200, 168, 58), "under": Color8(58, 66, 84),
	"idle": "mend", "prop": "bag",
	"note": "33, fixes lifts, smiles roughly twice a year"},

# ── Mexico City ──────────────────────────────────────────────────────────────
"pilar": {"city": "mexico", "build": "elder", "skin": 4,
	"hair": Color8(42, 30, 26), "cut": "crop", "drape": "plait",
	"wear": "marketapron", "shoes": "sandals", "coat": Color8(122, 58, 90),
	"trim": Color8(224, 212, 190), "metal": Color8(184, 147, 74),
	"idle": "sort", "note": "63, herbs and dried chillies, aisle four"},

"chuy": {"city": "mexico", "build": "adult", "skin": 4,
	"hair": Color8(30, 22, 32), "cut": "peakcap", "wear": "tee",
	"shoes": "trainers", "head": Color8(47, 122, 90),
	"coat": Color8(47, 122, 90), "trim": Color8(232, 226, 204),
	"sole": Color8(228, 226, 220),
	"idle": "cook", "prop": "glass",
	"note": "26, juice cart on the corner, never says no to anybody"},

# ── Sao Paulo ────────────────────────────────────────────────────────────────
"jandira": {"city": "saopaulo", "build": "adult", "skin": 3,
	"hair": Color8(32, 24, 32), "cut": "long", "wear": "shopcoat",
	"coat": Color8(168, 58, 58), "under": Color8(232, 220, 192),
	"metal": Color8(198, 194, 186),
	"idle": "sort", "prop": "box",
	"note": "41, the shop under the red lamps, stands very close"},

"wellington": {"city": "saopaulo", "build": "adult", "skin": 5,
	"hair": Color8(26, 20, 24), "cut": "shaved", "face": "beard",
	"wear": "tee", "shoes": "trainers", "coat": Color8(42, 42, 52),
	"trim": Color8(216, 192, 88), "sole": Color8(226, 224, 218),
	"idle": "nod", "prop": "phone",
	"note": "29, sound engineer, touches your arm mid-sentence"},

# ── Dakar ────────────────────────────────────────────────────────────────────
"ousmane": {"city": "dakar", "build": "adult", "skin": 6,
	"hair": Color8(26, 20, 20), "cut": "crop", "face": "beard",
	"wear": "boubou", "shoes": "sandals", "coat": Color8(224, 228, 232),
	"trim": Color8(122, 154, 176),
	"idle": "mend", "prop": "cloth",
	"note": "52, tailor two doors from the mosque, never rushed"},

"awa": {"city": "dakar", "build": "adult", "skin": 6,
	"hair": Color8(26, 20, 20), "cut": "wrap", "wear": "boubou",
	"shoes": "sandals", "head": Color8(216, 160, 58),
	"coat": Color8(47, 122, 134), "trim": Color8(216, 160, 58),
	"idle": "sort", "prop": "cloth",
	"note": "36, wax cloth six bolts deep, will out-greet anybody"},

# ── Tbilisi ──────────────────────────────────────────────────────────────────
"zurab": {"city": "tbilisi", "build": "elder", "skin": 2,
	"hair": Color8(138, 132, 124), "cut": "thinning", "face": "moustache",
	"wear": "openshirt", "shoes": "boots", "coat": Color8(74, 58, 58),
	"under": Color8(208, 196, 168),
	"idle": "talk", "prop": "glass",
	"note": "66, keeps wine in the cellar under the balcony, runs the table"},

"nino": {"city": "tbilisi", "build": "adult", "skin": 2,
	"hair": Color8(42, 32, 40), "cut": "wrap", "wear": "apron",
	"shoes": "boots", "head": Color8(122, 106, 138),
	"coat": Color8(74, 90, 74), "trim": Color8(224, 218, 200),
	"under": Color8(232, 228, 214),
	"idle": "sort", "note": "48, cheese and herbs by the station, coaches you"},

# ── Seoul ────────────────────────────────────────────────────────────────────
"baek": {"city": "seoul", "build": "elder", "skin": 1,
	"hair": Color8(160, 154, 146), "cut": "peakcap", "wear": "shopcoat",
	"shoes": "boots", "head": Color8(58, 64, 72),
	"coat": Color8(74, 80, 88), "under": Color8(200, 192, 176),
	"metal": Color8(168, 164, 156),
	"idle": "mend", "note": "71, lathe and press, same unit since 1979"},

"jiwon": {"city": "seoul", "build": "adult", "skin": 1,
	"hair": Color8(32, 26, 32), "cut": "bob", "mark": "wireglasses",
	"wear": "hoodie", "shoes": "trainers", "coat": Color8(42, 48, 64),
	"trim": Color8(216, 210, 200), "metal": Color8(160, 158, 154),
	"sole": Color8(226, 224, 218),
	"idle": "read", "prop": "phone",
	"note": "31, designs type upstairs from a press, drops honorifics early"},

# ── Mumbai ───────────────────────────────────────────────────────────────────
"farid": {"city": "mumbai", "build": "adult", "skin": 5,
	"hair": Color8(42, 32, 36), "cut": "crop", "face": "beard",
	"wear": "kurta", "shoes": "sandals", "coat": Color8(216, 210, 192),
	"trim": Color8(138, 122, 74),
	"idle": "sort", "prop": "brass",
	"note": "54, brass, clocks and things off ships, sells in three at once"},

"sunita": {"city": "mumbai", "build": "adult", "skin": 4,
	"hair": Color8(26, 18, 24), "cut": "dupatta", "wear": "sari",
	"shoes": "sandals", "head": Color8(200, 74, 106),
	"coat": Color8(122, 44, 90), "trim": Color8(224, 192, 88),
	"idle": "sort", "note": "47, wholesale thread, fourth generation"},

# ── La Paz ───────────────────────────────────────────────────────────────────
"remedios": {"city": "lapaz", "build": "elder", "skin": 4,
	"hair": Color8(26, 18, 24), "cut": "bowler", "drape": "plait",
	"wear": "pollera", "shoes": "sandals", "head": Color8(42, 38, 44),
	"coat": Color8(47, 90, 122), "trim": Color8(216, 168, 58),
	"idle": "sort", "prop": "basket", "prop_side": 0.0,
	"note": "64, potatoes and dried maize, 16 de Julio, marks every claim"},

"mauricio": {"city": "lapaz", "build": "adult", "skin": 4,
	"hair": Color8(30, 22, 32), "cut": "peakcap", "wear": "suit",
	"head": Color8(58, 74, 122), "coat": Color8(58, 74, 122),
	"trim": Color8(232, 200, 58), "under": Color8(224, 226, 232),
	"idle": "wait", "note": "39, cable car operator, Linea Amarilla"},

# ── Paris ────────────────────────────────────────────────────────────────────
"elodie": {"city": "paris", "build": "adult", "skin": 1,
	"hair": Color8(106, 74, 48), "cut": "bun", "wear": "shopcoat",
	"coat": Color8(47, 90, 74), "under": Color8(216, 203, 176),
	"metal": Color8(176, 172, 164),
	"idle": "serve", "prop": "papers",
	"note": "the kiosk by the lawn, asked in nine languages, greeted in none"},

"karim": {"city": "paris", "build": "adult", "skin": 3,
	"hair": Color8(42, 32, 36), "cut": "crop", "face": "beard",
	"mark": "wireglasses", "wear": "goodcoat", "head": Color8(122, 58, 58),
	"coat": Color8(74, 74, 86), "trim": Color8(122, 58, 58),
	"under": Color8(216, 208, 192), "metal": Color8(160, 156, 150),
	"idle": "read", "prop": "book",
	"note": "books off a trestle, decides vous or tu in one sentence"},

# ── Sydney ───────────────────────────────────────────────────────────────────
"jen": {"city": "sydney", "build": "adult", "skin": 0,
	"hair": Color8(122, 90, 58), "cut": "tied", "wear": "hivis",
	"shoes": "boots", "coat": Color8(42, 58, 74),
	"trim": Color8(216, 232, 58), "under": Color8(58, 74, 90),
	"idle": "watch", "note": "works the ferry wharf, shortens every word she can"},

"thuy": {"city": "sydney", "build": "adult", "skin": 3,
	"hair": Color8(26, 20, 24), "cut": "long", "wear": "suit",
	"shoes": "heels", "coat": Color8(42, 44, 56),
	"trim": Color8(200, 184, 160), "under": Color8(226, 224, 218),
	"idle": "wait", "prop": "phone",
	"note": "works in a tower, grew up forty minutes west"},

# ── The hand-built four, and Yusuf ───────────────────────────────────────────
# These five predate the roster and each keep their own script. They were the
# last people in the game still being drawn out of a hash.
"lukas": {"city": "berlin", "build": "adult", "skin": 1,
	"hair": Color8(106, 74, 44), "cut": "crop", "wear": "apron",
	"shoes": "boots", "coat": Color8(74, 62, 90),
	"trim": Color8(216, 200, 168), "under": Color8(228, 220, 200),
	"idle": "serve", "prop": "loaf",
	"note": "the bread man at the field market, up since four"},

"weber": {"city": "berlin", "build": "adult", "skin": 0,
	"hair": Color8(74, 58, 48), "cut": "bun", "wear": "suit",
	"coat": Color8(58, 47, 84), "trim": Color8(138, 122, 176),
	"under": Color8(224, 222, 232),
	"idle": "serve", "note": "Frau Weber, night reception, polite at five a.m."},

"renate": {"city": "berlin", "build": "elder", "skin": 0,
	"hair": Color8(176, 170, 162), "cut": "perm", "mark": "chainglasses",
	"wear": "goodcoat", "head": Color8(106, 74, 90),
	"coat": Color8(90, 84, 106), "trim": Color8(106, 74, 90),
	"metal": Color8(160, 156, 150),
	"idle": "wait", "prop": "bag",
	"note": "at the bus stop, as she apparently has been for a while"},

"ayse": {"city": "berlin", "build": "adult", "skin": 2,
	"hair": Color8(42, 30, 34), "cut": "long", "wear": "puffer",
	"shoes": "boots", "coat": Color8(138, 74, 58),
	"trim": Color8(224, 210, 186),
	"idle": "talk", "note": "one half of the two friends on the morning walk"},

"jonas": {"city": "berlin", "build": "adult", "skin": 0,
	"hair": Color8(154, 122, 74), "cut": "crop", "wear": "hoodie",
	"shoes": "trainers", "coat": Color8(90, 106, 74),
	"trim": Color8(192, 158, 90), "sole": Color8(226, 224, 218),
	"idle": "talk", "note": "the other half, and the one who does the listening"},

"yusuf": {"city": "istanbul", "build": "adult", "skin": 2,
	"hair": Color8(32, 26, 30), "cut": "crop", "face": "moustache",
	"wear": "shopcoat", "coat": Color8(106, 74, 58),
	"under": Color8(224, 214, 192), "metal": Color8(198, 168, 96),
	"idle": "talk", "prop": "glass",
	"note": "the shop in the han, and the glass eye above its door"},
# ── The eight who come to you ────────────────────────────────────────────────
#
# scenes/npc/Encounters.gd. They are strangers - a man with the wrong key, a
# neighbour about the bins - so none of them is a character in the roster
# sense, and all of them still get a design, because "a person nobody has met"
# is not a reason to draw somebody out of a hash.
"neumann": {"city": "berlin", "build": "adult", "skin": 0,
	"hair": Color8(74, 64, 54), "cut": "thinning", "face": "moustache",
	"wear": "goodcoat", "head": Color8(74, 62, 74),
	"coat": Color8(74, 66, 84), "trim": Color8(74, 62, 74),
	"idle": "wait", "prop": "bag",
	"note": "in room 304, with a card that worked last week"},

"bins_woman": {"city": "london", "build": "adult", "skin": 0,
	"hair": Color8(122, 90, 58), "cut": "bun", "wear": "housecoat",
	"shoes": "trainers", "coat": Color8(90, 106, 122),
	"trim": Color8(216, 208, 192), "sole": Color8(226, 224, 218),
	"idle": "talk", "note": "number nine, and she has waited a week to say it"},

"bonjour_man": {"city": "paris", "build": "adult", "skin": 1,
	"hair": Color8(58, 47, 42), "cut": "crop", "wear": "apron",
	"coat": Color8(58, 62, 74), "trim": Color8(228, 222, 208),
	"under": Color8(236, 232, 220),
	"idle": "serve", "note": "behind the counter, correcting something once"},

"hold_man": {"city": "moscow", "build": "adult", "skin": 0,
	"hair": Color8(74, 62, 52), "cut": "flatcap", "face": "moustache",
	"wear": "quilted", "shoes": "boots", "head": Color8(58, 54, 58),
	"coat": Color8(58, 62, 74), "trim": Color8(90, 100, 116),
	"idle": "mend", "note": "a broken strap and no spare hand"},

"cay_man": {"city": "istanbul", "build": "adult", "skin": 2,
	"hair": Color8(42, 34, 36), "cut": "crop", "face": "moustache",
	"wear": "shopcoat", "coat": Color8(90, 74, 62),
	"under": Color8(224, 214, 192),
	"idle": "serve", "prop": "glass", "prop_side": 0.0,
	"note": "two doors down, holding a glass you did not order"},

"mandal_boy": {"city": "mumbai", "build": "youth", "skin": 4,
	"hair": Color8(22, 18, 26), "cut": "crop", "wear": "mandaltee",
	"shoes": "sandals", "coat": Color8(224, 138, 46),
	"trim": Color8(242, 233, 216),
	"idle": "talk", "prop": "papers",
	"note": "a receipt book and forty feet of Ganpati to pay for"},

"eating_woman": {"city": "tokyo", "build": "elder", "skin": 1,
	"hair": Color8(168, 162, 156), "cut": "perm", "mark": "chainglasses",
	"wear": "apron", "shoes": "sandals", "coat": Color8(122, 106, 90),
	"trim": Color8(232, 226, 212), "under": Color8(220, 214, 200),
	"idle": "wipe", "note": "saw you walking and eating, and came after you"},

"flower_woman": {"city": "mexico", "build": "adult", "skin": 4,
	"hair": Color8(30, 22, 28), "cut": "crop", "drape": "plait",
	"wear": "marketapron", "shoes": "sandals", "coat": Color8(184, 74, 106),
	"trim": Color8(239, 230, 210), "metal": Color8(184, 147, 74),
	"idle": "sort", "prop": "flowers", "prop_side": 0.0,
	"note": "both arms full, and now so are yours"},
}



# The default parts, where a person does not say otherwise. Written out rather
# than derived, because a placeholder colour literal has cost this project
# more cycles than any other single habit.
const OUTLINE := Color8(38, 30, 46)
const EYE := Color8(34, 28, 40)
const WHITE := Color8(246, 242, 250)
const LIP := Color8(150, 92, 88)
const LEGS := Color8(58, 46, 42)
const SOLE := Color8(38, 30, 28)
const METAL := Color8(198, 168, 96)
const UNDER := Color8(216, 210, 198)

# Facial hair is the mouth row in the hair colour, never a very large lip.
const HAIRY := ["beard", "moustache"]


static func has_person(id: String) -> bool:
	return PEOPLE.has(id)


# A designed person, ready for CharacterArt.draw_figure. Anybody without an
# entry falls through to the crowd's own generator, which is the right answer
# for somebody who genuinely is one more person on the street.
static func look(id: String, city: String = "") -> Dictionary:
	if not PEOPLE.has(id):
		return CH.look(absi(id.hash()), city)
	var d: Dictionary = PEOPLE[id]
	var skin: Array = CH.SKINS[int(d.get("skin", 1)) % CH.SKINS.size()]
	var hair: Color = d.get("hair", CH.HAIRS[0])
	var coat: Color = d.get("coat", CH.COATS[0])
	var trim: Color = d.get("trim", coat.lightened(0.34))
	var head: Color = d.get("head", trim)
	var face: String = String(d.get("face", ""))
	return {
		"alien": false,
		"build": String(d.get("build", "adult")),
		"cut": String(d.get("cut", "crop")),
		"drape": String(d.get("drape", "")),
		"face": face,
		"mark": String(d.get("mark", "")),
		"wear": String(d.get("wear", "coat")),
		"shoes": String(d.get("shoes", "")),
		"idle": String(d.get("idle", "")),
		"prop": String(d.get("prop", "")),
		"prop_side": float(d.get("prop_side", 1.0)),
		"pal": {
			"X": OUTLINE,
			"S": skin[0], "L": skin[1], "H": skin[2],
			"E": EYE, "W": WHITE,
			"M": hair if HAIRY.has(face) else LIP,
			"R": hair,
			"C": coat, "O": coat.darkened(0.42), "D": coat.darkened(0.22),
			"g": trim, "a": trim,
			"P": head, "p": head.darkened(0.30),
			"n": d.get("under", UNDER),
			"j": d.get("metal", METAL),
			"B": d.get("legs", LEGS),
			"K": d.get("sole", SOLE),
		},
	}


# ── The people behind the counters ───────────────────────────────────────────
#
# A hundred ServicePoints across twenty cities each draw a clerk, and every one
# of them was CHAR.look() of a hashed string: the woman at the Tokyo ticket
# window and the man at the Dakar bureau were the same coat in whatever colours
# their ids landed on, and neither of them was dressed for the job.
#
# They have no names and should not get any - they are the counter, not a
# character. What they should have is the uniform of the counter they are
# standing at, which is a real and specific thing per service, and the skin of
# somewhere plausible for the city they are standing in, which CharacterArt's
# per-city bands already know how to do.
const TRADES := {
	"hotel_desk":    {"wear": "suit", "idle": "serve",
		"coat": Color8(58, 47, 84), "trim": Color8(138, 122, 176)},
	"exchange":      {"wear": "suit", "idle": "count",
		"coat": Color8(42, 58, 84), "trim": Color8(184, 160, 96)},
	"police_desk":   {"wear": "suit", "idle": "wait",
		"coat": Color8(38, 46, 66), "trim": Color8(196, 176, 90)},
	"hospital_desk": {"wear": "shopcoat", "idle": "read",
		"coat": Color8(196, 206, 210), "under": Color8(120, 158, 168)},
	"airport_desk":  {"wear": "suit", "idle": "serve",
		"coat": Color8(46, 62, 88), "trim": Color8(184, 62, 62)},
	"ubahn_ticket":  {"wear": "hivis", "idle": "wait",
		"coat": Color8(42, 52, 66), "trim": Color8(200, 176, 58)},
	"lost_property": {"wear": "shopcoat", "idle": "sort",
		"coat": Color8(96, 84, 62), "under": Color8(206, 196, 172)},
	"jobboard":      {"wear": "hivis", "idle": "watch",
		"coat": Color8(48, 54, 64), "trim": Color8(208, 184, 60)},
	"yusuf_shop":    {"wear": "shopcoat", "idle": "talk",
		"coat": Color8(106, 74, 58), "under": Color8(224, 214, 192)},
	"local":         {"wear": "apron", "idle": "serve",
		"coat": Color8(86, 74, 96), "trim": Color8(224, 216, 198)},
	"job_crates":    {"wear": "hivis", "idle": "haul",
		"coat": Color8(52, 58, 70), "trim": Color8(210, 186, 62)},
	"job_flyers":    {"wear": "hivis", "idle": "wait",
		"coat": Color8(52, 58, 70), "trim": Color8(210, 186, 62)},
	"job_dishes":    {"wear": "apron", "idle": "cook",
		"coat": Color8(180, 176, 168), "trim": Color8(228, 224, 214)},
}

# What somebody standing at an unlisted counter wears. A shop coat is the most
# honest guess there is: it says "works here" and claims nothing else.
const TRADE_DEFAULT := {"wear": "shopcoat", "idle": "serve",
	"coat": Color8(84, 78, 96), "under": Color8(212, 204, 190)}


# A clerk: dressed for the counter, from the city they are standing in.
static func clerk_look(clerk: String, service: String,
		city: String) -> Dictionary:
	var t: Dictionary = TRADES.get(service, TRADE_DEFAULT)
	# Everything not decided by the trade comes from the crowd's own generator,
	# so a clerk is a person from this city who happens to be behind a counter
	# rather than a uniform with a head on it.
	var who: Dictionary = CH.look(absi((clerk + service).hash()), city)
	who["wear"] = String(t.get("wear", "shopcoat"))
	who["idle"] = String(t.get("idle", "serve"))
	var coat: Color = t.get("coat", CH.COATS[0])
	var trim: Color = t.get("trim", coat.lightened(0.36))
	var pal: Dictionary = who["pal"]
	pal["C"] = coat
	pal["O"] = coat.darkened(0.42)
	pal["D"] = coat.darkened(0.22)
	pal["g"] = trim
	pal["a"] = trim
	pal["n"] = t.get("under", UNDER)
	pal["j"] = METAL
	pal["P"] = t.get("head", trim)
	pal["p"] = Color(pal["P"]).darkened(0.30)
	return who
