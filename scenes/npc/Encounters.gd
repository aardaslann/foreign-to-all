extends Object

# The people who come to YOU.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# Every person in this game waits. You walk up, you press E, and they respond -
# which means the entire social world of a game about not belonging anywhere is
# opt-in. Nothing has ever happened to this character that he did not press a
# button to cause.
#
# So: eight people who notice him first. A mark goes up over their head, they
# walk over, and the conversation opens whether he wanted it or not. It is the
# oldest trick in the genre - a trainer seeing you from across a room - and it
# is doing something specific here: being approached in a language you cannot
# speak is the situation this whole game is about, and the player has never
# once been in it.
#
# ── The rule for what they are about ─────────────────────────────────────────
#
# Not one of them is hostile and not one of them is a fight. Each is an
# ordinary misunderstanding a local would resolve in four seconds and the alien
# has no words for: a man with the wrong key, a bin put out on the wrong night,
# a shopkeeper who saw you eating in the street. The way out is either an
# object you are carrying or a word you have learned, and never a correct
# answer you could have guessed.
#
# ── Fields ───────────────────────────────────────────────────────────────────
#
#   city, region   where they happen
#   flag           world_flags key; set once it is over, so it happens once
#   needs          world_flags key that must be true first, or ""
#   mark           what floats over their head
#   look           an id in CastRoster, so they are designed like everybody else
#   lines          the conversation, in DialogueBox's own shape
#
# A response may carry `requires_item`, which hides it unless the thing is in
# his hands - showing the room card is not an option if he has not got it.

