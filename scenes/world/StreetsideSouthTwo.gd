extends Object

# Streetside encounters: the second district of each city in Africa and Latin
# America. Split from StreetsideSouth.gd by size alone.
#
# The tailors really do work on the pavement in the Medina; cloth in Sandaga
# really is sold by the pagne and not by the metre; a casera really does give
# you the yapa once she knows you; and the man with the barrel organ in Mexico
# City really is wearing that uniform, and it is beige, and it is a licence.

const SPOTS := {

# ── Dakar ────────────────────────────────────────────────────────────────────

"dakar:medina": {
	"title": "The tailor on the step",
	"start": "machine",
	"beats": {
		"machine": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A treadle machine on the pavement outside the shop rather than inside it, and a man working it with a rhythm his foot is doing without him."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "cut"}],
					"say": "A woman brings cloth she bought somewhere else. He does not sell cloth. He sells what happens to it."},
			],
			"text": "A treadle machine out on the pavement, and a man working it with a foot that stopped needing his attention years ago. Customers arrive carrying cloth they bought somewhere else.",
			"rows": [
				{"id": "cloth", "label": "Go and find cloth first", "to": "cloth"},
				{"id": "watch", "label": "Watch him measure somebody", "to": "measure"},
			],
		},
		"measure": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "reach"}],
					"say": "No tape. He puts two fingers on a shoulder, then a forearm against a back, and writes three numbers on the edge of a newspaper."},
			],
			"text": "There is no tape measure anywhere. He touches a shoulder, lays a forearm along a back, and writes three numbers in the margin of a newspaper. The garment will fit.",
			"rep": 2,
			"learn": [["wolof", "yere"], ["wolof", "ñaata"]],
			"rows": [
				{"id": "cloth", "label": "Go and buy cloth", "to": "cloth"},
				{"id": "ok", "label": "Watch until the machine stops", "to": ""},
			],
		},
		"cloth": {
			"text": "The cloth is sold four streets away by the pagne and never by the metre, so I come back with more than I need, which everybody knew I would.",
			"rep": 1,
			"item": "wax_cloth",
			"rows": [
				{"id": "order", "label": "Hand him the cloth", "cost": 12,
					"to": "ordered"},
				{"id": "ok", "label": "Keep it folded under your arm", "to": ""},
			],
		},
		"ordered": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "hand_over"}, {"at": 0.66, "act": "take"}],
					"say": "He takes the cloth, looks at it, and says a day. I do not know which day. I will find out by coming back and being wrong twice."},
			],
			"text": "He takes it, looks at the pattern, and names a day. I have no idea which day. The arrangement rests entirely on both of us coming back to the same piece of pavement.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Try to remember the corner", "to": ""}],
		},
	},
},

"dakar:sandaga": {
	"title": "Six yards or nothing",
	"start": "bolts",
	"beats": {
		"bolts": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Wax print stacked to the ceiling in a stall two metres wide, and every bolt has a pattern with a name that everybody except me knows."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "point"}, {"at": 0.62, "act": "offer"}],
					"say": "I point at a length of it and hold up one finger. He shakes his head and holds up six, and it is not a negotiation, it is arithmetic."},
			],
			"text": "Wax print stacked to the ceiling. Every pattern has a name and a meaning and a reason people will or will not wear it this year. I point at one and hold up a finger, and he holds up six.",
			"rows": [
				{"id": "six", "label": "Buy the six yards", "cost": 16, "to": "six"},
				{"id": "why", "label": "Find out why it is six", "to": "why"},
			],
		},
		"why": {
			"text": "Six yards is what a boubou takes, and a wrapper, and the head-tie, out of one cloth so the pattern matches across all three. Selling you two would be selling you a problem.",
			"rep": 2,
			"learn": [["wolof", "boubou"], ["wolof", "juróom-benn"]],
			"rows": [
				{"id": "six", "label": "Buy the six yards", "cost": 16, "to": "six"},
				{"id": "ok", "label": "Leave it on the shelf", "to": ""},
			],
		},
		"six": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "take"}, {"at": 0.64, "act": "cut"}],
					"say": "He tears it rather than cutting it, along a thread, in one movement, and the edge comes off straighter than any scissors I have seen used."},
			],
			"text": "He tears it along the thread in one movement and the edge is straighter than a cut. Then he folds it into a square the size of a book and puts it in my hands without a bag.",
			"rep": 3,
			"item": "wax_cloth",
			"rows": [{"id": "ok", "label": "Carry it the way he handed it over",
				"to": ""}],
		},
	},
},

