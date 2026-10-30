extends Object

# What the eight actually say.
#
# Three rounds each, then the day they invite you to. Every line is written
# for one specific person of one specific age in one specific trade, because
# the whole argument of this game is that there is no generic speaker - a
# seventeen-year-old in London and a seventy-four-year-old in Tokyo do not
# share a register, and writing them as if they did is the failure the game
# is about.
#
# Words are Latin script throughout. He is learning to SAY these, not to read
# them, and a word he cannot sound out teaches nothing.
#
# The three responses under each line are the three ways a visitor gets it
# right or wrong, and the rep numbers are the argument: matching how a person
# actually talks earns standing, and importing the last city's rules costs it.

# What they call you, round by round. Nobody is your friend on day one.
const STANDING := {
	"berlin":   ["a customer", "the one who keeps coming in", "practically a regular"],
	"london":   ["some guy", "the one from up the road", "safe"],
	"paris":    ["monsieur", "the neighbour", "a friend of the building"],
	"moscow":   ["a job", "the one with the coat", "svoy - one of ours"],
	"istanbul": ["a customer", "abi", "abi, and he means it"],
	"mumbai":   ["a customer", "boss", "bhai"],
	"tokyo":    ["a customer", "the one who comes back", "anta - you, familiarly"],
	"mexico":   ["senor", "the one from the corner", "casi de la familia"],
	# Zurich's third rung is a behaviour rather than a name, because in this
	# city that is what being let in IS: he stops changing language for you.
	"zurich":   ["a customer", "the one who keeps trying it",
		"somebody he does not slow down for"],
	# Sao Paulo's is a distance, for the same reason.
	"saopaulo": ["a customer", "the one who backs away",
		"somebody she does not have to reach for"],
}


static func standing(city: String, i: int) -> String:
	var rows: Array = STANDING.get(city, [])
	if rows.is_empty():
		return "a stranger"
	return String(rows[clampi(i, 0, rows.size() - 1)])


static func rounds_for(city: String) -> Array:
	return ROUNDS.get(city, [])


static func holiday_reel(city: String) -> Array:
	return REELS.get(city, [])


