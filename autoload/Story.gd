extends Node

# The spine: eight cities, eight people, eight holidays, and a name.
#
# See "Foreign to All/decisions/2026-08-29-the-storyline.md". The short of it:
# you are stranded and unreadable, and the game is about being let in. Learn a
# city's language far enough and one specific person becomes visible to you -
# they were always there, you could not hear them. Become their friend and you
# are invited to the most intimate thing a culture has, its holiday, and they
# walk you through it. At the end you choose one of the eight and ask them to
# name you, and every one of them gives you the same name in a different
# language: Foreign.
#
# The other twelve cities stay built and stay optional. They are where you
# live rather than where the plot is.

signal met(city: String)
signal befriended(city: String)
signal holiday_opened(city: String)
signal holiday_done(city: String)

# How the eight are drawn. Preloaded rather than reached for by class_name,
# like everything else here: the global class cache is the editor's, and every
# tool in this project runs headless with --script.
const CAST := preload("res://scenes/npc/Cast.gd")

# Latin script throughout: a word he cannot sound out is a box, not a word.
const MANDATORY := ["berlin", "london", "paris", "moscow", "istanbul",
	"mumbai", "tokyo", "mexico"]

# How much of the language has to land before you can hear them at all.
# GameState.FLUENCY_FRAGMENTS - about ten words you can actually use. Below
# that they are one more person on a street you cannot read.
const MEET_AT := 2

# How many conversations a friendship takes. Three: one to be a stranger who
# turned up twice, one to be a face, one to be somebody they would invite.
const ROUNDS := 3

const PEOPLE := {
"berlin": {
	"name": "Kerstin", "age": 57, "region": "mitte",
	"trade": "runs the Spati next to the hotel",
	"holiday": "Oktoberfest", "when": "the last Saturday in September",
	"gives": "Fremd",
},
"london": {
	"name": "Nadia", "age": 17, "region": "terrace",
	"trade": "sixth form, and the caff on Saturdays",
	"holiday": "Bonfire Night", "when": "the fifth of November",
	"gives": "Foreign",
},
"paris": {
	"name": "Odile", "age": 71, "region": "marais",
	"trade": "retired from a lycee, forty-one years in the same flat",
	"holiday": "14 Juillet", "when": "the fourteenth of July",
	"gives": "Etranger",
},
"moscow": {
	"name": "Viktor", "age": 46, "region": "basmanny",
	"trade": "the remont booth - shoes, zips, keys, watches",
	"holiday": "Maslenitsa", "when": "the week before Lent",
	"gives": "Chuzhoy",
},
"istanbul": {
	"name": "Arda", "age": 18, "region": "han",
	"trade": "the tea run through the han, thirty-one glasses an hour",
	"holiday": "Ramazan Bayrami", "when": "the three days after the fast",
	"gives": "Yabanci",
},
"mumbai": {
	"name": "Omkar", "age": 22, "region": "bhuleshwar",
	"trade": "phone repair, and the lane's Ganesh mandal",
	"holiday": "Ganesh Chaturthi", "when": "ten days at the end of the monsoon",
	"gives": "Pardesi",
},
"tokyo": {
	"name": "Setsuko", "age": 74, "region": "ueno",
	"trade": "a kitchenware shop on Kappabashi-dori",
	"holiday": "Tanabata", "when": "the first week of July",
	"gives": "Gaijin",
},
"mexico": {
	"name": "Rocio", "age": 45, "region": "coyoacan",
	"trade": "flowers in La Merced, six days a week",
	"holiday": "Dia de Muertos", "when": "the first and second of November",
	"gives": "Extranjero",
},

# ── The twelve that are not required ─────────────────────────────────────────
#
# Everything below here has the same depth as the eight above - a person, a
# trade, three conversations, an errand and a holiday - and none of it is on
# the critical path. MANDATORY is what can_end(), holidays_done() and focus()
# read, and it is still the original eight, so a player can finish this game
# without ever landing in Zurich and can also spend a season there.
#
# That distinction is the entire reason MANDATORY is a constant of its own and
# not PEOPLE.keys().

"saopaulo": {
	"name": "Neusa", "age": 61, "region": "bixiga",
	"trade": "the salao on the corner - thirty-one years with her hands on people",
	"holiday": "Festa Junina", "when": "the whole of June",
	"gives": "Gringo",
},
"zurich": {
	"name": "Beat", "age": 34, "region": "langstrasse",
	"trade": "the kiosk on the corner - papers, tram tickets, and the right bag",
	"holiday": "Sechselauten", "when": "the third Monday in April",
	"gives": "Auslander",
},
}