# ── La Paz ───────────────────────────────────────────────────────────────────

"lapaz:elalto": {
	"title": "Feria 16 de Julio",
	"start": "edge",
	"beats": {
		"edge": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "It goes further than I can see in either direction, and it is Thursday, and it will do this again on Sunday, and it is not a special occasion."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "carry"}],
					"say": "Car doors. Whole car doors, laid out in rows by make. Two rows along, wool. Two rows after that, somebody's television."},
			],
			"text": "A market that runs to the horizon in both directions, twice a week, on a plateau four thousand metres up. Car doors sorted by make. Wool. Televisions. Nobody is treating any of it as remarkable.",
			"rows": [
				{"id": "weigh", "label": "Try to buy food", "to": "scale"},
				{"id": "walk", "label": "Walk until it ends", "to": "endless"},
			],
		},
		"endless": {
			"text": "Forty minutes in one direction and it has not thinned. Somebody tells me a number of kilometres with their hands. I do not believe the number and I have no argument against it.",
			"rep": 2,
			"learn": [["spanish_bo", "feria"], ["spanish_bo", "jueves"]],
			"rows": [
				{"id": "weigh", "label": "Go back and buy something", "to": "scale"},
				{"id": "ok", "label": "Turn round", "to": ""},
			],
		},
		"scale": {
			"film": [
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.64, "act": "count"}],
					"say": "A brass scale hanging off the frame of the stall, a stone in one pan, and whatever I am buying in the other, and no numbers on anything."},
			],
			"text": "The scale hangs off the stall frame. A stone sits in one pan. Nothing is marked with a number and the price is a fact about the stone, which everybody but me already knows the weight of.",
			"rep": 2,
			"learn": [["spanish_bo", "libra"]],
			"rows": [
				{"id": "buy", "label": "Pay whatever the stone says", "cost": 5,
					"to": "bought"},
				{"id": "ok", "label": "Watch two more people do it first", "to": ""},
			],
		},
		"bought": {
			"text": "The stone was right and the price was small and she has put in one more than the stone allowed, without looking at me, while looking at the next person.",
			"rep": 2,
			"item": "potatoes",
			"rows": [{"id": "ok", "label": "Take the bag", "to": ""}],
		},
	},
},

"lapaz:rodriguez": {
	"title": "Your casera",
	"start": "row",
	"beats": {
		"row": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Thirty women selling the same four things at the same price down one street on a slope, and every customer walks past twenty of them to get to one."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "offer"}],
					"say": "The woman ahead of me is not asked what she wants. It is already in the bag by the time she has stopped walking."},
			],
			"text": "Thirty stalls selling the same things at the same prices, and everybody walking past twenty of them to reach one particular woman. The person ahead of me is handed her bag before she has said anything.",
			"rows": [
				{"id": "pick", "label": "Pick one and buy from her", "cost": 4,
					"to": "first"},
				{"id": "watch", "label": "Work out why they walk past the rest",
					"to": "why"},
			],
		},
		"why": {
			"text": "Because she is theirs. You have a casera, and she has you, and after that the price stops being a question and becomes a thing that was settled a long time ago between the two of you.",
			"rep": 2,
			"learn": [["spanish_bo", "casera"], ["spanish_bo", "siempre"]],
			"rows": [
				{"id": "pick", "label": "Pick one and start", "cost": 4,
					"to": "first"},
			],
		},
		"first": {
			"film": [
				{"set": "stall", "secs": 3.6, "prop": "coin", "prop_at": 0.58,
					"cast": [{"at": 0.30, "act": "hand_over"}, {"at": 0.64, "act": "take"}],
					"say": "The first time she counts it exactly. She does not smile and she is not unfriendly. I am nobody yet."},
			],
			"text": "The first time it is exact. She is not cold about it; I am simply not anybody yet. Somewhere in this arrangement there is a second time, and a third, and after that it changes.",
			"rep": 1,
			"item": "potatoes",
			"rows": [
				{"id": "again", "label": "Come back to the same stall tomorrow",
					"cost": 4, "to": "yapa"},
				{"id": "ok", "label": "Take the bag and go", "to": ""},
			],
		},
		"yapa": {
			"film": [
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "take"}, {"at": 0.66, "act": "offer"}],
					"say": "Same stall, same price, and then she puts one more in on top without saying anything about it or looking up."},
			],
			"text": "Same stall, same money, and one more goes in on top of what I paid for. She does not mention it. It is not a discount and it is not a gift; it is the difference between a customer and a regular, and I have just crossed it.",
			"rep": 3,
			"learn": [["spanish_bo", "yapa"]],
			"item": "potatoes",
			"rows": [{"id": "ok", "label": "Come back on Thursday too", "to": ""}],
		},
	},
},

