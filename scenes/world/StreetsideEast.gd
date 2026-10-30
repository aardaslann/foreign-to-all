extends Object

# Streetside encounters: Asia and the Pacific.
# Played through Streetside.spot() and the beat engine in Services._local().
#
# Every spot is a small scene, not a menu. See Streetside.gd for the shape;
# the short of it is that "needs" gates a move on having watched first, "toss"
# makes an outcome a real draw, and a wrong move lands in a beat that either
# lets you recover or does not.

const SPOTS := {

# ── Hanoi ────────────────────────────────────────────────────────────────────

"hanoi:badinh": {
	"title": "Ba Đình",
	"start": "square",
	"beats": {
		"square": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}],
					"say": "A parade square with nothing in it at all, and a low grey building at the far end of the nothing."},
				{"set": "queue", "secs": 3.6,
					"cast": [{"at": 0.26, "act": "watch"}, {"at": 0.52, "act": "queue"},
						{"at": 0.68, "act": "queue"},
						{"at": 0.88, "act": "stand", "z": 0.18,
							"appearance": {"build": "adult", "wear": "suit", "cut": "cap", "face": "",
								"pal": {"C": "eeeade", "D": "c6c9c1", "B": "deded3", "P": "ece8d9", "p": "aa974f", "g": "bf4334", "a": "e5e2d6"}}}],
					"say": "A queue four abreast, barely moving, and guards in white standing at ten-metre intervals down the whole length of it."},
			],
			"text": "A parade square with nothing in it, a low grey building at the far end, and a queue four abreast that is barely moving. Guards in white at ten-metre intervals.",
			"rows": [
				{"id": "watch", "label": "Watch the queue before joining it",
					"sub": "it costs a few minutes and there is clearly a way this is done",
					"to": "watched"},
				{"id": "join", "label": "Join the back of it",
					"sub": "it is a queue. You have stood in queues", "to": "raw"},
				{"id": "pagoda", "label": "Go and look at the small pagoda",
					"sub": "one wooden hall on a single stone pillar, in a pond",
					"to": "pagoda"},
			],
		},
		"watched": {
			"text": "Hands out of pockets. Nothing on the shoulders. Nobody talking, nobody stopping. A man takes his hat off before the guard asks, which is how you know it was expected.",
			"rep": 1,
			"learn": [["vietnamese", "lang"], ["vietnamese", "im"]],
			"rows": [
				{"id": "clean", "label": "Empty your hands and join",
					"sub": "hands out, bag down, mouth shut", "needs": "watched",
					"locked": "you do not know what they are all doing with their hands",
					"to": "clean"},
				{"id": "join", "label": "Join and improvise", "to": "raw"},
			],
		},
		"clean": {
			"text": "You go the whole way in silence with your hands where they can be seen. Nobody corrects you. At the far door a guard looks at you once and then at the next person.",
			"rep": 3,
			"rows": [{"id": "out", "label": "Out into the light", "to": ""}],
		},
		"raw": {
			"text": "Forty paces in, a guard steps across and lifts your wrist out of your pocket with one finger. He does not look at your face while he does it. Nobody behind you reacts at all.",
			"rep": -1,
			"rows": [
				{"id": "copy", "label": "Copy the man in front exactly",
					"sub": "whatever he does, half a second later", "to": "copied"},
				{"id": "leave", "label": "Step out at the gap in the rail",
					"to": "left"},
			],
		},
		"copied": {
			"text": "You shadow him: hands, pace, eyes forward. It works. It was always going to work. Every rule in this square could have been had by watching for ninety seconds.",
			"rep": 2,
			"rows": [{"id": "out", "label": "Out into the light", "to": ""}],
		},
		"left": {
			"text": "You stand at the rail and watch the rest of them do it correctly, which takes four minutes and teaches you everything you needed before you started.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Come back another day", "to": ""}],
		},
		"pagoda": {
			"staging": {"set": "pagoda", "cast": [{"at": 0.3, "act": "watch"}]},
			"text": "One pillar, one hall, a pond. A thousand years old and seventy years old at once: the last people to leave this country blew it up on the way out, and it was rebuilt from the drawings.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Stand and look at it", "to": ""}],
		},
	},
},