func is_mandatory(city: String) -> bool:
	return MANDATORY.has(city)


func person(city: String) -> Dictionary:
	return PEOPLE.get(city, {})


func person_name(city: String) -> String:
	return String(person(city).get("name", ""))


# What the figure looks like, in CharacterArt's terms.
#
# It used to be five integers per person indexing the shared palettes the
# anonymous crowd is drawn from - {"cut": "crop", "skin": 0, "hair": 5,
# "coat": 1, "accent": 3} - which is how eight people the whole game is about
# ended up wearing the crowd's coats in the crowd's colours. The designs now
# live in scenes/npc/Cast.gd, ported colour for colour off the design
# canvas they were drawn in, and they are still handed to exactly the same
# renderer as everybody else: one cast, one drawing, which is the rule this
# project has broken twice and will not break again.
func look_for(city: String) -> Dictionary:
	return CAST.look(city)


# ── The errand ───────────────────────────────────────────────────────────────
#
# Between being a face and being somebody they would invite, each of the eight
# asks for one thing. Two conversations and then a holiday was three beats for
# a whole city, and the middle one was the same beat twice: this is the part
# where the player has to go and USE the language rather than stand in front of
# somebody collecting it.
#
# Every errand is a district this city already has, and finishing it is
# finishing that district's own activity - the thing that district actually
# does, already written, already teaching its own words. Nothing new is built
# here: it is the game's own content, put on the critical path, which is where
# ninety-nine hand-researched activities should have been all along.
#
#   region   the district, and the world_flags key Services._local already sets
#   ask      what they say when they ask
#   step     what the log says
const ERRAND := {
# Her lunch. She names the place and not the dish, which is how somebody
# sends you for their lunch everywhere on earth, and Liberdade is where the
# Japanese-Brazilian groceries are - so the alien walks into a street of
# signs he can half read, four cities after Tokyo, and none of the rest of
# it is the same.
"saopaulo": {
	"region": "liberdade", "scene": "SaoPauloLiberdade.tscn",
	"title": "Her lunch, and she is specific",
	"step": "Go to Liberdade for Neusa's lunch. She named the place, not the dish",
	"ask": "She writes nothing down, says a street and a corner twice, and " +
		"puts her hand flat on my arm for the whole of it.

Liberdade. " +
		"She was still holding on when she finished, which I think means " +
		"she was not finished.",
},
# The Zurich one is a bag. It sounds like nothing and it is the single most
# reliable way for a newcomer here to get something wrong in public: household
# rubbish goes out in a specific municipal sack that you pay for, the fee is
# the printing on the bag, and putting your rubbish in any other bag is not
# frowned at, it is fined. He is being sent to buy one.
"zurich": {
	"region": "zurichwest", "scene": "ZurichWest.tscn",
	"title": "The right bag",
	"step": "Get the proper sack from the shop under the viaduct in Zurich West",
	"ask": "He holds up a blue bag with printing on it, then a supermarket " +
		"carrier, and shakes his head at the second one.

Somewhere there " +
		"is a correct bag, and I have been putting my rubbish out in the " +
		"wrong one for a fortnight, and nobody has said a word.",
},
# Berlin's is played in the street now (scenes/story/berlin/): a bag of bread
# rolls and a newspaper, taken from Kerstin's Späti in Mitte to Emil on his
# bench at Kollwitzplatz. Finished by the story, so it carries a `flag` rather
# than waiting on a district activity.
"berlin": {
	"region": "prenzlberg", "scene": "BerlinPrenzlberg.tscn",
	"flag": "berlin_errand_done",
	"title": "Für Emil",
	"step": "Take Kerstin's bag to Emil, on his bench at Kollwitzplatz",
	"ask": "She hands me a paper bag with bread rolls and a newspaper in it, " +
		"points north, and says a place twice.

Kollwitzplatz. Emil.",
},
"london": {
	"region": "highstreet", "scene": "LondonHighStreet.tscn",
	"title": "She wants a tea",
	"step": "Go to the caff on the high street and come back with a tea",
	"ask": "\"You couldn't, could you.\" It was not a question and it was " +
		"not a request, and somehow I have agreed to something.

" +
		"The caff. The one with the woman who calls everybody love.",
},
"paris": {
	"region": "belleville", "scene": "ParisBelleville.tscn",
	"title": "Bread, and the word before it",
	"step": "Buy bread in Belleville. Say bonjour first, and wait to be answered",
	"ask": "She writes nothing down. She says one word, waits until I repeat " +
		"it, and then says the rest.

Bonjour. Before anything. Before " +
		"the bread, before the money, before I am a person to be served.",
},
"moscow": {
	"region": "izmaylovo", "scene": "MoscowIzmaylovo.tscn",
	"title": "Something off a tray",
	"step": "Go out to the Vernisage at Izmaylovo and find what he described",
	"ask": "He draws it on the counter with a finger: round, small, a pin on " +
		"the back. Then he says a place, twice, until I have it.

" +
		"Izmaylovo. Trays of them, apparently.",
},
"istanbul": {
	"region": "carsi", "scene": "IstanbulCarsi.tscn",
	"title": "A loaf left hanging",
	"step": "Visit the bakery in the Çarşı and find out what the hanging tickets mean",
	"ask": "He will not let me pay for the tea. Instead he points towards the " +
		"bakery in the Çarşı and says two words slowly: askıda ekmek.\n\n" +
		"There are paper tickets behind the counter. He wants me to see " +
		"what happens to them, then come back.",
},
"mumbai": {
	"region": "chorbazaar", "scene": "MumbaiChorBazaar.tscn",
	"title": "The lane needs a thing",
	"step": "Go to Chor Bazaar and find what the mandal is short of",
	"ask": "He lists it in four languages inside one sentence and none of " +
		"them is the one I have been learning.

Chor Bazaar. Somebody " +
		"there has one. Somebody there has everything.",
},
"tokyo": {
	"region": "asakusa", "scene": "TokyoAsakusa.tscn",
	"title": "A wish, tied where it can be read",
	"step": "Go down to Asakusa and tie one to the bamboo",
	"ask": "She hands me a strip of paper and a pen and does not explain " +
		"either.

Asakusa. The bamboo is out already, and everybody " +
		"else seems to know what to write.",
},
"mexico": {
	"region": "merced", "scene": "MexicoMerced.tscn",
	"title": "An armful of orange",
	"step": "Go to La Merced for the cempasuchil, by weight, not by count",
	"ask": "She says the word for them four times, slowly, and it is longer " +
		"than any word I have.

La Merced. By the armful, and they are " +
		"sold by weight, which I did not expect of a flower.",
},
}


