extends Object

# Streetside encounters: Russia, Georgia and Turkey.
# Played through Streetside.spot() and the beat engine in Services._local().
#
# Split from StreetsideWest.gd purely on file size; these three sit together
# because all three run on a rule about who speaks first and what that costs.

const SPOTS := {

# ── Moscow ───────────────────────────────────────────────────────────────────

"moscow:izmaylovo": {
	"title": "Vernisazh",
	"start": "stalls",
	"beats": {
		"stalls": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "offer"}],
					"say": "Trays of small enamel badges, hundreds of them, off the coats of a country that stopped existing."},
				{"set": "market", "secs": 3.6, "prop": "coin", "prop_at": 0.74,
					"cast": [{"at": 0.32, "act": "stand"}, {"at": 0.58, "act": "hand_over"}],
					"say": "He names a number, and something in his face says the number is an opening remark rather than a price."},
			],
			"text": "Trays of Soviet lapel badges, fur hats, samovars, and a wooden kremlin built in the nineties that is pretending to be four hundred years old. A man has four hundred badges and a price for each.",
			"rows": [
				{"id": "pay", "label": "Pay what he asks", "cost": 300, "to": "paid"},
				{"id": "half", "label": "Offer him half", "to": "half"},
				{"id": "kremlin", "label": "Go and look at the fake kremlin",
					"to": "kremlin"},
			],
		},
		"half": {
			"text": "He laughs - a real one, from the chest - and comes back at two-thirds, and he is enjoying this more than he was thirty seconds ago. Four cities and this is the first place where arguing was the polite move.",
			"rep": 2,
			"learn": [["russian", "skolko"], ["russian", "dorogo"]],
			"rows": [
				{"id": "meet", "label": "Meet him in the middle", "cost": 200,
					"to": "shook"},
				{"id": "walk", "label": "Shrug and turn away", "to": "walked"},
			],
		},
		"shook": {
			"text": "He wraps it, shakes your hand, and holds the shake a beat longer than the sale needed. A small enamel thing off a coat, from a country that stopped existing, and now it is yours.",
			"rep": 3,
			"item": "soviet_badge",
			"rows": [{"id": "kremlin", "label": "Go and look at the kremlin",
				"to": "kremlin"}],
		},
		"walked": {
			"text": "Two steps. He says a number at your back that is below anything either of you has said, and he is grinning when you turn round, because you have finally started playing.",
			"rep": 2,
			"rows": [
				{"id": "back", "label": "Take it", "cost": 150, "to": "shook"},
				{"id": "gone", "label": "Keep walking", "to": "kremlin"},
			],
		},
		"paid": {
			"text": "He takes the money immediately and without pleasure. You have paid the asking price at a flea market, which is the one place on earth where the asking price is a conversational opening.",
			"rep": -1,
			"item": "soviet_badge",
			"rows": [{"id": "kremlin", "label": "Go and look at the kremlin",
				"to": "kremlin"}],
		},
		"kremlin": {
			"text": "Painted wood, onion domes, towers, all of it built in the nineteen-nineties as a market. Everyone knows. Nobody minds. It is the only thing here that is honest about being a copy.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Walk round it", "to": ""}],
		},
	},
},