const ROUNDS := {

# ── Sao Paulo · Neusa, 61 ─────────────────────────────────────────────────
# The salao on the corner in Bixiga, door propped open onto the street.
# Thirty-one years with her hands on people.
#
# Brazil is a documented contact culture: people stand closer in every social
# situation and touch far more while talking, and the distance a northern
# European keeps does not read as courtesy, it reads as cold. So this city's
# sentence is not made of words at all - it is made of how far away you are
# standing, and the alien has spent nine cities being taught to keep back.
#
# The full mechanic in [[Cities]] is proximity as grammar, a dialogue system
# with no dialogue box. That is an engine build. What is here is the same
# lesson through the system the game already has: every round is about the
# body rather than the vocabulary, and the costly answer is always the polite
# distance that worked everywhere else.
#
# Her trade is the reason she is a hairdresser and not another stallholder:
# a salao is the one ordinary job where touching a stranger IS the work, it
# is where half of Sao Paulo does its talking, and nobody else in this cast
# does anything like it. Rocio already sells things out of a market apron in
# Mexico City, and two women on two stalls in two Latin American cities is
# how twenty cities quietly become one.
#
# It is NOT Istanbul either. Being handled by Neusa is not a debt and she is
# not being hospitable - it means nothing whatever to her, and that is
# exactly why the alien flinching at it is so loud.
"saopaulo": [
	# One. She has taken hold of his chin to turn his face to the light
	# before either of them has said anything, because that is the job and
	# she has done it to forty thousand people. It is the single most
	# ordinary gesture in the scene and the most alarming thing that has
	# happened to him since he landed.
	[{
		"words": [
			{"text": "Senta",    "word": "senta",   "language": "portuguese"},
			{"text": "aqui.",    "word": "aqui",    "language": "portuguese"},
			{"text": "Deixa",    "word": "deixa",   "language": "portuguese"},
			{"text": "eu",       "word": "eu",      "language": "portuguese"},
			{"text": "ver.",     "word": "ver",     "language": "portuguese"},
			{"text": "Relaxa.",  "word": "relaxa",  "language": "portuguese"},
		],
		"responses": [
			{"gesture": "Sit. Let her turn your head where she wants it",
				"words": "Sit. Go still.",
				"say": "All right. All right.",
				"style": "casual", "rep": 3},
			{"gesture": "Sit, but pull your head back out of her hand first",
				"words": "Sit. Pull back.",
				"say": "Sorry - sorry, you startled me.",
				"style": "indirect", "rep": 0},
			{"gesture": "Stay standing, out of reach, and ask what it costs",
				"words": "Quanto? Primeiro.",
				"say": "How much is it? Before we start.",
				"style": "formal", "rep": -2},
		],
	}],
	# Two. They have travelled the length of the shopfront, because she has
	# been stepping forward every time he stepped back, and she has noticed.
	[{
		"words": [
			{"text": "Voce",     "word": "voce",    "language": "portuguese"},
			{"text": "ta",       "word": "ta",      "language": "portuguese"},
			{"text": "fugindo",  "word": "fugindo", "language": "portuguese"},
			{"text": "de",       "word": "de",      "language": "portuguese"},
			{"text": "mim?",     "word": "mim",     "language": "portuguese"},
			{"text": "Chega",    "word": "chega",   "language": "portuguese"},
			{"text": "mais.",    "word": "mais",    "language": "portuguese"},
		],
		"responses": [
			{"gesture": "Stop moving. Let her stand where she wants to stand",
				"words": "Stand still.",
				"say": "Sorry. I did not notice I was doing that.",
				"style": "casual", "rep": 3},
			# Honest, and she is genuinely interested - this is a thing
			# Brazilians know about other countries and find funny.
			{"gesture": "Tell her that where you are from, this is far enough",
				"words": "Longe. Assim. Normal.",
				"say": "Where I come from, this is how close people stand. This.",
				"style": "direct", "rep": 2},
			{"gesture": "Take one more step back and hold your ground",
				"words": "Step back. Stay there.",
				"say": "I am fine here. This is fine.",
				"style": "formal", "rep": -3},
		],
	}],
	# Three. Her hand goes on his arm and stays there for a sentence about
	# nothing, and the sentence ends in an invitation.
	[{
		"words": [
			{"text": "Junho,",    "word": "junina",   "language": "portuguese"},
			{"text": "fogueira,", "word": "fogueira", "language": "portuguese"},
			{"text": "milho,",    "word": "milho",    "language": "portuguese"},
			{"text": "danca.",    "word": "danca",    "language": "portuguese"},
			{"text": "Voce",      "word": "voce",     "language": "portuguese"},
			{"text": "vem.",      "word": "vem",      "language": "portuguese"},
		],
		"responses": [
			{"gesture": "Leave her hand where it is and say yes",
				"words": "Vou. Obrigado.",
				"say": "Yes. I will come.",
				"style": "casual", "rep": 3},
			{"gesture": "Put your hand on her arm back",
				"words": "Hand on her arm.",
				"say": "Yes. Of course yes.",
				"style": "casual", "rep": 3},
			# Not rude. Just the ninth city's habit, one city too late.
			{"gesture": "Move your arm, gently, and thank her for the invitation",
				"words": "Move arm. Nod. Obrigado.",
				"say": "That is very kind of you. Thank you.",
				"style": "formal", "rep": -2},
		],
	}],
],

# ── Zurich · Beat, 34 ─────────────────────────────────────────────────────
# The kiosk on the Langstrasse. Papers, tram tickets, and the right bag.
#
# Zurich's failure is diglossia, and the shape it takes in a conversation is
# this: the moment you are understood perfectly is the moment you have been
# put outside. Hochdeutsch is what this city WRITES, and what it says to
# strangers. When Beat switches into it for you he is being kind and he is
# also closing a door, and both of those are true at once and neither is
# performed. Being let in is when he stops.
#
# Which is why the reward table here is upside down from every other city:
# speaking correct German gets you served and gets you nothing, and repeating
# six syllables of dialect badly is worth more than a grammatical sentence.
"zurich": [
	# One. He says it in his own language, sees it land nowhere, and
	# switches. The line is deliberately half in each - the same sentence,
	# in the German he has a year of and the German he has none of.
	[{
		"words": [
			{"text": "Sali.",    "word": "sali",    "language": "swissgerman"},
			{"text": "Wottsch",  "word": "wottsch", "language": "swissgerman"},
			{"text": "öppis?",   "word": "oeppis",  "language": "swissgerman"},
			{"text": "Entschuldigung.", "word": "entschuldigung", "language": "german"},
			{"text": "Möchten",  "word": "möchten", "language": "german"},
			{"text": "Sie",      "word": "sie",     "language": "german"},
			{"text": "etwas",    "word": "etwas",   "language": "german"},
			{"text": "kaufen?",  "word": "kaufen",  "language": "german"},
		],
		"responses": [
			{"gesture": "Say the three syllables back at him. Badly",
				"words": "Wottsch... öppis?",
				"say": "Wottsch - öppis. Was that it? Was that anything?",
				"style": "casual", "rep": 2},
			{"gesture": "Point at the shelf and hold out a note",
				"words": "Point. Note.",
				"say": "That one. I cannot ask for it. I can pay for it.",
				"style": "gesture", "rep": 1},
			{"gesture": "Answer in the German you spent a year earning",
				"words": "Ja, bitte. Eine Fahrkarte.",
				"say": "Yes, please. One ticket.",
				"style": "formal", "rep": 0},
		],
	}],
	# Two. The sign in the window. He can read every word of it and it is
	# the first time in this city that reading has been no use at all.
	[{
		"words": [
			{"text": "Das",        "word": "das",        "language": "swissgerman"},
			{"text": "isch",       "word": "isch",       "language": "swissgerman"},
			{"text": "Hochdütsch.", "word": "hochdutsch", "language": "swissgerman"},
			{"text": "So",         "word": "so",         "language": "swissgerman"},
			{"text": "schriibt",   "word": "schriibt",   "language": "swissgerman"},
			{"text": "me,",        "word": "me",         "language": "swissgerman"},
			{"text": "so",         "word": "so",         "language": "swissgerman"},
			{"text": "redt",       "word": "redt",       "language": "swissgerman"},
			{"text": "me",         "word": "me",         "language": "swissgerman"},
			{"text": "nöd.",       "word": "noed",       "language": "swissgerman"},
		],
		"responses": [
			{"gesture": "Ask him to write down the way he SAID it",
				"words": "Schriibs. So. Wie du redsch.",
				"say": "Write that down. Not the spelling. The way it came out.",
				"style": "direct", "rep": 2},
			{"gesture": "Tell him you read the sign, and that it did not help",
				"words": "Ich kann lesen. Ich kann nicht verstehen.",
				"say": "I read it. Every word. It did not help me once.",
				"style": "direct", "rep": 1},
			{"gesture": "Read the sign back to him aloud, correctly",
				"words": "Read it out. Every word right.",
				"say": "There. I can say all of it.",
				"style": "formal", "rep": -1},
		],
	}],
	# Three. He does not switch, does not slow down, and does not check
	# whether it landed - and the sentence he does it in is an invitation.
	# The trap is the polite request, which every city before this one has
	# rewarded: asking for the written language out loud asks him to put you
	# back outside, and he will, immediately, and kindly, and for good.
	[{
		"words": [
			{"text": "Sächsilüüte.", "word": "saechsilueute", "language": "swissgerman"},
			{"text": "Ross,",        "word": "ross",   "language": "swissgerman"},
			{"text": "Zünft,",       "word": "zunft",  "language": "swissgerman"},
			{"text": "Füür,",        "word": "fuur",   "language": "swissgerman"},
			{"text": "alli.",        "word": "alli",   "language": "swissgerman"},
			{"text": "Chumm",        "word": "chumm",  "language": "swissgerman"},
			{"text": "au,",          "word": "au",     "language": "swissgerman"},
			{"text": "gell?",        "word": "gell",   "language": "swissgerman"},
		],
		"responses": [
			{"gesture": "Catch a third of it. Answer the third you caught",
				"words": "Ross. Alli Ross.",
				"say": "Horses. All of them horses. That is a third of it and the third was horses.",
				"style": "casual", "rep": 3},
			{"gesture": "Nod. Say nothing. Work it out later",
				"words": "Nod.",
				"say": "Yes. Absolutely. Whatever that was.",
				"style": "gesture", "rep": -1},
			{"gesture": "Ask him, politely, to say it in the other German",
				"words": "Bitte - Hochdeutsch? Langsam?",
				"say": "Sorry - could you say that in the written one? Slowly?",
				"style": "formal", "rep": -2},
		],
	}],
],

# ── Berlin · Kerstin, 57 ──────────────────────────────────────────────────
# Berliner Schnauze: blunt, dry, and never once unkind, which takes the
# player a long time to work out are compatible. -er swallows into -a.
"berlin": [
	[{
		"words": [
			{"text": "Na?",      "word": "na",      "language": "german"},
			{"text": "Kannste",  "word": "kannste", "language": "german"},
			{"text": "dit",      "word": "dit",     "language": "german"},
			{"text": "lesen?",   "word": "lesen",   "language": "german"},
			{"text": "Nee.",     "word": "nee",     "language": "german"},
		],
		"responses": [
			{"gesture": "Shake your head. Openly", "words": "Nee.",
				"say": "No. Not a word of it.",
				"style": "direct", "rep": 2},
			{"gesture": "Nod as though you had", "words": "Ja, ja.",
				"say": "Yes, of course, all of it.",
				"style": "casual", "rep": -2},
			{"gesture": "Point at the price and hold out coins",
				"words": "Point. Coins.",
				"say": "I cannot read it. I can pay for it.",
				"style": "indirect", "rep": 1},
		],
	}],
	[{
		"words": [
			{"text": "Icke",     "word": "icke",    "language": "german"},
			{"text": "steh",     "word": "steh",    "language": "german"},
			{"text": "hier",     "word": "hier",    "language": "german"},
			{"text": "seit",     "word": "seit",    "language": "german"},
			{"text": "achtundneunzig,", "word": "achtundneunzig", "language": "german"},
			{"text": "wa.",      "word": "wa",      "language": "german"},
		],
		"responses": [
			{"gesture": "Ask what was here before", "words": "Und vorher?",
				"say": "And before that? What stood here?",
				"style": "direct", "rep": 3},
			{"gesture": "Say that is a long time", "words": "Lange.",
				"say": "That is a very long time to stand in one place.",
				"style": "casual", "rep": 1},
			{"gesture": "Say nothing and wait", "words": "Wait.",
				"say": "...",
				"style": "indirect", "rep": 2},
		],
	}],
	[{
		"words": [
			{"text": "Du",       "word": "du",      "language": "german"},
			{"text": "bist",     "word": "bist",    "language": "german"},
			{"text": "imma",     "word": "imma",    "language": "german"},
			{"text": "hier.",    "word": "hier",    "language": "german"},
			{"text": "Samstag.", "word": "samstag", "language": "german"},
			{"text": "Wiesn.",   "word": "wiesn",   "language": "german"},
		],
		"responses": [
			{"gesture": "Say yes before you know what it is", "words": "Ja.",
				"say": "Yes. Whatever it is, yes.",
				"style": "casual", "rep": 3},
			{"gesture": "Ask what a Wiesn is", "words": "Wiesn?",
				"say": "What is a Wiesn?",
				"style": "direct", "rep": 2},
			{"gesture": "Say you would not want to intrude",
				"words": "Shake head. Step back.",
				"say": "I would not want to be in the way.",
				"style": "formal", "rep": -1},
		],
	}],
],

# ── London · Nadia, 17 ────────────────────────────────────────────────────
# Multicultural London English, unmistakably 2020s-teenage. "You alright?"
# is hello. It has never once been a question and he has been answering it.
"london": [
	[{
		"words": [
			{"text": "You",     "word": "you",     "language": "english"},
			{"text": "alright?", "word": "alright", "language": "english"},
			{"text": "Yeah?",   "word": "yeah",    "language": "english"},
			{"text": "Safe.",   "word": "safe",    "language": "english"},
		],
		"responses": [
			{"gesture": "Say it straight back at her", "words": "You alright?",
				"say": "You alright?", "style": "casual", "rep": 3},
			{"gesture": "Answer the question honestly",
				"words": "Not really.",
				"say": "No. I am not, particularly.", "style": "direct", "rep": -1},
			{"gesture": "Nod and keep walking", "words": "Nod.",
				"say": "*a nod*", "style": "indirect", "rep": 1},
		],
	}],
	[{
		"words": [
			{"text": "You",     "word": "you",     "language": "english"},
			{"text": "chat",    "word": "chat",    "language": "english"},
			{"text": "bare",    "word": "bare",    "language": "english"},
			{"text": "weird,",  "word": "weird",   "language": "english"},
			{"text": "innit.",  "word": "innit",   "language": "english"},
		],
		"responses": [
			{"gesture": "Agree, and mean it", "words": "Yeah. I do.",
				"say": "I do. I have no idea how anyone speaks here.",
				"style": "direct", "rep": 3},
			{"gesture": "Ask what bare means", "words": "Bare?",
				"say": "Bare. What is bare?", "style": "casual", "rep": 2},
			{"gesture": "Apologise for it", "words": "Sorry.",
				"say": "I am sorry. I will try to speak properly.",
				"style": "formal", "rep": -2},
		],
	}],
	[{
		"words": [
			{"text": "Fifth",   "word": "fifth",   "language": "english"},
			{"text": "of",      "word": "of",      "language": "english"},
			{"text": "November.", "word": "november", "language": "english"},
			{"text": "Come",    "word": "come",    "language": "english"},
			{"text": "road.",   "word": "road",    "language": "english"},
		],
		"responses": [
			{"gesture": "Say you will be there", "words": "Yeah. Course.",
				"say": "Yes. I will be there.", "style": "casual", "rep": 3},
			{"gesture": "Ask what happens on the fifth", "words": "What happens?",
				"say": "What happens on the fifth of November?",
				"style": "direct", "rep": 2},
			{"gesture": "Ask whether you are allowed", "words": "Am I allowed?",
				"say": "Am I permitted to attend?", "style": "formal", "rep": -1},
		],
	}],
],

# ── Paris · Odile, 71 ─────────────────────────────────────────────────────
# Bonjour first. Always. She will wait for it, and the waiting is the lesson:
# the offence was never his accent, it was starting to speak without it.
"paris": [
	[{
		"words": [
			{"text": "Bonjour.", "word": "bonjour", "language": "french"},
			{"text": "Bonjour,", "word": "bonjour", "language": "french"},
			{"text": "monsieur.", "word": "monsieur", "language": "french"},
			{"text": "Hein?",    "word": "hein",    "language": "french"},
		],
		"responses": [
			{"gesture": "Say bonjour before anything else", "words": "Bonjour.",
				"say": "Bonjour, madame.", "style": "formal", "rep": 3},
			{"gesture": "Ask your question straight away",
				"words": "Point at the door.",
				"say": "Which way is the station?", "style": "direct", "rep": -3},
			{"gesture": "Smile and wave", "words": "Wave.",
				"say": "*a wave*", "style": "casual", "rep": -1},
		],
	}],
	[{
		"words": [
			{"text": "Voila.",   "word": "voila",   "language": "french"},
			{"text": "Ce",       "word": "ce",      "language": "french"},
			{"text": "n est",    "word": "nest",    "language": "french"},
			{"text": "pas",      "word": "pas",     "language": "french"},
			{"text": "l accent.", "word": "accent", "language": "french"},
		],
		"responses": [
			{"gesture": "Ask what it is, then", "words": "Alors quoi?",
				"say": "Then what is it? What have I been doing?",
				"style": "direct", "rep": 3},
			{"gesture": "Say you have been rude without knowing",
				"words": "Pardon.",
				"say": "I have been rude for a year and nobody said.",
				"style": "formal", "rep": 2},
			{"gesture": "Say the French are difficult", "words": "Shrug.",
				"say": "This city is difficult.", "style": "casual", "rep": -3},
		],
	}],
	[{
		"words": [
			{"text": "Le",       "word": "le",      "language": "french"},
			{"text": "treize,",  "word": "treize",  "language": "french"},
			{"text": "chez",     "word": "chez",    "language": "french"},
			{"text": "les",      "word": "les",     "language": "french"},
			{"text": "pompiers.", "word": "pompiers", "language": "french"},
		],
		"responses": [
			{"gesture": "Accept, properly", "words": "Avec plaisir.",
				"say": "With pleasure, madame. Thank you.",
				"style": "formal", "rep": 3},
			{"gesture": "Ask what firemen have to do with it",
				"words": "Les pompiers?",
				"say": "The fire brigade? Why the fire brigade?",
				"style": "direct", "rep": 2},
			{"gesture": "Ask if it costs anything", "words": "C est payant?",
				"say": "Is there a charge?", "style": "direct", "rep": 0},
		],
	}],
],

# ── Moscow · Viktor, 46 ───────────────────────────────────────────────────
# No small talk, no filler, no smile for a stranger. The tell is diminutives:
# the day the name comes back with -ik on the end, it happened.
"moscow": [
	[{
		"words": [
			{"text": "Nu?",      "word": "nu",       "language": "russian"},
			{"text": "Davay.",   "word": "davay",    "language": "russian"},
			{"text": "Normalno.", "word": "normalno", "language": "russian"},
		],
		"responses": [
			{"gesture": "Put the broken thing on the counter. Say nothing",
				"words": "Put it down.",
				"say": "*sets it down*", "style": "direct", "rep": 3},
			{"gesture": "Smile broadly and greet him", "words": "Smile.",
				"say": "Good morning! Beautiful day!", "style": "casual", "rep": -2},
			{"gesture": "Apologise for troubling him", "words": "Izvinite.",
				"say": "I am sorry to trouble you.", "style": "formal", "rep": 0},
		],
	}],
	[{
		"words": [
			{"text": "Ty",       "word": "ty",       "language": "russian"},
			{"text": "opyat",    "word": "opyat",    "language": "russian"},
			{"text": "zdes.",    "word": "zdes",     "language": "russian"},
			{"text": "Ladno.",   "word": "ladno",    "language": "russian"},
		],
		"responses": [
			{"gesture": "Agree. You are, again", "words": "Da. Opyat.",
				"say": "Yes. Again.", "style": "direct", "rep": 3},
			{"gesture": "Explain why you keep coming back",
				"words": "Long explanation.",
				"say": "I come because nobody else here talks to me at all, and-",
				"style": "casual", "rep": -1},
			{"gesture": "Wait until he is finished with the work",
				"words": "Wait.",
				"say": "*waits*", "style": "indirect", "rep": 2},
		],
	}],
	[{
		"words": [
			{"text": "Maslenitsa.", "word": "maslenitsa", "language": "russian"},
			{"text": "Bliny.",   "word": "bliny",    "language": "russian"},
			{"text": "Prihodi.", "word": "prihodi",  "language": "russian"},
		],
		"responses": [
			{"gesture": "Say yes", "words": "Pridu.",
				"say": "I will come.", "style": "direct", "rep": 3},
			{"gesture": "Ask what Maslenitsa is", "words": "Chto eto?",
				"say": "What is Maslenitsa?", "style": "direct", "rep": 2},
			{"gesture": "Say he does not have to", "words": "Ne nado.",
				"say": "You do not have to invite me.", "style": "formal", "rep": -2},
		],
	}],
],

# ── Istanbul · Arda, 18 ───────────────────────────────────────────────────
# "Abi" in nearly every sentence. He will not take money after the third
# glass, and being allowed to pay is a demotion rather than a kindness.
"istanbul": [
	[{
		"words": [
			{"text": "Buyur",   "word": "buyur",   "language": "turkish"},
			{"text": "abi.",    "word": "abi",     "language": "turkish"},
			{"text": "Cay?",    "word": "cay",     "language": "turkish"},
			{"text": "Otur.",   "word": "otur",    "language": "turkish"},
		],
		"responses": [
			{"gesture": "Sit down and take the glass", "words": "Sit.",
				"say": "*sits, takes it*", "style": "casual", "rep": 3},
			{"gesture": "Take it and reach for money", "words": "Kac lira?",
				"say": "How much do I owe you?", "style": "direct", "rep": -1},
			{"gesture": "Refuse politely", "words": "Yok, tesekkurler.",
				"say": "No, thank you. I do not want to put you out.",
				"style": "formal", "rep": -3},
		],
	}],
	[{
		"words": [
			{"text": "Valla",   "word": "valla",   "language": "turkish"},
			{"text": "abi,",    "word": "abi",     "language": "turkish"},
			{"text": "para",    "word": "para",    "language": "turkish"},
			{"text": "yok.",    "word": "yok",     "language": "turkish"},
			{"text": "Aynen.",  "word": "aynen",   "language": "turkish"},
		],
		"responses": [
			{"gesture": "Stop trying to pay. Say thank you", "words": "Eyvallah.",
				"say": "Eyvallah.", "style": "casual", "rep": 3},
			{"gesture": "Leave the money on the tray anyway",
				"words": "Put it down.",
				"say": "*leaves it on the tray*", "style": "direct", "rep": -3},
			{"gesture": "Ask how you are supposed to repay him",
				"words": "Nasil oder?",
				"say": "Then how am I supposed to pay you back?",
				"style": "direct", "rep": 2},
		],
	}],
	[{
		"words": [
			{"text": "Bayram",  "word": "bayram",  "language": "turkish"},
			{"text": "geliyor.", "word": "geliyor", "language": "turkish"},
			{"text": "Bize",    "word": "bize",    "language": "turkish"},
			{"text": "gel",     "word": "gel",     "language": "turkish"},
			{"text": "kanka.",  "word": "kanka",   "language": "turkish"},
		],
		"responses": [
			{"gesture": "Notice what he just called you", "words": "Kanka?",
				"say": "Kanka. You have never called me that before.",
				"style": "casual", "rep": 3},
			{"gesture": "Accept", "words": "Gelirim.",
				"say": "I will come.", "style": "casual", "rep": 3},
			{"gesture": "Ask what you should bring", "words": "Ne getireyim?",
				"say": "What should I bring?", "style": "direct", "rep": 2},
		],
	}],
],

# ── Mumbai · Omkar, 22 ────────────────────────────────────────────────────
# Bambaiya: Hindi, Marathi, English and Gujarati inside one sentence,
# switching by WHO he is talking to rather than by topic.
"mumbai": [
	[{
		"words": [
			{"text": "Arre",    "word": "arre",    "language": "hindi"},
			{"text": "boss,",   "word": "boss",    "language": "hindi"},
			{"text": "kya",     "word": "kya",     "language": "hindi"},
			{"text": "scene",   "word": "scene",   "language": "hindi"},
			{"text": "hai?",    "word": "hai",     "language": "hindi"},
		],
		"responses": [
			{"gesture": "Answer in the same mix he used", "words": "Scene theek hai.",
				"say": "Scene theek hai, boss.", "style": "casual", "rep": 3},
			{"gesture": "Answer in careful, correct Hindi",
				"words": "Formal Hindi.",
				"say": "I am quite well, thank you for asking.",
				"style": "formal", "rep": -1},
			{"gesture": "Hold out the broken phone", "words": "Show him.",
				"say": "*holds it out*", "style": "direct", "rep": 2},
		],
	}],
	[{
		"words": [
			{"text": "Chalta",  "word": "chalta",  "language": "hindi"},
			{"text": "hai",     "word": "hai",     "language": "hindi"},
			{"text": "yaar.",   "word": "yaar",    "language": "hindi"},
			{"text": "Ekdum",   "word": "ekdum",   "language": "hindi"},
			{"text": "bindaas.", "word": "bindaas", "language": "hindi"},
		],
		"responses": [
			{"gesture": "Ask which language that sentence was",
				"words": "Kaunsi bhasha?",
				"say": "Which language was that? I counted three.",
				"style": "direct", "rep": 3},
			{"gesture": "Repeat it back badly", "words": "Ekdum bindaas.",
				"say": "Ekdum bindaas.", "style": "casual", "rep": 2},
			{"gesture": "Pick one language and stick to it",
				"words": "Only Hindi.",
				"say": "I will use Hindi. Only Hindi.", "style": "formal", "rep": -1},
		],
	}],
	[{
		"words": [
			{"text": "Bappa",   "word": "bappa",   "language": "hindi"},
			{"text": "aa",      "word": "aa",      "language": "hindi"},
			{"text": "rahe",    "word": "rahe",    "language": "hindi"},
			{"text": "hain.",   "word": "hain",    "language": "hindi"},
			{"text": "Aana,",   "word": "aana",    "language": "hindi"},
			{"text": "bhai.",   "word": "bhai",    "language": "hindi"},
		],
		"responses": [
			{"gesture": "Say you will come", "words": "Aaunga.",
				"say": "I will come.", "style": "casual", "rep": 3},
			{"gesture": "Ask who Bappa is", "words": "Bappa kaun?",
				"say": "Who is Bappa?", "style": "direct", "rep": 2},
			{"gesture": "Ask whether it is alright for you to be there",
				"words": "Main aa sakta hoon?",
				"say": "Is it alright? I am not from here.",
				"style": "formal", "rep": 1},
		],
	}],
],

# ── Tokyo · Setsuko, 74 ───────────────────────────────────────────────────
# Shitamachi: warmer and blunter than uptown, and still will not say no.
# "Chotto..." with the sentence unfinished is a door closing.
"tokyo": [
	[{
		"words": [
			{"text": "Ara.",    "word": "ara",     "language": "japanese"},
			{"text": "Anta,",   "word": "anta",    "language": "japanese"},
			{"text": "kore",    "word": "kore",    "language": "japanese"},
			{"text": "hoshii",  "word": "hoshii",  "language": "japanese"},
			{"text": "no?",     "word": "no",      "language": "japanese"},
		],
		"responses": [
			{"gesture": "Say yes, and point", "words": "Hai. Kore.",
				"say": "Yes. This one.", "style": "direct", "rep": 2},
			{"gesture": "Ask what it is for", "words": "Nan desu ka?",
				"say": "What is it for?", "style": "direct", "rep": 3},
			{"gesture": "Pick it up without asking", "words": "Take it.",
				"say": "*picks it up*", "style": "casual", "rep": -2},
		],
	}],
	[{
		"words": [
			{"text": "Sore",    "word": "sore",    "language": "japanese"},
			{"text": "wa",      "word": "wa",      "language": "japanese"},
			{"text": "chotto",  "word": "chotto",  "language": "japanese"},
			{"text": "ne...",   "word": "ne",      "language": "japanese"},
		],
		"responses": [
			{"gesture": "Understand that this is a no", "words": "Wakarimashita.",
				"say": "I understand. Thank you anyway.",
				"style": "formal", "rep": 3},
			{"gesture": "Ask again, more clearly", "words": "Onegaishimasu.",
				"say": "Please? Perhaps if I explain it better-",
				"style": "direct", "rep": -3},
			{"gesture": "Wait for the rest of the sentence", "words": "Wait.",
				"say": "*waits for the end of it*", "style": "indirect", "rep": 1},
		],
	}],
	[{
		"words": [
			{"text": "Tanabata",  "word": "tanabata", "language": "japanese"},
			{"text": "da",       "word": "da",      "language": "japanese"},
			{"text": "yo.",      "word": "yo",      "language": "japanese"},
			{"text": "Issho",    "word": "issho",   "language": "japanese"},
			{"text": "ni.",      "word": "ni",      "language": "japanese"},
		],
		"responses": [
			{"gesture": "Accept", "words": "Hai. Issho ni.",
				"say": "Yes. Together.", "style": "casual", "rep": 3},
			{"gesture": "Check that this is a real yes", "words": "Hontou ni?",
				"say": "Really? You are not being kind about a no?",
				"style": "direct", "rep": 2},
			{"gesture": "Say chotto back to her", "words": "Chotto...",
				"say": "Chotto...", "style": "indirect", "rep": 1},
		],
	}],
],

# ── Mexico City · Rocio, 45 ───────────────────────────────────────────────
# Chilanga: diminutives on everything, extremely courteous, and refusals
# that are long and indirect. Ahorita does not mean now.
"mexico": [
	[{
		"words": [
			{"text": "Mande?",  "word": "mande",   "language": "spanish_mx"},
			{"text": "Ay,",     "word": "ay",      "language": "spanish_mx"},
			{"text": "joven.",  "word": "joven",   "language": "spanish_mx"},
			{"text": "Que",     "word": "que",     "language": "spanish_mx"},
			{"text": "le",      "word": "le",      "language": "spanish_mx"},
			{"text": "damos?",  "word": "damos",   "language": "spanish_mx"},
		],
		"responses": [
			{"gesture": "Ask for a little of something", "words": "Un poquito.",
				"say": "Un poquito, please.", "style": "casual", "rep": 3},
			{"gesture": "Ask the price first", "words": "Cuanto cuesta?",
				"say": "How much does it cost?", "style": "direct", "rep": 1},
			{"gesture": "Say qué instead of mande", "words": "Que?",
				"say": "What?", "style": "direct", "rep": -1},
		],
	}],
	[{
		"words": [
			{"text": "Ahorita",  "word": "ahorita", "language": "spanish_mx"},
			{"text": "se",      "word": "se",      "language": "spanish_mx"},
			{"text": "las",     "word": "las",     "language": "spanish_mx"},
			{"text": "traigo,", "word": "traigo",  "language": "spanish_mx"},
			{"text": "joven.",  "word": "joven",   "language": "spanish_mx"},
		],
		"responses": [
			{"gesture": "Come back tomorrow", "words": "Manana entonces.",
				"say": "Tomorrow, then.", "style": "casual", "rep": 3},
			{"gesture": "Wait where you are", "words": "Wait.",
				"say": "*waits for ahorita to arrive*",
				"style": "indirect", "rep": 1},
			{"gesture": "Ask how long ahorita is", "words": "Cuanto es ahorita?",
				"say": "How long is ahorita?", "style": "direct", "rep": 2},
		],
	}],
	[{
		"words": [
			{"text": "Van",     "word": "van",     "language": "spanish_mx"},
			{"text": "a",       "word": "a",       "language": "spanish_mx"},
			{"text": "venir",   "word": "venir",   "language": "spanish_mx"},
			{"text": "los",     "word": "los",     "language": "spanish_mx"},
			{"text": "muertos.", "word": "muertos", "language": "spanish_mx"},
		],
		"responses": [
			{"gesture": "Ask who is coming", "words": "Quienes vienen?",
				"say": "Who is coming?", "style": "direct", "rep": 3},
			{"gesture": "Say you are sorry for her loss", "words": "Lo siento.",
				"say": "I am sorry. I did not know you had lost somebody.",
				"style": "formal", "rep": -1},
			{"gesture": "Offer to carry the flowers", "words": "Le ayudo?",
				"say": "May I carry those?", "style": "casual", "rep": 3},
		],
	}],
],
}


