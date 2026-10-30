extends Object

# Streetside encounters: North America and the Pacific islands.
# Played through Streetside.spot() and the beat engine in Services._local().
#
# These were written after the cutscene player existed, so every one of them
# is acted out before it is offered - see the "film" key on the opening beat.

const SPOTS := {

# ── Honolulu ─────────────────────────────────────────────────────────────────

"honolulu:waikiki": {
	"title": "The break at Kūhiō",
	"start": "sand",
	"beats": {
		"sand": {
			"film": [
				{"set": "beach", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A hundred metres of sand with thirty hotel floors standing on it, and past the shore break the water is full of people sitting on boards, waiting."},
				{"set": "beach", "secs": 3.8, "prop": "flag", "prop_at": 0.82,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.56, "act": "carry"}],
					"say": "An older man walks a board down past me. He has done this so many times that he is not looking at the sea, and the sea is the only thing I am looking at."},
				{"set": "beach", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.58, "act": "point"}],
					"say": "He stops. He points at the board, then at me, then at the water, in that order, and then waits."},
			],
			"text": "He is not selling anything. There is no stand, no board rack with a price on it, and no clipboard. He is a man on a beach with a spare board, pointing at the water.",
			"rows": [
				{"id": "go", "label": "Take the board and go out",
					"sub": "you have never done this and he has not asked whether you have",
					"to": "out"},
				{"id": "pay", "label": "Try to pay him first", "cost": 40,
					"to": "paid"},
				{"id": "watch", "label": "Stay on the sand and watch the line-up",
					"to": "watched"},
			],
		},
		"watched": {
			"text": "Nobody paddles for a wave that somebody nearer the peak is already on. Nobody says anything about it either. There is a whole order out there and it is being kept without a word.",
			"rep": 2,
			"learn": [["english", "lineup"], ["english", "kuleana"]],
			"rows": [
				{"id": "go", "label": "Now take the board", "needs": "watched",
					"locked": "you would paddle straight into somebody's wave",
					"to": "out"},
				{"id": "ok", "label": "Sit on the sand", "to": ""},
			],
		},
		"out": {
			"film": [
				{"set": "water", "secs": 3.4,
					"cast": [{"at": 0.42, "act": "swim"}],
					"say": "Further out than it looked. Everything is always further out than it looked."},
				{"set": "water", "secs": 3.6,
					"cast": [{"at": 0.40, "act": "swim"}, {"at": 0.66, "act": "point"}],
					"say": "He is behind me shouting one word over and over. I do not know the word. I know exactly what it means, because he is also pushing."},
			],
			"text": "The board goes, and for four seconds you are being carried by something enormous that has come three thousand kilometres to do this. Then you are in the water and it is over.",
			"rep": 3,
			"rows": [{"id": "back", "label": "Paddle back out", "to": "again"}],
		},
		"again": {
			"text": "He does not take the board back. He waves you out again, and does it four more times, and at no point does anybody mention money.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Stay out until your arms go", "to": ""}],
		},
		"paid": {
			"text": "He looks at the money, then at you, and pushes your hand gently back towards your own pocket. Something has just gone slightly wrong and it is not the money.",
			"rep": -2,
			"rows": [
				{"id": "go", "label": "Put it away and take the board", "to": "out"},
				{"id": "ok", "label": "Leave it", "to": ""},
			],
		},
	},
},

