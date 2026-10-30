extends Object

# The people of Honolulu, New York and Toronto.
# Reached through CityNPCsWorld.roster(); kept in its own file because that one
# is already at the size limit.
#
# All three run in English, so nothing here is gated on vocabulary. What is
# gated is register: how fast you are allowed to be, what a question is for,
# and whether an apology means anything.

const HONOLULU := {
	"kimo": {
		"name": "Kimo", "region": "waikiki", "color": Color(0.30, 0.38, 0.36),
		"role": "keeps two boards and lends one of them out. Has never charged anybody and does not intend to start.",
		"head": "cap",
		"relationships": ["a visitor", "a visitor", "somebody he took out"],
		"rounds": [
			[{
				"words": [
					{"text": "Howzit.",  "word": "howzit",  "language": "english"},
					{"text": "You",      "word": "you",     "language": "english"},
					{"text": "like",     "word": "like",    "language": "english"},
					{"text": "go?",      "word": "go",      "language": "english"},
				],
				"responses": [
					{"gesture": "Say yes and mean it",
						"words": "Yeah. I like go.",
						"say": "Yes. I have no idea what I am agreeing to.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask how much",
						"words": "Point at the board. Rub your fingers.",
						"say": "How much for the board?",
						"style": "direct", "rep": -2},
					{"gesture": "Say you have never done it",
						"words": "Shake your head. Point at the water.",
						"say": "I have never been in that water in my life.",
						"style": "formal", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "What",    "word": "what",    "language": "english"},
					{"text": "school",  "word": "school",  "language": "english"},
					{"text": "you",     "word": "you",     "language": "english"},
					{"text": "went?",   "word": "went",    "language": "english"},
				],
				"responses": [
					{"gesture": "Understand that he is asking where you are from",
						"words": "Nowhere here. Very far.",
						"say": "He is not asking about school. He is asking whose I am.",
						"style": "indirect", "rep": 3},
					{"gesture": "Answer about education",
						"words": "Hold up your hands. Explain.",
						"say": "We do not have schools where I am from, exactly -",
						"style": "direct", "rep": 0},
					{"gesture": "Ask him the same question back",
						"words": "Point at him. Same words.",
						"say": "What school you went?",
						"style": "casual", "rep": 2},
				],
			}],
		],
	},
	"lani": {
		"name": "Lani", "region": "chinatown", "color": Color(0.42, 0.30, 0.34),
		"role": "strings leis on a needle the length of her forearm without looking down. Sells to people who are giving them to somebody.",
		"head": "none",
		"relationships": ["a customer", "a customer", "somebody with someone to give one to"],
		"rounds": [
			[{
				"words": [
					{"text": "Who's",   "word": "whos",    "language": "english"},
					{"text": "it",      "word": "it",      "language": "english"},
					{"text": "for?",    "word": "for",     "language": "english"},
				],
				"responses": [
					{"gesture": "Admit it is for nobody",
						"words": "Open your hands. Nobody.",
						"say": "Nobody. I did not know that was the question.",
						"style": "direct", "rep": 3},
					{"gesture": "Say it is for you",
						"words": "Point at yourself.",
						"say": "Me. It is for me.",
						"style": "casual", "rep": -2},
					{"gesture": "Ask what the difference is",
						"words": "Point at the case. Then at the street.",
						"say": "Does it change what you would sell me?",
						"style": "indirect", "rep": 2},
				],
			}],
			[{
				"words": [
					{"text": "I'll",    "word": "ill",     "language": "english"},
					{"text": "hold",    "word": "hold",    "language": "english"},
					{"text": "it",      "word": "it",      "language": "english"},
					{"text": "for",     "word": "for",     "language": "english"},
					{"text": "you.",    "word": "you",     "language": "english"},
				],
				"responses": [
					{"gesture": "Let her",
						"words": "Nod. Leave it in the case.",
						"say": "She is holding a thing for a person I have not met yet.",
						"style": "indirect", "rep": 3},
					{"gesture": "Buy it anyway",
						"words": "Put the money down.",
						"say": "I will take it now. I will find somebody.",
						"style": "direct", "rep": 0},
					{"gesture": "Ask how long she will keep it",
						"words": "Point at the case. Then at the sky.",
						"say": "How long will it keep?",
						"style": "formal", "rep": 1},
				],
			}],
		],
	},
}