# ── The day itself ───────────────────────────────────────────────────────────
#
# Played as a reel in the city's own plates, which is the thing this game
# already does best. They walk you through it and tell you what you are
# looking at; the alien narrates what he makes of it, and is sometimes wrong.
#
# Every detail is the real one. Nothing here is a generic festival.
const REELS := {

# ── Sao Paulo · Festa Junina, the whole of June ──────────────────────────
#
# The real one, and it is not Carnaval - which is the point of choosing it.
# Festa Junina runs all June, in churchyards and school yards and on closed
# streets: bandeirinhas strung overhead, a bonfire, quentao and corn in every
# form there is (pamonha, canjica, curau, milho na brasa), everybody in check
# shirts and painted freckles, and the quadrilha - a called square dance with
# a mock wedding in it, danced in pairs, arms through arms.
#
# Which is why it is Sao Paulo's holiday rather than Carnaval. Carnaval is a
# crowd. This is a dance where you are physically attached to one specific
# person for twenty minutes, and being pulled into it is the whole lesson of
# the city arriving through the body instead of through a sentence.
"saopaulo": [
	{"set": "courtyard", "cast": [{"at": 0.28, "act": "look"}, {"at": 0.58, "act": "point"}],
		"say": "Bunting in four colours strung across the whole yard, low enough to touch, and everybody under it in a check shirt with freckles painted on."},
	{"set": "courtyard", "prop": "smoke", "prop_at": 0.52,
		"cast": [{"at": 0.24, "act": "watch"}, {"at": 0.54, "act": "stand"}, {"at": 0.78, "act": "watch"}],
		"say": "A bonfire in the middle of a city of twelve million people, in the middle of winter, which is June here and which I had not thought about once."},
	{"set": "stall", "prop": "bowl", "prop_at": 0.34,
		"cast": [{"at": 0.30, "act": "offer"}, {"at": 0.62, "act": "eat"}],
		"say": "Corn boiled, corn grilled, corn ground into a cake and steamed in its own leaf, and a hot spiced drink that Neusa hands me without asking whether I wanted one."},
	{"set": "courtyard", "cast": [{"at": 0.22, "act": "wave"}, {"at": 0.50, "act": "stand"}, {"at": 0.76, "act": "wave"}],
		"say": "Somebody with a microphone is calling the steps and nobody is listening to him. There is a wedding in the middle of it and both of them are about nine."},
	{"set": "courtyard", "cast": [{"at": 0.26, "act": "take"}, {"at": 0.54, "act": "stand"}, {"at": 0.80, "act": "wave"}],
		"say": "I am taken by the arm and put into a line before I have agreed to anything, which is the fourth time today, and the third time I have stopped counting."},
	{"set": "courtyard", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.62, "act": "stand"}],
		"say": "Nine cities of learning to stand back, and here it turns out the distance I was keeping was a sentence. I had been saying it to everybody, all year, without once opening my mouth."},
],

