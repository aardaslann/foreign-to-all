extends Object

# Streetside encounters: the second district of each East Asian city.
#
# Split from StreetsideEast.gd purely by size, the same way every other table
# in this folder is split. Streetside.spot() looks a key up across all of them
# and does not care which file it lives in.
#
# Everything here is the thing that district actually has. Bia hoi is sold on
# that corner at that hour for that price; the wholesale market really is under
# Long Bien at two in the morning; the bookshops on Yasukuni-dori really do all
# face north, and for the reason given.

const SPOTS := {

# ── Hanoi ────────────────────────────────────────────────────────────────────

"hanoi:phoco": {
	"title": "Bia hoi corner",
	"start": "corner",
	"beats": {
		"corner": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A steel keg on the pavement, a stack of stools eleven centimetres off the ground, and at five o'clock the corner fills without anybody arranging it."},
				{"set": "street", "secs": 3.8, "prop": "glass", "prop_at": 0.58,
					"cast": [{"at": 0.30, "act": "sit"}, {"at": 0.62, "act": "offer"}],
					"say": "The glass is thick, slightly green, and has been washed ten thousand times. It is put in front of me before I have said anything."},
			],
			"text": "A keg on the pavement and a stack of plastic stools. The beer is brewed that morning and drunk that evening and is not kept, which is why it costs what it costs.",
			"rows": [
				{"id": "sit", "label": "Sit down on a stool", "cost": 1,
					"to": "sat"},
				{"id": "watch", "label": "Watch how it is paid for", "to": "tally"},
			],
		},
		"sat": {
			"film": [
				{"set": "street", "secs": 3.6, "prop": "glass", "prop_at": 0.34,
					"cast": [{"at": 0.32, "act": "drink"}, {"at": 0.64, "act": "sit"}],
					"say": "Everybody is facing the road. The stools face out, not in. You come here to sit and watch the street go past, and the beer is what buys you the seat."},
			],
			"text": "The stools face the road rather than each other. Nobody is looking at anybody. The beer is the rent on a place to sit and watch a street.",
			"rep": 2,
			"learn": [["vietnamese", "bia"], ["vietnamese", "hoi"]],
			"rows": [
				{"id": "tally", "label": "Watch how the bill is worked out",
					"to": "tally"},
				{"id": "ok", "label": "Stay until the keg is empty", "to": ""},
			],
		},
		"tally": {
			"film": [
				{"set": "street", "secs": 3.6, "prop": "coin", "prop_at": 0.60,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "count"}],
					"say": "She counts the empty glasses on the table with one finger and says a number. There is no paper anywhere. There never was."},
			],
			"text": "Nobody writes anything down. She counts the empties with a finger and says a number, and the number is right, and the whole system is a woman remembering.",
			"rep": 2,
			"learn": [["vietnamese", "bao nhieu"]],
			"rows": [{"id": "ok", "label": "Pay what the glasses say", "cost": 2,
				"to": ""}],
		},
	},
},

"hanoi:longbien": {
	"title": "Under the bridge at two",
	"start": "arrive",
	"beats": {
		"arrive": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Two in the morning and this is the busiest place I have been on this planet. Everything green in this city passes through here before it is light."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "haul", "kit": "shoulder_pole",
						"appearance": {"build": "adult", "wear": "marketapron", "cut": "tied", "face": ""}}],
					"say": "A pole across the shoulders with a basket swinging off each end, and she is going faster than I am with nothing."},
			],
			"text": "The wholesale market under the bridge, between one and five in the morning. Everything green that the city will eat today comes through here first, on the back of a bicycle or on a pole across somebody's shoulders.",
			"rows": [
				{"id": "pole", "label": "Watch the shoulder poles", "to": "pole"},
				{"id": "buy", "label": "Try to buy one of anything", "to": "wholesale"},
			],
		},
		"pole": {
			"text": "The pole bends and springs with the walk, and the bending is the point: it carries the weight for her at the top of each step. It is a machine made of bamboo and timing.",
			"rep": 2,
			"learn": [["vietnamese", "ganh"], ["vietnamese", "cho"]],
			"rows": [
				{"id": "buy", "label": "Try to buy one of anything",
					"to": "wholesale"},
				{"id": "ok", "label": "Stand out of the way", "to": ""},
			],
		},
		"wholesale": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.64, "act": "recoil"}],
					"say": "I hold up one finger. She laughs, and holds up ten, and then a whole crate, and I understand that one of anything is not a thing you can buy here."},
			],
			"text": "You cannot buy one. This is where the people who sell to you buy, and the smallest unit in the place is a crate. Retail happens somewhere else, four hours from now, for three times the price.",
			"rep": 2,
			"rows": [
				{"id": "crate", "label": "Buy the crate", "cost": 14, "to": "crate"},
				{"id": "ok", "label": "Leave empty-handed", "to": ""},
			],
		},
		"crate": {
			"text": "I am now the owner of more fruit than I can carry and it cost less than four pieces did yesterday. Two women watch me work out that the price was never the problem.",
			"rep": 1,
			"item": "fruit_crate",
			"rows": [{"id": "ok", "label": "Work out how to carry it", "to": ""}],
		},
	},
},

