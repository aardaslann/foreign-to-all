extends Object

# Streetside encounters: the second district of Moscow, Rome, Tbilisi and
# Zurich. Split from the older tables by size alone.
#
# The stolovaya really is priced by what is on the tray; the fifth quarter
# really is why Testaccio eats what it eats; the halls in Sololaki really are
# unlocked; and Zurich really does run over twelve hundred public fountains,
# all of them drinkable unless a sign says otherwise.

const SPOTS := {

# ── Moscow ───────────────────────────────────────────────────────────────────

"moscow:kitaygorod": {
	"title": "Stolovaya",
	"start": "tray",
	"beats": {
		"tray": {
			"film": [
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A rail, a stack of trays, and forty metres of glass with everything already cooked behind it. Nobody is being asked what they want."},
				{"set": "counter/food", "secs": 3.8, "prop": "bowl", "prop_at": 0.58,
					"cast": [{"at": 0.28, "act": "queue"}, {"at": 0.62, "act": "offer"}],
					"say": "You slide the tray along and point, and a plate lands on it, and you keep sliding. There is no moment where anybody needs a sentence."},
			],
			"text": "A rail, a tray, and forty metres of glass with everything behind it already cooked. You point and slide. It is the first building on this planet designed by somebody who had thought about people who cannot ask.",
			"rows": [
				{"id": "point", "label": "Take a tray and point", "to": "pointed"},
				{"id": "watch", "label": "Watch how it is added up", "to": "till"},
			],
		},
		"pointed": {
			"film": [
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "point"}, {"at": 0.66, "act": "hand_over"}],
					"say": "Four plates on a tray chosen entirely by finger. Two of them are not what I thought they were and one of them is beetroot."},
			],
			"text": "Four plates, all of them chosen by pointing, two of them not at all what I thought. The system did not care that I could not read it, which is the first time that has been true since I landed.",
			"rep": 3,
			"learn": [["russian", "stolovaya"], ["russian", "eto"]],
			"rows": [
				{"id": "till", "label": "Get to the end of the rail", "to": "till"},
			],
		},
		"till": {
			"film": [
				{"set": "counter/food", "secs": 3.6, "prop": "coin", "prop_at": 0.58,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "count"}],
					"say": "She looks at the tray, not at me, and says a number. The price is a property of what is on the tray and has nothing to do with anything I did."},
			],
			"text": "She looks at the tray rather than at me and says a number. The bill is a fact about the tray. Nobody has asked me a question in this entire building and I have eaten.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Pay and find a table", "cost": 7,
				"to": ""}],
		},
	},
},

"moscow:basmanny": {
	"title": "The remont booth",
	"start": "booth",
	"beats": {
		"booth": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A metal box two metres square on the pavement with a man inside it and a hole in the front, and he is doing four unrelated trades out of it."},
				{"set": "shop/workshop", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "cut"}],
					"say": "Shoes, keys, watch batteries, and a machine for cutting letters into metal. All of it in a space where he cannot fully stand up."},
			],
			"text": "A steel booth on the pavement, two metres square, with one man in it doing shoe repair, key cutting, watch batteries and engraving out of a space he cannot stand up straight in.",
			"rows": [
				{"id": "shoe", "label": "Hand him a shoe", "cost": 4, "to": "shoe"},
				{"id": "watch", "label": "Watch him work", "to": "watched"},
			],
		},
		"watched": {
			"text": "Nothing in this booth is new and nothing in it is broken. Every tool has a handle worn to the shape of one hand. He does not throw anything away, including the parts of what he mends.",
			"rep": 2,
			"learn": [["russian", "remont"], ["russian", "spasibo"]],
			"rows": [
				{"id": "shoe", "label": "Hand him a shoe", "cost": 4, "to": "shoe"},
				{"id": "ok", "label": "Leave him to it", "to": ""},
			],
		},
		"shoe": {
			"film": [
				{"set": "shop/workshop", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "hand_over"}, {"at": 0.64, "act": "cut"}],
					"say": "He turns it over, looks at the sole for a second and a half, and starts. He did not ask me what was wrong with it and he was right not to."},
			],
			"text": "He turns it over, looks at the sole for about a second, and starts. He did not ask what was wrong with it. Four minutes later it comes back through the hole and the thing that was wrong is not wrong.",
			"rep": 3,
			"rows": [{"id": "ok", "label": "Put it back on standing on one leg",
				"to": ""}],
		},
	},
},

# ── Rome ─────────────────────────────────────────────────────────────────────