"honolulu:chinatown": {
	"title": "The lei stand",
	"start": "stand",
	"beats": {
		"stand": {
			"film": [
				{"set": "stall", "secs": 3.6, "prop": "bowl", "prop_at": 0.74,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.60, "act": "cut"}],
					"say": "The whole front of the shop is open to the street. A woman is stringing flowers onto a needle the length of my forearm without looking down at it."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.58, "act": "hand_over"},
						{"at": 0.72, "act": "carry"}],
					"say": "A man buys one and does not put it on. He carries it out in both hands like something that is not his yet."},
			],
			"text": "Plumeria, ti leaf, tuberose, orchid, and a refrigerated case behind. Everything here is sold by the strand and nobody in the shop is wearing one.",
			"rows": [
				{"id": "wear", "label": "Buy one and put it on", "cost": 25,
					"to": "wore"},
				{"id": "watch", "label": "Watch what the buyers do with them",
					"to": "watched"},
			],
		},
		"watched": {
			"text": "Not one person puts one on. They buy them and carry them out. A lei is not a thing you wear; it is a thing you are given, and buying one for yourself is buying half of it.",
			"rep": 2,
			"learn": [["english", "lei"], ["english", "aloha"]],
			"rows": [
				{"id": "give", "label": "Buy one to give to somebody", "cost": 25,
					"needs": "watched", "locked": "it is a garland and you have a neck",
					"to": "gave"},
				{"id": "wear", "label": "Buy one and put it on anyway", "cost": 25,
					"to": "wore"},
			],
		},
		"gave": {
			"text": "You do not have anybody to give it to. The woman watches you work that out on your face, takes it back, and puts it in the case, and says she will hold it.",
			"rep": 3,
			"item": "lei",
			"rows": [{"id": "ok", "label": "Say you will come back for it", "to": ""}],
		},
		"wore": {
			"text": "Nobody stops you and nobody minds. You spend the afternoon as the only person in Chinatown wearing flowers, and every local you pass reads the whole story off you at a glance.",
			"rep": -1,
			"item": "lei",
			"rows": [{"id": "ok", "label": "Keep walking", "to": ""}],
		},
	},
},

"honolulu:manoa": {
	"title": "Up the valley",
	"start": "porch",
	"beats": {
		"porch": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "recoil"}],
					"say": "It starts raining the way a tap starts. Nobody around me changes pace. Nobody opens anything over their head."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.62, "act": "stand"}],
					"say": "Four minutes later it stops, exactly as suddenly, and the whole valley is steaming. I am the only wet thing that made a decision about it."},
				{"set": "interior", "secs": 3.4, "prop": "door", "prop_at": 0.66,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.58, "act": "bow"}],
					"say": "At the door of the house, a row of shoes. Not tidy - just off, and left, and everybody's."},
			],
			"text": "A timber house on posts with a tin roof, and somebody in the doorway waving you up out of the wet. At the top of the steps: eleven pairs of shoes and no rack.",
			"rows": [
				{"id": "off", "label": "Take your shoes off", "to": "off"},
				{"id": "in", "label": "Go in", "to": "in"},
			],
		},
		"off": {
			"text": "Nobody says anything, which is how you know. Inside, the floor is bare wood and everybody's feet are on it and the whole house is quieter for it.",
			"rep": 3,
			"learn": [["english", "slippah"], ["english", "hale"]],
			"rows": [{"id": "ok", "label": "Sit down out of the rain", "to": ""}],
		},
		"in": {
			"text": "Four steps in, everybody looks at your feet at once. Nobody says anything then either. Somebody's grandmother gets up and moves a mat, and you understand and it is far too late.",
			"rep": -2,
			"rows": [
				{"id": "back", "label": "Go back out and take them off", "to": "off"},
				{"id": "ok", "label": "Sit down and hope", "to": ""},
			],
		},
	},
},

"honolulu:kakaako": {
	"title": "The wall",
	"start": "wall",
	"beats": {
		"wall": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "A warehouse gable four storeys high, painted end to end, and the paint is not dry."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "reach"}],
					"say": "She is up a ladder that somebody has to hold, and there is nobody holding it."},
			],
			"text": "A woman on a ladder, a wall the size of a ship, and a tray of cans on the ground with the lids off. The ladder is standing on gravel and moving very slightly.",
			"rows": [
				{"id": "hold", "label": "Hold the ladder", "sub": "without asking",
					"to": "held"},
				{"id": "ask", "label": "Ask if she wants help", "to": "asked"},
				{"id": "look", "label": "Look at the wall", "to": "looked"},
			],
		},
		"held": {
			"text": "She does not look down and does not thank you and does not stop. Forty minutes later she comes down, looks at you properly for the first time, and hands you a can.",
			"rep": 3,
			"item": "spray_can",
			"rows": [{"id": "ok", "label": "Put a mark on the bottom corner", "to": ""}],
		},
		"asked": {
			"text": "She says no, because saying yes to that question means owing you something. Then she carries on and the ladder carries on moving and you stand there having done it correctly and uselessly.",
			"rep": 1,
			"rows": [
				{"id": "hold", "label": "Hold it anyway", "to": "held"},
				{"id": "ok", "label": "Leave her to it", "to": ""},
			],
		},
		"looked": {
			"text": "The whole district is like this - one festival a year and the walls change. Underneath the paint the buildings are still warehouses and half of them are still working warehouses.",
			"rep": 1,
			"rows": [{"id": "wall", "label": "Go back to the ladder", "to": "wall"}],
		},
	},
},