# ── Mexico City ──────────────────────────────────────────────────────────────

"mexico:merced": {
	"title": "Golpe",
	"start": "aisle",
	"beats": {
		"aisle": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Chillies in sacks by the hundredweight, sorted by a system of colour and size that clearly matters enormously and that I cannot see the shape of."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.26, "act": "recoil"}, {"at": 0.58, "act": "push"},
						{"at": 0.74, "act": "walk"}],
					"say": "A word behind me, once, loud, and everybody moves sideways without turning round, and a stack of crates on two wheels goes through the space they made."},
			],
			"text": "The largest market I have stood in. Chillies in hundredweight sacks sorted by something I cannot read. Behind me a word goes off like a horn and the entire aisle steps sideways without looking.",
			"rows": [
				{"id": "learn", "label": "Learn the word", "to": "word"},
				{"id": "slow", "label": "Fail to move fast enough", "to": "clipped"},
			],
		},
		"clipped": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.30, "act": "recoil"}, {"at": 0.64, "act": "push"}],
					"say": "It catches my shoulder. Nobody stops. Nobody is angry. The word was said and the word was the whole of the warning."},
			],
			"text": "It catches my shoulder and goes on. Nobody stops and nobody is annoyed, because the word was said, and in this building the word is the entire safety system.",
			"rep": 1,
			"rows": [{"id": "learn", "label": "Learn the word", "to": "word"}],
		},
		"word": {
			"text": "One syllable, shouted, meaning: I am coming through with three hundred kilos and I cannot stop. Everybody in this market knows it, including the children, and now including me.",
			"rep": 3,
			"learn": [["spanish_mx", "golpe"], ["spanish_mx", "aguas"]],
			"rows": [
				{"id": "carry", "label": "Follow one to see where they go",
					"to": "follow"},
				{"id": "ok", "label": "Stand somewhere out of the lane", "to": ""},
			],
		},
		"follow": {
			"text": "Out to a van, back in empty, sixty seconds turnaround, all day. He is paid by the trip and the trip is measured in aisles, which is why the word exists.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Let him past", "to": ""}],
		},
	},
},

"mexico:juarez": {
	"title": "The organillero",
	"start": "corner",
	"beats": {
		"corner": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A beige uniform with a cap, a wooden box on a stand, and a handle he is turning at exactly the same speed he was turning it four minutes ago."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "scrub"}],
					"say": "The tune is coming out slightly wrong in a way that is not his fault. Something inside it went out of tune before he was born and stayed that way."},
			],
			"text": "A man in a beige uniform and cap turning the handle of a wooden box on a stand. The tune comes out slightly wrong and has done for eighty years, and the wrongness is now part of the tune.",
			"rows": [
				{"id": "hat", "label": "Watch how he is paid", "to": "hat"},
				{"id": "coin", "label": "Put a coin in", "cost": 2, "to": "coin"},
			],
		},
		"hat": {
			"film": [
				{"set": "street", "secs": 3.6, "prop": "coin", "prop_at": 0.60,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "take"}],
					"say": "A second man walks the pavement with the cap held out while the first one never stops turning. It takes two of them and only one of them plays."},
			],
			"text": "There are two of them. One turns the handle and never stops; the other works the pavement with the cap. Stopping would cost more than the coin is worth, so nobody stops.",
			"rep": 2,
			"learn": [["spanish_mx", "organillero"], ["spanish_mx", "propina"]],
			"rows": [
				{"id": "coin", "label": "Put a coin in the cap", "cost": 2,
					"to": "coin"},
				{"id": "ok", "label": "Listen to the end of the tune", "to": ""},
			],
		},
		"coin": {
			"film": [
				{"set": "street", "secs": 3.4, "prop": "coin", "prop_at": 0.52,
					"cast": [{"at": 0.32, "act": "hand_over"}, {"at": 0.66, "act": "bow"}],
					"say": "A nod, no words, and the handle does not change speed. The transaction did not interrupt anything, which is how it is designed."},
			],
			"text": "A nod, and the handle keeps its speed. The uniform is a licence, the box is nearly a century old, and there are fewer of them every year, which everybody here says out loud to each other and not to me.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Walk on with the tune behind you",
				"to": ""}],
		},
	},
},

