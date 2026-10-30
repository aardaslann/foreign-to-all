extends Node

const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")
# Each moment asks for a word the player has already worked out, next to a
# near miss that only knowing it in context avoids: the thesis in miniature.
# A choice is [id, label, icon]; an empty icon is an action, not an object.
# "repairs" answers each wrong choice in its own terms; "repair" is the rest.
const MOMENTS := {
	"ActivityBerlinSpati": {
		"person":"Rika", "name":"Rika", "language":"german", "word":"apfel", "written":"Apfel", "reach":128.0,
		"setup":"Rika is packing a neighbour's lunch. Beside the open bag she has left a handwritten note: Apfel. On the counter there is a roll, an apple, and a bottle whose label says Apfelsaft.",
		"choices":[["bread", "Slide the roll towards the bag", "bread"], ["apfelsaft", "Slide the Apfelsaft bottle towards the bag", "apfelsaft"], ["apple", "Slide the apple towards the bag", "apple"]],
		"correct":"apple", "hold":"bag",
		"repairs":{
			"apfelsaft":"Rika moves the bottle back and runs a finger along its label, Apfel and then Saft, one word built on another. Then she taps the note, where Apfel stands on its own."
		},
		"repair":"Rika leaves that beside the bag and taps the note again. There is no hurry.",
		"done":"Rika slips the apple into the lunch bag and folds the top. The Apfelsaft stays on the counter: the same word, made into something else. A word from the street outside has helped someone else get lunch ready.",
		"memory":"Packed an apple for Rika at the Späti, not the Apfelsaft."
	},
	"ActivityFerryDeck": {
		"person":"ferry_passenger", "name":"The passenger", "language":"turkish", "word":"çay", "written":"çay",
		"setup":"The passenger steadies a tray as the ferry rolls. Their companion's message reads: çay. On the tray: a tulip glass of dark red tea on its saucer, a sachet printed with an apple and the words elma çayı, and a bottle of water.",
		"choices":[["elma_cayi", "Pass the elma çayı sachet", "elma_cayi"], ["cay", "Pass the tulip glass", "cay"], ["water", "Pass the water bottle", "water"]],
		"correct":"cay", "hold":"cup_slim",
		"repairs":{
			"elma_cayi":"The passenger smiles and sets the sachet back down. Elma çayı is apple tea, sweet, and mostly sold to visitors. Çay on its own is the dark tea in the tulip glass, the one everybody here drinks."
		},
		"repair":"The passenger keeps that on the tray and tilts the phone towards the little glass. The steam is another clue.",
		"done":"The passenger takes the glass by its rim, saucer and all, and settles it beside their companion. Tea on Arda's tray, tea on a ferry: the same word in a different pair of hands.",
		"memory":"Passed çay to a passenger on the ferry, not the apple tea."
	},
	"ActivityLondonCharity": {
		"person":"charity_volunteer", "name":"The volunteer", "language":"english", "word":"give me a hand", "written":"Give me a hand?", "reach":100.0,
		"setup":"The volunteer's arms are full: a box held open against one hip, a stack of donated books leaning on the counter. A handwritten card propped against the stack reads: Give me a hand?",
		"choices":[["clap", "Give them a round of applause", ""], ["shake", "Offer your hand to shake", ""], ["book", "Steady the stack and pack the loose book", "book"]],
		"correct":"book", "hold":"box",
		"repairs":{
			"clap":"The volunteer laughs and nods at the leaning books. A big hand is applause; a hand on its own is help.",
			"shake":"Both of the volunteer's hands are busy with the box. They tip their head towards the books instead."
		},
		"repair":"The volunteer nods at the leaning books and the open box. The card is about a particular task.",
		"done":"The book fits and the volunteer can close the box. Val's request makes sense here too, with someone new and a different thing to carry.",
		"memory":"Gave a charity shop volunteer a hand with the books."
	},
	"ActivityParisTertre": {
		"person":"portrait_artist", "name":"The artist", "language":"french", "word":"après", "written":"Après", "reach":100.0,
		"setup":"A traveller offers the artist a wet portrait to wrap. The artist points to the glistening paint, then the empty drying clip. Après, she says, laying the wrapping paper beside it. Her next customer is already seated.",
		"choices":[["wrap", "Hold the paper open for the fresh portrait", ""], ["dry", "Clip the portrait up; leave the paper ready", ""], ["next", "Pass the wrapping paper to the next customer", ""]],
		"correct":"dry", "hold":"papers",
		"repair":"She lifts the paper clear of the wet paint, points to the drying clip, then the paper again. Two actions, in that order.",
		"done":"The portrait hangs where it can dry. The artist folds the paper ready for afterwards. Après was about Marcel's bread arriving after the meal began; here it saves a fresh painting from sticking to its wrapper.",
		"memory":"Left a portrait to dry before wrapping it. Après mattered to the artist too."
	},
	"ActivityMoscowStolovaya": {
		"person":"canteen_server", "name":"The server", "language":"russian", "word":"pochinit", "written":"Pochinit", "reach":155.0,
		"setup":"At the end of the counter, the server turns an old wooden tray over. One screw is loose. Beside it sit a screwdriver and a new tray still in its paper sleeve. Pochinit, the server says, keeping a hand on the old one.",
		"choices":[["repair", "Steady the old tray and pass the screwdriver", ""], ["replace", "Unwrap the new tray for this counter", ""], ["store", "Put the old tray aside for safekeeping", ""]],
		"correct":"repair", "hold":"tray",
		"repair":"The server nudges the loose handle, then holds out a hand towards the screwdriver. The tray is meant to go back into use.",
		"done":"A few turns, and the handle holds. The server tests it before loading the tray. A brooch at Viktor's bench and a tray here: pochinit keeps the familiar thing working.",
		"memory":"Helped the canteen server repair a tray rather than replace it."
	},
	"ActivityMumbaiMuseumGarden": {
		"person":"garden_sketcher", "name":"The sketcher", "language":"hindi", "word":"dheere", "written":"Dheere",
		"resident":{"id":"garden_sketcher", "feet":[330,565], "appearance":{"wear":"shirt"}},
		"setup":"A sketcher holds up a loose page for you to turn. The corner has caught under a clip. Dheere, she says, drawing one finger slowly through the air. Her other hand stays ready to catch the page.",
		"choices":[["later", "Leave the page for her to turn later", ""], ["fast", "Turn it in one clean movement", ""], ["slow", "Ease the corner free a little at a time", ""]],
		"correct":"slow", "hold":"papers",
		"repair":"She keeps her hand under the paper and repeats the slow movement. She is ready now; it is the pace she is changing.",
		"done":"The corner comes free without tearing. She turns to a drawing of the garden. Omkar slowed his speech for dheere; you slowed your hands. The same small word changed a different task.",
		"memory":"Turned a sketcher's caught page slowly, remembering dheere."
	},
	"ActivityTokyoBookshop": {
		"person":"bookshop_reader", "name":"The reader", "language":"japanese", "word":"mochiyasui", "written":"Mochiyasui",
		"resident":{"id":"bookshop_reader", "feet":[345,567], "appearance":{"wear":"jumper"}},
		"setup":"A reader is choosing a carrier for three heavy books. One has thin cord handles; the other has broad fabric loops. Mochiyasui? he asks, resting a loop across his fingers. Both bags are the same price.",
		"choices":[["cord", "Open the slim cord-handled bag", ""], ["loop", "Hold out the broad loops for him to try", ""], ["double", "Put both bags inside one another", ""]],
		"correct":"loop", "hold":"bag",
		"repair":"He curls his hand around the thin cord, then opens it again. He lays the broad loop across the same fingers and looks back at you.",
		"done":"He tries the weight, then nods and slips the books inside. At Setsuko's counter it was a cup handle. Here mochiyasui helps a different hand carry something home.",
		"memory":"Helped a reader find a carrier that was easy to hold, not just narrow."
	},
	"ActivityMexicoCoyoacanMarket": {
		"person":"market_packer", "name":"The stallholder", "language":"spanish_mx", "word":"taza", "written":"La taza",
		"resident":{"id":"market_packer", "feet":[385,575], "appearance":{"wear":"apron"}},
		"setup":"The stallholder is packing a small order. A cup, its saucer and a little jug stand on the cloth. La taza, she says, holding open a sleeve of paper and making space for a handle.",
		"choices":[["cup", "Slide the cup into the paper sleeve", ""], ["saucer", "Lay the saucer in the sleeve", ""], ["jug", "Pass the small jug by its handle", ""]],
		"correct":"cup", "hold":"cup_slim",
		"repair":"She keeps the sleeve open and points to the cup's rim. The jug has a spout; the saucer is what goes underneath.",
		"done":"The sleeve folds around the cup, with room left for its handle. Rocío's taza was important because of who had used it. This one belongs to somebody you have not met. The word still helps you take care of it.",
		"memory":"Packed a taza for a market stallholder, carrying the word beyond Rocío's table."
	}
}

