extends RefCounted

# Authored personal encounters. Choices describe intentions, never a citywide
# correct personality. Native text is paired with a reading and contextual meaning.
const CITIES := {
	"berlin": {
		"title": "A place at the corner",
		"return": "Kerstin keeps the door open with her foot. 'Look who found the way back.' Emil has left a space at the table; Rika waves you over without stopping her story.",
		"outings": [
			[
				"mitte",
				"Mitte.tscn"
			],
			[
				"prenzlberg",
				"BerlinPrenzlberg.tscn"
			],
			[
				"kreuzberg",
				"BerlinKreuzberg.tscn"
			],
			[
				"kiez",
				"Kiez.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Kerstin · The extra chair",
					"text": "Kerstin is carrying a chair out of the Späti. Emil, her upstairs neighbour, points at the pavement. Rika, who works late, points at the chair. They appear to be arguing over a rectangle of empty space.\n\nKerstin catches you watching. 'Hilfst du mir?' She lifts her end an inch. You do not need every word to understand the weight.",
					"choices": [
						[
							"Take the other end; let her show you where",
							"You set it beside the shop. She nudges it back to leave room for a pushchair. 'Danke.' Emil's objection was to the blocked pavement, not to people sitting together."
						],
						[
							"Point at the open space and ask first",
							"Kerstin draws a walking route with her hand. 'Hier frei.' Keep this bit clear. Rika moves her bag before you have to ask."
						]
					],
					"phrase": [
						"Hilfst du mir?",
						"",
						"Can you help me? She is asking about this chair.",
						[
							"hilfst",
							"du",
							"mir"
						]
					],
					"callback": ""
				},
				{
					"title": "Rika · Who gets the evening?",
					"text": "Rika wants a neighbourhood table after her shift. Emil wants to sleep before an early train. 'It's only one night,' she says. 'It's my only night,' he replies.\n\nKerstin is trying to make a welcome without making an enemy. She offers you the chair. Her blunt instructions sounded cross; now she has nowhere to sit herself.",
					"choices": [
						[
							"Ask what time would work for each of them",
							"Emil can stay until nine. Rika arrives at eight. There is an hour they both assumed did not exist. Kerstin writes 20–21 on the back of a receipt.",
							"We asked about people's actual schedules before deciding they wanted different things."
						],
						[
							"Suggest a quieter table inside after nine",
							"Rika looks through the window. There is room if the crates move. Emil volunteers to move two. Nobody has to pretend they enjoy the same evening.",
							"We made a quieter space instead of asking somebody to stop being bothered."
						]
					],
					"phrase": [
						"Wann?",
						"",
						"When? A useful question when an argument is really about time.",
						[
							"wann"
						]
					],
					"callback": ""
				},
				{
					"title": "Kerstin · A small invitation",
					"text": "She puts an empty bottle beside your notebook. 'Pfand.' It can go back to the shop; it still has a little value.\n\n'Go and see the neighbourhood. Then tell me what I missed while I was behind this counter.' She points towards Mitte and the other streets. This sounds less like homework than somebody asking you to come back.",
					"choices": [
						[
							"Point at the bottle, then the shop, to check",
							"She nods. Bring it back, get the deposit. You write down the connection. The activity in Mitte will let you try it; other neighbourhoods have their own things going on."
						],
						[
							"Try 'Pfand' and ask her to show you once",
							"She places the bottle in the crate and taps a coin. You repeat the word with an object and an action attached to it. 'Genau.' Exactly."
						]
					],
					"phrase": [
						"Pfand",
						"",
						"A refundable deposit, here on a bottle.",
						[
							"pfand",
							"flasche"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Kerstin · Back at the counter",
					"text": "You return with a street in your head instead of just a street name. Kerstin recognises you before you manage a greeting.\n\nRika says the table should have a big sign: EVERYONE WELCOME. Emil asks whether that includes people who don't want to buy anything. For a moment, nobody answers.",
					"choices": [
						[
							"Ask whether someone can just sit",
							"'Of course,' Kerstin says, then notices the drinks menu she put on the table. She moves it back to the counter. A welcome can accidentally look like a price list."
						],
						[
							"Suggest putting water and spare chairs out first",
							"Rika puts a jug where the menu stood. 'That says it better.' Emil takes the chair furthest from the speaker. Nobody makes him explain why."
						]
					],
					"phrase": [
						"Nur sitzen?",
						"",
						"Just sit? You are checking what participation requires.",
						[
							"nur",
							"sitzen"
						]
					],
					"callback": ""
				},
				{
					"title": "Emil · An assumption worth changing",
					"text": "Emil folds the cardboard sign with surprising care. Rika admits she thought his objections meant he disliked her friends. 'I dislike being awake at four,' he says. 'Your friends are mostly fine.'\n\nKerstin laughs hard enough to lose the cap she was holding. The serious-looking man searches for it under the counter.",
					"choices": [
						[
							"Tell Rika what you first thought of Kerstin",
							"Kerstin listens to your gestures: sharp voice, then an offered chair. 'Both me,' she says. A first impression caught a moment, not a whole person.",
							"Kerstin could be brisk and generous in the same breath. Emil wanted sleep, not an empty street."
						],
						[
							"Ask Emil to help make the evening work",
							"He sketches a place for the table that leaves the pavement clear. Being invited to help changes his face more than being told not to worry.",
							"Emil joined in when we asked what would make the evening work for him."
						]
					],
					"phrase": [
						"Zusammen",
						"",
						"Together. It does not have to mean doing everything identically.",
						[
							"zusammen"
						]
					],
					"callback": ""
				},
				{
					"title": "Kerstin · Before the table goes out",
					"text": "Kerstin has called the evening her little Oktoberfest. Rika raises an eyebrow. 'We're in Berlin.'\n\n'And my sister is in Munich. I miss her.' It is Kerstin's borrowed family occasion, not a rule about this city. She wants neighbourhood stories on the table alongside the food.\n\nExplore three different activities in total, including Mitte, then return. You may observe, ask or participate; purchases and perfect answers are not required.",
					"choices": [
						[
							"Offer to bring back a story rather than a souvenir",
							"'Better,' she says. 'I have enough things.' You have a reason to wander, and a place to bring what you notice."
						],
						[
							"Ask where to start",
							"She marks Mitte on your page and circles two other streets. Your journal keeps the next step; you can choose your own order."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Rika · Making room",
					"text": "The chairs are out. A customer with a pushchair pauses at the gap; Rika starts moving the whole table. Emil catches the far end. Kerstin asks you to help decide.",
					"choices": [
						[
							"Move two chairs and leave a clear route",
							"The table stays; the way through opens. The customer comes back later on foot, because getting past comfortably made returning feel possible."
						],
						[
							"Ask the customer where a gap would help",
							"They show you the narrow turn. You move the table just enough. Nobody had to become an expert in somebody else's day to ask one useful question."
						]
					],
					"phrase": [
						"Hier frei?",
						"",
						"Keep this space clear? Pointing makes the question specific.",
						[
							"hier",
							"frei"
						]
					],
					"callback": ""
				},
				{
					"title": "Kerstin · A name on the receipt",
					"text": "Kerstin writes RIKA and EMIL on two paper cups. She holds the pen over a third. You shake your head: there is no name to put there.\n\n'All right. We can keep a place without a label.' She remembers the first evening you helped.",
					"choices": [
						[
							"Draw the chair on your cup",
							"She draws a tiny extra chair beside it. You recognise a shared memory that does not need a translation.",
							"Kerstin saved me a place before she knew what to call me."
						],
						[
							"Leave the cup blank and sit with them",
							"Rika sets it beside hers without filling the silence. You do not need to solve your whole identity before drinking water with somebody.",
							"I could leave something unexplained and still belong at Kerstin's table."
						]
					],
					"phrase": [],
					"callback": "We made space at the corner together."
				},
				{
					"title": "Emil · The end of the shift",
					"text": "Emil checks his watch. Rika switches the music down before he asks. Kerstin pushes the last crate under the counter. The evening is ready because several small promises have been kept.",
					"choices": [
						[
							"Help carry the final crate",
							"'Feierabend,' Kerstin says, taking off her shop apron. Work is finished. She invites you back for the gathering whenever you are ready."
						],
						[
							"Check the clear path one last time",
							"A neighbour passes without turning sideways. Kerstin gives you a satisfied nod. You have helped make a welcome people can actually use."
						]
					],
					"phrase": [
						"Feierabend",
						"",
						"The end of the working day; time off after the shift.",
						[
							"feierabend"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Kerstin · Your place at the gathering",
					"text": "Kerstin puts bread, water and drinks on the table. 'Was möchtest du?' She points to each. Nobody makes choosing a drink a test of belonging.",
					"choices": [
						[
							"Choose water and sit beside Rika",
							"Kerstin fills the glass and carries on telling her story. Rika leaves the loud end of the table to somebody else."
						],
						[
							"Ask what each drink is before choosing",
							"Kerstin names them slowly. You point to the one you want. Curiosity is welcome; alcohol is optional."
						]
					],
					"phrase": [
						"Wasser, bitte.",
						"",
						"Water, please. A complete request can be very small.",
						[
							"wasser",
							"bitte"
						]
					],
					"callback": ""
				},
				{
					"title": "Rika · A welcome somebody can read",
					"text": "The sign has room for one more line. Rika offers you the pen.",
					"choices": [
						[
							"Draw a chair beside 'Willkommen'",
							"A passer-by points at the drawing, then at an empty seat. Rika nods. Your picture has done some of the translating."
						],
						[
							"Ask Rika to write it with you",
							"She says 'Willkommen' as the letters appear. You add the last one. Emil points out that the chair still matters more than the sign."
						]
					],
					"phrase": [
						"Willkommen",
						"",
						"Welcome. Here it comes with an actual place to sit.",
						[
							"willkommen"
						]
					],
					"callback": ""
				},
				{
					"title": "Kerstin · What I want to remember",
					"text": "The counter is quiet for once. Kerstin looks at the people, not at the bottles.",
					"choices": [
						[
							"Remember the clear space and the spare chair",
							"You keep the receipt with the little chair drawn on it. Kerstin saved a place without asking you to become somebody else.",
							"At Kerstin's table, welcome meant a clear path, a spare chair and room to say no."
						],
						[
							"Remember that an argument became a plan",
							"You keep the 20–21 receipt. The people who sounded furthest apart made an evening together.",
							"Rika and Emil did not need the same evening to share part of one."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"london": {
		"title": "Not just the usual",
		"return": "Nadia looks up from a revision card. 'Oh, it's you. Good.' Val puts a cup down and waits for your order instead of guessing.",
		"outings": [
			[
				"highstreet",
				"LondonHighStreet.tscn"
			],
			[
				"terrace",
				"LondonTerrace.tscn"
			],
			[
				"brixton",
				"LondonBrixton.tscn"
			],
			[
				"soho",
				"LondonSoho.tscn"
			],
			[
				"docklands",
				"LondonDocklands.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Nadia · The spare hand",
					"text": "Nadia has a textbook under the caff counter and three unfinished jobs above it. Val, who runs the place, says, 'You couldn't take those over, could you?' Mr Ahmed points at the cups.\n\nNadia sees you looking for a yes-or-no answer. 'She's asking for help. But you can still say no.'",
					"choices": [
						[
							"Point at the cups and the table to confirm",
							"Val nods at the nearer table. 'Lovely.' Nadia grins: asking which table prevented more trouble than sounding fluent would have."
						],
						[
							"Ask Nadia to demonstrate one trip",
							"She carries one cup and lets you follow with the other. 'See? Teamwork. My teacher calls this procrastination.'"
						]
					],
					"phrase": [
						"Could you…?",
						"",
						"Often a request in this situation. Confirm the action instead of guessing.",
						[
							"could",
							"you"
						]
					],
					"callback": ""
				},
				{
					"title": "Val · The usual isn't universal",
					"text": "Val reaches for milk before Mr Ahmed speaks. He stops her. His niece is visiting and wants her tea differently.\n\nNadia mutters, 'Everybody thinks knowing your usual is knowing you.' Her revision card says DESIGN PORTFOLIO, although Val keeps mentioning university.",
					"choices": [
						[
							"Ask the visitor how she wants her tea",
							"She points to the black tea and adds sugar herself. The order was easy once you asked the person drinking it.",
							"We asked what someone wanted today instead of treating 'the usual' as their identity."
						],
						[
							"Check both cups before carrying them",
							"One with milk, one without. Val switches the cups around. A familiar routine still has room for a new person.",
							"Checking a small detail helped me notice the person inside the routine."
						]
					],
					"phrase": [
						"Milk? Sugar?",
						"",
						"Two short questions are enough to check an order.",
						[
							"milk",
							"sugar"
						]
					],
					"callback": ""
				},
				{
					"title": "Nadia · Something to come back with",
					"text": "Nadia wants a tea from the high street when you are next there. 'Not a quest for the mythical perfect cuppa. Just tell me what happened.'\n\nShe suggests wandering first. The city has more voices than the one behind this counter.",
					"choices": [
						[
							"Ask her to write the order",
							"She writes 'tea, milk, no sugar', then circles 'ask if unsure'. You can try the high-street activity or another neighbourhood before returning."
						],
						[
							"Make a tiny drawing of the cup",
							"Nadia adds an X beside your sugar cubes. 'That works.' Your notebook does not have to look like anyone else's."
						]
					],
					"phrase": [
						"No sugar, please.",
						"",
						"A preference, not a judgement about someone else's cup.",
						[
							"no",
							"sugar",
							"please"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Nadia · Fine, actually",
					"text": "You find Nadia staring at a reply on her phone. 'Fine,' she says. Then: 'Sorry. Not fine. I hate when I do that.'\n\nVal has signed her up to help all evening on Bonfire Night. Nadia has a portfolio deadline. Neither realised the other had already made a plan.",
					"choices": [
						[
							"Ask whether she wants help or just someone to listen",
							"'Listen first.' She shows you a drawing of the caff. It is funnier and kinder than the place looks on a wet morning."
						],
						[
							"Ask what time she actually has available",
							"'One hour, after I finish this.' A specific answer replaces an evening-sized worry. You help her write it down."
						]
					],
					"phrase": [
						"Do you mean…?",
						"",
						"Check the meaning with the person speaking. 'Fine' is not a secret code everyone uses the same way.",
						[
							"mean"
						]
					],
					"callback": ""
				},
				{
					"title": "Val · Two kinds of help",
					"text": "Val thought giving Nadia the event posters would be a chance to use her design skills. Nadia heard another unpaid shift. Mr Ahmed suggests buying the posters; Val looks embarrassed she didn't think of that.\n\nNadia asks what you make of it.",
					"choices": [
						[
							"Suggest a small paid poster job with a clear finish",
							"Val agrees to three signs, not the whole night. Nadia chooses the typeface before the conversation ends.",
							"Nadia wanted a clear job she could finish, not an entire evening assumed on her behalf."
						],
						[
							"Help Nadia explain the deadline and decline",
							"Val says the old signs can last another year. 'Show me your portfolio when it's done, then.' Saying no has not ended the relationship.",
							"Nadia declined an extra shift and Val still wanted to see her work."
						]
					],
					"phrase": [
						"Not tonight.",
						"",
						"A boundary about this evening, not a rejection of the person.",
						[
							"tonight"
						]
					],
					"callback": ""
				},
				{
					"title": "Nadia · Beyond the counter",
					"text": "'Go somewhere I haven't been this week,' Nadia says. 'I've seen the milk fridge and the number twelve bus.'\n\nExplore three neighbourhood activities in total, including the high street. Come back with something ordinary you noticed; you won't be marked on it.",
					"choices": [
						[
							"Promise to bring back one small detail",
							"She points at a pigeon on her poster wearing a tiny scarf. 'Small details are my entire artistic career.'"
						],
						[
							"Ask for a starting point",
							"She names the high street, Brixton and the river. Your journal keeps the next step, and you choose the route."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Mr Ahmed · Where the noise ends",
					"text": "The Bonfire Night gathering has a loud patch and a quiet patch. Mr Ahmed's niece loves the colours but hates sudden bangs. Nadia asks her to choose a spot on the little map.",
					"choices": [
						[
							"Help label the quiet viewing area",
							"Nadia uses an ear symbol and a simple arrow. Mr Ahmed tests whether the sign makes sense from the path."
						],
						[
							"Walk the route with them before the crowd arrives",
							"They choose a place further back. Nobody has to prove they are enjoying themselves by standing closest."
						]
					],
					"phrase": [
						"A bit further back.",
						"",
						"A practical way to ask for more distance.",
						[
							"further",
							"back"
						]
					],
					"callback": ""
				},
				{
					"title": "Nadia · Not the helpful girl",
					"text": "Nadia shows you the finished caff drawing. Val is a superhero with six arms. Nadia herself has only two, both holding pencils.\n\n'People remember I'm useful. I'd like them to remember I make things.' She asks what you would want drawn beside you.",
					"choices": [
						[
							"Point to your notebook",
							"She draws it open, with little chairs and cups instead of perfect handwriting. 'You notice things. That's a thing.'",
							"Nadia drew me as someone who notices, not someone who needs fixing."
						],
						[
							"Admit you don't know yet",
							"'Good. Neither do I, most days.' She leaves space on the page. It feels less like a missing answer when two people share it.",
							"Nadia left space for the person I have not worked out how to describe."
						]
					],
					"phrase": [],
					"callback": "Nadia remembered how we made room for her own plans."
				},
				{
					"title": "Val · An actual invitation",
					"text": "Val asks, 'Will you come for the lights?' Then she catches herself. 'If you want. And you don't have to carry anything.'\n\nNadia smiles at that last part.",
					"choices": [
						[
							"Accept, and ask where to meet",
							"Nadia circles the quiet spot on the map. You can come back when ready; the evening will wait for you."
						],
						[
							"Say you will watch from further away",
							"'We'll find you after,' Nadia says. Being included does not require choosing the same place."
						]
					],
					"phrase": [
						"If you want.",
						"",
						"An invitation should leave room for an honest answer.",
						[
							"want"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Nadia · Before the lights",
					"text": "Nadia lays out her three signs. Mr Ahmed has brought tape; Val brought enough cups for people who said they might come.",
					"choices": [
						[
							"Match the quiet-area arrow to the map",
							"The arrow points towards the sheltered path. Nadia asks you to hold it while she tapes the corners."
						],
						[
							"Ask Nadia to show the route once more",
							"She walks it with her finger. 'No exam. It's dark out there.'"
						]
					],
					"phrase": [
						"This way.",
						"",
						"A short direction works better when the gesture agrees.",
						[
							"this",
							"way"
						]
					],
					"callback": ""
				},
				{
					"title": "Val · Your own cup",
					"text": "Val holds up two cups. 'Hot drink, or water?' Nadia adds, 'Or neither. Revolutionary concept.'",
					"choices": [
						[
							"Choose a warm drink and ask what is in it",
							"Val tells you before pouring. You take the cup by its sleeve and let your hands warm up."
						],
						[
							"Choose water and stay near the quiet group",
							"Mr Ahmed shifts over so you can see. Nobody asks you to justify the choice."
						]
					],
					"phrase": [
						"What is in it?",
						"",
						"A useful question about ingredients; you do not owe an explanation.",
						[
							"what",
							"in"
						]
					],
					"callback": ""
				},
				{
					"title": "Nadia · A drawing to keep",
					"text": "Nadia tears a small copy of the drawing from her pad. It includes the blank space you talked about.",
					"choices": [
						[
							"Keep the drawing with your travel notes",
							"You remember a person who wanted a future as well as a shift at the caff.",
							"Nadia made room for her own future, and left a space for mine."
						],
						[
							"Ask her to sign it",
							"She writes NADIA, then holds the pen towards you. When you cannot offer a name, she draws your notebook instead.",
							"Nadia signed her drawing and gave my unnamed place on it a notebook."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"paris": {
		"title": "The table downstairs",
		"return": "Odile is correcting a crossword, not your greeting. Inès has saved the corner of the table with the best light. 'You know the way now,' Odile says.",
		"outings": [
			[
				"belleville",
				"ParisBelleville.tscn"
			],
			[
				"marais",
				"ParisMarais.tscn"
			],
			[
				"montmartre",
				"ParisMontmartre.tscn"
			],
			[
				"champdemars",
				"ParisChampDeMars.tscn"
			],
			[
				"ladefense",
				"ParisLaDefense.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Odile · Before the question",
					"text": "Odile holds the building door with a shopping bag. You start pointing at your map. She says, 'Bonjour,' and waits. Inès, her neighbour, arrives mid-phone-call and waves instead.\n\nOdile waves back. The same person has accepted two different greetings.",
					"choices": [
						[
							"Say bonjour, then show the map",
							"She sets the bag down and looks properly. The greeting made this an encounter between people instead of a map arriving in her face."
						],
						[
							"Help with the door, then point and smile",
							"'Merci.' She sees what you are asking. You have greeted her with an action before finding the word."
						]
					],
					"phrase": [
						"Bonjour.",
						"",
						"Hello. Odile wants to acknowledge each other before the request.",
						[
							"bonjour"
						]
					],
					"callback": ""
				},
				{
					"title": "Inès · A table with too many plans",
					"text": "Odile is organising a neighbours' meal for 14 Juillet. Inès wants music and a late start. Marcel, who opens his bakery early, wants the food before he falls asleep. Odile has already written a very tidy timetable.",
					"choices": [
						[
							"Ask each person when they can come",
							"The timetable gets less tidy and more useful. Marcel can bring bread early; Inès can help clear later.",
							"A plan became more welcoming when we asked who could actually follow it."
						],
						[
							"Ask what matters most to each of them",
							"Food together, a little music, a seat for a sore knee. You write three pictures instead of choosing whose whole plan wins.",
							"We found three specific needs under three competing plans."
						]
					],
					"phrase": [
						"À quelle heure ?",
						"A quelle heure ?",
						"At what time? Ask about the practical detail.",
						[
							"quelle",
							"heure"
						]
					],
					"callback": ""
				},
				{
					"title": "Odile · The loaf and the hello",
					"text": "Odile points towards Belleville. 'Du pain.' Then she repeats the beginning: 'Bonjour.' She does not need you to perform a flawless sentence. She wants you to notice the person serving it.\n\nExplore a neighbourhood activity, then come back. The bakery is a useful place to begin.",
					"choices": [
						[
							"Repeat the greeting and point at her bread",
							"She says the words once, slowly, while your drawing catches up."
						],
						[
							"Ask Inès to write a small reminder",
							"Inès writes 'hello → ask → thank you'. 'Works with Odile too,' she whispers. Odile hears her."
						]
					],
					"phrase": [
						"Du pain, s'il vous plaît.",
						"Du pain, s'il vous plait.",
						"Some bread, please. Pointing can help specify which one.",
						[
							"pain",
							"merci"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Odile · The wrong kind of quiet",
					"text": "Odile describes Inès as distracted. Inès describes Odile as impossible to please. Then Marcel mentions that Inès has been taking hospital calls for her brother.\n\nOdile looks at the empty chair beside her, then at the phone in Inès's hand.",
					"choices": [
						[
							"Suggest asking Inès what would help",
							"Inès asks for a seat where she can step away easily. She did not need a judgement or a public explanation.",
							"Inès needed room to take a call. Her attention was somewhere important."
						],
						[
							"Offer to handle a small task while Inès calls",
							"You fold napkins. Odile folds the next pile without another comment. Help can be quiet without being cold.",
							"We stopped interpreting Inès's phone and helped with the thing in front of us."
						]
					],
					"phrase": [
						"Ça va ?",
						"Ca va ?",
						"Are you all right? Leave space for the person to choose how much to tell.",
						[
							"ca",
							"va"
						]
					],
					"callback": ""
				},
				{
					"title": "Marcel · How much bread?",
					"text": "Marcel asks whether to bring twelve or twenty rolls. Odile says twelve; Inès says people might bring friends. The numbers are suddenly useful.\n\nMarcel draws twelve circles, then eight more. You can understand the choice without reciting a lesson.",
					"choices": [
						[
							"Point to twelve, with the extra eight kept aside",
							"Marcel agrees to keep a reserve. Odile appreciates having a plan that can change."
						],
						[
							"Ask how many people have actually replied",
							"Inès counts the messages. Sixteen so far. Marcel draws four more circles. The answer came from asking, not from guessing confidently."
						]
					],
					"phrase": [
						"Combien ?",
						"",
						"How many? Here the object is rolls, not money.",
						[
							"combien"
						]
					],
					"callback": ""
				},
				{
					"title": "Odile · More than one Paris",
					"text": "Odile asks what you have seen beyond this doorway. Inès suggests a street where nobody knows her; Marcel suggests one where everybody knows him. They grin at the disagreement.\n\nTry three different neighbourhood activities in total, including Belleville, then bring your observations back.",
					"choices": [
						[
							"Choose a route that interests you",
							"Odile stops herself from correcting the order on your map. 'Vous me raconterez.' Tell me about it later."
						],
						[
							"Ask for the nearest unfinished activity",
							"She marks a place in your journal. You can ask for directions without agreeing to follow somebody else's entire day."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Inès · An invitation with a gap",
					"text": "The table is set, but Inès has left one place uncertain: her brother might feel well enough to join. Odile wants a final count.",
					"choices": [
						[
							"Keep one setting ready without promising he will come",
							"Odile places a folded napkin aside. An uncertain invitation is still an invitation."
						],
						[
							"Ask Inès whether she would prefer a quiet takeaway plate",
							"She chooses both possibilities. Marcel finds a clean container. Planning can support a change instead of punishing it."
						]
					],
					"phrase": [
						"Peut-être.",
						"Peut-etre.",
						"Maybe. A real answer when somebody cannot promise.",
						[
							"peut",
							"etre"
						]
					],
					"callback": ""
				},
				{
					"title": "Odile · Forty-one years",
					"text": "Odile says she knows this building. Then she corrects herself: she knows many things about it. People have changed while she stayed.\n\n'When I taught, I could always put a name on the register. You leave me a rather interesting blank.'",
					"choices": [
						[
							"Show her the places people have drawn in your notebook",
							"She recognises a cup, a chair and a route. 'Those are introductions too.'",
							"Odile saw a notebook full of introductions where a name would usually go."
						],
						[
							"Ask whether she ever liked not being recognised",
							"She laughs. 'On holiday. Constantly.' The person who knows everybody has sometimes wanted to be a stranger.",
							"Odile admitted that sometimes she enjoys being unknown."
						]
					],
					"phrase": [],
					"callback": "We let a careful plan make room for people."
				},
				{
					"title": "Marcel · The first seat",
					"text": "Marcel breaks off the end of a loaf. Inès turns the music down while a neighbour speaks. Odile asks where you would like to sit.",
					"choices": [
						[
							"Choose beside someone you have not met",
							"Odile introduces you with what you helped do, not with an explanation of what you are."
						],
						[
							"Sit beside Odile and help pass the bread",
							"She offers the basket with a small nod. You have an invitation to return for the evening whenever ready."
						]
					],
					"phrase": [
						"Avec vous.",
						"",
						"With you. The same words can mean a practical choice and something more.",
						[
							"avec",
							"vous"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Inès · A table, not a timetable",
					"text": "Inès brings two playlists: a lively one and a quieter one. A neighbour is telling a story at the far end.",
					"choices": [
						[
							"Save the lively music for after the story",
							"Inès writes a little arrow beside the playlist. Odile approves of this timetable revision."
						],
						[
							"Ask the people at the table what they prefer",
							"The answers differ. You make a quieter end and keep the speaker near people who want it."
						]
					],
					"phrase": [
						"Vous préférez quoi ?",
						"Vous preferez quoi ?",
						"What would you prefer? Ask the people affected.",
						[
							"preferez",
							"quoi"
						]
					],
					"callback": ""
				},
				{
					"title": "Marcel · Passing things along",
					"text": "Marcel offers the bread basket. There are enough rolls, and a reserve under the cloth.",
					"choices": [
						[
							"Say merci and pass the basket",
							"The words fit an action you now understand. Someone further down says them back to you."
						],
						[
							"Ask him to say the bread's name again",
							"He says it slowly and points. Nobody at the table treats your question as an interruption to belonging."
						]
					],
					"phrase": [
						"Encore une fois ?",
						"",
						"One more time? A request to repeat, not an apology for learning.",
						[
							"encore",
							"fois"
						]
					],
					"callback": ""
				},
				{
					"title": "Odile · The revised page",
					"text": "Odile's original timetable is covered in arrows. She folds it carefully instead of throwing it away.",
					"choices": [
						[
							"Keep the amended plan",
							"A tidy plan became a record of listening.",
							"Odile's crossed-out timetable remembered the people the first version missed."
						],
						[
							"Keep Inès's small drawing of the table",
							"Some seats are occupied, some are waiting. Neither kind is a mistake.",
							"Inès drew a table with room for people who could not promise to come."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"moscow": {
		"title": "Worth repairing",
		"return": "Viktor turns the lamp towards the counter when he sees you. Alina has left a new note; Pavel wants to know whether your little repair held.",
		"outings": [
			[
				"izmaylovo",
				"MoscowIzmaylovo.tscn"
			],
			[
				"basmanny",
				"MoscowBasmanny.tscn"
			],
			[
				"arbat",
				"MoscowArbat.tscn"
			],
			[
				"kitaygorod",
				"MoscowKitayGorod.tscn"
			],
			[
				"zamoskvorechye",
				"MoscowZamoskvorechye.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Viktor · The small box",
					"text": "Viktor has opened a tin containing a broken brooch. Alina, its owner, keeps pointing to the scratched face. Pavel, who brings spare parts, suggests a shiny replacement.\n\nViktor says little. He moves the lamp so you can see the scratched edge too.",
					"choices": [
						[
							"Ask what Alina wants to keep",
							"She points to the old surface, then a photograph in her wallet. The repair is about keeping this object, not obtaining any working brooch."
						],
						[
							"Point to the broken clasp rather than the scratches",
							"Viktor nods and sets a tiny spring aside. You have separated what is broken from what only looks old."
						]
					],
					"phrase": [
						"Что сохранить?",
						"Chto sokhranit?",
						"What should we preserve? The customer's answer matters.",
						[
							"chto",
							"sokhranit"
						]
					],
					"callback": ""
				},
				{
					"title": "Pavel · Newer is not always better",
					"text": "Pavel says he would choose the replacement. Alina says the scratches were made by her grandmother's sewing scissors. Neither is describing a rule for everybody.\n\nViktor offers you two trays: sound parts and worn parts.",
					"choices": [
						[
							"Sort by whether a part works, not whether it shines",
							"A dull clasp still closes perfectly. Pavel puts it into the sound tray with a small shrug.",
							"We asked what an object meant before deciding what a better version would be."
						],
						[
							"Ask Viktor to show one working clasp first",
							"He opens and closes it, slowly. You compare the click rather than the colour. He gives you the next one to try.",
							"Viktor explained with his hands, and I learned to ask for a demonstration."
						]
					],
					"phrase": [
						"Покажите, пожалуйста.",
						"Pokazhite, pozhaluysta.",
						"Please show me. A practical request when words are missing.",
						[
							"pokazhite",
							"pozhaluysta"
						]
					],
					"callback": ""
				},
				{
					"title": "Viktor · A detail worth finding",
					"text": "Viktor draws a small pin-backed shape, then writes Izmaylovo. 'Look at how they fasten,' he indicates. 'Don't buy the whole market.'\n\nTry a neighbourhood activity before returning. The trays at Izmaylovo are one place to start noticing how objects carry stories.",
					"choices": [
						[
							"Copy the shape and check the drawing",
							"He adds the clasp on the back. One clarified detail can save a lot of confident wandering."
						],
						[
							"Ask whether a drawing will do if you find nothing",
							"He nods. This is an invitation to look, not a demand to spend money."
						]
					],
					"phrase": [
						"Можно?",
						"Mozhno?",
						"May I? Point to the object you want to examine.",
						[
							"mozhno"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Alina · Who gets to tell the story?",
					"text": "Alina returns while Pavel tells someone the brooch belonged to her grandmother. She goes quiet. Viktor closes the tin until the other customer leaves.\n\nA good story does not automatically become a public story.",
					"choices": [
						[
							"Ask Alina what she wants shared",
							"'That it can be repaired.' Nothing more. Pavel apologises without asking her to comfort him.",
							"Alina decided how much of her family story belonged in the shop."
						],
						[
							"Put the photograph away and return to the clasp",
							"Alina relaxes. You make room for privacy through a small action instead of another question.",
							"We could help Alina without turning her memory into a performance."
						]
					],
					"phrase": [
						"Личное.",
						"Lichnoye.",
						"Personal; private. You do not need the details to respect the boundary.",
						[
							"lichnoye"
						]
					],
					"callback": ""
				},
				{
					"title": "Viktor · Not silent about everything",
					"text": "Pavel mentions football. Viktor suddenly has a lengthy opinion. Alina laughs: 'You found the switch.'\n\nHis short answers at the bench were concentration, not the whole of his personality. He stops mid-sentence to check whether you are following.",
					"choices": [
						[
							"Ask for the short version",
							"He points at two imaginary goals and sighs theatrically. Even Pavel understands that summary."
						],
						[
							"Admit you lost the words and enjoy the gestures",
							"Viktor reenacts a missed shot with a tiny spring. He catches it before it escapes. Alina applauds the save."
						]
					],
					"phrase": [
						"Медленнее, пожалуйста.",
						"Medlenneye, pozhaluysta.",
						"More slowly, please. The conversation can make room for your pace.",
						[
							"medlenneye"
						]
					],
					"callback": ""
				},
				{
					"title": "Pavel · More than the souvenir tray",
					"text": "Pavel suggests three places to notice what people keep, mend or pass on. Viktor circles Izmaylovo on your map.\n\nFinish three different neighbourhood activities in total, including Izmaylovo, then return. Observing or asking is enough; you do not owe the shop a purchase.",
					"choices": [
						[
							"Take the map and look for stories attached to objects",
							"Viktor lends you a pencil stub. 'Back with that,' he says, and Pavel laughs."
						],
						[
							"Ask which route is easiest to reach",
							"Pavel marks the transport connection. Your journey pass covers the ride."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Viktor · The repair decision",
					"text": "There are two working solutions: replace the clasp neatly, or reinforce the old one with a visible loop. Alina wants to wear the brooch, but has not chosen how.",
					"choices": [
						[
							"Show her both, then let her choose",
							"She picks the visible loop. 'I'll know where you helped it.' Viktor sets the replacement aside without argument."
						],
						[
							"Ask her to try each fastening before choosing",
							"The old clasp is difficult for her fingers. She chooses the new one and keeps the old piece in the tin. Preserving a memory need not mean preserving an inconvenience."
						]
					],
					"phrase": [
						"Как удобнее?",
						"Kak udobneye?",
						"Which is more comfortable or convenient? Let the user of the object decide.",
						[
							"kak",
							"udobneye"
						]
					],
					"callback": ""
				},
				{
					"title": "Alina · Something without a label",
					"text": "Alina asks your name for a thank-you note. There is no word to give her. Viktor taps the drawing you made: that can identify a person too.",
					"choices": [
						[
							"Draw the clasp beside her note",
							"She recognises your slightly crooked drawing immediately. It has become yours through use.",
							"Alina recognised my drawing when I had no name to sign."
						],
						[
							"Ask her to leave a space",
							"She leaves a whole line. 'Later, if you want.' There is no deadline attached.",
							"Alina left a line for a name without asking me to fill it today."
						]
					],
					"phrase": [],
					"callback": "We learned what mattered to Alina before repairing it."
				},
				{
					"title": "Pavel · The invitation",
					"text": "Pavel mentions Maslenitsa and brings out a list of people meeting for pancakes. Viktor adds a little lamp symbol beside your place: the one who helped at the bench.",
					"choices": [
						[
							"Offer to help set up",
							"Viktor gives you a task small enough to finish before the food arrives. This time the work is part of being together, not the price of entry."
						],
						[
							"Ask whether you can just join them",
							"'Yes,' says Viktor immediately. Pavel adds a chair to the drawing."
						]
					],
					"phrase": [
						"Вместе.",
						"Vmeste.",
						"Together. The invitation includes you before you offer anything.",
						[
							"vmeste"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Alina · At the shared table",
					"text": "There are several fillings, and not everybody wants the same thing. Alina labels the dishes while Pavel puts out plates.",
					"choices": [
						[
							"Ask what each filling contains",
							"Alina points to the labels and explains. You choose what suits you without having to taste everything."
						],
						[
							"Help put serving spoons with the right dishes",
							"Viktor checks one label with you. A small question prevents mixing up the plates."
						]
					],
					"phrase": [
						"Что внутри?",
						"Chto vnutri?",
						"What is inside? Ask before choosing food.",
						[
							"vnutri"
						]
					],
					"callback": ""
				},
				{
					"title": "Pavel · A toast or a word",
					"text": "Pavel asks if you want to say something. Viktor lifts his cup a little: a gesture is enough too.",
					"choices": [
						[
							"Say 'spasibo' and raise your cup",
							"Alina raises hers. You do not need a speech to thank the people in front of you."
						],
						[
							"Stay quiet and listen to Alina",
							"She chooses to tell a different family story today. It is hers to offer this time."
						]
					],
					"phrase": [
						"Спасибо.",
						"Spasibo.",
						"Thank you.",
						[
							"spasibo"
						]
					],
					"callback": ""
				},
				{
					"title": "Viktor · What held",
					"text": "Viktor hands back your pencil drawing. On the reverse he has drawn the repaired clasp.",
					"choices": [
						[
							"Keep the drawing of the repair",
							"A visible join can be evidence of care.",
							"Viktor helped something keep working without erasing the life it had already had."
						],
						[
							"Remember Alina choosing her own solution",
							"The answer was not hidden in a national custom. It was with the person who would wear the brooch.",
							"Alina chose what to preserve; our job was to ask and listen."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"istanbul": {
		"title": "Thirty-one glasses, three people",
		"return": "Arda has left a space on the tray for whatever you actually want. Selin asks where you went; Hasan pretends not to listen, then supplies a better route.",
		"outings": [
			[
				"carsi",
				"IstanbulCarsi.tscn"
			],
			[
				"han",
				"IstanbulHan.tscn"
			],
			[
				"karakoy",
				"IstanbulKarakoy.tscn"
			],
			[
				"kadikoy",
				"IstanbulKadikoy.tscn"
			],
			[
				"beyoglu",
				"IstanbulBeyoglu.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Arda · Before the tea goes cold",
					"text": "Arda balances a tray at the han. Hasan wants his tea strong. Selin wants hers lighter and has already said she will add her own sugar. Arda repeats the orders under his breath, then looks at you.\n\n'Çay?' His hand indicates a spare glass. An offer does not tell you whether you want it.",
					"choices": [
						[
							"Accept one, and point to Selin's lighter glass",
							"'Açık.' Arda lets you compare the colours. Selin gives you room at the table."
						],
						[
							"Decline with thanks and ask for water",
							"Arda puts the spare glass down and brings water. 'Tabii.' Of course. You remain part of the conversation."
						]
					],
					"phrase": [
						"Açık çay.",
						"Acik chay.",
						"Light tea. Here it is Selin's preference, not everybody's order.",
						[
							"açık",
							"çay"
						]
					],
					"callback": ""
				},
				{
					"title": "Selin · The person behind the order",
					"text": "Hasan says Arda should know the orders by now. Arda says Hasan changed his yesterday. Selin points out that knowing someone should include letting them change their mind.\n\nThe tray is ready, but two glasses look alike.",
					"choices": [
						[
							"Ask each person before handing the glasses over",
							"Hasan taps the stronger one. Selin takes the lighter one. The check takes seconds and saves a whole argument.",
							"We checked today's tea orders instead of making people keep yesterday's preferences."
						],
						[
							"Ask Arda to show how he remembers the tray",
							"He places a spoon beside Selin's glass as a marker. 'But ask if you forget.' A system helps; it does not replace the person.",
							"Arda showed me a small practical trick and still told me to ask when unsure."
						]
					],
					"phrase": [
						"Şeker?",
						"Sheker?",
						"Sugar? Let the person choose rather than adding it for them.",
						[
							"şeker"
						]
					],
					"callback": ""
				},
				{
					"title": "Arda · The tickets in the bakery",
					"text": "Arda mentions the bakery in the Çarşı. 'Askıda ekmek.' There are paper tickets behind the counter; he wants you to notice what they do.\n\nTry a neighbourhood activity, then come back. You do not have to buy anything or repay the tea.",
					"choices": [
						[
							"Ask him to say the two words slowly",
							"He repeats them, pointing towards the bakery. You write enough to recognise them there."
						],
						[
							"Draw a loaf and a hanging ticket",
							"He nods at both drawings. Your notebook can hold a question until the street answers it."
						]
					],
					"phrase": [
						"Askıda ekmek.",
						"Askida ekmek.",
						"Bread paid for in advance for someone who needs it; ask how this bakery handles it.",
						[
							"askıda",
							"ekmek"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Hasan · An offer with a camera",
					"text": "Hasan suggests photographing the han's holiday food collection. Selin worries that people collecting help will appear in the pictures. Arda can see what both are trying to protect: support for the collection, and people's privacy.",
					"choices": [
						[
							"Suggest photographing the supplies without the recipients",
							"Hasan frames the stacked packages. Selin checks that nobody appears at the edge. The collection can be visible without making someone's need public.",
							"We made the help visible without turning its recipients into a picture."
						],
						[
							"Ask whether a written notice would do the job",
							"Arda draws a simple map and lists what the collection needs. Hasan adds the opening time. Selin pins it up herself.",
							"A clear notice let people help without exposing anyone else's private circumstances."
						]
					],
					"phrase": [
						"İzin var mı?",
						"Izin var mi?",
						"Is there permission? Ask before including someone in a picture or story.",
						[
							"izin",
							"var",
							"mı"
						]
					],
					"callback": ""
				},
				{
					"title": "Arda · He isn't always cheerful",
					"text": "Arda misses one order and Hasan snaps. After Hasan leaves, Arda sits for a moment. 'He was waiting for a call. Still didn't have to say it like that.'\n\nYou can understand a reason without pretending the behaviour did not hurt.",
					"choices": [
						[
							"Ask whether Arda wants company",
							"He moves the tray so there is room. He talks about the job he might apply for. There is a life beyond this tea round."
						],
						[
							"Offer to carry the empty glasses while he rests",
							"He accepts, but points out the stable handle first. When you return, he has saved a seat."
						]
					],
					"phrase": [
						"Bir dakika.",
						"",
						"One minute. A small pause can be a reasonable request.",
						[
							"bir",
							"dakika"
						]
					],
					"callback": ""
				},
				{
					"title": "Selin · Beyond one courtyard",
					"text": "Selin asks whether every place you visit will become one line in your notebook. Arda says his line would currently be 'needs a break'.\n\nTry three different neighbourhood activities in total, including the Çarşı, before returning. Look for something that complicates your first impression.",
					"choices": [
						[
							"Promise to leave room for a second observation",
							"Selin draws an arrow on your page instead of crossing out the first sentence. Learning can revise it."
						],
						[
							"Ask Arda for an easy route",
							"He marks the connections. Transport is covered; you can spend your attention on the people you find."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Hasan · Making an apology useful",
					"text": "Hasan comes back with the call finally finished. He apologises to Arda, then reaches for the tray as though the tea round should immediately restart. Arda is still on his break.",
					"choices": [
						[
							"Ask whether the round can wait one minute",
							"Hasan sits. The apology acquires a small action to go with the words."
						],
						[
							"Offer to let people collect their own glass this round",
							"Selin takes hers first. Hasan brings his empty back. Arda finishes his break without becoming the subject of a speech."
						]
					],
					"phrase": [
						"Bekleyebilir mi?",
						"Bekleyebilir mi?",
						"Can it wait? Ask about the timing rather than deciding for someone.",
						[
							"bekleyebilir"
						]
					],
					"callback": ""
				},
				{
					"title": "Arda · What should I call you?",
					"text": "Arda needs a name for a label on the holiday packages. You have none to give. Selin asks whether a drawing would be all right.\n\n'Your choice,' Arda adds, holding the pen out instead of writing for you.",
					"choices": [
						[
							"Draw the little tray beside your contribution",
							"Arda recognises it and smiles. An ordinary afternoon has become a shared reference.",
							"Arda asked before giving me a label. I chose a tray we both remembered."
						],
						[
							"Leave it unsigned",
							"'Still counts,' Selin says. The package goes on the same stack as the others.",
							"Selin reminded me that something can matter without my name on it."
						]
					],
					"phrase": [],
					"callback": "We made room for rest and for people's choices."
				},
				{
					"title": "Selin · A place for the holiday",
					"text": "The neighbours are arranging their Ramazan Bayramı visit. Hasan asks who would like to help carry the packages; Arda asks who would like to stay and greet people. Selin asks who would simply like to come.",
					"choices": [
						[
							"Offer to greet people alongside Arda",
							"He rehearses the greeting with you and points to the seat where you can watch first."
						],
						[
							"Choose to join as a guest",
							"'Then be our guest,' Selin says. You can return when ready; there is no need to wait for a particular date."
						]
					],
					"phrase": [
						"Bayramınız kutlu olsun.",
						"Bayraminiz kutlu olsun.",
						"A holiday greeting: wishing someone a happy Bayram.",
						[
							"bayramınız",
							"kutlu",
							"olsun"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Arda · The first greeting",
					"text": "Hasan greets one neighbour with an embrace and another with a wave. Arda sees you studying the difference.\n\n'You can ask. Or wave. They can ask too.'",
					"choices": [
						[
							"Offer a wave and the greeting you practised",
							"The neighbour waves back, leaving the distance comfortable for both of you."
						],
						[
							"Wait and follow the greeting offered to you",
							"Selin introduces you and lets you choose whether to step closer. Nothing is forced."
						]
					],
					"phrase": [
						"Merhaba.",
						"",
						"Hello. The greeting can be warm without requiring touch.",
						[
							"merhaba"
						]
					],
					"callback": ""
				},
				{
					"title": "Selin · A plate of choices",
					"text": "There are sweets, water and tea. Selin tells you what is in the sweets before offering them. Arda remembers that preferences can change.",
					"choices": [
						[
							"Ask for a small portion",
							"She puts one on a plate and leaves the rest available. Accepting a little is not a promise to accept everything."
						],
						[
							"Decline food and share the conversation",
							"Selin pours water. Your place does not depend on eating."
						]
					],
					"phrase": [
						"Teşekkür ederim.",
						"Teshekkuer ederim.",
						"Thank you. It can accompany either accepting or declining.",
						[
							"teşekkür",
							"ederim"
						]
					],
					"callback": ""
				},
				{
					"title": "Arda · An ordinary glass",
					"text": "Arda holds the last empty glass to the light. 'Not thirty-one today. I lost count.' For once, that seems to please him.",
					"choices": [
						[
							"Remember the round where people served themselves",
							"The shared work gave Arda a moment to be a guest in his own courtyard.",
							"In the han, I learned to ask what each person wanted and to notice who needed a rest."
						],
						[
							"Remember the drawing on the package",
							"You sketch it again in your notebook: an invitation that did not require explaining everything about yourself.",
							"Arda offered me a place and let me choose what to put on the label."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"mumbai": {
		"title": "A lane with more than one voice",
		"return": "Omkar turns down the radio to hear where you have been. Asha has another list; Yusuf insists this one is shorter. It is not.",
		"outings": [
			[
				"chorbazaar",
				"MumbaiChorBazaar.tscn"
			],
			[
				"bhuleshwar",
				"MumbaiBhuleshwar.tscn"
			],
			[
				"colaba",
				"MumbaiColaba.tscn"
			],
			[
				"bandra",
				"MumbaiBandra.tscn"
			],
			[
				"byculla",
				"MumbaiByculla.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Omkar · Three people, four lists",
					"text": "Omkar is repairing a phone while Asha lists things needed for the neighbourhood gathering. Yusuf is trying to keep a delivery route clear. The conversation moves between languages faster than your pencil.\n\nOmkar notices. He draws a plug, a chair and a box. 'One thing at a time.'",
					"choices": [
						[
							"Point to the chair and ask who needs it",
							"Asha points to an older neighbour who cannot stand for long. The drawing becomes a person with a practical need."
						],
						[
							"Ask Omkar to repeat just the first item",
							"He puts down the phone and repeats it slowly. Yusuf waits instead of filling the gap with more instructions."
						]
					],
					"phrase": [
						"धीरे बोलिए।",
						"Dheere boliye.",
						"Please speak slowly. A Hindi phrase you can use when that is the language being spoken.",
						[
							"dheere",
							"boliye"
						]
					],
					"callback": ""
				},
				{
					"title": "Yusuf · Room to get through",
					"text": "Asha wants the decorations across the lane. Yusuf needs to wheel deliveries through it. Omkar knows both of them and initially assumes they will sort it out. They do not.",
					"choices": [
						[
							"Ask Yusuf to show the width his trolley needs",
							"You mark a clear route with empty boxes. Asha moves the decorations to the edge; they are still visible.",
							"We asked how much room a delivery actually needed before placing the decorations."
						],
						[
							"Ask Asha which part of the display matters most",
							"The welcome sign, she says. It can face the lane from the wall. Yusuf offers to fix the loose hook.",
							"Finding out what mattered let the plan change without dismissing the person who made it."
						]
					],
					"phrase": [
						"यहाँ?",
						"Yahaan?",
						"Here? Pair the question with a specific place.",
						[
							"yahaan"
						]
					],
					"callback": ""
				},
				{
					"title": "Omkar · A drawing for the market",
					"text": "The group needs a small replacement part. Omkar sketches it for your notebook and circles Chor Bazaar. 'Show the drawing. Check the shape. Ask again if you're unsure.'\n\nTry a neighbourhood activity, then come back. You are not expected to master every language in the lane.",
					"choices": [
						[
							"Check the drawing against the old part",
							"Omkar points out the end that must fit. You add that detail before leaving."
						],
						[
							"Ask which language to start with",
							"'Ask the person,' he says. 'Or start with the picture. We don't all have the same first language.'"
						]
					],
					"phrase": [
						"दिखाइए।",
						"Dikhaiye.",
						"Please show me. A demonstration can bridge a missing word.",
						[
							"dikhaiye"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Asha · Who the notice reaches",
					"text": "Asha's notice is beautifully written, but Yusuf points out that one of the new neighbours cannot read it. Omkar suggests more text in another language. Asha asks whether anyone has checked which language the neighbour reads.",
					"choices": [
						[
							"Ask the neighbour which version would help",
							"They choose a language and ask for the time in larger numbers. Asha makes the useful change instead of guessing from a name.",
							"We asked what language someone reads instead of assigning one to them."
						],
						[
							"Add simple pictures and offer to explain it aloud",
							"The neighbour follows the pictures, then asks a question you would not have predicted. Accessible does not mean there is nothing left to ask.",
							"Pictures opened the conversation; they did not replace the person's own questions."
						]
					],
					"phrase": [
						"समझ में आया?",
						"Samajh mein aaya?",
						"Did that make sense? Check understanding kindly, without turning it into a test.",
						[
							"samajh",
							"mein",
							"aaya"
						]
					],
					"callback": ""
				},
				{
					"title": "Omkar · The person with the screwdriver",
					"text": "Omkar is expected to fix every phone because he is good at it. Asha has brought him another one just as he opens his own sketchbook.\n\nIt contains stage designs. He shuts it, then decides to show you a page.",
					"choices": [
						[
							"Ask about the design before the phone",
							"He explains where the lights would go. For five minutes he is the person with an idea instead of the person who repairs everybody else's things."
						],
						[
							"Ask when he wants to stop working today",
							"He writes a finish time. Asha leaves the phone for tomorrow and asks to see the sketch."
						]
					],
					"phrase": [
						"बाद में।",
						"Baad mein.",
						"Later. Something can matter without happening immediately.",
						[
							"baad"
						]
					],
					"callback": ""
				},
				{
					"title": "Yusuf · The lane is not the whole city",
					"text": "Yusuf recommends a market; Asha recommends a quieter walk; Omkar recommends finding something neither of them has mentioned.\n\nTry three different neighbourhood activities in total, including Chor Bazaar, then return. You can observe or ask instead of buying.",
					"choices": [
						[
							"Keep their different suggestions",
							"A city is beginning to look less like one set of instructions and more like people lending you their routes."
						],
						[
							"Ask for the simplest transport connection",
							"Omkar draws it with arrows. The journey pass covers the ride; there is no shift to earn first."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Asha · A place to participate",
					"text": "The Ganesh Chaturthi preparations have attracted neighbours with different beliefs and different levels of interest. Yusuf wants to help with the practical setup but will not join the ritual. Asha says that is fine; another helper seems surprised.",
					"choices": [
						[
							"Ask Yusuf which job he wants",
							"He chooses the clear route and chairs. Asha thanks him for that specific work, without claiming more."
						],
						[
							"Help separate the invitation from an expectation",
							"You point to watching, helping and joining as different choices. Omkar makes three little drawings on the notice."
						]
					],
					"phrase": [
						"ठीक है।",
						"Theek hai.",
						"All right. Acceptance should be reflected in what happens next.",
						[
							"theek",
							"hai"
						]
					],
					"callback": ""
				},
				{
					"title": "Omkar · The blank on the sketch",
					"text": "Omkar has drawn the helpers around his stage design. There is a small unnamed figure beside the arrows. He asks whether you want to add anything.",
					"choices": [
						[
							"Draw the notebook in its hand",
							"'There,' he says. 'The one who kept asking.' He means it fondly, not as a complaint.",
							"Omkar remembered my questions as something I brought to the group."
						],
						[
							"Leave the figure without a label",
							"He leaves it alone. Asha recognises who it is anyway from where it is standing.",
							"People recognised my place in the work even without a name beneath it."
						]
					],
					"phrase": [],
					"callback": "We made a plan more people could understand and use."
				},
				{
					"title": "Yusuf · The last check",
					"text": "The route is clear, there is a chair where Asha asked for one, and Omkar has finished before his own stop time. Yusuf suggests testing the path with an empty trolley.",
					"choices": [
						[
							"Walk the route with him",
							"One corner is tighter than it looked on paper. You move a chair and keep its comfortable spot."
						],
						[
							"Ask Asha to try the seating area",
							"She notices it is hard to hear from there. Omkar adjusts the speaker direction without simply making everything louder."
						]
					],
					"phrase": [
						"धन्यवाद।",
						"Dhanyavaad.",
						"Thank you. Here it is for a particular contribution.",
						[
							"dhanyavaad"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Omkar · Your own way of joining",
					"text": "The gathering is ready. Omkar explains where visitors can watch and where people participating in the ritual are gathering.",
					"choices": [
						[
							"Watch respectfully and ask before joining anything unfamiliar",
							"He stays beside you for the first part, then leaves you free to decide."
						],
						[
							"Help Yusuf welcome people at the edge",
							"He gives you the simple route map. You are participating in the community work without pretending a belief."
						]
					],
					"phrase": [
						"पूछना है।",
						"Poochhna hai.",
						"I want to ask something. Asking is welcome.",
						[
							"poochhna"
						]
					],
					"callback": ""
				},
				{
					"title": "Asha · A portion and a question",
					"text": "Asha offers food and names its ingredients. Someone beside you declines; she puts the plate back without comment.",
					"choices": [
						[
							"Choose after checking the ingredients",
							"You take what suits you. Asha keeps the serving spoon with the right dish."
						],
						[
							"Say thanks and stay for the conversation",
							"Asha asks about your notebook. The food was an offer, not an entrance fee."
						]
					],
					"phrase": [
						"थोड़ा।",
						"Thoda.",
						"A little. It helps communicate a comfortable amount.",
						[
							"thoda"
						]
					],
					"callback": ""
				},
				{
					"title": "Omkar · The lights in his drawing",
					"text": "Omkar compares the finished setup to his sketch. They are not identical; the changes show where other people had a say.",
					"choices": [
						[
							"Keep the map with the added seating",
							"Your memory is a design that changed because people spoke.",
							"The lane held different languages, beliefs and needs. Asking made room for them."
						],
						[
							"Remember Omkar showing his own work",
							"You draw a screwdriver beside a pencil. One person can be more than the job everyone brings them.",
							"Omkar showed me the work he wanted to make, not only the repairs people expected."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"tokyo": {
		"title": "What the note doesn't say",
		"return": "Setsuko remembers where you stood at the counter. Haru shows you a new paper design; Mr Mori asks whether your wish needs revising.",
		"outings": [
			[
				"asakusa",
				"TokyoAsakusa.tscn"
			],
			[
				"ueno",
				"TokyoUeno.tscn"
			],
			[
				"yanaka",
				"TokyoYanaka.tscn"
			],
			[
				"jinbocho",
				"TokyoJinbocho.tscn"
			],
			[
				"shinbashi",
				"TokyoShinbashi.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Setsuko · Two cups that look alike",
					"text": "Setsuko has set two cups on the kitchenware counter. Haru likes the fine edge of one. Mr Mori asks whether the other is easier to hold with his stiff fingers.\n\nSetsuko lets him try both before explaining the price. She notices you studying them and turns the handles towards you.",
					"choices": [
						[
							"Ask Mr Mori which feels better",
							"He chooses the less delicate-looking cup. Haru tries it and understands why. There is no single best cup apart from a person using it."
						],
						[
							"Ask Setsuko to demonstrate the grip",
							"She holds one loosely and one firmly. You point to the difference. Her explanation becomes an action you can follow."
						]
					],
					"phrase": [
						"見せてください。",
						"Misete kudasai.",
						"Please show me.",
						[
							"misete",
							"kudasai"
						]
					],
					"callback": ""
				},
				{
					"title": "Haru · A reply worth checking",
					"text": "Haru asks Mr Mori if he wants his old cup wrapped. He says 'daijōbu' while reaching into his bag. Haru pauses: did he mean yes, fine, or no, not needed?\n\nSetsuko points to the bag. 'Ask him.' She does not offer a rule that can answer for every person.",
					"choices": [
						[
							"Hold up the wrapping and ask 'irimasu ka?'",
							"Mr Mori shows the padded pouch he brought. No wrapping needed this time. Haru thanks you for checking.",
							"We checked Mr Mori's reply instead of treating one word as a universal code."
						],
						[
							"Point to the pouch, then the cup, to confirm",
							"He nods and puts the cup safely inside. The gesture answered the practical question.",
							"A clear gesture helped us confirm what Mr Mori actually wanted."
						]
					],
					"phrase": [
						"いりますか？",
						"Irimasu ka?",
						"Do you need it? Point to what you are offering.",
						[
							"irimasu",
							"ka"
						]
					],
					"callback": ""
				},
				{
					"title": "Setsuko · A strip of paper",
					"text": "Setsuko has a bundle of paper strips for Tanabata. Haru is preparing a place to hang them. She gives you one blank strip and points towards Asakusa.\n\nTry a neighbourhood activity before coming back. You can learn what people do with the strips without deciding your own wish immediately.",
					"choices": [
						[
							"Ask what the paper is called",
							"'Tanzaku.' She shows you its shape and lets you hold the pen without waiting for an answer."
						],
						[
							"Keep it blank for now",
							"She slides it into your notebook so it will not crease. An unfinished thought can travel with you."
						]
					],
					"phrase": [
						"短冊",
						"Tanzaku.",
						"A narrow strip of paper; these are being used for Tanabata wishes.",
						[
							"tanzaku"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Haru · Public wishes, private thoughts",
					"text": "Haru wants visitors to read the wishes. Mr Mori has folded his strip so the writing is hidden. Haru thinks people might miss the point of the display.\n\nSetsuko asks a smaller question: who owns the wish?",
					"choices": [
						[
							"Ask Mr Mori whether he wants it visible",
							"He wants to hang it folded. Haru finds a way to tie it without opening it.",
							"Mr Mori's wish belonged to him even when the paper was part of a shared display."
						],
						[
							"Suggest space for blank or folded strips too",
							"Setsuko places one beside the examples. Participation no longer promises public explanation.",
							"We made room for a private wish inside a public celebration."
						]
					],
					"phrase": [
						"読んでもいいですか？",
						"Yonde mo ii desu ka?",
						"May I read it? The answer may be no.",
						[
							"yonde",
							"ii",
							"desu"
						]
					],
					"callback": ""
				},
				{
					"title": "Setsuko · Not always patient",
					"text": "A supplier is late. Setsuko is annoyed, and says so directly. Haru laughs at your surprised face. 'She can do that.'\n\nSetsuko turns back to you. She asks whether you thought her quiet way at the counter meant she never gets angry.",
					"choices": [
						[
							"Admit that you did",
							"'Different moment,' she says, showing two pages of the same calendar. One impression need not become a rule about her."
						],
						[
							"Ask if she wants you to come back later",
							"She chooses to finish this conversation first. You gave her an option instead of deciding her feelings for her."
						]
					],
					"phrase": [
						"あとで？",
						"Ato de?",
						"Later? Check the timing; do not assume.",
						[
							"ato",
							"de"
						]
					],
					"callback": ""
				},
				{
					"title": "Haru · Another way to look",
					"text": "Haru recommends looking at the wishes, bookshops and ordinary counters beyond this street. Setsuko adds, 'People first. Rules after, if you still need them.'\n\nTry three neighbourhood activities in total, including Asakusa, then return. Watching and asking both count.",
					"choices": [
						[
							"Take the blank strip with you",
							"You can leave it blank until something belongs on it."
						],
						[
							"Ask for a route with a quiet stop",
							"Haru marks one in your journal. There is no timed challenge attached to getting there."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Mr Mori · Where the paper hangs",
					"text": "Haru has tied the first wishes too high for Mr Mori to reach. Mr Mori starts to say it does not matter, then looks at the strip in his hand.",
					"choices": [
						[
							"Ask where he would like to hang it",
							"He chooses a lower branch. Haru moves the tie without making a ceremony of the correction."
						],
						[
							"Lower a spare branch and invite everyone to use it",
							"Several people choose the lower one. A change made for one person turns out to help more than one."
						]
					],
					"phrase": [
						"ここでいいですか？",
						"Koko de ii desu ka?",
						"Is here all right? Let the person confirm the place.",
						[
							"koko"
						]
					],
					"callback": ""
				},
				{
					"title": "Setsuko · Something to write",
					"text": "Setsuko offers to write your name on the back of the strip. You explain, with pauses and pictures, that your people did not use names in that way.\n\nShe sets the pen between you. 'Then we needn't put one there.'",
					"choices": [
						[
							"Write a wish without signing it",
							"Haru helps with the characters only when you point for help. The sentence remains yours.",
							"Setsuko left the decision about a name with me."
						],
						[
							"Draw the people who helped with the display",
							"Mr Mori recognises himself from the low branch. The drawing says something your vocabulary could not yet hold.",
							"My drawing could say whom I wanted to remember before I had all the words."
						]
					],
					"phrase": [],
					"callback": "We made room for private thoughts and different ways of participating."
				},
				{
					"title": "Haru · No perfect sentence required",
					"text": "Your strip is ready, or deliberately blank. Haru asks if you want it on the display for the gathering. Setsuko points to your notebook as another possible home for it.",
					"choices": [
						[
							"Choose to hang it",
							"Haru saves a place you can reach. Return when ready to join the evening."
						],
						[
							"Keep it in the notebook and come to watch",
							"'Mochiron.' Of course. A place at the gathering does not depend on displaying something private."
						]
					],
					"phrase": [
						"もちろん。",
						"Mochiron.",
						"Of course. Here it reassures you that watching is welcome.",
						[
							"mochiron"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Haru · Before tying the knot",
					"text": "Haru holds up your strip and waits. Nothing goes on the display just because somebody prepared it.",
					"choices": [
						[
							"Hang it where you chose",
							"The low branch bends slightly and settles. Mr Mori makes room beside his folded wish."
						],
						[
							"Change your mind and keep it",
							"Haru hands it back immediately. Setsuko passes you a cup of water. The evening continues."
						]
					],
					"phrase": [
						"やめておきます。",
						"Yamete okimasu.",
						"I'll leave it for now. You may change your mind.",
						[
							"yamete",
							"okimasu"
						]
					],
					"callback": ""
				},
				{
					"title": "Mr Mori · A question beside the bamboo",
					"text": "Mr Mori looks at a nearby strip, then stops before reading it. He asks its owner. Haru notices and does the same.",
					"choices": [
						[
							"Ask before reading another wish",
							"Its owner chooses to explain it to you, adding details the writing alone did not show."
						],
						[
							"Look at the colours and leave the words private",
							"There is plenty to notice without treating every visible thing as yours to inspect."
						]
					],
					"phrase": [
						"ありがとう。",
						"Arigatou.",
						"Thank you.",
						[
							"arigatou"
						]
					],
					"callback": ""
				},
				{
					"title": "Setsuko · What stayed with me",
					"text": "Setsuko closes the shop door behind the little gathering. The supplier finally arrives; this time she laughs.",
					"choices": [
						[
							"Remember the checked reply",
							"A single useful question did more than a list of rules about everybody in the city.",
							"Setsuko taught me to check what someone means, even when I recognise the word."
						],
						[
							"Remember the low branch",
							"You draw a small branch at the edge of your page. It carries several different kinds of wish.",
							"Haru lowered a branch, and the gathering became easier to join."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	},
	"mexico": {
		"title": "What we choose to remember",
		"return": "Rocío recognises your notebook across the flowers. Lucía has a new drawing. Tomás offers a chair and waits to see whether you want to talk.",
		"outings": [
			[
				"merced",
				"MexicoMerced.tscn"
			],
			[
				"coyoacan",
				"MexicoCoyoacan.tscn"
			],
			[
				"roma",
				"MexicoRoma.tscn"
			],
			[
				"condesa",
				"MexicoCondesa.tscn"
			],
			[
				"juarez",
				"MexicoJuarez.tscn"
			]
		],
		"chapters": [
			[
				{
					"title": "Rocío · An armful of orange",
					"text": "Rocío lifts a bundle of cempasúchil. Lucía wants enough flowers to cover the whole table; Tomás wants space for a photograph and a favourite cup.\n\nThey are preparing a family remembrance gathering. Rocío tells you that this is their family's way of arranging it. She asks what you notice.",
					"choices": [
						[
							"Point to the cup and ask who used it",
							"Tomás smiles, but does not tell the story yet. Rocío leaves the question there instead of answering for him."
						],
						[
							"Ask where the photograph will go",
							"Lucía clears the centre. The flowers frame the picture instead of hiding it."
						]
					],
					"phrase": [
						"¿Aquí?",
						"Aqui?",
						"Here? Check a placement before moving somebody's meaningful object.",
						[
							"aquí"
						]
					],
					"callback": ""
				},
				{
					"title": "Lucía · Pretty isn't the whole purpose",
					"text": "Lucía likes the symmetry of two identical flower bundles. Tomás has brought one slightly battered cup. It refuses to match anything.\n\nRocío sets it down anyway. 'That's the cup.'",
					"choices": [
						[
							"Make space around it rather than replacing it",
							"Lucía tilts the flowers until the arrangement works around the object. Beauty can support a memory instead of tidying it away.",
							"We arranged the flowers around the cup instead of replacing the thing that mattered."
						],
						[
							"Ask Tomás where he wants it",
							"He chooses the place nearest the photograph. The decision takes a second once the right person is asked.",
							"Tomás chose where his cup belonged. The arrangement followed the memory."
						]
					],
					"phrase": [
						"¿Dónde?",
						"Donde?",
						"Where? A practical question with room for someone else's preference.",
						[
							"dónde"
						]
					],
					"callback": ""
				},
				{
					"title": "Rocío · The word on the bundle",
					"text": "Rocío says 'cempasúchil' slowly. The word is longer than your drawing of the flower. She repeats it without making you repeat it perfectly.\n\nTry a neighbourhood activity before coming back. At La Merced you can see how the flowers are sold and ask about the amounts.",
					"choices": [
						[
							"Copy the sound beside a drawing",
							"She circles the drawing. Recognising the flower will help even if the word takes longer."
						],
						[
							"Ask her to show a small and a large bundle",
							"She lays them side by side. Numbers and quantities suddenly refer to something you can hold."
						]
					],
					"phrase": [
						"Cempasúchil.",
						"Cempasuchil.",
						"The marigold being used in this family's arrangement.",
						[
							"cempasúchil"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Tomás · A story he hasn't offered",
					"text": "Lucía wants to record Tomás explaining the photograph. He says he would rather not. Rocío puts her own phone away first.\n\nLucía wanted a memory to keep. Tomás wants to decide which memories he shares.",
					"choices": [
						[
							"Suggest asking what he would be happy to record",
							"He offers to explain the flower arrangement, leaving the photograph's story private.",
							"We asked what Tomás wanted to share instead of treating his memory as material to collect."
						],
						[
							"Suggest drawing the table without recording him",
							"Lucía finds her pencils. Tomás points out the cup's chipped handle and lets her draw it.",
							"Lucía found another way to remember the day without recording Tomás."
						]
					],
					"phrase": [
						"¿Puedo?",
						"Puedo?",
						"May I? Name or show what you want to do, and accept the answer.",
						[
							"puedo"
						]
					],
					"callback": ""
				},
				{
					"title": "Rocío · Laughter beside grief",
					"text": "Tomás tells an unexpectedly ridiculous story about the person in the photograph burning dinner. Lucía laughs, then looks worried that she should not have.\n\nRocío laughs too. A moment later Tomás is quiet. Neither expression cancels the other.",
					"choices": [
						[
							"Follow their lead without trying to fix the mood",
							"You listen when the story pauses. Tomás starts again when he wants."
						],
						[
							"Ask whether he would like company or a moment alone",
							"He asks you to stay. Quiet company is a clear enough answer."
						]
					],
					"phrase": [
						"¿Te acompaño?",
						"Te acompano?",
						"Would you like me to stay with you? Let the answer guide you.",
						[
							"acompaño"
						]
					],
					"callback": ""
				},
				{
					"title": "Lucía · Other streets, other stories",
					"text": "Lucía wants to know what you have seen around the city. Rocío says not every family will make the same table, or celebrate in the same way.\n\nTry three different neighbourhood activities in total, including La Merced, then return. You can ask and observe; no purchase is required.",
					"choices": [
						[
							"Look for one thing that surprises your first impression",
							"You leave an empty line beneath your earlier notes so there is room for a revision."
						],
						[
							"Ask for an easy route through the neighbourhoods",
							"Rocío points out the connection. Your pass covers the travel; bring back what you notice."
						]
					],
					"phrase": [],
					"callback": ""
				}
			],
			[
				{
					"title": "Rocío · Who belongs in the photograph?",
					"text": "Lucía suggests a picture of the helpers when the table is finished. Tomás wants to stand aside. You are not sure whether you want to be in it either.",
					"choices": [
						[
							"Ask everyone separately before arranging the picture",
							"The people who want to join stand together. Nobody is pulled back into the frame."
						],
						[
							"Suggest photographing the finished table instead",
							"Rocío checks that the private photograph may be included before lifting the phone. Consent still applies when the subject is an object with somebody's story attached."
						]
					],
					"phrase": [
						"Sin foto, gracias.",
						"",
						"No photo, thank you. A complete and reasonable boundary.",
						[
							"sin",
							"foto",
							"gracias"
						]
					],
					"callback": ""
				},
				{
					"title": "Lucía · The person without a name",
					"text": "Lucía is signing the drawing. She asks how to spell your name. You show her the blank spaces in your notebook.\n\n'Not forgotten?' she asks. You shake your head. Never given.",
					"choices": [
						[
							"Ask her to draw your notebook beside the signatures",
							"She draws it open. Rocío says she would know whose it was anywhere.",
							"Lucía could identify my notebook even where a signature was missing."
						],
						[
							"Leave your space empty",
							"Tomás taps the table. You are present without having to fill every blank.",
							"Tomás reminded me that an empty label does not make a person absent."
						]
					],
					"phrase": [],
					"callback": "We let people choose what to share and what to keep."
				},
				{
					"title": "Tomás · An invitation to stay",
					"text": "Tomás brings another chair. Rocío explains what will happen at the Día de Muertos gathering and asks how you would like to take part.",
					"choices": [
						[
							"Offer to help with the flowers",
							"She shows you which stems still need water. The task is shared, not the price of being invited."
						],
						[
							"Ask to sit with them and watch",
							"Tomás places the chair beside his. You can return whenever ready; nobody is testing your knowledge of the occasion."
						]
					],
					"phrase": [
						"Con permiso.",
						"",
						"With your permission / excuse me. Say it while checking the space or action.",
						[
							"con",
							"permiso"
						]
					],
					"callback": ""
				}
			],
			[
				{
					"title": "Rocío · Before the flowers move",
					"text": "Rocío hands you the final stems. One side of the table has been left open on purpose, for the cup and a person who will bring a photograph later.",
					"choices": [
						[
							"Ask where the flowers are wanted",
							"She points to the outer edge. The open space stays available."
						],
						[
							"Hold the stems while Lucía checks her drawing",
							"Lucía notices the gap has a purpose. Her drawing keeps it rather than filling it."
						]
					],
					"phrase": [
						"¿Cuántas?",
						"Cuantas?",
						"How many? Here you are asking about flowers.",
						[
							"cuántas"
						]
					],
					"callback": ""
				},
				{
					"title": "Tomás · A memory offered freely",
					"text": "Tomás begins a story without being asked to perform it. Lucía sets down her phone. Rocío offers food and explains what is in it.",
					"choices": [
						[
							"Listen with them",
							"The story belongs to this small group for now. You can remember it without taking a recording."
						],
						[
							"Thank him, then choose whether to eat",
							"Rocío accepts your choice. Sharing the gathering does not require accepting every dish."
						]
					],
					"phrase": [
						"Gracias por contarme.",
						"",
						"Thank you for telling me. The story was a gift, not something owed.",
						[
							"contarme"
						]
					],
					"callback": ""
				},
				{
					"title": "Lucía · The space in the drawing",
					"text": "Lucía gives you a copy. The cup is crooked, the flowers are bright, and there is a chair with your notebook on it.",
					"choices": [
						[
							"Keep the drawing",
							"A place can be recognised without a written name.",
							"Rocío's family made room for me without asking me to turn their memories into a spectacle."
						],
						[
							"Remember the story Tomás chose to tell",
							"You write only 'he chose to tell us'. The details can stay with the people who shared the evening.",
							"Tomás taught me that listening also means letting someone keep a story."
						]
					],
					"phrase": [],
					"callback": ""
				}
			]
		]
	}
}