"hanoi:tayho": {
	"title": "Hồ Tây",
	"start": "shore",
	"beats": {
		"shore": {
			"film": [
				{"set": "water", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "A lake big enough to have weather of its own, with a causeway out to a pagoda on an islet."},
				{"set": "stall", "secs": 3.6, "prop": "bowl", "prop_at": 0.74,
					"cast": [{"at": 0.3, "act": "sit"}, {"at": 0.58, "act": "cut"}],
					"say": "Plastic stools eleven centimetres off the ground, and a woman frying something in a pan the size of a bicycle wheel."},
			],
			"text": "The big lake, flat and grey-gold, a causeway out to a pagoda on an islet. On the shore: plastic stools eleven centimetres off the ground, and a woman frying something in a pan the size of a bicycle wheel.",
			"rows": [
				{"id": "sit", "label": "Sit down on one of the stools",
					"sub": "everyone else is folded onto one and eating", "to": "served"},
				{"id": "causeway", "label": "Walk out to the pagoda", "to": "pagoda"},
			],
		},
		"served": {
			"text": "A plate arrives without you ordering: whole shrimp in fried sweet potato batter. Beside it a mound of leaves, a bowl of pale liquid, and a pair of scissors. Three people are watching you, kindly.",
			"cost": 50000,
			"rows": [
				{"id": "eat", "label": "Eat the fried thing, leave the leaves",
					"sub": "the leaves are garnish. They are obviously garnish", "to": "wrong"},
				{"id": "watch", "label": "Wait and see what the next table does",
					"sub": "yours goes cold, and that is a price worth paying", "to": "learned"},
			],
		},
		"learned": {
			"text": "The next table tears a leaf, lays a fried piece in it, adds a smaller leaf, folds the parcel and dips it. The leaves are not garnish. The leaves are the plate.",
			"rep": 1,
			"learn": [["vietnamese", "rau"], ["vietnamese", "cuon"]],
			"rows": [
				{"id": "wrap", "label": "Build one the way they did",
					"sub": "leaf, shrimp, leaf, fold, dip", "needs": "learned",
					"locked": "you do not know what the leaves are for", "to": "right"},
				{"id": "eat", "label": "Eat it plain anyway", "to": "wrong"},
			],
		},
		"right": {
			"text": "It is a completely different food this way. The woman with the pan says something to the woman with the scissors and they both laugh, and it is not at you, and you can tell the difference now.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Finish it", "to": ""}],
		},
		"wrong": {
			"text": "You eat around a pile of herbs for ten minutes. Eventually she comes over, picks up a leaf, builds one in front of you and puts it in your hand without a word.",
			"rep": 1,
			"rows": [
				{"id": "copy", "label": "Do the next one her way", "to": "right"},
				{"id": "ok", "label": "Thank her and go", "to": ""},
			],
		},
		"pagoda": {
			"text": "A bodhi tree grows in the courtyard, cut from another tree, in another country, where the whole thing started. They know exactly which tree. They have the paperwork.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Walk back along the causeway", "to": ""}],
		},
	},
},

"hanoi:dongda": {
	"title": "Văn Miếu",
	"start": "gate",
	"again": "court",
	"beats": {
		"gate": {
			"film": [
				{"set": "gate", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "Five courtyards, one behind the other, each one quieter than the one before it."},
				{"set": "courtyard", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "point"}],
					"say": "In the third courtyard, eighty-two stone tablets standing on the backs of eighty-two stone turtles."},
			],
			"text": "Five courtyards, one behind the other, each quieter than the last. Families in gowns are being photographed. In the third courtyard, eighty-two stone tablets stand on the backs of eighty-two stone turtles.",
			"rows": [
				{"id": "court", "label": "Walk through to the turtles", "to": "court"},
				{"id": "grads", "label": "Watch the graduates",
					"sub": "gowns, parents, a photographer on a stepladder", "to": "grads"},
			],
		},
		"court": {
			"text": "Every tablet is a list of names: everyone who passed the imperial examinations, back to 1442. The turtles' heads are worn smooth and shiny, and a low fence now stops anyone reaching them.",
			"learn": [["vietnamese", "bia"], ["vietnamese", "rua"]],
			"rows": [
				{"id": "read", "label": "Try to read a tablet",
					"sub": "characters in columns, and not the alphabet on the street signs",
					"to": "read"},
				{"id": "fence", "label": "Work out what the fence is for", "to": "fence"},
			],
		},
		"read": {
			"text": "You cannot read it. Neither, you notice, can most of the people here - a grandmother is explaining it to a child off a printed card. The country kept this list six hundred years and then changed alphabet.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Stand with the grandmother a while", "to": ""}],
		},
		"fence": {
			"text": "People rubbed the turtles' heads for luck. Enough people, for enough centuries, that the stone went. The luck is fenced off now to stop it destroying the thing it comes from.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Leave the turtles alone", "to": ""}],
		},
		"grads": {
			"text": "A father moves his daughter half a step left, checks the frame, moves her back. This is the oldest university in the country and the photograph is the point of today.",
			"rep": 1,
			"rows": [{"id": "court", "label": "Go through to the turtles", "to": "court"}],
		},
	},
},

