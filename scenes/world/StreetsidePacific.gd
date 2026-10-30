extends Object

# Streetside encounters: the Pacific.
# Played through Streetside.spot() and the beat engine in Services._local().
#
# Sydney is the second city on the board the alien can read, and the second
# time reading turns out not to help. Most of what is gated here is not
# vocabulary - it is the difference between a sentence shaped like a question
# and a question.

const SPOTS := {

"sydney:circularquay": {
	"title": "The Quay",
	"start": "wharf",
	"beats": {
		"wharf": {
			"film": [
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "Five wharves, green and yellow boats going off all of them, a steel arch on one side and the shells on the other."},
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "stand"}, {"at": 0.58, "act": "wave"}],
					"say": "A woman in a high-visibility vest looks over and says four words at me that are shaped exactly like a question."},
			],
			"text": "Five wharves, green and yellow boats coming and going off all of them, a steel arch to your left and the shells to your right. A woman in a high-vis vest looks over and says: how ya going.",
			"rows": [
				{"id": "answer", "label": "Answer the question",
					"sub": "she asked how you are going, so tell her", "to": "answered"},
				{"id": "bounce", "label": "Say it straight back at her",
					"sub": "the same words, in the same tone, and keep walking",
					"to": "bounced"},
				{"id": "ferry", "label": "Get on a boat", "cost": 8, "to": "ferry"},
			],
		},
		"answered": {
			"text": "You start telling her. She waits, because she is polite, and something behind her eyes readjusts. It was not a question. It was the noise you make instead of hello.",
			"rep": -1,
			"learn": [["english", "going"], ["english", "mate"]],
			"rows": [
				{"id": "recover", "label": "Stop, and just say it back",
					"sub": "four words, no content, and move on", "to": "bounced"},
				{"id": "on", "label": "Finish the sentence anyway", "to": "long"},
			],
		},
		"bounced": {
			"text": "How ya going. Good thanks. That is the whole exchange and it contained no information and it worked perfectly, and she is already saying it to the next person.",
			"rep": 2,
			"rows": [
				{"id": "ferry", "label": "Get on a boat", "cost": 8, "to": "ferry"},
				{"id": "rocks", "label": "Walk up into the sandstone lanes",
					"to": "rocks"},
			],
		},
		"long": {
			"text": "She hears the whole thing. She is kind about it. At the end she says no worries mate and you are fairly sure that also meant nothing, and you are no longer certain which of you is being difficult.",
			"rep": 1,
			"rows": [{"id": "ferry", "label": "Get on a boat", "cost": 8,
				"to": "ferry"}],
		},
		"ferry": {
			"text": "The cheapest ticket in the city buys the view the whole place is priced against. Nobody on board looks up once. A man is doing a crossword with the bridge going past his ear.",
			"rep": 2,
			"rows": [
				{"id": "look", "label": "Look up the entire way",
					"sub": "like the only person here who has not seen it", "to": "looked"},
				{"id": "ok", "label": "Ride it back", "to": ""},
			],
		},
		"looked": {
			"text": "Twenty minutes with your face at the window. Somebody's grandmother catches you at it, and instead of finding it funny she points out the small beach you would not have seen.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Ride it back", "to": ""}],
		},
		"rocks": {
			"text": "Lanes cut out of the sandstone the buildings are made from, by people who were sent here as a punishment. There is a passage hacked straight through solid rock because going round was somebody else's problem.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Follow it through", "to": ""}],
		},
	},
},

"sydney:cbd": {
	"title": "Martin Place",
	"start": "plaza",
	"beats": {
		"plaza": {
			"film": [
				{"set": "tower", "secs": 3.6,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "A gold turret on a concrete stalk, three hundred metres up, and nothing else in the world looks like it."},
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.54, "act": "walk"}, {"at": 0.72, "act": "stand"}],
					"say": "In the plaza below it, a stone with names on it, and two men in suits crossing at speed."},
			],
			"text": "A pedestrian plaza between banks, a stone cenotaph in the middle of it, and a gold turret on a stalk three hundred metres up. Two men in suits are crossing at speed.",
			"rows": [
				{"id": "watch", "label": "Watch what the suits do at the stone",
					"to": "watched"},
				{"id": "tower", "label": "Go up the tower", "cost": 32, "to": "tower"},
			],
		},
		"watched": {
			"text": "They stop talking. Not both, and not for long, and nobody made them - one of them puts a hand out to slow the other for the length of the stone and then they resume mid-sentence.",
			"rep": 2,
			"rows": [
				{"id": "quiet", "label": "Do the same on your way past",
					"sub": "four seconds of nothing", "needs": "watched",
					"locked": "it is a lump of stone with names on it",
					"to": "quiet"},
				{"id": "tower", "label": "Go up the tower", "cost": 32, "to": "tower"},
			],
		},
		"quiet": {
			"text": "Four seconds. It is the only four seconds this square is quiet all day and it happens over and over, in ones and twos, without any of them arranging it.",
			"rep": 3,
			"rows": [{"id": "tower", "label": "Go up the tower", "cost": 32,
				"to": "tower"}],
		},
		"tower": {
			"text": "From up here the whole city is one harbour with buildings stuck round the edge of it, and every single thing of value is arranged to face the water. Out west, past the haze, it goes on for another fifty kilometres.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Come back down", "to": ""}],
		},
	},
},

