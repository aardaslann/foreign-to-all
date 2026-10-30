extends Object

# Streetside encounters: Africa and the Americas.
# Played through Streetside.spot() and the beat engine in Services._local().

const SPOTS := {

# ── Dakar ────────────────────────────────────────────────────────────────────

"dakar:yoff": {
	"title": "The landing beach",
	"start": "beach",
	"beats": {
		"beach": {
			"film": [
				{"set": "beach", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Painted boats coming in loaded, and the whole beach turning out to meet them without anybody calling it."},
				{"set": "beach", "secs": 3.8, "prop": "rope", "prop_at": 0.56,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.54, "act": "haul"}, {"at": 0.68, "act": "haul"}],
					"say": "Twenty people on a rope, in no particular order, in perfect time."},
			],
			"text": "Painted pirogues coming in loaded, and the whole beach turning out to meet them. Twenty people on a rope, hauling, in no particular order and perfect time.",
			"rows": [
				{"id": "buy", "label": "Try to buy fish off a boat", "to": "buy"},
				{"id": "rope", "label": "Take an end of the rope",
					"sub": "nobody asked you to. Nobody is going to stop you either",
					"to": "rope"},
				{"id": "watch", "label": "Stand and watch them land", "to": "watch"},
			],
		},
		"rope": {
			"text": "You get a grip and pull with the rest of them. The rhythm is not yours and you find it in about four seconds because twenty other people are supplying it.",
			"rep": 3,
			"learn": [["wolof", "nio"], ["wolof", "far"]],
			"rows": [
				{"id": "stay", "label": "Stay on the rope until the boat is up",
					"to": "stayed"},
				{"id": "buy", "label": "Let go and go and buy fish", "to": "buy"},
			],
		},
		"stayed": {
			"text": "For about four minutes nobody in this country thinks anything about you at all, which has not happened since you got here and which you would not have been able to buy.",
			"rep": 3,
			"rows": [{"id": "buy", "label": "Now go and buy fish", "to": "buy"}],
		},
		"watch": {
			"text": "The boat comes up the sand on twenty pairs of hands. The catch goes into basins. The basins go onto heads. Nothing is weighed and nobody writes anything down.",
			"rep": 1,
			"rows": [
				{"id": "rope", "label": "Take an end of the rope on the next one",
					"to": "rope"},
				{"id": "buy", "label": "Go and buy fish", "to": "buy"},
			],
		},
		"buy": {
			"text": "A woman with a basin looks at you and names a price. It is the price. There is no other price, because there is no tourist here to have one - there are only fish and people who want them.",
			"rows": [
				{"id": "pay", "label": "Pay it", "cost": 2000, "to": "paid"},
				{"id": "haggle", "label": "Try to knock her down", "to": "haggled"},
			],
		},
		"paid": {
			"text": "She wraps it in paper and gives you back a coin you did not know you were owed. You had braced yourself to be overcharged, and you were not.",
			"rep": 2,
			"item": "yoff_fish",
			"rows": [{"id": "ok", "label": "Carry it up the beach", "to": ""}],
		},
		"haggled": {
			"text": "She is not offended, she is confused. There is nothing to argue about. You have brought a habit from a market four thousand kilometres away into a place that does not have that habit.",
			"rep": -1,
			"rows": [{"id": "pay", "label": "Pay the price she said", "cost": 2000,
				"to": "paid"}],
		},
	},
},