# ── Zurich · Sechselauten, the third Monday in April ─────────────────────
#
# The real one. The Zug der Zunfte comes through the middle of the city -
# roughly three thousand guildsmen in historical dress and several hundred
# horses - and ends at Sechselautenplatz, where a cotton-wool snowman with
# his head packed with fireworks stands on a pyre by the lake. At six the
# Grossmunster bells go, which is what the word means: the six o'clock
# ringing, from the medieval rule that the working day ended at six once
# spring came. They light him, riders gallop round the fire, and the country
# times how long his head takes to explode as though it forecast the summer.
# It does not forecast the summer. Everybody times it.
#
# The lesson is NOT that the festival is not his. That is Berlin's, and doing
# it twice would make two cities into one. Zurich's is that this is the one
# day the city performs itself out loud, and it does the whole thing in the
# language that is never written down - so the German he spent an act earning
# is worth nothing all day, and for the first time nobody slows down for him.
"zurich": [
	{"set": "street", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.58, "act": "point"}],
		"say": "Three thousand men in six hundred years of coats, on horses, coming down a street I have walked twenty times to buy bread. Beat points them out by their collars."},
	{"set": "street", "prop": "flag", "prop_at": 0.62,
		"cast": [{"at": 0.26, "act": "look"}, {"at": 0.54, "act": "stand"}],
		"say": "Every banner is a trade that stopped existing four hundred years ago. Boatmen. Saddlers. They still meet, and they still have the flag."},
	{"set": "courtyard", "cast": [{"at": 0.30, "act": "look"}, {"at": 0.60, "act": "point"}],
		"say": "A snowman the height of a house, on a pile of firewood, in the square by the lake. His head is packed with explosives. Beat says the word twice so I get it. Boogg."},
	{"set": "courtyard", "prop": "smoke", "prop_at": 0.50,
		"cast": [{"at": 0.24, "act": "watch"}, {"at": 0.52, "act": "watch"}, {"at": 0.76, "act": "watch"}],
		"say": "At six exactly the bells go, which is the whole name: the six o'clock ringing, from when the working day was first allowed to end at six because the light had come back. Then they light him."},
	{"set": "courtyard", "prop": "smoke", "prop_at": 0.44,
		"cast": [{"at": 0.22, "act": "count"}, {"at": 0.50, "act": "watch"}, {"at": 0.78, "act": "count"}],
		"say": "Men on horses gallop round the fire while it burns and half the country has a watch out. How long his head takes to go is supposed to tell you what the summer will be. It does not. Everybody times it."},
	{"set": "street", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.62, "act": "stand"}],
		"say": "Nobody has slowed down for me once all day. Not the announcer, not the crowd, not him. I understood about a fifth of it, and it is the first time since I landed that I was not being accommodated. I was only standing in it."},
],

