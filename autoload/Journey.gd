extends Node

const CHAPTERS := preload("res://scenes/story/CityChapters.gd")
const SS := preload("res://scenes/world/Streetside.gd")
const VERSION := preload("res://autoload/BuildInfo.gd").VERSION
var busy := false


func core(city: String = "") -> bool:
	return Story.MANDATORY.has(GameState.city if city.is_empty() else city)


# Cities whose story has been rebuilt around deciphering - played in the street
# with the game's own glyphs, voices, register and hospitality, rather than as
# the simplified choice-panel chapters below. Everything cultural stays switched
# on in these; see scenes/story/berlin/ for the first of them.
const REBUILT := ["berlin", "istanbul", "london", "paris", "moscow", "mumbai", "tokyo", "mexico"]
const BERLIN := preload("res://scenes/story/berlin/BerlinStory.gd")

# Cumulative outings before the second and third conversations. The required
# personal discovery still matters; unrelated sightseeing is never a chore tax.
const OUTING_PLAN := {
	"berlin": [1, 3], "istanbul": [1, 2], "london": [1, 1],
	"paris": [1, 2], "moscow": [0, 1], "mumbai": [1, 1],
	"tokyo": [1, 2], "mexico": [0, 1]
}

const OUTING_INTENT := {
	"istanbul": "See what the hanging bread tickets mean in the Çarşı, and choose one other neighbourhood to explore.",
	"london": "Drop into the high-street caff. Nadia wants to hear what happened, not collect a delivery.",
	"paris": "Find something Odile would not have noticed in Belleville; choose one other neighbourhood for your page.",
	"moscow": "Look at the market trays in Izmaylovo. Bring back a detail for Viktor's drawing; buying is optional.",
	"mumbai": "Explore Chor Bazaar for Omkar's design. Look and ask; no shopping list is required.",
	"tokyo": "Visit Asakusa and one other neighbourhood. Keep something from the walk for your wish strip.",
	"mexico": "Explore La Merced, then return to Rocío's table. You are bringing a memory, not an order."
}


func rebuilt(city: String = "") -> bool:
	return REBUILT.has(GameState.city if city.is_empty() else city)


func simplified(city: String = "") -> bool:
	return core(city) and not rebuilt(city)


func ledger() -> Dictionary:
	if not GameState.world_flags.has("journey_v1"):
		GameState.world_flags["journey_v1"] = {"activities": {}, "chapters": {},
			"memories": {}, "phrases": {}, "history": []}
	return GameState.world_flags["journey_v1"]


func refill_pocket() -> void:
	if not core():
		return
	var allowance: int = maxi(20, GameState.convert_preview(20, "EUR", GameState.currency()))
	GameState.money = maxi(GameState.money, allowance)
	GameState.money_changed.emit(GameState.money)
	SaveManager.checkpoint()


func ensure_funds(price: int) -> void:
	if not core() or price <= GameState.money:
		return
	# A safety net at payment, not a task or an answer to the conversation.
	var pocket: int = maxi(20, GameState.convert_preview(20, "EUR", GameState.currency()))
	GameState.money = maxi(price, pocket)
	GameState.money_changed.emit(GameState.money)


func record(title: String, text: String) -> void:
	var history: Array = ledger()["history"]
	history.append({"title": title, "text": text, "city": GameState.city})
	if history.size() > 100:
		history.pop_front()


func learn(city: String, phrase: Array, source: String) -> void:
	# [native script, pronunciation, meaning, vocabulary keys]. Each distinct
	# context teaches once; reopening a panel is not a second encounter.
	if phrase.size() < 4:
		return
	var key: String = city + ":" + String(phrase[0])
	var saved: Dictionary = ledger()["phrases"].get(key, {"city": city,
		"native": phrase[0], "reading": phrase[1], "meaning": phrase[2], "sources": []})
	if Array(saved["sources"]).has(source):
		return
	saved["sources"].append(source)
	ledger()["phrases"][key] = saved
	var language: String = String(GameState.CITIES[city]["language"])
	for word: String in phrase[3]:
		GameState.expose(language, word, "hear")