var moment: Dictionary
var moment_id := ""
var actor: Node2D
var _busy := false
var _departing := false
var _choice: Node


func setup(place_id: String, residents: Array) -> void:
	if not MOMENTS.has(place_id): return
	moment_id = place_id
	moment = MOMENTS[place_id]
	for resident: Node2D in residents:
		if resident.get("id") == moment.person:
			actor = resident
			# Counter staff remain behind the original solid counter footprint.
			actor.interaction_reach = float(moment.get("reach", actor.REACH))
			actor.interacted.connect(_interact)
			actor.prompt_text = moment.written
			if completed(): actor.holding = moment.hold
			return


func completed() -> bool:
	return bool(GameState.world_flags.get("word_use_" + moment_id, false))


func eligible() -> bool:
	return not moment.is_empty() and NOTEBOOK.found(moment.language, moment.word) and not completed()


func _process(_delta: float) -> void:
	if is_instance_valid(actor): actor.talkable = eligible() and not _busy


func _interact(_person: String = "") -> void:
	if not eligible() or _busy or get_tree().paused: return
	_choice = get_tree().get_first_node_in_group("choice_panel")
	if _choice == null or _choice._open: return
	_busy = true
	_put_prompt_away()
	var rows: Array = []
	for option: Array in moment.choices:
		rows.append({"id":option[0], "label":option[1], "item":option[2]})
	rows.append({"id":"leave", "label":"Leave them to it"})
	_choice.open(moment.written, moment.setup, rows)
	var answer: String = await _choice.chosen
	if _departing: return
	if answer.is_empty() or answer == "leave":
		_busy = false
		return
	if answer != moment.correct:
		actor.act = "point"
		var repair: String = moment.get("repairs", {}).get(answer, moment.repair)
		_choice.open(moment.name, repair, [{"id":"retry", "label":"Look again"}, {"id":"leave", "label":"Leave them to it"}])
		var next: String = await _choice.chosen
		if _departing: return
		actor.act = "stand"
		_busy = false
		if next == "retry": _interact()
		return
	_complete()
	_choice.open(moment.name, moment.done, [{"id":"continue", "label":"Continue"}])
	await _choice.chosen
	if _departing: return
	actor.act = "stand"
	_busy = false


# The world pauses under the choice panel, so the resident's "[E] ... note"
# prompt would freeze where it was and peek out beside the panel. Its own
# update brings it back once the world moves again.
func _put_prompt_away() -> void:
	actor.talkable = false
	var prompt: Variant = actor.get("_prompt")
	if prompt is CanvasItem:
		(prompt as CanvasItem).visible = false


func _complete() -> void:
	if completed() or not eligible(): return
	GameState.world_flags["word_use_" + moment_id] = true
	NOTEBOOK.apply_in_context(moment.language, moment.word, moment_id, moment.memory)
	Journey.record("A word somewhere new", moment.memory)
	actor.holding = moment.hold
	actor.act = "nod"
	actor.talkable = false
	SaveManager.checkpoint()


func _exit_tree() -> void:
	_departing = true
	if _busy and is_instance_valid(_choice) and _choice._open:
		_choice._close("")