"moscow:arbat": {
	"title": "Stena Tsoya",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "A street with no cars on it, buskers every forty metres, and all of them playing the same four notes."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.34, "act": "watch"}, {"at": 0.62, "act": "reach"}],
					"say": "One wall covered edge to edge in handwriting, forty years deep, with fresh flowers at the bottom of it."},
			],
			"text": "A pedestrian street of buskers and portrait painters, and halfway down it one wall covered edge to edge in handwriting. Somebody has left flowers at the bottom of it today.",
			"rows": [
				{"id": "read", "label": "Look at the wall", "to": "wall"},
				{"id": "busk", "label": "Stop at the busker", "to": "busker"},
			],
		},
		"wall": {
			"text": "One name, over and over, in a hundred hands, going back forty years. Under it, in the same paint, the same short phrase again and again as though it were an argument nobody has finished.",
			"rep": 2,
			"learn": [["russian", "zhiv"], ["russian", "pesnya"]],
			"rows": [
				{"id": "ask", "label": "Ask somebody who he was", "to": "asked"},
				{"id": "clean", "label": "Notice that nobody cleans it", "to": "clean"},
			],
		},
		"asked": {
			"text": "The man you ask does not explain. He sings you four notes, badly, and then waits, and when nothing happens on your face he shrugs and is not disappointed, because it was never going to travel.",
			"rep": 2,
			"rows": [{"id": "clean", "label": "Look at the wall again", "to": "clean"}],
		},
		"clean": {
			"text": "Forty years of paint on a wall on the most walked street in the city, and it is never cleaned. Cleaning it is the single thing that would be an insult, and so the city simply does not.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Add nothing and go", "to": ""}],
		},
		"busker": {
			"text": "He is playing the four notes. So, further down, is somebody else. It has been the same four notes on this street for four decades and you have walked past them twice without hearing it.",
			"rep": 1,
			"rows": [{"id": "wall", "label": "Go and find the wall", "to": "wall"}],
		},
	},
},

"moscow:zamoskvorechye": {
	"title": "Across the river",
	"start": "lane",
	"beats": {
		"lane": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Low houses and small churches and not one tower. The other side of the river decided to stay the size it was."},
				{"set": "gate", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "bow"}],
					"say": "At the gate of the churchyard every woman does something with a scarf, at the same invisible line, and no line is painted there."},
			],
			"text": "The old merchants' quarter: low houses, small churches, no towers at all. A gate into a churchyard, and every woman going through it does something at the threshold with a scarf.",
			"rows": [
				{"id": "watch", "label": "Watch the gate before you go in",
					"to": "watched"},
				{"id": "in", "label": "Walk in", "to": "raw"},
				{"id": "gallery", "label": "Go to the gallery instead", "cost": 700,
					"to": "gallery"},
			],
		},
		"watched": {
			"text": "On at the gate, off at the gate. Men take a hat off at the same line. There is no line painted on the ground and every single person can see exactly where it is.",
			"rep": 2,
			"learn": [["russian", "platok"], ["russian", "khram"]],
			"rows": [
				{"id": "cross", "label": "Cross the line the way they do",
					"needs": "watched", "locked": "it is a gate in a wall",
					"to": "correct"},
				{"id": "in", "label": "Walk in", "to": "raw"},
			],
		},
		"correct": {
			"text": "You get it right and nothing happens, which is the point - nobody looks up, nobody adjusts, and for the length of the courtyard you are simply another person who knew where the line was.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stand at the back", "to": ""}],
		},
		"raw": {
			"text": "An old woman at the door stops you with one hand and puts a spare scarf into it from a basket kept there for exactly this. She is not angry. The basket exists because this happens daily.",
			"rep": -1,
			"rows": [
				{"id": "take", "label": "Take it and go in", "to": "correct"},
				{"id": "out", "label": "Back out", "to": ""},
			],
		},
		"gallery": {
			"text": "A merchant bought paintings for forty years and then gave the city all of them, and the building is his house. You walk through the rooms he lived in to get to them.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Walk the rooms", "to": ""}],
		},
	},
},

# ── Tbilisi ──────────────────────────────────────────────────────────────────