# ── Tokyo ────────────────────────────────────────────────────────────────────

"tokyo:asakusa": {
	"title": "Sensō-ji",
	"start": "gate",
	"again": "inner",
	"beats": {
		"gate": {
			"film": [
				{"set": "gate+stall", "secs": 3.8, "prop": "lantern", "prop_at": 0.5,
					"cast": [{"at": 0.3, "act": "watch"}],
					"say": "A gate with a paper lantern in it the size of a car, and a street of stalls running straight at a temple behind it."},
				{"set": "gate", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "walk"}, {"at": 0.58, "act": "bow"}],
					"say": "People stop at the threshold and bow once, quickly, to nothing I can see. Not all of them. Enough of them."},
				{"set": "street", "secs": 3.6, "prop": "smoke", "prop_at": 0.68,
					"cast": [{"at": 0.34, "act": "watch"}, {"at": 0.62, "act": "reach"}],
					"say": "At the top, a bronze cauldron with incense in it, and people pulling the smoke onto the parts of themselves that hurt."},
			],
			"text": "A gate with a paper lantern the size of a car hanging in it, and beyond that a street of stalls running straight at a temple. Thousands of people, and all of them doing something specific.",
			"rows": [
				{"id": "watch", "label": "Stand at the gate and watch",
					"sub": "people are stopping under the lantern before they go through",
					"to": "watched"},
				{"id": "walk", "label": "Walk straight through", "to": "inner"},
			],
		},
		"watched": {
			"text": "They stop at the threshold and bow once, quickly, to nothing you can see. Not all of them. Enough of them. Then they go through and the bow is over and nobody mentions it.",
			"rep": 1,
			"learn": [["japanese", "kaminarimon"], ["japanese", "omairi"]],
			"rows": [
				{"id": "bow", "label": "Bow at the threshold and go through",
					"sub": "once, quickly, to nothing you can see", "needs": "watched",
					"locked": "you have not noticed anyone doing anything at the gate",
					"to": "bowed"},
				{"id": "walk", "label": "Just go through", "to": "inner"},
			],
		},
		"bowed": {
			"text": "Nobody sees you do it, which turns out to be the point - it was never for an audience. A woman behind you does the same thing and neither of you acknowledges the other.",
			"rep": 2,
			"rows": [{"id": "on", "label": "On up the street of stalls", "to": "inner"}],
		},
		"inner": {
			"text": "At the top: a bronze cauldron with incense burning in it, and people cupping the smoke and pulling it onto themselves. Beside the hall, a wall of small wooden drawers and a rack of tied paper.",
			"rows": [
				{"id": "smoke", "label": "Stand in the smoke",
					"sub": "an old man is pulling it onto his knee, then his head", "to": "smoke"},
				{"id": "draw", "label": "Draw a fortune", "cost": 100,
					"sub": "shake the tin, a numbered stick falls out, the number opens a drawer",
					"to": "shake"},
				{"id": "go", "label": "Leave them to it", "to": ""},
			],
		},
		"smoke": {
			"text": "You copy him: hands, smoke, knee, head. He watches you do it, adjusts nothing, and goes back to his own. No words passed in either direction and something was clearly agreed.",
			"rep": 2,
			"rows": [
				{"id": "draw", "label": "Try the drawers", "cost": 100, "to": "shake"},
				{"id": "go", "label": "That was enough", "to": ""},
			],
		},
		"shake": {"toss": ["good", "bad", "bad"]},
		"good": {
			"text": "Number 31. The drawer holds a slip covered in characters, and the one word at the top is large and confident. The woman beside you glances at it and gives you a small approving nod.",
			"rep": 2,
			"item": "omikuji_good",
			"rows": [{"id": "keep", "label": "Fold it and keep it", "to": ""}],
		},
		"bad": {
			"text": "Number 7. Whatever it says, the man who looks over your shoulder makes a face and points at the rack of tied paper. Everyone is tying something there and walking away lighter.",
			"learn": [["japanese", "kyo"], ["japanese", "musubu"]],
			"rows": [
				{"id": "tie", "label": "Tie it to the rack and leave it",
					"sub": "that is what the rack is for", "to": "tied"},
				{"id": "pocket", "label": "Put it in your pocket",
					"sub": "it is yours. You paid for it", "to": "pocket"},
			],
		},
		"tied": {
			"text": "The system has a place to put the bad answer. You fold it round the wire with everyone else's bad answers and the whole thing is over, and that is apparently allowed.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Walk out through the gate", "to": ""}],
		},
		"pocket": {
			"text": "You keep it. The man makes the face again. You are now carrying a piece of paper you cannot read that everybody around you has agreed is bad news.",
			"rep": -1,
			"item": "omikuji_bad",
			"rows": [{"id": "ok", "label": "Walk out through the gate", "to": ""}],
		},
	},
},