# ── Mumbai ───────────────────────────────────────────────────────────────────

"mumbai:bhuleshwar": {
	"title": "Kabutarkhana",
	"start": "platform",
	"beats": {
		"platform": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A raised stone platform in the middle of the junction with several hundred pigeons standing on it, and the traffic goes round rather than through."},
				{"set": "steps", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "reach"}],
					"say": "A man buys grain from a sack, walks up the steps, and pours it out. He does not stay to watch them eat. That was not the point of it."},
			],
			"text": "A stone platform in the middle of the junction, several hundred pigeons on it, and the traffic going round rather than through. A man buys grain, pours it, and leaves without watching.",
			"rows": [
				{"id": "grain", "label": "Buy a measure of grain", "cost": 3,
					"to": "poured"},
				{"id": "watch", "label": "Watch who else comes", "to": "who"},
			],
		},
		"poured": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "offer"}, {"at": 0.66, "act": "watch"}],
					"say": "I pour it out and the noise of four hundred wings going up at once is the loudest thing in this street, and nobody else looks round."},
			],
			"text": "The grain costs almost nothing and the man selling it will sell to anybody. It is not charity to the birds. It is a thing you do, in a city where doing it is old enough that a junction was built round it.",
			"rep": 3,
			"learn": [["hindi", "dana"], ["hindi", "kabutar"]],
			"rows": [
				{"id": "who", "label": "See who else is doing it", "to": "who"},
				{"id": "ok", "label": "Come back down the steps", "to": ""},
			],
		},
		"who": {
			"text": "An old woman, a man in a shirt and tie on his way somewhere, two children sent with a coin. None of them stay more than a minute. Whatever this is, it is not sentimental about it.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Move on", "to": ""}],
		},
	},
},

"mumbai:chorbazaar": {
	"title": "Chor Bazaar",
	"start": "lane",
	"beats": {
		"lane": {
			"film": [
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Brass taps, ship's instruments, a hundred door handles in a tray, film posters, and four gramophone horns stacked like a wedding cake."},
				{"set": "stall", "secs": 3.8, "prop": "board", "prop_at": 0.62,
					"cast": [{"at": 0.28, "act": "reach"}, {"at": 0.64, "act": "offer"}],
					"say": "I pick a thing up and he says a number. I put it down and he says a smaller number before it has touched the cloth."},
			],
			"text": "A lane of things that came from somewhere. Brass, instruments, door handles by the tray, film posters, gramophone horns. Nobody will tell you where any of it was before it was here, and asking is not done.",
			"rows": [
				{"id": "haggle", "label": "Put it down and walk", "to": "walked"},
				{"id": "pay", "label": "Pay the first number", "cost": 18,
					"to": "paid"},
			],
		},
		"walked": {
			"film": [
				{"set": "stall", "secs": 3.6, "prop": "coin", "prop_at": 0.56,
					"cast": [{"at": 0.30, "act": "walk"}, {"at": 0.62, "act": "wave"}],
					"say": "Four steps and the number follows me down the lane, twice, each time smaller. Walking away is not rude here. Walking away is the second half of the sentence."},
			],
			"text": "The number follows you down the lane and gets smaller as it goes. Leaving is not an insult; it is the rest of the conversation, and the only part of it I can do without words.",
			"rep": 3,
			"learn": [["hindi", "kitna"], ["hindi", "nahi"]],
			"rows": [
				{"id": "buy", "label": "Turn round and buy it", "cost": 9,
					"to": "bought"},
				{"id": "ok", "label": "Keep walking", "to": ""},
			],
		},
		"paid": {
			"text": "He takes it without a flicker and wraps the thing in newspaper. Two stalls along, the same object is on a cloth with a number on it that is half of what I have just handed over.",
			"rep": 0,
			"item": "brass_thing",
			"rows": [{"id": "ok", "label": "Work out what just happened", "to": ""}],
		},
		"bought": {
			"text": "Half of what he first said, and he is pleased, and I am pleased, and neither of us has said a word either of us understood. The newspaper it is wrapped in is older than the thing.",
			"rep": 2,
			"item": "brass_thing",
			"rows": [{"id": "ok", "label": "Put it in your pocket", "to": ""}],
		},
	},
},

# ── Seoul ────────────────────────────────────────────────────────────────────