const ALL := {

# ── Berlin ───────────────────────────────────────────────────────────────────
# A man is standing in room 304 with a key card that used to work, and both of
# them are completely certain.
"berlin_room": {
	"city": "berlin", "region": "mitte", "flag": "enc_berlin_room",
	"needs": "", "mark": "!", "look": "neumann",
	"name": "A man in your room", "relationship": "Fremder",
	"lines": [
		{
			"words": [
				{"text": "Was",     "word": "was",    "language": "german"},
				{"text": "machen",  "word": "machen", "language": "german"},
				{"text": "Sie",     "word": "sie",    "language": "german"},
				{"text": "hier?",   "word": "hier",   "language": "german"},
				{"text": "Das",     "word": "das",    "language": "german"},
				{"text": "ist",     "word": "ist",    "language": "german"},
				{"text": "mein",    "word": "mein",   "language": "german"},
				{"text": "Zimmer!", "word": "zimmer", "language": "german"},
			],
			"responses": [
				{"text": "Hold up the card. Three digits, and one of them is his",
					"words": "Card. Drei null vier.",
					"say": "Drei null vier. Dieses Zimmer.",
					"style": "direct", "rep": 2, "requires_item": "zimmerkarte",
					"action": "flag:enc_berlin_room"},
				{"text": "Point at the door, then at yourself, twice",
					"words": "Door. Me. Door. Me.",
					"say": "This room. Mine. I am sorry.",
					"style": "gesture", "rep": 1},
				{"text": "Back out into the corridor and check the number again",
					"words": "Step back. Look up.",
					"say": "Let me check. I may have the wrong floor.",
					"style": "indirect", "rep": -1},
			],
		},
		{
			"words": [
				{"text": "Ach",       "word": "ach",       "language": "german"},
				{"text": "so.",       "word": "so",        "language": "german"},
				{"text": "Entschuldigung.", "word": "entschuldigung", "language": "german"},
				{"text": "Letzte",    "word": "letzte",    "language": "german"},
				{"text": "Woche",     "word": "woche",     "language": "german"},
				{"text": "war",       "word": "war",       "language": "german"},
				{"text": "das",       "word": "das",       "language": "german"},
				{"text": "meins.",    "word": "meins",     "language": "german"},
			],
			"responses": [
				{"text": "Nod. It is a mistake anybody could make",
					"words": "Nod. Shrug.",
					"say": "It happens. No harm done.",
					"style": "casual", "rep": 2,
					"action": "flag:enc_berlin_room"},
				# The option IS the word. Offering it to somebody who has not
				# got the word would be the game promising a sentence on his
				# behalf and then failing to have it, so it is simply not
				# there until "danke" is - which is the first word anybody
				# picks up in this city, so it arrives early.
				{"text": "Say the one word you are sure of",
					"words": "Danke.", "say": "Danke schön.",
					"style": "formal", "rep": 1, "requires_word": "danke",
					"action": "flag:enc_berlin_room"},
				{"text": "Hold the door open and wait",
					"words": "Open door. Wait.",
					"say": "After you.",
					"style": "gesture", "rep": 1,
					"action": "flag:enc_berlin_room"},
			],
		},
	],
},

# ── London ───────────────────────────────────────────────────────────────────
# The bins. Four doors down, and she has been waiting a week to say this.
"london_bins": {
	"city": "london", "region": "terrace", "flag": "enc_london_bins",
	"needs": "", "mark": "!", "look": "bins_woman",
	"name": "Woman from number nine", "relationship": "neighbour",
	"lines": [
		{
			"words": [
				{"text": "Sorry,",      "word": "sorry",      "language": "english"},
				{"text": "you",         "word": "you",        "language": "english"},
				{"text": "alright?",    "word": "alright",    "language": "english"},
				{"text": "It's",        "word": "it",         "language": "english"},
				{"text": "just",        "word": "just",       "language": "english"},
				{"text": "the",         "word": "the",        "language": "english"},
				{"text": "recycling",   "word": "recycling",  "language": "english"},
				{"text": "goes",        "word": "goes",       "language": "english"},
				{"text": "Tuesday.",    "word": "tuesday",    "language": "english"},
			],
			"responses": [
				{"text": "Say sorry. It appears to be the correct move here",
					"words": "Sorry. Sorry.",
					"say": "Sorry - I did not know. Tuesday. Got it.",
					"style": "casual", "rep": 2,
					"action": "flag:enc_london_bins"},
				{"text": "Take the bin back in while she watches",
					"words": "Pick up bin. Carry it back.",
					"say": "I will move it now.",
					"style": "direct", "rep": 2,
					"action": "flag:enc_london_bins"},
				{"text": "Answer the question she opened with, honestly",
					"words": "Point at yourself. Shake head.",
					"say": "Not really, no. It has been a strange week.",
					"style": "direct", "rep": -2,
					"action": "flag:enc_london_bins"},
			],
		},
	],
},

# ── Sao Paulo ────────────────────────────────────────────────────────────────
# She has met him once, which is enough, and she greets him the way you greet
# somebody you have met once: a hand on the shoulder and a kiss on the cheek.
#
# The detail is real and Brazilians tease each other about it: it is ONE kiss
# in Sao Paulo and two in Rio, and more in parts of Minas. So the alien is not
# only being touched by a near-stranger, he is being touched a specific number
# of times, and going for a second one is a joke she will make for a year.
#
# The way out is not a correct answer. It is standing still.
"saopaulo_beijinho": {
	"city": "saopaulo", "region": "vilamadalena", "flag": "enc_saopaulo_beijinho",
	"needs": "", "mark": "!", "look": "beijo_woman",
	"name": "Somebody who has met you once", "relationship": "amiga",
	"lines": [
		{
			"words": [
				{"text": "Oi!",     "word": "oi",     "language": "portuguese"},
				{"text": "Tudo",    "word": "tudo",   "language": "portuguese"},
				{"text": "bem?",    "word": "bem",    "language": "portuguese"},
				{"text": "Chega",   "word": "chega",  "language": "portuguese"},
				{"text": "aqui,",   "word": "aqui",   "language": "portuguese"},
				{"text": "relaxa.", "word": "relaxa", "language": "portuguese"},
			],
			"responses": [
				{"text": "Stand still and let it happen. One side, once",
					"words": "Stand still. Lean in.",
					"say": "Oi. Tudo bem.",
					"style": "casual", "rep": 3,
					"action": "flag:enc_saopaulo_beijinho"},
				{"text": "Go for the second cheek too",
					"words": "Turn head. Second side. Nobody there.",
					"say": "Oh - sorry. Sorry. Wrong number.",
					"style": "indirect", "rep": 1,
					"action": "flag:enc_saopaulo_beijinho"},
				{"text": "Put out a hand to shake instead, at arm's length",
					"words": "Hold out hand. Elbow locked.",
					"say": "Good afternoon. It is good to see you again.",
					"style": "formal", "rep": -2,
					"action": "flag:enc_saopaulo_beijinho"},
			],
		},
	],
},

# ── Zurich ───────────────────────────────────────────────────────────────────
# Sunday, in Seefeld, and he is doing an ordinary loud thing at an ordinary
# hour. She is not angry and she is not going to argue: Sonntagsruhe is a real
# rule, it is written on the notice in every entrance hall in the country, and
# it is a law rather than a preference.
#
# The whole encounter is one joke and the joke is this city's thesis. He read
# that notice on his first day. It is in Hochdeutsch. He understood every
# single word of it. Understanding the words was not the same as knowing it
# was a rule, that it was about him, and that it started at midnight.
#
# She says it in dialect, because annoyed people do not accommodate anybody,
# and the way out is either the written word he already has or six syllables
# of hers. Asking her to switch works perfectly and costs him the street.
"zurich_sonntag": {
	"city": "zurich", "region": "seefeld", "flag": "enc_zurich_sonntag",
	"needs": "", "mark": "!", "look": "sunntig_frau",
	"name": "A woman from the first floor", "relationship": "Nachbarin",
	"lines": [
		{
			"words": [
				{"text": "Sunntig,", "word": "sunntig", "language": "swissgerman"},
				{"text": "gell.",    "word": "gell",    "language": "swissgerman"},
				{"text": "So",       "word": "so",      "language": "swissgerman"},
				{"text": "macht",    "word": "macht",   "language": "swissgerman"},
				{"text": "me",       "word": "me",      "language": "swissgerman"},
				{"text": "das",      "word": "das",     "language": "swissgerman"},
				{"text": "nöd.",     "word": "noed",    "language": "swissgerman"},
			],
			"responses": [
				{"text": "Stop. Put it down. Say her one word back to her",
					"words": "Sunntig.",
					"say": "Sunday. Yes. Sunday.",
					"style": "casual", "rep": 2,
					"action": "flag:enc_zurich_sonntag"},
				{"text": "Point back at the notice in the hall. You have read it",
					"words": "Point. Sonntagsruhe.",
					"say": "It is written up there. I read it on my first day and I understood every word of it.",
					"style": "direct", "rep": 2,
					"action": "flag:enc_zurich_sonntag"},
				{"text": "Ask her, in the German you have, what the matter is",
					"words": "Entschuldigung. Ich kann nicht verstehen.",
					"say": "Excuse me. I cannot understand. What is wrong?",
					"style": "formal", "rep": -1,
					"action": "flag:enc_zurich_sonntag"},
			],
		},
	],
},

# ── Paris ────────────────────────────────────────────────────────────────────
# He is not angry. He is correcting something, once, and then it is over.
"paris_bonjour": {
	"city": "paris", "region": "marais", "flag": "enc_paris_bonjour",
	"needs": "", "mark": "!", "look": "bonjour_man",
	"name": "The man behind the counter", "relationship": "monsieur",
	"lines": [
		{
			"words": [
				{"text": "Monsieur.",  "word": "monsieur", "language": "french"},
				{"text": "On",         "word": "on",       "language": "french"},
				{"text": "dit",        "word": "dit",      "language": "french"},
				{"text": "bonjour.",   "word": "bonjour",  "language": "french"},
			],
			"responses": [
				{"text": "Say it. Just the one word, and mean it",
					"words": "Bonjour.", "say": "Bonjour, monsieur. Pardon.",
					"style": "formal", "rep": 3,
					"action": "flag:enc_paris_bonjour"},
				# He has just been told the word, so he can say the word - and
				# the rest of the sentence waits until it is his. "Un" is the
				# whole difference between the two lower phrasings here.
				{"text": "Say it while already asking for the thing you came for",
					"gesture": "Bonjour. Then point at the coffee.",
					"words": "Bonjour - un cafe.",
					"say": "Bonjour, un cafe, s'il vous plait.",
					"style": "direct", "rep": 1,
					"action": "flag:enc_paris_bonjour"},
				{"text": "Apologise in a language he does not speak",
					"words": "Sorry. Sorry.",
					"say": "I am sorry, I did not realise.",
					"style": "indirect", "rep": -1,
					"action": "flag:enc_paris_bonjour"},
			],
		},
	],
},

# ── Moscow ───────────────────────────────────────────────────────────────────
# He needs both hands for four seconds and you are the nearest person.
"moscow_hold": {
	"city": "moscow", "region": "basmanny", "flag": "enc_moscow_hold",
	"needs": "", "mark": "!", "look": "hold_man",
	"name": "A man with a broken strap", "relationship": "nobody",
	"lines": [
		{
			"words": [
				{"text": "Slushayte.",  "word": "slushayte", "language": "russian"},
				{"text": "Derzhite",    "word": "derzhite",  "language": "russian"},
				{"text": "eto.",        "word": "eto",       "language": "russian"},
				{"text": "Sekundu.",    "word": "sekundu",   "language": "russian"},
			],
			"responses": [
				{"text": "Take it. Hold it. Say nothing",
					"words": "Take. Hold.", "say": "Of course.",
					"style": "direct", "rep": 2,
					"action": "flag:enc_moscow_hold"},
				{"text": "Take it and smile at him about it",
					"words": "Take. Smile.",
					"say": "Happy to help!",
					"style": "casual", "rep": -2,
					"action": "flag:enc_moscow_hold"},
				{"text": "Look at your hands, then at his, and take it anyway",
					"words": "Hesitate. Take.",
					"say": "I - yes. Alright.",
					"style": "indirect", "rep": 1,
					"action": "flag:enc_moscow_hold"},
			],
		},
	],
},

# ── Istanbul ─────────────────────────────────────────────────────────────────
# The tea you did not order and cannot refuse, which is the whole city.
"istanbul_cay": {
	"city": "istanbul", "region": "han", "flag": "enc_istanbul_cay",
	"needs": "", "mark": "!", "look": "cay_man",
	"name": "The shop two doors down", "relationship": "komsu",
	"lines": [
		{
			"words": [
				{"text": "Abi!",       "word": "abi",     "language": "turkish"},
				{"text": "Buyur,",     "word": "buyur",   "language": "turkish"},
				{"text": "buyur.",     "word": "buyur",   "language": "turkish"},
				{"text": "Bir",        "word": "bir",     "language": "turkish"},
				{"text": "çay",        "word": "çay",     "language": "turkish"},
				{"text": "iç.",        "word": "iç",      "language": "turkish"},
			],
			"responses": [
				{"text": "Take the glass. Sit down. You were not going anywhere",
					"words": "Take. Sit.", "say": "Eyvallah abi. Tesekkurler.",
					"style": "casual", "rep": 3,
					"action": "flag:enc_istanbul_cay"},
				{"text": "Take it and try to pay for it",
					"words": "Take. Offer coins.",
					"say": "How much? Let me pay.",
					"style": "direct", "rep": -2,
					"action": "flag:enc_istanbul_cay"},
				{"text": "Put a hand on your chest and decline politely",
					"words": "Hand on chest. Shake head.",
					"say": "That is very kind, but no thank you.",
					"style": "formal", "rep": -1,
					"action": "flag:enc_istanbul_cay"},
			],
		},
	],
},

# ── Mumbai ───────────────────────────────────────────────────────────────────
# The lane is building something forty feet tall and everybody pays for it.
"mumbai_mandal": {
	"city": "mumbai", "region": "bhuleshwar", "flag": "enc_mumbai_mandal",
	"needs": "", "mark": "!", "look": "mandal_boy",
	"name": "Boy with a receipt book", "relationship": "the lane",
	"lines": [
		{
			"words": [
				{"text": "Arre",     "word": "arre",     "language": "hindi"},
				{"text": "bhai,",    "word": "bhai",     "language": "hindi"},
				{"text": "mandal",   "word": "mandal",   "language": "hindi"},
				{"text": "ke",       "word": "ke",       "language": "hindi"},
				{"text": "liye.",    "word": "liye",     "language": "hindi"},
				{"text": "Thoda",    "word": "thoda",    "language": "hindi"},
				{"text": "sa.",      "word": "sa",       "language": "hindi"},
			],
			"responses": [
				{"text": "Give something, and take the receipt he tears off",
					"words": "Coins. Take receipt.",
					"say": "Here. For the pandal.",
					"style": "casual", "rep": 3, "requires_money": 2,
					"action": "flag:enc_mumbai_mandal"},
				{"text": "Ask what it is for, with your hands",
					"words": "Point at book. Raise eyebrows.",
					"say": "What is this for?",
					"style": "direct", "rep": 1,
					"action": "flag:enc_mumbai_mandal"},
				{"text": "Say you have nothing, and show him it is true",
					"words": "Empty hands.",
					"say": "I have nothing on me. I am sorry.",
					"style": "indirect", "rep": 0,
					"action": "flag:enc_mumbai_mandal"},
			],
		},
	],
},

# ── Tokyo ────────────────────────────────────────────────────────────────────
# She is not telling you off. She is offering you somewhere to stand.
"tokyo_eating": {
	"city": "tokyo", "region": "ueno", "flag": "enc_tokyo_eating",
	"needs": "", "mark": "!", "look": "eating_woman",
	"name": "The woman from the shop", "relationship": "shitamachi",
	"lines": [
		{
			"words": [
				{"text": "Ara,",        "word": "ara",       "language": "japanese"},
				{"text": "chotto",      "word": "chotto",    "language": "japanese"},
				{"text": "ne.",         "word": "ne",        "language": "japanese"},
				{"text": "Tabearuki",   "word": "tabearuki", "language": "japanese"},
				{"text": "wa",          "word": "wa",        "language": "japanese"},
				{"text": "chotto...",   "word": "chotto",    "language": "japanese"},
			],
			"responses": [
				{"text": "Stop walking. Stand still. Finish it where you are",
					"words": "Stop. Stand. Eat.",
					"say": "Ah - sumimasen. I will stand here.",
					"style": "formal", "rep": 3,
					"action": "flag:enc_tokyo_eating"},
				{"text": "Hear the 'chotto' as a maybe and keep walking",
					"words": "Nod. Keep going.",
					"say": "Thank you! It is very good.",
					"style": "casual", "rep": -3,
					"action": "flag:enc_tokyo_eating"},
				{"text": "Hold it out and look for a bin",
					"words": "Hold it out. Look around.",
					"say": "Where should I put this?",
					"style": "indirect", "rep": 1,
					"action": "flag:enc_tokyo_eating"},
			],
		},
	],
},

# ── Mexico City ──────────────────────────────────────────────────────────────
# She has decided you are carrying flowers now.
"mexico_flowers": {
	"city": "mexico", "region": "coyoacan", "flag": "enc_mexico_flowers",
	"needs": "", "mark": "!", "look": "flower_woman",
	"name": "A woman with both arms full", "relationship": "vecina",
	"lines": [
		{
			"words": [
				{"text": "Joven,",    "word": "joven",    "language": "spanish_mx"},
				{"text": "ayudeme",   "word": "ayudeme",  "language": "spanish_mx"},
				{"text": "tantito.",  "word": "tantito",  "language": "spanish_mx"},
				{"text": "Ahorita",   "word": "ahorita",  "language": "spanish_mx"},
				{"text": "vengo.",    "word": "vengo",    "language": "spanish_mx"},
			],
			"responses": [
				{"text": "Hold the flowers. She said ahorita, which is not now",
					"words": "Take flowers. Wait.",
					"say": "Of course. I will wait here.",
					"style": "casual", "rep": 3,
					"action": "flag:enc_mexico_flowers"},
				{"text": "Take them and carry them where she was going",
					"words": "Take. Follow.",
					"say": "I will bring them. Where to?",
					"style": "direct", "rep": 1,
					"action": "flag:enc_mexico_flowers"},
				{"text": "Take them, and put them down after a minute",
					"words": "Take. Set down. Leave.",
					"say": "I have to go, sorry.",
					"style": "indirect", "rep": -3,
					"action": "flag:enc_mexico_flowers"},
			],
		},
	],
},
}


static func get_encounter(id: String) -> Dictionary:
	return ALL.get(id, {})


# Whether this one is still waiting to happen.
static func pending(id: String) -> bool:
	var e: Dictionary = ALL.get(id, {})
	if e.is_empty():
		return false
	if bool(GameState.world_flags.get(String(e.get("flag", "")), false)):
		return false
	var needs: String = String(e.get("needs", ""))
	if not needs.is_empty():
		return bool(GameState.world_flags.get(needs, false))
	return true