func errand_of(city: String) -> Dictionary:
	return ERRAND.get(city, {})


# Done when that district's own activity has been. Services._local sets this
# flag; nothing here has to know what the activity was.
func errand_done(city: String) -> bool:
	var e: Dictionary = errand_of(city)
	if e.is_empty():
		return true
	if e.has("flag"):
		return bool(GameState.world_flags.get(String(e["flag"]), false))
	return bool(GameState.world_flags.get(
		"spot_" + String(e.get("region", "")), false))


# ── Where the player is up to ────────────────────────────────────────────────
# Kept in GameState.world_flags so it saves and loads with everything else,
# rather than in a parallel store that a load would quietly forget.

func _flag(city: String, what: String) -> String:
	return "story_" + what + "_" + city


func rounds_done(city: String) -> int:
	return int(GameState.world_flags.get(_flag(city, "rounds"), 0))


func has_met(city: String) -> bool:
	return bool(GameState.world_flags.get(_flag(city, "met"), false))


func is_friend(city: String) -> bool:
	return rounds_done(city) >= ROUNDS


func holiday_seen(city: String) -> bool:
	return bool(GameState.world_flags.get(_flag(city, "holiday"), false))


# Can this city's person be found yet? Not a threshold on time or on money -
# on whether enough of their language has landed that you could hear them.
#
# The test is PEOPLE, not MANDATORY. It was MANDATORY for as long as the eight
# were the only ones written, and the day Beat went into PEOPLE that line
# quietly made him unreachable: KeyNPC hides itself until can_meet() is true,
# so an optional city's person was a design, a trade, an errand and a holiday
# behind a door that could not open. MANDATORY gates the ENDING. It was never
# meant to gate whether somebody exists.
func can_meet(city: String) -> bool:
	if person(city).is_empty() or has_met(city):
		return false
	if is_mandatory(city):
		return true
	var lang: String = String(GameState.CITIES.get(city, {}).get("language", ""))
	return GameState.fluency(lang) >= MEET_AT