func completed_activities(city: String) -> Array:
	var done: Array = []
	for outing: Array in CHAPTERS.CITIES[city]["outings"]:
		if bool(GameState.world_flags.get("spot_" + String(outing[0]), false)):
			done.append(outing[0])
	return done


func ready_for_round(city: String) -> bool:
	var round_i: int = Story.rounds_done(city)
	if round_i == 0 or round_i >= Story.ROUNDS:
		return true
	var count: int = completed_activities(city).size()
	var plan: Array = OUTING_PLAN.get(city, [1, 3])
	return count >= int(plan[0]) if round_i == 1 else count >= int(plan[1]) and Story.errand_done(city)


func next_outing(city: String) -> Array:
	var outings: Array = CHAPTERS.CITIES[city]["outings"]
	var done: Array = completed_activities(city)
	if Story.rounds_done(city) >= 2 and not Story.errand_done(city):
		for outing: Array in outings:
			if outing[0] == Story.errand_of(city).get("region", ""):
				return outing
	for outing: Array in outings:
		if not done.has(outing[0]):
			return outing
	return outings[0]


func next_step(city: String) -> String:
	if city == "berlin":
		return BERLIN.next_step()
	var who: String = Story.person_name(city)
	if Story.holiday_seen(city):
		return "Visit again for a familiar face, or choose your next destination at the airport."
	if not ready_for_round(city):
		var outing: Array = next_outing(city)
		if Story.rounds_done(city) >= 2:
			return String(OUTING_INTENT.get(city, "Explore the neighbourhood.")) + " Next: " + GameState.region_name(outing[0]) + "."
		return "Take a walk before seeing %s again. The activity in %s is one place to start." % [who, GameState.region_name(outing[0])]
	return "%s %s" % [Services.meeting_directions(city),
		"Your invitation is ready; there is no calendar to wait for." if Story.is_friend(city) else "You can point, ask for help, or try the words. Fluency is not required."]


func guide(city: String) -> void:
	if city == "berlin":
		BERLIN.guide()
		return
	# One city intention follows its changing location. Old story quests are
	# retired, not deleted, so existing saves retain their earlier history.
	for id: String in ["earn_keep", "learn_" + city, "meet_" + city, "errand_" + city, "holiday_" + city]:
		if GameState.quests.has(id):
			var old: Dictionary = GameState.quests[id]
			if not bool(old.get("completed", false)):
				for step: Dictionary in old.get("steps", []):
					step["done"] = true
				old["completed"] = true
				GameState.quest_updated.emit(id)
	var id: String = "journey_" + city
	var scene: String = Story.path(Story.SCENE[city])
	var count: int = completed_activities(city).size()
	var r: int = Story.rounds_done(city)
	var plan: Array = OUTING_PLAN.get(city, [1, 3])
	var states: Array = [r >= 1, count >= int(plan[0]) or r >= 2, r >= 2,
		(count >= int(plan[1]) and Story.errand_done(city)) or r >= 3, r >= 3, Story.holiday_seen(city)]
	var destination: String = scene if ready_for_round(city) else Story.path(next_outing(city)[1])
	var meeting := Services.meeting_directions(city)
	var outing_route := Services.route_directions(city, destination)
	var steps: Array = [meeting,
		"Stay for the next conversation" if int(plan[0]) == 0 else "Try a neighbourhood activity",
		"Share the next part of the conversation. " + meeting, String(OUTING_INTENT.get(city, "Explore the neighbourhood.")),
		"Return to your friend. " + meeting, "Join the celebration with %s at %s." % [Story.person_name(city), String(Story.WHERE[city])]]
	if not ready_for_round(city):
		steps[1] += ". " + outing_route
		steps[3] += " " + outing_route
	GameState.start_quest(id, String(CHAPTERS.CITIES[city]["title"]), steps,
		[scene, destination, scene, destination, scene, scene])
	var q: Dictionary = GameState.quests[id]
	var changed := false
	for i in range(states.size()):
		var step: Dictionary = q["steps"][i]
		if step["done"] != states[i] or step["target"] != destination or step["text"] != steps[i]:
			step["done"] = states[i]
			step["target"] = destination
			step["text"] = steps[i]
			changed = true
	q["completed"] = Story.holiday_seen(city)
	if changed:
		GameState.quest_updated.emit(id)


