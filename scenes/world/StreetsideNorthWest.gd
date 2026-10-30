extends Object

# Streetside encounters: Berlin and London.
#
# The two cities the game was built around, and for a long time the only two
# with nothing to do in them. Every district in Paris, Sydney, Honolulu and
# thirteen others had a streetside institution to work out; Berlin - which is
# where the player lands - had four districts and not one thing on any street
# that asked anything of him.
#
# What is here is what these places actually run on and what a person who
# cannot read has to work out for himself: the deposit on a bottle, a box of
# things left out for free, the night the bins go out, a queue, and a train
# with nobody driving it.

const SPOTS := {

# ── Berlin ───────────────────────────────────────────────────────────────────

"berlin:mitte": {
	"title": "The Späti",
	"start": "counter",
	"beats": {
		"counter": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A shop the size of a corridor, open at an hour when nothing else is, with a fridge running the whole length of one wall."},
				{"set": "counter", "secs": 3.6, "prop": "coin", "prop_at": 0.50,
					"cast": [{"at": 0.30, "act": "stand"}, {"at": 0.64, "act": "offer"}],
					"say": "I put a bottle on the counter. The young woman on the till takes it back off me, opens it, and hands it over open. Nobody drinks it in here."},
			],
			"text": "A shop the width of a corridor that is open when nothing else is. The young woman on the till opens the bottle before she gives it back, which appears to be the arrangement, and everyone who buys one goes and sits on the step outside.",
			"rows": [
				{"id": "step", "label": "Sit on the step with it", "cost": 2,
					"to": "step"},
				{"id": "watch", "label": "Watch who else comes in", "to": "step"},
			],
		},
		"step": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "sit"}, {"at": 0.62, "act": "stand"}],
					"say": "Four people on one doorstep and none of them arrived together. This is not a bar. It is a step, and it is doing the work of one."},
			],
			"text": "Four strangers on the same doorstep, none of whom came together and none of whom are talking. The step is doing the work of a bar and costs nothing to sit on.",
			"rep": 1,
			"learn": [["german", "späti"], ["german", "feierabend"]],
			"rows": [
				{"id": "empty", "label": "Finish it and look for a bin",
					"to": "pfand"},
			],
		},
		"pfand": {
			"film": [
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.66, "act": "point"}],
					"say": "I go to put the empty in the bin and a man stops me. Not angrily. He points at the ledge beside the bin, where nine other bottles are standing in a row."},
			],
			"text": "The empty does not go in the bin. It goes on the ledge beside it, standing up, where nine others already are. A man with a bag comes along the row and takes them, and neither of us has said a word about why.",
			"rep": 2,
			"learn": [["german", "pfand"], ["german", "flasche"]],
			"rows": [
				{"id": "back", "label": "Take one back to the shop yourself",
					"to": "refund"},
				{"id": "ok", "label": "Leave it standing on the ledge", "to": ""},
			],
		},
		"refund": {
			"film": [
				{"set": "counter", "secs": 3.4, "prop": "coin", "prop_at": 0.50,
					"cast": [{"at": 0.32, "act": "hand_over"}, {"at": 0.64, "act": "take"}],
					"say": "I hand the empty bottle back over the counter and she gives me money for it. The bottle was never entirely mine. I was holding a deposit."},
			],
			"text": "He takes the empty and gives money back for it. The bottle was never sold to me; the deposit on it was lent to me, and half the people on this street are quietly earning it out of other people's bins.",
			"rep": 2,
			"coin": 2,
			"rows": [{"id": "ok", "label": "Put it in your pocket", "to": ""}],
		},
	},
},

"berlin:kiez": {
	"title": "The box beside the stall",
	"start": "crate",
	"beats": {
		"crate": {
			"film": [
				{"set": "field+stall", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.66, "act": "reach"}],
					"say": "A crate on the grass beside the stall with a word on the side in marker pen. A woman stops, reads it, takes something out and walks on. Nobody stops her."},
			],
			"text": "A crate on the grass with one word on the side in marker pen. A woman stops, reads it, takes something and walks on, and the man behind the trestle does not look up. Whatever the word says, it is permission, and it was written for anybody who could read it.",
			"rep": 2,
			"learn": [["german", "verschenken"]],
			"rows": [
				{"id": "take", "label": "Take something out of the crate",
					"to": "took"},
				{"id": "ok", "label": "Leave it alone", "to": ""},
			],
		},
		"took": {
			"text": "Nothing happens. No shout, no hand on my arm, nobody even turns round. It is the first thing this planet has given me for free and I only found out it was free by watching somebody else risk it first.",
			"rep": 2,
			"item": "apple",
			"rows": [{"id": "ok", "label": "Sit down on the grass with it", "to": ""}],
		},
	},
},