"rome:testaccio": {
	"title": "The fifth quarter",
	"start": "counter",
	"beats": {
		"counter": {
			"film": [
				{"set": "market+counter", "secs": 3.6,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.54, "act": "queue"},
						{"at": 0.70, "act": "queue"}],
					"say": "A covered market on a modern floor, and one counter in it with a queue while the others have nobody."},
				{"set": "counter/food", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "queue"}, {"at": 0.62, "act": "cut"}],
					"say": "The tray in front of him holds none of the parts of an animal I would have recognised as food."},
			],
			"text": "One counter in this market has a queue and the rest do not. What is in his tray is not the meat anybody would have chosen, and it is the reason people walk past four other butchers to stand here.",
			"rows": [
				{"id": "why", "label": "Find out why that counter", "to": "why"},
				{"id": "buy", "label": "Point at something", "cost": 7, "to": "bought"},
			],
		},
		"why": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "look_up"}, {"at": 0.66, "act": "watch"}],
					"say": "There is a slaughterhouse at the end of this street. It is a museum now, and the wall is the same wall."},
			],
			"text": "The slaughterhouse at the end of the street paid its men partly in the parts nobody would buy. Four generations later that is what the quarter's food is, and it is now expensive, and the building is a museum.",
			"rep": 3,
			"learn": [["italian", "quinto"], ["italian", "quarto"]],
			"rows": [
				{"id": "buy", "label": "Point at something", "cost": 7,
					"to": "bought"},
				{"id": "ok", "label": "Walk down to the wall", "to": ""},
			],
		},
		"bought": {
			"film": [
				{"set": "counter/food", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "point"}, {"at": 0.64, "act": "hand_over"}],
					"say": "He wraps it in waxed paper, then in a second sheet, and tells me something with three numbers in it that is clearly an instruction and not a price."},
			],
			"text": "Wrapped twice in waxed paper, with an instruction in it I could not follow that contained three numbers. Cooking it is evidently a thing with steps, and he has just given me all of them, and I have none of them.",
			"rep": 2,
			"item": "quinto_quarto",
			"rows": [{"id": "ok", "label": "Carry it out under your arm", "to": ""}],
		},
	},
},

"rome:esquilino": {
	"title": "Piazza Vittorio, inside",
	"start": "hall",
	"beats": {
		"hall": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A hall behind a nineteenth-century square, and inside it a market selling almost nothing the rest of this city sells."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "offer"}],
					"say": "Bitter leaves I have not seen anywhere else here, four kinds of dried fish, and a man weighing spices out of sacks into paper cones."},
			],
			"text": "A market hall behind a nineteenth-century square, selling almost nothing the rest of the city sells: bitter greens, dried fish, whole spices out of sacks, and a queue at every stall speaking something different.",
			"rows": [
				{"id": "spice", "label": "Buy a cone of something", "cost": 4,
					"to": "cone"},
				{"id": "listen", "label": "Listen to the queue", "to": "queue"},
			],
		},
		"queue": {
			"text": "Four languages in six people and none of them is the one on the street signs outside. Everybody is understood. Whatever is being used in here is not any of the four, and it is working.",
			"rep": 3,
			"learn": [["italian", "mercato"], ["italian", "quanto"]],
			"rows": [
				{"id": "spice", "label": "Buy a cone of something", "cost": 4,
					"to": "cone"},
				{"id": "ok", "label": "Keep listening", "to": ""},
			],
		},
		"cone": {
			"film": [
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "point"}, {"at": 0.64, "act": "count"}],
					"say": "He rolls the paper into a cone with one hand, fills it off the scale, and folds the top over twice. I have bought a smell."},
			],
			"text": "Rolled into a cone with one hand, filled off the scale, folded twice at the top. I do not know what it is or what it goes in, and it is going to make my coat smell of somewhere for a fortnight.",
			"rep": 2,
			"item": "spice_cone",
			"rows": [{"id": "ok", "label": "Put it in an inside pocket", "to": ""}],
		},
	},
},

# ── Tbilisi ──────────────────────────────────────────────────────────────────

