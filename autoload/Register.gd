extends Object

# How you address somebody, which is not the same thing as what you say.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# The game's thesis is that knowing the words is not enough. Until now it
# proved that with a table: five style tags - direct, casual, indirect, formal,
# gesture - worth plus or minus two points depending on the city. That is a
# real idea and it is one lookup deep, and against a vocabulary system holding
# 958 guesses in 16 languages it was the smaller half of the game pretending to
# be the larger one.
#
# Register is the other half, done properly. It is orthogonal to vocabulary:
# you can know every word in the sentence and still choose the wrong "you", and
# the failure has nothing to do with what you were trying to say. That is the
# exact experience this game is about and there was no mechanism for it.
#
# The scene that started this already exists, in Paris, once, hand-written:
#
#     "Vous, still. It is politer and it is now wrong."
#
# Seven words, the whole thesis, and one conversation. This is that, as a
# system, in every language that has one.
#
# ── The shape of a ladder ────────────────────────────────────────────────────
#
# Rungs are ordered FAMILIAR FIRST. Each is [id, what he would say, what it is
# for]. A language may have two rungs or four, and the fourth is not "extra
# politeness" - Vietnamese is not French with more steps.
#
#   default   the rung a stranger gets: where a culture starts, which is not
#             where it is most comfortable
#   warms     whether standing moves the expectation DOWN the ladder. In most
#             places being known means being addressed familiarly, and going
#             on being formal at somebody who has started calling you `du` is
#             its own kind of rude. Where this is false, the distance IS the
#             respect and it never closes
#   axis      "distance" - the rungs are about how well you know each other
#             "age"      - the rungs are about who is older, and knowing them
#                          better does not move you an inch
#
# ── The rule this file exists to keep ────────────────────────────────────────
#
# A ladder is what a language DOES, not a politeness score. Where a language
# does not divide address this way it says so and says why, exactly as the
# time-of-day table refuses to invent a translation of "good afternoon".