"tokyo:ueno": {
	"title": "Ameya-Yokochō",
	"start": "lane",
	"beats": {
		"lane": {
			"film": [
				{"set": "market", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "walk"}],
					"say": "A market squeezed under a railway. Every ninety seconds a train goes over the top and the whole roof answers."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "recoil"}, {"at": 0.58, "act": "point"}],
					"say": "A man in an apron is bellowing at the entire street. This has not happened to me once anywhere else in this country."},
			],
			"text": "A market wedged under and along the railway. Every ninety seconds a train goes over the top. A man in an apron is bellowing at the whole street, and this has not happened to you once anywhere else in this country.",
			"rows": [
				{"id": "listen", "label": "Stand and listen to what he is shouting",
					"sub": "it is the same three sounds over and over, with one changing",
					"to": "listened"},
				{"id": "buy", "label": "Point at a tray and hold out money",
					"cost": 500, "to": "full"},
			],
		},
		"listened": {
			"text": "One of the sounds is a number, and the number is going down. Every time the pile gets smaller he drops it again. Nobody is buying yet. Everybody is waiting, and pretending not to.",
			"rep": 1,
			"learn": [["japanese", "yasui"], ["japanese", "sen"]],
			"rows": [
				{"id": "wait", "label": "Wait for it to drop again",
					"sub": "with everybody else, all of you not looking at each other",
					"needs": "listened",
					"locked": "you have not worked out that the number is moving",
					"to": "waited"},
				{"id": "buy", "label": "Buy now before it goes", "cost": 500,
					"to": "full"},
			],
		},
		"waited": {
			"text": "He drops it a third time and eight people move at once, including you. You get the same box for three hundred less than the first number, because the first number was never the number.",
			"cost": 200,
			"rep": 3,
			"item": "ameyoko_box",
			"rows": [{"id": "ok", "label": "Out under the tracks", "to": ""}],
		},
		"full": {
			"text": "He takes the money, hands you the box, and immediately shouts a smaller number at the man behind you. You paid the opening price, which was an opening price.",
			"rep": 1,
			"item": "ameyoko_box",
			"rows": [{"id": "ok", "label": "Out under the tracks", "to": ""}],
		},
	},
},