func talk(city: String) -> void:
	if city == "berlin":
		# Berlin is played in the street, by whoever is standing in it.
		var stage := get_tree().get_first_node_in_group("berlin_stage")
		if stage != null and not stage.busy():
			await stage.play(stage.due("kerstin"))
		return
	if busy:
		return
	busy = true
	# A scene change destroys a director's pending awaits. Release the global
	# conversation lock as well, so the next city's friend remains available.
	var host: Node = get_tree().current_scene
	var release: Callable = func():
		busy = false
		host.set_meta("story_departing", true)
	if host != null:
		host.tree_exiting.connect(release, CONNECT_ONE_SHOT)
	var cp := get_tree().get_first_node_in_group("choice_panel")
	if cp == null:
		busy = false
		return
	if not Story.has_met(city):
		Story.mark_met(city)
	if not ready_for_round(city):
		cp.open(Story.person_name(city), next_step(city), [{"id": "ok", "label": "I'll have a look"}])
		await cp.chosen
	elif Story.holiday_seen(city):
		var memory: String = String(ledger()["memories"].get(city, CHAPTERS.CITIES[city]["return"]))
		cp.open("A familiar face · " + Story.person_name(city), String(CHAPTERS.CITIES[city]["return"]) + "\n\n" + memory,
			[{"id": "ok", "label": "Stay a moment, then carry on"}])
		await cp.chosen
	else:
		var round_i: int = mini(Story.rounds_done(city), 3)
		if city == "istanbul":
			await load("res://scenes/story/istanbul/IstanbulStory.gd").play(round_i)
		elif city == "london":
			await load("res://scenes/story/london/LondonStory.gd").play(round_i)
		elif city == "paris":
			await load("res://scenes/story/paris/ParisStory.gd").play(round_i)
		elif city == "moscow":
			await load("res://scenes/story/moscow/MoscowStory.gd").play(round_i)
		elif city == "mumbai":
			await load("res://scenes/story/mumbai/MumbaiStory.gd").play(round_i)
		elif city == "tokyo":
			await load("res://scenes/story/tokyo/TokyoStory.gd").play(round_i)
		elif city == "mexico":
			await load("res://scenes/story/mexico/MexicoStory.gd").play(round_i)
		elif await play_chapter(city, round_i):
			if round_i < 3:
				Story.add_round(city)
			else:
				var cs := get_tree().get_first_node_in_group("cutscene")
				if cs != null:
					cs.play(city, holiday_reel(city), true)
					await cs.finished
					if cs.completed:
						Story.mark_holiday(city)
	if not is_instance_valid(host) or host.is_queued_for_deletion() or host.has_meta("story_departing"):
		busy = false
		return
	Story.guide()
	SaveManager.checkpoint()
	busy = false
	if is_instance_valid(host) and host.tree_exiting.is_connected(release):
		host.tree_exiting.disconnect(release)