"honolulu:northshore": {
	"title": "Waimea in winter",
	"start": "road",
	"beats": {
		"road": {
			"film": [
				{"set": "beach", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.52, "act": "watch"},
						{"at": 0.68, "act": "watch"}],
					"say": "Two hundred people standing on a road looking at water, and not one of them is talking."},
				{"set": "water", "secs": 4.0,
					"cast": [{"at": 0.36, "act": "recoil"}],
					"say": "Something comes in that is taller than the trees behind me. The ground moves. Actually moves - I feel it through the road."},
			],
			"text": "The whole shoulder of the highway is parked cars. Everybody is out of them and up on the bank, watching a bay where nobody is swimming and eight people are.",
			"rows": [
				{"id": "watch", "label": "Stand with them and watch",
					"to": "watched"},
				{"id": "down", "label": "Go down onto the sand", "to": "sand"},
				{"id": "ice", "label": "Get shave ice from the truck", "cost": 8,
					"to": "ice"},
			],
		},
		"watched": {
			"text": "Nobody explains it to you and nobody has to. Twice an hour the horizon stands up and eight people who have spent their lives on this go over the edge of it on purpose.",
			"rep": 3,
			"rows": [
				{"id": "ice", "label": "Get shave ice", "cost": 8, "to": "ice"},
				{"id": "ok", "label": "Stay until it gets dark", "to": ""},
			],
		},
		"sand": {
			"text": "You get eleven steps onto the sand before three separate people call you back, all of them calm, none of them surprised. The water comes up to where you were standing about forty seconds later.",
			"rep": -1,
			"learn": [["english", "shorebreak"]],
			"rows": [{"id": "watch", "label": "Go back up onto the bank",
				"to": "watched"}],
		},
		"ice": {
			"text": "Ice shaved to powder, syrup, and ice cream at the bottom that you were not told about and find with the spoon. It is the best thing you have eaten on this planet and it costs less than a bus fare.",
			"rep": 2,
			"item": "shave_ice",
			"rows": [{"id": "ok", "label": "Eat it watching the bay", "to": ""}],
		},
	},
},

# ── New York ─────────────────────────────────────────────────────────────────

"newyork:midtown": {
	"title": "Asking",
	"start": "corner",
	"beats": {
		"corner": {
			"film": [
				{"set": "tower", "secs": 3.8,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "I look up and keep looking up and it does not finish. The building goes past where the sky should start."},
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "stand"}, {"at": 0.56, "act": "walk"},
						{"at": 0.74, "act": "walk"}],
					"say": "Nobody else looks up. Not one of them. The looking up is how they know."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.36, "act": "point"}, {"at": 0.58, "act": "stand"}],
					"say": "I stop somebody to ask the way, and get four words back before I have finished the question."},
			],
			"text": "He answered before you were done. Not rudely - he heard enough, and the rest of your sentence was costing you both time. Now he is waiting to see whether you need more.",
			"rows": [
				{"id": "go", "label": "Take the four words and go",
					"sub": "he has already told you; the rest is manners you cannot afford",
					"to": "went"},
				{"id": "finish", "label": "Finish the question politely",
					"to": "finished"},
				{"id": "thanks", "label": "Thank him at length", "to": "thanked"},
			],
		},
		"went": {
			"text": "The four words were right. You are there in six minutes. The whole exchange took under four seconds and both of you got exactly what you needed out of it.",
			"rep": 3,
			"learn": [["english", "block"], ["english", "avenue"]],
			"rows": [{"id": "ok", "label": "Keep moving", "to": ""}],
		},
		"finished": {
			"text": "He waits for the whole thing, patiently, having already answered it, and then says the same four words again. You have both spent eleven seconds on a four-second problem.",
			"rep": 1,
			"rows": [
				{"id": "ok", "label": "Go", "to": ""},
				{"id": "again", "label": "Try somebody else, faster", "to": "went"},
			],
		},
		"thanked": {
			"text": "Three sentences in, he is already walking. Not offended - finished. Gratitude here is a nod, and the long version reads as somebody who has not understood that the transaction is over.",
			"rep": -1,
			"rows": [{"id": "ok", "label": "Go", "to": ""}],
		},
	},
},