# ── São Paulo ────────────────────────────────────────────────────────────────

"saopaulo:liberdade": {
	"title": "Sunday under the lamps",
	"start": "lamps",
	"beats": {
		"lamps": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "look_up"}],
					"say": "Red lamps down the whole street on steel posts, shaped like something that grows, and nobody under them is looking up at them."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "queue"}, {"at": 0.62, "act": "cut"}],
					"say": "It is Sunday and the square has filled with folding tables. A woman is frying something in a pan the size of a bicycle wheel."},
			],
			"text": "Red lamps the length of the street, shaped like lily-of-the-valley, put up by a community that came here a century ago. On Sunday the square underneath fills with folding tables and fryers.",
			"rows": [
				{"id": "eat", "label": "Buy whatever is being fried", "cost": 5,
					"to": "fried"},
				{"id": "look", "label": "Look at what else is on the tables",
					"to": "tables"},
			],
		},
		"tables": {
			"text": "Rice cakes, a man selling seeds, three tables of manga, one of tools, one of somebody's grandmother's crockery. Half the signs are in two alphabets and neither of them is one I can read.",
			"rep": 2,
			"learn": [["portuguese", "feira"], ["portuguese", "domingo"]],
			"rows": [
				{"id": "eat", "label": "Buy whatever is being fried", "cost": 5,
					"to": "fried"},
				{"id": "ok", "label": "Walk the whole square", "to": ""},
			],
		},
		"fried": {
			"film": [
				{"set": "counter/food", "secs": 3.6, "prop": "smoke", "prop_at": 0.36,
					"cast": [{"at": 0.32, "act": "take"}, {"at": 0.66, "act": "offer"}],
					"say": "Enormous, thin, blistered, and folded over something I did not choose. She hands it to me on a napkin the size of a stamp and that is the whole of the packaging."},
			],
			"text": "Enormous and thin and blistered, folded over something I did not choose, handed over on a napkin the size of a stamp. It is Japanese in this square and it is entirely Brazilian on the plate.",
			"rep": 3,
			"item": "pastel",
			"learn": [["portuguese", "pastel"]],
			"rows": [{"id": "ok", "label": "Eat it standing at the table", "to": ""}],
		},
	},
},

"saopaulo:bixiga": {
	"title": "The Sunday junk fair",
	"start": "praca",
	"beats": {
		"praca": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A small square, a hundred cloths on the ground, and on each cloth the entire contents of a drawer from a flat somewhere in this city."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "reach"}, {"at": 0.62, "act": "sit"}],
					"say": "The man whose cloth this is does not get up, does not greet me, and does not mind me handling any of it. He is reading."},
			],
			"text": "A square full of cloths on the ground, each one holding the contents of somebody's drawer. Nobody gets up when you stop. Nobody minds you handling anything.",
			"rows": [
				{"id": "dig", "label": "Go through one cloth properly", "to": "dig"},
				{"id": "cantina", "label": "Follow the smell out of the square",
					"to": "cantina"},
			],
		},
		"dig": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "reach"}, {"at": 0.66, "act": "count"}],
					"say": "Keys to nothing, a tin of buttons, six photographs of people nobody here can name, and a small brass thing whose whole purpose has been forgotten."},
			],
			"text": "Keys to nothing. A tin of buttons. Photographs of people nobody at this stall could name. The price of any of it is whatever he says when you finally hold one up, and he only looks up then.",
			"rep": 2,
			"learn": [["portuguese", "quanto"], ["portuguese", "antiguidade"]],
			"rows": [
				{"id": "buy", "label": "Hold one up", "cost": 6, "to": "bought"},
				{"id": "cantina", "label": "Follow the smell instead",
					"to": "cantina"},
			],
		},
		"bought": {
			"text": "He says a number, I hand it over, and he goes back to his book without wrapping it, because it was in somebody's drawer for forty years and it will survive my pocket.",
			"rep": 2,
			"item": "brass_thing",
			"rows": [{"id": "ok", "label": "Put it away", "to": ""}],
		},
		"cantina": {
			"film": [
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "carry"}],
					"say": "Checked cloths, a room of long tables, and an Italian surname on the window in a quarter of a Brazilian city where nobody at the tables is speaking Italian."},
			],
			"text": "Checked cloths and long shared tables, an Italian surname on the glass, and not one word of Italian being spoken in the room. The food stayed. The language went. Nobody in here finds that strange.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Sit at the end of a long table",
				"to": ""}],
		},
	},
},

}