func play_chapter(city: String, chapter: int) -> bool:
	var key: String = city + ":" + str(chapter)
	var state: Dictionary = ledger()["chapters"].get(key, {"at": 0, "choices": {}, "pending": ""})
	ledger()["chapters"][key] = state
	var beats: Array = CHAPTERS.CITIES[city]["chapters"][chapter]
	var cp := get_tree().get_first_node_in_group("choice_panel")
	if cp == null:
		return false
	while int(state["at"]) < beats.size() or not String(state["pending"]).is_empty():
		# Choice, effects and next cursor commit together. Leaving during the
		# response shows it again without awarding anything twice.
		if not String(state["pending"]).is_empty():
			cp.open(Story.person_name(city), String(state["pending"]), [{"id": "next", "label": "Continue"}])
			if String(await cp.chosen).is_empty():
				return false
			state["pending"] = ""
			continue
		var at: int = int(state["at"])
		var beat: Dictionary = beats[at]
		var text: String = String(beat["text"])
		var callback: String = String(beat.get("callback", ""))
		if not callback.is_empty():
			text += "\n\n" + String(ledger()["memories"].get(city, callback))
		var phrase: Array = beat.get("phrase", [])
		if not phrase.is_empty():
			text += "\n\n" + String(phrase[0])
			if phrase[1] != phrase[0] and not String(phrase[1]).is_empty():
				text += "  ·  " + String(phrase[1])
		var rows: Array = []
		for i in range(beat["choices"].size()):
			rows.append({"id": str(i), "label": beat["choices"][i][0]})
		cp.open(String(beat.get("title", Story.person_name(city))), text, rows)
		var pick: String = await cp.chosen
		if pick.is_empty():
			return false
		var selected: Array = beat["choices"][int(pick)]
		state["choices"][str(at)] = int(pick)
		state["at"] = at + 1
		state["pending"] = selected[1]
		if phrase.size() >= 3:
			state["pending"] += "\n\nLooking back at the exchange: “%s” — %s" % [phrase[0], phrase[2]]
		if selected.size() > 2:
			ledger()["memories"][city] = selected[2]
		learn(city, phrase, key + ":" + str(at))
		record(String(beat.get("title", Story.person_name(city))), text + "\n\nYou: " + String(selected[0]) + "\n" + String(selected[1]))
		SaveManager.checkpoint()
	return true


func play_activity() -> void:
	if busy:
		return
	busy = true
	await _activity()
	busy = false


func _activity() -> void:
	var city: String = GameState.city
	var region: String = GameState.current_region
	var data: Dictionary = SS.spot(city, region)
	var cp := get_tree().get_first_node_in_group("choice_panel")
	var cs := get_tree().get_first_node_in_group("cutscene")
	if data.is_empty() or cp == null or cs == null:
		return
	var key: String = city + ":" + region
	var seen: bool = bool(GameState.world_flags.get("spot_" + region, false))
	var state: Dictionary = ledger()["activities"].get(key, {})
	if state.is_empty() or bool(state.get("done", false)):
		var rewarded: Dictionary = state.get("effects", {})
		state = {"at": data.get("again", data["start"]) if seen else data["start"],
			"effects": rewarded, "context": {}, "done": false, "steps": 0, "revisit": seen}
		ledger()["activities"][key] = state
	var beats: Dictionary = data["beats"]
	var automatic_steps := 0
	while beats.has(String(state["at"])):
		var at: String = String(state["at"])
		var beat: Dictionary = beats[at]
		var rendered: Dictionary = SS.render_beat(beat, at, state["context"])
		var shots: Array = rendered["shots"]
		# Unfilmed choices need their prose once, in the decision panel.
		if not beat.has("film") and not Array(beat.get("rows", [])).is_empty():
			shots = []
		if not shots.is_empty():
			cs.play(city, shots)
			await cs.finished
			if not cs.completed:
				return
		state["context"] = rendered["context"]
		if not state["effects"].has(at):
			state["effects"][at] = true
			Services._beat_effects(beat, region)
		SaveManager.checkpoint()
		var toss: Array = beat.get("toss", [])
		if not toss.is_empty():
			automatic_steps += 1
			if automatic_steps >= SS.BEAT_LIMIT:
				push_error("Automatic activity cycle: " + key)
				return
			state["at"] = toss.pick_random()
			state["steps"] = int(state["steps"]) + 1
			continue
		var rows: Array = []
		for i in range(beat.get("rows", []).size()):
			var row: Dictionary = beat["rows"][i]
			rows.append({"id": str(i), "label": row.get("label", "Continue"),
				"sub": "Journey allowance covers " + GameState.symbol() + str(row["cost"]) if int(row.get("cost", 0)) > 0 else ""})
		if rows.is_empty():
			break
		cp.open(String(data.get("title", "On this street")), SS.decision_text(beat, not shots.is_empty()), rows)
		var pick: String = await cp.chosen
		if pick.is_empty():
			return
		automatic_steps = 0
		var took: Dictionary = beat["rows"][int(pick)]
		record(String(data.get("title", region)), String(beat.get("text", "")) + "\n\nYou: " + String(took["label"]))
		var next: String = String(took.get("to", ""))
		state["steps"] = int(state["steps"]) + 1
		state["at"] = next
		if next.is_empty():
			break
		var context: Dictionary = state["context"]
		context.merge(took.get("staging", {}), true)
		SaveManager.checkpoint()
	state["done"] = true
	GameState.world_flags["spot_" + region] = true
	Story.guide()
	SaveManager.checkpoint()