"tbilisi:avlabari": {
	"title": "Abanotubani",
	"start": "domes",
	"beats": {
		"domes": {
			"film": [
				{"set": "street", "secs": 3.6, "prop": "smoke", "prop_at": 0.7,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Brick domes sitting flat on the ground with steam coming out of the tops of them, and a smell of eggs over the whole quarter."},
				{"set": "interior", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.6, "act": "scrub"}],
					"say": "Through the wall, somebody is being scrubbed like a pan, and appears to be enjoying it."},
			],
			"text": "Brick domes sitting flat on the ground with steam coming out of the tops of them, and a smell of eggs over the whole quarter. The water underneath is why there is a city here at all.",
			"rows": [
				{"id": "pay", "label": "Pay for a room and go in", "cost": 15,
					"to": "inside"},
				{"id": "look", "label": "Just look at the domes", "to": "look"},
			],
		},
		"look": {
			"text": "A king's hawk went into the hot spring, or his horse did, depending who is telling it, and the city was founded on the spot. They tell it as a fact because here it functions as one.",
			"staging": {"set": "street", "cast": [{"at": 0.32, "act": "watch"}]},
			"rep": 1,
			"rows": [{"id": "pay", "label": "Pay and go in", "cost": 15,
				"to": "inside"}],
		},
		"inside": {
			"text": "A private room, a stone slab, and water hot enough to argue with. Through the wall you can hear somebody being worked on, and a sound like a plate being scrubbed.",
			"staging": {"set": "interior", "cast": [{"at": 0.34, "act": "stand"}, {"at": 0.6, "act": "scrub"}]},
			"rep": 2,
			"learn": [["georgian", "abano"], ["georgian", "tskali"]],
			"rows": [
				{"id": "kisi", "label": "Ask for the scrub as well", "cost": 10,
					"to": "kisi"},
				{"id": "soak", "label": "Just soak", "to": "soak"},
			],
		},
		"kisi": {
			"text": "He scrubs you the way you would clean a pan, without ceremony and without apology, and then shows you what came off, holding it up, with some pride, waiting for you to be impressed.",
			"rep": 3,
			"rows": [
				{"id": "react", "label": "Be impressed", "to": "react"},
				{"id": "flinch", "label": "Look away", "to": "flinch"},
			],
		},
		"react": {
			"text": "You react properly and he is delighted and does it again on the other arm to get the same result. Not one word of that passed between you and you understood every part of it.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Get back in the water", "to": ""}],
		},
		"flinch": {
			"text": "He puts it down, slightly deflated, and finishes the job quickly and well. You have declined the only part of this that was a conversation.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Get back in the water", "to": ""}],
		},
		"soak": {
			"text": "Forty minutes in water that comes out of the ground at this temperature, under a brick dome, in the middle of a capital city, for about the price of a coffee.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Stay until you cannot", "to": ""}],
		},
	},
},

"tbilisi:saburtalo": {
	"title": "The blocks",
	"start": "avenue",
	"beats": {
		"avenue": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "Avenues planned all at once, and glass going up between the concrete, and none of it agreeing with any of the rest."},
				{"set": "park", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.56, "act": "sit"}, {"at": 0.68, "act": "sit"}],
					"say": "In the gap between two blocks: a table, four men, a game, and the same four men tomorrow."},
			],
			"text": "Wide avenues planned all at once, glass towers going up between the concrete ones, and a gap between two blocks with a table in it and four men round the table.",
			"rows": [
				{"id": "yard", "label": "Cut through the courtyard", "to": "yard"},
				{"id": "metro", "label": "Take the escalator down", "to": "metro"},
			],
		},
		"yard": {
			"text": "The buildings face the road and the people face the yard. Everything with a name on it is out at the front and everything that matters is round the back, and you have just walked into the back.",
			"rep": 2,
			"learn": [["georgian", "ezo"], ["georgian", "magida"]],
			"rows": [
				{"id": "nod", "label": "Nod at the table and keep walking",
					"sub": "you are crossing their room and both parties know it",
					"to": "nodded"},
				{"id": "through", "label": "Walk through as if it were a street",
					"to": "through"},
			],
		},
		"nodded": {
			"text": "One of them lifts his chin about a centimetre and goes back to the game. That is the entire permission and it cost you nothing, and it would have cost you something not to ask for it.",
			"rep": 3,
			"rows": [{"id": "metro", "label": "On to the metro", "to": "metro"}],
		},
		"through": {
			"text": "The game stops. Four men watch you cross their yard and then start again once you have gone. Nothing happened, and something was noted, and you will not be nodded at tomorrow.",
			"rep": -1,
			"rows": [{"id": "metro", "label": "On to the metro", "to": "metro"}],
		},
		"metro": {
			"text": "Two minutes down, standing still, on an escalator that does not appear to end. It was not dug this deep for the trains, and nobody who built it pretended otherwise.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Ride it all the way down", "to": ""}],
		},
	},
},