const LADDERS := {

# ── du / Sie ─────────────────────────────────────────────────────────────────
# Berlin is quicker to du than the rest of the country and quicker than Zurich
# by a distance, which is why the two German entries are not one entry.
"german": {
	"axis": "distance", "default": "sie", "warms": true,
	"rungs": [
		["du", "du", "somebody you know, a child, most people under thirty here"],
		["sie", "Sie", "a stranger, a counter, anybody older than you"],
	],
	"note": "Berlin offers du early and means it. Taking the offer is the polite move; declining it is the rude one.",
},
"swissgerman": {
	"axis": "distance", "default": "sie", "warms": false,
	"rungs": [
		["du", "du", "friends, and only after it has been offered out loud"],
		["sie", "Sie", "everybody else, indefinitely, including a neighbour of ten years"],
	],
	"note": "Zurich does not warm. Sie is not coldness here, it is the ordinary temperature, and du has to be handed over rather than assumed.",
},

# ── tu / vous ────────────────────────────────────────────────────────────────
"french": {
	"axis": "distance", "default": "vous", "warms": true,
	"rungs": [
		["tu", "tu", "somebody who has tutoyer-ed you first, and children"],
		["vous", "vous", "everybody, until they say otherwise"],
	],
	"note": "Vous is the default, and staying on it past the moment you were let off it is its own mistake - politer, and wrong.",
},
"italian": {
	"axis": "distance", "default": "lei", "warms": true,
	"rungs": [
		["tu", "tu", "anybody your own age in a bar, and everybody after five minutes"],
		["lei", "Lei", "a counter, an office, somebody's grandmother"],
	],
	"note": "Rome moves to tu faster than the grammar books do, and being stuck on Lei reads as keeping your distance on purpose.",
},

# ── ty / vy ──────────────────────────────────────────────────────────────────
"russian": {
	"axis": "distance", "default": "vy", "warms": true,
	"rungs": [
		["ty", "ty", "friends, family, and anybody who has told you to"],
		["vy", "vy", "strangers, and anybody older, and it is not negotiable early"],
	],
	"note": "The move to ty is an event. It gets said out loud - davay na ty - and it does not happen by drift.",
},

# ── sen / siz ────────────────────────────────────────────────────────────────
"turkish": {
	"axis": "distance", "default": "siz", "warms": true,
	"rungs": [
		["sen", "sen", "friends, anybody younger, and the whole han within a week"],
		["siz", "siz", "a stranger, and anybody you would call abla or abi"],
	],
	"note": "Siz gets you in the door and sen keeps you in the room. Istanbul warms fast and expects you to warm with it.",
},

# ── tu / usted ───────────────────────────────────────────────────────────────
"spanish_mx": {
	"axis": "distance", "default": "usted", "warms": true,
	"rungs": [
		["tu", "tu", "anybody your age, and the market after the second visit"],
		["usted", "usted", "elders, and anybody serving you, and it is warm rather than stiff"],
	],
	"note": "Usted in Mexico City is affection with distance in it, not coldness. It is what you call somebody's mother forever.",
},
"spanish_bo": {
	"axis": "distance", "default": "usted", "warms": false,
	"rungs": [
		["tu", "tu", "people your own age you already know"],
		["usted", "usted", "almost everybody, almost always"],
	],
	"note": "La Paz stays on usted long after Mexico City would have let it go, and dropping it early reads as a stranger being familiar.",
},

# ── voce / o senhor ──────────────────────────────────────────────────────────
"portuguese": {
	"axis": "distance", "default": "voce", "warms": false,
	"rungs": [
		["voce", "voce", "everybody, at once, including people you have never met"],
		["senhor", "o senhor / a senhora", "the elderly, and anybody you have just been rude to"],
	],
	# `warms` is false here and it is not the same false as Zurich's. Zurich
	# starts formal and never closes the distance; Sao Paulo starts CLOSED, so
	# there is nowhere for standing to move it - the default is already the
	# bottom rung. The ladder runs the other way: the mistake this language
	# punishes is reaching for o senhor unprompted, which reads as holding
	# somebody at arm's length rather than as good manners. Age still moves it,
	# which is why senhor exists at all.
	"note": "Sao Paulo starts familiar and stays there. Being too formal is the error here, not being too close.",
},

# ── plain / -masu / keigo ────────────────────────────────────────────────────
"japanese": {
	"axis": "distance", "default": "teinei", "warms": false,
	"rungs": [
		["futsuu", "plain form", "close friends, and nobody you met this year"],
		["teinei", "-masu / -desu", "the ordinary polite register, and where a foreigner should live"],
		["keigo", "keigo", "customers, officials, and anybody whose shop you are standing in"],
	],
	"note": "Three rungs, and the middle one is not a compromise - it is the correct answer almost always. Reaching for keigo unprompted is its own error and a common one.",
},

# ── banmal / haeyo / hapsyo ──────────────────────────────────────────────────
"korean": {
	"axis": "distance", "default": "haeyo", "warms": false,
	"rungs": [
		["banmal", "banmal", "only once somebody has said you may, and they will say it"],
		["haeyo", "haeyo-che", "ordinary polite speech, where almost everything happens"],
		["hapsyo", "hapsyo-che", "a counter, an announcement, somebody twice your age"],
	],
	"note": "Age decides this before friendship does, and the question of who is older gets asked out loud early so that it can.",
},

# ── tu / tum / aap ───────────────────────────────────────────────────────────
"hindi": {
	"axis": "distance", "default": "aap", "warms": true,
	"rungs": [
		["tu", "tu", "intimacy or insult, with almost nothing in between"],
		["tum", "tum", "friends, and the lane once it knows you"],
		["aap", "aap", "elders, strangers, and anybody being served"],
	],
	"note": "Three rungs, and the bottom one is dangerous: tu to the wrong person is not familiarity, it is contempt.",
},

# ── the one that is not about distance at all ────────────────────────────────
# Vietnamese has no polite `you`. It has a kinship term for every relative age,
# and you must decide which one you are before you can say anything at all -
# including hello. There is no neutral option to hide in.
"vietnamese": {
	"axis": "age", "default": "anh_chi", "warms": false,
	"rungs": [
		["em", "em", "you are the younger one, and they are not much older"],
		["anh_chi", "anh / chi", "they are a little older than you - the safe guess"],
		["co_chu", "co / chu", "your parents' generation"],
		["bac", "bac", "older than your parents"],
	],
	"note": "The pronoun IS the greeting. Getting it wrong is not rudeness, it is a claim about how old you both are, made out loud, in public, before anything else is said.",
},

# ── yow / yeen ───────────────────────────────────────────────────────────────
"wolof": {
	"axis": "distance", "default": "yeen", "warms": true,
	"rungs": [
		["yow", "yow", "one person, who you know"],
		["yeen", "yeen", "the plural, used for one person as respect"],
	],
	"note": "The respect is the plural, and it matters far less here than the greeting does. In Dakar what you get wrong is skipping the salaam, not the pronoun.",
},

# ── shen / tkven ─────────────────────────────────────────────────────────────
"georgian": {
	"axis": "distance", "default": "tkven", "warms": true,
	"rungs": [
		["shen", "shen", "friends, and the table after the second toast"],
		["tkven", "tkven", "strangers and elders, briefly"],
	],
	"note": "Tbilisi warms across one meal. Staying formal at a table you have been fed at is the mistake.",
},

# ── and the one with no ladder ───────────────────────────────────────────────
# English has no grammatical second person to get wrong, which is exactly why
# London is the hardest city in the game to read: the politeness is all in
# phrasing, hedging and volume, and none of it is visible as a choice. An empty
# ladder is a fact about English, not a gap in this table.
"english": {
	"axis": "none", "default": "", "warms": false, "rungs": [],
	"note": "One `you` for everybody. The register is real and it is hidden in how much you hedge, which is why nobody can tell you when you have got it wrong.",
},
}