func mark_met(city: String) -> void:
	GameState.world_flags[_flag(city, "met")] = true
	met.emit(city)
	guide()


func add_round(city: String) -> void:
	var n: int = rounds_done(city) + 1
	GameState.world_flags[_flag(city, "rounds")] = n
	if n == ROUNDS:
		befriended.emit(city)
		holiday_opened.emit(city)
	# The invitation is the thread's business, not the quest log's. It used to
	# be opened by a QuestLog signal handler, so a save loaded without that UI
	# alive - or the tool that walks the storyline - never got invited at all.
	guide()


func mark_holiday(city: String) -> void:
	GameState.world_flags[_flag(city, "holiday")] = true
	holiday_done.emit(city)
	guide()


# Is the city dressed for its holiday right now? True from the moment the
# friendship completes until the walk through it is finished - so the
# decorations go up because somebody invited you, not on a calendar you
# cannot see.
func holiday_on(city: String) -> bool:
	return is_friend(city) and not holiday_seen(city)


func holidays_done() -> int:
	var n: int = 0
	for c: String in MANDATORY:
		if holiday_seen(c):
			n += 1
	return n


# Everything done, and the field in Berlin has something in it again.
func can_end() -> bool:
	return holidays_done() >= MANDATORY.size()


# Who you asked to name you, and what they called you.
func namer() -> String:
	return String(GameState.world_flags.get("story_namer", ""))


func given_name() -> String:
	var c: String = namer()
	return String(person(c).get("gives", "")) if not c.is_empty() else ""


func set_namer(city: String) -> void:
	GameState.world_flags["story_namer"] = city


# ── The thread ────────────────────────────────────────────────────────────────
#
# A player must never have to guess what this game wants from them.
#
# Up to the hotel room there was a chain — buy bread, get a map, find a bed —
# and after the room it stopped dead. The next thing that happens in this game
# is that somebody becomes visible to you once enough of their language has
# landed, and NOTHING said so: no quest, no hint, no arrow. You woke up in a
# paid room in a city you could not read with an empty log, and the only way
# forward was to guess that wandering and listening was the mechanic.
#
# guide() closes that. It is derived from the world rather than fired by
# events: it looks at what is true and makes sure exactly one thing is being
# asked, and that the thing has somewhere the arrow can point. Being derived
# means a save from before any of this existed picks up the right thread, and
# that no path through the game can leave the log empty — including the ones
# that skip the intro, arrive by dev console, or do the eight out of order.
#
# The order of MANDATORY is a suggestion, not a rail. Stand in any of the
# eight and the thread is about the city you are standing in.

# Where the city's person is, where its language is loudest, and the way out.
const SCENE := {
	"berlin": "Mitte.tscn", "london": "LondonTerrace.tscn",
	"paris": "ParisMarais.tscn", "moscow": "MoscowBasmanny.tscn",
	"istanbul": "IstanbulHan.tscn", "mumbai": "MumbaiBhuleshwar.tscn",
	"tokyo": "TokyoUeno.tscn", "mexico": "MexicoCoyoacan.tscn",
	"saopaulo": "SaoPauloBixiga.tscn",
	"zurich": "ZurichLangstrasse.tscn",
}

