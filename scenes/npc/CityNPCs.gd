class_name CityNPCs
extends Object

# The people. One roster, keyed by id, read by CityNPC.gd.
#
# Every line here is written as the person would actually say it, not as a
# generic villager. An eighty-year-old caff owner and a sixteen-year-old on the
# bus do not share a vocabulary, a speed, or a reason for talking to you, and
# the player should be able to tell them apart with the sound off.
#
# Each response carries up to four phrasings — see GameState.phrase_for():
#   gesture  what you do when you have no words at all
#   words    naming and pointing
#   frag     two or three words, understood badly
#   say      a whole sentence, and now the tone is what can be wrong
#
# `rep` is the reputation change. The rule across all three cities: matching
# the person's register earns it, and mismatching costs it. Formality with a
# teenager is as wrong as slang with an official.

# ── BERLIN ────────────────────────────────────────────────────────────────────
#
# The city the game starts in had no roster at all. Berlin's people were the
# hand-built ones - Lukas, Renate, the Spati - written before CityNPCs existed,
# so Prenzlberg and Kreuzberg were streets with doors, a way back and nobody
# on them. These four are the street.
#
# Berlin's failure is that the system receives you without understanding you,
# and the two districts pull opposite ways against it. Prenzlberg is where
# being from somewhere else is so ordinary that a German from Stuttgart is
# also from somewhere else. Kreuzberg is where the alien finds out that having
# learned a language is not the same as knowing when to use it.
const BERLIN := {

	# Sixty-eight, born in the back building, and the bins round the
	# playground are a round he walks. Flaschensammeln is an ordinary thing a
	# Berlin pensioner does and he is not ashamed of it, so nothing here is
	# pitiable: he is correcting a stranger who is throwing money away, and he
	# is slightly enjoying it.
	"hartmut": {
		"name": "Hartmut", "region": "prenzlberg", "color": Color(0.44, 0.42, 0.36),
		"role": "sixty-eight. Born in the back building, watched the street "
			+ "change twice. Walks the bins by the playground for Pfand and "
			+ "is not embarrassed about it.",
		"relationships": ["a stranger", "the one who keeps turning up",
			"Nachbar", "Nachbar"],
		"rounds": [
			[{
				"words": [
					{"text": "Nee!",    "word": "nee",    "language": "german"},
					{"text": "Pfand.",  "word": "pfand",  "language": "german"},
					{"text": "Das",     "word": "das",    "language": "german"},
					{"text": "ist",     "word": "ist",    "language": "german"},
					{"text": "Geld,",   "word": "geld",   "language": "german"},
					{"text": "Mensch.", "word": "mensch", "language": "german"},
				],
				"responses": [
					# Both of the first two are right, which is the point: the
					# bottle is worth something and it does not matter which of
					# you takes it back. Apologising is the only wrong move,
					# because it treats a correction as an accusation.
					{"gesture": "Fish it back out and hold it out to him",
						"words": "Take bottle. Hold it out.",
						"say": "Here. You have it.",
						"style": "direct", "rep": 3},
					{"gesture": "Fish it back out and keep it",
						"words": "Take bottle. Keep it.",
						"say": "Mine, then. I will take it back myself.",
						"style": "direct", "rep": 2},
					{"gesture": "Apologise and push it further into the bin",
						"words": "Sorry. Sorry.",
						"say": "I am sorry. I did not mean to.",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Flasche,", "word": "flasche", "language": "german"},
					{"text": "jeden",    "word": "jeden",   "language": "german"},
					{"text": "Tag.",     "word": "tag",     "language": "german"},
					{"text": "Das",      "word": "das",     "language": "german"},
					{"text": "ist",      "word": "ist",     "language": "german"},
					{"text": "Arbeit.",  "word": "arbeit",  "language": "german"},
				],
				"responses": [
					{"gesture": "Agree with him. It plainly is",
						"words": "Ja. Arbeit.",
						"say": "Yes. It is work.",
						"style": "direct", "rep": 3},
					{"gesture": "Offer him a coin instead",
						"words": "Hold out money.",
						"say": "Here - take this instead, it is easier.",
						"style": "indirect", "rep": -3},
					{"gesture": "Ask how many that is in a day",
						"words": "Wie viele? Jeden Tag?",
						"say": "How many is that? In one day?",
						"style": "casual", "rep": 1},
				],
			}],
		],
	},

	# The mirror, and the reason Prenzlberg gets two people. She is German,
	# she is not foreign, and she is also not from here - nine years in and
	# still die Wessi to men on benches. She is the first person in the game
	# whose German the alien understands completely, because she speaks the
	# one he has been taught, which is nobody's here.
	#
	# Her rep table is the city's inverted on purpose. Berlin costs you for
	# formality; she does not, because she is Swabian and it is what she is
	# comfortable with. A city's rules are not every person in it.
	"ilka": {
		"name": "Ilka", "region": "prenzlberg", "color": Color(0.62, 0.52, 0.66),
		"role": "thirty-one. Nine years here, from Stuttgart, and still called "
			+ "die Wessi by men on benches. Speaks the German the alien has "
			+ "actually been learning, which is its own kind of foreign.",
		"relationships": ["a stranger", "the one from the corner",
			"a neighbour", "a neighbour"],
		"rounds": [
			[{
				"words": [
					{"text": "Entschuldigung.", "word": "entschuldigung", "language": "german"},
					{"text": "Ist",   "word": "ist",  "language": "german"},
					{"text": "hier",  "word": "hier", "language": "german"},
					{"text": "frei?", "word": "frei", "language": "german"},
				],
				"responses": [
					{"gesture": "Move along the bench. Say nothing",
						"words": "Shift over.",
						"say": "Of course. Please.",
						"style": "gesture", "rep": 2},
					{"gesture": "Answer in the full sentence you were taught",
						"words": "Ja, bitte. Hier ist frei.",
						"say": "Yes, please do. This seat is free.",
						"style": "formal", "rep": 3},
					{"gesture": "Try the one Berlin word you have picked up",
						"words": "Na.",
						"say": "Na.",
						"style": "casual", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Neun",  "word": "neun",  "language": "german"},
					{"text": "Jahre", "word": "jahre", "language": "german"},
					{"text": "hier.", "word": "hier",  "language": "german"},
					{"text": "Und",   "word": "und",   "language": "german"},
					{"text": "immer", "word": "immer", "language": "german"},
					{"text": "noch",  "word": "noch",  "language": "german"},
					{"text": "nicht", "word": "nicht", "language": "german"},
					{"text": "von",   "word": "von",   "language": "german"},
					{"text": "hier.", "word": "hier",  "language": "german"},
				],
				"responses": [
					{"gesture": "Point at her, then at yourself",
						"words": "Wir. Beide.",
						"say": "Both of us, then.",
						"style": "casual", "rep": 3},
					{"gesture": "Tell her nine years sounds like a long time",
						"words": "Neun Jahre. Lang.",
						"say": "Nine years is a long time to still be new.",
						"style": "direct", "rep": 1},
					{"gesture": "Point out that she is German and you are not",
						"words": "Du bist von hier. Ich nicht.",
						"say": "But you are German. It is not the same thing.",
						"style": "direct", "rep": -2},
				],
			}],
		],
	},

	# Kreuzberg, and the double-take this district exists for.
	#
	# She was born on this street. Her grandfather came in 1971. She switches
	# language inside a sentence without noticing she has done it, which is
	# simply how people here talk - and the alien, who has spent the game
	# unable to say anything at all, arrives holding words from a city two
	# thousand kilometres away and has to work out what they are for.
	#
	# Round two is the whole point. Being asked where he learned it is a
	# friendly question. Asking her the same question back is not, and the
	# game has already said so out loud in London, where Nadia is bored of
	# being asked where she is REALLY from. Having the words is not the same
	# as knowing that using them can be a way of telling somebody what you
	# think they are.
	"sibel": {
		"name": "Sibel", "region": "kreuzberg", "color": Color(0.78, 0.46, 0.34),
		"role": "twenty-six. Born on this street; her grandfather came in "
			+ "1971. On the till at the Maybachufer market stall, Tuesdays "
			+ "and Fridays, and changes language mid-sentence without hearing "
			+ "herself do it.",
		"relationships": ["a customer", "a customer", "kanka", "kanka"],
		"rounds": [
			[{
				"words": [
					{"text": "Buyurun", "word": "buyurun", "language": "turkish"},
					{"text": "abla.",   "word": "abla",    "language": "turkish"},
					{"text": "Ja,",     "word": "ja",      "language": "german"},
					{"text": "gleich.", "word": "gleich",  "language": "german"},
					{"text": "Bitte?",  "word": "bitte",   "language": "german"},
				],
				"responses": [
					{"gesture": "Answer in German. She is working, in Berlin",
						"words": "Ja, bitte. Eine.",
						"say": "Yes please. One of those.",
						"style": "direct", "rep": 2},
					# Only offered if he has actually been to Istanbul (the
					# dialogue box hides needs_city answers otherwise): cities
					# come in any order, and if he can say it, he earned it.
					{"gesture": "Answer with the Turkish you carried out of Istanbul",
						"words": "Merhaba abla. Bir tane.",
						"say": "Hello. One of those, please.",
						"style": "casual", "rep": 3, "needs_city": "istanbul"},
					{"gesture": "Point, and hold up one finger",
						"words": "Point. One finger.",
						"say": "That one. Just one.",
						"style": "gesture", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Du",        "word": "du",        "language": "german"},
					{"text": "kannst",    "word": "kannst",    "language": "german"},
					{"text": "Türkisch?", "word": "tuerkisch", "language": "german"},
					{"text": "Woher?",    "word": "woher",     "language": "german"},
				],
				"responses": [
					{"gesture": "Say the name of the city, and nothing else",
						"words": "Istanbul.",
						"say": "Istanbul. I lived there for a while.",
						"style": "direct", "rep": 3, "needs_city": "istanbul"},
					{"gesture": "Say you have been picking it up on this street",
						"words": "Hier. Von euch.",
						"say": "Here. Off this street. Off you, mostly.",
						"style": "casual", "rep": 2},
					# The failure this district is for. She is from Kreuzberg.
					{"gesture": "Assume she is from there too, and ask whereabouts",
						"words": "Du auch? Woher?",
						"say": "You are from there too? Whereabouts, exactly?",
						"style": "direct", "rep": -3},
				],
			}],
		],
	},

	# Fifty-nine, and he came at nine. The 1971 date is his father's; the
	# children followed years later, which is what family reunification
	# actually looked like and is why so many men his age remember a station
	# and a man they had to be told was theirs.
	"ercan": {
		"name": "Ercan", "region": "kreuzberg", "color": Color(0.36, 0.46, 0.50),
		"role": "fifty-nine. Came at nine, four years after his father did. "
			+ "Mends bicycles in an arch under the U1 on Skalitzer Strasse "
			+ "and has not heard a train go over since about 1974.",
		"relationships": ["a customer", "a customer", "abi", "abi"],
		"rounds": [
			[{
				"words": [
					{"text": "Kaputt?", "word": "kaputt", "language": "german"},
					{"text": "Hier.",   "word": "hier",   "language": "german"},
					{"text": "Gleich.", "word": "gleich", "language": "german"},
				],
				"responses": [
					{"gesture": "Put it down where he pointed, and wait",
						"words": "Set it down. Wait.",
						"say": "Thank you. I will wait.",
						"style": "gesture", "rep": 2},
					{"gesture": "Ask what it costs before you hand it over",
						"words": "Wie teuer?",
						"say": "How much will it be? Before you start.",
						"style": "direct", "rep": 1},
					{"gesture": "Explain the whole problem at length",
						"words": "Long sentence. Gestures. More sentence.",
						"say": "So it began making a noise on Tuesday, and then -",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "Vierzig", "word": "vierzig", "language": "german"},
					{"text": "Jahre",   "word": "jahre",   "language": "german"},
					{"text": "hier.",   "word": "hier",    "language": "german"},
					{"text": "Die",     "word": "die",     "language": "german"},
					{"text": "Bahn?",   "word": "bahn",    "language": "german"},
					{"text": "Nicht",   "word": "nicht",   "language": "german"},
					{"text": "mehr.",   "word": "mehr",    "language": "german"},
				],
				"responses": [
					{"gesture": "Listen for it. You can hear nothing else",
						"words": "Look up. Wince.",
						"say": "I can hear nothing but it.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask whether the language went quiet as well",
						"words": "Und Deutsch? Auch nicht mehr?",
						"say": "And the German? Did that stop being loud too?",
						"style": "direct", "rep": 2},
					{"gesture": "Say forty years is long enough to be from here",
						"words": "Vierzig Jahre. Du bist von hier.",
						"say": "Forty years. You are from here, then.",
						"style": "direct", "rep": 1},
				],
			}],
		],
	},
}


# ── LONDON ────────────────────────────────────────────────────────────────────
# The words arrive whole and mean something else. Every NPC here is friendly and
# none of them are telling you what they mean.

const LONDON := {
	"dot": {
		"name": "Dot", "region": "highstreet", "color": Color(0.72, 0.34, 0.36),
		"role": "runs the caff. Seventy-one. Has called every customer 'love' since 1974.",
		"relationships": ["a face", "love", "darlin'", "darlin'"],
		"rounds": [
			[
				{
					"words": [
						{"text": "You",     "word": "you",     "language": "english"},
						{"text": "alright,", "word": "alright", "language": "english"},
						{"text": "love?",   "word": "love",    "language": "english"},
						{"text": "Sit",     "word": "sit",     "language": "english"},
						{"text": "anywhere.", "word": "anywhere", "language": "english"},
					],
					"responses": [
						{"gesture": "Nod once and sit down",
							"words": "Nod. Sit.",
							"say": "Ta. Just a tea, please.",
							"style": "casual", "rep": 2},
						{"gesture": "Hold still and try to answer the question honestly",
							"words": "Point at yourself. Shake your head slowly.",
							"say": "Not really, no. It has been a difficult week.",
							"style": "direct", "rep": -1},
						{"gesture": "Bow your head deeply",
							"words": "Bow. Say nothing.",
							"say": "I am most grateful for your hospitality.",
							"style": "formal", "rep": -2},
					],
				},
				{
					"words": [
						{"text": "Not",    "word": "not",   "language": "english"},
						{"text": "seen",   "word": "seen",  "language": "english"},
						{"text": "you",    "word": "you",   "language": "english"},
						{"text": "before,", "word": "before", "language": "english"},
						{"text": "have",   "word": "have",  "language": "english"},
						{"text": "I?",     "word": "i",     "language": "english"},
					],
					"responses": [
						{"gesture": "Shake your head, and point at the door",
							"words": "New. Here.",
							"say": "No. I came in on Tuesday.",
							"style": "casual", "rep": 2},
						{"gesture": "Look at the floor and wait for her to move on",
							"words": "Say nothing.",
							"say": "I would rather not say.",
							"style": "indirect", "rep": -1},
					],
				},
			],
			[
				{
					"words": [
						{"text": "Cold",   "word": "cold",  "language": "english"},
						{"text": "enough", "word": "enough", "language": "english"},
						{"text": "for",    "word": "for",   "language": "english"},
						{"text": "you?",   "word": "you",   "language": "english"},
					],
					"responses": [
						# The weather is not a question about the weather. Agreeing
						# is the entire content of the exchange.
						{"gesture": "Pull your shoulders up and blow into your hands",
							"words": "Cold. Very.",
							"say": "Freezing. And it's not even December.",
							"style": "casual", "rep": 3},
						{"gesture": "Look up at the ceiling, then shrug — it seems fine",
							"words": "Point up. Shrug.",
							"say": "It is within the range I can tolerate.",
							"style": "direct", "rep": -2},
					],
				},
			],
		],
	},
	# ── Docklands ────────────────────────────────────────────────────────
	# The district had a way back and nobody on it. These two are the whole
	# of London's failure standing eleven metres apart: the most fluent
	# English in the game, which tells you nothing, and the bluntest, which
	# tells you everything and is not on anybody's payroll to be nice.

	# Every sentence is a formula and every formula is no. He is not being
	# unkind and he is not being obstructive - this is simply the register
	# the job is done in, and it is impenetrable in exact proportion to how
	# correct it is. The alien can now understand English perfectly and is
	# further from getting through this door than he was in Berlin, where at
	# least nobody pretended the conversation was going anywhere.
	"femi": {
		"name": "Femi", "region": "docklands", "color": Color(0.30, 0.38, 0.56),
		"role": "twenty-four. Nights on the desk in a tower lobby. Says no "
			+ "eleven times an hour without once using the word.",
		"relationships": ["sir", "sir", "sir", "sir"],
		"rounds": [
			[{
				"words": [
					{"text": "Sorry,",   "word": "sorry",   "language": "english"},
					{"text": "you",      "word": "you",     "language": "english"},
					{"text": "alright?", "word": "alright", "language": "english"},
					{"text": "I'm",      "word": "im",      "language": "english"},
					{"text": "afraid",   "word": "afraid",  "language": "english"},
					{"text": "I",        "word": "i",       "language": "english"},
					{"text": "can't",    "word": "cant",    "language": "english"},
					{"text": "let",      "word": "let",     "language": "english"},
					{"text": "you",      "word": "you",     "language": "english"},
					{"text": "through",  "word": "through", "language": "english"},
					{"text": "without",  "word": "without", "language": "english"},
					{"text": "a",        "word": "a",       "language": "english"},
					{"text": "pass.",    "word": "pass",    "language": "english"},
				],
				"responses": [
					# There is no answer that opens the door, which is the
					# point. What is available is whether you make his shift
					# worse. Arguing with the formula is arguing with a wall
					# that is apologising to you.
					{"gesture": "Accept it immediately. He is not the door",
						"words": "Right. No worries.",
						"say": "Right. No worries. Cheers anyway.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask him where you would get one",
						"words": "Where do I get a pass?",
						"say": "Where would I get one? Genuinely asking.",
						"style": "direct", "rep": 2},
					{"gesture": "Point out that he said sorry and afraid and neither is true",
						"words": "You are not sorry. You are not afraid.",
						"say": "You are not sorry and you are not afraid. Why say it?",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Nobody",   "word": "nobody",   "language": "english"},
					{"text": "in",       "word": "in",       "language": "english"},
					{"text": "this",     "word": "this",     "language": "english"},
					{"text": "building", "word": "building", "language": "english"},
					{"text": "knows",    "word": "know",     "language": "english"},
					{"text": "my",       "word": "my",       "language": "english"},
					{"text": "name.",    "word": "name",     "language": "english"},
				],
				"responses": [
					{"gesture": "Ask him what it is",
						"words": "What is your name?",
						"say": "What is it, then?",
						"style": "direct", "rep": 3},
					{"gesture": "Say yours first",
						"words": "Point at yourself. Wait.",
						"say": "I have not got one either. That is a long story.",
						"style": "casual", "rep": 2},
					{"gesture": "Tell him that is terrible",
						"words": "That is terrible.",
						"say": "That is awful. That is really awful.",
						"style": "formal", "rep": -1},
				],
			}],
		],
	},

	# The other half, and the reason this district has two. Nineteen years in
	# the same tower on a five a.m. shift, and she has never once met anybody
	# who works there. She has no script because nobody wrote her one, which
	# makes her the most legible person in London.
	"trish": {
		"name": "Trish", "region": "docklands", "color": Color(0.66, 0.44, 0.40),
		"role": "fifty-two. Cleans the offices from five. Nineteen years in "
			+ "the building and has never met a soul who works in it.",
		"relationships": ["a face", "love", "love", "darlin'"],
		"rounds": [
			[{
				"words": [
					{"text": "You",     "word": "you",     "language": "english"},
					{"text": "lost,",   "word": "lost",    "language": "english"},
					{"text": "love?",   "word": "love",    "language": "english"},
					{"text": "Nineteen", "word": "nineteen", "language": "english"},
					{"text": "years",   "word": "years",   "language": "english"},
					{"text": "I've",    "word": "ive",     "language": "english"},
					{"text": "done",    "word": "done",    "language": "english"},
					{"text": "this",    "word": "this",    "language": "english"},
					{"text": "floor.",  "word": "floor",   "language": "english"},
				],
				"responses": [
					{"gesture": "Say yes. You are lost, and she asked",
						"words": "Yes. Very.",
						"say": "Yes. Completely.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask her nineteen years of what",
						"words": "Nineteen years? Here?",
						"say": "Nineteen years in this one building?",
						"style": "direct", "rep": 2},
					# The trap London has been laying all act. From Femi,
					# "you alright" was furniture. From her it was a question.
					{"gesture": "Answer the way you learned to on the high street",
						"words": "Yeah, safe.",
						"say": "Yeah, safe, you alright.",
						"style": "casual", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "They",   "word": "they",   "language": "english"},
					{"text": "don't",  "word": "dont",   "language": "english"},
					{"text": "see",    "word": "see",    "language": "english"},
					{"text": "me.",    "word": "me",     "language": "english"},
					{"text": "Not",    "word": "not",    "language": "english"},
					{"text": "rude.",  "word": "rude",   "language": "english"},
					{"text": "Just",   "word": "just",   "language": "english"},
					{"text": "don't.",  "word": "dont",   "language": "english"},
				],
				"responses": [
					{"gesture": "Say you know exactly what she means",
						"words": "I know. I know that one.",
						"say": "I know that one. I have had a year of it.",
						"style": "casual", "rep": 3},
					{"gesture": "Say it is because of the hour, not the work",
						"words": "Five in the morning. Nobody sees anyone.",
						"say": "It is the hour. At five nobody sees anybody.",
						"style": "indirect", "rep": 1},
					{"gesture": "Tell her she should say something to them",
						"words": "Tell them. Say something.",
						"say": "You should say something. Make them look at you.",
						"style": "direct", "rep": -2},
				],
			}],
		],
	},

	"kai": {
		"name": "Kai", "region": "highstreet", "color": Color(0.28, 0.62, 0.58),
		"role": "sixteen. Waiting for a bus that is late. Talks fast and quietly, "
			+ "mostly to his friends, occasionally at you.",
		"relationships": ["some guy", "some guy", "aight", "aight"],
		"rounds": [
			[
				{
					"words": [
						{"text": "You",   "word": "you",   "language": "english"},
						{"text": "safe?",  "word": "safe",  "language": "english"},
						{"text": "Bus",   "word": "bus",   "language": "english"},
						{"text": "ain't", "word": "aint",  "language": "english"},
						{"text": "come",  "word": "come",  "language": "english"},
						{"text": "innit.", "word": "innit", "language": "english"},
					],
					"responses": [
						# "Safe" is a greeting and "innit" is not a question.
						# Answering either literally marks you out instantly.
						{"gesture": "Tip your chin up, once",
							"words": "Chin up. Nothing else.",
							"say": "Yeah, safe.",
							"style": "casual", "rep": 3},
						{"gesture": "Look around for danger, then back at him",
							"words": "Point around. Look worried.",
							"say": "Am I safe? Is something wrong?",
							"style": "direct", "rep": -2},
						{"gesture": "Offer a handshake",
							"words": "Hold out your hand.",
							"say": "Good afternoon. How do you do?",
							"style": "formal", "rep": -3},
					],
				},
			],
		],
	},
	"aggarwal": {
		"name": "Mr Aggarwal", "region": "highstreet", "color": Color(0.36, 0.42, 0.72),
		"role": "newsagent, fifties. Came here at nineteen. Speaks more carefully "
			+ "correct English than anybody born in this postcode.",
		"relationships": ["a customer", "a customer", "a regular", "a regular"],
		"rounds": [
			[
				{
					"words": [
						{"text": "Good",     "word": "good",     "language": "english"},
						{"text": "afternoon.", "word": "afternoon", "language": "english"},
						{"text": "Was",      "word": "was",      "language": "english"},
						{"text": "there",    "word": "there",    "language": "english"},
						{"text": "something", "word": "something", "language": "english"},
						{"text": "particular?", "word": "particular", "language": "english"},
					],
					"responses": [
						# He gives you the full form, and he means it. Here
						# formality is the correct register, not stiffness.
						{"gesture": "Straighten up and nod respectfully",
							"words": "Nod. Point at the shelf.",
							"say": "Good afternoon. I am looking for a map.",
							"style": "formal", "rep": 3},
						{"gesture": "Wave loosely and start browsing",
							"words": "Wave. Wander off.",
							"say": "Alright mate, just having a look.",
							"style": "casual", "rep": -1},
					],
				},
			],
		],
	},
	"marcus": {
		"name": "Marcus", "region": "brixton", "color": Color(0.32, 0.44, 0.36),
		"role": "record shop under the arches. Fifty-eight. Been here since it was cheap.",
		"head": "none",
		"relationships": ["a browser", "a browser", "you again"],
		"rounds": [
			[{
				"words": [
					{"text": "You",      "word": "you",      "language": "english"},
					{"text": "looking",  "word": "looking",  "language": "english"},
					{"text": "for",      "word": "for",      "language": "english"},
					{"text": "something", "word": "something", "language": "english"},
					{"text": "or",       "word": "or",       "language": "english"},
					{"text": "just",     "word": "just",     "language": "english"},
					{"text": "looking?", "word": "looking",  "language": "english"},
				],
				"responses": [
					{"gesture": "Say you are just looking, and mean it",
						"words": "Point at the racks. Shrug.",
						"say": "Just looking. Is that all right?",
						"style": "casual", "rep": 2},
					{"gesture": "Invent something you are looking for",
						"words": "Name a thing. Any thing.",
						"say": "Something with... drums? I do not know what I want.",
						"style": "direct", "rep": 0},
					{"gesture": "Apologise for being in the shop",
						"words": "Back toward the door.",
						"say": "Sorry - I will get out of your way.",
						"style": "formal", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "This",   "word": "this",   "language": "english"},
					{"text": "whole",  "word": "whole",  "language": "english"},
					{"text": "street", "word": "street", "language": "english"},
					{"text": "used",   "word": "used",   "language": "english"},
					{"text": "to",     "word": "to",     "language": "english"},
					{"text": "be",     "word": "be",     "language": "english"},
					{"text": "us.",    "word": "us",     "language": "english"},
				],
				"responses": [
					{"gesture": "Let him say the rest of it",
						"words": "Wait. Do not fill it.",
						"say": "(He does say the rest of it. It takes a while.)",
						"style": "indirect", "rep": 3},
					{"gesture": "Ask what changed",
						"words": "Point at the new frontage across the road.",
						"say": "Used to be. What happened?",
						"style": "direct", "rep": 2},
					{"gesture": "Say something warm and general",
						"words": "Smile. Nod along.",
						"say": "It still seems like a lovely area!",
						"style": "casual", "rep": -2},
				],
			}],
		],
	},
	"esme": {
		"name": "Esme", "region": "soho", "color": Color(0.52, 0.30, 0.42),
		"role": "stage door, six nights a week. Thirty-four. Has heard every excuse.",
		"head": "none",
		"relationships": ["nobody", "nobody", "one of the regulars"],
		"rounds": [
			[{
				"words": [
					{"text": "Yeah,",   "word": "yeah",   "language": "english"},
					{"text": "no,",     "word": "no",     "language": "english"},
					{"text": "you",     "word": "you",    "language": "english"},
					{"text": "can",     "word": "can",    "language": "english"},
					{"text": "wait",    "word": "wait",   "language": "english"},
					{"text": "there.",  "word": "there",  "language": "english"},
				],
				"responses": [
					{"gesture": "Hear the no inside the yeah",
						"words": "Nod. Do not move closer.",
						"say": "That was a no, was it. Fine. I will wait there.",
						"style": "indirect", "rep": 3},
					{"gesture": "Take the yeah at face value and go in",
						"words": "Step forward.",
						"say": "Great, thank you!",
						"style": "casual", "rep": -3},
					{"gesture": "Ask which of the two she meant",
						"words": "Point at her. Then at the door.",
						"say": "Yeah, or no? Both of those were in there.",
						"style": "direct", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "You",      "word": "you",      "language": "english"},
					{"text": "learn",    "word": "learn",    "language": "english"},
					{"text": "quick",    "word": "quick",    "language": "english"},
					{"text": "round",    "word": "round",    "language": "english"},
					{"text": "here.",    "word": "here",     "language": "english"},
				],
				"responses": [
					{"gesture": "Take it as the compliment it nearly is",
						"words": "Nod once. Stay where you are.",
						"say": "I have been getting it wrong for a long time.",
						"style": "casual", "rep": 3},
					{"gesture": "Say what you actually learned",
						"words": "Point at your ear.",
						"say": "Not the words. Where the no is hiding in them.",
						"style": "direct", "rep": 3},
					{"gesture": "Thank her effusively",
						"words": "Thank her. Twice.",
						"say": "That is so kind of you to say, honestly, thank you.",
						"style": "formal", "rep": -1},
				],
			}],
		],
	},
}

# ── ISTANBUL ──────────────────────────────────────────────────────────────────
# Nobody here is selling you anything. They are all putting something in front
# of you, and the cost of taking it is the act.

const ISTANBUL := {

	# ── Karakoy ──────────────────────────────────────────────────────────
	# The district had a way back and nobody on it, and it is the one place
	# in the city where Istanbul's own lesson can be taught by taking it
	# away. Persembe Pazari is still ships' chandlers and hardware; two
	# streets up the same buildings are cafes with English menus. Both of
	# those are really there and they are forty metres apart.

	# The debt, done straight. He puts the glass down before a word is
	# exchanged and will not be paid for it. Berlin trained the alien to
	# settle up and owe nothing, and every instinct that city gave him is
	# an insult in this room.
	"bulent": {
		"name": "Bülent", "region": "karakoy", "color": Color(0.54, 0.40, 0.28),
		"role": "sixty-three. Ship chandler in Persembe Pazari - rope, brass, "
			+ "anchor chain. Has never once let anybody pay for the tea.",
		"relationships": ["misafir", "misafir", "abi", "abi"],
		"rounds": [
			[{
				"words": [
					{"text": "Otur.",   "word": "otur",   "language": "turkish"},
					{"text": "İç.",     "word": "ic",     "language": "turkish"},
					{"text": "Para",    "word": "para",   "language": "turkish"},
					{"text": "yok.",    "word": "yok",    "language": "turkish"},
					{"text": "Olsun.",  "word": "olsun",  "language": "turkish"},
				],
				"responses": [
					{"gesture": "Sit down and drink it before you have decided to",
						"words": "Sit. Take the glass.",
						"say": "Yes. Thank you. I am learning to say yes to this.",
						"style": "casual", "rep": 3},
					{"gesture": "Take it, and ask what he is working on",
						"words": "Tesekkur ederim. Bu ne?",
						"say": "Thank you. What is that one for?",
						"style": "casual", "rep": 3},
					# The Berlin reflex, and it is the insult. Not because
					# money is rude - because paying is how you refuse to be
					# a guest, and he offered you that and not a drink.
					{"gesture": "Put the money on the counter anyway",
						"words": "Set coins down. Firmly.",
						"say": "No, please - let me pay for it. I insist.",
						"style": "direct", "rep": -3},
				],
			}],
			[{
				"words": [
					{"text": "Misafir",  "word": "misafir", "language": "turkish"},
					{"text": "borç",     "word": "borc",    "language": "turkish"},
					{"text": "değil.",   "word": "değil",   "language": "turkish"},
					{"text": "Gel,",     "word": "gel",     "language": "turkish"},
					{"text": "yarın.",   "word": "yarin",   "language": "turkish"},
				],
				"responses": [
					{"gesture": "Say you will come tomorrow, and mean it",
						"words": "Yarin. Geliyorum.",
						"say": "Tomorrow. I will come tomorrow.",
						"style": "casual", "rep": 3},
					{"gesture": "Bring something back with you next time instead",
						"words": "Point at yourself. Then at the door. Then hold up two fingers.",
						"say": "Then I bring something. Not money. Something.",
						"style": "indirect", "rep": 2},
					{"gesture": "Work out aloud what you now owe him",
						"words": "Iki cay. Ne kadar?",
						"say": "Two teas, then. So what does that make it?",
						"style": "direct", "rep": -2},
				],
			}],
		],
	},

	# Two streets up, and the same century. She is not a villain and she is
	# not a warning: she runs a good business properly, in a district where
	# rents went up because of businesses like hers, and she is from here.
	#
	# Her round is the inversion the whole city has been building to. She
	# takes the money, gives a receipt, speaks English, and lets the alien
	# owe absolutely nothing - and after Bulent, being allowed to owe nothing
	# reads exactly like being turned away. That is the lesson stated by its
	# absence, which is the only way left to state it by this point.
	"yasemin": {
		"name": "Yasemin", "region": "karakoy", "color": Color(0.40, 0.52, 0.50),
		"role": "thirty-four. Runs the coffee place two streets up from the "
			+ "chandlers. Grew up four doors from it. Charges you properly "
			+ "and gives you a receipt.",
		"relationships": ["a customer", "a customer", "a regular", "a regular"],
		"rounds": [
			[{
				"words": [
					{"text": "Buyurun.",  "word": "buyurun", "language": "turkish"},
					{"text": "Bir",       "word": "bir",     "language": "turkish"},
					{"text": "kart?",     "word": "kart",    "language": "turkish"},
					{"text": "Otuz",      "word": "otuz",    "language": "turkish"},
					{"text": "lira.",     "word": "lira",    "language": "turkish"},
				],
				"responses": [
					{"gesture": "Pay. It is a shop and this is what shops are",
						"words": "Hold out the card. Take the receipt.",
						"say": "Of course. Thank you.",
						"style": "direct", "rep": 2},
					# He has been in this city long enough to feel the gap.
					{"gesture": "Notice that nothing has been put in front of you",
						"words": "Look at the counter. Nothing on it.",
						"say": "Nobody has given me anything. I did not know I would miss it.",
						"style": "indirect", "rep": 3},
					{"gesture": "Wait to be offered something first",
						"words": "Stand. Wait. Keep waiting.",
						"say": "I will wait. Somebody always brings something.",
						"style": "indirect", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Ben",       "word": "ben",     "language": "turkish"},
					{"text": "buralıyım.", "word": "burali",  "language": "turkish"},
					{"text": "Sokak",     "word": "sokak",   "language": "turkish"},
					{"text": "değişti.",  "word": "degisti", "language": "turkish"},
					{"text": "Ben",       "word": "ben",     "language": "turkish"},
					{"text": "değil.",    "word": "değil",   "language": "turkish"},
				],
				"responses": [
					{"gesture": "Say you assumed she was not",
						"words": "I thought you were not from here.",
						"say": "I had assumed you were not from here. I am sorry.",
						"style": "direct", "rep": 1},
					{"gesture": "Ask whether the street changing is hers too",
						"words": "Sokak degisti. Senin de mi?",
						"say": "The street changed. Did it change for you as well?",
						"style": "casual", "rep": 3},
					{"gesture": "Tell her the old shops downhill are the real Karakoy",
						"words": "Asagida. Gercek Karakoy.",
						"say": "The real Karakoy is down the hill, though. The old shops.",
						"style": "direct", "rep": -3},
				],
			}],
		],
	},

	"meryem": {
		"name": "Meryem", "region": "han", "color": Color(0.62, 0.34, 0.30),
		"role": "Yusuf's mother, seventies. Feeds whoever is in the shop at the "
			+ "hour she feeds people. Never asks a question you cannot answer.",
		"relationships": ["misafir", "misafir", "oğlum", "oğlum"],
		"rounds": [
			[
				{
					"words": [
						{"text": "Aç",      "word": "aç",      "language": "turkish"},
						{"text": "mısın?",  "word": "mi",      "language": "turkish"},
						{"text": "Otur,",   "word": "otur",    "language": "turkish"},
						{"text": "otur.",   "word": "otur",    "language": "turkish"},
					],
					"responses": [
						# She asked whether you are hungry, which can be answered
						# with a plate. That is deliberate on her part.
						# This is the offer, and Istanbul wants one no before the
						# yes. Accepting straight off is not rude and it is not
						# the shape either - she has a whole insistence ready,
						# and taking it at once means nobody gets to use it.
						{"gesture": "Sit down where she is pointing",
							"words": "Sit. Nod.",
							"frag": "Aç. Evet.",
							"say": "Evet, açım. Teşekkür ederim.",
							"style": "gesture", "rep": 3, "ritual": "accept"},
						# The token refusal. Scored at minus three since the day
						# it was written, because nothing in the game knew it
						# was half of something.
						{"gesture": "Hold up both palms and back towards the door",
							"words": "Palms up. Step back.",
							"frag": "Yok. Yok.",
							"say": "No, thank you, I don't want to trouble you.",
							"style": "formal", "rep": -3, "ritual": "decline"},
						{"gesture": "Reach for your money",
							"words": "Hold out coins.",
							"frag": "Para? Ne kadar?",
							"say": "Let me pay you for it.",
							"style": "direct", "rep": -4},
					],
				},
				{
					"timed": true,
					"words": [
						{"text": "Çayını",  "word": "çay",     "language": "turkish"},
						{"text": "iç.",     "word": "iç",      "language": "turkish"},
						{"text": "Soğuyor.", "word": "soğuk",  "language": "turkish"},
					],
					"responses": [
						# And the insistence. This is where the yes belongs, and
						# the tea is going cold while he decides - so it is the
						# one exchange in Istanbul with a clock on it, and in
						# this city a silence reads as a refusal.
						{"gesture": "Take the glass by the rim, two fingers, like she showed you",
							"words": "Take the glass. Two fingers.",
							"frag": "Çay. Teşekkür.",
							"say": "Sağ olun. Çok güzel.",
							"style": "gesture", "rep": 2, "ritual": "accept"},
						{"gesture": "Leave it on the tray and get on with why you came",
							"words": "Leave it. Point at the door.",
							"frag": "Sonra. İş var.",
							"say": "In a moment — I wanted to ask about the shop.",
							"style": "direct", "rep": -2, "ritual": "decline"},
					],
				},
			],
		],
	},
	"emre": {
		"name": "Emre", "region": "carsi", "color": Color(0.24, 0.58, 0.52),
		"role": "nine years old, in the lane every afternoon. The best language "
			+ "teacher in the game and does not know it — he points at a thing, "
			+ "says its name, and waits for you to say it back.",
		"relationships": ["yabancı", "arkadaş", "arkadaş", "arkadaş"],
		"rounds": [
			[
				{
					"words": [
						{"text": "Bak!",   "word": "bak",   "language": "turkish"},
						{"text": "Kedi.",  "word": "kedi",  "language": "turkish"},
						{"text": "Kedi!",  "word": "kedi",  "language": "turkish"},
						{"text": "Sen",    "word": "sen",   "language": "turkish"},
						{"text": "söyle.", "word": "söyle", "language": "turkish"},
					],
					"responses": [
						# A child will make you repeat a word until you have it.
						# No adult in this game will do that for you.
						{"gesture": "Point at the cat and try the sound back at him",
							"words": "Kedi.",
							"frag": "Kedi. Bu kedi.",
							"say": "Kedi. Bu bir kedi, değil mi?",
							"style": "gesture", "rep": 3},
						{"gesture": "Copy him exactly, including the way he points",
							"words": "Bak! Kedi!",
							"frag": "Bak, kedi!",
							"say": "Bak — kedi! Doğru mu?",
							"style": "casual", "rep": 3},
						{"gesture": "Pat his head and move on",
							"words": "Pat his head.",
							"frag": "Tamam. Güle güle.",
							"say": "Yes, very good. I'm busy just now.",
							"style": "formal", "rep": -2},
					],
				},
			],
		],
	},
	"nurhan": {
		"name": "Nurhan Abla", "region": "carsi", "color": Color(0.68, 0.48, 0.22),
		"role": "runs the büfe, fifties. Brisk, kind, and will call you 'oğlum' "
			+ "before she knows your name. Kinship words are not affection here, "
			+ "they are the ordinary way of addressing a person.",
		"relationships": ["yabancı", "oğlum", "oğlum", "canım"],
		"rounds": [
			[
				{
					"words": [
						{"text": "Buyurun",  "word": "buyurun", "language": "turkish"},
						{"text": "oğlum,",   "word": "oğlum",   "language": "turkish"},
						{"text": "ne",       "word": "ne",      "language": "turkish"},
						{"text": "istersin?", "word": "iste",   "language": "turkish"},
					],
					"responses": [
						{"gesture": "Point at the bread, then hold up one finger",
							"words": "Ekmek. Bir.",
							"frag": "Bir ekmek, lütfen.",
							"say": "Bir ekmek alabilir miyim, abla?",
							"style": "direct", "rep": 2},
						# Haggling at a büfe is absurd — the price is the price.
						# It is mandatory forty metres away in the market.
						{"gesture": "Point at the bread, then hold up fewer coins than she asked",
							"words": "Ekmek. Less money.",
							"frag": "Çok pahalı. Az para.",
							"say": "That's too much. I'll give you half.",
							"style": "direct", "rep": -3},
						{"gesture": "Stand back and wait to be served in turn",
							"words": "Wait. Say nothing.",
							"frag": "Ben beklerim.",
							"say": "After you — I'm not in a hurry.",
							"style": "indirect", "rep": 1},
					],
				},
			],
		],
	},
	"sevim": {
		"name": "Sevim", "region": "kadikoy", "color": Color(0.36, 0.44, 0.48),
		"role": "runs the fish stall by the ferry. Fifty-one. Feeds the cats first.",
		"head": "none",
		"relationships": ["a stranger", "canım", "canım"],
		"rounds": [
			[{
				"words": [
					{"text": "Otur,",   "word": "otur",   "language": "turkish"},
					{"text": "çay",     "word": "çay",    "language": "turkish"},
					{"text": "içer",    "word": "içer",   "language": "turkish"},
					{"text": "misin?",  "word": "misin",  "language": "turkish"},
				],
				"responses": [
					{"gesture": "Sit down before you have decided to",
						"words": "Sit. Take the glass.",
						"say": "Yes. Thank you. I have learned to say yes to this.",
						"style": "casual", "rep": 3},
					{"gesture": "Offer to pay for it",
						"words": "Reach for coins.",
						"say": "Let me get this one.",
						"style": "direct", "rep": -3},
					{"gesture": "Say you are in a hurry",
						"words": "Point at the ferry. Wince.",
						"say": "I would love to, but the boat -",
						"style": "formal", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "Karşıdan", "word": "karşıdan", "language": "turkish"},
					{"text": "mı",       "word": "mı",       "language": "turkish"},
					{"text": "geldin?",  "word": "geldin",   "language": "turkish"},
				],
				"responses": [
					{"gesture": "Say yes, and mean the crossing",
						"words": "Point back across the water.",
						"say": "From the other side. On the boat, this morning.",
						"style": "casual", "rep": 2},
					{"gesture": "Say yes, and mean something much further",
						"words": "Point at the water. Then up.",
						"say": "Further than the other side. Much further.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask why it matters which side",
						"words": "Point left. Point right. Shrug.",
						"say": "Is it a different city over there?",
						"style": "indirect", "rep": 1},
				],
			}],
		],
	},
	"altan": {
		"name": "Altan", "region": "beyoglu", "color": Color(0.46, 0.28, 0.30),
		"role": "second-hand books in a passage off İstiklal. Sixty-three. Was a translator.",
		"head": "none",
		"relationships": ["a customer", "a customer", "the one who asks"],
		"rounds": [
			[{
				"words": [
					{"text": "Burası",  "word": "burası",  "language": "turkish"},
					{"text": "Avrupa",  "word": "avrupa",  "language": "turkish"},
					{"text": "gibi",    "word": "gibi",    "language": "turkish"},
					{"text": "değil",   "word": "değil",   "language": "turkish"},
					{"text": "mi?",     "word": "mi",      "language": "turkish"},
				],
				"responses": [
					{"gesture": "Say what you actually notice",
						"words": "Point at the cornices. Then at the street.",
						"say": "It was built to look like it. It does not sound like it.",
						"style": "direct", "rep": 3},
					{"gesture": "Agree politely",
						"words": "Nod. Look around.",
						"say": "Very much so. It is beautiful.",
						"style": "formal", "rep": 0},
					{"gesture": "Say you have just come from four of them",
						"words": "Count on your fingers.",
						"say": "I have just come from four of those. This is not one.",
						"style": "casual", "rep": 3},
				],
			}],
			[{
				"words": [
					{"text": "Ben",       "word": "ben",       "language": "turkish"},
					{"text": "çevirmendim.", "word": "çevirmen", "language": "turkish"},
					{"text": "Otuz",      "word": "otuz",      "language": "turkish"},
					{"text": "yıl.",      "word": "yıl",       "language": "turkish"},
				],
				"responses": [
					{"gesture": "Ask the only question worth asking him",
						"words": "Point at your mouth. Then at your chest.",
						"say": "Thirty years. Did any of it ever come across whole?",
						"style": "direct", "rep": 3},
					{"gesture": "Say that sounds useful",
						"words": "Nod appreciatively.",
						"say": "That must have been a very useful skill.",
						"style": "formal", "rep": -1},
					{"gesture": "Tell him what you have been doing",
						"words": "Gesture at everything.",
						"say": "I have been trying to do that in nine cities without training.",
						"style": "casual", "rep": 2},
				],
			}],
		],
	},
}


static func roster(city: String) -> Dictionary:
	match city:
		"berlin":   return BERLIN
		"london":   return LONDON
		"istanbul": return ISTANBUL
		# The other twelve live in CityNPCsWorld.gd; this file was already
		# three hundred lines for two cities and that is twelve more.
		_:          return CityNPCsWorld.roster(city)


static func get_npc(city: String, id: String) -> Dictionary:
	return roster(city).get(id, {})