# ── Being corrected ──────────────────────────────────────────────────────────
#
# How anybody actually learns this: somebody says it back to you the right way.
# Not a tutorial and not a hint - a person, mildly, in the middle of something
# else, because they would rather you got it right than watch you get it wrong
# again.
#
# Each entry is [what they say, what he makes of it]. `formal` is the
# correction he gets for keeping his distance; `close` is the one for taking a
# liberty, and the two are not the same temperature anywhere in this table.
#
# The important rule is in the CALLER, not here: only people who already think
# reasonably well of him bother. Below that they simply cool, and he is left to
# work out why on his own - which is the more common experience of this and the
# reason the mechanic is not a difficulty setting.
const CORRECTIONS := {
"german": {
	"formal": ["Ach, sag doch du.",
		"She waved the Sie away like a fly. Whatever I have been doing,\nI am to stop doing it."],
	"close": ["Wir sind per Sie, junger Mann.",
		"That was said pleasantly and it was not a suggestion. There is a\nline and I have just found out where it is."],
},
"swissgerman": {
	"formal": ["Sie chonnd ruhig du sage.",
		"An offer, made once, carefully. I do not think it gets made twice."],
	"close": ["Mir sind no bim Sie.",
		"Not annoyed. Corrected, the way you would straighten a picture."],
},
"french": {
	"formal": ["On peut se tutoyer, vous savez.",
		"There is a verb for it. They have a verb for the act of changing\nhow you speak to somebody, and I have just been offered it."],
	"close": ["On ne se connait pas si bien que ca.",
		"Said with a small smile that did not reach anything. I stepped\nover a line I could not see, and it was drawn a long time ago."],
},
"italian": {
	"formal": ["Ma dammi del tu, dai.",
		"Impatient with the formality rather than with me. Lei is being\ntreated as the rude thing here, which is new."],
	"close": ["Diamoci del Lei, per favore.",
		"Cooler than the room was a second ago."],
},
"russian": {
	"formal": ["Davay na ty.",
		"He said it like a decision being taken rather than a favour being\ndone. I think that is exactly what it was."],
	"close": ["Davayte na vy.",
		"The 'te' is the whole correction. One syllable, and I am back\nwhere I started."],
},
"turkish": {
	"formal": ["Abi ya, sen de.",
		"He is telling me off for being formal, and calling me abi while\nhe does it, which I think means it is affectionate."],
	"close": ["Siz deyin, kolay gelsin.",
		"Polite all the way through, and unmistakable."],
},
"spanish_mx": {
	"formal": ["No me hables de usted, hombre.",
		"Usted was making him feel old. That had not occurred to me as a\nthing a word could do."],
	"close": ["De usted, joven.",
		"'Joven'. Corrected and placed, in two words."],
},
"spanish_bo": {
	"formal": ["Puede tutearme, no mas.",
		"Offered, and then not repeated, and I notice she went on using\nusted with me anyway."],
	"close": ["De usted, por favor.",
		"Flat. This city does not hand that over quickly and I tried to\ntake it."],
},
"portuguese": {
	"formal": ["Pode falar voce, relaxa.",
		"He found the formality funny. Not unkindly - funny."],
	"close": ["Trata por senhora, meu bem.",
		"'Meu bem' and a correction in the same breath. Both were meant."],
},
"japanese": {
	"formal": ["Sonna ni katakuranakute mo.",
		"I reached past polite into something stiffer, and it landed as\ndistance rather than as respect."],
	"close": ["...desu, ne.",
		"She repeated my sentence back with the ending on it. She did not\nmark it as a correction. It was one."],
},
"korean": {
	"formal": ["Geunyang pyeonhage haseyo.",
		"Permission, given explicitly, because here it has to be."],
	"close": ["Malsseum nopyeo jusillaeyo.",
		"I used the short form at somebody I had no standing to use it\nwith. It is not rudeness exactly. It is a claim."],
},
"hindi": {
	"formal": ["Aap kya, tum bolo.",
		"Aap was putting a counter between us and he moved it."],
	"close": ["Aap kahiye, bhai.",
		"He called me bhai and asked for aap in the same sentence, and\nboth of those things are true at once."],
},
"vietnamese": {
	"formal": ["Goi anh la duoc roi.",
		"I had aged him a generation. He corrected it the way you would\ncorrect a spelling - immediately, and without any weight on it."],
	"close": ["Goi bang co nhe.",
		"I made her younger than she is, out loud, in front of her shop.\nThat is not a grammar mistake."],
},
"wolof": {
	"formal": ["Yow la wax, waaw.",
		"The plural was doing more work than it needed to."],
	"close": ["Yeen laa wax.",
		"Gently. The greeting matters more here than this does, and we\nboth know it."],
},
"georgian": {
	"formal": ["Shen mitxari, ra.",
		"Two toasts in and the formal one has become the strange one."],
	"close": ["Tkven, tu sheidzleba.",
		"Briefly. Then the table carried on."],
},
}