"tbilisi:sololaki": {
	"title": "The unlocked hall",
	"start": "door",
	"beats": {
		"door": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A door four metres high with the paint coming off it in sheets, standing very slightly open, in a street of doors doing the same."},
				{"set": "gate", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "reach"}, {"at": 0.62, "act": "walk"}],
					"say": "A woman pushes one open with her shoulder because her hands are full, and it swings, and nobody was keeping it shut."},
			],
			"text": "Doors four metres high with the paint coming off them, and every one I pass is very slightly open. A woman shoulders one because her hands are full. None of them are locked.",
			"rows": [
				{"id": "push", "label": "Push one open", "to": "hall"},
				{"id": "wait", "label": "Wait to see if anybody minds", "to": "nobody"},
			],
		},
		"nobody": {
			"text": "Four people go in and out in ten minutes and not one of them looks at the door, or at me looking at the door. Whatever is behind it is not being guarded from anybody.",
			"rep": 1,
			"rows": [{"id": "push", "label": "Push it open", "to": "hall"}],
		},
		"hall": {
			"film": [
				{"set": "courtyard", "secs": 4.0,
					"cast": [{"at": 0.34, "act": "look_up"}],
					"say": "The ceiling is painted. Not a pattern - a painting, with figures in it, going brown at the edges where the roof has been letting in water for about ninety years."},
				{"set": "courtyard", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}, {"at": 0.64, "act": "walk"}],
					"say": "Stained glass on the half-landing with two panes gone and cardboard where they were, and somebody's washing on the balcony above it."},
			],
			"text": "A painted ceiling with figures in it, going brown where the roof has leaked for ninety years. Stained glass on the landing with two panes replaced by cardboard. People live here. It is a stairwell.",
			"rep": 3,
			"learn": [["georgian", "kari"], ["georgian", "sakhli"]],
			"rows": [
				{"id": "up", "label": "Go up to the half-landing", "to": "landing"},
				{"id": "ok", "label": "Pull the door to behind you", "to": ""},
			],
		},
		"landing": {
			"text": "From the landing the whole hall is one room with a sky painted on it, and eleven doorbells by the door, and a cat asleep on the ninth stair as if the painting were wallpaper. To everyone here it is.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Go back down quietly", "to": ""}],
		},
	},
},

"tbilisi:dezerter": {
	"title": "Deserters' Bazaar",
	"start": "cheese",
	"beats": {
		"cheese": {
			"film": [
				{"set": "market", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Wheels of white cheese the size of a car wheel, stacked, and each woman behind them has a knife and will cut you a corner to try before anything is agreed."},
				{"set": "stall", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "take"}, {"at": 0.62, "act": "offer"}],
					"say": "A corner of it is in my hand before I have indicated any interest at all. Refusing it is evidently not one of the available moves."},
			],
			"text": "Wheels of white cheese stacked like tyres, and a corner of one is in my hand before I have shown any interest. Tasting is not a favour here; it is the first half of the sentence.",
			"rows": [
				{"id": "buy", "label": "Buy a piece", "cost": 6, "to": "bought"},
				{"id": "walk", "label": "Walk on to the hanging things", "to": "candles"},
			],
		},
		"bought": {
			"text": "She cuts a wedge with a wire, weighs it, and adds a piece of something else on top that I did not buy and cannot identify. The second thing turns out to be the better of the two.",
			"rep": 2,
			"item": "sulguni",
			"learn": [["georgian", "qveli"], ["georgian", "ramdeni"]],
			"rows": [
				{"id": "candles", "label": "Go and look at the hanging things",
					"to": "candles"},
			],
		},
		"candles": {
			"film": [
				{"set": "stall", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "look_up"}, {"at": 0.64, "act": "watch"}],
					"say": "Rows of what look exactly like candles hanging on a line, brown and purple and knobbled, and a woman takes one down and bites the end off it."},
			],
			"text": "They look like candles hanging on a line and they are nuts on a string, dipped over and over in grape must until they set. A woman takes one down and bites the end off, which settles what they are.",
			"rep": 3,
			"learn": [["georgian", "churchkhela"]],
			"rows": [
				{"id": "try", "label": "Take one off the line", "cost": 3,
					"to": "tried"},
				{"id": "ok", "label": "Keep walking", "to": ""},
			],
		},
		"tried": {
			"text": "Chewy, not sweet in the way I expected, and the nuts inside are the whole point. It is the food of a place that had to make the harvest last a winter and then decided it liked it.",
			"rep": 2,
			"item": "churchkhela",
			"rows": [{"id": "ok", "label": "Eat it walking", "to": ""}],
		},
	},
},

# ── Zurich ───────────────────────────────────────────────────────────────────