"newyork:lowereast": {
	"title": "The bodega",
	"start": "door",
	"beats": {
		"door": {
			"film": [
				{"set": "counter/food", "secs": 3.4, "prop": "board", "prop_at": 0.24,
					"cast": [{"at": 0.36, "act": "watch"}, {"at": 0.66, "act": "cut"}],
					"say": "A shop the width of a corridor, open all night, with a griddle at the back and a cat asleep on the newspapers."},
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "watch"}, {"at": 0.56, "act": "stand"},
						{"at": 0.70, "act": "cut"}],
					"say": "The man in front of me says five syllables. The griddle starts before he has finished saying them."},
			],
			"text": "No menu you can see. The man behind the griddle is looking at you and the queue behind you is four deep and the whole system runs on people already knowing what they want.",
			"rows": [
				{"id": "copy", "label": "Say what the man in front said",
					"sub": "you caught most of it", "cost": 6, "to": "copied"},
				{"id": "read", "label": "Look for something to read", "to": "stalled"},
				{"id": "point", "label": "Point at the griddle", "cost": 6,
					"to": "pointed"},
			],
		},
		"copied": {
			"text": "It arrives in ninety seconds wrapped in foil and paper, and it is enormous, and it costs less than a coffee. You did not choose any part of it and it is exactly right.",
			"rep": 3,
			"item": "bec",
			"learn": [["english", "bodega"], ["english", "regular"]],
			"rows": [{"id": "ok", "label": "Eat it standing outside", "to": ""}],
		},
		"stalled": {
			"text": "There is nothing to read. There has never been anything to read. The board above the griddle has been painted over twice and the prices on it are from a different decade.",
			"rep": -1,
			"rows": [
				{"id": "copy", "label": "Say what the last man said", "cost": 6,
					"to": "copied"},
				{"id": "point", "label": "Point", "cost": 6, "to": "pointed"},
			],
		},
		"pointed": {
			"text": "He builds you something. It is good. It is also visibly the thing you get when you could not say it, and the man behind you says his five syllables while you are still counting out coins.",
			"rep": 1,
			"item": "bec",
			"rows": [{"id": "ok", "label": "Take it outside", "to": ""}],
		},
	},
},

"newyork:harlem": {
	"title": "The stoop",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "steps", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.58, "act": "sit"},
						{"at": 0.70, "act": "sit"}],
					"say": "Every house on this street has a full flight of steps up to a door on the first floor, and most of the steps have somebody on them."},
				{"set": "steps", "secs": 3.8,
					"cast": [{"at": 0.32, "act": "walk"}, {"at": 0.60, "act": "sit"}],
					"say": "It is not a queue and it is not a party. They are sitting on their own front steps looking at the street, and the street is looking back, and this appears to be the whole activity."},
			],
			"text": "Brownstone, both sides, all the way down. Somebody on the steps two houses along lifts his chin at you as you pass, which is either a greeting or a question and you cannot tell which.",
			"rows": [
				{"id": "back", "label": "Lift your chin back", "to": "nodded"},
				{"id": "sit", "label": "Sit down on an empty stoop", "to": "sat"},
				{"id": "on", "label": "Keep walking and look ahead", "to": "past"},
			],
		},
		"nodded": {
			"text": "That was the whole thing. It cost nothing, it committed you to nothing, and three doors down somebody else does it and you get it right the second time without thinking.",
			"rep": 2,
			"learn": [["english", "stoop"]],
			"rows": [
				{"id": "sit", "label": "Sit down on an empty one", "to": "sat"},
				{"id": "ok", "label": "Walk on", "to": ""},
			],
		},
		"sat": {
			"text": "It is somebody's front steps. The somebody comes out about four minutes later, looks at you, and sits down two steps up, and says something about the weather that you get maybe half of.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Stay on the steps", "to": ""}],
		},
		"past": {
			"text": "Nothing happens. Nothing was going to happen. You have walked the length of a street where the entire front room is outdoors and stayed indoors the whole way down it.",
			"rep": -1,
			"rows": [{"id": "back", "label": "Turn round and try again",
				"to": "nodded"}],
		},
	},
},

