extends Node2D

# The thing that says "this can be touched".
#
# Every interactable in the game announced itself with a prompt that only
# appears once you are already standing on it, so a door you never happened to
# walk into was a door you never learned was there. A city of ninety-nine
# districts cannot be searched by bumping into it.
#
# So anything you can press E at now stands in a slow pool of warm light, in
# the alien's own accent gold out of art/player/alien.gpl, and the pool
# brightens as you come into range. It breathes rather than blinks: a blinking
# object is an alarm, and none of these are urgent.
#
# Nothing places one of these by hand. Interactables autoload watches for the
# Prompt node every interactable already has and attaches one, so a new
# interactable - including one spawned at runtime - cannot forget it.

const GOLD := Color(0.886, 0.706, 0.361)

# How far out the pool reaches. Set from whatever it is attached to, because a
# doorway is not the same size as a person.
@export var radius: float = 32.0
@export var tint: Color = GOLD
@export var lift: float = 0.0        # nudge up off the origin line

# How close the player has to be before it brightens. A shade wider than a
# typical interaction area, so the light arrives before the prompt does.
const NEAR_DIST := 150.0

# How many stacked rings make the falloff. Additive, so the middle is the
# sum of all of them and the edge is one.
const RINGS := 10

var _t: float = 0.0
var _near: float = 0.0
var _player: Node2D = null


func _ready() -> void:
	z_index = -1
	# Added, not painted. A gold oval blended normally is a gold sticker on
	# the pavement; the same oval added to what is under it is light, and it
	# behaves like light - strongest over the dark dawn road, barely there on
	# a bright morning kerb, which is exactly right.
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = m
	# Out of phase with its neighbours: a street of six doors pulsing in
	# unison reads as the whole street flashing.
	_t = randf() * TAU
	_size_to_parent()


func _size_to_parent() -> void:
	var p: Node = get_parent()
	if p == null:
		return
	if "target_scene" in p:
		radius = 42.0        # a doorway is wide and you aim at it from afar
	elif "service" in p:
		radius = 34.0        # a counter, a machine, a notice board
	elif "npc_id" in p or "npc_name" in p:
		radius = 25.0        # a person, and only just enough to notice


func _process(delta: float) -> void:
	_t += delta
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	var want: float = 0.0
	if _player != null:
		var d: float = global_position.distance_to(_player.global_position)
		want = clampf(1.0 - d / NEAR_DIST, 0.0, 1.0)
	# Eased rather than snapped, so walking past something does not strobe it.
	_near = move_toward(_near, want, delta * 3.0)
	queue_redraw()


func _draw() -> void:
	# One cycle every two and a half seconds, and it never goes fully out.
	# Damped to nothing when the player asked for less movement; the pool
	# still brightens as you approach, because that is information.
	var pulse: float = (0.5 + 0.5 * sin(_t * 2.5)) * SaveManager.motion()
	# At rest it should be findable across a street; in range it should be
	# unmistakable. The first pass topped out at 0.15 of a normal blend and
	# was invisible in a render, which is the whole reason for looking.
	var a: float = lerpf(0.13, 0.23, pulse) + _near * 0.22
	# Added light on a bright morning kerb is physically fainter and that is
	# correct, but this is an affordance before it is weather - it has to be
	# as findable at nine in the morning as it is at dusk.
	a *= lerpf(1.55, 1.0, GameState.CLOCK.night_amount(GameState.clock_minutes, GameState.city))
	var r: float = radius * (1.0 + pulse * 0.05 + _near * 0.09)
	# Flattened, because it is light lying on a pavement and not a ball.
	draw_set_transform(Vector2(0.0, -lift), 0.0, Vector2(1.0, 0.38))
	# Widest and faintest first, each ring adding onto the last, so the
	# brightness ramps toward the middle instead of stepping. Three rings
	# banded plainly enough to read as a manhole cover; ten do not.
	for i in range(RINGS):
		var k: float = 1.0 - float(i) / float(RINGS)
		draw_circle(Vector2.ZERO, r * k,
			Color(tint.r, tint.g, tint.b, a * 0.12))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