"dakar:plateau": {
	"title": "Marché Kermel",
	"start": "hall",
	"beats": {
		"hall": {
			"film": [
				{"set": "stall", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "A round market hall with ministries and bank towers standing behind it, and flowers for sale at the door."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.6, "act": "offer"}],
					"say": "She turns to me and starts talking, and ninety seconds in, no flowers have been mentioned by either of us."},
			],
			"text": "A round colonial market hall with ministries and bank towers behind it. At the door, women selling flowers. One of them turns to you and starts talking, and it is not about flowers.",
			"rows": [
				{"id": "answer", "label": "Answer her questions",
					"sub": "she is asking after your family, and you have none here",
					"to": "answered"},
				{"id": "cut", "label": "Say what you want and how much",
					"sub": "she is clearly busy and so are you", "to": "cut"},
			],
		},
		"answered": {
			"text": "Your family. Your health. Your morning. Your family again. It has been ninety seconds and no flowers have been mentioned by either of you and she is entirely satisfied.",
			"rep": 2,
			"learn": [["wolof", "nangadef"], ["wolof", "mangifi"]],
			"rows": [
				{"id": "ask", "label": "Now ask about the flowers", "cost": 1500,
					"needs": "answered",
					"locked": "you have not got through the part that comes first",
					"to": "sold"},
				{"id": "wait", "label": "Ask after her family too", "to": "back"},
			],
		},
		"back": {
			"text": "She stops, properly looks at you for the first time, and answers at length. Somewhere in it she starts wrapping flowers you have not asked for or agreed to.",
			"rep": 3,
			"rows": [{"id": "buy", "label": "Buy them", "cost": 1500, "to": "sold"}],
		},
		"cut": {
			"text": "She goes quiet and sells you flowers. It takes eleven seconds and it is the coldest transaction you have had in this city. The questions were not delay. The questions were the sale.",
			"rep": -2,
			"item": "kermel_flowers",
			"rows": [{"id": "ok", "label": "Take them and go", "to": ""}],
		},
		"sold": {
			"text": "The flowers cost what flowers cost. What you paid for was four minutes, and you have just worked out that in this city those four minutes are not overhead.",
			"rep": 2,
			"item": "kermel_flowers",
			"rows": [{"id": "square", "label": "Walk out to the square",
				"to": "square"}],
		},
		"square": {
			"text": "Towers here, and only here: banks, ministries, flags. Ten minutes in any direction nothing is above three floors. The city stacks up in exactly one square and then stops.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Look up at them", "to": ""}],
		},
	},
},

"dakar:ouakam": {
	"title": "Mosquée de la Divinité",
	"start": "road",
	"beats": {
		"road": {
			"film": [
				{"set": "beach", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "White towers at the bottom of a cliff with the Atlantic coming in behind them."},
				{"set": "steps", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.56, "act": "carry"}, {"at": 0.7, "act": "carry"}],
					"say": "Everyone on the path is going up, and all of them are carrying something. I am the only one going down empty-handed."},
			],
			"text": "White towers standing at the bottom of a cliff with the Atlantic coming in behind them. A path goes down. Everyone on it is carrying something up.",
			"rows": [
				{"id": "down", "label": "Take the path down", "to": "down"},
				{"id": "stay", "label": "Stay on the road and look", "to": "stay"},
			],
		},
		"down": {
			"text": "Halfway down, a boy going up with a crate steps off the path to let you pass, and so does the man behind him, and so does the woman behind him. You are the only one going down empty-handed.",
			"rows": [
				{"id": "carry", "label": "Take the crate off him and carry it up",
					"to": "carry"},
				{"id": "on", "label": "Keep going down", "to": "shore"},
			],
		},
		"carry": {
			"text": "He does not let go of it. He lets you take one end. You go up backwards, badly, and at the top four people are laughing and one of them is him.",
			"rep": 3,
			"learn": [["wolof", "jerejef"], ["wolof", "dama"]],
			"rows": [{"id": "shore", "label": "Go back down", "to": "shore"}],
		},
		"shore": {
			"text": "A mosque at the bottom of a cliff, facing the water. Someone dreamed the design and it was built exactly, and they tell you that immediately, before you have asked anything.",
			"rep": 2,
			"rows": [
				{"id": "surf", "label": "Watch the surfers", "to": "surf"},
				{"id": "ok", "label": "Sit on the rocks", "to": ""},
			],
		},
		"surf": {
			"text": "Boys from the village, on boards, in the Atlantic, between the rocks and the mosque. The break is famous somewhere else. Here it is just the sea and nobody is watching it but you.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Sit on the rocks", "to": ""}],
		},
		"stay": {
			"text": "From up here it is a white building on a beach. Everything that makes it worth the trip is happening on the path you did not take.",
			"rows": [{"id": "down", "label": "Take the path after all", "to": "down"}],
		},
	},
},