"berlin": [
	{"set": "street", "cast": [{"at": 0.30, "act": "stand"}, {"at": 0.60, "act": "stand"}],
		"say": "Kerstin is wearing a dirndl and is not happy about it. There is a brass band on a flatbed lorry at the end of the road."},
	{"set": "market", "prop": "glass", "prop_at": 0.66,
		"cast": [{"at": 0.26, "act": "watch"}, {"at": 0.54, "act": "offer"}, {"at": 0.72, "act": "drink"}],
		"say": "A litre of beer in a glass with a handle, which two hands are required to lift and which nobody puts down."},
	{"set": "stall", "prop": "board", "prop_at": 0.30,
		"cast": [{"at": 0.30, "act": "look"}, {"at": 0.58, "act": "point"}],
		"say": "Roast almonds, a hoopla stall, a small ferris wheel, and eleven thousand people in leather trousers."},
	{"set": "street", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.56, "act": "stand"}],
		"say": "\u201cDit is nich unsa. Dit is Bayern.\u201d This is not ours. This is Bavaria - six hundred kilometres from here, and she has been there twice."},
	{"set": "street", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.62, "act": "bow"}],
		"say": "The only German thing the world can name belongs to a part of the country she does not come from, and she is standing in it in a borrowed dress."},
	{"set": "street", "cast": [{"at": 0.34, "act": "watch"}, {"at": 0.60, "act": "stand"}],
		"say": "I have spent a year being read as a category instead of a person. I recognise the shape of this exactly."},
],