# The market. Every one of these is the real one: Ameyoko under the tracks,
# the Vernisage at Izmaylovo, La Merced, Chor Bazaar, the Kapalicarsi. A
# market is where a language is spoken at you loudest and most repetitively,
# by people who need you to understand, which is the fastest place on earth
# to pick up twenty words.
const MARKET := {
	"berlin": "Kiez.tscn", "london": "LondonHighStreet.tscn",
	"paris": "ParisBelleville.tscn", "moscow": "MoscowIzmaylovo.tscn",
	"istanbul": "IstanbulCarsi.tscn", "mumbai": "MumbaiChorBazaar.tscn",
	"tokyo": "TokyoUeno.tscn", "mexico": "MexicoMerced.tscn",
}

# All twenty, not the eight. _fly() looks this up by the city you are STANDING
# in - "get to the airport" is a sentence about where your feet are - and the
# fallback for a miss is Berlin's Airport.tscn. So for as long as this table
# held only the eight, every one of the twelve pointed the player at a terminal
# on the other side of the world: stand in Seoul, be told to fly to Paris, and
# the arrow aims at Berlin Brandenburg.
const AIRPORT := {
	"berlin": "Airport.tscn", "london": "LondonAirport.tscn",
	"paris": "ParisAirport.tscn", "moscow": "MoscowAirport.tscn",
	"istanbul": "IstanbulHavalimani.tscn", "mumbai": "MumbaiAirport.tscn",
	"tokyo": "TokyoAirport.tscn", "mexico": "MexicoAirport.tscn",
	"zurich": "ZurichAirport.tscn", "hanoi": "HanoiAirport.tscn",
	"rome": "RomeAirport.tscn", "saopaulo": "SaoPauloAirport.tscn",
	"dakar": "DakarAirport.tscn", "tbilisi": "TbilisiAirport.tscn",
	"seoul": "SeoulAirport.tscn", "lapaz": "LaPazAirport.tscn",
	"sydney": "SydneyAirport.tscn", "honolulu": "HonoluluAirport.tscn",
	"newyork": "NewYorkAirport.tscn", "toronto": "TorontoAirport.tscn",
}

const JOB_BOARD := "res://scenes/world/MitteOst.tscn"
# The pod lies in the Kiez. WreckSite.tscn is only the pod itself, instanced in
# that scene, so pointing the arrow at it pointed at a place no route reaches.
const FIELD := "res://scenes/world/Kiez.tscn"

var _guiding: bool = false


static func path(file: String) -> String:
	return "res://scenes/world/" + file


# Which of the eight the thread is currently about. The one you are standing
# in, if it is one of them and is not finished; otherwise the next unfinished
# in order.
func focus() -> String:
	var here: String = GameState.city
	if is_mandatory(here) and not holiday_seen(here):
		return here
	for c: String in MANDATORY:
		if not holiday_seen(c):
			return c
	return ""


func guide() -> void:
	# Ticking a step calls back in here. Once through is enough.
	if _guiding:
		return
	_guiding = true
	_guide()
	_guiding = false


func _guide() -> void:
	# Berlin's intro owns its thread until the bed is found. A player who
	# travels early still gets the destination city's own story guidance.
	if GameState.city == "berlin" and not GameState.quests.has("find_bed"):
		return
	if GameState.city == "berlin" and not bool(Dictionary(GameState.quests["find_bed"]).get("completed", false)):
		return
	_settle()
	if is_mandatory(GameState.city):
		Journey.guide(GameState.city)
		if not holiday_seen(GameState.city):
			return
	_open()
	_side()