"tokyo:shinbashi": {
	"title": "Under the tracks",
	"start": "square",
	"beats": {
		"square": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "watch"}],
					"say": "A steam locomotive parked in a square, and behind it a row of doorways under the railway arches."},
				{"set": "street", "secs": 3.8, "prop": "curtain", "prop_at": 0.66,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.58, "act": "walk"}],
					"say": "Some of the doors have a short split cloth hanging over them. Some do not. People are only using the ones that do."},
			],
			"text": "A steam locomotive parked in a square, and behind it a row of doorways under the railway arches. Some have a short split curtain hanging over the door. Some do not.",
			"rows": [
				{"id": "watch", "label": "Watch which doors people use",
					"sub": "there is a pattern and it is not the lights", "to": "watched"},
				{"id": "any", "label": "Try the nearest door", "to": "shut"},
				{"id": "tv", "label": "Watch the television crew",
					"sub": "they are stopping people leaving work and asking them things",
					"to": "tv"},
			],
		},
		"watched": {
			"text": "The curtain is the sign. Hung out means open; taken in means done for the night. It is a cloth, and it is the whole opening-hours system, and it is not written anywhere.",
			"rep": 1,
			"learn": [["japanese", "noren"], ["japanese", "aitemasu"]],
			"rows": [
				{"id": "in", "label": "Go in under a hanging curtain", "cost": 800,
					"needs": "watched",
					"locked": "you do not know which of these places are open", "to": "inside"},
				{"id": "any", "label": "Try a door with no curtain", "to": "shut"},
			],
		},
		"shut": {
			"text": "The door slides and a man looks up from wiping the counter and says something apologetic with his whole body. It is not open. It was never open. You back out into the alley.",
			"rep": -1,
			"rows": [
				{"id": "watch", "label": "Stand back and work out the difference",
					"to": "watched"},
				{"id": "go", "label": "Give up on the arches", "to": ""},
			],
		},
		"inside": {
			"text": "No chairs. No menu you can read. A man beside you already three deep, talking steadily to the wall and to you with equal warmth. The barman is waiting, patiently, for something.",
			"rows": [
				{"id": "point", "label": "Point at what the man beside you has",
					"sub": "the oldest ordering system there is", "to": "same"},
				{"id": "menu", "label": "Try to read the board", "to": "stuck"},
			],
		},
		"same": {
			"text": "It arrives in eight seconds. The man beside you is delighted, taps your glass with his, and resumes his monologue. You understand none of it and it stops mattering somewhere in the second minute.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay until he leaves", "to": ""}],
		},
		"stuck": {
			"text": "You read the board for long enough that the barman quietly puts a glass of what everyone else is having in front of you and moves down the counter. He was never going to let you fail at this.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Drink it", "to": ""}],
		},
		"tv": {
			"text": "The same people who would not meet your eye on the train are saying exactly what they think into a lens at half past seven. The uniform comes off with the office door.",
			"rep": 1,
			"rows": [{"id": "square", "label": "Back to the arches", "to": "square"}],
		},
	},
},

# ── Seoul ────────────────────────────────────────────────────────────────────

"seoul:hongdae": {
	"title": "The playground street",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Somebody sets an amp down on the pavement, and does not announce anything, and does not look up."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.24, "act": "watch"}, {"at": 0.4, "act": "watch"}, {"at": 0.58, "act": "stand"}, {"at": 0.74, "act": "watch"}],
					"say": "In about forty seconds a ring of people has assembled around her at exactly the same distance, as if it were marked on the ground."},
			],
			"text": "A university district where the pavement is the venue. Someone sets an amp down, and in about forty seconds a ring of people has assembled around them at exactly the same distance, as if it were marked.",
			"rows": [
				{"id": "edge", "label": "Stand at the edge and watch the ring form",
					"sub": "nobody is organising it and it is a perfect circle", "to": "edge"},
				{"id": "push", "label": "Walk into the middle for a better view",
					"to": "inside"},
			],
		},
		"edge": {
			"text": "The ring has an inside and an outside and one rule: the inside is hers. Latecomers join the back and lean, and the circle grows outward and never inward.",
			"rep": 1,
			"learn": [["korean", "gil"], ["korean", "geori"]],
			"rows": [
				{"id": "join", "label": "Take a place on the rim",
					"sub": "at the distance everyone else is at", "needs": "edge",
					"locked": "you have not worked out where the edge of this thing is",
					"to": "joined"},
				{"id": "push", "label": "Get closer", "to": "inside"},
			],
		},
		"joined": {
			"text": "You stand where the ring says to stand for four songs. At the end everyone applauds at once and a queue forms itself at the open case, and you are in it before you decide to be.",
			"rep": 2,
			"rows": [
				{"id": "tip", "label": "Put something in the case", "cost": 2000,
					"sub": "at the end, with everyone else, not during", "to": "tipped"},
				{"id": "go", "label": "Move on with the crowd", "to": ""},
			],
		},
		"tipped": {
			"text": "Not while she was singing. At the end, all at once, in a line that formed without anyone starting it. Even the giving has an order here and you are inside it.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Move on", "to": ""}],
		},
		"inside": {
			"text": "You get three steps in before you understand that the middle is not a viewing position, it is the stage. The ring closes behind you and reopens in front of you and puts you back outside it, politely, without anyone touching you.",
			"rep": -2,
			"rows": [
				{"id": "edge", "label": "Go and stand where they are standing",
					"to": "edge"},
				{"id": "go", "label": "Walk off", "to": ""},
			],
		},
	},
},