# The correction for a slip, or an empty array where the language has none.
# `off` is positive for too formal and negative for too familiar.
static func correction(language: String, off: int) -> Array:
	if off == 0:
		return []
	var row: Dictionary = CORRECTIONS.get(language, {})
	var key: String = "formal" if off > 0 else "close"
	var pair: Array = row.get(key, [])
	return pair


# ── Reading the table ────────────────────────────────────────────────────────

static func has_ladder(language: String) -> bool:
	var row: Dictionary = LADDERS.get(language, {})
	var rs: Array = row.get("rungs", [])
	return not rs.is_empty()


static func rungs(language: String) -> Array:
	var row: Dictionary = LADDERS.get(language, {})
	var rs: Array = row.get("rungs", [])
	return rs


static func rung_ids(language: String) -> Array:
	var out: Array = []
	for r: Array in rungs(language):
		out.append(String(r[0]))
	return out


static func default_rung(language: String) -> String:
	var row: Dictionary = LADDERS.get(language, {})
	return String(row.get("default", ""))


static func warms(language: String) -> bool:
	var row: Dictionary = LADDERS.get(language, {})
	return bool(row.get("warms", false))


static func axis(language: String) -> String:
	var row: Dictionary = LADDERS.get(language, {})
	return String(row.get("axis", "none"))


static func note(language: String) -> String:
	var row: Dictionary = LADDERS.get(language, {})
	return String(row.get("note", ""))


# How a rung is written on a button, and what it is for.
static func shown(language: String, rung: String) -> String:
	for r: Array in rungs(language):
		if String(r[0]) == rung:
			return String(r[1])
	return rung


static func gloss(language: String, rung: String) -> String:
	for r: Array in rungs(language):
		if String(r[0]) == rung:
			return String(r[2])
	return ""


static func index_of(language: String, rung: String) -> int:
	var ids: Array = rung_ids(language)
	return ids.find(rung)