"tbilisi:chugureti": {
	"title": "Fabrika",
	"start": "yard",
	"beats": {
		"yard": {
			"film": [
				{"set": "courtyard", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.58, "act": "sit"}],
					"say": "A sewing factory with the machines gone and the courtyard full of people who have never sewn anything."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "Outside, carved wooden balconies hanging off the fronts of the houses, every one different and every one failing."},
			],
			"text": "A Soviet sewing factory with the machines gone and the courtyard full: students, a barber, a bike shop, and everybody sharing the same slab of concrete. Nothing was changed except what it is for.",
			"rows": [
				{"id": "sit", "label": "Sit in the yard", "to": "sat"},
				{"id": "street", "label": "Go and look at the balconies outside",
					"to": "balcony"},
			],
		},
		"sat": {
			"text": "Nobody asks you anything for an hour. The word on the building is still the word for a factory and the whole city calls it that, and none of the people in the yard have ever sewn anything.",
			"rep": 2,
			"learn": [["georgian", "fabrika"], ["georgian", "eziani"]],
			"rows": [{"id": "street", "label": "Go out to the street",
				"to": "balcony"}],
		},
		"balcony": {
			"text": "Carved wooden balconies hanging off the fronts of the houses, every one different, held up with whatever was available at the time. All of them are failing and none of them are being repaired.",
			"rep": 2,
			"rows": [
				{"id": "close", "label": "Look at how one is actually held up",
					"to": "close"},
				{"id": "ok", "label": "Walk the street", "to": ""},
			],
		},
		"close": {
			"text": "A steel pole, a car jack, and a length of scaffold, holding up a hundred and forty years of carved wood on a street that is beautiful in a way that is going to end up in the road.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Walk on under it", "to": ""}],
		},
	},
},

# ── İstanbul ─────────────────────────────────────────────────────────────────

"istanbul:beyoglu": {
	"title": "İstiklal Caddesi",
	"start": "crowd",
	"beats": {
		"crowd": {
			"film": [
				{"set": "tram", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.52, "act": "walk"}, {"at": 0.7, "act": "walk"}],
					"say": "A street too full to walk down, and a red tram coming through the middle of it at walking pace anyway."},
				{"set": "tram", "secs": 3.8,
					"cast": [{"at": 0.36, "act": "recoil"}],
					"say": "The crowd opens without looking round and closes behind it. Nobody watched the tram. All of them knew where it was."},
			],
			"text": "A street too full to walk down, and a red tram coming through it anyway at walking pace. It does not slow and it does not sound a bell, and the crowd is not looking at it.",
			"rows": [
				{"id": "watch", "label": "Watch how the crowd handles the tram",
					"to": "watched"},
				{"id": "dodge", "label": "Get out of its way", "to": "dodged"},
				{"id": "simit", "label": "Buy a simit from a cart", "cost": 15,
					"to": "simit"},
			],
		},
		"watched": {
			"text": "It opens without anybody looking round and closes behind it. Nobody watched the tram. They all knew where it was the way you know where your own hands are, and the gap was never wider than it needed to be.",
			"rep": 2,
			"learn": [["turkish", "tramvay"], ["turkish", "yol"]],
			"rows": [
				{"id": "walk", "label": "Walk with the crowd and let it move you",
					"needs": "watched",
					"locked": "you are going to keep flinching at the tram",
					"to": "carried"},
				{"id": "dodge", "label": "Keep an eye on it yourself", "to": "dodged"},
			],
		},
		"carried": {
			"text": "You stop steering. The street does it. Four hundred metres go past without a single decision from you, and the tram comes through twice and you barely register either of them.",
			"rep": 3,
			"rows": [{"id": "simit", "label": "Buy a simit", "cost": 15,
				"to": "simit"}],
		},
		"dodged": {
			"text": "You jump, twice, at something moving at four miles an hour that everyone else treated as weather. A man in a doorway watches you do it and is very kind about it with his face.",
			"rep": -1,
			"rows": [
				{"id": "watch", "label": "Stand still and watch them instead",
					"to": "watched"},
				{"id": "simit", "label": "Buy a simit", "cost": 15, "to": "simit"},
			],
		},
		"simit": {
			"text": "Sesame, a ring, and the same price from every cart in a city of sixteen million. It is the one number here you have not had to argue about, and nobody has ever tried to.",
			"rep": 1,
			"item": "simit",
			"rows": [{"id": "ok", "label": "Eat it walking", "to": ""}],
		},
	},
},

