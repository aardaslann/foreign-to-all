extends Object

# Streetside encounters: Western Europe.
# Played through Streetside.spot() and the beat engine in Services._local().
#
# Switzerland, Italy and France. Britain moved next door to Berlin when the
# two original cities finally got streets worth stopping on; the other half of
# Europe - Russia, Georgia and Turkey - is in StreetsideNorth.gd. The split is
# only ever about keeping one file from running past the size this project
# allows.

const SPOTS := {

# ── Zürich ───────────────────────────────────────────────────────────────────

"zurich:zurichwest": {
	"title": "Im Viadukt",
	"start": "arches",
	"beats": {
		"arches": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Thirty-six arches under a railway, and every one of them has a shop in it. A train goes over the top and nobody looks up."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.62, "act": "stand"}],
					"say": "Seventeen shipping containers bolted into a tower, with stairs. Somebody decided rust was a material and everybody agreed."},
			],
			"text": "A railway viaduct with every arch bricked up and let out as a shop, thirty-six of them in a row, and the trains still going over the top every few minutes.",
			"rows": [
				{"id": "walk", "label": "Walk the arches", "to": "walked"},
				{"id": "tower", "label": "Go up the stack of shipping containers",
					"sub": "seventeen of them, rusted, bolted together, with a shop inside",
					"to": "tower"},
			],
		},
		"walked": {
			"text": "Every arch is a different trade and all of them are expensive. Nothing anywhere says what this was. The viaduct is a hundred and twenty years old and is being treated as decor.",
			"rep": 1,
			"learn": [["swissgerman", "viadukt"], ["swissgerman", "gleis"]],
			"rows": [
				{"id": "tower", "label": "Go up the container tower", "to": "tower"},
				{"id": "ok", "label": "Stand under it as a train goes over", "to": ""},
			],
		},
		"tower": {
			"text": "From the roof: cranes, glass, new flats, and one foundry chimney standing on its own that somebody fought to keep. This whole quarter was where the city made things, within living memory.",
			"rep": 2,
			"rows": [
				{"id": "chimney", "label": "Look at the chimney properly",
					"to": "chimney"},
				{"id": "ok", "label": "Climb back down", "to": ""},
			],
		},
		"chimney": {
			"text": "It goes to nothing. It is a brick tube with no furnace under it, kept because the shape of the work is worth more to this quarter now than the work was.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Climb back down", "to": ""}],
		},
	},
},

"zurich:seefeld": {
	"title": "Utoquai",
	"start": "wall",
	"beats": {
		"wall": {
			"film": [
				{"set": "water", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "A wooden bathhouse on stilts, and sixty people in the lake at eleven in the morning on a working Tuesday."},
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.58, "act": "swim"}],
					"say": "They are all wearing office clothes on the bank. Not one of them has made an afternoon of it."},
			],
			"text": "A wooden bathhouse on stilts out over the lake. It is the middle of a working day and there are perhaps sixty people in the water, most of them wearing office clothes on the bank.",
			"rows": [
				{"id": "watch", "label": "Watch what they do afterwards",
					"to": "watched"},
				{"id": "swim", "label": "Pay in and swim", "cost": 8, "to": "cold"},
				{"id": "garden", "label": "Go and find the Chinese garden",
					"to": "garden"},
			],
		},
		"watched": {
			"text": "They swim, they dry off in about four minutes, they put the shirt back on, and they go back to work with wet hair and nobody at the office will remark on it. It is a lunch break.",
			"rep": 1,
			"learn": [["swissgerman", "badi"], ["swissgerman", "schwuume"]],
			"rows": [
				{"id": "lunch", "label": "Do it the way they do it",
					"sub": "in, out, dry, gone, forty minutes", "cost": 8,
					"needs": "watched",
					"locked": "you would treat this as an afternoon", "to": "lunch"},
				{"id": "swim", "label": "Pay in and stay all afternoon", "cost": 8,
					"to": "cold"},
			],
		},
		"lunch": {
			"text": "In, out, dry, gone. You are back on the pavement in forty minutes with cold hair, and for the length of that swim you were doing exactly what everybody else was doing.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Walk back up into the city", "to": ""}],
		},
		"cold": {
			"text": "The lake is clean enough to drink and cold enough to argue with. You stay in too long, come out grey, and are the only person on the deck who has made an occasion of it.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Sit in the sun until you stop shaking",
				"to": ""}],
		},
		"garden": {
			"text": "A Chinese garden, given to this city by a city called Kunming, in return for help with their water pipes. One city gave another city a garden for fixing the drains.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Walk round it twice", "to": ""}],
		},
	},
},

