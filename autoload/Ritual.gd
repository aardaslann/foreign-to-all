extends Object

# When you speak, and how many times you say no before you say yes.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# Register covers which "you" he uses. It does not cover the two things that
# get a foreigner wrong most often and which no amount of vocabulary fixes:
#
#   TIMING    a pause is not the absence of an answer. It IS one, and it means
#             something different in every city on this itinerary. In Tokyo it
#             is consideration; in Rome it is a hole somebody else will fill;
#             in Dakar being quick is itself the error, because the greeting
#             cannot be hurried and business does not start until it is done
#
#   RITUAL    somebody puts a glass in front of you. Taking it straight away
#             is not gratitude and refusing it is not politeness. There is a
#             number of times you are supposed to say no first, and it is not
#             the same number in Istanbul as it is in Berlin, where it is zero
#             and a token refusal reads as somebody who does not know what
#             they want
#
# Both are things the player can get wrong while understanding every word, and
# both are things nobody will ever explain to them. That is the whole subject.
#
# ── The rule this file keeps ─────────────────────────────────────────────────
#
# These are hospitality customs, not national character. `refusals: 1` in
# Istanbul is a fact about how an offer is made and accepted there; it is not a
# claim that Turkish people are indirect. Where a place does not do this, the
# entry says zero and says why, rather than inventing a ceremony to make the
# table look full.

# ── How long a silence is allowed to be ──────────────────────────────────────
#
#   seconds  before the pause stops being a pause and becomes his answer
#   reads    what it is taken for
#   rep      what it costs, or is worth. Silence is NEVER catastrophic: it is
#            a different answer rather than a failure, and in two cities it is
#            the best one available
const PATIENCE := {
"berlin": {"seconds": 8.0, "rep": -1, "reads": "evasive",
	"note": "A question was asked. Not answering it is the only rude thing available here."},
"zurich": {"seconds": 9.0, "rep": -1, "reads": "unhelpful",
	"note": "The pause is fine. The absence of an answer at the end of it is not."},
"london": {"seconds": 11.0, "rep": 0, "reads": "an awkwardness everybody survives",
	"note": "The silence is excruciating and costs nothing. Somebody fills it and then apologises for filling it."},
"paris": {"seconds": 9.0, "rep": -1, "reads": "a snub",
	"note": "A question deserves a reply, and the reply is the courtesy rather than the content of it."},
"moscow": {"seconds": 13.0, "rep": 0, "reads": "nothing at all",
	"note": "Nobody here is frightened of a silence and nobody fills one to be polite."},
"istanbul": {"seconds": 7.0, "rep": -2, "reads": "a refusal",
	"note": "In a conversation this warm, going quiet is the loudest thing he can do."},
"mumbai": {"seconds": 7.0, "rep": -1, "reads": "an opening",
	"note": "The gap gets taken. Not out of rudeness - somebody assumed he had finished."},
"tokyo": {"seconds": 16.0, "rep": 1, "reads": "consideration",
	"note": "He said nothing for a long moment and it landed as thought rather than as absence. This is the only city where waiting is the answer."},
"seoul": {"seconds": 13.0, "rep": 0, "reads": "deference",
	"note": "Letting the older person speak first is not hesitation, and stopping to let them is not weakness."},
"mexico": {"seconds": 9.0, "rep": -1, "reads": "coldness",
	"note": "Warmth is kept up by both people. Dropping his end of it reads as withdrawing."},
"lapaz": {"seconds": 14.0, "rep": 0, "reads": "ordinary",
	"note": "Nothing is hurried at this altitude and a pause is not an event."},
"saopaulo": {"seconds": 8.0, "rep": -1, "reads": "a wall",
	"note": "The conversation is a thing being built between two people and he stopped carrying his half."},
"rome": {"seconds": 7.0, "rep": -1, "reads": "a gap",
	"note": "Somebody else took the sentence. They were not being rude; it was lying there."},
"hanoi": {"seconds": 12.0, "rep": 0, "reads": "fine",
	"note": "Getting the words in the right order matters more than getting them out quickly."},
"dakar": {"seconds": 18.0, "rep": 1, "reads": "correct",
	"note": "Nothing here starts until the greeting has finished, and the greeting takes as long as it takes. Waiting is not politeness. It is the procedure."},
"tbilisi": {"seconds": 12.0, "rep": 0, "reads": "a breath",
	"note": "The table waits. It has waited longer than this for worse toasts."},
"newyork": {"seconds": 6.0, "rep": -1, "reads": "a lost turn",
	"note": "The turn passes. Nobody took it from him and nobody is coming back for it."},
"toronto": {"seconds": 11.0, "rep": 0, "reads": "no problem at all",
	"note": "It gets waited out, and then somebody apologises to him for the wait."},
"sydney": {"seconds": 9.0, "rep": -1, "reads": "hard work",
	"note": "The exchange is meant to be easy. Making it effortful is the fault."},
"honolulu": {"seconds": 14.0, "rep": 0, "reads": "fine",
	"note": "Nobody is in a hurry and nobody reads anything into him not being either."},
}