"zurich:niederdorf": {
	"title": "The fountain",
	"start": "spout",
	"beats": {
		"spout": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "A stone trough on a corner with water coming out of a spout into it, and it has not stopped once since I arrived, and nobody has turned it off."},
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "watch"}, {"at": 0.62, "act": "drink"}],
					"say": "A man in a suit stops, holds a bottle under it, fills it, and goes. It took him four seconds and he did not look at the fountain while he did it."},
			],
			"text": "A stone trough on the corner running constantly. A man in a suit fills a bottle under it in four seconds without looking at it. There are over twelve hundred of these in this city and they all do this all day.",
			"rows": [
				{"id": "drink", "label": "Drink from it", "to": "drank"},
				{"id": "count", "label": "Count them along the street", "to": "count"},
			],
		},
		"drank": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.32, "act": "drink"}, {"at": 0.66, "act": "walk"}],
					"say": "Cold enough to hurt. Nobody watches me do it. It is not a kindness to travellers - it is the water supply, and it is simply also outside."},
			],
			"text": "Cold enough to hurt. Nobody watches me do it, because there is nothing to watch: this is the city's drinking water and it happens to also be outdoors, in stone, on every corner, for nothing.",
			"rep": 3,
			"learn": [["swissgerman", "brunne"], ["swissgerman", "wasser"]],
			"rows": [
				{"id": "count", "label": "Count them along the street",
					"to": "count"},
				{"id": "ok", "label": "Fill something and walk on", "to": ""},
			],
		},
		"count": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "walk"}, {"at": 0.62, "act": "watch"}],
					"say": "Four in six minutes of walking. One of them has a sign on it and the sign is the only one anybody needs to be able to read here."},
			],
			"text": "Four in six minutes. Only one of them carries a sign, and that sign means do not drink this one, and it is the single piece of writing in this city whose meaning I would have wanted first.",
			"rep": 2,
			"rows": [{"id": "ok", "label": "Remember which one had the sign",
				"to": ""}],
		},
	},
},

"zurich:langstrasse": {
	"title": "The street that stays open",
	"start": "kiosk",
	"beats": {
		"kiosk": {
			"film": [
				{"set": "street", "secs": 3.6,
					"cast": [{"at": 0.30, "act": "watch"}],
					"say": "Everything in this city shut at half past six. This street did not. One road, four hundred metres, and it is the only lit thing on the map."},
				{"set": "counter", "secs": 3.8,
					"cast": [{"at": 0.28, "act": "queue"}, {"at": 0.62, "act": "offer"}],
					"say": "A kiosk the size of a wardrobe selling six countries' worth of things at once, to a queue with nothing else in common."},
			],
			"text": "The whole city shut at half past six and this one street did not. Four hundred metres of it, lit, with a kiosk the size of a wardrobe at one end selling six countries' worth of things.",
			"rows": [
				{"id": "buy", "label": "Buy something at the kiosk", "cost": 5,
					"to": "bought"},
				{"id": "walk", "label": "Walk the whole four hundred metres",
					"to": "walked"},
			],
		},
		"walked": {
			"film": [
				{"set": "street", "secs": 3.8,
					"cast": [{"at": 0.30, "act": "walk"}, {"at": 0.60, "act": "stand"},
						{"at": 0.74, "act": "watch"}],
					"say": "A Turkish grill, an Eritrean bar, a Balkan cafe, a bank, and two police standing at the corner who are not doing anything and are extremely clearly there."},
			],
			"text": "A Turkish grill, an Eritrean bar, a Balkan cafe, a bank, and two police at the corner doing nothing at all and standing where everyone can see them. This street is where the country keeps the parts of itself that stay up late.",
			"rep": 2,
			"learn": [["swissgerman", "offe"], ["swissgerman", "nacht"]],
			"rows": [
				{"id": "buy", "label": "Buy something before it all shuts",
					"cost": 5, "to": "bought"},
				{"id": "ok", "label": "Walk back the way you came", "to": ""},
			],
		},
		"bought": {
			"film": [
				{"set": "counter/food", "secs": 3.6, "prop": "smoke", "prop_at": 0.36,
					"cast": [{"at": 0.32, "act": "take"}, {"at": 0.66, "act": "cut"}],
					"say": "He builds it without asking me a single question, because at this hour there is only one thing anybody wants and he has been right about that all night."},
			],
			"text": "He builds it without asking anything, because at this hour there is one thing people want and he has been right about it every night for years. It costs more than a meal did in four other countries and I eat it standing up.",
			"rep": 2,
			"item": "kebab",
			"rows": [{"id": "ok", "label": "Eat it against the wall", "to": ""}],
		},
	},
},

}
