extends Node

const COUNTER_ENCOUNTER := preload("res://scenes/dialogue/CounterEncounter.gd")
const FLIGHT := preload("res://scenes/cutscene/FlightCutscene.gd")
const ROUTES := preload("res://scenes/world/SceneGraph.gd")
var _boarding := false

# Existing terminal connections are retained; the three rail-linked airports
# include one onward ride without replacing normal ticket-language encounters.
const AIRPORT_RAIL := {
	"berlin": {"hall":"res://scenes/world/UBahnStation.tscn", "stop":"mitte", "label":"U8 - Weinmeisterstrasse"},
	"london": {"hall":"res://scenes/world/LondonUnderground.tscn", "stop":"terrace", "label":"District - Aldgate East"},
	"istanbul": {"hall":"res://scenes/world/IstanbulMetro.tscn", "stop":"carsi", "label":"M2 - Vezneciler"},
}
const AIRPORT_EXIT_NAMES := {
	"berlin":"City trains", "london":"Underground", "istanbul":"Metro",
	"paris":"Le Marais", "moscow":"Basmanny", "mumbai":"Chor Bazaar",
	"tokyo":"Jinbocho", "mexico":"Juarez",
}
const FIRST_IMPRESSIONS := {
	"london":"I can read the signs here.\n\nI thought that would be the hard part.",
	"istanbul":"Tea glasses on little saucers. Conversations spilling out of doorways.\n\nI wonder where there is room for one more.",
	"paris":"Past the terminal, the streets are full of ordinary errands.\n\nI have a map. I still need someone to ask.",
	"moscow":"The signs look like words I almost recognise.\n\nAlmost is doing a great deal of work.",
	"mumbai":"So many signs, and more than one script.\n\nI will have to begin with one person, not the whole city.",
	"tokyo":"Beyond the station, the streets are full of small doorways.\n\nI wonder which one I will recognise on the way back.",
	"mexico":"Shop signs, open doors, somewhere to stop.\n\nA city on the departure board is becoming a place I can walk through.",
}


func has_airport_transfer(path: String = "") -> bool:
	if String(GameState.world_flags.get("airport_transfer", "")) != GameState.city:
		return false
	if not AIRPORT_RAIL.has(GameState.city): return false
	if path.is_empty():
		var current := get_tree().current_scene
		if current == null: return false
		path = current.scene_file_path
	return path == AIRPORT_RAIL[GameState.city].hall


func arrival_guidance() -> Dictionary:
	var current := get_tree().current_scene
	if current == null: return {}
	var target := ""
	var text := ""
	var city: String = GameState.city
	if current.scene_file_path == GameState.ARRIVALS.get(city, ""):
		if String(GameState.world_flags.get("airport_transfer", "")) != city: return {}
		var door := current.get_node_or_null("Exit")
		if door == null: return {}
		target = String(door.target_scene)
		text = "Follow the exit to %s. Transfer into town included." % AIRPORT_EXIT_NAMES.get(city, "city transport")
	elif has_airport_transfer():
		target = GameState.CITY_ENTRIES[city]
		text = "Take %s into town. Transfer included; no ticket needed." % AIRPORT_RAIL[city].label
	else:
		return {}
	if Journey.core(city) and not Story.holiday_seen(city):
		var meeting := Story.path(Story.SCENE[city])
		text += "\nThen: " + meeting_directions(city, meeting)
	return {"title":"Arrivals - " + String(GameState.CITIES[city].name), "completed":false,
		"steps":[{"text":text, "target":target, "done":false}]}


# The labels come from the same data as the platform menu. These are routes
# inside this game, not claims about current real-world railway services.
func destination_stop(city: String, target: String) -> Array:
	var best: Array = []
	var distance := 999
	for stop: Array in METRO_LINES.get(city, []):
		var hops := _walking_hops(String(stop[4]), target)
		if hops >= 0 and hops < distance:
			best = stop
			distance = hops
	return best


func _walking_hops(start: String, target: String) -> int:
	var queue: Array = [[start, 0]]
	var seen := {start:true}
	while not queue.is_empty():
		var item: Array = queue.pop_front()
		if item[0] == target: return int(item[1])
		for door: Array in ROUTES.DOORS.get(item[0], []):
			var next := String(door[0])
			# A shared station is not a walking shortcut across the city.
			if seen.has(next) or ROUTES.TRANSIT.has(next): continue
			seen[next] = true
			queue.append([next, int(item[1]) + 1])
	return -1


func route_directions(city: String, target: String) -> String:
	var stop := destination_stop(city, target)
	if stop.is_empty(): return ""
	var here := get_tree().current_scene
	if city == GameState.city and here != null and here.scene_file_path in [target, String(stop[4])]:
		return ""
	return "Take %s to %s (%s)." % [String(stop[1]), String(stop[2]), GameState.region_name(String(stop[0]))]


func meeting_directions(city: String, target: String = "") -> String:
	if target.is_empty(): target = Story.path(Story.SCENE[city])
	return "%s Meet %s at %s." % [route_directions(city, target), Story.person_name(city), String(Story.WHERE[city])]


func prepare_airport(terminal: Node) -> void:
	if not is_instance_valid(terminal) or terminal != get_tree().current_scene: return
	var exit := terminal.get_node_or_null("Exit")
	if exit != null:
		var place: String = AIRPORT_EXIT_NAMES.get(GameState.city, "city transport")
		exit.prompt_text = "E - City transfer"
		exit.sign_text = "CITY TRANSFER - " + place
		exit.get_node("Prompt").text = exit.prompt_text
	for desk in terminal.get_children():
		if desk.get("service") == "airport_desk":
			desk.prompt_text = "E - Departures"
			desk.get_node("Prompt").text = desk.prompt_text
	refresh_arrival_guidance()


func refresh_arrival_guidance() -> void:
	var log := get_tree().get_first_node_in_group("quest_log")
	if log != null: log._refresh_tracker()


func first_street_arrival(fallback: String = "") -> void:
	var city: String = GameState.city
	var just_landed: bool = String(GameState.world_flags.get("airport_transfer", "")) == city
	if just_landed:
		GameState.advance_clock(30.0)
		GameState.world_flags.erase("airport_transfer")
	# London and Istanbul once kept their own spelling of this flag, and saves
	# and tools carry both; either one means the first impression is spent.
	var key: String = city + "_arrived" if city in ["london", "istanbul"] else "arrived_" + city
	var seen: bool = bool(GameState.world_flags.get("arrived_" + city, false)) \
		or bool(GameState.world_flags.get(city + "_arrived", false))
	var text: String = FIRST_IMPRESSIONS.get(city, fallback)
	if not text.is_empty() and not seen:
		GameState.world_flags[key] = true
		_think(text)
	if just_landed:
		SaveManager.checkpoint.call_deferred()

# Every counter, machine and notice board in the game routes through here.
# A ServicePoint in the world calls Services.run("exchange", node); this file
# owns the rules, the money, and the story consequences.

# ── Odd jobs ─────────────────────────────────────────────────────────────────
#
# Taking a job used to BE the job. You picked a card off the notice board, you
# walked to the ServicePoint the card named, and the money appeared - so "stack
# the delivery crates" was a fetch quest with the fetch taken out, and the only
# labour in a game about a stranger who has to earn a room was pressing E in
# the right district.
#
# Now each one is a loop with hands in it:
#
#   take   a pile, a box, a stack. Walk into it and you are carrying a load
#   give   where the load goes. Walk into it and you set one down
#   reps   how many trips it takes
#
# Both ends are JobSpot nodes in the world, so the work happens where the work
# is rather than inside a menu, and the player walks slower while loaded.
#
#   load   what CharacterArt draws in his arms on the way
#   target the ServicePoint that hands the job in when it is finished
const JOBS := {
	"crates": {
		"title":  "Stack the delivery crates",
		"giver":  "the bread man at the field market",
		"where":  "the stall by the wreck",
		"pay":    4,
		"target": "job_crates",
		"load":   "crate", "reps": 3,
		"take":   "the pallet by the van", "give": "the stall's back shelf",
		"accept": "Crates. Stack crates. Even I can understand a mime that clear.

" +
			"He wants them by the stall, at the field where I came down.
" +
			"Three loads off the pallet, and they go on the back shelf.",
		"done":   "Twelve crates, stacked. My arms ache in a way that feels
" +
			"almost good — the first honest tiredness on this planet.",
	},
	"flyers": {
		"title":  "Hand out flyers on the platform",
		"giver":  "a tired woman with a cardboard box",
		"where":  "the U-Bahn platform",
		"pay":    3,
		"target": "job_flyers",
		"load":   "papers", "reps": 3,
		"take":   "the cardboard box by the stairs",
		"give":   "the end of the platform, where people wait",
		"accept": "A box of papers, all identical. She pushed one at a stranger,
" +
			"then pointed at me and at the box.

So: give these to people.
" +
			"Three armfuls, from the box to the far end of the platform.",
		"done":   "Most people took one without looking at me. A few did look.
" +
			"One of them smiled. The box is empty.",
	},
	"dishes": {
		"title":  "Wash up after the evening service",
		"giver":  "the cook, through a hatch",
		"where":  "the restaurant kitchen",
		"pay":    5,
		"target": "job_dishes",
		"load":   "box", "reps": 4,
		"take":   "the sink, and the mountain in it",
		"give":   "the rack by the pass",
		"accept": "He held up a plate, then a cloth, then pointed at a sink
" +
			"with a mountain in it. The instructions were perfect.
" +
			"Four trays, sink to rack, and the mountain goes down.",
		"done":   "The mountain is gone. He said a word twice and pressed coins
" +
			"into my hand without counting them where I could see.",
	},
	"sweep": {
		"title":  "Sweep the station steps",
		"giver":  "a man in a reflective vest",
		"where":  "the U-Bahn platform",
		"pay":    3,
		"target": "job_flyers",
		"load":   "broomup", "reps": 2,
		"take":   "the broom against the wall",
		"give":   "the bottom of the steps",
		"accept": "He mimed sweeping, then handed me the broom before I agreed.
" +
			"Apparently that counts as a contract here.
" +
			"From the wall to the bottom of the steps, twice.",
		"done":   "Clean steps. Nobody will notice, which he seemed to say
" +
			"is the whole point of the work.",
	},
}