# ── How many times you say no first ──────────────────────────────────────────
#
# `refusals` is the number of token declines expected before accepting. Zero is
# a real answer and eight cities have it.
const HOSPITALITY := {
"istanbul": {"refusals": 1,
	"right": "She put it down anyway, which I now think was the plan. The\nrefusal was not a refusal. It was my half of it.",
	"early": "I took it the first time it was offered. She gave it gladly and\nsomething small did not happen that was supposed to.",
	"late": "I said no twice and she stopped asking. I have refused a woman's\nhouse in her own shop and she was too polite to say so."},
"tokyo": {"refusals": 1,
	"right": "Declined once, quietly, and then accepted. The whole thing took\nfour seconds and both of us did it correctly.",
	"early": "Taken immediately. Nobody minded. Nobody would ever say they\nminded, which is not the same as nobody minding.",
	"late": "Enryo twice is not modesty any more. It is making somebody ask\nthree times for the pleasure of being asked."},
"rome": {"refusals": 1,
	"right": "One no, one insistence, one yes. It is a rhythm and I found it.",
	"early": "He looked briefly disappointed. He had a whole argument ready.",
	"late": "Two refusals and it stopped being offered. That was mine to lose."},
"moscow": {"refusals": 1,
	"right": "Refused once for form, accepted when he insisted, and he was\nsatisfied in a way he did not comment on.",
	"early": "Fine. He would rather I ate.",
	"late": "Refusing a second time was refusing him, and he took it that way\nbecause that is what it was."},
"mumbai": {"refusals": 1,
	"right": "No, no - and then the plate arrives regardless, and that is the\ncorrect ending for everybody.",
	"early": "Nobody objected. The no is expected but it is not enforced.",
	"late": "Three refusals is somebody who does not want to be there."},
"mexico": {"refusals": 1,
	"right": "One polite no, then yes, and the second cup was never in doubt.",
	"early": "Accepted straight off, which is fine, and slightly bare.",
	"late": "The offer got quieter and then stopped."},
"seoul": {"refusals": 1,
	"right": "Declined once with both hands, then took it with both hands.\nThe hands are half of it.",
	"early": "Taken at once, from somebody older, with one hand. Three things\nand I got two of them wrong.",
	"late": "Making an elder offer three times is not modesty."},
"tbilisi": {"refusals": 0,
	"right": "You do not refuse at this table. I have understood that much.",
	"early": "",
	"late": "A refused glass at a Georgian table is a refused toast, and a\nrefused toast is a refused sentiment, and the sentiment was about\nhis mother."},
"dakar": {"refusals": 0,
	"right": "Taken with the right hand, after the greeting, which is the part\nthat mattered.",
	"early": "",
	"late": "Declining food in a house is not a small thing to do and there is\nno version of it that reads as politeness."},
"berlin": {"refusals": 0,
	"right": "Asked, answered, done. Nobody performed anything.",
	"early": "",
	"late": "A refusal here is information. She wrote it down and moved on,\nand I did not get asked again, because why would I be."},
"zurich": {"refusals": 0,
	"right": "Yes or no, and either is completely acceptable, and that is the\nwhole of it.",
	"early": "",
	"late": "Taken at his word. He always is."},
"london": {"refusals": 1,
	"right": "\"Go on then.\" Two words, after one \"no, honestly, I'm fine\",\nand apparently that is the entire ceremony.",
	"early": "Said yes first time. A tiny flicker, gone immediately, and then\nthe kettle.",
	"late": "\"Are you sure?\" \"I'm sure.\" \"You sure?\" There is a third\nrefusal available and taking it ends something."},
"paris": {"refusals": 1,
	"right": "Declined, was pressed, accepted. It is a small formal shape and\nit is done for its own sake.",
	"early": "Accepted at once. Not wrong. Not quite the form either.",
	"late": "The second refusal was believed."},
"saopaulo": {"refusals": 0,
	"right": "Taken. Immediately. Somebody would have been hurt by anything\nelse.",
	"early": "",
	"late": "Refusing here is a thing you do to a stranger, and I am trying\nnot to be one."},
"hanoi": {"refusals": 1,
	"right": "One decline for the older person's benefit, then both hands.",
	"early": "Taken straight away. Nobody was insulted and nobody was pleased.",
	"late": "Twice is too many when somebody has already poured it."},
"lapaz": {"refusals": 0,
	"right": "Accepted, and something is owed now, which is the point of it.",
	"early": "",
	"late": "What was being offered was not the drink."},
"newyork": {"refusals": 0,
	"right": "Yes. Next. The whole exchange took four seconds and nobody felt\nanything about it.",
	"early": "",
	"late": "Refused twice and got taken at his word both times, because why\nwould anybody ask a third time."},
"toronto": {"refusals": 1,
	"right": "One \"oh, no, I couldn't\", one insistence, one yes, and two\napologies neither of us needed.",
	"early": "Accepted at once, and then apologised for accepting at once.",
	"late": "Everybody keeps being nice about it and the offer quietly dies."},
"sydney": {"refusals": 0,
	"right": "Yes, thanks. Done. Making more of it than that is the mistake.",
	"early": "",
	"late": "Two refusals turns a simple thing into an occasion, which is the\nonly real rudeness available here."},
"honolulu": {"refusals": 0,
	"right": "Taken, and eaten there, in front of them, which is the part that\nwas actually being asked.",
	"early": "",
	"late": "Food offered is not a formality to be negotiated."},
}