"zurich:oerlikon": {
	"title": "MFO-Park",
	"start": "frame",
	"beats": {
		"frame": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "A steel frame four storeys high with nothing inside it and no roof on it, and the walls are plants."},
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "walk"}, {"at": 0.64, "act": "sit"}],
					"say": "People are eating lunch in it. I cannot work out whether I am indoors."},
			],
			"text": "A steel frame four storeys high with nothing inside it, standing on the footprint of a machine works. The walls are climbing plants. There is no roof. People are eating lunch in it.",
			"rows": [
				{"id": "up", "label": "Go up the stairs at the end", "to": "up"},
				{"id": "plaque", "label": "Find out what stood here", "to": "plaque"},
			],
		},
		"up": {
			"text": "Three flights, and then a walkway with green on both sides and sky above. A room with no roof and walls made of plants. You cannot decide whether you are indoors and neither can the building.",
			"rep": 2,
			"rows": [
				{"id": "plaque", "label": "Go and read the plaque", "to": "plaque"},
				{"id": "ok", "label": "Sit up here", "to": ""},
			],
		},
		"plaque": {
			"text": "The machine works. Turbines, generators, weapons. They kept the exact footprint and the exact height and threw away everything that made it, and called the empty shape a park.",
			"rep": 2,
			"learn": [["swissgerman", "fabrik"], ["swissgerman", "gruen"]],
			"rows": [{"id": "ok", "label": "Stand in the middle of it", "to": ""}],
		},
	},
},

# ── Rome ─────────────────────────────────────────────────────────────────────

"rome:trastevere": {
	"title": "Il nasone",
	"start": "corner",
	"beats": {
		"corner": {
			"film": [
				{"set": "street", "secs": 3.4, "prop": "glass", "prop_at": 0.72,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A cast-iron spout on a corner, running water into a drain, and it has not been turned off in a hundred and fifty years."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.58, "act": "drink"}],
					"say": "A child does something to the end of it with a thumb and the water goes upward into her mouth. Then she is gone."},
			],
			"text": "A cast-iron spout on a corner running water it never turns off, into a drain, all day and all night. Four lanes meet here and the church at the end has gold inside it.",
			"rows": [
				{"id": "drink", "label": "Drink from the spout",
					"sub": "you will have to get low and it will run down your chin",
					"to": "wet"},
				{"id": "watch", "label": "Wait and see how anyone else does it",
					"to": "watched"},
				{"id": "steps", "label": "Go and sit on the church steps",
					"to": "steps"},
			],
		},
		"watched": {
			"text": "A child does it without breaking stride: covers the end of the spout with a thumb, and the water gives up and comes out of a small hole on top in an arc, at mouth height.",
			"rep": 2,
			"learn": [["italian", "acqua"], ["italian", "nasone"]],
			"rows": [
				{"id": "thumb", "label": "Cover the end with your thumb",
					"needs": "watched", "locked": "it is a tap. It points down",
					"to": "arc"},
				{"id": "drink", "label": "Get down and drink from the spout",
					"to": "wet"},
			],
		},
		"arc": {
			"text": "The water changes its mind and goes upward into your mouth. There are two thousand of these in the city and every single one has the second hole and nobody has ever put up a sign.",
			"rep": 3,
			"rows": [{"id": "steps", "label": "Go and sit on the steps", "to": "steps"}],
		},
		"wet": {
			"text": "You get most of it on your shirt. A man at the bar opposite watches the whole thing, waits until you have finished, and then does the thumb trick slowly, facing you, twice.",
			"rep": 1,
			"rows": [
				{"id": "thumb", "label": "Try it his way", "to": "arc"},
				{"id": "steps", "label": "Go and sit down", "to": "steps"},
			],
		},
		"steps": {
			"text": "The oldest church in the city is behind you, with gold mosaics in it. Everyone on the steps is facing out into the square. The building is not the point. It is the thing to sit on.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Sit facing out", "to": ""}],
		},
	},
},