"newyork:williamsburg": {
	"title": "The roof",
	"start": "yard",
	"beats": {
		"yard": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.34, "act": "point"}],
					"say": "Every roof on this street has a wooden barrel on legs standing on it. Not one or two. Every roof."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.60, "act": "carry"}],
					"say": "A man goes up a ladder on the outside of a building carrying staves, in the ordinary course of a Tuesday."},
			],
			"text": "Fifteen thousand wooden water tanks over this city and they are still built by hand by about three families. The one above you is leaking a thin steady thread onto the fire escape.",
			"rows": [
				{"id": "why", "label": "Work out why they are wooden",
					"to": "why"},
				{"id": "up", "label": "Go up and look", "to": "up"},
			],
		},
		"why": {
			"text": "Steel sweats in August and freezes solid in February. Wood does neither, and swells tight when you fill it. The oldest technology on the skyline is on top of everything newer than it.",
			"rep": 2,
			"learn": [["english", "tank"]],
			"rows": [
				{"id": "up", "label": "Go up and look", "to": "up"},
				{"id": "ok", "label": "Walk under it", "to": ""},
			],
		},
		"up": {
			"text": "From the roof: the bridge, the river, and the whole of the other island standing up out of the water on the far side of it, lit from the inside, at a scale that does not resolve into buildings.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Sit on the parapet", "to": ""}],
		},
	},
},

"newyork:jacksonheights": {
	"title": "Roosevelt Avenue",
	"start": "under",
	"beats": {
		"under": {
			"film": [
				{"set": "platform", "secs": 3.4,
					"cast": [{"at": 0.36, "act": "recoil"}],
					"say": "The train goes over the top of the street and everything under it stops being audible for eleven seconds."},
				{"set": "market", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.54, "act": "offer"},
						{"at": 0.72, "act": "stand"}],
					"say": "Under the steel: four shops in a row, and I count six alphabets before the corner. Not six languages. Six alphabets."},
			],
			"text": "A cart, a griddle, a queue, and the woman running it is taking orders in three languages without pausing between them, switching on whoever is in front of her.",
			"rows": [
				{"id": "listen", "label": "Work out how she is choosing",
					"to": "listened"},
				{"id": "order", "label": "Order in English", "cost": 7,
					"to": "english"},
			],
		},
		"listened": {
			"text": "She is not choosing. She starts in whatever the last person used and switches the instant she is wrong, without apology and without commentary, about once every ninety seconds all day.",
			"rep": 2,
			"learn": [["english", "roosevelt"], ["english", "elevated"]],
			"rows": [
				{"id": "wrong", "label": "Let her guess wrong on purpose",
					"sub": "and see what happens next", "needs": "listened",
					"locked": "you have not noticed her doing it", "cost": 7,
					"to": "guessed"},
				{"id": "order", "label": "Order in English", "cost": 7,
					"to": "english"},
			],
		},
		"guessed": {
			"text": "She opens in something you have never heard, reads your face in about a third of a second, switches, and hands you food. She did not find it funny and she did not find it annoying. It happens all day.",
			"rep": 3,
			"item": "arepa",
			"rows": [{"id": "ok", "label": "Eat it under the tracks", "to": ""}],
		},
		"english": {
			"text": "She answers in English, correctly, and it is the least interesting version of this street available. Behind you two people are doing the whole thing in something else and enjoying it more.",
			"rep": 1,
			"item": "arepa",
			"rows": [{"id": "ok", "label": "Eat it under the tracks", "to": ""}],
		},
	},
},

# ── Toronto ──────────────────────────────────────────────────────────────────