"sydney:newtown": {
	"title": "King Street",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Two kilometres of shopfronts with iron lace over the footpath and nothing matching anything else."},
				{"set": "counter", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "sit"}, {"at": 0.52, "act": "stand"}, {"at": 0.7, "act": "hand_over"}],
					"say": "Through a pub door: a band, no cover charge, a dog asleep under the pool table, and nobody coming to any of the tables."},
			],
			"text": "Two kilometres of shopfronts with iron lace over the footpath and nothing matching anything. Through a pub door: a band, no cover charge, and a dog asleep under the pool table.",
			"rows": [
				{"id": "pub", "label": "Go into the pub", "to": "bar"},
				{"id": "mural", "label": "Find the painted face on the corner",
					"to": "mural"},
			],
		},
		"bar": {
			"text": "Nobody comes over. You sit at a table for a while and continue to be comprehensively un-served, while everyone else goes up to the counter and comes back carrying things.",
			"rows": [
				{"id": "wait", "label": "Keep waiting politely", "to": "waited"},
				{"id": "counter", "label": "Go up to the counter", "cost": 12,
					"to": "counter"},
			],
		},
		"waited": {
			"text": "Eleven minutes. Second country in a row that works this way and you have got it wrong in both. The barman has made eye contact twice and read it, both times, as you being fine.",
			"rep": -1,
			"rows": [
				{"id": "counter", "label": "Get up and go to the counter",
					"cost": 12, "to": "counter"},
				{"id": "go", "label": "Leave", "to": ""},
			],
		},
		"counter": {
			"text": "You order at the bar and carry it back yourself, which is the whole system. Three people at the next table are buying in turn - one of them gets the lot each round and it comes out even by closing.",
			"rep": 2,
			"learn": [["english", "round"], ["english", "shout"]],
			"rows": [
				{"id": "round", "label": "Buy the next round when it is your turn",
					"sub": "it is bookkeeping, not generosity", "cost": 12,
					"needs": "counter",
					"locked": "you have not worked out what they are doing with the drinks",
					"to": "round"},
				{"id": "ok", "label": "Stay for the band", "to": ""},
			],
		},
		"round": {
			"text": "You take your turn without being asked and the table adjusts around you without comment, which is the only acknowledgement it is ever going to get and is worth more than one.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay for the band", "to": ""}],
		},
		"mural": {
			"text": "A face painted on a shop wall in 1991 with four words under it. Developers have tried three times. The street has stopped them three times, and the street is not sentimental about much else.",
			"rep": 2,
			"rows": [{"id": "pub", "label": "Go and find the band", "to": "bar"}],
		},
	},
},