"istanbul:kadikoy": {
	"title": "The Asian side",
	"start": "ferry",
	"beats": {
		"ferry": {
			"film": [
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.36, "act": "sit"}, {"at": 0.58, "act": "sit"}],
					"say": "Twenty minutes across, two continents, and every single person on board is reading or asleep."},
				{"set": "beach+market", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "cut"}],
					"say": "Off the boat: ice, shouting, fish in rows, and cats moving through all of it with total confidence."},
			],
			"text": "Twenty minutes across, two continents, and a glass of tea sold from a tray by a man who never stops moving. Everyone on board is reading or asleep. Nobody is at the window.",
			"cost": 20,
			"rows": [
				{"id": "tea", "label": "Take a glass of tea", "cost": 15,
					"to": "tea"},
				{"id": "window", "label": "Stand at the rail the whole way",
					"to": "window"},
			],
		},
		"tea": {
			"text": "Small tulip glass, no handle, far too hot to hold, and everybody is holding one by the rim with two fingers. You do it wrong once and get it right after that.",
			"rep": 2,
			"learn": [["turkish", "cay"], ["turkish", "ince"]],
			"rows": [{"id": "market", "label": "Off the boat and into the market",
				"to": "market"}],
		},
		"window": {
			"text": "The city goes past on both sides and you are the only person watching it. A commuter route, twice a day, for a hundred years, and you are the only one who has not stopped noticing.",
			"rep": 2,
			"rows": [{"id": "market", "label": "Off the boat and into the market",
				"to": "market"}],
		},
		"market": {
			"text": "Ice, shouting, fish laid out in rows, and cats moving through all of it with total confidence. There are bowls put down for them and a phone number for a vet taped to a wall.",
			"rep": 1,
			"rows": [
				{"id": "cat", "label": "Work out whose cats these are", "to": "cats"},
				{"id": "ok", "label": "Walk the market", "to": ""},
			],
		},
		"cats": {
			"text": "Nobody's. Everybody's. They are not strays, they are staff, and the entire street has quietly agreed to feed them and get them treated and never to claim one.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Sit at the bull statue", "to": ""}],
		},
	},
},