"london": [
	{"set": "street", "cast": [{"at": 0.30, "act": "stand"}, {"at": 0.58, "act": "point"}],
		"say": "It is dark at half past four. Something goes off two streets away and nobody in the road so much as turns round."},
	{"set": "park", "prop": "lantern", "prop_at": 0.70,
		"cast": [{"at": 0.24, "act": "watch"}, {"at": 0.50, "act": "watch"}, {"at": 0.74, "act": "watch"}],
		"say": "Everybody standing in a cold field with their heads back. Nadia hands me a toffee apple and does not explain it."},
	{"set": "field", "cast": [{"at": 0.30, "act": "eat"}, {"at": 0.60, "act": "watch"}],
		"say": "A jacket potato out of foil, too hot to hold, eaten with the fingers by people in good coats."},
	{"set": "park", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.56, "act": "stand"}],
		"say": "I ask who Guy Fawkes was. \u201cHe tried to blow up Parliament, I fink.\u201d Nobody within earshot can do better, and nobody minds."},
	{"set": "park", "cast": [{"at": 0.32, "act": "look"}, {"at": 0.58, "act": "watch"}],
		"say": "Four hundred years ago they burned a man in effigy for treason. Tonight it is a firework display with a hot dog van and everybody is very happy."},
	{"set": "street", "cast": [{"at": 0.34, "act": "stand"}, {"at": 0.62, "act": "wave"}],
		"say": "A holiday can come completely unstuck from the thing it is about and still be the warmest night of the year. \u201cYou alright?\u201d she says. It still is not a question."},
],

