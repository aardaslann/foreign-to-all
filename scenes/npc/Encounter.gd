extends CharacterBody2D

# Somebody who sees you first.
#
# Every other person in this game waits to be pressed E at. This one notices
# the player, puts a mark over their head, walks over, and opens the
# conversation whether it was wanted or not.
#
# Borrowed openly from the trainer who spots you across a room, and doing a
# specific job here rather than a generic one: being approached, in a language
# you cannot speak, by somebody who has already decided something about you, is
# the exact situation this game is about, and until now the player was never
# once in it. They could always simply not press the button.
#
# ── The beats ────────────────────────────────────────────────────────────────
#
#   waiting   they have not seen him. Standing, doing their own thing
#   seen      the mark goes up and they hold for a beat, so it reads
#   coming    they walk to him. He can move; they re-aim
#   talking   the dialogue is open
#   leaving   the flag is set and they go
#
# The mark is drawn rather than typed, because a glyph at this size is a smear
# and because it has to read at a glance from across a room.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")
const DATA := preload("res://scenes/npc/Encounters.gd")

@export var encounter: String = ""
# How far away they notice him. A room is about 500 across, so this is "the
# same room" rather than "the same district".
@export var sight: float = 320.0
# Where they go afterwards. Zero means they simply stop.
#
# On a street this is the far end of it, and walking off the end of a street is
# a way of leaving that everybody reads. In a ROOM it has to be the door,
# because a room has one - the man in 304 was walking into the far wall and
# then ceasing to exist while the player watched him do it.
@export var leave_to: Vector2 = Vector2.ZERO
# The way round the furniture, when the door is not in a straight line from
# where they are standing. Walked in order, and then leave_to. A
# CharacterBody2D slides along a bed rather than going round it, and then
# slides into the corner between the bed and the wall and stops there.
@export var leave_via: PackedVector2Array = PackedVector2Array()
@export var doorway_clearance: float = 0.0

const SPEED := 74.0
const REACH := 58.0          # close enough to be talked at
const HOLD := 0.75           # beat between seeing him and moving

var _state: String = "waiting"
var _t: float = 0.0
var _hold: float = 0.0
var _look: Dictionary = {}
var _data: Dictionary = {}
var _leg: int = 0             # which waypoint of leave_via they are walking to
var _fade: float = 0.0        # counting down through the doorway
var _exit_direction := Vector2.UP


func _ready() -> void:
	add_to_group("encounter")
	_data = DATA.get_encounter(encounter)
	if _data.is_empty():
		push_warning("Encounter: no entry for '%s'" % encounter)
		queue_free()
		return
	if not DATA.pending(encounter):
		# It has already happened, or its precondition is not met. Either way
		# nobody is standing here.
		queue_free()
		return
	_look = ROSTER.look(String(_data.get("look", "")), GameState.city)


func _physics_process(delta: float) -> void:
	_t += delta
	if get_tree().paused:
		return
	if _story_busy():
		# Physical story beats unpause walking. They still own the shared
		# dialogue overlay; a passer-by must not replace a pending answer.
		velocity = Vector2.ZERO
		queue_redraw()
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	match _state:
		"waiting":
			if global_position.distance_to(player.global_position) <= sight:
				_state = "seen"
				_hold = HOLD
		"seen":
			_hold -= delta
			if _hold <= 0.0:
				_state = "coming"
		"coming":
			var to: Vector2 = player.global_position - global_position
			if to.length() <= REACH:
				velocity = Vector2.ZERO
				_talk()
			else:
				velocity = to.normalized() * SPEED
				move_and_slide()
		"leaving":
			_walk_out(delta)
	queue_redraw()


func _talk() -> void:
	if _state == "talking" or _story_busy():
		return
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null or dlg.visible:
		return
	_state = "talking"
	dlg.show_dialogue(_data.get("lines", []),
		String(_data.get("name", "Somebody")),
		String(_data.get("relationship", "")),
		Color(0.72, 0.34, 0.32), true,
		String(_data.get("region", "")), _look,
		# Voiced as the person they are drawn as (CastRoster id).
		String(_data.get("look", "")))
	await get_tree().create_timer(0.2).timeout
	# The dialogue box is a shared overlay with no per-conversation signal, so
	# this waits for it to close rather than being told. Cheap, and it cannot
	# get stuck: if the box goes, so does the wait.
	while is_instance_valid(dlg) and (dlg as CanvasLayer).visible:
		await get_tree().process_frame
	_settle()