"berlin:prenzlberg": {
	"title": "Kollwitzplatz market",
	"start": "stalls",
	"beats": {
		"stalls": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Two rows of stalls under the trees and everything on them costs three times what it costs in the shop behind me."},
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.64, "act": "recoil"}],
					"say": "I pick up a tomato to look at it and the woman takes it out of my hand. Not unkindly. She puts it in the bag herself and holds the bag out."},
			],
			"text": "Two rows of stalls under the trees, everything on them three times the price of the shop behind me, and when I reach for a tomato the woman takes it out of my hand and bags it herself.",
			"rows": [
				{"id": "point", "label": "Point instead of reaching", "to": "pointed"},
				{"id": "watch", "label": "Watch how the others do it", "to": "pointed"},
			],
		},
		"pointed": {
			"text": "Everyone points. Nobody touches. The seller chooses which one you get and you take what you are given, and this is not rudeness on either side - it is the whole grammar of the transaction and it took me one wrong move to learn it.",
			"rep": 2,
			"learn": [["german", "markt"], ["german", "kilo"]],
			"rows": [
				{"id": "buy", "label": "Point at something and pay", "cost": 6,
					"to": "bought"},
				{"id": "ok", "label": "Walk the rows without buying", "to": ""},
			],
		},
		"bought": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "take"}, {"at": 0.66, "act": "hand_over"}],
					"say": "She adds one more than I pointed at and does not charge me for it. I have no way to ask why and no way to refuse."},
			],
			"text": "She puts one more in the bag than I asked for and does not charge for it. There is no word for what that is and no way to give it back without insulting her.",
			"rep": 2,
			"item": "tomatoes",
			"rows": [{"id": "ok", "label": "Take the bag", "to": ""}],
		},
	},
},

"berlin:kreuzberg": {
	"title": "Maybachufer",
	"start": "canal",
	"beats": {
		"canal": {
			"film": [
				{"set": "water+market", "secs": 3.4,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A market along a canal bank, twice a week, and half of what is shouted here is not the language of this country."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.62, "act": "offer"}],
					"say": "The same word twice, at the same pitch, over and over, and it is not aimed at me. It is aimed at the whole bank at once."},
			],
			"text": "A market strung along a canal bank twice a week, where half of what is shouted is not the language of the country it is in, and the shouting is not aimed at anybody in particular.",
			"rows": [
				{"id": "cloth", "label": "Look at the bolts of cloth", "to": "cloth"},
				{"id": "late", "label": "Wait until it starts packing up",
					"to": "late"},
			],
		},
		"cloth": {
			"text": "Bolts of fabric standing on end, eight deep, and the man cuts by holding the cloth against his own outstretched arm. That measurement is his body and it has not changed since he learned it.",
			"rep": 1,
			"learn": [["german", "stoff"], ["turkish", "kumaş"]],
			"rows": [
				{"id": "late", "label": "Stay until they pack up", "to": "late"},
				{"id": "ok", "label": "Move on", "to": ""},
			],
		},
		"late": {
			"film": [
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "offer"}],
					"say": "At the end the prices fall in the open. Nobody haggled all afternoon and now everything halves at once, for everyone, without being asked."},
			],
			"text": "In the last half hour the prices come down in the open, all of them, for everybody, without anyone asking. What would not move goes into crates and the crates go to the same two people every week.",
			"rep": 2,
			"learn": [["german", "feierabend"], ["turkish", "pazar"]],
			"rows": [
				{"id": "buy", "label": "Buy something at the fallen price",
					"cost": 3, "to": "cheap"},
				{"id": "ok", "label": "Watch the crates go", "to": ""},
			],
		},
		"cheap": {
			"text": "Three coins for what would have been nine at noon. The price was never a fact about the thing. It was a fact about the hour.",
			"rep": 1,
			"item": "bread",
			"rows": [{"id": "ok", "label": "Walk along the water with it", "to": ""}],
		},
	},
},

# ── London ───────────────────────────────────────────────────────────────────