# ── What this person expects to be called ────────────────────────────────────
#
# Nobody authored this per person and nobody should have to: the roster already
# says how old everybody is, and the world already knows how well you are
# thought of. Both facts were sitting there being read by nothing.
#
#   who       a person's `who` dictionary - `build` is child/youth/adult/elder
#   standing  city reputation, -100..100
#
# On an AGE ladder the answer is only their age, and no amount of being liked
# moves it: you do not get promoted out of being younger than somebody.
#
# On a DISTANCE ladder a stranger gets the default, and being known moves the
# expectation one rung toward the familiar - but only in a culture that warms.
# Zurich, La Paz, Tokyo and Seoul do not, and that is the point of them.
const WARM_AT := 35          # the same threshold the endings call being known
const CLOSE_AT := 70         # and the one that gets you the bottom rung


# The eight carry an age rather than a build, because they were written as
# people before they were drawn. One place to turn one into the other, so that
# a seventy-four-year-old is not an adult in one file and an elder in another.
static func build_for_age(age: int) -> String:
	if age <= 0:
		return "adult"
	if age < 13:
		return "child"
	if age < 21:
		return "youth"
	if age >= 65:
		return "elder"
	return "adult"


static func expected(language: String, who: Dictionary, standing: int) -> String:
	if not has_ladder(language):
		return ""
	var ids: Array = rung_ids(language)
	if ids.is_empty():
		return ""
	var build: String = String(who.get("build", "adult"))

	if axis(language) == "age":
		# Their generation against his. He reads as a young adult to everybody
		# who meets him, which is its own small joke: nobody can place him and
		# everybody has to try.
		if build == "child" or build == "youth":
			return String(ids[0])
		if build == "elder":
			return String(ids[mini(3, ids.size() - 1)])
		return String(ids[mini(1, ids.size() - 1)])

	var at: int = index_of(language, default_rung(language))
	if at < 0:
		at = ids.size() - 1
	# A child is never addressed formally in any of these languages.
	if build == "child":
		return String(ids[0])
	if warms(language):
		if standing >= CLOSE_AT:
			at -= 2
		elif standing >= WARM_AT:
			at -= 1
	# An elder holds their rung a step longer than anybody else does.
	if build == "elder":
		at += 1
	return String(ids[clampi(at, 0, ids.size() - 1)])


# What it reads as when he gets it wrong, in the language's own terms rather
# than as a number. A positive `off` means he was too formal and a negative one
# too familiar - and they are not the same mistake, which is the entire reason
# this returns prose instead of a delta.
# The moment somebody's expectation of him moves, said in his own voice.
#
# Without this the mechanic is a trap. The expectation shifts when a city warms
# to him, and if that happens silently then the first he knows of it is a
# penalty for a thing that was correct yesterday - which is not the experience
# of being let in, it is the experience of an unmarked rule. So the crossing is
# an EVENT, and he notices it, because in life somebody says it out loud.
static func moved(language: String, from_rung: String, to_rung: String) -> String:
	if not has_ladder(language) or from_rung == to_rung:
		return ""
	var was: String = shown(language, from_rung)
	var now: String = shown(language, to_rung)
	var closer: bool = index_of(language, to_rung) < index_of(language, from_rung)
	if axis(language) == "age":
		return "They called me %s, not %s.\n\nThat is not politeness. That " \
			% [now, was] + "is somebody deciding how old I am,\nand saying " \
			+ "it in front of me, and being right."
	if closer:
		return "They said %s.\n\nThey have been saying %s since I got here. " \
			% [now, was] + "Nobody announced\nit. It just happened, and now " \
			+ "saying %s back would be the\ncold thing to do." % was
	return "They have gone back to %s.\n\nI had %s. I do not know which " \
		% [now, was] + "thing I did, and there is no\nway to ask that is not " \
		+ "the same mistake again."


static func misread(language: String, used: String, want: String) -> String:
	if not has_ladder(language) or used == want or used.is_empty():
		return ""
	var off: int = index_of(language, used) - index_of(language, want)
	if off == 0:
		return ""
	if axis(language) == "age":
		if off > 0:
			return "made them older than they are, out loud"
		return "made them younger than they are, out loud"
	if off > 0:
		return "kept a distance they had already closed"
	return "closed a distance that was not his to close"