"seoul:seongsu": {
	"title": "The shoe streets",
	"start": "brick",
	"beats": {
		"brick": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Red brick and roller shutters, and two doors on the same wall."},
				{"set": "interior", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "cut"}],
					"say": "One is a coffee shop with the crane rail left in the ceiling. One is a workshop with lasts hung up in rows and a radio going."},
			],
			"text": "Red brick and roller shutters. Two doors on the same wall: one is a café with a crane rail left in the ceiling, one is a workshop with lasts hung up in rows and a radio going.",
			"rows": [
				{"id": "shop", "label": "Look into the workshop", "to": "shop"},
				{"id": "cafe", "label": "Go into the café", "cost": 7000, "to": "cafe"},
			],
		},
		"shop": {
			"text": "A man in his sixties gluing a sole, in a room that has done this since before the coffee. He looks up, sees you looking, and goes back to it. He is neither pleased nor bothered.",
			"rep": 1,
			"learn": [["korean", "gudu"], ["korean", "gongjang"]],
			"rows": [
				{"id": "watch", "label": "Stay in the doorway and watch him work",
					"sub": "he has not asked you to leave", "to": "watched"},
				{"id": "cafe", "label": "Go next door for the coffee", "cost": 7000,
					"to": "cafe"},
			],
		},
		"watched": {
			"text": "Eleven minutes. He does not perform and you do not interrupt. At the end he holds the shoe up to the light, turns it once, and sets it down, and glances at you to check you saw the good bit.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Nod and go", "to": ""}],
		},
		"cafe": {
			"text": "They kept the concrete, the crane rail and the roughness, and priced the coffee accordingly. Through the wall you can hear the radio and, under it, a hammer.",
			"rep": 1,
			"rows": [
				{"id": "shop", "label": "Go and look at where the hammer is",
					"to": "shop"},
				{"id": "ok", "label": "Sit with it", "to": ""},
			],
		},
	},
},

"seoul:mangwon": {
	"title": "Mangwon Market",
	"start": "lane",
	"beats": {
		"lane": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "A covered lane where the neighbourhood actually shops, and no English anywhere, which here means no tourists rather than no welcome."},
				{"set": "counter/food", "secs": 3.4,
					"cast": [{"at": 0.3, "act": "stand"}, {"at": 0.58, "act": "cut"}],
					"say": "A griddle of savoury pancakes and a woman with scissors, and everything on this street is cut with scissors."},
			],
			"text": "A covered lane where the neighbourhood actually shops. A griddle of savoury pancakes, a woman with scissors, and no English anywhere, which here means no tourists rather than no welcome.",
			"rows": [
				{"id": "point", "label": "Point at one thing and hold up a finger",
					"cost": 3000, "to": "one"},
				{"id": "vague", "label": "Gesture at the whole griddle and shrug",
					"sub": "hand it over to her entirely", "cost": 5000, "to": "hers"},
			],
		},
		"one": {
			"text": "She cuts it with scissors - everything here is cut with scissors - and hands it over in paper. It is exactly what you asked for and slightly less than you wanted.",
			"rep": 1,
			"rows": [
				{"id": "again", "label": "Try again and let her choose",
					"cost": 5000, "to": "hers"},
				{"id": "ok", "label": "Eat it walking", "to": ""},
			],
		},
		"hers": {
			"text": "She looks at you for two seconds, decides something, and builds a plate that is not on any sign. It is more than you pointed at and she charges you less than the board says.",
			"rep": 3,
			"learn": [["korean", "ajumma"], ["korean", "jeon"]],
			"rows": [{"id": "ok", "label": "Eat it at the counter", "to": ""}],
		},
	},
},