"istanbul:carsi": {
	"title": "Askıda ekmek",
	"start": "bakery",
	"beats": {
		"bakery": {
			"film": [
				{"set": "counter/bakery", "secs": 3.4, "prop": "nail", "prop_at": 0.52,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A bakery the size of a doorway with a nail in the wall behind the counter and paper tickets hanging off it."},
				{"set": "counter/bakery", "secs": 3.8, "prop": "nail", "prop_at": 0.50,
					"cast": [{"at": 0.30, "act": "hand_over"}, {"at": 0.64, "act": "point"}],
					"say": "A man pays for two loaves, takes one, and points at the nail. The baker writes something small and hangs it up. The second loaf never leaves the shelf."},
			],
			"text": "A bakery the width of a doorway with a nail behind the counter and paper tickets hanging off it. A man pays for two loaves, takes one, and points at the nail, and the second loaf stays on the shelf.",
			"rows": [
				{"id": "wait", "label": "Wait and see who takes it", "to": "taken"},
				{"id": "ask", "label": "Point at the nail yourself", "to": "nail"},
			],
		},
		"taken": {
			"film": [
				{"set": "counter/bakery", "secs": 3.6, "prop": "nail", "prop_at": 0.48,
					"cast": [{"at": 0.26, "act": "queue"}, {"at": 0.44, "act": "queue"},
						{"at": 0.68, "act": "take"}],
					"say": "An old man comes in, says nothing, takes a ticket off the nail and is handed bread. No money. No explanation. Nobody in the queue turns round."},
			],
			"text": "An old man comes in, takes a ticket off the nail without a word and is handed bread. No money moves and nobody in the queue turns round. Whoever paid for it is not here and was never going to be.",
			"rep": 2,
			"learn": [["turkish", "askıda"], ["turkish", "ekmek"]],
			"rows": [
				{"id": "pay", "label": "Pay for one and leave it hanging",
					"cost": 5, "to": "hung"},
				{"id": "ok", "label": "Buy one for yourself", "cost": 3, "to": "own"},
			],
		},
		"nail": {
			"text": "The baker looks at the nail, then at me, then holds up two fingers and one finger, and waits. The whole arrangement is being explained in a language of hands because the words on the tickets are no use to either of us.",
			"rep": 1,
			"learn": [["turkish", "bir"], ["turkish", "iki"]],
			"rows": [
				{"id": "pay", "label": "Pay for two and take one", "cost": 5,
					"to": "hung"},
				{"id": "wait", "label": "Wait and watch instead", "to": "taken"},
			],
		},
		"hung": {
			"film": [
				{"set": "counter/bakery", "secs": 3.6, "prop": "bread", "prop_at": 0.50,
					"cast": [{"at": 0.34, "act": "hand_over"}, {"at": 0.66, "act": "write"}],
					"say": "He writes the ticket, hangs it on the nail, and gives me the other loaf. He does not thank me and I would not have understood it. The nail does the thanking."},
			],
			"text": "He writes a ticket, hangs it on the nail and gives me the other loaf. He does not thank me, which is correct: the arrangement is between the nail and whoever needs it, and I am not part of it any more.",
			"rep": 3,
			"item": "bread",
			"rows": [{"id": "ok", "label": "Eat it walking", "to": ""}],
		},
		"own": {
			"text": "Warm, heavy, and half of it is gone before I am back on the street. The nail is still there behind the counter with four tickets on it, and now I know what each of them is.",
			"rep": 1,
			"item": "bread",
			"rows": [{"id": "ok", "label": "Eat it walking", "to": ""}],
		},
	},
},

"istanbul:han": {
	"title": "The çaycı",
	"start": "courtyard",
	"beats": {
		"courtyard": {
			"film": [
				{"set": "courtyard", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A stone courtyard with two floors of workshops round it and one tree in the middle. Somebody upstairs is hitting metal on a rhythm."},
				{"set": "courtyard", "secs": 3.8, "prop": "glass", "prop_at": 0.62,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "carry"}],
					"say": "A boy crosses it carrying a tray that swings from three chains and does not spill. Six glasses on it, all full, and he has not looked at them once."},
			],
			"text": "A stone courtyard with two floors of workshops round it and one tree in the middle. A boy crosses it carrying six full glasses on a tray swinging from three chains, and never once looks at them.",
			"rows": [
				{"id": "follow", "label": "Follow the tray", "to": "delivered"},
				{"id": "sit", "label": "Sit down under the tree", "to": "arrives"},
			],
		},
		"delivered": {
			"text": "He goes up the stairs, into a workshop, puts a glass beside a man's elbow and leaves without either of them speaking. The man does not stop working. Two doors along, the same. He is not selling anything. He is keeping the building running.",
			"rep": 2,
			"learn": [["turkish", "çay"], ["turkish", "han"]],
			"rows": [
				{"id": "sit", "label": "Go and sit under the tree", "to": "arrives"},
				{"id": "ok", "label": "Watch him finish the round", "to": ""},
			],
		},
		"arrives": {
			"film": [
				{"set": "courtyard", "secs": 3.6, "prop": "glass", "prop_at": 0.48,
					"cast": [{"at": 0.32, "act": "sit"}, {"at": 0.64, "act": "offer"}],
					"say": "I sit down and a glass arrives that I did not ask for. I reach for money and he has already gone."},
			],
			"text": "I sit down and a glass arrives that I did not order. When I reach for money he has already gone up the stairs. Whatever this is, it is not a purchase, and refusing it was never one of the options.",
			"rep": 2,
			"learn": [["turkish", "buyrun"], ["turkish", "teşekkür"]],
			"rows": [
				{"id": "pay", "label": "Find him and pay anyway", "cost": 2,
					"to": "paid"},
				{"id": "drink", "label": "Drink it and stay where you are",
					"to": "stayed"},
			],
		},
		"paid": {
			"text": "He takes the coin because refusing it would be its own kind of rudeness, and then he brings a second glass. I have not won this and I am not going to.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Drink the second one", "to": ""}],
		},
		"stayed": {
			"text": "Two hours in a courtyard where nobody asks me anything. The hammering upstairs stops at some point and I do not notice when. It is the first place in this city that has not required anything of me.",
			"rep": 3,
			"flag": "rested_han",
			"rows": [{"id": "ok", "label": "Get up eventually", "to": ""}],
		},
	},
},