# ── Reading the tables ───────────────────────────────────────────────────────

static func patience(city: String) -> float:
	var row: Dictionary = PATIENCE.get(city, {})
	return float(row.get("seconds", 10.0))


static func silence_rep(city: String) -> int:
	var row: Dictionary = PATIENCE.get(city, {})
	return int(row.get("rep", 0))


static func silence_reads(city: String) -> String:
	var row: Dictionary = PATIENCE.get(city, {})
	return String(row.get("reads", ""))


static func silence_note(city: String) -> String:
	var row: Dictionary = PATIENCE.get(city, {})
	return String(row.get("note", ""))


static func refusals_wanted(city: String) -> int:
	var row: Dictionary = HOSPITALITY.get(city, {})
	return int(row.get("refusals", 0))


# What an accepted offer was worth, given how many times he said no first, and
# what he makes of it afterwards. Returns [rep, prose].
#
# Getting it right is worth more than the option's own rep, because it is the
# harder thing and nothing else in this game rewards it. Getting it wrong is
# never worse than graceless: refusing hospitality twice where one no was
# wanted is a real mistake and it is still a small one.
static func accepted(city: String, refusals: int) -> Array:
	var row: Dictionary = HOSPITALITY.get(city, {})
	if row.is_empty():
		return [0, ""]
	var want: int = int(row.get("refusals", 0))
	if refusals == want:
		return [3, String(row.get("right", ""))]
	if refusals < want:
		return [-1, String(row.get("early", ""))]
	return [-2, String(row.get("late", ""))]