"rome:monti": {
	"title": "Piazza della Madonna dei Monti",
	"start": "piazza",
	"beats": {
		"piazza": {
			"film": [
				{"set": "street", "secs": 3.4, "prop": "glass", "prop_at": 0.78,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A fountain with a step round it, and by nine the step has forty people on it and every one of them has a bottle."},
				{"set": "counter", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.62, "act": "hand_over"}],
					"say": "They buy at the counter and carry it straight out. The room with the bottles in it is not where the evening is."},
			],
			"text": "A small fountain with a wide step around it. By nine the step is full - forty people sitting on it, all with a bottle, none of them inside the bar that sold it to them.",
			"rows": [
				{"id": "bar", "label": "Go into the bar and drink it there",
					"cost": 4, "to": "inside"},
				{"id": "take", "label": "Buy one and bring it outside", "cost": 4,
					"to": "outside"},
				{"id": "edge", "label": "Stand at the edge and watch", "to": "edge"},
			],
		},
		"edge": {
			"text": "Nobody is sitting inside. They buy at the counter, pay a third of what a table costs, and carry it out to the step. The room with the bottles in it is not where the evening is.",
			"rep": 1,
			"learn": [["italian", "banco"], ["italian", "fuori"]],
			"rows": [
				{"id": "take", "label": "Buy at the counter and come out",
					"cost": 4, "needs": "edge",
					"locked": "you assume you are meant to sit down somewhere",
					"to": "outside"},
				{"id": "bar", "label": "Sit at a table inside", "cost": 4,
					"to": "inside"},
			],
		},
		"outside": {
			"text": "You take a place on the step. There is room, and taking it is the whole transaction. The conversation beside you does not stop or slow, which has not happened once since you got here.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay until the step empties", "to": ""}],
		},
		"inside": {
			"text": "You sit at a table in an empty room, pay the table price, and watch forty people have the evening through the window. The barman brings your drink and looks faintly sorry for you.",
			"rep": -1,
			"rows": [
				{"id": "out", "label": "Take it outside after all", "to": "outside"},
				{"id": "ok", "label": "Finish it in here", "to": ""},
			],
		},
	},
},

"rome:garbatella": {
	"title": "Lotto 24",
	"start": "road",
	"beats": {
		"road": {
			"film": [
				{"set": "courtyard", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Not a street. An opening into a courtyard, with flats on all four sides of it and washing across the middle."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "stand"}, {"at": 0.62, "act": "reach"}],
					"say": "A woman on the second floor sees me, keeps hanging washing, and does not stop seeing me."},
			],
			"text": "Not a street: an entrance into a courtyard, with flats built round all four sides of it and washing strung across the middle. There is no gate and no sign and no doubt that it is theirs.",
			"rows": [
				{"id": "in", "label": "Walk in", "to": "court"},
				{"id": "wait", "label": "Stand at the entrance a moment first",
					"sub": "somebody will look up, and what they do next is the answer",
					"to": "waited"},
				{"id": "on", "label": "Stay on the road", "to": ""},
			],
		},
		"waited": {
			"text": "A woman on the second floor sees you, keeps hanging washing, and does not stop seeing you. That is not a refusal. In this courtyard it is the whole of the permission process.",
			"rep": 1,
			"learn": [["italian", "cortile"], ["italian", "lotto"]],
			"rows": [
				{"id": "in", "label": "Go in, slowly, in her sightline",
					"needs": "waited", "locked": "you would walk in as if it were a street",
					"to": "welcome"},
				{"id": "on", "label": "Leave them to it", "to": ""},
			],
		},
		"court": {
			"text": "You are four steps in before you understand you are standing in somebody's yard. Two children stop. A man puts down a crate. Nobody says anything and nobody has to.",
			"rep": -1,
			"rows": [
				{"id": "back", "label": "Back out to the road", "to": "backed"},
				{"id": "table", "label": "Sit down at the long table anyway",
					"to": "presumed"},
			],
		},
		"welcome": {
			"text": "She finishes the row of washing and goes inside, which is how you know it was fine. Built for workers a hundred years ago in a style trying hard to look like a village. It worked. It is a village.",
			"rep": 2,
			"rows": [
				{"id": "table", "label": "Sit at the long table", "to": "table"},
				{"id": "ok", "label": "Walk round and go", "to": ""},
			],
		},
		"table": {
			"text": "Somebody put a table in the middle of the courtyard for everybody, which is the entire idea of this place. You sit at the end of it and nobody asks you anything for twenty minutes.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay until somebody does", "to": ""}],
		},
		"presumed": {
			"text": "You sit at their table. The man picks the crate back up. It is not a scene and there will not be one, and you will simply never find out what this place is like when you are not being tolerated.",
			"rep": -2,
			"rows": [{"id": "ok", "label": "Leave after a minute", "to": ""}],
		},
		"backed": {
			"text": "You back out and stand on the road. Through the entrance you can see the table, the washing, and eleven people who all know each other, and none of that was ever hidden from you.",
			"rep": 1,
			"rows": [{"id": "wait", "label": "Try it again properly", "to": "waited"}],
		},
	},
},