# How many trips a job takes, and what it looks like in his arms. Read by the
# JobSpot nodes in the world and by the HUD.
func job_reps(id: String) -> int:
	return int(Dictionary(JOBS.get(id, {})).get("reps", 1))


func job_load(id: String) -> String:
	return String(Dictionary(JOBS.get(id, {})).get("load", "box"))


func job_title(id: String) -> String:
	return String(Dictionary(JOBS.get(id, {})).get("title", ""))


# What the player is being asked to do right now, in one line. The HUD and the
# job site both say it, so they cannot disagree about what is left.
# Where the work is. Dishes are washed in whichever city he took the job in -
# there is a kitchen in Berlin, London and Istanbul and they are the same job -
# so it is a per-city lookup rather than one path.
const JOB_SCENES := {
	"crates": {"": "res://scenes/world/Kiez.tscn"},
	"flyers": {"": "res://scenes/world/UBahnStation.tscn"},
	"sweep":  {"": "res://scenes/world/UBahnStation.tscn"},
	"dishes": {"": "res://scenes/world/Restaurant.tscn",
		"london": "res://scenes/world/LondonCaff.tscn",
		"istanbul": "res://scenes/world/IstanbulLokanta.tscn"},
}


func job_scene(id: String) -> String:
	var per: Dictionary = JOB_SCENES.get(id, {})
	return String(per.get(GameState.city, per.get("", "")))


# A job goes in the log like everything else the game asks of the player, so
# the arrow can point at it and so "what am I supposed to be doing" has one
# answer rather than two. It used to live only in the notice board's own head.
func open_job_quest(id: String) -> void:
	if not JOBS.has(id):
		return
	var j: Dictionary = JOBS[id]
	var where: String = job_scene(id)
	GameState.start_quest("job_" + id, String(j.get("title", "Work")),
		["Take a load from %s" % String(j.get("take", "the pile")),
		 "Carry %d of them to %s" % [job_reps(id), String(j.get("give", "where they go"))],
		 "Tell %s it is done" % String(j.get("giver", "whoever asked"))],
		[where, where, where])


# Tick whatever is now true. Called from the piles themselves, so the log
# cannot disagree with the number of crates left on the pallet.
func settle_job_quest() -> void:
	var id: String = GameState.active_job
	if id.is_empty():
		return
	var qid: String = "job_" + id
	if not GameState.quests.has(qid):
		return
	if not GameState.carrying.is_empty() or GameState.job_progress > 0:
		GameState.complete_quest_step(qid, 0)
	if GameState.job_progress >= job_reps(id):
		GameState.complete_quest_step(qid, 1)


func job_step() -> String:
	var id: String = GameState.active_job
	if id.is_empty() or not JOBS.has(id):
		return ""
	var j: Dictionary = JOBS[id]
	var left: int = job_reps(id) - GameState.job_progress
	if not GameState.carrying.is_empty():
		return "Carry it to %s  (%d to go)" % [String(j.get("give", "where it goes")), left]
	return "Pick up a load from %s  (%d to go)" % [String(j.get("take", "the pile")), left]


func _choice() -> Node:
	return get_tree().get_first_node_in_group("choice_panel")