"sydney:bondi": {
	"title": "Between the flags",
	"start": "sand",
	"beats": {
		"sand": {
			"film": [
				{"set": "beach", "secs": 3.6, "prop": "flag", "prop_at": 0.3,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "A crescent of sand, and two pairs of red and yellow flags planted a hundred metres apart."},
				{"set": "beach", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.46, "act": "swim"}, {"at": 0.56, "act": "swim"}],
					"say": "Every person in the water is between them. The water either side is empty and looks identical and is calmer."},
			],
			"text": "A crescent of sand, a cream pavilion, and two pairs of red-and-yellow flags planted a hundred metres apart. Every person in the water is between them. The water either side looks identical.",
			"rows": [
				{"id": "ask", "label": "Work out why nobody swims outside them",
					"sub": "there is no rope and no sign and no one policing it",
					"to": "worked"},
				{"id": "wide", "label": "Swim where there is space",
					"sub": "the empty water is right there and it is empty",
					"to": "rip"},
				{"id": "pool", "label": "Go to the pool at the far end", "cost": 9,
					"to": "pool"},
			],
		},
		"worked": {
			"text": "The flat, calm, inviting strip past the flags is flat because it is moving. It is water leaving the beach. The choppy crowded part is the part that is safe, which is exactly backwards from how it looks.",
			"rep": 2,
			"learn": [["english", "rip"], ["english", "flags"]],
			"rows": [
				{"id": "between", "label": "Swim between the flags",
					"staging": {"set": "beach", "cast": [{"at": 0.25, "act": "swim"}, {"at": 0.5, "act": "swim"}, {"at": 0.75, "act": "swim"}]},
					"sub": "in the crowded, choppy, correct water", "needs": "worked",
					"locked": "the flags are two pieces of cloth", "to": "safe"},
				{"id": "wide", "label": "Swim in the calm part anyway", "to": "rip"},
			],
		},
		"safe": {
			"text": "Shoulder to shoulder with two hundred people in the worst-looking water on the beach, which is the best water on the beach, because somebody in a red cap read it this morning and put two flags where the reading came out safe.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Get out and dry off", "to": ""}],
		},
		"rip": {
			"text": "Forty seconds in, the beach is further away than it was, and you are not swimming badly. There is a red and yellow shape already in the water and moving, and it got there before you understood.",
			"rep": -2,
			"rows": [
				{"id": "float", "label": "Stop swimming and let it take you",
					"sub": "everything says fight it and everything is wrong",
					"needs": "worked",
					"locked": "every instinct you have says swim at the sand",
					"to": "float"},
				{"id": "fight", "label": "Swim straight at the beach", "to": "hauled"},
			],
		},
		"float": {
			"text": "You stop. It carries you out and then, past the break, it lets go, and you come in sideways with the waves. The man in the cap reaches you anyway and is extremely calm about all of it.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Sit on the sand a while", "to": ""}],
		},
		"hauled": {
			"text": "You swim at the beach until you have nothing left, and the beach stays where it is. Then somebody has you under the arms. On the sand he asks if you are right, and this time you know that is not a question about being correct.",
			"rep": -1,
			"rows": [{"id": "ok", "label": "Sit down for a long time", "to": ""}],
		},
		"pool": {
			"text": "An ocean bath cut into the rock at the end of the beach. You swim laps and the sea breaks over the end of the lane into your face. They built it to lose that argument on purpose.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Swim until your arms go", "to": ""}],
		},
	},
},

"sydney:cabramatta": {
	"title": "Freedom Plaza",
	"start": "arch",
	"beats": {
		"arch": {
			"film": [
				{"set": "gate", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "A gateway with green tile roofs and turned-up eaves, and a stone lion on each side of the road."},
				{"set": "counter/bakery", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "queue"}, {"at": 0.56, "act": "queue"}, {"at": 0.72, "act": "cut"}],
					"say": "Behind it a bakery with a queue, and the woman ahead of me orders the whole thing in about four words."},
			],
			"text": "A gateway with green tile roofs and turned-up eaves, a stone lion on each side, and behind it a street of low shopfronts under awnings. Thirty kilometres from the harbour and nothing here is for visitors.",
			"rows": [
				{"id": "read", "label": "Read the gateway",
					"sub": "there is a date on it and it is recent", "to": "read"},
				{"id": "bakery", "label": "Go into the bakery with the queue",
					"to": "queue"},
			],
		},
		"read": {
			"text": "Put up by people who arrived here after 1975 with nothing at all. The first thing they built once they could build was not a wall. It was a gate, with a sign on it saying which way in was.",
			"rep": 2,
			"rows": [{"id": "bakery", "label": "Join the queue at the bakery",
				"to": "queue"}],
		},
		"queue": {
			"text": "A French bread roll, filled the Vietnamese way, in an Australian suburb. The woman ahead of you orders in about four words. When you get there the woman behind the counter waits, and the queue behind you waits.",
			"rows": [
				{"id": "point", "label": "Point at the one in the case", "cost": 8,
					"to": "point"},
				{"id": "copy", "label": "Say what the woman ahead of you said",
					"sub": "you caught most of the sounds", "cost": 8, "to": "copy"},
			],
		},
		"point": {
			"text": "You get exactly what you pointed at and it is very good. Behind you the queue moves on and nothing at all was strange about any of it.",
			"rep": 1,
			"item": "banh_mi",
			"rows": [{"id": "ok", "label": "Eat it under the awnings", "to": ""}],
		},
		"copy": {
			"text": "You mangle it. She corrects one syllable, once, without stopping what her hands are doing, and then says it back to you properly and waits for you to have another go.",
			"rep": 3,
			"item": "banh_mi",
			"learn": [["english", "cabra"], ["english", "banhmi"]],
			"rows": [{"id": "ok", "label": "Say it again, better", "to": ""}],
		},
	},
},

}