# ── Paris ────────────────────────────────────────────────────────────────────

"paris:champdemars": {
	"title": "Champ-de-Mars",
	"start": "lawn",
	"beats": {
		"lawn": {
			"film": [
				{"set": "tower", "secs": 4.0,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "It does not stop. I keep looking up and the iron keeps going and the top of it is not in the sky I can see."},
				{"set": "park", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "sit"}, {"at": 0.54, "act": "sit"}, {"at": 0.7, "act": "sit"}],
					"say": "Half the district is lying on the grass under it with bread and a bottle, and almost none of them are looking up."},
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.6, "act": "offer"}],
					"say": "A man works the path with thirty small metal towers threaded on a loop of wire, and one already in his hand for me."},
			],
			"text": "A long formal lawn with the tower standing in the open end of it. Men are working the path with loops of wire, thirty small metal towers threaded onto each loop.",
			"rows": [
				{"id": "grass", "label": "Sit on the grass with everyone else",
					"to": "grass"},
				{"id": "seller", "label": "Let one of them show you the wire",
					"to": "seller"},
			],
		},
		"grass": {
			"text": "There is a sign about the grass. Nobody has ever read it. Half the district is lying on it at six in the evening with bread and a bottle, and almost none of them are looking up.",
			"rep": 2,
			"learn": [["french", "pelouse"], ["french", "soir"]],
			"rows": [
				{"id": "seller", "label": "Watch what happens when the police come",
					"to": "police"},
				{"id": "ok", "label": "Stay until it gets dark", "to": ""},
			],
		},
		"police": {
			"text": "Two of them walk down the path and every loop of wire disappears at the same moment, without anyone signalling. Four minutes later all of it is back and nothing has been said.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Lie back down", "to": ""}],
		},
		"seller": {
			"text": "He has thirty on the wire and one already in his hand for you. He says a number. Behind him, ten metres away, another man is holding up the same wire.",
			"rows": [
				{"id": "pay", "label": "Pay what he asked", "cost": 10, "to": "full"},
				{"id": "look", "label": "Look at the other man first", "to": "compare"},
			],
		},
		"compare": {
			"text": "The same wire, the same towers, half the number. Neither of them is cheating you. There is simply no fixed price, and the first number is only ever the first number.",
			"rep": 2,
			"rows": [
				{"id": "half", "label": "Go back and offer him half", "cost": 5,
					"needs": "compare", "locked": "he said a price and prices are prices",
					"to": "deal"},
				{"id": "pay", "label": "Pay the first man anyway", "cost": 10,
					"to": "full"},
			],
		},
		"deal": {
			"text": "He takes it without a flicker and is already walking at somebody else before you have got your hand out of your pocket. It was never an insult to ask. Asking was the mechanism.",
			"rep": 2,
			"item": "tower_charm",
			"rows": [{"id": "grass", "label": "Go and lie on the grass", "to": "grass"}],
		},
		"full": {
			"text": "You pay it. It is a small metal tower and it is fine. Ten metres away the same object is going for half and both men know it and neither of them is doing anything wrong.",
			"rep": -1,
			"item": "tower_charm",
			"rows": [{"id": "grass", "label": "Go and lie on the grass", "to": "grass"}],
		},
	},
},

