extends StaticBody2D

# One of the eight.
#
# They are not quest-givers standing in a marked spot from the first minute.
# They are invisible until you can hear them: KeyNPC hides itself until
# Story.can_meet() is true, which asks whether enough of the city's language
# has landed for a conversation to be possible at all. Before that they are
# one more person on a street you cannot read - which is what everybody in
# this game is, until they are not.
#
# Placed in the district the character actually works in, one per mandatory
# city. Drawn by scenes/npc/CharacterArt.gd like everybody else, because a
# separate renderer for the important people is how you get a cast that looks
# like two casts.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const COUNTER := preload("res://scenes/npc/Counters.gd")
const LINES := preload("res://scenes/npc/KeyLines.gd")

@export var city: String = ""

var player_nearby: bool = false
var _t: float = 0.0
var _busy: bool = false
var _seen_this_visit: bool = false


func _ready() -> void:
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)
	$Prompt.visible = false
	_refresh()


func _process(delta: float) -> void:
	_t += delta
	# They arrive the moment the language does, without a loading screen: the
	# check is cheap and the transition should be able to happen while you are
	# standing there.
	if not visible and Story.can_meet(city):
		_refresh()
	if visible:
		queue_redraw()


func _refresh() -> void:
	var show_them: bool = Story.has_met(city) or Story.can_meet(city)
	visible = show_them
	set_collision_layer_value(1, show_them)
	$InteractionArea.monitoring = show_them
	if show_them and not Story.has_met(city):
		_open_quest()



# The quest to find them lives in Story with the rest of the thread, so it
# cannot disagree with what the log says after a reload. The player can
# toggle the quest arrow when they want help finding the right district.
func _open_quest() -> void:
	Story.guide()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or _busy or not visible or get_tree().paused:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_talk()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _talk() -> void:
	_busy = true
	await _run()
	_busy = false


func _run() -> void:
	if Journey.core(city):
		await Journey.talk(city)
		return
	var p: Dictionary = Story.person(city)
	var who: String = String(p.get("name", "Somebody"))

	if not Story.has_met(city):
		# mark_met runs the thread, which ticks the step that is now true.
		# This used to ALSO call complete_last_step, which ticks the LAST step
		# - so the first conversation marked "And again, properly, this time"
		# as done while the middle step was still open, and the log read as a
		# quest that had skipped its own middle.
		Story.mark_met(city)

	# The holiday takes over the moment the friendship is complete: they are
	# not going to talk about the weather on the day they invited you to.
	if Story.holiday_on(city):
		await _walk_the_holiday(p)
		return

	# Two conversations in, they have asked for something, and the third does
	# not happen until it is done. Standing here pressing E three times used
	# to be a whole friendship.
	if Story.rounds_done(city) >= 2 and not Story.errand_done(city):
		_ask_errand(p)
		return

	var round_i: int = mini(Story.rounds_done(city), Story.ROUNDS - 1)
	var rounds: Array = LINES.rounds_for(city)
	if rounds.is_empty():
		return
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return
	var entry: Array = rounds[mini(round_i, rounds.size() - 1)]
	# Their age decides which "you" they expect, and the eight carry an age
	# rather than a build - Setsuko at seventy-four is not addressed the way
	# Nadia at seventeen is, in any language in this game that has the choice.
	var them: Dictionary = {"build": GameState.REGISTER.build_for_age(
		int(Story.person(city).get("age", 0)))}
	# In the same voice as their street story: the key person's name is the id
	# the story records them under (Kerstin -> "kerstin").
	dlg.show_dialogue(entry, who, LINES.standing(city, round_i),
		CHAR.COATS[0], not _seen_this_visit,
		String(Story.person(city).get("region", "")), them,
		String(Story.person(city).get("name", "")).to_lower())
	_seen_this_visit = true
	if not Story.is_friend(city):
		Story.add_round(city)


# What they want. Said as a thought rather than as a dialogue, because it is
# him working out what he has just been asked for rather than a conversation
# with options - he has no words for "which district?" yet, and pretending he
# does would be the one dishonest exchange in the game.
func _ask_errand(p: Dictionary) -> void:
	var e: Dictionary = Story.errand_of(city)
	if e.is_empty():
		return
	Story.guide()
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(String(p.get("name", "They")) + " again.

"
			+ String(e.get("ask", "")))


# The day itself. It plays as a reel, in the city's own plates, because that
# is what this game already does better than anything else it does.
func _walk_the_holiday(p: Dictionary) -> void:
	var cs := get_tree().get_first_node_in_group("cutscene")
	var reel: Array = LINES.holiday_reel(city)
	if cs != null and not reel.is_empty():
		cs.play(city, reel, true)
		await cs.finished
	Story.mark_holiday(city)
	GameState.change_reputation(String(p.get("region", "")), 6)


func _draw() -> void:
	if not visible:
		return
	var unit: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, unit)
	CHAR.draw_figure(self, st["offset"], unit, Story.look_for(city),
		"stand", _t, int(city.hash()), int(st["clip"]))