# Tick every step whose condition is now true, whichever quest it is on.
#
# Doing this only inside the branch that opened a quest is why the log filled
# up: `earn_keep` could only be ticked while the player still had no work, and
# `learn_berlin` only while Berlin still could not hear them - so the moment
# each one was actually satisfied, the code that would have closed it stopped
# running. By the eighth city fifteen finished quests were still open. Ticking
# is separate from opening now, and reads only the world.
func _settle() -> void:
	if GameState.quests.has("earn_keep"):
		if not GameState.active_job.is_empty() or not GameState.jobs_done.is_empty():
			GameState.complete_quest_step("earn_keep", 0)
		if not GameState.jobs_done.is_empty():
			GameState.complete_quest_step("earn_keep", 1)
	# Every city with a person, not only the eight. Ticking reads the world and
	# touches a quest only if it is open, so a city whose quests were never
	# started costs one dictionary lookup - and an optional city whose quests
	# WERE started used to have no way of ever closing them.
	for c: String in PEOPLE:
		var lang: String = String(GameState.CITIES.get(c, {}).get("language", ""))
		var need: int = int(GameState.FLUENCY_STEPS[MEET_AT - 1])
		if GameState.quests.has("learn_" + c) 				and (GameState.words_usable(lang) >= need or has_met(c)):
			GameState.complete_quest_step("learn_" + c, 0)
		if GameState.quests.has("meet_" + c):
			if has_met(c):
				GameState.complete_quest_step("meet_" + c, 0)
			var r: int = rounds_done(c)
			if r >= 2:
				GameState.complete_quest_step("meet_" + c, 1)
			if r >= ROUNDS:
				GameState.complete_quest_step("meet_" + c, 2)
		if GameState.quests.has("errand_" + c):
			if errand_done(c):
				GameState.complete_quest_step("errand_" + c, 0)
			if rounds_done(c) >= ROUNDS:
				GameState.complete_last_step("errand_" + c)
		if GameState.quests.has("holiday_" + c) and holiday_seen(c):
			GameState.complete_last_step("holiday_" + c)
	for id: String in GameState.quests.keys():
		var q: Dictionary = GameState.quests[id]
		if bool(q.get("completed", false)):
			continue
		# "on_to_<city>" named one country as the next chapter. The order is
		# the player's, so those are closed and _onward() asks instead.
		if id.begins_with("on_to_"):
			for st: Dictionary in q.get("steps", []):
				st["done"] = true
			q["completed"] = true
			GameState.quest_updated.emit(id)
		# Landing in any city whose story is unfinished is the journey onward.
		elif id.begins_with("onward_") and is_mandatory(GameState.city) \
				and not holiday_seen(GameState.city):
			GameState.complete_quest_step(id, 0)
			GameState.complete_quest_step(id, 1)
	if GameState.quests.has("the_name"):
		# Going back means a visit after the ending opened: every player has
		# already stood in the field once, at the very start. A loaded player
		# can also already be there without recording another visit.
		var ending: Dictionary = GameState.quests["the_name"]
		var current := get_tree().current_scene
		var at_field: bool = can_end() and GameState.city == "berlin" \
				and current != null and current.scene_file_path == FIELD
		if not namer().is_empty():
			# A received name proves the whole finale, including older saves
			# whose return-to-field step never completed.
			for i in range(ending.get("steps", []).size()):
				GameState.complete_quest_step("the_name", i)
		elif at_field or int(GameState.region_visits.get("wreck", 0)) > 0 or (ending.has("field_visits")
				and int(GameState.region_visits.get("kiez", 0)) > int(ending["field_visits"])):
			GameState.complete_quest_step("the_name", 0)


# The one thing being asked, right now.
func _open() -> void:
	var c: String = focus()
	if c.is_empty():
		_the_name()
		return
	# Nothing in this game is free and the room is paid for one night. Work
	# is the first thing a stranger has to solve, and it is also where the
	# language stops being decoration.
	if GameState.city != c:
		_onward()
		return
	if not has_met(c):
		if can_meet(c):
			_find(c)
		else:
			_learn(c)
		return
	if not is_friend(c):
		# Two conversations in, they ask for something. Until it is done the
		# third conversation is not available: this is the part of a city
		# where the player has to go and USE the language rather than stand
		# in front of somebody collecting it.
		if rounds_done(c) >= 2 and not errand_done(c):
			_errand(c)
		else:
			_find(c)
		return
	if not holiday_seen(c):
		_holiday(c)