"paris": [
	{"set": "courtyard", "cast": [{"at": 0.30, "act": "stand"}, {"at": 0.58, "act": "point"}],
		"say": "The thirteenth. The doors of the fire station are open and there is a queue of people who do not appear to have been invited."},
	{"set": "courtyard", "prop": "lantern", "prop_at": 0.72,
		"cast": [{"at": 0.24, "act": "watch"}, {"at": 0.50, "act": "wave"}, {"at": 0.74, "act": "wave"}],
		"say": "“Le bal des pompiers,” says Odile. Anyone may walk in. Nobody checks anything. Everybody dances."},
	{"set": "courtyard", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.60, "act": "offer"}],
		"say": "The city that would not sell me bread until I said bonjour first has thrown a building open to the entire street, for free, and is pouring."},
	{"set": "street", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.56, "act": "stand"}],
		"say": "The next morning there are tanks on the Champs-Elysees, which she has firm opinions about and expresses at length."},
	{"set": "tower", "cast": [{"at": 0.30, "act": "look"}, {"at": 0.62, "act": "look"}],
		"say": "At eleven at night the sky over the Champ de Mars comes apart, and half a million people say the same three vowels at the same time."},
	{"set": "street", "cast": [{"at": 0.34, "act": "stand"}, {"at": 0.60, "act": "stand"}],
		"say": "The politeness was never coldness. It was a door with a handle, and I had spent a year pushing on the hinge."},
],

"moscow": [
	{"set": "market", "prop": "bowl", "prop_at": 0.68,
		"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.56, "act": "pour"}],
		"say": "Blini. Thin as paper, and round, which Viktor says is the entire point: it is the sun, and it is February."},
	{"set": "market", "cast": [{"at": 0.30, "act": "eat"}, {"at": 0.58, "act": "offer"}],
		"say": "Every day of the week has a name and a rule about whose house you eat at. He recites all seven without appearing to think about it."},
	{"set": "street", "cast": [{"at": 0.26, "act": "stand"}, {"at": 0.54, "act": "watch"}, {"at": 0.74, "act": "watch"}],
		"say": "Ribbons on everything, children on sledges, a fistfight arranged in advance and conducted with great courtesy."},
	{"set": "courtyard", "prop": "flag", "prop_at": 0.62,
		"cast": [{"at": 0.30, "act": "look"}, {"at": 0.60, "act": "stand"}],
		"say": "A straw woman four metres high goes up in the square, and everybody watches winter burn without saying anything at all."},
	{"set": "courtyard", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.58, "act": "stand"}],
		"say": "He calls me something with -ik on the end of it. It is the first diminutive in eleven months and he does not mark the occasion."},
	{"set": "street", "cast": [{"at": 0.34, "act": "watch"}, {"at": 0.60, "act": "stand"}],
		"say": "A smile here is not small change. It is spent on people who have earned it, and I have been reading a year of ordinary courtesy as a wall."},
],