"seoul:euljiro": {
	"title": "The lathe and the beer crate",
	"start": "day",
	"beats": {
		"day": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Every ground floor on this alley is a workshop the size of a garage, and each one does exactly one thing to metal."},
				{"set": "shop/workshop", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "cut"}],
					"say": "He cuts one part. He does not make the thing the part is for. Somebody two doors down does the next operation and that is the whole arrangement."},
			],
			"text": "A district of one-room workshops, each doing a single operation to metal, and the thing being made passes down the alley from door to door until it is finished.",
			"rows": [
				{"id": "follow", "label": "Follow a part down the alley",
					"to": "chain"},
				{"id": "wait", "label": "Wait until it gets dark", "to": "night"},
			],
		},
		"chain": {
			"text": "Cut, drilled, bent, plated, threaded. Six doors and five men and none of them has spoken to another one all afternoon. They do not need to. The part says what it needs next.",
			"rep": 2,
			"learn": [["korean", "gongjang"], ["korean", "hana"]],
			"rows": [
				{"id": "wait", "label": "Wait until it gets dark", "to": "night"},
				{"id": "ok", "label": "Leave them to it", "to": ""},
			],
		},
		"night": {
			"film": [
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "sit"}],
					"say": "The shutters come down at seven and the same alley fills with tables. The tables are the crates the beer came in. Nothing has been brought out that was not already here."},
				{"set": "street", "secs": 3.6, "prop": "glass", "prop_at": 0.60,
					"cast": [{"at": 0.32, "act": "sit"}, {"at": 0.66, "act": "offer"}],
					"say": "People who work in offices are sitting on a machinist's step drinking out of a green bottle, and the machinist has gone home."},
			],
			"text": "At seven the shutters come down and the same alley becomes somewhere to drink. The tables are the crates. The stools are the steps of the workshops. Nothing was brought in and nothing will be taken away.",
			"rep": 3,
			"learn": [["korean", "sul"], ["korean", "anju"]],
			"rows": [
				{"id": "sit", "label": "Sit on a crate", "cost": 5, "to": "sat"},
				{"id": "ok", "label": "Walk the alley once more", "to": ""},
			],
		},
		"sat": {
			"text": "Two hours on an upturned crate outside a shut metal shop. Somebody pours for me before pouring for themselves, and does not pour their own until mine is full, and I work out that this is a rule.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Pour for the person beside you",
				"to": ""}],
		},
	},
},

"seoul:jongno": {
	"title": "Gwangjang, the griddle",
	"start": "aisle",
	"beats": {
		"aisle": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "An aisle of griddles under one roof, a stool in front of each, and a woman behind every one of them who has been at that griddle longer than I have been on this planet."},
				{"set": "counter/food", "secs": 3.8, "prop": "bowl", "prop_at": 0.60,
					"cast": [{"at": 0.28, "act": "sit"}, {"at": 0.62, "act": "offer"}],
					"say": "A plate is in front of me before I sat down properly. I did not order it. She decided, and she was not wrong."},
			],
			"text": "A covered market of griddles, a stool at each, and a plate arriving before you have finished sitting down. The mung beans are ground on the spot in a stone mill you can watch turning.",
			"rows": [
				{"id": "eat", "label": "Eat what arrived", "cost": 6, "to": "ate"},
				{"id": "point", "label": "Try to order something else",
					"to": "ordered"},
			],
		},
		"ate": {
			"film": [
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "eat"}, {"at": 0.66, "act": "watch"}],
					"say": "Hot, heavy, and fried in a quantity of oil that would be a scandal anywhere I have been. Half the stool next to me is somebody's grandmother and half is a man in a suit."},
			],
			"text": "Fried in more oil than seems reasonable, eaten off a shared table with people who have nothing else in common with each other. She is already pouring the next batch onto the griddle behind her without looking at it.",
			"rep": 2,
			"learn": [["korean", "jeon"], ["korean", "mashisseoyo"]],
			"rows": [
				{"id": "pay", "label": "Work out how to pay", "to": "paid"},
			],
		},
		"ordered": {
			"text": "I point at something two stools down. She looks at what I pointed at, looks at me, and brings the first thing anyway. There is a version of this where she is wrong and this is not it.",
			"rep": 1,
			"rows": [
				{"id": "eat", "label": "Eat what she decided", "cost": 6,
					"to": "ate"},
			],
		},
		"paid": {
			"text": "You pay her, not a till. She keeps the money in an apron pocket and gives change out of the same pocket, and the arithmetic happens somewhere I cannot see.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Get off the stool", "to": ""}],
		},
	},
},

# ── Tokyo ────────────────────────────────────────────────────────────────────