"paris:marais": {
	"title": "Rue des Rosiers",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Narrow, crooked, nothing lining up with anything. This quarter was never rebuilt and it has not forgotten."},
				{"set": "counter", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "queue"}, {"at": 0.56, "act": "queue"}, {"at": 0.72, "act": "cut"}],
					"say": "One shop with a queue down the pavement, and a man at the door calling the orders back over his shoulder in three languages."},
			],
			"text": "Narrow, medieval, nothing lining up with anything - this quarter was never rebuilt. One shop has a queue down the pavement and a man at the door shouting orders back over his shoulder in three languages.",
			"rows": [
				{"id": "queue", "label": "Join the queue", "to": "queue"},
				{"id": "square", "label": "Go and find the brick square instead",
					"to": "vosges"},
			],
		},
		"queue": {
			"text": "It moves fast. When you get to the front he says something at speed, and does not slow down, and behind you the queue is close enough that stopping it has a cost.",
			"rows": [
				{"id": "bonjour", "label": "Say bonjour first, then everything else",
					"to": "greeted"},
				{"id": "order", "label": "Say the name of the thing and hold out money",
					"cost": 9, "to": "cold"},
			],
		},
		"greeted": {
			"text": "One word before anything else and his whole face changes register. He waits for you now. He suggests something. He tells you which of two things is better today and hands it over.",
			"rep": 3,
			"cost": 9,
			"item": "falafel",
			"learn": [["french", "bonjour"], ["french", "voila"]],
			"rows": [{"id": "vosges", "label": "Eat it walking to the square",
				"to": "vosges"}],
		},
		"cold": {
			"text": "You get exactly what you named, correctly, at speed, with nothing added. It is very good and the entire exchange was four seconds long and neither of you was in it.",
			"rep": -1,
			"item": "falafel",
			"rows": [
				{"id": "again", "label": "Come back tomorrow and start differently",
					"to": "greeted"},
				{"id": "vosges", "label": "Walk to the square", "to": "vosges"},
			],
		},
		"vosges": {
			"text": "Red brick with stone quoins, steep blue slate, an arcade all the way round, and thirty-six pavilions identical to each other. From 1612, and the first square in this city that was planned rather than grown.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Sit under the arcade", "to": ""}],
		},
	},
},

"paris:montmartre": {
	"title": "Place du Tertre",
	"start": "square",
	"beats": {
		"square": {
			"film": [
				{"set": "steps", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Stairs, and then more stairs, and at the top of them a white church too bright to be the same century as anything under it."},
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.56, "act": "write"}, {"at": 0.74, "act": "sit"}],
					"say": "A square the size of a room, packed edge to edge with easels, and not one of the painters is moving."},
			],
			"text": "A small square at the top of the hill, packed edge to edge with easels. Every painter has a pitch and none of them are moving. Below, a white basilica the size of the sky.",
			"rows": [
				{"id": "sit", "label": "Sit for a portrait", "cost": 40,
					"to": "portrait"},
				{"id": "pitch", "label": "Work out why nobody moves their easel",
					"to": "pitch"},
				{"id": "vines", "label": "Go and find the vineyard", "to": "vines"},
			],
		},
		"pitch": {
			"text": "Every painter in this square holds a licence, there are a fixed number of them, and there is a waiting list measured in years. The disorder is administered, in an office, by name.",
			"rep": 2,
			"learn": [["french", "place"], ["french", "permis"]],
			"rows": [
				{"id": "sit", "label": "Sit for one of them", "cost": 40,
					"to": "portrait"},
				{"id": "vines", "label": "Go and find the vineyard", "to": "vines"},
			],
		},
		"portrait": {
			"text": "Fifteen minutes in charcoal, and he will not let you see it until it is done. When he turns it round it is flattering and it is not your face, and he watches you notice both things.",
			"rep": 1,
			"item": "portrait",
			"rows": [
				{"id": "say", "label": "Tell him it is not quite you",
					"to": "honest"},
				{"id": "smile", "label": "Take it and thank him", "to": "polite"},
			],
		},
		"honest": {
			"text": "He laughs, takes it back, and puts four lines into it that are wrong in a way that makes it right. He knew. He does this every time and waits to see who says so.",
			"rep": 3,
			"rows": [{"id": "vines", "label": "Go and find the vineyard", "to": "vines"}],
		},
		"polite": {
			"text": "He rolls it, ties it, hands it over. Both of you know and neither of you is going to say it, and that turns out to be a kind of transaction as well.",
			"rep": 1,
			"rows": [{"id": "vines", "label": "Go and find the vineyard", "to": "vines"}],
		},
		"vines": {
			"text": "A real vineyard, behind a fence, on the north slope, in the middle of the city. It still makes wine, badly, and the money goes to the district. Nobody is looking at it but you and a man walking a dog.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Stand at the fence", "to": ""}],
		},
	},
},