const NEWYORK := {
	"marisol": {
		"name": "Marisol", "region": "midtown", "color": Color(0.34, 0.30, 0.42),
		"role": "runs a newsstand on a corner four thousand people an hour go past. Has answered every question this city can produce.",
		"head": "none",
		"relationships": ["a tourist", "a tourist", "a regular"],
		"rounds": [
			[{
				"words": [
					{"text": "Yeah,",   "word": "yeah",    "language": "english"},
					{"text": "two",     "word": "two",     "language": "english"},
					{"text": "blocks,", "word": "blocks",  "language": "english"},
					{"text": "left.",   "word": "left",    "language": "english"},
				],
				"responses": [
					{"gesture": "Take it and go",
						"words": "Nod once. Go.",
						"say": "She answered before I finished. She was right.",
						"style": "direct", "rep": 3},
					{"gesture": "Finish the question you were asking",
						"words": "Keep going. Be thorough.",
						"say": "Sorry, I had not said which one I meant -",
						"style": "formal", "rep": -1},
					{"gesture": "Thank her at length",
						"words": "Three sentences of gratitude.",
						"say": "That is very kind, I really do appreciate -",
						"style": "casual", "rep": -2},
				],
			}],
			[{
				"words": [
					{"text": "You",     "word": "you",     "language": "english"},
					{"text": "buying",  "word": "buying",  "language": "english"},
					{"text": "or",      "word": "or",      "language": "english"},
					{"text": "asking?", "word": "asking",  "language": "english"},
				],
				"responses": [
					{"gesture": "Say which, straight away",
						"words": "Asking.",
						"say": "Not a rebuke. A scheduling question.",
						"style": "direct", "rep": 3},
					{"gesture": "Buy something to be polite",
						"words": "Put money down.",
						"say": "Buying. I will buy something.",
						"style": "casual", "rep": 1},
					{"gesture": "Apologise for taking her time",
						"words": "Step back. Hands up.",
						"say": "I am sorry, I should not have stopped you -",
						"style": "formal", "rep": -1},
				],
			}],
		],
	},
	"dov": {
		"name": "Dov", "region": "lowereast", "color": Color(0.30, 0.32, 0.30),
		"role": "on the griddle since five. Knows what nine hundred people want without any of them saying a full sentence.",
		"head": "cap",
		"relationships": ["a stranger", "a stranger", "a regular"],
		"rounds": [
			[{
				"words": [
					{"text": "What",    "word": "what",    "language": "english"},
					{"text": "you",     "word": "you",     "language": "english"},
					{"text": "want?",   "word": "want",    "language": "english"},
				],
				"responses": [
					{"gesture": "Say what the last man said",
						"words": "Repeat the five syllables.",
						"say": "I do not know what I have ordered and it is already cooking.",
						"style": "casual", "rep": 3},
					{"gesture": "Ask what there is",
						"words": "Open your hands at the griddle.",
						"say": "What do you have?",
						"style": "direct", "rep": -1},
					{"gesture": "Ask what he would have",
						"words": "Point at him. Then at yourself.",
						"say": "What would you have?",
						"style": "indirect", "rep": 1},
				],
			}],
			[{
				"words": [
					{"text": "Salt,",   "word": "salt",    "language": "english"},
					{"text": "pepper,", "word": "pepper",  "language": "english"},
					{"text": "ketchup?", "word": "ketchup", "language": "english"},
				],
				"responses": [
					{"gesture": "Answer at the speed he asked",
						"words": "Yes. Yes. No.",
						"say": "Three words back in the time he took to say three.",
						"style": "direct", "rep": 3},
					{"gesture": "Think about it",
						"words": "Pause. Consider.",
						"say": "Let me think - what does it normally come with?",
						"style": "formal", "rep": -2},
					{"gesture": "Say yes to all of it",
						"words": "Nod at everything.",
						"say": "All of it. Whatever it is.",
						"style": "casual", "rep": 1},
				],
			}],
		],
	},
}