"london:soho": {
	"title": "Outside the pub",
	"start": "pavement",
	"beats": {
		"pavement": {
			"film": [
				{"set": "street", "secs": 3.6, "prop": "glass", "prop_at": 0.74,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.56, "act": "stand"}, {"at": 0.7, "act": "stand"}],
					"say": "The pub is full, so the drinking has moved onto the pavement. It is not spilling out. It is where the evening is."},
				{"set": "counter", "secs": 3.4,
					"cast": [{"at": 0.36, "act": "stand"}, {"at": 0.62, "act": "hand_over"}],
					"say": "Nobody comes to a table. They go to the counter, say a thing, and carry it out themselves."},
			],
			"text": "The pub is full so the drinking has moved onto the pavement, and it is not spilling out - it is where the evening is. Nobody inside is taking orders from anybody standing up.",
			"rows": [
				{"id": "table", "label": "Find a table and wait", "to": "waited"},
				{"id": "bar", "label": "Go to the counter", "cost": 6, "to": "served"},
			],
		},
		"waited": {
			"text": "Nine minutes at a table nobody comes to. Two people have made eye contact with you and read it, correctly, as a man who is fine. There is no table service and there never was.",
			"rep": -1,
			"learn": [["english", "round"], ["english", "yours"]],
			"rows": [
				{"id": "bar", "label": "Get up and go to the counter", "cost": 6,
					"to": "served"},
				{"id": "go", "label": "Leave", "to": ""},
			],
		},
		"served": {
			"text": "You order standing at the counter and carry it out yourself. On the pavement, four people are drinking and only ever one of them is at the bar at a time, and it is a different one each time.",
			"rep": 2,
			"rows": [
				{"id": "watch", "label": "Work out the pattern", "to": "round"},
				{"id": "ok", "label": "Stand and drink it", "to": ""},
			],
		},
		"round": {
			"text": "Each of them buys for all of them, in turn. It comes out even by closing time. It is not generosity, it is bookkeeping, and leaving before your turn is a thing they will remember for years.",
			"rep": 2,
			"rows": [
				{"id": "buy", "label": "Take your turn", "cost": 24,
					"sub": "all four, because that is what a turn is", "needs": "round",
					"locked": "you have not worked out what they are doing",
					"to": "took"},
				{"id": "ok", "label": "Finish yours and go", "to": ""},
			],
		},
		"took": {
			"text": "You come back with four and put them down and nobody thanks you, because thanking you would imply it was a favour. One of them moves along the wall to make room and that is the receipt.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay for the next one", "to": ""}],
		},
	},
},

"london:brixton": {
	"title": "Electric Avenue",
	"start": "road",
	"beats": {
		"road": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.6, "act": "offer"}],
					"say": "The first market street in this country to be lit by electricity, and it is still a market."},
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.58, "act": "cut"}],
					"say": "Yam, plantain, salt fish, phone cases, wigs, and four languages before the first corner."},
			],
			"text": "The first market street in the country to be lit by electricity, still a market. Yam, plantain, salt fish, phone cases, wigs, and four languages before the first corner.",
			"rows": [
				{"id": "walk", "label": "Walk the length of it", "to": "walked"},
				{"id": "mural", "label": "Find the painted face people leave flowers under",
					"to": "mural"},
			],
		},
		"walked": {
			"text": "None of the food on this street is from this country and most of it has been here longer than the people arguing about whether it belongs. That appears to be the actual history of the road.",
			"rep": 2,
			"learn": [["english", "endz"], ["english", "safe"]],
			"rows": [
				{"id": "buy", "label": "Buy something you cannot identify",
					"cost": 4, "to": "bought"},
				{"id": "mural", "label": "Go and find the mural", "to": "mural"},
			],
		},
		"bought": {
			"text": "The woman selling it asks where you are from, and when you cannot answer she tells you how to cook it anyway, twice, slowly, and then writes the second way on the bag.",
			"rep": 3,
			"item": "brixton_bag",
			"rows": [{"id": "mural", "label": "Go and find the mural", "to": "mural"}],
		},
		"mural": {
			"text": "A face on a shop wall with flowers under it that somebody has replaced this week. He was from somewhere else in this city, and this street has decided he was from here.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Stand with it a minute", "to": ""}],
		},
	},
},
"london:terrace": {
	"title": "Bin night",
	"start": "wheelie",
	"beats": {
		"wheelie": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Every house on this street has put a wheeled bin out at the kerb this evening. Not one of them did it yesterday."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "haul"}],
					"say": "Two colours of lid, and each house has put out only one of the two. Whatever decides which is not written on the bin."},
			],
			"text": "Every house on the terrace has wheeled a bin out to the kerb this evening and none of them did it yesterday. There are two colours of lid and each house has put out only one.",
			"rows": [
				{"id": "count", "label": "Count which colour is out tonight",
					"to": "counted"},
				{"id": "leaflet", "label": "Read the card taped inside a lid",
					"to": "leaflet"},
			],
		},
		"counted": {
			"text": "Green tonight, all the way down. The black ones are still in the passages. So the two colours alternate, and every household on this street is holding a calendar in their head that nobody says out loud.",
			"rep": 2,
			"learn": [["english", "recycling"], ["english", "collection"]],
			"rows": [
				{"id": "leaflet", "label": "Look at the card in the lid",
					"to": "leaflet"},
				{"id": "ok", "label": "Walk to the end of the terrace", "to": ""},
			],
		},
		"leaflet": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "write"}],
					"say": "A printed card taped inside the lid, a grid of dates, two colours. It is the whole answer and it is the one form of it I cannot use."},
			],
			"text": "A printed card taped inside the lid: a grid of dates in two colours. It is the entire answer, stated plainly, in the one form I have no access to. The street around me is running on it perfectly.",
			"rep": 1,
			"rows": [
				{"id": "copy", "label": "Copy the pattern from the street instead",
					"to": "counted"},
				{"id": "ok", "label": "Close the lid", "to": ""},
			],
		},
	},
},