"istanbul": [
	{"set": "street", "cast": [{"at": 0.30, "act": "stand"}, {"at": 0.58, "act": "point"}],
		"say": "First light, and the han is shut. Arda is in a shirt that has been ironed, which I have never seen before."},
	{"set": "steps", "cast": [{"at": 0.26, "act": "bow"}, {"at": 0.52, "act": "stand"}, {"at": 0.74, "act": "bow"}],
		"say": "The oldest person in the building first. You take their hand, kiss the back of it, and touch it to your forehead. There is an order and everybody knows it."},
	{"set": "interior", "prop": "glass", "prop_at": 0.70,
		"cast": [{"at": 0.28, "act": "take"}, {"at": 0.56, "act": "offer"}],
		"say": "Cologne poured into my hands at the door, and a tray of sweets held out before anybody has said a word. Seker Bayrami: the sugar holiday."},
	{"set": "interior", "cast": [{"at": 0.30, "act": "hand_over"}, {"at": 0.60, "act": "take"}],
		"say": "Children come round in packs and are given money, and are entirely ruthless about the route they take."},
	{"set": "street", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.58, "act": "stand"}],
		"say": "Then the graves, which nobody warned me about, and which everybody visits, and after which everybody eats again."},
	{"set": "street", "cast": [{"at": 0.34, "act": "watch"}, {"at": 0.60, "act": "stand"}],
		"say": "Being given to is not free here and was never meant to be. Every time I tried not to be a burden I was refusing to be in a relationship at all."},
],

"mumbai": [
	{"set": "market", "cast": [{"at": 0.28, "act": "look"}, {"at": 0.56, "act": "point"}, {"at": 0.76, "act": "haul"}],
		"say": "The lane has been shut for three weeks and there is a pandal in it. Twelfth Lane has raised one forty feet high and the next lane is openly furious about it."},
	{"set": "market", "prop": "bowl", "prop_at": 0.68,
		"cast": [{"at": 0.30, "act": "eat"}, {"at": 0.58, "act": "offer"}],
		"say": "Modak by the plateful, and Omkar switching language three times inside one sentence depending on who has just walked up."},
	{"set": "street", "cast": [{"at": 0.26, "act": "stand"}, {"at": 0.52, "act": "wave"}, {"at": 0.74, "act": "wave"}],
		"say": "Ten days. Drums that do not stop. Colour thrown at the height of a first-floor window."},
	{"set": "street", "cast": [{"at": 0.30, "act": "haul"}, {"at": 0.60, "act": "haul"}],
		"say": "Then they pick it up and walk it to the sea - Lalbaug, Chinchpokli, Saat Rasta, Opera House - and the whole city walks with it."},
	{"set": "water", "cast": [{"at": 0.32, "act": "look"}, {"at": 0.62, "act": "stand"}],
		"say": "At Girgaum Chowpatty they carry it into the water and let it dissolve. A year of work, given back on purpose."},
	{"set": "water", "cast": [{"at": 0.34, "act": "stand"}, {"at": 0.60, "act": "stand"}],
		"say": "“Ganpati Bappa Morya - pudhchya varshi lavkar ya.” Come back early next year. They are not saying goodbye to it. They are booking it."},
],

"tokyo": [
	{"set": "market", "cast": [{"at": 0.28, "act": "look"}, {"at": 0.56, "act": "point"}],
		"say": "Kappabashi-dori, a kilometre of it, hung end to end with paper balls trailing coloured streamers. Setsuko calls them kusudama and does not elaborate."},
	{"set": "shop", "prop": "board", "prop_at": 0.34,
		"cast": [{"at": 0.30, "act": "read"}, {"at": 0.58, "act": "offer"}],
		"say": "She gives me a strip of paper and a pen. A tanzaku. You write a wish on it and tie it where it can be read by anybody who passes."},
	{"set": "market", "cast": [{"at": 0.26, "act": "watch"}, {"at": 0.54, "act": "point"}, {"at": 0.76, "act": "stand"}],
		"say": "Bamboo set out along the pavement, already thick with them. Most are about examinations. One is about a knee."},
	{"set": "street", "cast": [{"at": 0.30, "act": "watch"}, {"at": 0.58, "act": "watch"}],
		"say": "A parade comes down the street on the fourth, and dances borrowed from four other prefectures on the fifth, performed with total seriousness."},
	{"set": "shop", "cast": [{"at": 0.32, "act": "stand"}, {"at": 0.60, "act": "stand"}],
		"say": "Orihime and Hikoboshi: two people allowed to meet once a year, across a river of stars. She tells this to somebody who cannot get home, and does not appear to notice."},
	{"set": "street", "cast": [{"at": 0.34, "act": "look"}, {"at": 0.62, "act": "stand"}],
		"say": "“Chotto” was never maybe. Everything I counted as a yes for a year was somebody being kind about a no, and I tied a wish to a pole about it."},
],

"mexico": [
	{"set": "market", "prop": "bowl", "prop_at": 0.30,
		"cast": [{"at": 0.28, "act": "carry"}, {"at": 0.56, "act": "count"}],
		"say": "Cempasuchil sold by weight, by the armful, until her hands are orange to the wrist and so are mine."},
	{"set": "steps", "cast": [{"at": 0.30, "act": "offer"}, {"at": 0.58, "act": "bow"}],
		"say": "Petals laid in a line from the street door inward, so that they can find the way. She is very particular about the corners."},
	{"set": "interior", "prop": "lantern", "prop_at": 0.68,
		"cast": [{"at": 0.26, "act": "stand"}, {"at": 0.54, "act": "point"}],
		"say": "His water, because it is a long way. His bread. His cigarettes, which killed him, and which are on the table because he liked them."},
	{"set": "courtyard", "cast": [{"at": 0.28, "act": "watch"}, {"at": 0.54, "act": "wave"}, {"at": 0.76, "act": "stand"}],
		"say": "The plaza is shut to cars, there are rides for the children, and somebody is winning a competition for the best Catrina."},
	{"set": "courtyard", "cast": [{"at": 0.30, "act": "eat"}, {"at": 0.58, "act": "offer"}],
		"say": "Sugar skulls with the names of living people on them, handed to those people, who laugh. Pan de muerto, which is just bread, and is not."},
	{"set": "steps", "cast": [{"at": 0.34, "act": "stand"}, {"at": 0.60, "act": "stand"}],
		"say": "It is a table laid for a guest. I have been keeping mine out of the way for a year, as though it were something I had spilled."},
],
}
