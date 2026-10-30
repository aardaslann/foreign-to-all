extends Area2D

# The field at the edge, and the last scene in the game.
#
# It is the same object at both ends of the story. At the start it is a broken
# machine that starts a search; at the end it is a working one, sitting in the
# grass with the hatch open, and the only thing left to decide is whether to
# get in.
#
# Gate C, from docs/design/story.md: the ending is reachable only here, only in
# Berlin, and only with all nine pieces. Staying is never a punishment and is
# never gated on failure - it has to be a real choice, which means leaving has
# to be genuinely available at the same moment.

var player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and not get_tree().paused and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_inspect()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _think(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(text)


# How much of the world you have to have stood in before the field has
# anything left to say to you.
const ENDING_CITIES := 12


func _inspect() -> void:
	if get_tree().get_first_node_in_group("thought_box") == null:
		return
	# Gate C. The pod is not going anywhere and never was; what decides the
	# ending is how much of this planet you actually went and stood in.
	if Story.can_end() and GameState.city == "berlin":
		_ending()
		return
	var seen: int = GameState.cities_visited()
	if seen <= 1:
		_think("My pod, or what is left of it.

" +
			"The hull is split open. Whatever brought me here, I do not
" +
			"think I am leaving the same way.

" +
			"I do not know this place. I do not know the sounds they make
" +
			"here, let alone what the sounds mean. But I am still standing.
" +
			"That is somewhere to start.")
		return
	_think("It does not go back together. I have stopped trying.

" +
		"%d places now, and the thing I keep bringing back to it is not
" % seen +
		"parts. It is words, and the shapes people make with their hands,
" +
		"and which of them will let me sit down.

" +
		"The pod is where I landed. It is not where I have been.")


# ── The ending ────────────────────────────────────────────────────────────────
# The core is whole. The pod works. Both doors are open and the game does not
# have an opinion about which one is correct.

func _ending() -> void:
	GameState.world_flags["core_whole"] = true
	# Before the pod, the name. His species has no personal names - identity
	# is positional - so the one concept he could never place is the one that
	# means himself. It cannot be taken. It has to be given.
	if Story.can_end():
		if Story.namer().is_empty():
			await _be_named()
		else:
			var naming := get_tree().get_first_node_in_group("naming")
			if naming != null: naming.play(Story.namer())
		return
	if not GameState.quests.has("stay_or_go"):
		GameState.start_quest("stay_or_go", "The pod is fixed", ["Decide"])
	if bool(GameState.world_flags.get("ending_chosen", false)):
		_think("It is still sitting in the grass with the hatch open.\n\n" +
			"I have already decided. I keep coming back to look at it\n" +
			"anyway.")
		return
	var cp := get_tree().get_first_node_in_group("choice_panel")
	if cp == null:
		return
	var best: Array = GameState.best_city()
	var words: int = GameState.words_known()
	cp.open("The core is whole",
		"nine pieces, and the last one came out of an apron four thousand " +
		"metres up. It seats. It holds. Nothing goes wrong.",
		[
			{"id": "leave", "label": "Get in and go",
				"sub": "it works. It has worked since the moment it was whole"},
			{"id": "stay", "label": "Close the hatch and walk back to the road",
				"sub": _stay_note(best)},
			{"id": "", "label": "Stand here a while longer",
				"sub": "the field is not going anywhere either"},
		])
	var pick: String = await cp.chosen
	if pick.is_empty():
		return
	GameState.world_flags["ending_chosen"] = true
	GameState.complete_last_step("stay_or_go")
	if pick == "leave":
		_leave(best, words)
	else:
		_stay(best)


func _stay_note(best: Array) -> String:
	var c: String = String(best[0])
	var score: int = int(best[1])
	if c.is_empty() or score < 35:
		return "you would be staying because you have run out of elsewhere"
	return "in %s you are %s, which took a year to become true" \
		% [String(GameState.CITIES.get(c, {}).get("name", c)),
			GameState.city_rep_level(c)]


# Two leaving endings, and the difference is whether anybody came. Neither is
# the good one; they are just different true things.
func _leave(best: Array, words: int) -> void:
	var regarded: int = 0
	for c in GameState.CITIES.keys():
		if GameState.city_reputation(String(c)) >= 35:
			regarded += 1
	if regarded >= 2 and words >= 60:
		_think("They come. Not all of them, and not from everywhere — the\n" +
			"ones who could get to a field outside Berlin on a Tuesday.\n\n" +
			"Renate. Lukas, who shut the stall for it. The officer, off\n" +
			"duty, standing well back.\n\n" +
			"In my pocket: a card from a caff with a phone number on it in\n" +
			"biro, and a small heavy parcel I have not opened.\n\n" +
			"I have learned how to say goodbye in nine languages and I am\n" +
			"told I get all nine of them slightly wrong.\n\n" +
			"I said them anyway. Every one. To the right people, in the\n" +
			"right order, with the right hands.\n\n" +
			"That is not fluency. I have decided it is better than fluency.")
	else:
		_think("Nobody came. There was no reason for anybody to come.\n\n" +
			"The burn ring is still in the grass from the first landing and\n" +
			"it will still be there tomorrow, and nobody who walks past it\n" +
			"will know what it was.\n\n" +
			"I was here for a season and I leave the way I arrived — as a\n" +
			"thing that happened to a field.\n\n" +
			"I know %d words. I never once managed to be a person anybody\n" % words +
			"would walk across a road for.")
	_owed()
	_roll_credits()


# Plays last, over the top of either leaving ending, and it is the only thing
# that follows the player home.
func _owed() -> void:
	if not bool(GameState.world_flags.get("charm_taken", false)):
		return
	if bool(GameState.world_flags.get("charm_repaid", false)):
		return
	await get_tree().create_timer(1.2).timeout
	_think("There is a shop in a courtyard on the other side of the world\n" +
		"with a cord over its door, and the cord has a gap in it where I am.\n\n" +
		"He did not sell it to me. He would not have sold it to me. He gave\n" +
		"it to me because by then I was somebody it could be given to.\n\n" +
		"I am taking their luck off the planet at four hundred metres a\n" +
		"second and I never went back with the bead.")


# Two staying endings, and the second one is not a punishment. Staying because
# you have nowhere else to be is a thing that happens to people, and it is what
# the whole game has been about.

const STAY_PROSE := {
	"berlin": "An Anmeldung. A form, a counter, a woman with a pen.\n\n" +
		"Every box is a box now. I fill it in, and the hardest part is\n" +
		"choosing what to write on the line that says name.",
	# Dot, 71, who has run this caff since 1974 and has called everybody love
	# for every one of those years. It said Bev here until 2026-09-09, and Bev
	# is nobody: she was London's key character in the design that the eight-
	# and-a-name storyline replaced, and when that pass swapped her for Nadia
	# it did not come back for the ending. So the most emotionally loaded line
	# in London named somebody the player had never met and could not meet.
	"london": "The caff at six in the morning.\n\n" +
		"Dot says one full sentence at full speed about the weather and\n" +
		"puts love on the end of it, and I get all of it, and it is the\n" +
		"most beautiful thing anybody has ever said to me.",
	"istanbul": "The cord over the door, retied.\n\n" +
		"There is a new bead in the empty place and it is the wrong blue,\n" +
		"and Yusuf has not mentioned it once.",
	"seoul": "Somebody used the short ending with me in the alley and I\n" +
		"used it back without thinking about it first.\n\n" +
		"I have a position here. It is not a high one. It is mine.",
	"lapaz": "I said a thing happened and I marked it as a thing I saw.\n\n" +
		"Nobody looked up. That is what it is like when a sentence is\n" +
		"simply true and the grammar has no complaint about who is saying it.",
	"saopaulo": "She stood close enough that I could have stepped back, and\n" +
		"I did not, and neither of us said anything about it.",
	"rome": "I got served first this morning.\n\n" +
		"I talked over him to do it and he did not break stride.",
	"tokyo": "He said chotto and let it hang, and I said thank you and\n" +
		"left, and both of us knew exactly what had been agreed.",
	"dakar": "I got through the whole greeting before I asked for anything.\n\n" +
		"It took four minutes. Everything after it took thirty seconds.",
	"mumbai": "Three languages in one sentence and not one of them finished.\n\n" +
		"Nobody has corrected me in a week.",
}


func _stay(best: Array) -> void:
	var c: String = String(best[0])
	var score: int = int(best[1])
	if c.is_empty() or score < 35:
		_think("The pod works. I checked it twice.\n\n" +
			"I am not staying because I am wanted here. I am staying\n" +
			"because I have run out of places where I would be less of a\n" +
			"stranger, and this one at least has bread I know the word for.\n\n" +
			"That is a worse reason than the one I wanted. It is still a\n" +
			"reason, and I am still here.")
		_roll_credits()
		return
	var where: String = String(GameState.CITIES.get(c, {}).get("name", c))
	var tail: String = String(STAY_PROSE.get(c,
		"Somebody said my name the way the people here say names,\n" +
		"and did not slow down to do it."))
	_think("The pod is repaired and it is sitting in the grass with the\n" +
		"hatch open, and it will still be there tomorrow.\n\n" +
		"I am going back to %s.\n\n" % where + tail)
	_roll_credits()


# The pod lights, the field goes dark, and the game returns to the title. The
# save is left exactly as it is, because the ending is a state the world is in
# rather than a thing that deletes it.
func _roll_credits() -> void:
	await get_tree().create_timer(9.0).timeout
	if not is_inside_tree():
		return
	TransitionManager.go("res://scenes/title/TitleScreen.tscn")


# Eight people, and you choose one. Whoever you choose says the same thing in
# a different language, and the eight are not synonyms: the temperature of
# the word is what you are actually choosing.
func _be_named() -> void:
	var cp := get_tree().get_first_node_in_group("choice_panel")
	if cp == null:
		return
	var rows: Array = []
	for c: String in Story.MANDATORY:
		var p: Dictionary = Story.person(c)
		rows.append({
			"id": c,
			"label": "Ask %s" % String(p.get("name", "")),
			"sub": "%s — %s" % [
				String(GameState.CITIES.get(c, {}).get("name", c)),
				String(Journey.ledger()["memories"].get(c, p.get("trade", "")))],
		})
	rows.append({"id": "", "label": "Not yet",
		"sub": "the pod is not going anywhere, and neither is the question"})
	cp.open("I have never had a name",
		"my people do not use them. You are where you stand, and I have been " +
		"standing in eight places. One of them has to say it, and mean it.",
		rows)
	var pick: String = await cp.chosen
	if pick.is_empty():
		return
	var nm := get_tree().get_first_node_in_group("naming")
	if nm != null:
		nm.play(pick)
		await nm.finished