# ── Mexico City ──────────────────────────────────────────────────────────────

"mexico:roma": {
	"title": "Plaza Río de Janeiro",
	"start": "plaza",
	"beats": {
		"plaza": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Old mansions round a small park, and one gap in the terrace, hoarded off, with flowers taped to the boards."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "stand"}, {"at": 0.54, "act": "walk"}, {"at": 0.7, "act": "walk"}],
					"say": "An alarm goes off, and every door on the square opens, and people begin walking out into the middle of the road."},
			],
			"text": "Porfirian mansions round a small park. One side of the terrace has a gap in it, hoarded off, with a plaque on the boards and fresh flowers taped underneath.",
			"rows": [
				{"id": "plaque", "label": "Read the plaque", "to": "plaque"},
				{"id": "sit", "label": "Sit in the park", "to": "sit"},
			],
		},
		"plaque": {
			"text": "Two dates. Thirty-two years apart. The same month, the same day. You read them twice because you assume you have misread one, and you have not.",
			"rep": 2,
			"learn": [["spanish", "temblor"], ["spanish", "septiembre"]],
			"rows": [{"id": "sit", "label": "Go and sit down", "to": "sit"}],
		},
		"sit": {
			"text": "An alarm goes off. Not a car - a public one, from a pole, loud and flat and unhurried. Every door on the plaza opens and people start walking out into the middle of the road.",
			"rows": [
				{"id": "run", "label": "Run", "sub": "an alarm means run", "to": "ran"},
				{"id": "follow", "label": "Do exactly what they are doing",
					"sub": "which is walking, and not quickly", "to": "drill"},
			],
		},
		"drill": {
			"text": "You stand in the road with two hundred people for four minutes. Somebody's dog is there. Two of them carry on an argument about a delivery. Then it ends and everyone goes back in.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Go back to the bench", "to": ""}],
		},
		"ran": {
			"text": "You are the only person running. A man puts a hand out, not to stop you, just to slow you, and says one word twice. It is practice. It is held on the date it happened, both times.",
			"rep": -1,
			"rows": [
				{"id": "stand", "label": "Stop and stand with them", "to": "drill"},
				{"id": "go", "label": "Keep going", "to": ""},
			],
		},
	},
},

"mexico:coyoacan": {
	"title": "Mercado de Coyoacán",
	"start": "market",
	"beats": {
		"market": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.62, "act": "cut"}],
					"say": "A covered market in what was its own village until the city came and got it."},
				{"set": "counter", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "stand"}, {"at": 0.58, "act": "hand_over"}],
					"say": "Nobody orders a thing. They order a base and keep talking, and she keeps building while they talk."},
			],
			"text": "A covered market in what was its own village until the city came and got it. A counter with a queue, four women working it, and a stack of flat fried discs the size of a hand.",
			"rows": [
				{"id": "queue", "label": "Join the queue and watch the front",
					"to": "watched"},
				{"id": "order", "label": "Go up and point at a finished one",
					"cost": 60, "to": "plain"},
				{"id": "fountain", "label": "Go and find the coyotes", "to": "coyotes"},
			],
		},
		"watched": {
			"text": "Nobody orders a thing. They order a base and then keep talking, and she builds upward while they talk, and it stops when they stop. The size of it is a conversation, not a menu item.",
			"rep": 1,
			"learn": [["spanish", "tostada"], ["spanish", "poquito"]],
			"rows": [
				{"id": "build", "label": "Order, and keep going", "cost": 60,
					"needs": "watched",
					"locked": "you do not know how they are deciding what goes on it",
					"to": "built"},
				{"id": "order", "label": "Point at a finished one", "cost": 60,
					"to": "plain"},
			],
		},
		"built": {
			"text": "You point, she adds, you do not stop, she does not stop. It ends up structurally impossible, and she hands it over with no instructions while everyone nearby watches to see how you hold it.",
			"rep": 3,
			"item": "tostada",
			"rows": [{"id": "ok", "label": "Try to eat it standing up", "to": ""}],
		},
		"plain": {
			"text": "You get the smallest one anybody has ordered all morning. It is correct and it is fine, and the woman behind you gets something four times the size for the same money.",
			"rep": 1,
			"item": "tostada",
			"rows": [{"id": "ok", "label": "Eat it walking", "to": ""}],
		},
		"coyotes": {
			"text": "Two of them, in bronze, in a fountain. The place of the coyotes. The city arrived and swallowed the village, and the village is still, very obviously, a village.",
			"rep": 1,
			"rows": [{"id": "market", "label": "Back to the market", "to": "market"}],
		},
	},
},