"toronto:downtown": {
	"title": "The streetcar",
	"start": "stop",
	"beats": {
		"stop": {
			"film": [
				{"set": "tower", "secs": 3.6,
					"cast": [{"at": 0.42, "act": "watch"}],
					"say": "Concrete, going up, and continuing to go up after I have run out of neck."},
				{"set": "station", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "stand"}, {"at": 0.56, "act": "stand"},
						{"at": 0.70, "act": "stand"}],
					"say": "The stop is a painted rectangle in the middle of the road. You stand in the traffic and the traffic is expected to stop, and it does."},
				{"set": "interior", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "walk"}, {"at": 0.58, "act": "sit"},
						{"at": 0.72, "act": "sit"}],
					"say": "Everyone getting off at the back says something to the driver at the front, who cannot possibly hear it, and does it anyway."},
			],
			"text": "It comes down the middle of the road in the traffic, the doors open onto the lane, and everybody steps out into it as if the cars were a formality.",
			"rows": [
				{"id": "ride", "label": "Get on", "cost": 4, "to": "on"},
				{"id": "watch", "label": "Watch the doors first", "to": "watched"},
			],
		},
		"watched": {
			"text": "On at the front, past the driver. Off at the back. And every single person going out of the back door says thank you down the length of the car to a man who is not listening and never turns round.",
			"rep": 2,
			"learn": [["english", "ttc"], ["english", "sorry"]],
			"rows": [
				{"id": "ride", "label": "Get on, and do it their way", "cost": 4,
					"needs": "watched",
					"locked": "you will get off silently like a normal person",
					"to": "thanked"},
				{"id": "ride2", "label": "Get on", "cost": 4, "to": "on"},
			],
		},
		"thanked": {
			"text": "You say it into the back of a stranger's head from twelve metres away and he does not react and nobody expected him to. It is not communication. It is a thing this city does to itself.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Step down into the road", "to": ""}],
		},
		"on": {
			"text": "You get off in silence and two people behind you do not, and the difference registers on exactly nobody. It cost nothing. It just was not the thing.",
			"rep": 1,
			"rows": [{"id": "ok", "label": "Step down into the road", "to": ""}],
		},
	},
},

"toronto:kensington": {
	"title": "Kensington Market",
	"start": "street",
	"beats": {
		"street": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.62, "act": "carry"}],
					"say": "Houses. Actual houses, with gables and porches, and the front room of each one is a shop, and the garden is where the produce is."},
				{"set": "market", "secs": 3.8, "prop": "coin", "prop_at": 0.72,
					"cast": [{"at": 0.32, "act": "reach"}, {"at": 0.60, "act": "watch"}],
					"say": "Nobody is standing at the tables. You pick things up yourself, and somewhere inside the house there is a person who will take money when you are finished."},
			],
			"text": "Crates on the pavement, no attendant, no barrier, and the shop is somebody's front room. Two doors down, the same arrangement in a different language.",
			"rows": [
				{"id": "take", "label": "Fill a bag and go in to pay", "cost": 9,
					"to": "paid"},
				{"id": "wait", "label": "Wait to be served", "to": "waited"},
			],
		},
		"paid": {
			"text": "She weighs it, tells you a number, and asks where you are from - and it is a friendly question here, asked of everybody, and answering it costs you nothing at all.",
			"rep": 3,
			"item": "market_bag",
			"learn": [["english", "loonie"]],
			"rows": [{"id": "ok", "label": "Take the bag", "to": ""}],
		},
		"waited": {
			"text": "Eleven minutes beside a crate of plantain. Two people come out, serve themselves, go in, pay and leave, around you, and every one of them says sorry on the way past.",
			"rep": -1,
			"rows": [{"id": "take", "label": "Help yourself like everybody else",
				"cost": 9, "to": "paid"}],
		},
	},
},

"toronto:gerrard": {
	"title": "The India Bazaar",
	"start": "window",
	"beats": {
		"window": {
			"film": [
				{"set": "counter", "secs": 3.6, "prop": "board", "prop_at": 0.22,
					"cast": [{"at": 0.34, "act": "watch"}, {"at": 0.62, "act": "reach"}],
					"say": "The window is the whole shop. Every colour they have is in it, hung so it hangs, and there is no way in that is not past all of it."},
				{"set": "counter", "secs": 4.0,
					"cast": [{"at": 0.32, "act": "watch"}, {"at": 0.58, "act": "hand_over"},
						{"at": 0.72, "act": "take"}],
					"say": "A man unrolls six metres of cloth onto a counter in one movement, for a woman who has not said she is buying anything."},
			],
			"text": "He has taken down four and is opening a fifth. Nobody has agreed to anything. The unrolling is not a step towards the sale; the unrolling appears to be the shop.",
			"rows": [
				{"id": "stay", "label": "Let him keep unrolling",
					"sub": "you have no use for six metres of anything", "to": "stayed"},
				{"id": "stop", "label": "Stop him and say you are only looking",
					"to": "stopped"},
				{"id": "buy", "label": "Buy the fourth one", "cost": 60, "to": "bought"},
			],
		},
		"stayed": {
			"text": "Nine of them. Then tea, from somewhere, that nobody offered and nobody asked for. Then his brother, and an argument about which was best, conducted mostly for your benefit.",
			"rep": 3,
			"learn": [["english", "bazaar"]],
			"rows": [
				{"id": "buy", "label": "Buy the one they agreed on", "cost": 60,
					"to": "bought"},
				{"id": "ok", "label": "Thank them and go", "to": ""},
			],
		},
		"stopped": {
			"text": "He stops instantly, folds them, and is entirely pleasant about it. The shop goes quiet. You have declined something that was not an offer, and there is nothing left to do here.",
			"rep": -1,
			"rows": [{"id": "ok", "label": "Go", "to": ""}],
		},
		"bought": {
			"text": "He wraps it, then puts a second smaller thing in the bag that you did not buy and are not being charged for, and shuts the bag before you can look at it.",
			"rep": 2,
			"item": "cloth",
			"rows": [{"id": "ok", "label": "Take it", "to": ""}],
		},
	},
},