# Leaving, properly.
#
# They walk the waypoints their scene gave them and then the door, and at the
# door they go out of it - a step and a fade rather than a body switching off.
# The fade is short: this is somebody stepping through a doorway, not a ghost.
#
# The old version aimed at one point and called queue_free() on arrival, and
# the point the hotel room gave it was the far wall. So the last thing the
# player saw of the only person who has ever come to find them was a man
# walking into plaster and blinking out. The free is still necessary - they are
# solid, and standing there afterwards they are a person-shaped wall across the
# only door - but it happens on the far side of it now.
const FADE := 0.34


func _walk_out(delta: float) -> void:
	if _fade > 0.0:
		_fade -= delta
		# Continue the last step through the threshold while the door occludes
		# him. Previously this phase kept playing a stationary walking loop.
		position += _exit_direction * SPEED * 0.40 * delta
		modulate.a = clampf(_fade / FADE, 0.0, 1.0)
		if _fade <= 0.0:
			queue_free()
		return
	var aim: Vector2 = leave_to
	if _leg < leave_via.size():
		aim = leave_via[_leg]
	if aim == Vector2.ZERO:
		queue_free()
		return
	var to: Vector2 = aim - global_position
	# A doorway's closed ground footprint still blocks the player. Once the
	# visitor reaches the final, opening threshold, let his last steps cross
	# it; otherwise the collider stops him just short of the exit forever.
	if _leg>=leave_via.size() and doorway_clearance>0 and to.length()<=doorway_clearance:
		collision_layer=0
		collision_mask=0
	if to.length() <= 10.0:
		if _leg < leave_via.size():
			_leg += 1
			return
		# At the door. Out of it.
		_exit_direction = velocity.normalized() if velocity.length() > 0.1 else Vector2.UP
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		_fade = FADE
		return
	velocity = to.normalized() * SPEED
	move_and_slide()


func _settle() -> void:
	# A response may have set the flag itself. If none did - the player picked
	# an option with no action on it - it is still over: being made to have the
	# same conversation twice is a bug, not a consequence.
	var flag: String = String(_data.get("flag", ""))
	if not flag.is_empty():
		GameState.world_flags[flag] = true
	_state = "leaving"


# ── Drawing ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	if _state == "gone":
		return
	var act: String = "stand"
	if (_state == "coming" or _state == "leaving") and velocity.length() > 1.0:
		act = "walk"
	CHAR.draw_figure(self, Vector2.ZERO, CHAR.world_unit(self), _look, act, _t,
		absi(encounter.hash()))
	if (_state == "seen" or _state == "coming") and not _story_busy():
		_draw_mark()


func _story_busy() -> bool:
	if Journey.busy:
		return true
	var director := get_tree().get_first_node_in_group("story_director")
	return director != null and director.running()


# The mark. Drawn as blocks: it has to read from across a room, and it rises
# and settles rather than appearing, so the eye catches the movement even at
# the edge of the screen.
const MARK_CLR := Color(0.929, 0.353, 0.302)
const MARK_EDGE := Color(0.10, 0.05, 0.07, 0.85)


func _draw_mark() -> void:
	var pop: float = clampf((HOLD - _hold) / 0.18, 0.0, 1.0)
	if _state == "coming":
		pop = 1.0
	var bob: float = sin(_t * 5.0) * 2.0 * SaveManager.motion()
	var y: float = -64.0 - pop * 6.0 + bob
	var u: float = 3.0
	# A dark pass first, a little larger, so it survives a pale street.
	for pass_i in range(2):
		var col: Color = MARK_EDGE if pass_i == 0 else MARK_CLR
		var pad: float = 1.5 if pass_i == 0 else 0.0
		draw_rect(Rect2(-u * 0.5 - pad, y - pad, u + pad * 2.0,
			u * 3.4 + pad * 2.0), col)
		draw_rect(Rect2(-u * 0.5 - pad, y + u * 4.2 - pad, u + pad * 2.0,
			u + pad * 2.0), col)