const CLOSING := {
	"berlin": [
		"Kerstin's corner is busy. Her borrowed family celebration has become an evening the neighbours made together.",
		"There is water beside the other drinks, and a seat that does not require a purchase.",
		"Emil checks the clear path. Rika moves a bag before he has to ask.",
		"Kerstin talks about her sister. This is one person's connection to an occasion, not a definition of Berlin.",
		"Someone points to the chair on our sign and asks if the empty one is free. It is."
	],
	"london": [
		"Nadia's arrows lead towards the lights and towards a quieter place to watch them.",
		"Val has brought spare cups. Mr Ahmed has left enough room for his niece to step back.",
		"Some people watch from the front; others stay with the quiet group. The evening has more than one good view.",
		"Nadia points out her little drawing on the sign. For once, the thing she made is what people thank her for.",
		"After the lights, she asks whether I am all right. This time I check, and she really wants to know."
	],
	"paris": [
		"The table downstairs is less symmetrical than Odile's plan. It has room for the people who changed it.",
		"Marcel brings the bread in two batches. The spare setting remains available.",
		"Inès steps away for a call and returns to find her chair waiting.",
		"Odile points out what she would do differently next time. Then she asks what I would change.",
		"We pass the basket along. The greeting I practised has become the beginning of a conversation."
	],
	"moscow": [
		"Viktor moves the work lamp aside. For this evening, the bench can hold plates.",
		"Alina explains the fillings to whoever asks. Nobody has to accept a plate to remain at the table.",
		"Pavel starts the football argument again. Viktor answers with his hands as much as with his words.",
		"Alina touches the repaired clasp. She decides which part of the story to tell.",
		"The tiny join still shows where the brooch was helped. She wanted it that way."
	],
	"istanbul": [
		"The han's tea round is slower today. Arda has time to sit down between the greetings.",
		"Some neighbours embrace, others wave. I follow the invitation in front of me.",
		"Selin sets the drinks where people can choose them. Hasan brings his empty glass back.",
		"The packages are ready. The people who collect them do not become a photograph.",
		"Arda notices the little tray in my notebook. We both know which afternoon it means."
	],
	"mumbai": [
		"The lane has a clear route through it and a seat where somebody asked for one.",
		"Asha checks that visitors can understand the notice. Yusuf helps someone find the way.",
		"Some neighbours join the ritual; some help around it; others watch. Omkar explains without insisting.",
		"His drawing has become a shared place. The changes are evidence of the people who helped.",
		"When somebody brings another broken phone, Omkar points to tomorrow on his little note."
	],
	"tokyo": [
		"Haru has left a reachable branch among the decorations. Mr Mori stops beside it.",
		"Some strips show their writing. Others remain folded. Their owners decide.",
		"Setsuko checks before moving a paper. A small question is enough to keep it somebody else's choice.",
		"The shop is closed for the gathering. There is no need to buy anything to stay.",
		"I recognise more words now. That makes checking what someone means easier, not unnecessary."
	],
	"mexico": [
		"The flowers frame the photograph and the cup. They do not cover the things the family wanted to remember.",
		"Rocío explains the arrangement to someone who asks. Another guest simply sits beside Tomás.",
		"Lucía puts her drawing where everyone who helped can see it.",
		"Tomás chooses to tell a story. We listen without reaching for a camera.",
		"The crooked handle is still crooked in the drawing. It is how we recognise this particular cup."
	]
}