"mexico:condesa": {
	"title": "Parque México",
	"start": "oval",
	"beats": {
		"oval": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "An oval park with an oval road round it, and the road is that shape because horses used to run on it."},
				{"set": "park", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.62, "act": "walk"}],
					"say": "A man comes the other way with nine dogs and not one lead, and not one of the nine is out of position."},
			],
			"text": "An oval park with an oval road round it. A man comes the other way with nine dogs and not one lead between them, and none of the nine is out of position.",
			"rows": [
				{"id": "watch", "label": "Watch how he does it", "to": "watched"},
				{"id": "shape", "label": "Work out why the park is this shape",
					"to": "shape"},
			],
		},
		"watched": {
			"text": "He makes a sound you cannot reproduce - not a word, barely a noise - and all nine turn at once. He does it twice more in five minutes and never raises his voice or looks back.",
			"rep": 2,
			"rows": [
				{"id": "try", "label": "Try to make the sound",
					"sub": "quietly, to yourself, walking away", "to": "tried"},
				{"id": "shape", "label": "Go and look at the bandstand", "to": "shape"},
			],
		},
		"tried": {
			"text": "You get it wrong. Two of the dogs look at you anyway, which is worse, and the man laughs and says something over his shoulder that you would give a great deal to have understood.",
			"rep": 1,
			"rows": [{"id": "shape", "label": "Walk on round the oval", "to": "shape"}],
		},
		"shape": {
			"text": "The road is a circle because horses used to run on it. Nobody alive remembers the horses. The road is still exactly the shape of them, and every building on it was built facing a racetrack.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Follow it all the way round", "to": ""}],
		},
	},
},

# ── São Paulo ────────────────────────────────────────────────────────────────