func _think(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(text)


func run(service: String, _source: Node) -> void:
	match service:
		"exchange":       await _exchange()
		"jobboard":       await _jobboard()
		"ubahn_ticket":   await _ubahn_ticket()
		"ubahn_travel":   await _ubahn_travel()
		"lost_property":  await _lost_property()
		"hotel_desk":     await _hotel_desk()
		"yusuf_shop":     await _yusuf_shop()
		"police_desk":    await _police_desk()
		"hospital_desk":  await _hospital_desk()
		"airport_desk":   await _airport_desk()
		"local":          await _local()
		"job_crates", "job_flyers", "job_dishes": _job_site(service)
		_: _think("Nothing here answers to me.")


# ── Money exchange ───────────────────────────────────────────────────────────
# A booth changes money in both directions, which the first version of this did
# not: it offered euro, pound and lira and nothing else - three currencies left
# over from when the game had three cities - and only ever sold you foreign
# money for local. So a player who worked a shift in Tokyo, flew to Dakar and
# walked into the bureau there was told, in effect, that yen do not exist.
#
# The wallet has always kept one pocket per currency and travelling has never
# emptied any of them. What was missing was a counter that would take them.

func _exchange() -> void:
	var cp := _choice()
	if cp == null:
		return
	var here: String = GameState.currency()
	var rows: Array = []

	# Coming in: everything foreign he is carrying, richest first. This is what
	# a traveller actually does at a bureau, and it is the direction that was
	# missing.
	for row: Dictionary in GameState.foreign_holdings():
		var cur: String = String(row["cur"])
		var have: int = int(row["amount"])
		var back: int = GameState.convert_preview(have, cur, here)
		rows.append({
			"id": "in:" + cur,
			"label": "%s  \u2192  %s" % [GameState.currency_label(cur),
				GameState.currency_label(here)],
			"sub": "hands over all %d %s and takes %d %s back"
				% [have, cur, back, here],
			"disabled": back <= 0,
		})

	# Going out: the money of the places he has already been, because those are
	# the only foreign names that mean anything to him yet. Capped, so the
	# board stays a board and not a departure list.
	var step: int = GameState.exchange_step(here)
	var give: int = mini(GameState.cash(here), step)
	var offered: Array = []
	for c: String in GameState.CITIES.keys():
		if not bool(GameState.world_flags.get("visited_" + String(c), false)):
			continue
		var cur2: String = String(GameState.CITIES[c].get("currency", ""))
		if cur2 == here or cur2.is_empty() or offered.has(cur2):
			continue
		offered.append(cur2)
	if offered.is_empty():
		offered.append("EUR" if here != "EUR" else "USD")
	for cur3: String in offered.slice(0, 3):
		var got: int = GameState.convert_preview(give, here, cur3)
		rows.append({
			"id": "out:" + cur3,
			"label": "%s  \u2192  %s" % [GameState.currency_label(here),
				GameState.currency_label(cur3)],
			"sub": "changes %d %s into %d %s (their cut is a tenth)"
				% [give, here, got, cur3],
			"disabled": give <= 0 or got <= 0,
		})

	rows.append({"id": "", "label": "Just look at the board",
		"sub": "columns of numbers that keep changing, and none of them explain"})

	cp.open(_booth_name(),
		"the woman behind the glass waits with the patience of someone paid by the hour",
		rows)
	var pick: String = await cp.chosen
	if pick.is_empty():
		return

	var parts: PackedStringArray = pick.split(":")
	if parts.size() != 2:
		return
	var here_now: String = GameState.currency()
	var ok: bool = false
	if parts[0] == "in":
		var from: String = String(parts[1])
		ok = GameState.exchange(GameState.cash(from), from, here_now)
	else:
		var to: String = String(parts[1])
		var amount: int = mini(GameState.cash(here_now),
			GameState.exchange_step(here_now))
		ok = GameState.exchange(amount, here_now, to)
	if not ok:
		return
	GameState.world_flags["used_exchange"] = true
	_think("She counted it twice, then pushed a different set of\n" +
		"metal and paper back under the glass.\n\n" +
		"Same value, they say. Different faces on it.\n" +
		"Somewhere between the two piles, she kept a little.")


# What the sign over the window says, in the language of the country. He cannot
# read any of them, but they are not all the same word and he can tell.
const BOOTH_NAMES := {
	"berlin": "Wechselstube", "zurich": "Wechselstube", "istanbul": "D\u00f6viz",
	"london": "Bureau de Change", "paris": "Bureau de Change",
	"rome": "Cambio", "mexico": "Casa de Cambio", "lapaz": "Casa de Cambio",
	"saopaulo": "Casa de C\u00e2mbio", "moscow": "Obmen",
	"tbilisi": "Valuta", "hanoi": "\u0110\u1ed5i ti\u1ec1n",
	"tokyo": "Ryogae", "seoul": "Hwanjeon", "mumbai": "Money Changer",
	"dakar": "Bureau de Change", "sydney": "Currency Exchange",
	"honolulu": "Currency Exchange", "newyork": "Currency Exchange",
	"toronto": "Bureau de Change",
}


func _booth_name() -> String:
	return String(BOOTH_NAMES.get(GameState.city, "Currency Exchange"))
# ── Odd jobs board ───────────────────────────────────────────────────────────

func _jobboard() -> void:
	var cp := _choice()
	if cp == null:
		return
	if not GameState.active_job.is_empty():
		var j: Dictionary = JOBS.get(GameState.active_job, {})
		_think("I already agreed to something.\n\n" + String(j.get("title", "")) +
			"\n— " + String(j.get("where", "")))
		return

	var rows := []
	for id: String in JOBS:
		var j: Dictionary = JOBS[id]
		var times := int(GameState.jobs_done.get(id, 0))
		rows.append({
			"id": id,
			"label": String(j["title"]),
			"sub": "%s · %s%s" % [String(j["giver"]), String(j["where"]),
				("  ·  done %d×" % times) if times > 0 else ""],
			"cost": "%s%d" % [GameState.symbol(), int(j["pay"])],
		})
	rows.append({"id": "", "label": "Walk away", "sub": "the cards will still be here"})

	cp.open("Notice board",
		"cards pinned at every angle. You cannot read one word of them — but " +
		"the pictures, the phone-number fringes and the coins drawn in the corner say enough",
		rows)
	var pick: String = await cp.chosen
	if pick.is_empty() or not JOBS.has(pick):
		return
	GameState.accept_job(pick)
	open_job_quest(pick)
	_think(String(JOBS[pick]["accept"]))


func _job_site(service: String) -> void:
	var id := GameState.active_job
	if id.is_empty() or not JOBS.has(id):
		_think("Someone works here. It is not me, not today.")
		return
	var job: Dictionary = JOBS[id]
	if String(job["target"]) != service:
		_think("Wrong place. The card in my pocket points somewhere else:

" +
			String(job["where"]))
		return
	# The work is done out in the world now, at the pile and at the place the
	# pile goes. This counter is where it is HANDED IN - so it says what is
	# left rather than paying out for having walked here.
	var left: int = job_reps(id) - GameState.job_progress
	if left > 0:
		_think(String(job["title"]) + "

" + job_step() + "

" +
			"He looks at the pile, then at me, and goes back to what he was doing.")
		return
	var pay := int(job["pay"])
	GameState.complete_last_step("job_" + id)
	# Read before the count goes up, so this describes the state he arrived in.
	var done_before: int = int(GameState.jobs_done.get(id, 0))
	GameState.finish_job(id, pay)
	_think(String(job["done"]) + "

( +%s%d )" % [GameState.symbol(), pay]
		+ _reliability(done_before))


# What being asked again is like. Nobody says any of it out loud, which is the
# point: the whole exchange happens without a word he would need to understand,
# and it is the only ladder in this game he can start climbing on his first
# day. The prose is about being RECOGNISED rather than about being paid.
func _reliability(done_before: int) -> String:
	if done_before <= 0:
		return ""
	if done_before == 1:
		return "

He nodded at me before I said anything. That has not
" 			+ "happened here before."
	if done_before == 2:
		return "

He had it ready. He knew I was coming, or he knew
" 			+ "somebody was, and I turned out to be somebody."
	return "

Nobody explains the job to me any more. I am the person
" 		+ "who does this now, which is a small thing to be and it is
" 		+ "the first thing I have been."


# ── U-Bahn ───────────────────────────────────────────────────────────────────

# Whatever the machine calls itself. The alien cannot read any of them, but
# the SHAPE of the word is different in each country and that is the point.
const MACHINE_TITLES := {
	"berlin": "Fahrkartenautomat", "zurich": "Billettautomat",
	"london": "Ticket machine",    "rome": "Biglietteria automatica",
	"moscow": "Biletnyy avtomat",  "mexico": "Taquilla",
	"saopaulo": "Bilheteria",      "dakar": "Guichet",
	"tbilisi": "Salaro",           "seoul": "Ticket machine",
	"mumbai": "Ticket window",     "istanbul": "Biletmatik",
	"lapaz": "Boleteria",          "tokyo": "Kippu uriba",
	"hanoi": "Quay ve",
}


func _machine_title() -> String:
	return String(MACHINE_TITLES.get(GameState.city, "Ticket machine"))


func _ubahn_ticket() -> void:
	if has_airport_transfer():
		_think("The ride into town is already included in my flight.\n\nI can go straight to the platform.")
		return
	if Journey.core():
		if GameState.has_item("ticket_ubahn"):
			_think("The ticket is already in my pocket. One journey is waiting for me.")
			return
		if not await COUNTER_ENCOUNTER.request("ticket"):
			return
		var covered_fare: int = GameState.transit_fare()
		Journey.ensure_funds(covered_fare)
		GameState.money -= covered_fare
		GameState.money_changed.emit(GameState.money)
		# Handed over at the machine, ready for the barrier in this same visit.
		GameState.add_item("ticket_ubahn")
		Items.learn("ticket_ubahn")
		COUNTER_ENCOUNTER.received("ticket")
		return
	var cp := _choice()
	if cp == null:
		return
	var fare: int = GameState.transit_fare()
	var afford := GameState.money >= fare
	cp.open(_machine_title(),
		"a machine with more buttons than a language has sounds. One of them is bigger than the others.",
		[
			{"id": "single", "label": "The big green button",
				"sub": "one ride, anywhere on the coloured tangle",
				"cost": "%s%d" % [GameState.symbol(), fare], "disabled": not afford},
			{"id": "", "label": "Step back",
				"sub": "" if afford else "not enough coins for the big button anyway"},
		])
	var pick: String = await cp.chosen
	if pick != "single":
		return
	GameState.money -= fare
	GameState.money_changed.emit(GameState.money)
	GameState.drop_item("ticket_ubahn")
	if GameState.city == "berlin":
		GameState.expose("german", "fahrkarte", "pointed")
	_think("A stiff paper rectangle drops into the tray.\n\n" +
		"I have bought permission to be carried somewhere. That is a\n" +
		"strange thing to be able to buy.")


# Hoisted out of the function body: as an inline literal this was
# `var dest := {...}.get(pick, "")`, and Dictionary.get() returns Variant, so
# ':=' inferred Variant and Godot's warnings-as-errors refused to compile it.
# Where the metro actually goes, per city.
#
# It used to offer three stops in Berlin, one of which was the street you had
# just walked in from and two of which were interiors — so riding it either put
# you back where you started or teleported you into a waiting room. A metro
# should take you to a DISTRICT: somewhere with its own streets, its own shops
# and its own opinion of you.
#
# Each entry: [id, line colour name, station name, what the sign shows, scene]
const METRO_LINES := {
	"berlin": [
		["prenzlberg", "U2", "Eberswalder Strasse",
			"the stop with the trees drawn on the tiles",
			"res://scenes/world/BerlinPrenzlberg.tscn"],
		["kreuzberg", "U1", "Kottbusser Tor",
			"the one where the map line crosses the water",
			"res://scenes/world/BerlinKreuzberg.tscn"],
		["mitte", "U8", "Weinmeisterstrasse",
			"back the way you came",
			"res://scenes/world/Mitte.tscn"],
		["flughafen", "S9", "Flughafen",
			"the one drawn with a little aeroplane",
			"res://scenes/world/Airport.tscn"],
	],
	"zurich": [
		["niederdorf", "Tram 4", "Rudolf-Brun-Bruecke",
			"back over the river to the old lanes",
			"res://scenes/world/ZurichNiederdorf.tscn"],
		["langstrasse", "Tram 8", "Helvetiaplatz",
			"the stop where the map stops being tidy",
			"res://scenes/world/ZurichLangstrasse.tscn"],
		["zurichwest", "Tram 4", "Escher-Wyss-Platz",
			"the end of the line, under the viaduct",
			"res://scenes/world/ZurichWest.tscn"],
		["seefeld", "Tram 4", "Hoeschgasse",
			"out along the lake",
			"res://scenes/world/ZurichSeefeld.tscn"],
		["oerlikon", "S5", "Zuerich Oerlikon",
			"north, past the tracks, where nothing is old",
			"res://scenes/world/ZurichOerlikon.tscn"],
		["flughafen", "S2", "Zuerich Flughafen",
			"the one drawn with an aeroplane",
			"res://scenes/world/ZurichAirport.tscn"],
	],
	"hanoi": [
		["phoco", "Bus 09", "Bo Ho",
			"back to the thirty-six streets",
			"res://scenes/world/HanoiPhoCo.tscn"],
		["longbien", "Bus 01", "Long Bien",
			"the stop under the old bridge",
			"res://scenes/world/HanoiLongBien.tscn"],
		["badinh", "Bus 22", "Ba Dinh",
			"out to the wide streets and the villas",
			"res://scenes/world/HanoiBaDinh.tscn"],
		["dongda", "Tuyen 2A", "Cat Linh",
			"up on the concrete, above the traffic",
			"res://scenes/world/HanoiDongDa.tscn"],
		["tayho", "Bus 55", "Ho Tay",
			"out to the water",
			"res://scenes/world/HanoiTayHo.tscn"],
		["sanbay", "Bus 86", "San bay Noi Bai",
			"the one with a little aeroplane on it",
			"res://scenes/world/HanoiAirport.tscn"],
	],
	"london": [
		["docklands", "DLR", "Canary Wharf",
			"the towers on the diagram, drawn taller than everything",
			"res://scenes/world/LondonDocklands.tscn"],
		["terrace", "District", "Aldgate East",
			"back up the road",
			"res://scenes/world/LondonTerrace.tscn"],
		["soho", "Piccadilly", "Piccadilly Circus",
			"the blue line, into the middle of it",
			"res://scenes/world/LondonSoho.tscn"],
		["brixton", "Victoria", "Brixton",
			"light blue, and it stops there because the line does",
			"res://scenes/world/LondonBrixton.tscn"],
		["airport", "Piccadilly", "Heathrow",
			"the aeroplane at the end of the blue line",
			"res://scenes/world/LondonAirport.tscn"],
	],
	"tokyo": [
		["yanaka", "Chiyoda", "Sendagi",
			"green on the diagram, back to the low town",
			"res://scenes/world/TokyoYanaka.tscn"],
		["jinbocho", "Hanzomon", "Jimbocho",
			"purple, and it smells of paper up there",
			"res://scenes/world/TokyoJinbocho.tscn"],
		["shinbashi", "Asakusa", "Shimbashi",
			"the rose-coloured line, south",
			"res://scenes/world/TokyoShinbashi.tscn"],
		["asakusa", "Asakusa", "Asakusa",
			"the rose-coloured line, the other end",
			"res://scenes/world/TokyoAsakusa.tscn"],
		["ueno", "Ginza", "Ueno",
			"orange on the diagram, to the market under the railway",
			"res://scenes/world/TokyoUeno.tscn"],
		["kuko", "Keikyu", "Haneda Kuko",
			"the aeroplane at the end",
			"res://scenes/world/TokyoAirport.tscn"],
	],
	"rome": [
		["testaccio", "Linea B", "Piramide",
			"blue on the map, by the pyramid",
			"res://scenes/world/RomeTestaccio.tscn"],
		["esquilino", "Linea A", "Vittorio Emanuele",
			"orange, under the big square",
			"res://scenes/world/RomeEsquilino.tscn"],
		["trastevere", "Tram 8", "Trastevere/Mastai",
			"the tram, over the river",
			"res://scenes/world/RomeTrastevere.tscn"],
		["monti", "Linea B", "Cavour",
			"blue again, one stop from the ruin",
			"res://scenes/world/RomeMonti.tscn"],
		["garbatella", "Linea B", "Garbatella",
			"blue, out past the basilica, to the numbered courts",
			"res://scenes/world/RomeGarbatella.tscn"],
		["aeroporto", "FL1", "Fiumicino Aeroporto",
			"the aeroplane at the end",
			"res://scenes/world/RomeAirport.tscn"],
	],
	"moscow": [
		["kitaygorod", "Liniya 6", "Kitay-gorod",
			"orange, back to the middle",
			"res://scenes/world/MoscowKitayGorod.tscn"],
		["basmanny", "Liniya 3", "Baumanskaya",
			"dark blue, out past the ring",
			"res://scenes/world/MoscowBasmanny.tscn"],
		["izmaylovo", "Liniya 3", "Izmaylovskaya",
			"dark blue, right to the end",
			"res://scenes/world/MoscowIzmaylovo.tscn"],
		["zamoskvorechye", "Liniya 2", "Novokuznetskaya",
			"green, across the river",
			"res://scenes/world/MoscowZamoskvorechye.tscn"],
		["arbat", "Liniya 3", "Arbatskaya",
			"dark blue, to the street with no road on it",
			"res://scenes/world/MoscowArbat.tscn"],
		["aeroport", "Aeroekspress", "Sheremetyevo",
			"the aeroplane at the end",
			"res://scenes/world/MoscowAirport.tscn"],
	],
	"mexico": [
		["merced", "Linea 1", "Merced",
			"pink, back to the market",
			"res://scenes/world/MexicoMerced.tscn"],
		["juarez", "Linea 3", "Juarez",
			"olive green, up to the wide streets",
			"res://scenes/world/MexicoJuarez.tscn"],
		["coyoacan", "Linea 3", "Viveros/Derechos Humanos",
			"olive green, a long way south",
			"res://scenes/world/MexicoCoyoacan.tscn"],
		["roma", "Linea 1", "Insurgentes",
			"pink, the round station",
			"res://scenes/world/MexicoRoma.tscn"],
		["condesa", "Linea 1", "Chapultepec",
			"pink, to the streets that were once a racetrack",
			"res://scenes/world/MexicoCondesa.tscn"],
		["aeropuerto", "Linea 5", "Terminal Aerea",
			"the aeroplane at the end",
			"res://scenes/world/MexicoAirport.tscn"],
	],
	"saopaulo": [
		["liberdade", "Linha 1 Azul", "Liberdade",
			"blue, back under the red lamps",
			"res://scenes/world/SaoPauloLiberdade.tscn"],
		["bixiga", "Linha 2 Verde", "Brigadeiro",
			"green, down the hill",
			"res://scenes/world/SaoPauloBixiga.tscn"],
		["mercadao", "Linha 1 Azul", "Sao Bento",
			"blue, where the market is",
			"res://scenes/world/SaoPauloMercadao.tscn"],
		["vilamadalena", "Linha 2 Verde", "Vila Madalena",
			"green, right to the end",
			"res://scenes/world/SaoPauloVilaMadalena.tscn"],
		["paulista", "Linha 2 Verde", "Trianon-Masp",
			"green, up to the avenue with no wires",
			"res://scenes/world/SaoPauloPaulista.tscn"],
		["aeroporto", "Linha 13 Jade", "Aeroporto-Guarulhos",
			"the aeroplane at the end",
			"res://scenes/world/SaoPauloAirport.tscn"],
	],
	"dakar": [
		["medina", "BRT B1", "Medina",
			"the long electric bus, back to the grid",
			"res://scenes/world/DakarMedina.tscn"],
		["sandaga", "Dem Dikk 7", "Sandaga",
			"the blue bus, down to the market",
			"res://scenes/world/DakarSandaga.tscn"],
		["ouakam", "Dem Dikk 12", "Ouakam",
			"out towards the headland",
			"res://scenes/world/DakarOuakam.tscn"],
		["yoff", "TER", "Yoff",
			"the new train, and it is very fast",
			"res://scenes/world/DakarYoff.tscn"],
		["plateau", "Dem Dikk 1", "Plateau",
			"down to the ministries, where nobody greets you",
			"res://scenes/world/DakarPlateau.tscn"],
		["aeroport", "TER", "Diamniadio",
			"the aeroplane at the end of the line",
			"res://scenes/world/DakarAirport.tscn"],
	],
	"tbilisi": [
		["sololaki", "Khazi 1", "Liberty Square",
			"red on the diagram, back up the hill",
			"res://scenes/world/TbilisiSololaki.tscn"],
		["dezerter", "Khazi 1", "Station Square",
			"where the two lines cross, and the only place they do",
			"res://scenes/world/TbilisiDezerter.tscn"],
		["avlabari", "Khazi 1", "Avlabari",
			"red, over the river",
			"res://scenes/world/TbilisiAvlabari.tscn"],
		["saburtalo", "Khazi 2", "Delisi",
			"green, the short line",
			"res://scenes/world/TbilisiSaburtalo.tscn"],
		["chugureti", "Khazi 1", "Marjanishvili",
			"red, over the river to the German grid",
			"res://scenes/world/TbilisiChugureti.tscn"],
		["aeroporti", "Bus 37", "Aeroporti",
			"the one with an aeroplane on the front",
			"res://scenes/world/TbilisiAirport.tscn"],
	],
	"seoul": [
		["euljiro", "Line 2", "Euljiro 4-ga",
			"green on the map, back to the tool alleys",
			"res://scenes/world/SeoulEuljiro.tscn"],
		["jongno", "Line 3", "Jongno 3-ga",
			"orange, north to the arcade",
			"res://scenes/world/SeoulJongno.tscn"],
		["mangwon", "Line 6", "Mangwon",
			"brown, west, where nobody is in a hurry",
			"res://scenes/world/SeoulMangwon.tscn"],
		["seongsu", "Line 2", "Seongsu",
			"green again, east, over the water",
			"res://scenes/world/SeoulSeongsu.tscn"],
		["hongdae", "Line 2", "Hongik Univ",
			"green, west, to the streets that are all under thirty",
			"res://scenes/world/SeoulHongdae.tscn"],
		["gonghang", "AREX", "Incheon Gonghang",
			"the aeroplane at the end",
			"res://scenes/world/SeoulAirport.tscn"],
	],
	"mumbai": [
		["bhuleshwar", "Western", "Charni Road",
			"back down to the wholesale lanes",
			"res://scenes/world/MumbaiBhuleshwar.tscn"],
		["chorbazaar", "Western", "Grant Road",
			"one stop, and the street changes completely",
			"res://scenes/world/MumbaiChorBazaar.tscn"],
		["byculla", "Central", "Byculla",
			"the other line, the old station",
			"res://scenes/world/MumbaiByculla.tscn"],
		["bandra", "Western", "Bandra",
			"north, and it takes a while",
			"res://scenes/world/MumbaiBandra.tscn"],
		["colaba", "Metro 3", "Cuffe Parade",
			"the new line, south, to the arcade you walk inside",
			"res://scenes/world/MumbaiColaba.tscn"],
		["vimantal", "Metro 3", "CSMIA",
			"the aeroplane at the end",
			"res://scenes/world/MumbaiAirport.tscn"],
	],
	"istanbul": [
		["karakoy", "T1", "Karakoy",
			"the stop where the diagram meets the water",
			"res://scenes/world/IstanbulKarakoy.tscn"],
		["carsi", "M2", "Vezneciler",
			"back to the lane",
			"res://scenes/world/IstanbulCarsi.tscn"],
		["beyoglu", "M2", "Sishane",
			"up the hill, to the street that thinks it is in Europe",
			"res://scenes/world/IstanbulBeyoglu.tscn"],
		["kadikoy", "Vapur", "Kadikoy",
			"not a train. A boat, and it goes to the other continent",
			"res://scenes/world/IstanbulKadikoy.tscn"],
		["havalimani", "M11", "Havalimani",
			"the aeroplane at the end",
			"res://scenes/world/IstanbulHavalimani.tscn"],
	],
	"lapaz": [
		["elalto", "Linea Roja", "16 de Julio",
			"red, up to the rim",
			"res://scenes/world/LaPazElAlto.tscn"],
		["rodriguez", "Linea Roja", "Estacion Central",
			"red, back down into the bowl",
			"res://scenes/world/LaPazRodriguez.tscn"],
		["sopocachi", "Linea Amarilla", "Sopocachi",
			"yellow, across the middle",
			"res://scenes/world/LaPazSopocachi.tscn"],
		["irpavi", "Linea Verde", "Irpavi",
			"green, all the way down the valley",
			"res://scenes/world/LaPazIrpavi.tscn"],
		["sanpedro", "Puma Katari", "San Pedro",
			"the city bus, down to the square with the wall on it",
			"res://scenes/world/LaPazSanPedro.tscn"],
		["aeropuerto", "Linea Roja", "El Alto Aeropuerto",
			"the aeroplane, and it is above the clouds",
			"res://scenes/world/LaPazAirport.tscn"],
	],
	"paris": [
		["marais", "1", "Saint-Paul",
			"the oldest line, straight through the middle",
			"res://scenes/world/ParisMarais.tscn"],
		["montmartre", "12", "Abbesses",
			"the deepest station in the city, and the lift is broken",
			"res://scenes/world/ParisMontmartre.tscn"],
		["belleville", "11", "Belleville",
			"uphill, and the line climbs with it",
			"res://scenes/world/ParisBelleville.tscn"],
		["ladefense", "RER A", "La Defense Grande Arche",
			"not the Metro. A bigger train, out past the boundary",
			"res://scenes/world/ParisLaDefense.tscn"],
		["champdemars", "6", "Bir-Hakeim",
			"the line that comes up out of the ground to cross the river",
			"res://scenes/world/ParisChampDeMars.tscn"],
		["aeroport", "RER B", "Charles de Gaulle",
			"the one with the aeroplane drawn beside it",
			"res://scenes/world/ParisAirport.tscn"],
	],
	"sydney": [
		["cbd", "T1", "Town Hall",
			"three stops, and everyone gets off at this one",
			"res://scenes/world/SydneyCBD.tscn"],
		["newtown", "T2", "Newtown",
			"out to where the shops stop matching",
			"res://scenes/world/SydneyNewtown.tscn"],
		["bondi", "333", "Bondi Beach",
			"a bus. The beach never got a train and this is why",
			"res://scenes/world/SydneyBondi.tscn"],
		["cabramatta", "T3", "Cabramatta",
			"forty minutes west, and the announcements change",
			"res://scenes/world/SydneyCabramatta.tscn"],
		["circularquay", "T1", "Circular Quay",
			"back to the water",
			"res://scenes/world/SydneyCircularQuay.tscn"],
		["airport", "T8", "International Airport",
			"the aeroplane, and they charge you extra for the station",
			"res://scenes/world/SydneyAirport.tscn"],
	],
	"honolulu": [
		["chinatown", "2", "Hotel Street",
			"the bus, and the bus is the whole system here",
			"res://scenes/world/HonoluluChinatown.tscn"],
		["kakaako", "20", "Ala Moana",
			"past the warehouses with the painted ends",
			"res://scenes/world/HonoluluKakaako.tscn"],
		["manoa", "6", "Manoa Valley",
			"up the valley, where it is raining and will stop",
			"res://scenes/world/HonoluluManoa.tscn"],
		["northshore", "60", "Haleiwa",
			"two hours round the island, and worth every minute",
			"res://scenes/world/HonoluluNorthShore.tscn"],
		["waikiki", "8", "Kuhio Avenue",
			"back to the beach",
			"res://scenes/world/HonoluluWaikiki.tscn"],
		["airport", "19", "Airport",
			"the one that will not let you on with a large bag",
			"res://scenes/world/HonoluluAirport.tscn"],
	],
	"newyork": [
		["lowereast", "F", "Delancey Street",
			"downtown, and it runs all night, which nothing else does",
			"res://scenes/world/NewYorkLowerEast.tscn"],
		["harlem", "A", "125th Street",
			"express, and it does not stop for a hundred blocks",
			"res://scenes/world/NewYorkHarlem.tscn"],
		["williamsburg", "L", "Bedford Avenue",
			"one stop under the river and you are in another borough",
			"res://scenes/world/NewYorkWilliamsburg.tscn"],
		["jacksonheights", "7", "74th Street",
			"above the street, not under it, most of the way",
			"res://scenes/world/NewYorkJacksonHeights.tscn"],
		["midtown", "6", "33rd Street",
			"back into the middle",
			"res://scenes/world/NewYorkMidtown.tscn"],
		["airport", "AirTrain", "Howard Beach",
			"the aeroplane, and they charge you again at the platform",
			"res://scenes/world/NewYorkAirport.tscn"],
	],
	"toronto": [
		["kensington", "506", "Spadina",
			"a streetcar, in the traffic, the way they have always run",
			"res://scenes/world/TorontoKensington.tscn"],
		["gerrard", "506", "Gerrard and Coxwell",
			"east along the same line, to where the signs change",
			"res://scenes/world/TorontoGerrard.tscn"],
		["distillery", "504", "Distillery Loop",
			"down to the brick, where the road turns to cobbles",
			"res://scenes/world/TorontoDistillery.tscn"],
		["scarborough", "Line 2", "Kennedy",
			"forty minutes east, and then a bus, and then the lake",
			"res://scenes/world/TorontoScarborough.tscn"],
		["downtown", "Line 1", "Union",
			"back under the towers",
			"res://scenes/world/TorontoDowntown.tscn"],
		["airport", "UP Express", "Pearson",
			"twenty-five minutes, and it is the one thing here that is quick",
			"res://scenes/world/TorontoAirport.tscn"],
	],
}


func _ubahn_travel() -> void:
	var cp := _choice()
	if cp == null:
		return
	var included: bool = has_airport_transfer()
	if Journey.core() and not included and not GameState.has_item("ticket_ubahn"):
		await _ubahn_ticket()
	var has_ticket: bool = included or GameState.has_item("ticket_ubahn")
	var lines: Array = METRO_LINES.get(GameState.city, [])
	var rows: Array = []
	var routes: Dictionary = {}
	var from: String = String(GameState.world_flags.get("transit_from", ""))
	for line in lines:
		var id: String = String(line[0])
		var scene: String = String(line[4])
		# A stop that has not been built yet simply is not on the board, rather
		# than fading to black on a scene that does not exist
		if not ResourceLoader.exists(scene):
			continue
		var label: String = "%s — %s" % [String(line[1]), String(line[2])]
		# The stop he is standing in.
		#
		# It used to be dropped off the board entirely, which is defensible -
		# you cannot catch a train to where you already are - and which reads
		# as a missing station. Somebody in a metro station is looking at the
		# map to work out where they ARE before they work out where to go, and
		# the one thing every real map in the world tells them is the thing
		# this board withheld. So the stop stays on the list, in its place on
		# the line, unpickable, and it says which one it is.
		if scene == from:
			rows.append({
				"id": "",
				"label": label,
				"sub": "(you are here)",
				"disabled": true,
			})
			continue
		routes[id] = scene
		rows.append({
			"id": id,
			"label": label,
			"sub": "Airport transfer included" if included else String(line[3]),
			"disabled": not has_ticket,
		})
	rows.append({
		"id": "",
		"label": "Stay on the platform",
		"sub": "" if has_ticket else "the barriers want a ticket first",
	})
	cp.open("Into the city" if included else "Which train?",
		"Your flight includes this ride. Choose a neighbourhood." if included else
		"the board counts down in numbers you can read, toward names you cannot",
		rows)
	var pick: String = await cp.chosen
	if pick.is_empty() or not has_ticket:
		return
	if not routes.has(pick):
		return
	if included:
		GameState.world_flags.erase("airport_transfer")
	else:
		GameState.remove_item("ticket_ubahn")
	GameState.world_flags["rode_ubahn"] = true
	GameState.advance_clock(30.0 if included else 15.0)
	GameState.spawn_tag = "from_ubahn"
	# Emerge at the destination's real station entrance.
	var hall := get_tree().current_scene
	GameState.last_scene = hall.scene_file_path if hall != null else ""
	TransitionManager.go(String(routes[pick]))
	if included:
		await get_tree().scene_changed
		SaveManager.checkpoint()


# ── U-Bahn lost property — the ridged fragment ───────────────────────────────

func _lost_property() -> void:
	if GameState.has_item("lost_parcel"):
		_think("The clerk recognises me now and shakes his head,\n" +
			"almost kindly. Nothing else of mine has been lost.")
		return
	var cp := _choice()
	if cp == null:
		return
	var fee := 2
	var afford := GameState.money >= fee
	cp.open("Fundbüro",
		"a hatch, a ledger, and shelves of umbrellas going back years. He " +
		"holds up something ridged and dark and raises an eyebrow.",
		[
			{"id": "claim", "label": "Point at it. Then at yourself.",
				"sub": "he taps the ledger and rubs two fingers together — a fee",
				"cost": "%s%d" % [GameState.symbol(), fee], "disabled": not afford},
			{"id": "", "label": "Leave it on the shelf",
				"sub": "" if afford else "he will not take a promise instead of coins"},
		])
	var pick: String = await cp.chosen
	if pick != "claim" or not afford:
		return
	GameState.money -= fee
	GameState.money_changed.emit(GameState.money)
	GameState.drop_item("lost_parcel")
	_think("He writes a line in the ledger, turns the book round, and\n" +
		"taps an empty box. I draw the only mark I know is mine.\n\n" +
		"Whatever is in the bag is warm through the paper."
		+ " Nobody asked me what it was.")


# ── Police found property — the etched fragment ──────────────────────────────

# ── Hotel front desk ─────────────────────────────────────────────────────────
# Berlin's bed came through Frau Weber, who had decided about you. This one is
# a transaction. The alien will notice the difference and not have a word for it.

func _hotel_desk() -> void:
	if Journey.core():
		if GameState.room_booked_here():
			_think("My key is still in my pocket. I have somewhere to come back to.")
			return
		if not await COUNTER_ENCOUNTER.request("room"):
			return
		var booked: bool = GameState.book_room() if GameState.city == "berlin" else GameState.book_room_away()
		if booked:
			COUNTER_ENCOUNTER.received("room")
			_think("A key slides across the counter. They point upstairs, then repeat the word.\n\nThis time I know what I have asked for.")
		return
	if GameState.city == "istanbul":
		await _istanbul_hotel_desk()
		return
	if GameState.room_booked_here():
		_think("The key is already in my pocket. She looks at me the way\n" +
			"you look at furniture you have stopped noticing.")
		return
	var price: int = GameState.room_price()
	var sym: String = GameState.symbol()
	var cp := _choice()
	if cp == null:
		return
	var can_pay: bool = GameState.money >= price
	cp.open("Reception",
		"a laminate counter, fourteen hooks where there should be fifteen, " +
		"and a woman who has already asked how I am and did not wait.",
		[
			{"id": "book", "label": "Show your journey pass" if Journey.core() else "Put the money on the counter",
				"sub": "Your room is included" if Journey.core() else "%s%d for the night" % [sym, price],
				"disabled": not can_pay},
			{"id": "ask", "label": "Point at the breakfast card",
				"sub": "7 - 9.30, and in biro, not sundays"},
			{"id": "", "label": "Say the thing she said to you, back at her",
				"sub": "\"you alright\" — it seemed to be a greeting"},
		])
	var id: String = await cp.chosen
	match id:
		"book":
			if GameState.book_room_away():
				_think("A key, a number, and a stair with no lift.\n\n" +
					"She said \"lovely\" three times. None of them were about me.")
			else:
				_think("Not enough. She keeps the key on the hook and her face\n" +
					"exactly where it was.")
		"ask":
			_think("She said \"half seven\" and I understood every sound in it.\n\n" +
				"Half of seven is three and a half. That cannot be what she meant.")
		_:
			_think("I said it back to her. She laughed — not unkindly — and\n" +
				"answered a question I had not asked.\n\nSo it was not a question.")


func _istanbul_hotel_desk() -> void:
	if GameState.room_booked_here():
		_think("The key is in my pocket. She points to the stairs marked ODALAR.\n\nA room upstairs, and somewhere to come back to.")
		return
	var cp := _choice()
	if cp == null:return
	var price: int = GameState.room_price()
	cp.open("Resepsiyon", "A key rack, a small glass of tea, and a handwritten price card. She turns the card towards me and waits.", [
		{"id":"book", "label":"Show your journey pass", "sub":"Your room is included", "disabled":GameState.money<price},
		{"id":"ask", "label":"Point at the breakfast card", "sub":"Kahvaltı · 07.00–10.00"},
		{"id":"", "label":"Return her greeting", "sub":"Merhaba"}
	])
	var id: String = await cp.chosen
	match id:
		"book":
			if GameState.book_room_away():
				_think("She slides over the key and points to the stairs on the left.\n\n\"İyi dinlenmeler.\" I do not know every word. I understand the wish.")
			else:_think("I count again. Not quite enough for the room yet.")
		"ask":_think("She taps seven, then ten, and points to the breakfast room.\n\nA few numbers can be a small kindness.")
		_:_think("\"Merhaba.\" She smiles and says it back.\n\nA beginning I can manage.")

# ── Yusuf's shop ─────────────────────────────────────────────────────────────
# The last fragment, and the only one that cannot be paid for, filed for, or
# argued out of anybody. It is on a cord above his doorway between two blue
# glass eyes, and Yusuf does not consider it a thing that can change hands.
#
# The act is a ladder of refusals the player must NOT make. Every rung is a
# move that was correct in Berlin (settle up, owe nothing) or in London (find
# the right channel) and is wrong here. Progress is measured in hours spent
# achieving nothing, which is the one currency the player has not been taught.

func _yusuf_stage() -> int:
	return int(GameState.world_flags.get("yusuf_stage", 0))


func _yusuf_advance() -> void:
	GameState.world_flags["yusuf_stage"] = _yusuf_stage() + 1


func _yusuf_shop() -> void:
	if GameState.has_item("charm_eye"):
		_think("Yusuf is asleep in the good chair with the radio on.\n\n" +
			"I have a key to a shop I do not own, in a city I cannot read.")
		return
	match _yusuf_stage():
		0: await _yusuf_tea()
		1: await _yusuf_sit()
		2: await _yusuf_meal()
		3: await _yusuf_work()
		_: await _yusuf_charm()


# Rung one. The glass arrives before a word is exchanged. It is not a
# transaction and treating it as one ends the conversation permanently politely.
func _yusuf_tea() -> void:
	var cp := _choice()
	if cp == null:
		return
	cp.open("Yusuf",
		"He has poured before I finished coming through the door. The glass " +
		"is too hot to hold and he is already talking, to me, about nothing.",
		[
			{"id": "take", "label": "Take the glass",
				"sub": "it is too hot. hold it anyway"},
			{"id": "pay", "label": "Put coins on the counter for it",
				"sub": "settle up. owe nothing. it has worked twice"},
			{"id": "refuse", "label": "Hold up a hand and decline",
				"sub": "there is no time, and it is right there on the cord"},
		])
	var id: String = await cp.chosen
	match id:
		"take":
			_yusuf_advance()
			GameState.expose("turkish", "çay", "pointed")
			_think("Too hot to hold, so I hold it wrong, and he laughs and\n" +
				"shows me the rim — two fingers, at the top, where it is cool.\n\n" +
				"He did not want anything. I keep waiting for the part where\n" +
				"he wants something.")
		"pay":
			GameState.change_reputation("han", -8)
			_think("The coins are still on the counter. He has not touched them\n" +
				"and he will not, and the talking has stopped.\n\n" +
				"I have paid for something that was not for sale.")
		_:
			GameState.change_reputation("han", -5)
			_think("He put the glass down where I would have to reach past it\n" +
				"to leave, and went back to his shelves.\n\nThe glass went cold.")


# Rung two. He will not talk business standing. An hour with nothing agreed is
# not a delay before the work — it IS the work.
func _yusuf_sit() -> void:
	var cp := _choice()
	if cp == null:
		return
	cp.open("Yusuf",
		"There is a second stool out. There was a second stool out the last " +
		"time too. He has not once looked at it or mentioned it.",
		[
			{"id": "sit", "label": "Sit down and let the hour go past",
				"sub": "nothing gets agreed. that appears to be allowed"},
			{"id": "ask", "label": "Point up at the cord above the doorway",
				"sub": "the thing between the two blue eyes"},
			{"id": "offer", "label": "Show him money",
				"sub": "name a number. it has always been a number"},
		])
	var id: String = await cp.chosen
	match id:
		"sit":
			_yusuf_advance()
			GameState.expose("turkish", "otur", "used")
			GameState.change_reputation("han", 4)
			_think("An hour. Maybe two. He talked and I understood one word in\n" +
				"nine and it did not seem to matter to either of us.\n\n" +
				"Nothing was agreed. Something happened anyway.")
		"offer":
			# Price is the insult: it says his luck has a number, and that he
			# looks like a man who needs cash.
			GameState.change_reputation("han", -12)
			_think("His face did something quick and then stopped doing it.\n\n" +
				"He said a short sentence I did not need translated, and\n" +
				"poured more tea, and did not sit down again.")
		_:
			_think("He looked where I pointed, for a long moment, and then at me,\n" +
				"and then he asked me something gently and changed the subject\n" +
				"for both of us.")


# Rung three. Meryem never asks a question the alien cannot answer. She asks
# whether it is hungry — which can be answered with a plate.
func _yusuf_meal() -> void:
	var cp := _choice()
	if cp == null:
		return
	cp.open("Meryem",
		"She feeds whoever is in the shop at the hour she feeds people. She " +
		"has not asked my name. She has put down a third plate and I am full.",
		[
			{"id": "eat", "label": "Eat the fourth plate",
				"sub": "you are full. stopping says the food was not good"},
			{"id": "stop", "label": "Put a hand over the plate",
				"sub": "the polite thing, everywhere else you have been"},
			{"id": "pay", "label": "Try to pay her",
				"sub": "surely this one. surely this one is payable"},
		])
	var id: String = await cp.chosen
	match id:
		"eat":
			_yusuf_advance()
			GameState.expose("turkish", "ye", "used")
			GameState.change_reputation("han", 6)
			_think("I ate the fourth plate. It hurt a little.\n\n" +
				"She sat down for the first time all evening, and that was\n" +
				"the answer to a question nobody had asked out loud.")
		"pay":
			GameState.change_reputation("han", -10)
			_think("She laughed, and then understood that I meant it, and then\n" +
				"was quiet in a way I have not heard from her.")
		_:
			GameState.change_reputation("han", -4)
			_think("She took the plate away without a word and did not offer\n" +
				"a fifth. Something closed that had been open.")


# Rung four. The unpaid work — and then refusing the money, which is the exact
# inverse of Berlin, where refusing payment would have been incomprehensible.
func _yusuf_work() -> void:
	var cp := _choice()
	if cp == null:
		return
	cp.open("The shop",
		"I have swept it. I carried the trays. I sat with Meryem for an hour " +
		"while she did not need help. Yusuf is holding out folded notes and " +
		"will not put his hand down.",
		[
			{"id": "refuse", "label": "Fold his hand shut around it",
				"sub": "in Berlin this would have been incomprehensible"},
			{"id": "take", "label": "Take the money",
				"sub": "work is paid. that is what work is"},
		])
	var id: String = await cp.chosen
	match id:
		"refuse":
			_yusuf_advance()
			GameState.change_reputation("han", 10)
			_think("He put the notes away and looked at me properly, for what\n" +
				"I think was the first time.\n\n" +
				"I am not a customer any more. I do not know what I am.")
		_:
			GameState.change_reputation("han", -6)
			_think("He paid me. He was pleased to pay me. He is pleased with me\n" +
				"the way you are pleased with a good transaction.\n\n" +
				"I have been put back outside, and he was kind about it.")


# The charm comes down. It does not arrive clean — there is a hole drilled
# through it by a brother who is not here, and that hole is why it could be
# worn at all.
func _yusuf_charm() -> void:
	var cp := _choice()
	if cp == null:
		return
	cp.open("The cord above the door",
		"He took it down himself, without being asked, on an ordinary " +
		"afternoon, and held it out on his flat palm with the drilled hole " +
		"turned up so I could see it first.",
		[
			{"id": "take", "label": "Take it, and look at the hole",
				"sub": "Kerem drilled it. that is why it could be hung at all"},
			{"id": "wait", "label": "Not yet",
				"sub": "leave it on the cord a while longer"},
		])
	var id: String = await cp.chosen
	if id != "take":
		_think("He put it back up between the two eyes and did not ask why.")
		return
	GameState.drop_item("charm_eye")
	GameState.change_reputation("han", 12)
	_think("There is a hole through it that should not be there.\n\n" +
		"His brother made that hole, four years ago, because he thought it\n" +
		"was pretty. The shop has done well since. Nobody in this family\n" +
		"thinks those two things are unrelated and nobody will say so.\n\n" +
		"I am carrying a piece of my own machine and someone else's luck.")


func _police_desk() -> void:
	if GameState.has_item("police_bag"):
		_think("The officer nods at me the way you nod at furniture\n" +
			"you have stopped noticing. Our business is done.")
		return
	var cp := _choice()
	if cp == null:
		return
	# You cannot claim it with words. You claim it by matching it.
	var can_prove: bool = GameState.has_item("hospital_dish")
	cp.open("Police — Lost property" if GameState.city == "london" else "Polizeiwache — Fundsachen",
		"a numbered bag on the counter, and inside it something with your " +
		"markings on it. The officer's questions are a wall of sound.",
		[
			{"id": "match", "label": "Put what they took out of you beside the bag",
				"sub": "let the edges answer for you — they were one piece once",
				"disabled": not can_prove},
			{"id": "insist", "label": "Point at the bag. Point at your chest. Again.",
				"sub": "he has heard this from better liars"},
			{"id": "", "label": "Go, before this becomes something else"},
		])
	var pick: String = await cp.chosen
	match pick:
		"match":
			GameState.drop_item("police_bag")
			GameState.change_reputation("mitte", 2)
			_think("I set my shard on the counter. He looks at it, at the bag,\n" +
				"at the two broken edges that only fit each other.\n\n" +
				"Something in his face changes. He slides the bag across,\n" +
				"and says a short word I decide to believe means: yours.")
		"insist":
			GameState.change_reputation("mitte", -1)
			_think("I point until pointing becomes rude. He puts the bag\n" +
				"under the counter and writes something down.\n\n" +
				"Insisting is not the same as proving. I will have to come\n" +
				"back with the piece that fits it.")


# ── Hospital — the shard they take out of you ────────────────────────────────

func _hospital_desk() -> void:
	if GameState.has_item("hospital_dish"):
		_think("The nurse points at my side, then gives a thumbs-up she
" +
			"clearly learned from a film. It is healing.")
		return
	var cp := _choice()
	if cp == null:
		return
	# The form is a language too, and it is the one in this building the alien
	# has no chance with. It gets exactly one attempt. That attempt costs the
	# patience of the queue, and it fails — because a body is not a thing
	# paperwork can hold, and no amount of trying harder makes it one.
	#
	# Two passes at most: the form, and then whatever the player does after it.
	for _attempt in range(2):
		var tried: bool = bool(GameState.world_flags.get("tried_the_form", false))
		cp.open("Triage" if GameState.city == "london" else "Anmeldung", _anmeldung_blurb(tried), _anmeldung_rows(tried))
		var pick: String = await cp.chosen
		if pick == "show":
			_anmeldung_treat(tried)
			return
		if pick != "forms" or tried:
			return
		GameState.world_flags["tried_the_form"] = true
		GameState.change_reputation("mitte", -2)
		_think("Three boxes filled with marks that mean nothing here, and
" +
			"a fourth I cannot even guess at. She reads them. She does not
" +
			"laugh, which I appreciate.

" +
			"Then she slides it back and taps the same empty box, and the
" +
			"queue behind me has grown by four people, and one of them sighs.

" +
			"I have been trying to turn myself into a document.")


func _anmeldung_rows(tried: bool) -> Array:
	var rows: Array = [
		{"id": "show", "label": "Lift your shirt and show her the wound",
			"sub": "the skin there has been warm since the landing"},
	]
	if tried:
		rows.append({"id": "forms", "label": "Try the form again",
			"sub": "the same boxes, and still nothing true to put in them",
			"disabled": true})
	else:
		rows.append({"id": "forms",
			"label": "Try to fill in the form she slides over",
			"sub": "every box is a small locked door"})
	rows.append({"id": "", "label": "Turn around and leave"})
	return rows


func _anmeldung_blurb(tried: bool) -> String:
	if tried:
		return "she has the form back and she is not angry about it. She is " 			+ "not going to ask a third time either. She is waiting for " 			+ "whatever I have that is not writing."
	return "she asks for something — a card, a name, a number. I have none " 		+ "of them. Behind her, someone is already pulling a curtain back."


# The counter stops being a counter. Whether the player fought the paper first
# is remembered, here in the prose and later in the ending.
func _anmeldung_treat(tried: bool) -> void:
	GameState.drop_item("hospital_dish")
	GameState.change_reputation("mitte", 2)
	var opening: String = "No card. No name they can spell. They treat me anyway."
	if tried:
		opening = "No card. No name they can spell. One form ruined.
" 			+ "They treat me anyway, and nobody mentions the form again."
	_think(opening + "

" +
		"Behind the curtain: a light, a cold line drawn across my side,
" +
		"and then a small ridged thing dropped into a metal dish.

" +
		"It has been inside me since the sky. One piece back.")


# The district itself
# ----------------------------------------------------------------------------
# A district is not a menu. The first version of this was: pick one of three
# lines, get a paragraph of inner monologue, done - which is a list with
# consequences bolted on, not an activity.
#
# So a streetside spot is a small scene you play. It is a state machine of
# BEATS. Each beat is a situation and two to four things you can do about it,
# and what you did changes which beat you land in next. That gives the three
# things the flat version could not have:
#
#   watching first is worth something   a beat can require that you have
#                                       already been somewhere ("needs"), so
#                                       the correct move is only available to
#                                       someone who looked before acting. That
#                                       is the entire thesis of this game
#                                       expressed as a lock.
#   you can get it wrong                a wrong move lands in a different beat
#                                       with its own choices, usually one that
#                                       lets you recover and one that does not
#   the outcome is not always yours      a beat can toss between two endings,
#                                       so drawing a fortune is a real draw
#
# Beats can charge money, move reputation, teach a word, hand over an object,
# and set a world flag. Coming back a second time starts somewhere else, so a
# place you have already worked out reads as one you have already worked out.

const SS := preload("res://scenes/world/Streetside.gd")

# How many beats one visit may run before we call it a loop and stop. Data
# with a cycle in it would otherwise hang the game with the panel open.


func _local() -> void:
	if Journey.core():
		await Journey.play_activity()
		return
	var region: String = GameState.current_region
	var data: Dictionary = SS.spot(GameState.city, region)
	if data.is_empty():
		_think("Nothing on this street is asking anything of me.")
		return

	# No panel. The activity is a reel: it plays, he narrates it, and what it
	# does to him lands at the end. The beat graph is still what is authored -
	# it is walked rather than offered, taking the first move he can afford at
	# each step.
	#
	# The walk itself lives in Streetside.reel(), not here, because it was
	# also written out longhand in tools/playreel.gd and the two had drifted:
	# the tool ignored price and always took the first toss, so the contact
	# sheet you inspected was not the reel the player saw. One implementation,
	# two callers.
	var flag: String = "spot_" + region
	var seen_before: bool = bool(GameState.world_flags.get(flag, false))
	var built: Dictionary = SS.reel(GameState.city, region, GameState.money,
		seen_before)
	var reel: Array = built.get("shots", [])

	if reel.is_empty():
		_think("Nothing on this street is asking anything of me.")
		return

	var cs := get_tree().get_first_node_in_group("cutscene")
	if cs != null:
		cs.play(GameState.city, reel)
		await cs.finished

	var spent: int = int(built.get("spent", 0))
	if spent > 0:
		GameState.money -= spent
		GameState.money_changed.emit(GameState.money)
	for beat2: Dictionary in built.get("owed", []):
		_beat_effects(beat2, region)
	GameState.world_flags[flag] = true


# Everything a beat does to the world. Applied after the reel has run, not
# while it is running, so nothing changes under the player mid-scene.
func _beat_effects(beat: Dictionary, region: String) -> void:
	var rep: int = int(beat.get("rep", 0))
	if rep != 0:
		GameState.change_reputation(region, rep)
	for w in beat.get("learn", []):
		var pair: Array = w
		GameState.expose(String(pair[0]), String(pair[1]), "see")
	var item: String = String(beat.get("item", ""))
	if not item.is_empty():
		GameState.drop_item(item)
	# A beat can put money in his hand as well as take it out of it - the
	# deposit on a bottle comes back, and being paid for a small thing is
	# how half the world's streets actually work.
	var coin: int = int(beat.get("coin", 0))
	if coin != 0:
		GameState.money += coin
		GameState.money_changed.emit(GameState.money)
	var wf: String = String(beat.get("flag", ""))
	if not wf.is_empty():
		GameState.world_flags[wf] = true


# ── Airport — the flights ────────────────────────────────────────────────────
# One desk, fifteen cities, and it is the same desk in all of them.
#
# The desk does not hand the player a list. Every other counter in this game
# does, and a list of place names would be the alien reading words again — so
# the board turns round and it is a map, and the destination is chosen by
# pointing. See scenes/ui/WorldMap.gd.
#
# The rule underneath every refusal: a city does not let you leave until you
# have what you came for, you have slept there, and you can answer the person
# behind the glass. That is not an inventory lock. It is the thesis pointed at
# a departures board.
#
# This file owns the rules. The map is told what is open and draws that; it
# never decides anything, which is why the answer is asked for twice — once to
# colour the marker, and again when the marker is clicked.

# What the desk needs to hear before it sells you a seat. She is behind glass,
# she is on a schedule, and she will not draw pictures — so this is the one
# counter in the game where not knowing the words is what stops you.
#
# Only Berlin so far. A city earns an entry here when its word table lands;
# putting a number in before then would wall off a language nobody can learn.
const DESK_WORDS := {"berlin": 12}

# The order the trail runs in. Everywhere you have already been stays open, and
# the next unvisited city opens as soon as the one you are in is finished with
# you — so the map fills in as you go, instead of offering fifteen strangers
# on the first morning.
const TRAIL := ["berlin", "zurich", "hanoi", "london", "paris", "tokyo",
	"rome", "moscow", "newyork", "toronto", "mexico", "saopaulo",
	"dakar", "tbilisi", "seoul", "sydney", "honolulu", "mumbai",
	"istanbul", "lapaz"]

const DESK_TITLES := {
	"berlin":   "Abflug — departures",
	"zurich":   "Abflug — departures",
	"london":   "Departures",
	"rome":     "Partenze — departures",
	"moscow":   "Vylet — departures",
	"mexico":   "Salidas — departures",
	"saopaulo": "Partidas — departures",
	"dakar":    "Départs — departures",
	"istanbul": "Giden Yolcu — departures",
	"lapaz":    "Salidas — departures",
	"paris":    "Départs — departures",
	"sydney":   "Departures",
	"honolulu": "Departures",
	"newyork":  "Departures",
	"toronto":  "Departures",
}


func _airport_desk() -> void:
	if _boarding: return
	var wm := get_tree().get_first_node_in_group("world_map")
	if wm == null:
		_think("The board turns over and over and I cannot make it mean\n" +
			"anything. There is nobody behind the desk.")
		return
	var here: String = GameState.city
	var fare: int = GameState.flight_fare()
	var routes: Dictionary = {}
	for dest: String in GameState.CITIES.keys():
		if dest == here:
			continue
		routes[String(dest)] = _route_row(String(dest))
	wm.open(routes, _fare_line(fare))
	var pick: String = await wm.chosen
	if pick.is_empty() or not GameState.CITIES.has(pick):
		return
	# Asked a second time rather than trusting the marker that was clicked.
	if not _flight_block(pick).is_empty():
		return
	_board_flight(pick, fare)


# One destination, as the map needs it: whether you can go, and what it says.
func _route_row(dest: String) -> Dictionary:
	if not Journey.core(dest):
		return {"ok": false, "note": "This beta follows eight cities. More journeys will open later."}
	if not GameState.city_reachable(dest):
		return {"ok": false, "note": "nothing on the board goes there"}
	var block: String = _flight_block(dest)
	if block.is_empty():
		var arrival := GameState.CLOCK.text_at(GameState.clock_minutes + GameState.CLOCK.flight_minutes(GameState.city, dest), dest)
		return {"ok": true, "note": "Arrives %s local time. %s" % [arrival, _dest_note(dest)]}
	return {"ok": false, "note": block}


func _fare_line(fare: int) -> String:
	if Journey.core():
		return "A seat costs %s%d, including the transfer into town. Your allowance covers any shortfall. You land at the airport; you can always return." % [GameState.symbol(), fare]
	var have: int = GameState.money
	var head: String = "a seat is %s%d, and you have %s%d" \
		% [GameState.symbol(), fare, GameState.symbol(), have]
	if have < fare:
		return head + " — which is not enough for any of them"
	return head


# Buy the seat and go. Order matters: the fare comes out of the wallet you are
# standing in, and the quest step belongs to the city you are leaving, so both
# have to happen before travel_to() moves the pocket under you.
func _board_flight(dest: String, fare: int) -> void:
	if _boarding or TransitionManager._busy or get_tree().paused: return
	if dest == GameState.city or not GameState.city_reachable(dest) or not _flight_block(dest).is_empty(): return
	_boarding = true
	var from: String = GameState.city
	var film := FLIGHT.new()
	film.origin = from
	film.destination = dest
	add_child(film)
	await film.finished
	# Nothing is spent or moved while the old airport is still on screen.
	Journey.ensure_funds(fare)
	GameState.money -= fare
	GameState.money_changed.emit(GameState.money)
	GameState.world_flags["ticket_" + dest] = true
	GameState.world_flags["left_" + from] = true
	GameState.complete_last_step("leave_" + from)
	GameState.advance_clock(GameState.CLOCK.flight_minutes(from, dest))
	GameState.travel_to(dest)
	GameState.world_flags["airport_transfer"] = dest
	GameState.spawn_tag = ""
	GameState.last_scene = ""     # you do not arrive through a door
	GameState.entered_from = ""
	GameState.world_flags.erase("transit_from")
	GameState.skip_next_visit_count = false
	TransitionManager.go(String(GameState.ARRIVALS.get(dest, "")))
	await get_tree().scene_changed
	SaveManager.checkpoint()
	film.queue_free()
	_boarding = false


# Why you are not getting on that plane, in the alien's own terms. An empty
# string means the seat is yours.
#
# The order is the point. The first true thing is the thing the desk says, and
# it should be the most human one — what you are still carrying, then where you
# slept, then whether you can answer her — rather than the till.
func _flight_block(dest: String) -> String:
	if not Journey.core(dest):
		return "This destination is outside the eight-city beta."
	if Journey.core():
		return ""
	var here: String = GameState.city
	if not GameState.rested_here():
		return "you have not slept in this city. She asks where you stayed " \
			+ "and there is no answer you can give that is true"
	var need: int = int(DESK_WORDS.get(here, 0))
	var have: int = GameState.words_usable(GameState.local_language())
	if have < need:
		return "three questions through the glass, at speed, and no miming. " \
			+ "%d more words and one of them might land" % (need - have)
	if not _trail_open(dest):
		return "you have not heard of it yet. Somebody would have to tell " \
			+ "you it was there"
	if GameState.money < GameState.flight_fare():
		return "the number on the board is not a suggestion, and you are short"
	return ""


# Somewhere you have already been, or the one place the trail points at next.
func _trail_open(dest: String) -> bool:
	if bool(GameState.world_flags.get("visited_" + dest, false)):
		return true
	if dest == "berlin":
		return true          # the field is always behind you
	for id: String in TRAIL:
		if id == "berlin":
			continue
		if bool(GameState.world_flags.get("visited_" + id, false)):
			continue
		return dest == id
	return false


# What the board says about somewhere you have not been. It used to say who
# had taken a piece of the pod there; now it says the only thing that is
# still true, which is that you have not been.
func _dest_note(dest: String) -> String:
	if bool(GameState.world_flags.get("visited_" + dest, false)):
		return "you have been. You could go back"
	if dest == "berlin":
		return "the field is still there, and so is the burn ring"
	return "you have never been. That is the only reason to go"