# The city you are standing in, when it is one of the twelve.
#
# _open() is the THREAD and the thread is the eight: it asks exactly one thing
# and that thing is always on the critical path, which is why focus() only
# ever returns a mandatory city. But a player who lands in Zurich and stays
# there has a person in front of them, an errand and a day they can be invited
# to, and none of it appeared in the log - so living in an optional city meant
# doing the whole arc by guesswork while the log talked about somewhere else.
#
# _side() runs after _open() and adds the local arc alongside it. It never
# competes: the thread's quest is still open, still says where the plot is,
# and this one is about the street you actually chose to be on.
#
# Deliberately no _learn() here. The game does not send you to Zurich to
# collect twenty words - you either fell into the language because you stayed,
# or you did not, and twelve "Make yourself heard" quests in one log would
# turn the optional half of the game into a checklist.
func _side() -> void:
	var c: String = GameState.city
	if is_mandatory(c) or person(c).is_empty():
		return
	if not has_met(c):
		if can_meet(c):
			_find(c)
		return
	if not is_friend(c):
		if rounds_done(c) >= 2 and not errand_done(c):
			_errand(c)
		else:
			_find(c)
		return
	if not holiday_seen(c):
		_holiday(c)


func _earn() -> void:
	GameState.start_quest("earn_keep", "The room is paid for one night",
		["Find where work is posted", "Take a job, and finish it"],
		[JOB_BOARD, JOB_BOARD])
	if not GameState.active_job.is_empty() or not GameState.jobs_done.is_empty():
		GameState.complete_quest_step("earn_keep", 0)
	if not GameState.jobs_done.is_empty():
		GameState.complete_quest_step("earn_keep", 1)


# The gate the whole game turns on, said out loud.
#
# It used to be a silent threshold: reach FLUENCY_FRAGMENTS in the local
# language and a person appears. A threshold nobody is told about is not a
# gate, it is a secret. The quest names the language, names the number, and
# points at the market, which is where the words are.
func _learn(c: String) -> void:
	var lang: String = String(GameState.CITIES.get(c, {}).get("language", ""))
	var need: int = int(GameState.FLUENCY_STEPS[MEET_AT - 1])
	GameState.start_quest("learn_" + c, "Make yourself heard",
		["Learn %d words of %s well enough to use them. The market is where they are said loudest." % [need, lang.capitalize()]],
		[path(String(MARKET.get(c, SCENE.get(c, ""))))])


# They were always there. You could not hear them.
# Where to look, in words a player can act on.
#
# The step used to say "Find the one who runs the Spati on the corner" and
# stop. Berlin has thousands of Spatis and the game has one - in MITTE, four
# districts from where Kerstin actually stands - so a player followed the only
# lead the sentence gave them, walked into the Spati they knew, interacted
# with it, and got a bottle-deposit story and no quest progress. The quest was
# not broken; it was describing a person without saying where the person was.
#
# So every one of the eight names its district. Vagueness about WHO somebody is
# is the texture of this game. Vagueness about WHERE is just a hunt.
const WHERE := {
	"berlin": "the Späti next to the hotel, in Mitte",
	"london": "the terrace, four doors down",
	"paris": "the Marais, second floor",
	"moscow": "the booth off Basmanny",
	"istanbul": "the han in Carsi, on the stairs",
	"mumbai": "the lane in Bhuleshwar",
	"tokyo": "Kappabashi-dori, in Ueno",
	"mexico": "the flower rows in Coyoacan",
	"saopaulo": "Bixiga, the salao with the door propped open",
	"zurich": "the Langstrasse, the kiosk on the corner",
}


func _find(c: String) -> void:
	var p: Dictionary = person(c)
	if p.is_empty():
		return
	var id: String = "meet_" + c
	var where: String = path(String(SCENE.get(c, "")))
	var place: String = String(WHERE.get(c, ""))
	var first: String = "Find the one who %s" % String(p.get("trade", "works here"))
	if not place.is_empty():
		first += " — %s" % place
	GameState.start_quest(id, "Somebody keeps being there",
		[first, "Talk with them again", "And again — properly, this time"],
		[where, where, where])