"saopaulo:mercadao": {
	"title": "Mercado Municipal",
	"start": "floor",
	"beats": {
		"floor": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Stained glass over a market floor, and the light through it lands on crates of fruit like it is being introduced."},
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.56, "act": "offer"}],
					"say": "A man has something cut and is holding it out at arm's length, already smiling, before I have slowed down."},
			],
			"text": "Stained glass over a market floor. A man at a fruit stall already has something cut and is holding it out towards you at arm's length, smiling, before you have slowed down.",
			"rows": [
				{"id": "take", "label": "Take it", "sub": "he is offering. It is cut. It is free",
					"to": "trap"},
				{"id": "hands", "label": "Keep your hands where they are",
					"sub": "and look at what happens to the man in front of you",
					"to": "watched"},
			],
		},
		"watched": {
			"text": "The man ahead takes one. Then he is holding it, and a bag appears, and a number is said, and he is buying half a kilo of something he had not been thinking about ten seconds ago.",
			"rep": 2,
			"learn": [["portuguese", "quanto"], ["portuguese", "nao"]],
			"rows": [
				{"id": "walk", "label": "Walk past with your hands down",
					"needs": "watched", "locked": "it is a free piece of fruit",
					"to": "clear"},
				{"id": "take", "label": "Take one anyway", "to": "trap"},
			],
		},
		"trap": {
			"text": "It is in your hand. He is already bagging more of it and saying a number, and the number is not small, and there is a queue behind you now.",
			"rows": [
				{"id": "pay", "label": "Pay for it", "cost": 80, "to": "paid"},
				{"id": "give", "label": "Hand it back and say no",
					"sub": "out loud, once, and keep walking", "to": "refused"},
			],
		},
		"paid": {
			"text": "Eighty. For fruit. He put it in your hand before you agreed to anything and the agreeing was the taking. You have learned something and this is what it cost.",
			"rep": 1,
			"rows": [{"id": "sand", "label": "Go and find the sandwich", "to": "sand"}],
		},
		"refused": {
			"text": "He shrugs and turns to the next person without a flicker. It was never personal and it was never going to be a scene. The word was the whole defence and it took one syllable.",
			"rep": 2,
			"rows": [{"id": "sand", "label": "Go and find the sandwich", "to": "sand"}],
		},
		"clear": {
			"text": "You go past with your hands at your sides and he does not even finish the gesture. Four stalls on, another one starts it, and you are already walking differently.",
			"rep": 3,
			"rows": [{"id": "sand", "label": "Go and find the sandwich", "to": "sand"}],
		},
		"sand": {
			"text": "Half a kilo of mortadella in a bread roll. Everyone warns you and nobody stops you. Two people at the next counter are sharing one and visibly losing.",
			"rows": [
				{"id": "buy", "label": "Order one", "cost": 45, "to": "eaten"},
				{"id": "no", "label": "Look at it and decline", "to": ""},
			],
		},
		"eaten": {
			"text": "It is not a sandwich, it is a structure. You get through perhaps a third of it and the man who sold it to you is not remotely surprised.",
			"rep": 1,
			"item": "mortadela",
			"rows": [{"id": "ok", "label": "Look up at the glass", "to": ""}],
		},
	},
},

"saopaulo:paulista": {
	"title": "Avenida Paulista",
	"start": "avenue",
	"beats": {
		"avenue": {
			"film": [
				{"set": "tower", "secs": 3.4,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "Eight lanes of the most expensive road in the country, with towers standing on both sides of it."},
				{"set": "gate", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "stand"}, {"at": 0.58, "act": "walk"}],
					"say": "A museum held two storeys in the air on four red legs, and the ground floor of it is not a floor. It is just gone."},
			],
			"text": "Eight lanes with towers down both sides, and a museum ahead held two storeys in the air on four red legs. The ground floor of it is not a ground floor. It is just gone.",
			"rows": [
				{"id": "under", "label": "Walk into the space under the museum",
					"to": "vao"},
				{"id": "in", "label": "Go up into the museum instead", "cost": 70,
					"to": "inside"},
			],
		},
		"vao": {
			"text": "A covered square the size of the building, open on all four sides, full of people who are not going to the museum. A protest is setting up at one end. Somebody is selling coffee off a bike.",
			"rep": 2,
			"learn": [["portuguese", "vao"], ["portuguese", "livre"]],
			"rows": [
				{"id": "stay", "label": "Stay and see what it is for", "to": "stay"},
				{"id": "in", "label": "Go up into the museum", "cost": 70,
					"to": "inside"},
			],
		},
		"stay": {
			"text": "She lifted the building off the ground and gave the space underneath back to the street, and the street took it. It is the most used room in the city and it is not a room.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Sit on the edge of it", "to": ""}],
		},
		"inside": {
			"text": "The paintings are on glass easels in the middle of the floor with nothing behind them, so you see the back of every one and the room and the people through it. There is no correct order to walk in.",
			"rep": 2,
			"rows": [
				{"id": "order", "label": "Try to find the intended route",
					"to": "noorder"},
				{"id": "ok", "label": "Wander", "to": ""},
			],
		},
		"noorder": {
			"text": "There is not one. That was the decision. Every wall label is behind the picture, so you look, and then you find out what you were looking at, and never the other way round.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Go back to the first one", "to": ""}],
		},
	},
},