"london:highstreet": {
	"title": "The charity shop",
	"start": "window",
	"beats": {
		"window": {
			"film": [
				{"set": "counter/clothes", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A shop full of other people's coats, all of them worn, all of them cheap, and a woman behind the till who is not being paid to be there."},
				{"set": "counter/clothes", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.66, "act": "stand"}],
					"say": "The prices are handwritten on stickers. Nothing matches anything. Somebody's whole wardrobe is on this rail and they are not coming back for it."},
			],
			"text": "A shop full of secondhand coats with handwritten prices, and a woman behind the till who is plainly not being paid to stand there. Somebody's entire wardrobe is on one rail and nobody is coming back for it.",
			"rows": [
				{"id": "rail", "label": "Go through the rail", "to": "rail"},
				{"id": "till", "label": "Watch what happens at the till",
					"to": "till"},
			],
		},
		"rail": {
			"text": "Four pounds for a coat that cost somebody eighty. It is not a market and it is not charity to me - the money goes somewhere else entirely, to a thing I cannot read the name of on the window.",
			"rep": 1,
			"learn": [["english", "charity"], ["english", "donation"]],
			"rows": [
				{"id": "buy", "label": "Buy the coat", "cost": 4, "to": "bought"},
				{"id": "till", "label": "Watch the till instead", "to": "till"},
			],
		},
		"till": {
			"film": [
				{"set": "counter/clothes", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "hand_over"}, {"at": 0.64, "act": "take"}],
					"say": "A man comes in with a bag, hands it over, takes nothing, and leaves. No money moved in either direction."},
			],
			"text": "A man comes in with a full bag, hands it across the counter, takes nothing and leaves. No money moves in either direction. The shop runs on things people have finished with.",
			"rep": 2,
			"rows": [
				{"id": "buy", "label": "Buy something off the rail", "cost": 4,
					"to": "bought"},
				{"id": "ok", "label": "Leave without buying", "to": ""},
			],
		},
		"bought": {
			"text": "She folds it, puts it in a used bag, and says something short and warm that I do not catch. The coat is warmer than mine and cost less than a meal.",
			"rep": 2,
			"item": "coat",
			"rows": [{"id": "ok", "label": "Put it on outside", "to": ""}],
		},
	},
},

"london:docklands": {
	"title": "The front of the train",
	"start": "platform",
	"beats": {
		"platform": {
			"film": [
				{"set": "station", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "queue"}],
					"say": "The train comes in on a rail above the road and stops. I look along it for the front window and the driver's seat is a passenger seat."},
				{"set": "station", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.62, "act": "sit"}],
					"say": "A child gets in first and takes it, the way you would take the best seat in a cinema. Everyone else lets her."},
			],
			"text": "The train comes in on a rail above the road and there is no driver in it. The seat where a driver would sit is a passenger seat, and a child takes it first while everyone else lets her.",
			"rows": [
				{"id": "front", "label": "Sit at the front", "to": "front"},
				{"id": "look", "label": "Look for whoever is driving", "to": "nobody"},
			],
		},
		"nobody": {
			"text": "There is a person on board, walking the carriages with a machine, and they are not driving it. Nothing on this train is being steered by anybody I can see, and not one passenger has looked up.",
			"rep": 1,
			"learn": [["english", "automatic"], ["english", "carriage"]],
			"rows": [
				{"id": "front", "label": "Take the front seat", "to": "front"},
				{"id": "ok", "label": "Sit down anywhere", "to": ""},
			],
		},
		"front": {
			"film": [
				{"set": "station", "secs": 4.0,
					"cast": [{"at": 0.34, "act": "sit"}],
					"say": "The rail goes between the towers at the height of the fourth floor. Offices on both sides, level with me, lit, and everyone in them working with their backs to the window."},
				{"set": "station", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "sit"}, {"at": 0.66, "act": "watch"}],
					"say": "It slows without being asked and stops exactly where the doors line up. Whatever is deciding that is not in this carriage."},
			],
			"text": "From the front seat the rail runs between the towers at the height of a fourth floor, offices lit on both sides and everybody in them working with their backs to the glass. The train slows, stops and lines its doors up without anybody in it deciding to.",
			"rep": 2,
			"learn": [["english", "platform"], ["english", "doors"]],
			"rows": [{"id": "ok", "label": "Ride it to the end", "to": ""}],
		},
	},
},

}