const TORONTO := {
	"priya": {
		"name": "Priya", "region": "downtown", "color": Color(0.32, 0.34, 0.40),
		"role": "rides the same streetcar twice a day and has thanked the driver every single time.",
		"head": "none",
		"relationships": ["a passenger", "a passenger", "somebody who says it too"],
		"rounds": [
			[{
				"words": [
					{"text": "Sorry,",  "word": "sorry",   "language": "english"},
					{"text": "is",      "word": "is",      "language": "english"},
					{"text": "this",    "word": "this",    "language": "english"},
					{"text": "yours?",  "word": "yours",   "language": "english"},
				],
				"responses": [
					{"gesture": "Say sorry back, and answer",
						"words": "Sorry - no, not mine.",
						"say": "Neither of us has done anything. It is a doorbell, not an apology.",
						"style": "casual", "rep": 3},
					{"gesture": "Just answer",
						"words": "Shake your head.",
						"say": "No.",
						"style": "direct", "rep": 0},
					{"gesture": "Ask what she is sorry for",
						"words": "Point at her. Tilt your head.",
						"say": "Why are you sorry?",
						"style": "formal", "rep": -1},
				],
			}],
			[{
				"words": [
					{"text": "You",     "word": "you",     "language": "english"},
					{"text": "getting", "word": "getting", "language": "english"},
					{"text": "off",     "word": "off",     "language": "english"},
					{"text": "here?",   "word": "here",    "language": "english"},
				],
				"responses": [
					{"gesture": "Answer, and thank the driver on the way out",
						"words": "Yes - thanks!",
						"say": "Down the whole length of the car, at a man who will not turn round.",
						"style": "casual", "rep": 3},
					{"gesture": "Get off silently",
						"words": "Step down.",
						"say": "I get off the way I would get off anywhere.",
						"style": "direct", "rep": 0},
					{"gesture": "Ask if you are meant to say something",
						"words": "Point at the driver. Then at your mouth.",
						"say": "Am I supposed to say something to him?",
						"style": "indirect", "rep": 2},
				],
			}],
		],
	},
	"wes": {
		"name": "Wes", "region": "kensington", "color": Color(0.38, 0.32, 0.28),
		"role": "third generation in the same front room. Sells what his grandfather sold plus nine things his grandfather would not recognise.",
		"head": "cap",
		"relationships": ["a shopper", "a shopper", "a regular"],
		"rounds": [
			[{
				"words": [
					{"text": "Take",    "word": "take",    "language": "english"},
					{"text": "what",    "word": "what",    "language": "english"},
					{"text": "you",     "word": "you",     "language": "english"},
					{"text": "want.",   "word": "want",    "language": "english"},
				],
				"responses": [
					{"gesture": "Fill a bag yourself",
						"words": "Start picking things up.",
						"say": "Nobody is watching the crates. Nobody has ever watched the crates.",
						"style": "casual", "rep": 3},
					{"gesture": "Wait to be served",
						"words": "Stand still. Wait.",
						"say": "I will wait until somebody attends to me.",
						"style": "formal", "rep": -2},
					{"gesture": "Ask what is worth having",
						"words": "Point at two crates.",
						"say": "Which of these is any good?",
						"style": "direct", "rep": 2},
				],
			}],
			[{
				"words": [
					{"text": "Where",   "word": "where",   "language": "english"},
					{"text": "you",     "word": "you",     "language": "english"},
					{"text": "from?",   "word": "from",    "language": "english"},
				],
				"responses": [
					{"gesture": "Answer it straight",
						"words": "Very far. Not here.",
						"say": "Very far. Not here. Thank you for asking.",
						"style": "direct", "rep": 3},
					{"gesture": "Ask him first",
						"words": "Point at him.",
						"say": "Where are you from?",
						"style": "casual", "rep": 2},
					{"gesture": "Deflect",
						"words": "Shrug. Look at the crates.",
						"say": "Around.",
						"style": "indirect", "rep": 0},
				],
			}],
		],
	},
}