"saopaulo:vilamadalena": {
	"title": "Beco do Batman",
	"start": "alley",
	"beats": {
		"alley": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "An alley where every wall is painted and none of the paint is dry enough to be old."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.36, "act": "point"}],
					"say": "Above the murals, up the sides of the buildings, thin spiky black letters that are not for me at all."},
			],
			"text": "An alley where every wall is painted and none of it is old. Above the murals, running up the sides of the buildings, thin spiky black lettering in a shape you cannot read at all.",
			"rows": [
				{"id": "murals", "label": "Look at the murals", "to": "murals"},
				{"id": "black", "label": "Look at the thin black letters",
					"to": "pixo"},
			],
		},
		"murals": {
			"text": "Some of it went up last night over something that was here last week. Nothing in this alley is older than a few months and everybody treats it as a monument, and the monument is that it keeps changing.",
			"rep": 1,
			"rows": [
				{"id": "black", "label": "Look up at the black letters", "to": "pixo"},
				{"id": "ok", "label": "Walk it slowly", "to": ""},
			],
		},
		"pixo": {
			"text": "It is not decoration and it is not for you. It is an alphabet, it is signed, and it is fifteen metres up a blank wall with no scaffolding and no way to have got there safely.",
			"rep": 2,
			"learn": [["portuguese", "pixo"], ["portuguese", "letra"]],
			"rows": [
				{"id": "ask", "label": "Ask somebody what it says", "to": "asked"},
				{"id": "ok", "label": "Stand and look at the height of it", "to": ""},
			],
		},
		"asked": {
			"text": "The woman you ask looks up, then at you, and says a name - just a name, as though you had asked who lives at a house. Then she carries on, because that was the entire answer.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Look at the wall again", "to": ""}],
		},
	},
},

# ── La Paz ───────────────────────────────────────────────────────────────────

"lapaz:sopocachi": {
	"title": "Plaza Avaroa",
	"start": "plaza",
	"beats": {
		"plaza": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}, {"at": 0.58, "act": "sit"}],
					"say": "Trees, benches, a statue, and the whole neighbourhood going through it on the way to somewhere."},
				{"set": "park", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "scrub"}],
					"say": "Two men working shoes are wearing knitted masks over their faces, in a public square, in the afternoon."},
			],
			"text": "Trees, benches, a statue, and the neighbourhood going through. Two men working shoes wear knitted balaclavas with only the eyes showing, in the middle of the afternoon, in a public square.",
			"rows": [
				{"id": "why", "label": "Work out why their faces are covered",
					"to": "why"},
				{"id": "cart", "label": "Buy something off the drinks cart",
					"cost": 10, "to": "api"},
				{"id": "avoid", "label": "Sit on a bench well away from them",
					"to": "avoided"},
			],
		},
		"why": {
			"text": "Nobody in the square reacts to them at all. A woman gets her shoes done and talks the whole time. It is not to frighten anyone. It is so that nobody they know sees them doing it.",
			"rep": 3,
			"learn": [["spanish", "lustrabotas"], ["spanish", "verguenza"]],
			"rows": [
				{"id": "shoes", "label": "Get your shoes done", "cost": 5,
					"needs": "why", "locked": "you are not going near them",
					"to": "shoes"},
				{"id": "cart", "label": "Buy something off the cart", "cost": 10,
					"to": "api"},
			],
		},
		"shoes": {
			"text": "He works and talks and you understand about a fifth of it. At the end he looks at your face rather than your feet for the first time, and that is the transaction that actually happened.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Sit down for a while", "to": ""}],
		},
		"avoided": {
			"text": "You sit at the far end with your back to them and nothing happens, because nothing was ever going to happen. You have spent an afternoon being careful about the wrong thing.",
			"rep": -1,
			"rows": [
				{"id": "why", "label": "Watch them properly", "to": "why"},
				{"id": "ok", "label": "Move on", "to": ""},
			],
		},
		"api": {
			"text": "Hot, purple, thick, made of corn, in a glass, at four thousand metres. It does the job that nothing else has done since you landed and you understand the whole city slightly better holding it.",
			"rep": 2,
			"item": "api",
			"rows": [{"id": "ok", "label": "Drink it on a bench", "to": ""}],
		},
	},
},