# ── Mumbai ───────────────────────────────────────────────────────────────────

"mumbai:colaba": {
	"title": "The Causeway",
	"start": "stall",
	"beats": {
		"stall": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Hawkers down one side of the road, and a stone arch standing on the water at the end of it."},
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.3, "act": "stand"}, {"at": 0.56, "act": "offer"}],
					"say": "A man holds up something I had not been looking at and says a number. Eight hundred."},
			],
			"text": "Hawkers down one side of the road, a stone arch on the water at the end of it. A man holds up something you had not been looking at and says a number: eight hundred.",
			"rows": [
				{"id": "pay", "label": "Pay the eight hundred", "cost": 800,
					"to": "paid"},
				{"id": "half", "label": "Say four hundred", "to": "four"},
				{"id": "low", "label": "Say two hundred", "to": "two"},
				{"id": "quiet", "label": "Say nothing at all", "to": "quiet"},
			],
		},
		"paid": {
			"text": "He takes it instantly, which tells you everything. The man four stalls down is holding up the same object and starting at four hundred.",
			"rep": -1,
			"item": "causeway_thing",
			"rows": [{"id": "ok", "label": "Keep walking", "to": ""}],
		},
		"four": {
			"text": "He laughs, puts a hand on his chest as though wounded, and says six hundred. This is not offence. This is the second line of a script you are now inside.",
			"rep": 1,
			"learn": [["hindi", "kitna"], ["hindi", "nahi"]],
			"rows": [
				{"id": "five", "label": "Five hundred, and mean it", "cost": 500,
					"to": "deal"},
				{"id": "walk", "label": "Shrug and start walking", "to": "walked"},
			],
		},
		"two": {
			"text": "He stops smiling for exactly one second, then restarts at five fifty. Going in that low was rude and also effective, and both of those are now true at once.",
			"rows": [
				{"id": "three", "label": "Three fifty", "cost": 350, "to": "deal"},
				{"id": "walk", "label": "Shrug and start walking", "to": "walked"},
			],
		},
		"quiet": {
			"text": "You say nothing. He waits. You keep saying nothing. He says six hundred, to the silence, and then five hundred, to the same silence.",
			"rep": 2,
			"rows": [
				{"id": "still", "label": "Keep saying nothing", "to": "silence"},
				{"id": "take", "label": "Take it at five hundred", "cost": 500,
					"to": "deal"},
			],
		},
		"silence": {
			"text": "Four hundred. He is arguing with somebody who is not participating and losing. You had not spoken once. Silence turned out to be a position in the negotiation.",
			"cost": 400,
			"rep": 3,
			"item": "causeway_thing",
			"rows": [{"id": "ok", "label": "Take it and go", "to": ""}],
		},
		"walked": {
			"text": "Four steps. That is all it takes. He calls a number at your back and it is lower than anything either of you has said out loud so far.",
			"rows": [
				{"id": "back", "label": "Turn round and take it", "cost": 300,
					"to": "deal"},
				{"id": "gone", "label": "Keep going", "to": "gone"},
			],
		},
		"deal": {
			"text": "Done. He wraps it in newspaper, shakes your hand, and is already talking to somebody else before you have put your money away. Nothing about any of that was personal.",
			"rep": 2,
			"item": "causeway_thing",
			"rows": [{"id": "arch", "label": "Walk down to the arch", "to": "arch"}],
		},
		"gone": {
			"text": "You keep walking and he lets you. Somewhere behind you the number is still going down, for somebody else, and that was always how this was going to end.",
			"rep": 1,
			"rows": [{"id": "arch", "label": "Walk down to the arch", "to": "arch"}],
		},
		"arch": {
			"text": "An arch built on the water to say welcome to a king who came once. The most famous thing that ever happened at it was the last of them leaving through it, in the other direction.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Look across at the towers", "to": ""}],
		},
	},
},

