class_name CityNPCsWorld
extends Object

# The people of the twelve cities added after Berlin.
#
# Kept out of CityNPCs.gd because that file was already three hundred lines for
# two cities, and this is twelve. CityNPCs.roster() delegates here.
#
# Every person in this file exists to teach their city ONE thing - the way that
# city fails to be understood - and the three responses under each line are the
# three ways a visitor gets it wrong or right. The `rep` numbers are the
# argument: matching how a place actually communicates earns standing, and
# importing the previous city rules costs it.
#
# Appearance is data. `skin`, `hair` and `head` are per person and optional;
# CityNPC falls back to a city-wide range picked by id hash. Nobody wears
# anything because of their age.

# ── ZURICH ────────────────────────────────────────────────────────────────────
# Every word is German. None of it is the German you spent an act learning.

const ZURICH := {
	"ruedi": {
		"name": "Ruedi", "region": "niederdorf", "color": Color(0.42, 0.30, 0.28),
		"role": "drives the 4. Forty-six. Has never once thought about how he speaks.",
		"head": "cap",
		"relationships": ["a fare", "a fare", "the one who writes"],
		"rounds": [
			[{
				"words": [
					{"text": "Grüezi,",  "word": "gruezi",  "language": "swissgerman"},
					{"text": "chumm",    "word": "chumm",   "language": "swissgerman"},
					{"text": "ine,",     "word": "ine",     "language": "swissgerman"},
					{"text": "mir",      "word": "mir",     "language": "swissgerman"},
					{"text": "fahred",   "word": "fahred",  "language": "swissgerman"},
					{"text": "grad.",    "word": "grad",    "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Get on. Work it out later",
						"words": "Step up. Nod.",
						"say": "Right. Yes. Getting on.",
						"style": "casual", "rep": 2},
					{"gesture": "Say the German word for good morning, carefully",
						"words": "Guten Morgen.",
						"say": "Guten Morgen. I would like to travel.",
						"style": "formal", "rep": 0},
					{"gesture": "Ask him to repeat it",
						"words": "Point at your ear. Shake your head.",
						"say": "Sorry - could you say that again more slowly?",
						"style": "direct", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Du",      "word": "du",      "language": "swissgerman"},
					{"text": "verstahsch", "word": "verstahsch", "language": "swissgerman"},
					{"text": "nüt,",    "word": "nut",     "language": "swissgerman"},
					{"text": "oder?",   "word": "oder",    "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Admit it. Hold your hands open",
						"words": "No. Nothing.",
						"say": "No. Not a word of it, and I read the sign fine.",
						"style": "direct", "rep": 2},
					{"gesture": "Pretend you did",
						"words": "Nod. Smile.",
						"say": "Yes, of course, absolutely.",
						"style": "casual", "rep": -2},
					{"gesture": "Point at the printed timetable on the wall",
						"words": "Point at the paper. Then at him.",
						"say": "I can read that. I cannot hear you. Write it?",
						"style": "indirect", "rep": 3},
				],
			}],
			[{
				"words": [
					{"text": "Da,",     "word": "da",      "language": "swissgerman"},
					{"text": "ich",     "word": "ich",     "language": "swissgerman"},
					{"text": "schriibs", "word": "schriibs", "language": "swissgerman"},
					{"text": "der",     "word": "der",     "language": "swissgerman"},
					{"text": "uf.",     "word": "uf",      "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Take the paper with both hands",
						"words": "Take it. Bow your head.",
						"say": "Thank you. This I can actually use.",
						"style": "casual", "rep": 3},
					{"gesture": "Read it aloud, badly",
						"words": "Sound the letters out.",
						"say": "Es-cher-Vice-Platz. Is that near?",
						"style": "direct", "rep": 1},
					{"gesture": "Put it in your pocket without looking",
						"words": "Pocket it.",
						"say": "Fine. Thanks.",
						"style": "casual", "rep": -1},
				],
			}],
		],
	},
	"frau_amsler": {
		"name": "Frau Amsler", "region": "langstrasse",
		"color": Color(0.36, 0.42, 0.40), "build_hint": "elder",
		"role": "kiosk on the corner. Sixty-eight. Speaks four languages and writes in one.",
		"head": "none",
		"relationships": ["a customer", "a customer", "the one from the tram"],
		"rounds": [
			[{
				"words": [
					{"text": "Was",     "word": "was",     "language": "swissgerman"},
					{"text": "wottsch?", "word": "wottsch", "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Point at what you want",
						"words": "Point. Hold up one finger.",
						"say": "That one, please. Just the one.",
						"style": "casual", "rep": 2},
					{"gesture": "Try the sentence you learned in Berlin",
						"words": "Ich möchte...",
						"say": "Ich möchte eine Karte kaufen, bitte.",
						"style": "formal", "rep": 0},
					{"gesture": "Stand there",
						"words": "Say nothing.",
						"say": "...",
						"style": "indirect", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Ah,",     "word": "ah",      "language": "swissgerman"},
					{"text": "Sie",     "word": "sie",     "language": "swissgerman"},
					{"text": "schriibed", "word": "schriibed", "language": "swissgerman"},
					{"text": "lieber.", "word": "lieber",  "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Nod, and hold out the pen",
						"words": "Nod. Offer the pen.",
						"say": "Writing works. Speaking does not. I am sorry.",
						"style": "direct", "rep": 3},
					{"gesture": "Insist on speaking",
						"words": "Keep talking.",
						"say": "No, no, I can manage, I have been learning -",
						"style": "formal", "rep": -2},
					{"gesture": "Laugh, and mean it",
						"words": "Laugh. Shrug.",
						"say": "I learned the wrong half of this language.",
						"style": "casual", "rep": 2},
				],
			}],
			[{
				"words": [
					{"text": "Alli",    "word": "alli",    "language": "swissgerman"},
					{"text": "schriibed", "word": "schriibed", "language": "swissgerman"},
					{"text": "Hochdütsch,", "word": "hochdutsch", "language": "swissgerman"},
					{"text": "keine",   "word": "keine",   "language": "swissgerman"},
					{"text": "redt",    "word": "redt",    "language": "swissgerman"},
					{"text": "so.",     "word": "so",      "language": "swissgerman"},
				],
				"responses": [
					{"gesture": "Sit with that for a moment",
						"words": "Say nothing. Nod slowly.",
						"say": "So the language I learned is one nobody says out loud.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask which one you should have learned",
						"words": "Point at her mouth. Shrug.",
						"say": "Then which one was I supposed to learn?",
						"style": "casual", "rep": 1},
					{"gesture": "Decide it is her problem",
						"words": "Frown. Point at the sign.",
						"say": "The signs are in mine. That should be enough.",
						"style": "direct", "rep": -3},
				],
			}],
		],
	},
}


# ── HANOI ─────────────────────────────────────────────────────────────────────
# You have the word. You do not have the pitch, and the pitch is the word.

const HANOI := {
	"hien": {
		"name": "Hien", "region": "phoco", "color": Color(0.55, 0.30, 0.26),
		"role": "sells bun on a plastic stool. Thirty-eight. Endlessly patient about tone.",
		"head": "none",
		"relationships": ["a customer", "the one who tries", "the one who tries"],
		"rounds": [
			[{
				"words": [
					{"text": "Ban",   "word": "ban",   "language": "vietnamese"},
					{"text": "muon",  "word": "muon",  "language": "vietnamese"},
					{"text": "gi?",   "word": "gi",    "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Point at the pot, then at yourself",
						"words": "Point. One.",
						"say": "That, please. One of those.",
						"style": "casual", "rep": 2},
					{"gesture": "Say the word for water, flat",
						"words": "Nuoc.",
						"say": "Nuoc. I would like nuoc.",
						"style": "direct", "rep": 0},
					{"gesture": "Say it again, higher, watching her face",
						"words": "Nuoc?  ...nuoc?",
						"say": "Nuoc - no. Nuoc? Which one is the drinkable one?",
						"style": "indirect", "rep": 3},
				],
			}],
			[{
				"words": [
					{"text": "Cao",   "word": "cao",   "language": "vietnamese"},
					{"text": "hon.",  "word": "hon",   "language": "vietnamese"},
					{"text": "Nghe",  "word": "nghe",  "language": "vietnamese"},
					{"text": "day.",  "word": "day",   "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Listen to the shape, not the letters",
						"words": "Close your eyes. Listen.",
						"say": "The sound goes up at the end. That is part of the word.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask for it written instead",
						"words": "Mime writing.",
						"say": "Can I have it written? I read better than I hear.",
						"style": "indirect", "rep": -1},
					{"gesture": "Repeat it, and get it wrong again",
						"words": "Try. Fail. Try.",
						"say": "Nuoc. Nuoc. I am saying the same thing you are.",
						"style": "casual", "rep": 1},
				],
			}],
		],
	},
	"lan": {
		"name": "Lan", "region": "dongda", "color": Color(0.42, 0.36, 0.30),
		"role": "sells tea from a cart by the metro stairs. Twenty-nine. Repeats you back.",
		"head": "none",
		"relationships": ["a customer", "a customer", "the one who kept trying"],
		"rounds": [
			[{
				"words": [
					{"text": "Tra",   "word": "tra",   "language": "vietnamese"},
					{"text": "da",    "word": "da",    "language": "vietnamese"},
					{"text": "khong?", "word": "khong", "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Say the word back at the pitch she used",
						"words": "Copy the shape of it, not the letters.",
						"say": "Tra da. Like that? Was that it?",
						"style": "direct", "rep": 3},
					{"gesture": "Say it flat and hope",
						"words": "Tra da.",
						"say": "Tra da. Please.",
						"style": "casual", "rep": 1},
					{"gesture": "Point at the cart instead",
						"words": "Point. Hold up one finger.",
						"say": "One of those. Whatever it is called.",
						"style": "indirect", "rep": 0},
				],
			}],
			[{
				"words": [
					{"text": "Gan",   "word": "gan",   "language": "vietnamese"},
					{"text": "roi.",  "word": "roi",   "language": "vietnamese"},
					{"text": "Lam",   "word": "lam",   "language": "vietnamese"},
					{"text": "lai.",  "word": "lai",   "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Do it again. And again",
						"words": "Try. Listen. Try.",
						"say": "Again. I have got all afternoon and no dignity left.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask her to write the tone marks down",
						"words": "Mime writing. Point at the air above the word.",
						"say": "The little marks. Can you draw me the little marks?",
						"style": "direct", "rep": 2},
					{"gesture": "Decide near enough is enough",
						"words": "Take the tea. Nod.",
						"say": "Near is fine. You understood me.",
						"style": "indirect", "rep": 1},
				],
			}],
		],
	},
	"duc": {
		"name": "Duc", "region": "longbien", "color": Color(0.30, 0.40, 0.45),
		"role": "xe om rider under the bridge. Twenty-four. Corrects you for free.",
		"head": "cap",
		"relationships": ["a fare", "a fare", "the one who listens"],
		"rounds": [
			[{
				"words": [
					{"text": "Di",    "word": "di",    "language": "vietnamese"},
					{"text": "dau?",  "word": "dau",   "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Show him the written address",
						"words": "Hold out the paper.",
						"say": "Here. This place. Do you know it?",
						"style": "casual", "rep": 2},
					{"gesture": "Say the district name and watch it miss",
						"words": "Ba Dinh.",
						"say": "Ba Dinh. I am trying to get to Ba Dinh.",
						"style": "direct", "rep": 1},
					{"gesture": "Point along the road and hope",
						"words": "Point. Shrug.",
						"say": "That way? Somewhere that way.",
						"style": "indirect", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Ban",   "word": "ban",   "language": "vietnamese"},
					{"text": "noi",   "word": "noi",   "language": "vietnamese"},
					{"text": "gan",   "word": "gan",   "language": "vietnamese"},
					{"text": "dung.", "word": "dung",  "language": "vietnamese"},
				],
				"responses": [
					{"gesture": "Take the near-miss as the compliment it is",
						"words": "Nod. Smile.",
						"say": "Near is further than I got yesterday.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask him to say it once more",
						"words": "Point at his mouth. Wait.",
						"say": "Once more. I want the shape, not the letters.",
						"style": "direct", "rep": 2},
					{"gesture": "Decide the language is broken",
						"words": "Sigh. Wave it away.",
						"say": "It is the same word. It should not matter how I sing it.",
						"style": "direct", "rep": -3},
				],
			}],
		],
	},
}


# ── TOKYO ─────────────────────────────────────────────────────────────────────
# Nobody will ever say no to you. The no is in the pause.

const TOKYO := {
	"iwata": {
		"name": "Iwata-san", "region": "jinbocho", "color": Color(0.34, 0.32, 0.40),
		"role": "second-hand bookshop, third generation. Sixty-two. Never refuses.",
		"head": "none",
		"relationships": ["a customer", "a customer", "a regular"],
		"rounds": [
			[{
				"words": [
					{"text": "Chotto",  "word": "chotto", "language": "japanese"},
					{"text": "ne...",   "word": "ne",     "language": "japanese"},
				],
				"responses": [
					{"gesture": "Stop. Let the silence finish the sentence",
						"words": "Wait. Say nothing.",
						"say": "...Ah. That is a no, is it.",
						"style": "indirect", "rep": 3},
					{"gesture": "Fill the gap",
						"words": "Talk. Keep talking.",
						"say": "It is fine, I can come back, or I could pay more, or -",
						"style": "casual", "rep": -2},
					{"gesture": "Ask him to be direct",
						"words": "Point. Ask.",
						"say": "Is that a yes or a no? I would rather know.",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Muzukashii", "word": "muzukashii", "language": "japanese"},
					{"text": "desu",       "word": "desu",       "language": "japanese"},
					{"text": "ne.",        "word": "ne",         "language": "japanese"},
				],
				"responses": [
					{"gesture": "Thank him for the answer he did give",
						"words": "Bow. Step back.",
						"say": "Difficult. Yes. Thank you for telling me.",
						"style": "indirect", "rep": 3},
					{"gesture": "Hear difficult as not impossible",
						"words": "Lean in. Try again.",
						"say": "Difficult is not no. What would make it easier?",
						"style": "direct", "rep": -2},
					{"gesture": "Buy something small and leave",
						"words": "Put a coin down. Go.",
						"say": "I will take this one instead. Thank you.",
						"style": "casual", "rep": 2},
				],
			}],
		],
	},
	"sora": {
		"name": "Sora", "region": "yanaka", "color": Color(0.46, 0.40, 0.30),
		"role": "art student, nineteen, talks too much and knows it.",
		"head": "hood",
		"relationships": ["a stranger", "the quiet one", "the quiet one"],
		"rounds": [
			[{
				"words": [
					{"text": "Sumimasen,", "word": "sumimasen", "language": "japanese"},
					{"text": "daijoubu",   "word": "daijoubu",  "language": "japanese"},
					{"text": "desu",       "word": "desu",      "language": "japanese"},
					{"text": "ka?",        "word": "ka",        "language": "japanese"},
				],
				"responses": [
					{"gesture": "Nod, and let it rest there",
						"words": "Nod once.",
						"say": "Yes. Fine. Thank you.",
						"style": "indirect", "rep": 2},
					{"gesture": "Explain everything",
						"words": "Gesture. Point. Gesture.",
						"say": "Not really - I have walked since six and I cannot -",
						"style": "casual", "rep": 0},
					{"gesture": "Stare",
						"words": "Say nothing at all.",
						"say": "...",
						"style": "direct", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Watashi",  "word": "watashi", "language": "japanese"},
					{"text": "mo",       "word": "mo",      "language": "japanese"},
					{"text": "shizuka",  "word": "shizuka", "language": "japanese"},
					{"text": "ga",       "word": "ga",      "language": "japanese"},
					{"text": "nigate.",  "word": "nigate",  "language": "japanese"},
				],
				"responses": [
					{"gesture": "Let the pause sit, together",
						"words": "Sit. Wait.",
						"say": "So we can both be bad at it. Quietly.",
						"style": "indirect", "rep": 3},
					{"gesture": "Fill it, cheerfully",
						"words": "Talk about the weather.",
						"say": "It is very warm today. Is it always this warm?",
						"style": "casual", "rep": 1},
					{"gesture": "Name the thing out loud",
						"words": "Point at the air between you.",
						"say": "The quiet is where the meaning is here, is it not.",
						"style": "direct", "rep": 2},
				],
			}],
		],
	},
}


# ── ROME ──────────────────────────────────────────────────────────────────────
# Waiting for a gap is not politeness here. It is how you never speak.

const ROME := {
	"nando": {
		"name": "Nando", "region": "testaccio", "color": Color(0.60, 0.34, 0.22),
		"role": "third stall on the left, forty years. Fifty-nine. Talks over everyone.",
		"head": "cap",
		"relationships": ["nobody", "the quiet one", "one of the regulars"],
		"rounds": [
			[{
				"words": [
					{"text": "Allora,", "word": "allora", "language": "italian"},
					{"text": "dimmi,",  "word": "dimmi",  "language": "italian"},
					{"text": "dimmi,",  "word": "dimmi",  "language": "italian"},
					{"text": "che",     "word": "che",    "language": "italian"},
					{"text": "vuoi -",  "word": "vuoi",   "language": "italian"},
				],
				"responses": [
					{"gesture": "Cut straight in over the end of it",
						"words": "Talk. Now. Over him.",
						"say": "That one - the one at the back - how much?",
						"style": "casual", "rep": 3},
					{"gesture": "Wait for him to finish",
						"words": "Wait. Keep waiting.",
						"say": "(He has started a different sentence. And another.)",
						"style": "formal", "rep": -2},
					{"gesture": "Raise a hand and wait to be called on",
						"words": "Hand up. Wait.",
						"say": "Excuse me - sorry - when you have a moment -",
						"style": "indirect", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Ecco,",  "word": "ecco",  "language": "italian"},
					{"text": "cosi",   "word": "cosi",  "language": "italian"},
					{"text": "si",     "word": "si",    "language": "italian"},
					{"text": "fa.",    "word": "fa",    "language": "italian"},
				],
				"responses": [
					{"gesture": "Interrupt him agreeing with you",
						"words": "Cut in. Agree loudly.",
						"say": "I know, I know - I have been doing it wrong all week -",
						"style": "casual", "rep": 3},
					{"gesture": "Apologise for interrupting",
						"words": "Stop. Step back.",
						"say": "Sorry. I did not mean to talk over you.",
						"style": "formal", "rep": -2},
					{"gesture": "Ask why silence was the wrong answer",
						"words": "Point at your own mouth. Shrug.",
						"say": "Where I have been, waiting was the polite thing.",
						"style": "direct", "rep": 1},
				],
			}],
		],
	},
	"lucia": {
		"name": "Lucia", "region": "esquilino", "color": Color(0.38, 0.30, 0.42),
		"role": "runs the bar by the market. Forty-four. Serves whoever speaks.",
		"head": "none",
		"relationships": ["nobody", "a face", "a face"],
		"rounds": [
			[{
				"words": [
					{"text": "Chi",   "word": "chi",   "language": "italian"},
					{"text": "e",     "word": "e",     "language": "italian"},
					{"text": "il",    "word": "il",    "language": "italian"},
					{"text": "prossimo?", "word": "prossimo", "language": "italian"},
				],
				"responses": [
					{"gesture": "Say what you want before anyone else does",
						"words": "Speak. Immediately.",
						"say": "Coffee. Standing. Thank you.",
						"style": "casual", "rep": 3},
					{"gesture": "Look around to see whose turn it is",
						"words": "Look left. Look right.",
						"say": "(Two people arrived after you and are being served.)",
						"style": "indirect", "rep": -2},
					{"gesture": "Point at the person who was here first",
						"words": "Point at them. Step back.",
						"say": "They were before me, I think.",
						"style": "formal", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Bravo.", "word": "bravo", "language": "italian"},
					{"text": "Stavolta", "word": "stavolta", "language": "italian"},
					{"text": "hai",    "word": "hai",   "language": "italian"},
					{"text": "parlato.", "word": "parlato", "language": "italian"},
				],
				"responses": [
					{"gesture": "Accept it without deflecting",
						"words": "Nod. Take the cup.",
						"say": "I worked out that nobody was going to ask me.",
						"style": "casual", "rep": 3},
					{"gesture": "Apologise for having been loud",
						"words": "Shrink slightly.",
						"say": "I hope I was not rude about it.",
						"style": "formal", "rep": -2},
					{"gesture": "Say what it cost you",
						"words": "Rub your face. Laugh.",
						"say": "Four days. It took four days to make myself do that.",
						"style": "direct", "rep": 2},
				],
			}],
		],
	},
}


# ── MOSCOW ────────────────────────────────────────────────────────────────────
# Your face has been making a claim for four cities. Here it is read as one.

const MOSCOW := {
	"galina": {
		"name": "Galina", "region": "kitaygorod", "color": Color(0.34, 0.36, 0.44),
		"role": "kiosk by the metro. Fifty-seven. Will help you completely, unsmiling.",
		"head": "none",
		"relationships": ["a stranger", "a stranger", "the one who stopped grinning"],
		"rounds": [
			[{
				"words": [
					{"text": "Chto",  "word": "chto",  "language": "russian"},
					{"text": "vam",   "word": "vam",   "language": "russian"},
					{"text": "nuzhno?", "word": "nuzhno", "language": "russian"},
				],
				"responses": [
					{"gesture": "Say what you need. Nothing else",
						"words": "Point. State it.",
						"say": "A ticket. One. Please.",
						"style": "direct", "rep": 3},
					{"gesture": "Smile widely first, to show you mean well",
						"words": "Smile. Then point.",
						"say": "Hello! Lovely day! Could I possibly get a ticket?",
						"style": "casual", "rep": -3},
					{"gesture": "Apologise for existing, then ask",
						"words": "Shrink. Point.",
						"say": "Sorry, so sorry to bother you, if it is not too much -",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Pochemu", "word": "pochemu", "language": "russian"},
					{"text": "vy",      "word": "vy",      "language": "russian"},
					{"text": "vsyo",    "word": "vsyo",    "language": "russian"},
					{"text": "vremya",  "word": "vremya",  "language": "russian"},
					{"text": "ulybaetes?", "word": "ulybaetes", "language": "russian"},
				],
				"responses": [
					{"gesture": "Let your face go still and answer plainly",
						"words": "Stop. Answer.",
						"say": "Because where I come from it means I am not a threat.",
						"style": "direct", "rep": 3},
					{"gesture": "Smile harder to prove you are friendly",
						"words": "Smile. Widen it.",
						"say": "I am just being friendly. It is only politeness.",
						"style": "casual", "rep": -3},
					{"gesture": "Ask what a smile is for here",
						"words": "Point at your mouth. Then at hers.",
						"say": "What does it mean, here, when somebody does it?",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
	"artyom": {
		"name": "Artyom", "region": "basmanny", "color": Color(0.28, 0.34, 0.38),
		"role": "fixes lifts. Thirty-three. Smiles roughly twice a year.",
		"head": "cap",
		"relationships": ["nobody", "nobody", "someone he knows"],
		"rounds": [
			[{
				"words": [
					{"text": "Vy",     "word": "vy",     "language": "russian"},
					{"text": "zabludilis?", "word": "zabludilis", "language": "russian"},
				],
				"responses": [
					{"gesture": "Admit it flatly",
						"words": "Nod. Once.",
						"say": "Completely. I have been walking in a circle.",
						"style": "direct", "rep": 3},
					{"gesture": "Laugh it off",
						"words": "Laugh. Wave a hand.",
						"say": "Ha, no, no, I am fine, all good, thank you so much!",
						"style": "casual", "rep": -2},
					{"gesture": "Say nothing and look at the map",
						"words": "Look down. Study it.",
						"say": "...",
						"style": "indirect", "rep": 0},
				],
			}],
			[{
				"words": [
					{"text": "Idyom.", "word": "idyom", "language": "russian"},
					{"text": "Ya",     "word": "ya",     "language": "russian"},
					{"text": "pokazhu.", "word": "pokazhu", "language": "russian"},
				],
				"responses": [
					{"gesture": "Follow without thanking him five times",
						"words": "Nod. Follow.",
						"say": "Thank you. Once, and I mean it.",
						"style": "direct", "rep": 3},
					{"gesture": "Thank him repeatedly on the way",
						"words": "Thank him. Again. Again.",
						"say": "This is so kind, honestly, so kind, thank you, really -",
						"style": "casual", "rep": -2},
					{"gesture": "Notice him almost smile, and not mention it",
						"words": "See it. Look away.",
						"say": "(The corner of his mouth moved. He would deny it.)",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
}


# ── MEXICO CITY ───────────────────────────────────────────────────────────────
# Moscow, inverted, and it must be played straight after it. Flat reads as cold.

const MEXICO := {
	"pilar": {
		"name": "Dona Pilar", "region": "merced", "color": Color(0.62, 0.36, 0.30),
		"role": "herbs and dried chillies, aisle four. Sixty-three. Diminutives everything.",
		"head": "none",
		"relationships": ["a customer", "joven", "mijo"],
		"rounds": [
			[{
				"words": [
					{"text": "Que",    "word": "que",    "language": "spanish_mx"},
					{"text": "le",     "word": "le",     "language": "spanish_mx"},
					{"text": "damos,", "word": "damos",  "language": "spanish_mx"},
					{"text": "joven?", "word": "joven",  "language": "spanish_mx"},
				],
				"responses": [
					{"gesture": "Approach it sideways, warmly",
						"words": "Greet. Then ask.",
						"say": "Good morning - what a lot you have. Might I take a little?",
						"style": "indirect", "rep": 3},
					{"gesture": "State the requirement plainly, and nothing else",
						"words": "Point. State it.",
						"say": "One hundred grams. That one.",
						"style": "direct", "rep": -3},
					{"gesture": "Say nothing and hold up the money",
						"words": "Hold out coins.",
						"say": "...",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Ay,",     "word": "ay",     "language": "spanish_mx"},
					{"text": "no",      "word": "no",     "language": "spanish_mx"},
					{"text": "sea",     "word": "sea",    "language": "spanish_mx"},
					{"text": "asi,",    "word": "asi",    "language": "spanish_mx"},
					{"text": "mijo.",   "word": "mijo",   "language": "spanish_mx"},
				],
				"responses": [
					{"gesture": "Soften, and start again",
						"words": "Slow down. Try again, gently.",
						"say": "Forgive me. I came from somewhere blunter than this.",
						"style": "indirect", "rep": 3},
					{"gesture": "Defend the directness",
						"words": "Frown. Repeat it.",
						"say": "I only said what I wanted. That is not rudeness.",
						"style": "direct", "rep": -3},
					{"gesture": "Ask her to teach you the long way round",
						"words": "Point at her. Then at your mouth.",
						"say": "Show me how you would have asked me for it.",
						"style": "casual", "rep": 2},
				],
			}],
		],
	},
	"chuy": {
		"name": "Chuy", "region": "juarez", "color": Color(0.40, 0.48, 0.34),
		"role": "juice cart on the corner. Twenty-six. Never says no to anybody either.",
		"head": "cap",
		"relationships": ["a stranger", "compa", "compa"],
		"rounds": [
			[{
				"words": [
					{"text": "Ahorita", "word": "ahorita", "language": "spanish_mx"},
					{"text": "se",      "word": "se",      "language": "spanish_mx"},
					{"text": "lo",      "word": "lo",      "language": "spanish_mx"},
					{"text": "hago.",   "word": "hago",    "language": "spanish_mx"},
				],
				"responses": [
					{"gesture": "Settle in. Ahorita is not now",
						"words": "Sit. Wait.",
						"say": "I have learned what that word actually means. I will wait.",
						"style": "indirect", "rep": 3},
					{"gesture": "Ask how long ahorita is",
						"words": "Tap your wrist. Raise eyebrows.",
						"say": "How long is ahorita, roughly, in minutes?",
						"style": "direct", "rep": 0},
					{"gesture": "Assume it means immediately and hover",
						"words": "Stand very close. Watch him.",
						"say": "Great, I will just wait right here then.",
						"style": "casual", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Oiga,",  "word": "oiga",  "language": "spanish_mx"},
					{"text": "usted",  "word": "usted", "language": "spanish_mx"},
					{"text": "no",     "word": "no",    "language": "spanish_mx"},
					{"text": "es",     "word": "es",    "language": "spanish_mx"},
					{"text": "de",     "word": "de",    "language": "spanish_mx"},
					{"text": "aqui.",  "word": "aqui",  "language": "spanish_mx"},
				],
				"responses": [
					{"gesture": "Agree, and leave the rest unsaid",
						"words": "Shake your head. Smile.",
						"say": "No. Not from anywhere near here, in fact.",
						"style": "indirect", "rep": 3},
					{"gesture": "Say exactly where you are from",
						"words": "Point at the sky.",
						"say": "I came down in a field. I have been walking since.",
						"style": "direct", "rep": 1},
					{"gesture": "Ask how he could tell",
						"words": "Point at yourself. Shrug.",
						"say": "What gave it away? I have been trying very hard.",
						"style": "casual", "rep": 2},
				],
			}],
		],
	},
}


# ── SAO PAULO ─────────────────────────────────────────────────────────────────
# The distance you stand at is the sentence. Nobody will ever tell you that.

const SAOPAULO := {
	"jandira": {
		"name": "Jandira", "region": "liberdade", "color": Color(0.56, 0.28, 0.30),
		"role": "runs the shop under the red lamps. Forty-one. Stands very close.",
		"head": "none",
		"relationships": ["a stranger", "querido", "querido"],
		"rounds": [
			[{
				"words": [
					{"text": "Oi,",     "word": "oi",     "language": "portuguese"},
					{"text": "tudo",    "word": "tudo",   "language": "portuguese"},
					{"text": "bem?",    "word": "bem",    "language": "portuguese"},
				],
				"responses": [
					{"gesture": "Stay where you are while she comes in close",
						"words": "Hold your ground. Nod.",
						"say": "All good, thank you. Yes.",
						"style": "casual", "rep": 3},
					{"gesture": "Take a step back to a comfortable distance",
						"words": "Step back.",
						"say": "(Her face changes very slightly. She does not follow.)",
						"style": "formal", "rep": -3},
					{"gesture": "Step back, then realise, and step in again",
						"words": "Back. Then forward.",
						"say": "Sorry - I am from somewhere that stands further away.",
						"style": "direct", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Voce",   "word": "voce",   "language": "portuguese"},
					{"text": "fica",   "word": "fica",   "language": "portuguese"},
					{"text": "longe",  "word": "longe",  "language": "portuguese"},
					{"text": "demais.", "word": "demais", "language": "portuguese"},
				],
				"responses": [
					{"gesture": "Close the gap and stay there",
						"words": "Move in. Stay.",
						"say": "Then I will stand here. Tell me if it is still wrong.",
						"style": "casual", "rep": 3},
					{"gesture": "Explain that where you come from it is respect",
						"words": "Point at the floor between you.",
						"say": "Where I have been, this gap was the polite thing.",
						"style": "direct", "rep": 2},
					{"gesture": "Apologise and keep the distance anyway",
						"words": "Apologise. Do not move.",
						"say": "Sorry. I am more comfortable here, if that is all right.",
						"style": "formal", "rep": -2},
				],
			}],
		],
	},
	"wellington": {
		"name": "Wellington", "region": "bixiga", "color": Color(0.34, 0.44, 0.38),
		"role": "sound engineer, twenty-nine, touches your arm mid-sentence.",
		"head": "cap",
		"relationships": ["a stranger", "mano", "mano"],
		"rounds": [
			[{
				"words": [
					{"text": "Fala,",  "word": "fala",  "language": "portuguese"},
					{"text": "mano.",  "word": "mano",  "language": "portuguese"},
					{"text": "Perdido?", "word": "perdido", "language": "portuguese"},
				],
				"responses": [
					{"gesture": "Let him put a hand on your arm",
						"words": "Stay still. Let it happen.",
						"say": "Very. Which way is the market from here?",
						"style": "casual", "rep": 3},
					{"gesture": "Pull your arm away",
						"words": "Withdraw the arm.",
						"say": "(He lets go at once, and stops leaning in.)",
						"style": "formal", "rep": -3},
					{"gesture": "Ask before you touch him back",
						"words": "Gesture at his shoulder. Wait.",
						"say": "Is this all right, here? I am still learning the rules.",
						"style": "direct", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Relaxa,", "word": "relaxa", "language": "portuguese"},
					{"text": "aqui",    "word": "aqui",   "language": "portuguese"},
					{"text": "e",       "word": "e",      "language": "portuguese"},
					{"text": "assim.",  "word": "assim",  "language": "portuguese"},
				],
				"responses": [
					{"gesture": "Relax, actually",
						"words": "Loosen. Breathe out.",
						"say": "All right. I will stop measuring the distance.",
						"style": "casual", "rep": 3},
					{"gesture": "Say what the space had been protecting",
						"words": "Point at the gap. Then at yourself.",
						"say": "I kept it because it was the one thing I controlled.",
						"style": "direct", "rep": 2},
					{"gesture": "Stay stiff",
						"words": "Hold still. Say nothing.",
						"say": "...",
						"style": "formal", "rep": -1},
				],
			}],
		],
	},
}


# ── DAKAR ─────────────────────────────────────────────────────────────────────
# You may not begin. The greeting is not the preamble, it is the door.

const DAKAR := {
	"ousmane": {
		"name": "Ousmane", "region": "medina", "color": Color(0.28, 0.46, 0.42),
		"role": "tailor, two doors down from the mosque. Fifty-two. Never rushed.",
		"head": "none",
		"relationships": ["a stranger", "a guest", "a guest"],
		"rounds": [
			[{
				"words": [
					{"text": "Salaam",  "word": "salaam",  "language": "wolof"},
					{"text": "aleekum.", "word": "aleekum", "language": "wolof"},
					{"text": "Naka",    "word": "naka",    "language": "wolof"},
					{"text": "nga",     "word": "nga",     "language": "wolof"},
					{"text": "def?",    "word": "def",     "language": "wolof"},
				],
				"responses": [
					{"gesture": "Return the greeting and ask it back",
						"words": "Return it. Then ask him.",
						"say": "And upon you. And you - how are you?",
						"style": "formal", "rep": 3},
					{"gesture": "Answer, then go straight to the business",
						"words": "Nod. Then point at the cloth.",
						"say": "Fine, thank you. I need this mended by tonight.",
						"style": "direct", "rep": -3},
					{"gesture": "Wait for him to get to the point",
						"words": "Wait. Watch.",
						"say": "(He asks about your household. Then your health. Again.)",
						"style": "indirect", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Ana",     "word": "ana",     "language": "wolof"},
					{"text": "waa",     "word": "waa",     "language": "wolof"},
					{"text": "ker",     "word": "ker",     "language": "wolof"},
					{"text": "ga?",     "word": "ga",      "language": "wolof"},
				],
				"responses": [
					{"gesture": "Answer honestly, which is the hard answer",
						"words": "Shake your head slowly.",
						"say": "I do not have one. Not on this planet.",
						"style": "direct", "rep": 3},
					{"gesture": "Say they are well, because that is the form",
						"words": "Nod. Say the words.",
						"say": "They are well. Thank you for asking after them.",
						"style": "formal", "rep": 2},
					{"gesture": "Ask why he wants to know",
						"words": "Frown. Point at him.",
						"say": "Why does my family matter to a trouser hem?",
						"style": "casual", "rep": -3},
				],
			}],
		],
	},
	"awa": {
		"name": "Awa", "region": "sandaga", "color": Color(0.52, 0.34, 0.44),
		"role": "wax cloth, six bolts deep. Thirty-six. Will out-greet anybody.",
		"head": "wrap",
		"relationships": ["a stranger", "sister", "sister"],
		"rounds": [
			[{
				"words": [
					{"text": "Nanga",  "word": "nanga",  "language": "wolof"},
					{"text": "def?",   "word": "def",    "language": "wolof"},
					{"text": "Mbaa",   "word": "mbaa",   "language": "wolof"},
					{"text": "sant",   "word": "sant",   "language": "wolof"},
					{"text": "wi?",    "word": "wi",     "language": "wolof"},
				],
				"responses": [
					{"gesture": "Give your name, and ask for hers",
						"words": "Point at yourself. Then at her.",
						"say": "I have no name to give you. But I would like yours.",
						"style": "formal", "rep": 3},
					{"gesture": "Repeat the greeting back word for word",
						"words": "Copy it. Exactly.",
						"say": "Nanga def. Mbaa sant wi.",
						"style": "casual", "rep": 2},
					{"gesture": "Point at the cloth you want",
						"words": "Point. Hold up two fingers.",
						"say": "Two metres of that blue one.",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Lu",     "word": "lu",     "language": "wolof"},
					{"text": "tax",    "word": "tax",    "language": "wolof"},
					{"text": "nga",    "word": "nga",    "language": "wolof"},
					{"text": "gaaw?",  "word": "gaaw",   "language": "wolof"},
				],
				"responses": [
					{"gesture": "Slow all the way down",
						"words": "Stop. Sit on the stool.",
						"say": "No reason. I have nowhere to be that matters.",
						"style": "indirect", "rep": 3},
					{"gesture": "Admit the habit is from somewhere else",
						"words": "Point back over your shoulder.",
						"say": "Four cities taught me that speed was politeness.",
						"style": "direct", "rep": 2},
					{"gesture": "Check the time",
						"words": "Look at the sun. Fidget.",
						"say": "I do have somewhere to be, actually.",
						"style": "casual", "rep": -2},
				],
			}],
		],
	},
}


# ── TBILISI ───────────────────────────────────────────────────────────────────
# It is your turn to speak, there is a correct shape, and nobody will say what.

const TBILISI := {
	"zurab": {
		"name": "Zurab", "region": "sololaki", "color": Color(0.48, 0.24, 0.28),
		"role": "keeps wine in the cellar under the balcony. Sixty-six. Runs the table.",
		"head": "none",
		"relationships": ["a guest", "a guest", "one of the table"],
		"rounds": [
			[{
				"words": [
					{"text": "Akhla",  "word": "akhla",  "language": "georgian"},
					{"text": "shen",   "word": "shen",   "language": "georgian"},
					{"text": "khar.",  "word": "khar",   "language": "georgian"},
				],
				"responses": [
					{"gesture": "Stand up, because standing is the first half of it",
						"words": "Stand. Hold the glass.",
						"say": "(Everyone is waiting. Standing was correct.)",
						"style": "formal", "rep": 3},
					{"gesture": "Stay seated and say something short and warm",
						"words": "Sit. Raise the glass an inch.",
						"say": "To all of you. Thank you for the food.",
						"style": "casual", "rep": -2},
					{"gesture": "Decline",
						"words": "Shake your head. Push the glass away.",
						"say": "I would rather not. I am no good at this.",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Rasac",   "word": "rasac",   "language": "georgian"},
					{"text": "ginda,",  "word": "ginda",   "language": "georgian"},
					{"text": "magram",  "word": "magram",  "language": "georgian"},
					{"text": "grdzlad.", "word": "grdzlad", "language": "georgian"},
				],
				"responses": [
					{"gesture": "Speak at length about the dead, which is the order",
						"words": "Speak. Keep going. Do not stop early.",
						"say": "To the people who are not at this table. And then to peace.",
						"style": "formal", "rep": 3},
					{"gesture": "Say one true sentence and sit down",
						"words": "One line. Sit.",
						"say": "I am glad I am here. That is all I have.",
						"style": "direct", "rep": 1},
					{"gesture": "Make a joke",
						"words": "Grin. Say something light.",
						"say": "To whoever has to carry me home!",
						"style": "casual", "rep": -3},
				],
			}],
		],
	},
	"nino": {
		"name": "Nino", "region": "dezerter", "color": Color(0.38, 0.44, 0.32),
		"role": "sells cheese and herbs by the station. Forty-eight. Coaches you quietly.",
		"head": "scarf",
		"relationships": ["a customer", "a customer", "the one who listened"],
		"rounds": [
			[{
				"words": [
					{"text": "Ar",      "word": "ar",      "language": "georgian"},
					{"text": "ginervulo.", "word": "ginervulo", "language": "georgian"},
					{"text": "Aris",    "word": "aris",    "language": "georgian"},
					{"text": "tsesi.",  "word": "tsesi",   "language": "georgian"},
				],
				"responses": [
					{"gesture": "Ask what the order of subjects is",
						"words": "Point at the table. Then count on your fingers.",
						"say": "There is an order, is there. Tell me the order.",
						"style": "direct", "rep": 3},
					{"gesture": "Say you would rather mean it than get it right",
						"words": "Touch your chest. Shrug.",
						"say": "I would rather say something true than something correct.",
						"style": "casual", "rep": 0},
					{"gesture": "Nod as though you understood",
						"words": "Nod. Say nothing.",
						"say": "Of course. A rule. Naturally.",
						"style": "indirect", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Jer",     "word": "jer",     "language": "georgian"},
					{"text": "mshvidoba,", "word": "mshvidoba", "language": "georgian"},
					{"text": "mere",    "word": "mere",    "language": "georgian"},
					{"text": "mshoblebi.", "word": "mshoblebi", "language": "georgian"},
				],
				"responses": [
					{"gesture": "Learn it as a form, not as a feeling",
						"words": "Repeat the order back.",
						"say": "Peace first. Then parents. It is a container, not a feeling.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask whether anyone means it",
						"words": "Point at the room. Raise an eyebrow.",
						"say": "Does anybody actually mean any of it?",
						"style": "casual", "rep": -1},
					{"gesture": "Thank her for telling you the rule nobody says",
						"words": "Bow your head.",
						"say": "Nobody else was going to tell me that. Thank you.",
						"style": "formal", "rep": 2},
				],
			}],
		],
	},
}


# ── SEOUL ─────────────────────────────────────────────────────────────────────
# You cannot finish a sentence without claiming a rank you do not have.

const SEOUL := {
	"baek": {
		"name": "Baek sajangnim", "region": "euljiro", "color": Color(0.34, 0.36, 0.34),
		"role": "lathe and press, same unit since 1979. Seventy-one. Asks your age first.",
		"head": "cap",
		"relationships": ["a stranger", "the foreigner", "the one who asked"],
		"rounds": [
			[{
				"words": [
					{"text": "Nai-ga",  "word": "nai",     "language": "korean"},
					{"text": "eotteoke", "word": "eotteoke", "language": "korean"},
					{"text": "doeseyo?", "word": "doeseyo", "language": "korean"},
				],
				"responses": [
					{"gesture": "Try to answer a question you have no answer to",
						"words": "Open your hands. Shake your head.",
						"say": "I do not have one. Not in years that mean anything here.",
						"style": "direct", "rep": 2},
					{"gesture": "Ask why it matters before he can order the room",
						"words": "Point at him. Then at yourself.",
						"say": "Why is that the first thing? What changes?",
						"style": "casual", "rep": -2},
					{"gesture": "Guess high, and let him be the elder",
						"words": "Hold a hand low. Then point at him, high.",
						"say": "Younger than you. Certainly younger than you.",
						"style": "formal", "rep": 3},
				],
			}],
			[{
				"words": [
					{"text": "Geureom", "word": "geureom", "language": "korean"},
					{"text": "malmun-i", "word": "malmun", "language": "korean"},
					{"text": "an",      "word": "an",      "language": "korean"},
					{"text": "yeollyeo.", "word": "yeollyeo", "language": "korean"},
				],
				"responses": [
					{"gesture": "Understand that the grammar has stopped, not the man",
						"words": "Nod slowly.",
						"say": "So without a rank there is no verb ending. None at all.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask him to choose one for you",
						"words": "Point at him. Then at your mouth.",
						"say": "Then decide for me. Put me somewhere and I will speak from there.",
						"style": "formal", "rep": 3},
					{"gesture": "Speak flat and hope it passes",
						"words": "Say it with no ending at all.",
						"say": "(The sentence stops halfway and lands on the floor.)",
						"style": "casual", "rep": -2},
				],
			}],
		],
	},
	"jiwon": {
		"name": "Jiwon", "region": "mangwon", "color": Color(0.44, 0.34, 0.48),
		"role": "designs type upstairs from a press. Thirty-one. Drops the honorifics early.",
		"head": "none",
		"relationships": ["a stranger", "a neighbour", "a friend"],
		"rounds": [
			[{
				"words": [
					{"text": "Mal",    "word": "mal",    "language": "korean"},
					{"text": "noha-do", "word": "noha",   "language": "korean"},
					{"text": "dwae?",  "word": "dwae",   "language": "korean"},
				],
				"responses": [
					{"gesture": "Say yes, without knowing what you agreed to",
						"words": "Nod.",
						"say": "Yes. Whatever that was, yes.",
						"style": "casual", "rep": 2},
					{"gesture": "Ask what she is offering to put down",
						"words": "Point at her mouth. Tilt your head.",
						"say": "What exactly are you asking to stop doing?",
						"style": "direct", "rep": 2},
					{"gesture": "Insist on the formal ending, to be safe",
						"words": "Keep the long ending on.",
						"say": "I would rather stay respectful, if that is all right.",
						"style": "formal", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Igeon",  "word": "igeon",  "language": "korean"},
					{"text": "gangdeung-i", "word": "gangdeung", "language": "korean"},
					{"text": "anya.",  "word": "anya",   "language": "korean"},
					{"text": "Chodae-ya.", "word": "chodae", "language": "korean"},
				],
				"responses": [
					{"gesture": "Take it as the invitation it is",
						"words": "Sit down. Use the short ending back.",
						"say": "Then I will take it. Thank you - the short way.",
						"style": "casual", "rep": 3},
					{"gesture": "Say you had read it as a demotion",
						"words": "Touch your chest. Look down.",
						"say": "I thought you had put me lower. I had it backwards.",
						"style": "direct", "rep": 3},
					{"gesture": "Keep the distance the formal ending gave you",
						"words": "Hold the long ending.",
						"say": "(She does not push it. But she does not do it again.)",
						"style": "formal", "rep": -2},
				],
			}],
		],
	},
}


# ── MUMBAI ────────────────────────────────────────────────────────────────────
# There is no single language to learn. The mix is the register.

const MUMBAI := {
	"farid": {
		"name": "Farid", "region": "chorbazaar", "color": Color(0.50, 0.38, 0.24),
		"role": "brass, clocks, and things off ships. Fifty-four. Sells in three at once.",
		"head": "cap",
		"relationships": ["a stranger", "boss", "boss"],
		"rounds": [
			[{
				"words": [
					{"text": "Arre",   "word": "arre",   "language": "hindi"},
					{"text": "boss,",  "word": "boss",   "language": "hindi"},
					{"text": "kya",    "word": "kya",    "language": "hindi"},
					{"text": "chahiye,", "word": "chahiye", "language": "hindi"},
					{"text": "tell",   "word": "tell",   "language": "hindi"},
					{"text": "me.",    "word": "me",     "language": "hindi"},
				],
				"responses": [
					{"gesture": "Mix it back, badly, without apologising",
						"words": "Point. Use whatever words arrive.",
						"say": "That one - kitna - the brass one, how much?",
						"style": "casual", "rep": 3},
					{"gesture": "Answer in careful, complete English",
						"words": "Speak clearly. One language.",
						"say": "Good afternoon. I would like to enquire about that item.",
						"style": "formal", "rep": -2},
					{"gesture": "Try one full sentence of Hindi",
						"words": "Say it all in one language.",
						"say": "Mujhe woh cheez chahiye.",
						"style": "direct", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Aise",   "word": "aise",   "language": "hindi"},
					{"text": "hi",     "word": "hi",     "language": "hindi"},
					{"text": "bolte",  "word": "bolte",  "language": "hindi"},
					{"text": "hain",   "word": "hain",   "language": "hindi"},
					{"text": "yahan.", "word": "yahan",  "language": "hindi"},
				],
				"responses": [
					{"gesture": "Stop trying to be pure and start assembling",
						"words": "Take words from three places. Stack them.",
						"say": "So a clean sentence is the one that marks me out. Fine.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask which one is the real language",
						"words": "Hold up three fingers. Point at each.",
						"say": "Which of the three is the actual one?",
						"style": "direct", "rep": 0},
					{"gesture": "Decide to learn one properly and use only that",
						"words": "Shake your head. Pick one.",
						"say": "I will learn one of them properly. That must be better.",
						"style": "formal", "rep": -3},
				],
			}],
		],
	},
	"sunita": {
		"name": "Sunita", "region": "bhuleshwar", "color": Color(0.58, 0.32, 0.40),
		"role": "wholesale thread, fourth generation. Forty-seven. Corrects your grammar kindly.",
		"head": "none",
		"relationships": ["a stranger", "beta", "beta"],
		"rounds": [
			[{
				"words": [
					{"text": "Kitna",  "word": "kitna",  "language": "hindi"},
					{"text": "chahiye,", "word": "chahiye", "language": "hindi"},
					{"text": "half",   "word": "half",   "language": "hindi"},
					{"text": "kilo?",  "word": "kilo",   "language": "hindi"},
				],
				"responses": [
					{"gesture": "Answer in the same mix she used",
						"words": "Half kilo. Haan.",
						"say": "Half kilo, haan. Bas.",
						"style": "casual", "rep": 3},
					{"gesture": "Translate her sentence in your head first",
						"words": "Pause. Work it out. Answer late.",
						"say": "...Yes. Half a kilogram would be correct.",
						"style": "formal", "rep": -1},
					{"gesture": "Ask her to pick one language and stay in it",
						"words": "Hold up one finger.",
						"say": "Could you use just one of them? For me?",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Tum",    "word": "tum",    "language": "hindi"},
					{"text": "seekh",  "word": "seekh",  "language": "hindi"},
					{"text": "rahe",   "word": "rahe",   "language": "hindi"},
					{"text": "ho,",    "word": "ho",     "language": "hindi"},
					{"text": "good.",  "word": "good",   "language": "hindi"},
				],
				"responses": [
					{"gesture": "Take the compliment in the mix it was given in",
						"words": "Smile. Thank her in two languages.",
						"say": "Thank you. Shukriya. Both, apparently.",
						"style": "casual", "rep": 3},
					{"gesture": "Say what it cost to stop being tidy",
						"words": "Rub your face.",
						"say": "Every city so far wanted one language done properly.",
						"style": "direct", "rep": 2},
					{"gesture": "Apologise for the mess of it",
						"words": "Wince. Apologise.",
						"say": "Sorry - I know it comes out as a jumble.",
						"style": "formal", "rep": -2},
				],
			}],
		],
	},
}


# ── LA PAZ ────────────────────────────────────────────────────────────────────
# The last city. You cannot say a thing happened without saying how you know.

const LAPAZ := {
	"remedios": {
		"name": "Dona Remedios", "region": "elalto", "color": Color(0.52, 0.30, 0.36),
		"role": "potatoes and dried maize, 16 de Julio. Sixty-four. Marks every claim.",
		"head": "hat",
		"relationships": ["a stranger", "a customer", "the one who said it plainly"],
		"rounds": [
			[{
				"words": [
					{"text": "Dicen",  "word": "dicen",  "language": "spanish_bo"},
					{"text": "que",    "word": "que",    "language": "spanish_bo"},
					{"text": "vino",   "word": "vino",   "language": "spanish_bo"},
					{"text": "del",    "word": "del",    "language": "spanish_bo"},
					{"text": "cielo.", "word": "cielo",  "language": "spanish_bo"},
				],
				"responses": [
					{"gesture": "Notice she said DICEN, and that it matters",
						"words": "Point at her. Then at your ear.",
						"say": "They say. You did not say you saw it.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask who told her",
						"words": "Point at her. Then out at the market.",
						"say": "Who says? Somebody in particular?",
						"style": "casual", "rep": 2},
					{"gesture": "Deny it",
						"words": "Shake your head. Firmly.",
						"say": "Nothing came from the sky. People make things up.",
						"style": "indirect", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Y",      "word": "y",      "language": "spanish_bo"},
					{"text": "vos,",   "word": "vos",    "language": "spanish_bo"},
					{"text": "como",   "word": "como",   "language": "spanish_bo"},
					{"text": "sabes?", "word": "sabes",  "language": "spanish_bo"},
				],
				"responses": [
					{"gesture": "Say it the only way the grammar allows",
						"words": "Touch the scar. Point at the sky. Then at yourself.",
						"say": "I saw it myself. I was there. It was me.",
						"style": "direct", "rep": 4},
					{"gesture": "Say you heard it somewhere",
						"words": "Wave a hand vaguely.",
						"say": "Somebody mentioned it. I do not remember who.",
						"style": "indirect", "rep": -3},
					{"gesture": "Say you worked it out",
						"words": "Tap your temple.",
						"say": "I put it together. From the pieces. It follows.",
						"style": "casual", "rep": 0},
				],
			}],
		],
	},
	"mauricio": {
		"name": "Mauricio", "region": "sopocachi", "color": Color(0.32, 0.40, 0.50),
		"role": "cable car operator, Linea Amarilla. Thirty-nine. Asks how you know.",
		"head": "cap",
		"relationships": ["a passenger", "a passenger", "somebody with a story"],
		"rounds": [
			[{
				"words": [
					{"text": "De",     "word": "de",     "language": "spanish_bo"},
					{"text": "donde",  "word": "donde",  "language": "spanish_bo"},
					{"text": "eres,",  "word": "eres",   "language": "spanish_bo"},
					{"text": "pues?",  "word": "pues",   "language": "spanish_bo"},
				],
				"responses": [
					{"gesture": "Look out of the cabin at four thousand metres",
						"words": "Point up. Then further up.",
						"say": "Further than the top of this line goes.",
						"style": "indirect", "rep": 2},
					{"gesture": "Give the honest answer and mark it as witnessed",
						"words": "Point at yourself. Then at the sky. Firmly.",
						"say": "Somewhere I saw with my own eyes and can never point to.",
						"style": "direct", "rep": 3},
					{"gesture": "Name the last place you landed instead",
						"words": "Say a place name.",
						"say": "The airport. Before that, another airport. It is a long list.",
						"style": "casual", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Aqui",   "word": "aqui",   "language": "spanish_bo"},
					{"text": "hay",    "word": "hay",    "language": "spanish_bo"},
					{"text": "que",    "word": "que",    "language": "spanish_bo"},
					{"text": "decir",  "word": "decir",  "language": "spanish_bo"},
					{"text": "como",   "word": "como",   "language": "spanish_bo"},
					{"text": "lo",     "word": "lo",     "language": "spanish_bo"},
					{"text": "sabes.", "word": "sabes",  "language": "spanish_bo"},
				],
				"responses": [
					{"gesture": "Accept that the grammar will not let you hide",
						"words": "Nod. Slowly.",
						"say": "Fifteen cities and none of them made me say it.",
						"style": "direct", "rep": 4},
					{"gesture": "Ask whether anyone ever gets it wrong on purpose",
						"words": "Tilt your head. Point at your mouth.",
						"say": "Can you lie with it? Mark a guess as a thing you saw?",
						"style": "casual", "rep": 2},
					{"gesture": "Say nothing all the way down",
						"words": "Watch the city come up at you.",
						"say": "...",
						"style": "indirect", "rep": 0},
				],
			}],
		],
	},
}


# ── Dispatch ──────────────────────────────────────────────────────────────────

# The three American cities live in their own file; this one is already
# at the size the project allows.
const AMERICA := preload("res://scenes/npc/CityNPCsAmerica.gd")


static func roster(city: String) -> Dictionary:
	match city:
		"zurich":   return ZURICH
		"paris":    return PARIS
		"honolulu": return AMERICA.HONOLULU
		"newyork":  return AMERICA.NEWYORK
		"toronto":  return AMERICA.TORONTO
		"sydney":   return SYDNEY
		"hanoi":    return HANOI
		"tokyo":    return TOKYO
		"rome":     return ROME
		"moscow":   return MOSCOW
		"mexico":   return MEXICO
		"saopaulo": return SAOPAULO
		"dakar":    return DAKAR
		"tbilisi":  return TBILISI
		"seoul":    return SEOUL
		"mumbai":   return MUMBAI
		"lapaz":    return LAPAZ
		_:          return {}


# ── Paris ────────────────────────────────────────────────────────────────────
# The rule this city runs on is not vocabulary. You say bonjour before you say
# anything else, to anyone you address, every time. Skipping it is not brisk;
# it is the offence. Most of what visitors read as rudeness here is the reply
# to a greeting they did not give.
const PARIS := {
	"elodie": {
		"name": "Élodie", "region": "champdemars", "color": Color(0.36, 0.30, 0.44),
		"role": "runs the kiosk by the lawn. Has been asked for directions in nine languages today and greeted in none.",
		"head": "none",
		"relationships": ["a customer", "a customer", "the one who says it first"],
		"rounds": [
			[{
				"words": [
					{"text": "Bonjour.",   "word": "bonjour",  "language": "french"},
					{"text": "Je",         "word": "je",       "language": "french"},
					{"text": "vous",       "word": "vous",     "language": "french"},
					{"text": "écoute.",    "word": "ecoute",   "language": "french"},
				],
				"responses": [
					{"gesture": "Say it back before anything else",
						"words": "Bonjour.",
						"say": "Bonjour. And then the rest.",
						"style": "formal", "rep": 3},
					{"gesture": "Point at what you want",
						"words": "Point. Hold up one finger.",
						"say": "One of those, please.",
						"style": "direct", "rep": -2},
					{"gesture": "Smile and start explaining",
						"words": "Open your hands. Begin.",
						"say": "Sorry, I am looking for somewhere to sleep -",
						"style": "casual", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Voilà.",     "word": "voila",    "language": "french"},
					{"text": "Ce",         "word": "ce",       "language": "french"},
					{"text": "n'est",      "word": "nest",     "language": "french"},
					{"text": "pas",        "word": "pas",      "language": "french"},
					{"text": "compliqué.", "word": "complique", "language": "french"},
				],
				"responses": [
					{"gesture": "Agree that it is not complicated",
						"words": "Nod. Say it back.",
						"say": "No. It is one word and I did not say it.",
						"style": "direct", "rep": 3},
					{"gesture": "Apologise at length",
						"words": "Hands up. Keep going.",
						"say": "I am sorry, I did not know, I did not mean -",
						"style": "formal", "rep": 0},
					{"gesture": "Ask her to teach you the rest",
						"words": "Point at your mouth. Then at her.",
						"say": "What else am I supposed to say first?",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
	"karim": {
		"name": "Karim", "region": "marais", "color": Color(0.30, 0.34, 0.30),
		"role": "sells second-hand books off a trestle. Decides in one sentence whether you get vous or tu, and never explains which.",
		"head": "cap",
		"relationships": ["a browser", "a browser", "someone he says tu to"],
		"rounds": [
			[{
				"words": [
					{"text": "Vous",       "word": "vous",     "language": "french"},
					{"text": "cherchez",   "word": "cherchez", "language": "french"},
					{"text": "quelque",    "word": "quelque",  "language": "french"},
					{"text": "chose",      "word": "chose",    "language": "french"},
					{"text": "monsieur?",  "word": "monsieur", "language": "french"},
				],
				"responses": [
					{"gesture": "Answer him the same way he addressed you",
						"words": "Vous. Merci.",
						"say": "Not yet. Thank you - the formal one, back at him.",
						"style": "formal", "rep": 3},
					{"gesture": "Use the short word you heard a child use",
						"words": "Tu.",
						"say": "Tu. It was shorter so it seemed easier.",
						"style": "casual", "rep": -2},
					{"gesture": "Avoid choosing at all",
						"words": "Nod at the books. Say nothing.",
						"say": "Just looking. No pronoun, no risk.",
						"style": "indirect", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Tu",         "word": "tu",       "language": "french"},
					{"text": "peux",       "word": "peux",     "language": "french"},
					{"text": "regarder,",  "word": "regarder", "language": "french"},
					{"text": "vas-y.",     "word": "vasy",     "language": "french"},
				],
				"responses": [
					{"gesture": "Notice that the word changed and follow him",
						"words": "Tu. Merci.",
						"say": "He moved first. So I move with him.",
						"style": "casual", "rep": 3},
					{"gesture": "Stay formal to be safe",
						"words": "Vous. Merci.",
						"say": "Vous, still. It is politer and it is now wrong.",
						"style": "formal", "rep": -1},
					{"gesture": "Ask him outright which one you should use",
						"words": "Point at him. Then at yourself.",
						"say": "Which of the two words am I allowed?",
						"style": "direct", "rep": 1},
				],
			}],
		],
	},
}


# ── Sydney ───────────────────────────────────────────────────────────────────
# The second city on the board where the alien can read every sign, and the
# second time that turns out not to help. Australian English runs on
# diminutives and on sentences that are shaped like questions and are not
# ones. "How are you going" is a greeting. "Yeah nah" is no. "Nah yeah" is
# yes. None of that is written down anywhere.
const SYDNEY := {
	"jen": {
		"name": "Jen", "region": "circularquay", "color": Color(0.24, 0.38, 0.40),
		"role": "works the ferry wharf. Uses your first name from the first sentence and shortens every word she can.",
		"head": "cap",
		"relationships": ["a passenger", "a passenger", "mate"],
		"rounds": [
			[{
				"words": [
					{"text": "How",     "word": "how",     "language": "english"},
					{"text": "ya",      "word": "ya",      "language": "english"},
					{"text": "going,",  "word": "going",   "language": "english"},
					{"text": "mate?",   "word": "mate",    "language": "english"},
				],
				"responses": [
					{"gesture": "Answer it as a greeting, not a question",
						"words": "Good thanks. You?",
						"say": "Good, thanks - and bounce it straight back.",
						"style": "casual", "rep": 3},
					{"gesture": "Tell her how you are actually going",
						"words": "Begin. Be honest.",
						"say": "Badly. I have been here four hours and I -",
						"style": "direct", "rep": -1},
					{"gesture": "Ask where you are going",
						"words": "Point at the boat. Then at yourself.",
						"say": "Sorry - where does this one go?",
						"style": "formal", "rep": 0},
				],
			}],
			[{
				"words": [
					{"text": "Yeah",    "word": "yeah",    "language": "english"},
					{"text": "nah",     "word": "nah",     "language": "english"},
					{"text": "you're",  "word": "youre",   "language": "english"},
					{"text": "right,",  "word": "right",   "language": "english"},
					{"text": "no",      "word": "no",      "language": "english"},
					{"text": "worries.", "word": "worries", "language": "english"},
				],
				"responses": [
					{"gesture": "Take the whole thing as a no",
						"words": "Nod. Step back.",
						"say": "Yeah nah is no. The yeah is just packaging.",
						"style": "casual", "rep": 3},
					{"gesture": "Take it as a yes and get on",
						"words": "Step forward.",
						"say": "She said yeah. I heard yeah. I am getting on.",
						"style": "direct", "rep": -2},
					{"gesture": "Ask which half of that was the answer",
						"words": "Hold up two fingers. Point at each.",
						"say": "Was that a yes or was that a no?",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
	"thuy": {
		"name": "Thuy", "region": "cbd", "color": Color(0.40, 0.30, 0.32),
		"role": "works in one of the towers, grew up forty minutes west. Has answered the same question about where she is from since primary school.",
		"head": "none",
		"relationships": ["a stranger", "a stranger", "someone who asked properly"],
		"rounds": [
			[{
				"words": [
					{"text": "You",      "word": "you",      "language": "english"},
					{"text": "right",    "word": "right",    "language": "english"},
					{"text": "there?",   "word": "there",    "language": "english"},
				],
				"responses": [
					{"gesture": "Understand that this is an offer of help",
						"words": "Yes - thanks. Actually, no.",
						"say": "It is not about whether I am correct. She is asking if I need something.",
						"style": "casual", "rep": 3},
					{"gesture": "Confirm that you are, in fact, correct",
						"words": "Nod firmly.",
						"say": "Yes. I am right. About what?",
						"style": "direct", "rep": -1},
					{"gesture": "Ask her where she is from",
						"words": "Point at her. Open your hands.",
						"say": "Where are you from? It seems like the friendly question.",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Born",     "word": "born",     "language": "english"},
					{"text": "here.",    "word": "here",     "language": "english"},
					{"text": "Cabra.",   "word": "cabra",    "language": "english"},
					{"text": "Forty",    "word": "forty",    "language": "english"},
					{"text": "minutes",  "word": "minutes",  "language": "english"},
					{"text": "that",     "word": "that",     "language": "english"},
					{"text": "way.",     "word": "way",      "language": "english"},
				],
				"responses": [
					{"gesture": "Accept the answer she gave you",
						"words": "Nod. Leave it there.",
						"say": "West of here. That is the answer to the question I asked.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask where she is really from",
						"words": "Shake your head. Ask again.",
						"say": "No, but originally -",
						"style": "casual", "rep": -3},
					{"gesture": "Ask what is out that way",
						"words": "Point west. Raise your eyebrows.",
						"say": "What is out there? I have not been.",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
}
