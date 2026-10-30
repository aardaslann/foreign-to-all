extends Area2D

# One end of a job: the pile you take from, or the place it goes.
#
# ── Why this exists ──────────────────────────────────────────────────────────
#
# Taking a job used to be the whole job. The notice board handed you a card,
# you walked to the ServicePoint the card named, and the money appeared - so
# "stack the delivery crates" was a fetch quest with the fetch removed, and the
# only labour in a game about a stranger who has to earn a room was pressing E
# in the correct district.
#
# A JobSpot is one half of the loop. `role` is "take" or "give":
#
#   take   walk up empty-handed and you are carrying a load
#   give   walk up carrying one and you set it down; that is one trip
#
# When the last trip lands, the job is finished at the counter that gave it -
# which is where the money is, so the player still has to go back and be paid
# by a person rather than by a number appearing.
#
# ── What it looks like ───────────────────────────────────────────────────────
#
# It draws its own pile, and the pile SHRINKS as the work is done: three crates
# on the pallet, then two, then one, then none, while the shelf at the other
# end fills up. That is the only feedback in the loop that is not a line of
# text, and it is the one that makes the work read as being done rather than
# counted.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const GLOW := preload("res://scenes/world/Glow.gd")

@export var job: String = ""
# take | give
@export var role: String = "take"
# What the pile is drawn as. Falls back to the job's own load.
@export var pile: String = ""

var _near: bool = false
var _t: float = 0.0
var _flash: float = 0.0
var _glow: Node2D = null


func _ready() -> void:
	monitoring = true
	add_to_group("job_spot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not has_node("Glow"):
		var g := Node2D.new()
		g.name = "Glow"
		g.set_script(GLOW)
		g.set("radius", 26.0)
		add_child(g)
	_glow = get_node_or_null("Glow") as Node2D
	# Dark until there is work here. Twelve of these stand in five districts
	# and every one of them lit up whether or not anybody had taken the job -
	# so the player walked across a field toward a warm pool of light, arrived
	# at bare grass, pressed E at bare grass, and learned that light in this
	# game means nothing. The glow is a promise that something here answers.
	# It only gets to make that promise when it can keep it.
	if _glow != null:
		_glow.visible = false
	z_index = 1


func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(0.0, _flash - delta * 1.6)
	if _glow != null:
		_glow.visible = _live()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not _near or get_tree().paused or not _live():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_use()


# Whether this end of the loop is the one the player needs right now. A pile
# with nothing left in it is not offering anything, and neither is the shelf
# when his hands are empty.
#
# Public, because the arrow in the UI asks every job spot in the scene which of
# them it should be pointing at, and there must be exactly one answer.
func is_live() -> bool:
	return _live()


func _live() -> bool:
	if job.is_empty() or GameState.active_job != job:
		return false
	if GameState.job_progress >= Services.job_reps(job):
		return false
	if role == "take":
		return GameState.carrying.is_empty()
	return GameState.carrying == Services.job_load(job)


func _use() -> void:
	if role == "take":
		GameState.carry_load(Services.job_load(job))
		Services.settle_job_quest()
		_flash = 1.0
		_say("Heavier than it looks.\n\n" + Services.job_step())
		return
	GameState.drop_load()
	Services.settle_job_quest()
	_flash = 1.0
	var left: int = Services.job_reps(job) - GameState.job_progress
	if left > 0:
		_say("Down.\n\n" + Services.job_step())
	else:
		# The work is finished; the money is not. He has to go back to the
		# person who asked, which is the half of a job this game is about.
		_say("That is the last of them.\n\nNow to find the one who asked, " +
			"and work out how to say that it is done.")


func _say(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb:
		tb.show_thought(text)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near = false


# ── Drawing ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	if job.is_empty() or GameState.active_job != job:
		return
	var what: String = pile if not pile.is_empty() else Services.job_load(job)
	var need: int = Services.job_reps(job)
	var done: int = GameState.job_progress
	# A take-pile empties as the work goes; a give-pile fills up.
	var count: int = (need - done) if role == "take" else done
	if role == "take" and not GameState.carrying.is_empty():
		count -= 1
	count = clampi(count, 0, need)

	# The floor it stands on, so the stack is not floating - and only while
	# there IS a stack. An empty shelf drew its own shadow, which put a dark
	# oval on bare grass with nothing above it: the same "something is here"
	# lie the glow was telling, in a different colour.
	if count > 0:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.34))
		draw_circle(Vector2.ZERO, 26.0, Color(0.0, 0.0, 0.0, 0.24))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# One unit is 2.6 pixels here rather than the 1.35 a held load is drawn at:
	# a crate on the ground has to read across a field at the camera's 1.667x,
	# and at the held size the pile came out as three brown specks in grass.
	for i in range(count):
		# Stacked, each one a little off the last, because a perfectly aligned
		# stack reads as one tall box.
		var off := Vector2(float((i % 2) * 5 - 2), -float(i) * 17.0)
		CHAR.draw_prop(self, off + Vector2(0.0, 4.0), 2.6, what, 0.0, 0.0)

	if _flash > 0.02:
		draw_circle(Vector2(0.0, 6.0), 18.0 + (1.0 - _flash) * 30.0,
			Color(0.886, 0.706, 0.361, _flash * 0.30))

	if not _live():
		return

	var font: Font = ThemeDB.fallback_font
	if _near:
		var msg: String = "[E] Pick one up" if role == "take" else "[E] Set it down"
		draw_string(font, Vector2(-38.0, -46.0), msg,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
			Color(0.94, 0.92, 1.00, 0.95))
		return

	# Not near it, and it is the end of the loop he needs: say where it is and
	# what it is for. A player carrying a crate across a district should never
	# have to guess which corner of it the crate belongs in - and a pile of
	# three brown boxes in grass, seen from the far side of a field, is three
	# brown specks. So the marker is what carries at that distance, and the
	# words under it say which half of the job this is.
	_draw_marker(font, count)


const MARKER := Color(0.886, 0.706, 0.361)
const MARKER_EDGE := Color(0.10, 0.08, 0.05, 0.85)


func _draw_marker(font: Font, count: int) -> void:
	var bob: float = sin(_t * 2.6) * 3.0 * SaveManager.motion()
	# Above whatever is actually stacked here. A fixed height put the chevron
	# through the top crate of a full pallet and left it stranded in the air
	# over an empty shelf.
	var y: float = -34.0 - float(count) * 17.0 + bob
	# A chevron pointing down at the thing, drawn dark-first so it survives a
	# pale morning pavement as well as a dark one.
	for pass_i in range(2):
		var col: Color = MARKER_EDGE if pass_i == 0 else MARKER
		var pad: float = 2.0 if pass_i == 0 else 0.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(0.0, y + 14.0 + pad),
			Vector2(-9.0 - pad, y - 1.0 - pad),
			Vector2(9.0 + pad, y - 1.0 - pad),
		]), col)
	var what: String = "Take one" if role == "take" else "They go here"
	var left: int = Services.job_reps(job) - GameState.job_progress
	if role == "take" and left > 1:
		what = "Take one  (%d to go)" % left
	var w: float = font.get_string_size(what, HORIZONTAL_ALIGNMENT_LEFT,
		-1, 12).x
	draw_string(font, Vector2(-w * 0.5 + 1.0, y - 7.0), what,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MARKER_EDGE)
	draw_string(font, Vector2(-w * 0.5, y - 8.0), what,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.98, 0.94, 0.86, 0.96))