func holiday_reel(city: String) -> Array:
	if city == "berlin":
		return BERLIN.reel()
	var reel: Array = preload("res://scenes/npc/KeyLines.gd").holiday_reel(city).duplicate(true)
	var lines: Array = CLOSING[city].duplicate()
	if city == "moscow" and rebuilt(city):
		var flags: Dictionary = GameState.world_flags.get("moscow_story", {}).get("flags", {})
		lines[4] = "The wider clasp opens with one hand. Alina kept the old piece in its tin; the scratched face is still hers." if flags.get("new_clasp", false) else "The tiny join still shows where the brooch was helped. Alina wanted it that way."
		lines[0] = "Viktor puts the tools away. Today the little stands hold plates for their Maslenitsa gathering."
	if city == "mumbai" and rebuilt(city):
		var flags: Dictionary = GameState.world_flags.get("mumbai_story", {}).get("flags", {})
		lines[1] = "The route drawing and large time help someone find the gathering. The words are still there beside them." if flags.get("picture_notice", false) else "Asha checks the notice versions with the neighbours who asked for them. Yusuf helps someone find the way."
		lines[3] = "Yusuf and I welcome someone using the route we kept open. Omkar comes over to see who has arrived." if flags.get("welcoming", false) else "Omkar leaves me a seat and time for my questions. Watching is a way to be here too."
	if city == "tokyo" and rebuilt(city):
		var flags: Dictionary = GameState.world_flags.get("tokyo_story", {}).get("flags", {})
		lines[2] = "My strip moves beside the others on the low branch. Haru waited for permission before tying it." if flags.get("public_wish", false) else "My strip stays in my notebook. Haru leaves me a place beside the display anyway."
		lines[4] = {"home":"My drawing points towards home. Missing it and enjoying this gathering can happen together.", "return":"My drawing has a returning arrow. For the first time, I want a way back here as well.", "blank":"My strip is still blank. Setsuko let an unfinished wish belong here too."}.get(flags.get("wish", "blank"), lines[4])
	if city == "mexico" and rebuilt(city):
		var flags: Dictionary = GameState.world_flags.get("mexico_story", {}).get("flags", {})
		lines[2] = "Lucía keeps the picture of Rocío and me. Tomás stayed outside its frame, exactly as he asked." if flags.get("portrait", false) else "I stayed outside the portrait. Lucía's drawing still has a chair with my notebook on it."
		lines[3] = "The little clip is about the flowers Tomás offered to explain. His family story remains with those he chose to tell." if flags.get("record_flowers", false) else "The drawing keeps the crooked cup. Tomás's story was heard without being recorded."
	for i in range(reel.size()):
		reel[i]["say"] = lines[i] if i < lines.size() else String(ledger()["memories"].get(city, CHAPTERS.CITIES[city]["return"]))
		var cast: Array = reel[i].get("cast", [])
		if not cast.is_empty():
			cast[0]["act"] = "watch"
		if cast.size() > 1:
			cast[1]["appearance"] = Story.look_for(city)
	return reel