# The one thing they ask for. It is a district this city already has, and it
# is finished by doing what that district does.
func _errand(c: String) -> void:
	var e: Dictionary = errand_of(c)
	if e.is_empty():
		return
	var p: Dictionary = person(c)
	var where: String = path(String(e.get("scene", "")))
	GameState.start_quest("errand_" + c, String(e.get("title", "A favour")),
		[String(e.get("step", "Go and do it")),
		 "Go back to %s" % String(p.get("name", "them"))],
		[where, path(String(SCENE.get(c, "")))])


func _holiday(c: String) -> void:
	var p: Dictionary = person(c)
	if p.is_empty():
		return
	GameState.start_quest("holiday_" + c, String(p.get("holiday", "A holiday")),
		["%s. %s is expecting you." % [String(p.get("when", "Today")),
			String(p.get("name", "They"))]],
		[path(String(SCENE.get(c, "")))])


# The airport of the city you are standing in. "Get to the airport" is a
# sentence about where your feet are, wherever they are now.
func _local_airport() -> String:
	return path(String(AIRPORT.get(GameState.city, "Airport.tscn")))


# You are standing in a finished city, or one of the twelve. Which of the eight
# comes next is the player's choice: the log names every city still waiting,
# not the next one in MANDATORY's order, and points at the local airport. One
# quest per leg of the journey, so the log keeps a line for each departure.
func _onward() -> void:
	var waiting: Array = []
	for c: String in MANDATORY:
		if not holiday_seen(c):
			waiting.append(String(GameState.CITIES.get(c, {}).get("name", c.capitalize())))
	if waiting.is_empty():
		return
	var title: String = "Where next is up to you"
	var fly: String = "Fly to any city still waiting: %s" % ", ".join(waiting)
	if waiting.size() == 1:
		title = "One city is still waiting"
		fly = "Fly to %s" % waiting[0]
	# Revisiting a finished city can begin another leg without finishing any
	# new story. Keep the active leg, otherwise allocate unused history space.
	var id := ""
	for qid: String in GameState.quests:
		if qid.begins_with("onward_") and not bool(GameState.quests[qid].get("completed", false)):
			id = qid
			break
	if id.is_empty():
		var leg := 1
		while GameState.quests.has("onward_%d" % leg):
			leg += 1
		id = "onward_%d" % leg
	var out: String = _local_airport()
	GameState.start_quest(id, title, ["Get to the airport", fly], [out, out])
	_retarget(id, title, ["Get to the airport", fly], [out, out])


# Eight cities let you in. There is one thing left that you have never had.
#
# The field is in Berlin, and the arrow only follows a city's own doors and
# trains. From anywhere else the way back starts at the airport you are near.
func _the_name() -> void:
	if not namer().is_empty():
		return
	var steps: Array = ["Go back to Berlin, to the field you landed in",
		"Ask one of the eight to name you"]
	GameState.start_quest("the_name", "You have never had a name", steps, [FIELD, FIELD])
	var ending: Dictionary = GameState.quests["the_name"]
	if not ending.has("field_visits"):
		ending["field_visits"] = int(GameState.region_visits.get("kiez", 0))
	var to: String = FIELD if GameState.city == "berlin" else _local_airport()
	_retarget("the_name", String(ending.get("title", "")), steps, [to, to])


# start_quest() never touches a quest that already exists, so a step whose
# place depends on where the player now stands is re-aimed here. Finished
# steps keep what they said.
func _retarget(id: String, title: String, texts: Array, targets: Array) -> void:
	if not GameState.quests.has(id):
		return
	var q: Dictionary = GameState.quests[id]
	var changed: bool = String(q.get("title", "")) != title
	q["title"] = title
	var steps: Array = q.get("steps", [])
	for i in range(mini(steps.size(), targets.size())):
		var st: Dictionary = steps[i]
		if bool(st.get("done", false)):
			continue
		if String(st.get("text", "")) != String(texts[i]) \
				or String(st.get("target", "")) != String(targets[i]):
			st["text"] = texts[i]
			st["target"] = targets[i]
			changed = true
	if changed:
		GameState.quest_updated.emit(id)
