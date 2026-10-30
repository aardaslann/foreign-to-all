extends Object

# Berlin, chapters three and four, and the small things people say when there
# is no chapter to play. One and two, and the reasoning behind all of it, are
# in BerlinScript.gd.
#
# Three is the errand, and it is two scenes in two districts: Emil on his bench
# in Prenzlauer Berg, and then Kerstin, who wants to know what he said. The
# second scene is the test the whole city has been building to, and it does not
# look like one. He carries a sentence across town in a language he has had for
# three days, and what arrives is whatever he actually understood.
#
# Four is Saturday. The dirndl, Emil, the chair, and the Wiesn.

const S := preload("res://scenes/story/berlin/BerlinScript.gd")

# Prenzlauer Berg: the bench by the playground railings, clear of the stalls and of the neighbours who stand by them.
const BENCH := [1048, 500]
const EMIL_SEAT := [1048, 504]
# Mitte, after Saturday: his own chair, next to the new one's.
const EMIL_CHAIR := [84, 478]


const CHAPTERS := {

# ── Three · Für Emil ──────────────────────────────────────────────────────────
"3": [
	{"do": "label", "name": "start", "save": true},
	{"do": "prop", "id": "bench", "kind": "bench", "at": BENCH},
	{"do": "actor", "id": "emil", "at": EMIL_SEAT, "act": "sit"},
	{"do": "ask", "id": "emil",
		"stage": "An old man on the bench by the playground, one leg stretched straight out in front of him. He looks at the bag in your hands, then at you, and does not smile.",
		"say": "Wat soll dit? Ick kenn Se nich.",
		"options": [
			{"gesture": "Say the name she gave you, and hold out the bag", "words": "Von Kerstin.",
				"say": "Von Kerstin. Für Sie.", "style": "direct", "rep": 3,
				"confirm": {"von": "from. \"von Kerstin\" was the whole explanation, and it was enough"},
				"go": "from_k"},
			{"gesture": "Hold out the bag, and a coin as well", "style": "formal", "rep": -1,
				"misread": {"soll": "I thought he was asking what it cost"},
				"go": "charity"},
			{"gesture": "Put the bag on the bench and step back", "style": "indirect", "rep": 0,
				"go": "left_it"},
		]},
	{"do": "label", "name": "charity"},
	{"do": "line", "id": "emil", "say": "Ick brauch keen Almosen, junger Mann.", "act": "recoil"},
	{"do": "think", "text": "He did not raise his voice. He did not need to. I had made it look as though somebody felt sorry for him, and that was the one thing in the bag he did not want."},
	{"do": "ask", "id": "emil",
		"stage": "He has not taken the bag. He is waiting for a better reason than pity.",
		"say": "Von wem is dit?",
		"options": [
			{"gesture": "Say her name, and point back the way you came", "words": "Kerstin.",
				"style": "direct", "rep": 2,
				"confirm": {"wem": "whom. he asked who it was from, and the answer changed everything"},
				"go": "from_k"},
			{"gesture": "Shrug", "style": "indirect", "rep": 0, "go": "paper"},
		]},
	{"do": "label", "name": "left_it"},
	{"do": "line", "id": "emil", "say": "Hallo! Junger Mann! Wat is dit?", "act": "wave"},
	{"do": "label", "name": "paper"},
	{"do": "act", "id": "emil", "act": "look", "secs": 1.0, "then": "sit"},
	{"do": "line", "id": "emil", "say": "Die Zeitung. Dit is Kerstin.", "act": "sit"},
	{"do": "think", "text": "He knew who it was from by the newspaper. She sends the one he reads. Nobody had to explain anything to anybody; the paper did it."},

	{"do": "label", "name": "from_k", "save": true},
	{"do": "cue", "call": "take_bag"},
	{"do": "hold", "id": "emil", "prop": "bag"},
	{"do": "line", "id": "emil", "say": "Kerstin. Die Olle.", "act": "sit"},
	{"do": "think", "text": "He says her name the way you say the name of a street you grew up on."},
	{"do": "ask", "id": "emil",
		"stage": "He taps his knee, then points across the square at the U-Bahn entrance, and makes a face at the stairs going down.",
		"say": "Dit Knie. Die Treppen am Senefelderplatz. Deswegen komm ick nich.",
		"options": [
			{"gesture": "Nod at his knee. Say nothing", "style": "indirect", "rep": 2,
				"confirm": {"knie": "knee. he tapped it", "treppen": "stairs. he made a face at them"},
				"go": "message"},
			{"gesture": "Point at his knee, then at the stairs, and ask", "words": "Das Knie?",
				"say": "Das Knie? Wegen der Treppen?", "style": "direct", "rep": 2,
				"confirm": {"knie": "knee. he tapped it", "treppen": "stairs. he made a face at them"},
				"go": "message"},
		]},

	{"do": "label", "name": "message", "save": true},
	{"do": "ask", "id": "emil", "silent": true,
		"stage": "He holds up six fingers, then taps the last square in a row printed on the back of his newspaper. Then he points at you, and back the way you came.",
		"say": "Sagen Se Kerstin: Samstag komm ick. Knie hin oder her.",
		"options": [
			{"gesture": "Nod. You will tell her", "words": "Samstag. Ja.", "style": "direct", "rep": 2,
				"confirm": {"samstag": "saturday. six fingers, the last square before the week turns over"},
				"set": {"relay": "samstag"}, "go": "duzen"},
			{"gesture": "Nod, though all you really caught was the knee", "style": "casual", "rep": 1,
				"set": {"relay": "knie"}, "go": "duzen"},
		]},

	{"do": "label", "name": "duzen", "save": true},
	{"do": "ask", "id": "emil", "silent": true,
		"stage": "He holds out his hand. Not for anything. To shake.",
		"say": "Ick bin Emil. Wir können uns ruhig duzen.",
		"options": [
			{"gesture": "Shake his hand", "words": "Emil. Gerne.", "style": "direct", "rep": 3,
				"confirm": {"duzen": "to call each other du. he offered it, and it was his to offer",
					"emil": "his name. said with his hand out"},
				"set": {"emil_du": true}, "register": "du", "go": "du_yes"},
			{"gesture": "Shake his hand, but stay with Sie to be safe", "style": "formal", "rep": -2,
				"confirm": {"emil": "his name. said with his hand out"},
				"go": "du_no"},
		]},
	{"do": "label", "name": "du_yes"},
	{"do": "think", "text": "An old man on a bench has made me, formally, somebody he knows. It took one handshake. Kerstin began with du. Emil wanted to offer it himself. I had mistaken two people for one rule."},
	{"do": "goto", "to": "done"},
	{"do": "label", "name": "du_no"},
	{"do": "line", "id": "emil", "say": "Na, wie Se wollen.", "act": "sit"},
	{"do": "think", "text": "I kept Sie because I meant respect. Emil heard distance. He let it pass, but next time I can remember what he asked to be called."},
	{"do": "label", "name": "done"},
	{"do": "line", "id": "emil", "say": "Grüß Kerstin.", "act": "wave"},
	{"do": "memory", "title": "Emil",
		"text": "Emil drove trams for thirty-one years and now his knee will not do the stairs at Senefelderplatz. He would not take the bag until he knew who it was from. He sent a message back with me, and I carried it as far as I understood it."},
	{"do": "cue", "call": "errand_done"},
	{"do": "end"},
],

# ── Three, continued · Und? ───────────────────────────────────────────────────
"3b": [
	{"do": "label", "name": "start", "save": true},
	{"do": "actor", "id": "kerstin", "at": S.K, "act": "look"},
	{"do": "ask", "id": "kerstin", "silent": true,
		"stage": "She is watching the corner where the U-Bahn comes up. She looks at your empty hands - the bag has gone - and then at your face.",
		"say": "Und? Wat sagt er?",
		"options": [
			{"gesture": "Hold up six fingers, the way he did", "words": "Samstag. Er kommt.",
				"say": "Samstag. Emil kommt am Samstag.", "style": "direct", "rep": 3,
				"if": {"relay": "samstag"}, "go": "right"},
			{"gesture": "Tap your knee, and make a face at the ground", "style": "indirect", "rep": 1,
				"go": "knee"},
			{"gesture": "Shrug. You gave him the bag", "style": "casual", "rep": 0, "go": "shrug"},
		]},
	{"do": "label", "name": "right"},
	{"do": "line", "id": "kerstin", "say": "Samstag? Echt?", "act": "look"},
	{"do": "line", "id": "kerstin", "say": "Na, denn.", "act": "nod"},
	{"do": "think", "text": "She smiled. I did not know her face did that. I carried one word across the city for her, and it arrived."},
	{"do": "goto", "to": "ok"},
	{"do": "label", "name": "knee"},
	{"do": "line", "id": "kerstin", "say": "Dit Knie. Ick weeß.", "act": "look"},
	{"do": "line", "id": "kerstin", "say": "Denn hol ick ihn ab. Samstag.", "act": "nod"},
	{"do": "set", "flag": "fetch_emil"},
	{"do": "think", "text": "I brought back the knee, and she heard the rest of it anyway: the stairs, the week, the reason. She is going to fetch him. I did not know a knee could carry that much."},
	{"do": "goto", "to": "ok"},
	{"do": "label", "name": "shrug"},
	{"do": "line", "id": "kerstin", "say": "Hat er se jenommen? Die Tüte?", "act": "look"},
	{"do": "line", "id": "kerstin", "say": "Na, immerhin.", "act": "nod"},
	{"do": "set", "flag": "fetch_emil"},
	{"do": "label", "name": "ok"},
	{"do": "line", "id": "kerstin", "say": "Samstag is Wiesn. Erst schlafen, wa.", "act": "point"},
	{"do": "cue", "call": "chapter_done"},
	{"do": "end"},
],

# ── Four · Samstag ────────────────────────────────────────────────────────────
"4": [
	{"do": "label", "name": "start", "save": true},
	{"do": "prop", "id": "chair", "kind": "chair", "at": S.CHAIR},
	{"do": "actor", "id": "kerstin", "at": S.K, "act": "stand", "outfit": "dirndl"},
	{"do": "if", "flag": "fetch_emil", "then": "with_emil", "else": "dress"},
	{"do": "label", "name": "with_emil"},
	{"do": "actor", "id": "emil", "at": [312, 480], "act": "stand"},
	{"do": "label", "name": "dress"},
	{"do": "ask", "id": "kerstin",
		"stage": "Kerstin is wearing a dress with a laced bodice and a white apron, and she is standing in it the way you stand in the rain.",
		"say": "Guck nich so. Dit is'n Dirndl. Von meener Schwester aus München.",
		"options": [
			{"gesture": "Tell her she looks good", "words": "Gut!", "say": "Sieht gut aus.",
				"style": "casual", "rep": 1, "go": "compliment"},
			{"gesture": "Look at the dress, then at the street, and raise your eyebrows",
				"style": "direct", "rep": 2, "go": "eyebrows"},
			{"gesture": "Say nothing, and keep staring", "style": "indirect", "rep": -1, "go": "stare"},
		]},
	{"do": "label", "name": "compliment"},
	{"do": "line", "id": "kerstin", "say": "Hör uff. Ick seh aus wie ne Kuckucksuhr.", "act": "look"},
	{"do": "think", "text": "I told her she looked good, and she told me to stop, and she has not stopped smiling. I am learning that here both of those can be true at once."},
	{"do": "goto", "to": "wiesn"},
	{"do": "label", "name": "eyebrows"},
	{"do": "line", "id": "kerstin", "say": "Jenau. Ick seh aus wie ne Kuckucksuhr.", "act": "wave"},
	{"do": "think", "text": "Agreeing with her was the compliment. I will not pretend I understand why."},
	{"do": "goto", "to": "wiesn"},
	{"do": "label", "name": "stare"},
	{"do": "line", "id": "kerstin", "say": "Wat? Sag wat!", "act": "recoil"},
	{"do": "line", "id": "kerstin", "say": "Ick seh aus wie ne Kuckucksuhr, ick weeß.", "act": "look"},

	{"do": "label", "name": "wiesn", "save": true},
	{"do": "ask", "id": "kerstin",
		"stage": "She taps a calendar taped inside the shop door - today's square has a ring drawn round it - then points at you, then at the U-Bahn.",
		"say": "Heute is Samstag. Wiesn. Kommste mit?",
		"options": [
			{"gesture": "Nod, before you know what a Wiesn is", "words": "Ja!", "style": "casual",
				"rep": 3, "ritual": "accept",
				"confirm": {"kommste": "\"kommst du\" - are you coming. squeezed into one word",
					"mit": "with. along"},
				"go": "emil_comes"},
			{"gesture": "Ask what a Wiesn is", "words": "Wiesn?", "say": "Was ist eine Wiesn?",
				"style": "direct", "rep": 2, "go": "what"},
		]},
	{"do": "label", "name": "what"},
	{"do": "line", "id": "kerstin", "say": "Oktoberfest. Bier, Blasmusik, Lederhosen.", "act": "look"},
	{"do": "line", "id": "kerstin", "say": "Dit is nich unsa. Dit is Bayern. Aber jut.", "act": "nod"},
	{"do": "understand", "word": "wiesn", "meaning": "the Oktoberfest. she says it is not theirs, and goes anyway"},

	{"do": "label", "name": "emil_comes"},
	{"do": "if", "flag": "fetch_emil", "then": "emil_here"},
	{"do": "actor", "id": "emil", "at": S.UBAHN, "act": "stand"},
	{"do": "walk", "id": "emil", "to": [312, 480], "pace": 30.0},
	{"do": "line", "id": "emil", "say": "Morjen, Kerstin. Morjen, Neuer.", "act": "wave"},
	{"do": "line", "id": "kerstin", "say": "Na endlich!", "act": "wave"},
	{"do": "think", "text": "He came. He points at the bus, then at the folding seat he brought for the wait. He found a route his knee could manage. I carried Saturday back to Kerstin, and now there is somebody waiting for him."},
	{"do": "goto", "to": "chair"},
	{"do": "label", "name": "emil_here"},
	{"do": "line", "id": "emil", "say": "Morjen, Neuer.", "act": "wave"},
	{"do": "line", "id": "kerstin", "say": "Hab ihn abjeholt.", "act": "nod"},

	{"do": "label", "name": "chair", "save": true},
	{"do": "ask", "id": "kerstin", "silent": true,
		"stage": "Kerstin looks at Emil's knee, then at your chair by the window, then at you.",
		"say": "Emil braucht nen Stuhl. Nimmste den mit?",
		"options": [
			{"gesture": "Fold up your chair and pick it up", "style": "direct", "rep": 2,
				"confirm": {"stuhl": "chair. mine, and then his"}, "go": "carry"},
			{"gesture": "Offer Emil your arm instead", "style": "indirect", "rep": 2, "go": "arm"},
		]},
	{"do": "label", "name": "arm"},
	{"do": "line", "id": "emil", "say": "Dit Knie is nich so schlimm.", "act": "look"},
	{"do": "line", "id": "kerstin", "say": "Beides. Arm und Stuhl.", "act": "point"},
	{"do": "understand", "word": "stuhl", "meaning": "chair. she wanted both - the arm and the chair"},

	{"do": "label", "name": "carry", "save": true},
	{"do": "prop", "id": "chair", "kind": "chair", "at": S.CHAIR, "carryable": true},
	{"do": "walk", "id": "kerstin", "to": [560, 492], "pace": 34.0, "wait": false},
	{"do": "walk", "id": "emil", "to": [540, 500], "pace": 26.0, "wait": false},
	{"do": "carry", "props": ["chair"], "to": S.UBAHN, "radius": 40,
		"hint": "Carry the chair to the U-Bahn. They are going at Emil's pace"},
	{"do": "label", "name": "celebration", "save": true},
	{"do": "cue", "call": "holiday"},
	{"do": "cue", "call": "holiday_done"},
	{"do": "think", "text": "There is a chair outside a shop on a corner in Berlin with a strip of tape across the back, and on the tape, in marker pen, it says DER NEUE. It is not a name. It is the only one I have ever had, and somebody wrote it down."},
	{"do": "memory", "title": "Samstag",
		"text": "Kerstin wore her sister's dirndl and said the whole way there that it was not hers. Emil sat on the chair I carried and told a stranger about the M10. On the way home she wrote DER NEUE on a strip of tape and put it on my chair, next to one that says EMIL."},
	{"do": "end"},
],

# ── When there is no chapter ──────────────────────────────────────────────────
"wait_morgen": [
	{"do": "line", "id": "kerstin", "say": "Morgen, Neuer. Erst schlafen.", "act": "point"},
],
"wait_emil": [
	{"do": "cue", "call": "give_bag"},
	{"do": "line", "id": "kerstin", "say": "Kollwitzplatz. Emil. Die Tüte.", "act": "point"},
],
"wait_saturday": [
	{"do": "line", "id": "kerstin", "say": "Samstag, wa. Erst schlafen.", "act": "wave"},
],
"after": [
	{"do": "cue", "call": "after_line"},
],
"emil_waiting": [
	{"do": "line", "id": "emil", "say": "Grüß Kerstin. Samstag.", "act": "wave"},
],
"emil_after": [
	{"do": "line", "id": "emil", "say": "Setz dir, Neuer. Is dein Stuhl.", "act": "sit"},
],
}


# What she says in passing once the chapters are done. Short, and in the same
# words he has spent four days learning, so every one of them now reads.
const AFTER := [
	"Na, Neuer!",
	"Kaffee? Schwarz, wa.",
	"Allet jut?",
	"Emil war heute schon da.",
	"Setz dir, Neuer.",
	"Morgen, Neuer.",
]