"istanbul:karakoy": {
	"title": "The turnstile",
	"start": "gate",
	"beats": {
		"gate": {
			"film": [
				{"set": "water", "secs": 3.4,
					"cast": [{"at": 0.30, "act": "queue"}],
					"say": "A row of metal arms between me and the water, and the ferry is on the other side of them with its engine already running."},
				{"set": "station", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.64, "act": "reach"}],
					"say": "Everyone touches a card to a yellow circle. It makes a noise, the arm gives way, they go through. Nobody breaks stride to do it."},
			],
			"text": "A row of metal arms between me and the water and the ferry already running on the other side. Everyone touches a card to a yellow circle, the arm gives way and they walk through without breaking stride.",
			"rows": [
				{"id": "machine", "label": "Find the machine that sells the card",
					"to": "machine"},
				{"id": "push", "label": "Push the arm and see", "to": "refused"},
			],
		},
		"refused": {
			"text": "It does not move. It is not locked so much as indifferent. There is no slot for money on it anywhere and nobody standing near it to appeal to.",
			"rows": [
				{"id": "machine", "label": "Look for a machine", "to": "machine"},
			],
		},
		"machine": {
			"film": [
				{"set": "station", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "write"}, {"at": 0.66, "act": "watch"}],
					"say": "A blue box with a screen full of words. I press things until it shows a picture of a card and a number, and then it wants coins, which I have."},
			],
			"text": "A blue box with a screen full of words I cannot read. Pressing things at random eventually produces a picture of a card and a number, and a number is a thing I can pay.",
			"rep": 1,
			"learn": [["turkish", "kart"], ["turkish", "vapur"]],
			"rows": [
				{"id": "buy", "label": "Feed it coins", "cost": 12, "to": "card"},
				{"id": "ok", "label": "Step away from it", "to": ""},
			],
		},
		"card": {
			"film": [
				{"set": "station", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.64, "act": "walk"}],
					"say": "The circle makes the noise. The arm gives way. Nobody looks up, because there was nothing to see - I did the thing everyone does and the city let me through."},
			],
			"text": "The circle makes its noise and the arm gives way and nobody looks up, because there was nothing to look at. I did the ordinary thing correctly and the city stopped noticing me, which is the closest to being from here I have managed.",
			"rep": 3,
			"item": "transit_card",
			"learn": [["turkish", "geçiş"]],
			"rows": [{"id": "ok", "label": "Get on the boat", "to": ""}],
		},
	},
},

}