"mumbai:bandra": {
	"title": "Mount Mary",
	"start": "steps",
	"beats": {
		"steps": {
			"film": [
				{"set": "steps+stall", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Steps up to a basilica, and stalls on both sides of them the whole way up."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.6, "act": "hand_over"}],
					"say": "The candles are shaped. A leg. An arm. A hand. A small house. A torso."},
			],
			"text": "Steps up to a basilica, and stalls on both sides selling candles - but the candles are shaped: a leg, an arm, a hand, a small house, a torso.",
			"rows": [
				{"id": "ask", "label": "Work out what the shapes are for",
					"sub": "watch what people pick and how they pick it", "to": "worked"},
				{"id": "buy", "label": "Buy a plain one", "cost": 50, "to": "plain"},
				{"id": "walk", "label": "Go down to the sea wall instead",
					"to": "wall"},
			],
		},
		"worked": {
			"text": "You buy the part of you that is wrong. A leg for a leg. A house if the problem is the house. The queue is Hindu and Muslim and Catholic and nobody is checking, because the wax does not.",
			"rep": 2,
			"learn": [["hindi", "mannat"], ["hindi", "diya"]],
			"rows": [
				{"id": "pick", "label": "Buy the one that fits", "cost": 50,
					"needs": "worked", "locked": "they are just candles to you",
					"to": "fitted"},
				{"id": "buy", "label": "Buy a plain one anyway", "cost": 50,
					"to": "plain"},
			],
		},
		"fitted": {
			"text": "You pick one up without having to be told which, and the woman selling them nods once and takes your money and does not explain anything, because there was nothing left to explain.",
			"rep": 3,
			"item": "wax_votive",
			"rows": [{"id": "wall", "label": "Down to the sea wall", "to": "wall"}],
		},
		"plain": {
			"text": "A plain candle, which is a perfectly good candle. The woman looks at it, then at you, and you understand that you have bought the version for people who did not know.",
			"rep": 1,
			"item": "wax_votive",
			"rows": [{"id": "wall", "label": "Down to the sea wall", "to": "wall"}],
		},
		"wall": {
			"text": "The promenade, the ruined fort, the bridge out across the water with its lights on. A hundred people are standing outside one particular gate, patiently, for a man who lives behind it.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Watch the bridge for a while", "to": ""}],
		},
	},
},

"mumbai:byculla": {
	"title": "Bhau Daji Lad",
	"start": "gate",
	"beats": {
		"gate": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "walk"}],
					"say": "A hall of blue and gold cast iron standing in a garden, and it costs almost nothing to go in."},
				{"set": "counter/cases", "secs": 3.8,
					"cast": [{"at": 0.3, "act": "watch"}, {"at": 0.62, "act": "point"}],
					"say": "Cases of small clay figures: every trade in the city, in miniature, made when the city was new so it could look at itself."},
			],
			"text": "A hall of blue and gold cast iron in a garden, and it costs almost nothing to go in. Outside the gate a brick chimney stands on its own in a car park.",
			"rows": [
				{"id": "in", "label": "Pay and go in", "cost": 10, "to": "models"},
				{"id": "chimney", "label": "Go and look at the chimney",
					"to": "chimney"},
			],
		},
		"models": {
			"text": "Cases of small clay figures: every trade in the city, in miniature, modelled when the city was new so it could look at itself. A potter. A dyer. A man carrying ice.",
			"rep": 2,
			"learn": [["hindi", "kaam"], ["hindi", "sheher"]],
			"rows": [
				{"id": "count", "label": "Count how many of these jobs you saw today",
					"sub": "on the way here, on this street, this morning", "to": "count"},
				{"id": "ok", "label": "Walk the cases", "to": ""},
			],
		},
		"count": {
			"text": "Most of them. Not the ice. The rest of them are outside the door, doing it now, a hundred and fifty years after somebody made a small clay model of them for a museum.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Sit in the garden", "to": ""}],
		},
		"chimney": {
			"text": "A quarter of a million people worked in the mills this chimney belonged to. It is kept because it is picturesque, in the car park of the thing that replaced them.",
			"rep": 1,
			"rows": [{"id": "in", "label": "Go into the museum", "cost": 10,
				"to": "models"}],
		},
	},
},

}