"tokyo:yanaka": {
	"title": "Yanaka Ginza",
	"start": "steps",
	"beats": {
		"steps": {
			"film": [
				{"set": "steps", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A flight of steps down into a street of sixty shops, none of them a chain, in a quarter that the fire and then the bombing both somehow missed."},
				{"set": "counter/food", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "queue"}, {"at": 0.62, "act": "cut"}],
					"say": "A fryer, a queue of four, and a woman lifting things out of the oil with a wire basket in a rhythm she has not had to think about for years."},
			],
			"text": "Steps down into a street of small shops, none of them a chain. There is a fryer near the bottom with a short queue at it and a woman working the basket without looking at it.",
			"rows": [
				{"id": "buy", "label": "Buy one", "cost": 4, "to": "hot"},
				{"id": "watch", "label": "Watch what people do with theirs",
					"to": "standing"},
			],
		},
		"hot": {
			"film": [
				{"set": "counter/food", "secs": 3.6, "prop": "smoke", "prop_at": 0.34,
					"cast": [{"at": 0.32, "act": "take"}, {"at": 0.64, "act": "watch"}],
					"say": "Too hot to hold and I start walking with it, and three people look at me at once, and I stop walking."},
			],
			"text": "Too hot to hold, and I take a step away with it, and three people look up at the same moment. So I stand where I bought it, in front of the shop, and eat it there.",
			"rep": 3,
			"item": "menchi_katsu",
			"learn": [["japanese", "atsui"], ["japanese", "tabearuki"]],
			"rows": [
				{"id": "standing", "label": "Look at where everyone else is eating",
					"to": "standing"},
			],
		},
		"standing": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "eat"}, {"at": 0.60, "act": "eat"},
						{"at": 0.74, "act": "watch"}],
					"say": "Everybody who bought one is standing within two metres of the shop that sold it, eating, and then walking on with empty hands."},
			],
			"text": "Everybody eats it standing in front of the shop that sold it. The street has almost no bins, and it does not need them, because nothing leaves the shop's two metres of pavement still in a wrapper.",
			"rep": 2,
			"rows": [
				{"id": "cats", "label": "Follow the cats up to the cemetery",
					"to": "cats"},
				{"id": "ok", "label": "Walk to the end of the street", "to": ""},
			],
		},
		"cats": {
			"text": "Seven cats between here and the top of the hill, all of them fed by somebody and belonging to nobody, and a graveyard full of cherry trees that people walk their shopping home through.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Walk back down", "to": ""}],
		},
	},
},

"tokyo:jinbocho": {
	"title": "The north side of the street",
	"start": "row",
	"beats": {
		"row": {
			"film": [
				{"set": "shop", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A hundred and eighty second-hand bookshops in about four streets, and carts of them out on the pavement in the rain-shadow of the awnings."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.64, "act": "walk"}],
					"say": "Every shopfront on the long street is on the same side of it. The whole trade is on one pavement and the other one is nearly empty."},
			],
			"text": "A hundred and eighty second-hand bookshops in four streets, and on the long one every single shopfront is on the same side of the road.",
			"rows": [
				{"id": "why", "label": "Work out why they are all on one side",
					"to": "north"},
				{"id": "cart", "label": "Go through a cart on the pavement",
					"to": "cart"},
			],
		},
		"north": {
			"film": [
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "look_up"}, {"at": 0.66, "act": "watch"}],
					"say": "The sun is on the empty pavement all afternoon and never touches the shops. They face north. Every one of them faces north."},
			],
			"text": "They face north. All of them. The sun crosses the other pavement all day and never lands on a shopfront, because sunlight takes the colour out of a spine and a faded spine does not sell. A whole street arranged around what light does to paper.",
			"rep": 3,
			"learn": [["japanese", "hon"], ["japanese", "kita"]],
			"rows": [
				{"id": "cart", "label": "Go through a cart", "to": "cart"},
				{"id": "ok", "label": "Walk the shaded side", "to": ""},
			],
		},
		"cart": {
			"film": [
				{"set": "shop", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "reach"}, {"at": 0.62, "act": "stand"}],
					"say": "Rows of spines I cannot read, sorted by something I cannot see, and the man inside has not looked up once since I arrived."},
			],
			"text": "The spines are sorted by something. Not colour, not size. Somebody knows exactly where everything on this cart is and it is not going to be me.",
			"rep": 2,
			"rows": [
				{"id": "buy", "label": "Buy one for the picture on the front",
					"cost": 5, "to": "bought"},
				{"id": "ok", "label": "Put it back where it was", "to": ""},
			],
		},
		"bought": {
			"text": "A hundred yen, wrapped in paper, and I have bought a book I cannot read for the woodcut on the cover. He wraps it as carefully as if I could.",
			"rep": 2,
			"item": "old_book",
			"rows": [{"id": "ok", "label": "Carry it out under your arm", "to": ""}],
		},
	},
},

}
