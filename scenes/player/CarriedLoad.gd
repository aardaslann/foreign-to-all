extends Node2D

# What is in the alien's arms, drawn in front of him.
#
# ── Why this is its own node ─────────────────────────────────────────────────
#
# It was drawn in Player._draw(). A node draws before its children, and the
# player IS a sprite child - so the crate went behind him and the only part of
# it anybody ever saw was a brown corner at his hip. Then it was drawn at 1.35
# units per pixel where the pile on the ground is drawn at 2.6, so the crate
# also shrank to a third of itself in the act of being picked up. A player
# carrying something across a district could not tell they were carrying it.
#
# So: its own node, z above the sprite, at the pile's own scale. It is the same
# crate that was on the pallet, and it is the first thing you see.
#
# ── The weight ───────────────────────────────────────────────────────────────
#
# He walks at 78% loaded (Player.LADEN) and the thing in his arms rides with
# the step rather than hanging still beside him - the bob comes off his own
# velocity, so it reads as weight rather than as an object floating along on
# its own schedule.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const STORY_PROP := preload("res://scenes/story/StoryProp.gd")

# The unit the pile on the ground is drawn at, near enough, so a crate does not
# change size between the pallet and his hands.
const UNIT := 2.4

# Where his hands are, in the body's own coordinates: the shadow line is y 21.5
# and he stands about forty units above it, so this is in front, at the waist,
# which is where anybody carries a box they have to walk with.
const HANDS := Vector2(0.0, 17.0)

var _last: String = ""


func _process(_delta: float) -> void:
	# The player is in every scene in the game, and this node is empty for most
	# of it. Redraw when the load changes, and then only while there is one.
	var now: String = GameState.carrying
	if now != _last:
		_last = now
		queue_redraw()
	elif not now.is_empty():
		queue_redraw()


func _draw() -> void:
	var load: String = GameState.carrying
	if load.is_empty():
		return
	var body := get_parent() as CharacterBody2D
	var bob: float = 0.0
	if body != null and body.velocity.length() > 5.0:
		bob = sin(float(Time.get_ticks_msec()) * 0.012) * 1.2
	# A shadow on the ground under it first, so it has weight rather than being
	# a decal pinned to his chest.
	draw_set_transform(Vector2(0.0, 21.5), 0.0, Vector2(1.0, 0.30))
	draw_circle(Vector2.ZERO, 13.0, Color(0.0, 0.0, 0.0, 0.16))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# side 0 is both hands, held in front - a crate, a tray, an armful of paper.
	var unit: float = CHAR.world_unit(self)
	# Something from a story scene - her crate, the chair, the bag for Emil -
	# is drawn exactly as it was drawn on the pavement a moment ago.
	if load.begins_with("story_"):
		var kind: String = load.substr(6)
		var scale: float = unit * (0.62 if kind == "chair" else 0.95)
		# Held at the waist, where a job's crate sits: the same hand height as
		# CHAR.draw_prop below, with the prop's bottom edge just under it. The
		# chair is taller, so it rests lower in his arms.
		var waist: float = HANDS.y - (unit - 2.0) * 8.0
		var bottom: float = waist + (7.0 if kind == "chair" else 1.0)
		STORY_PROP.draw_kind(self, Vector2(0.0, bottom + bob), kind, scale)
		return
	CHAR.draw_prop(self, HANDS - Vector2(0, (unit - 2.0) * 8.0), UNIT, load, 0.0, bob)