"paris:belleville": {
	"title": "Parc de Belleville",
	"start": "hill",
	"beats": {
		"hill": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "The steepest street I have walked up in this city, past a Chinese supermarket and a Tunisian bakery on the same wall."},
				{"set": "park", "secs": 3.8,
					"cast": [{"at": 0.36, "act": "watch"}],
					"say": "At the top, a terrace with no ticket office, and the whole city laid out flat with one lattice mast sticking out of it."},
			],
			"text": "The steepest street you have walked up in this city, past a Chinese supermarket, a Tunisian bakery and three painted shutters. At the top there is a terrace and no ticket office.",
			"rows": [
				{"id": "top", "label": "Go up to the terrace", "to": "top"},
				{"id": "market", "label": "Stop at the market on the boulevard",
					"to": "market"},
			],
		},
		"top": {
			"text": "The whole city, laid out flat, with one lattice mast sticking out of it and a white dome off to the left. Nobody charged you anything and there are eleven people up here.",
			"rep": 3,
			"learn": [["french", "vue"], ["french", "colline"]],
			"rows": [
				{"id": "market", "label": "Go back down to the market", "to": "market"},
				{"id": "ok", "label": "Sit on the wall until it gets dark", "to": ""},
			],
		},
		"market": {
			"text": "One stall, four languages, and the man running it switches between them mid-sentence without slowing down. He is not performing. It is simply faster than choosing one.",
			"rep": 2,
			"rows": [
				{"id": "try", "label": "Try him in the one word of French you trust",
					"to": "tried"},
				{"id": "point", "label": "Point at what you want", "cost": 6,
					"to": "pointed"},
			],
		},
		"tried": {
			"text": "He answers in French, then repeats it in something else, then in a third thing, watching your face each time to see which one lands. None of them do. He is completely unbothered and tries a fourth.",
			"rep": 3,
			"cost": 6,
			"rows": [{"id": "ok", "label": "Buy what he ends up holding", "to": ""}],
		},
		"pointed": {
			"text": "You get what you pointed at. He was ready to meet you in any of four languages and you used none of them, which is allowed, and is also the smallest version of this that was available.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Eat it on the hill", "to": ""}],
		},
	},
},

"paris:ladefense": {
	"title": "The Esplanade",
	"start": "deck",
	"beats": {
		"deck": {
			"film": [
				{"set": "tower", "secs": 3.6,
					"cast": [{"at": 0.44, "act": "watch"}],
					"say": "Glass, on all sides, going up out of a concrete deck with the roads and the trains buried underneath it."},
				{"set": "gate", "secs": 3.8,
					"cast": [{"at": 0.36, "act": "stand"}],
					"say": "A hollow cube in white marble, a hundred and ten metres on a side, with offices in the walls and nothing in the middle."},
			],
			"text": "A concrete deck with the motorways and the trains buried underneath it, towers standing on top, and a wind that was not designed and cannot now be removed. It is a Sunday and there is nobody here.",
			"rows": [
				{"id": "arche", "label": "Walk up to the marble cube", "to": "arche"},
				{"id": "look", "label": "Look back east down the deck", "to": "axis"},
			],
		},
		"arche": {
			"text": "A hollow cube, a hundred and ten metres on a side, faced in white marble, with offices in the walls and nothing in the middle. It is a door. That is the whole building.",
			"rep": 2,
			"learn": [["french", "arche"], ["french", "axe"]],
			"rows": [
				{"id": "look", "label": "Stand in the middle and look east",
					"to": "axis"},
				{"id": "ok", "label": "Walk round the outside of it", "to": ""},
			],
		},
		"axis": {
			"text": "Straight down the deck, straight down an avenue, six kilometres away and dead centre, another arch. Somebody drew a line on a map three hundred years ago and they are still building along it.",
			"rep": 3,
			"rows": [
				{"id": "why", "label": "Work out why the towers are all out here",
					"to": "why"},
				{"id": "ok", "label": "Stand on the line", "to": ""},
			],
		},
		"why": {
			"text": "The city banned height in the middle after one tower went up in 1973 and everybody hated it. So every tower in the country is standing on this slab, outside the boundary, and you can see the join from here.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Look back at the low city", "to": ""}],
		},
	},
},

}