"toronto:distillery": {
	"title": "The cobbles",
	"start": "lane",
	"beats": {
		"lane": {
			"film": [
				{"set": "street", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "watch"}],
					"say": "Red brick on all four sides, cast iron, and a road surface that has not had a car on it since before I landed."},
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.34, "act": "walk"}, {"at": 0.62, "act": "stand"}],
					"say": "Forty buildings kept whole because a whisky company went under and for a century nobody could afford to knock them down."},
			],
			"text": "The largest group of Victorian industrial buildings left in North America, saved by a bankruptcy. A man at a trestle is selling something hot out of a copper pot.",
			"rows": [
				{"id": "pot", "label": "See what is in the pot", "cost": 7,
					"to": "pot"},
				{"id": "walk", "label": "Walk the lane end to end", "to": "walked"},
			],
		},
		"walked": {
			"text": "Every doorway has a date over it and none of them is later than 1895. The brick is soft, and the corners are worn round where a century of people took them at the same angle.",
			"rep": 2,
			"rows": [
				{"id": "pot", "label": "Go back to the pot", "cost": 7, "to": "pot"},
				{"id": "ok", "label": "Stand in the middle of the road", "to": ""},
			],
		},
		"pot": {
			"text": "Hot cider with something in it, in a paper cup, in weather that would be an emergency almost anywhere else. He tells you the temperature as though it were good news.",
			"rep": 2,
			"item": "cider",
			"rows": [{"id": "ok", "label": "Drink it walking", "to": ""}],
		},
	},
},

"toronto:scarborough": {
	"title": "The Bluffs",
	"start": "top",
	"beats": {
		"top": {
			"film": [
				{"set": "park", "secs": 3.4,
					"cast": [{"at": 0.32, "act": "walk"}],
					"say": "Forty minutes on a train and then a bus, past strip malls in six alphabets, and then the road simply stops."},
				{"set": "water", "secs": 4.0,
					"cast": [{"at": 0.36, "act": "recoil"}],
					"say": "Ninety metres straight down, and then water to the horizon with no far side to it. I had been told this was a lake."},
			],
			"text": "A cliff of pale banded sediment dropping into fresh water that runs to the horizon. There is a fence, and it has been walked round so often that there is a path on the wrong side of it.",
			"rows": [
				{"id": "edge", "label": "Go round the fence", "to": "edge"},
				{"id": "read", "label": "Read the bands in the cliff", "to": "read"},
				{"id": "down", "label": "Take the path down to the water",
					"to": "down"},
			],
		},
		"read": {
			"text": "Twelve layers, and each one is a different ice age. The whole cliff is a record of this place being scraped flat and buried and scraped flat again, and it is going into the lake at a metre a year.",
			"rep": 3,
			"learn": [["english", "bluffs"]],
			"rows": [{"id": "down", "label": "Go down to the water", "to": "down"}],
		},
		"edge": {
			"text": "The ground at the edge is not ground. It is the top of the next collapse, and there is a crack behind you where it has already decided. You come back over the fence carefully.",
			"rep": -2,
			"rows": [{"id": "read", "label": "Look at it from a sensible distance",
				"to": "read"}],
		},
		"down": {
			"text": "At the bottom the cliff is above you and the city is not visible in any direction, and there are three million people about twenty minutes behind it.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Sit on the stones", "to": ""}],
		},
	},
},

}
