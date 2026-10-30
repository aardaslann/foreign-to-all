extends Area2D

# A cat you can sit down next to.
#
# There were already cats in fifteen of the twenty cities, because a warm city
# has them and the plates would have been lying without them. They were paint:
# a shape in the background, no more touchable than a bollard.
#
# This is the same shape, made of a node, so the one creature in this game that
# does not want anything from you and does not need to be understood can be
# reached. The alien cannot ask a cat for directions, cannot fail its grammar,
# cannot owe it a debt. Pressing E gets a completely legible answer, which is
# the only place in twenty cities where that is true.

const CAT := preload("res://scenes/world/CatArt.gd")

# 0 loafed, 1 sitting upright. CatArt.COATS decides the fur.
@export var pose: int = 0
@export var coat: int = 0

var _t: float = 0.0
var _pet: float = -1.0     # seconds since the last stroke; < 0 is untouched
var _hearts: Array = []    # [[offset_x, drift_x, delay, size], ...]
var _near: bool = false

# How long the whole reaction runs. Long enough to watch, short enough that
# the player is not held still by it.
const PURR := 2.6
const HEARTS := 3


func _ready() -> void:
	body_entered.connect(_on_in)
	body_exited.connect(_on_out)
	$Prompt.text = "E — Pet the cat"
	# A cat is a hash of where it sits, so two on one street are not twins.
	var h: int = absi(int(position.x) * 31 + int(position.y))
	_t = float(h % 100) * 0.11
	set_process(true)


func _process(delta: float) -> void:
	var motion: float = SaveManager.motion()
	_t += delta * maxf(motion, 0.25)
	if _pet >= 0.0:
		_pet += delta
		if _pet > PURR:
			_pet = -1.0
			_hearts.clear()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not _near or not (event is InputEventKey):
		return
	var k: InputEventKey = event
	if event.is_action_pressed("interact"):
		_stroke()


func _stroke() -> void:
	# Stroking again while it is already purring restarts the reaction rather
	# than stacking a second set of hearts on top of the first.
	_pet = 0.0
	_hearts.clear()
	var h: int = absi(int(_t * 1000.0))
	for i in range(HEARTS):
		_hearts.append([
			-9.0 + float((h >> (i * 3)) % 19),        # where it starts
			-7.0 + float((h >> (i * 5 + 1)) % 15),    # how far it drifts
			float(i) * 0.22,                          # when it appears
			0.78 + float((h >> (i * 2 + 3)) % 5) * 0.11,
		])
	# Worth a point of standing the first time in a district and never again.
	# Feeding and minding street cats is a real civic habit in most of the
	# cities on this itinerary - conspicuously so in Istanbul - so a stranger
	# doing it is read correctly. Once, so it cannot be farmed by a player who
	# works out that the cat is a button.
	var key: String = "cat_" + GameState.current_region
	if not GameState.world_flags.get(key, false):
		GameState.world_flags[key] = true
		GameState.change_reputation(GameState.current_region, 1)


func _on_in(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near = true
		$Prompt.visible = true


func _on_out(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near = false
		$Prompt.visible = false


func _draw() -> void:
	# The purr rises over a quarter second and tails off over the last third,
	# so nothing about the reaction switches on or off.
	var purr: float = 0.0
	if _pet >= 0.0:
		purr = minf(_pet / 0.25, 1.0) * clampf((PURR - _pet) / (PURR * 0.34), 0.0, 1.0)
	CAT.draw_cat(self, 0.0, 0.0, pose, coat, _t, purr)
	for h: Array in _hearts:
		_heart(h)


# One heart: it swells as it appears, rises, drifts and thins away. Nothing
# pops in or out - a heart that blinks on at full size reads as a hit marker
# from a different game.
#
# Drawn from a grid at the same unit the people are drawn at, because a heart
# assembled out of four rectangles reads as a plus sign, which is what the
# first attempt looked like on screen.
const HEART := [
	".XX.XX.",
	"XXXXXXX",
	"XXXXXXX",
	".XXXXX.",
	"..XXX..",
	"...X...",
]
const RISE := 52.0
const LIFT := 34.0     # clear of the cat's ears before it starts


func _heart(h: Array) -> void:
	var age: float = _pet - float(h[2])
	if age <= 0.0:
		return
	var life: float = clampf(age / (PURR - 0.5), 0.0, 1.0)
	if life >= 1.0:
		return
	# Out fast, in slow: the ease that makes a rising thing feel light.
	var climb: float = 1.0 - pow(1.0 - life, 2.4)
	var grow: float = clampf(life / 0.20, 0.0, 1.0)
	var fade: float = 1.0 - clampf((life - 0.55) / 0.45, 0.0, 1.0)
	# A little past full size and back, so it arrives with a beat.
	var pop: float = 1.0 + 0.22 * sin(clampf(life / 0.34, 0.0, 1.0) * PI)
	var u: float = float(h[3]) * (0.25 + 0.75 * pow(grow, 0.55)) * pop * 2.1
	var at: Vector2 = Vector2(
		float(h[0]) + float(h[1]) * climb + sin(life * 5.0 + float(h[2]) * 9.0) * 2.6,
		-LIFT - RISE * climb)
	var col := Color(0.97, 0.29, 0.40, 0.94 * fade)
	var edge := Color(0.74, 0.15, 0.28, 0.94 * fade)
	var shine := Color(1.0, 0.72, 0.76, 0.90 * fade)
	var w: float = float(HEART[0].length())
	for r in range(HEART.size()):
		var row: String = HEART[r]
		var y: float = at.y + (float(r) - 3.0) * u
		var x: int = 0
		while x < row.length():
			if row[x] == "X":
				var run: int = 1
				while x + run < row.length() and row[x + run] == "X":
					run += 1
				var c: Color = col
				if r == HEART.size() - 1 or r == HEART.size() - 2:
					c = edge
				elif r == 0 and x < 3:
					c = shine
				draw_rect(Rect2(at.x + (float(x) - w * 0.5) * u, y,
					float(run) * u, u), c)
				x += run
			else:
				x += 1