"lapaz:sanpedro": {
	"title": "Plaza San Pedro",
	"start": "square",
	"beats": {
		"square": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "An ordinary square: trees, benches, a market, a church. One whole side of it is a blank wall with a small gate in it."},
				{"set": "gate", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.58, "act": "carry"}],
					"say": "Women with shopping bags are going in through the gate. Children are coming out of it."},
			],
			"text": "An ordinary square: trees, benches, a market, a church. One whole side of it is a blank wall with a small gate in it, and women with shopping bags are going in through the gate.",
			"rows": [
				{"id": "gate", "label": "Watch the gate", "to": "gate"},
				{"id": "square", "label": "Sit in the square with everyone else",
					"to": "sat"},
				{"id": "past", "label": "Walk on quickly", "to": ""},
			],
		},
		"gate": {
			"text": "Children go in. Children come out. A woman goes in with vegetables and comes out with an empty bag and a school uniform over her arm. Nothing about the traffic through that gate is one-way.",
			"rep": 2,
			"learn": [["spanish", "carcel"], ["spanish", "familia"]],
			"rows": [
				{"id": "ask", "label": "Ask the woman at the stall about it",
					"needs": "gate", "locked": "it is a wall with a door in it",
					"to": "asked"},
				{"id": "sat", "label": "Go and sit in the square", "to": "sat"},
			],
		},
		"asked": {
			"text": "Families live in there with them. They pay rent for their cells. There is a shop inside. She tells you this the way you would give directions, and then asks if you want the potatoes.",
			"rep": 3,
			"rows": [{"id": "sat", "label": "Go and sit down", "to": "sat"}],
		},
		"sat": {
			"text": "Children in the square, a wall, and behind the wall more children. Everybody here has arranged their day around a fact you found out four minutes ago.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Stay a while", "to": ""}],
		},
	},
},

"lapaz:irpavi": {
	"title": "Zona Sur",
	"start": "cable",
	"beats": {
		"cable": {
			"film": [
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.4, "act": "sit"}],
					"say": "Eight hundred metres down in eleven minutes, in a box on a wire, over the roofs."},
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}],
					"say": "Somewhere on the way my chest stopped arguing with me, and I noticed it happening."},
			],
			"text": "You come down eight hundred metres in a cable car, over roofs, in eleven minutes. Somewhere on the way your chest stops arguing with you and you notice it happening.",
			"rep": 1,
			"learn": [["spanish", "bajar"], ["spanish", "aire"]],
			"rows": [
				{"id": "notice", "label": "Sit with the difference in the air",
					"to": "air"},
				{"id": "mall", "label": "Go into the shopping centre", "to": "mall"},
			],
		},
		"air": {
			"text": "The same city. A third of an hour away. Eight hundred metres of altitude between one half of it and the other, and the money went downhill, which is the exact opposite of everywhere you have been.",
			"rep": 3,
			"rows": [
				{"id": "mall", "label": "Go into the shopping centre", "to": "mall"},
				{"id": "ok", "label": "Look back up the hill", "to": ""},
			],
		},
		"mall": {
			"text": "Escalators, chains, a cinema, air conditioning. There is nothing in here to tell you which country you are in, and for a lot of the people in it that is the product.",
			"rep": 1,
			"rows": [
				{"id": "back", "label": "Go back out and look up the hill",
					"to": "uphill"},
				{"id": "ok", "label": "Stay in the cool for a bit", "to": ""},
			],
		},
		"uphill": {
			"text": "From the car park you can see the rim, four thousand metres up, brick the colour of the ground, going all the way round. Everyone in this car park came down from it this morning.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Get back in the cable car", "to": ""}],
		},
	},
},

}
