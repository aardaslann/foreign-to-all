extends CharacterBody2D

# The alien — the player, using the final production sprites from the
# character handoff. SpriteFrames are built at ready from the
# per-animation strips in res://art/player/strips/ (32px cells, pixel-exact:
# nearest filter, integer scale only). Facing is 4-directional, driven by
# velocity; blink is baked into idle frame 6, so no code-side blink timers.

const SPEED := 120.0

# What he is carrying, drawn by the same thing that draws what everybody else
# is carrying - so a crate in his hands and a crate in the greengrocer's are
# the same object at the same size, which is the whole reason CharacterArt
# owns props at all.
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const HELD := preload("res://scenes/player/CarriedLoad.gd")
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")

# A full load is slower. Three crates should not move at the speed of a man
# holding nothing, and it is the cheapest possible way to make the work read
# as work.
const LADEN := 0.78

const CELL      := 32
const STRIP_DIR := "res://art/player/strips/"

# animation -> [frame count, fps, loops] — from the handoff README table
const ANIMS := {
	"idle_down":      [6, 5.0, true],
	"idle_up":        [6, 5.0, true],
	"idle_right":     [6, 5.0, true],
	"idle_left":      [6, 5.0, true],
	"walk_down":      [8, 10.0, true],
	"walk_up":        [8, 10.0, true],
	"walk_right":     [8, 10.0, true],
	"walk_left":      [8, 10.0, true],
	"interact_down":  [4, 6.0, false],
	"interact_up":    [4, 6.0, false],
	"interact_right": [4, 6.0, false],
	"interact_left":  [4, 6.0, false],
}

var _facing:      String = "down"
var _interacting: bool   = false
var _reading:     bool   = false

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group("player")
	# Runs through pauses so the read-loop can play while dialogue is open
	process_mode = Node.PROCESS_MODE_ALWAYS

	_sprite.sprite_frames = _build_frames()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(2, 2)
	if get_parent().has_meta("character_unit"):
		var unit: float = float(get_parent().get_meta("character_unit"))
		_sprite.scale = Vector2(unit, unit)
		_sprite.position.y = -(unit - 2.0) * 10.0
		$CollisionShape2D.position.y = 20.0
		var feet := RectangleShape2D.new()
		# Authored scenes collide at the soles/shadow, not the shins. An 18px
		# deep box bridged visible gaps between a crate and the next object.
		var foot_depth := 8.0 if get_parent().get_meta("object_silhouettes",false) else 18.0
		feet.size = Vector2(14.0*unit/2.0,foot_depth)
		$CollisionShape2D.shape = feet
	# Boots live at cell rows 25-27; -1.5px (pre-scale) puts their soles on
	# the drawn shadow line at y≈21
	_sprite.offset = Vector2(0, -1.5)
	_sprite.animation_finished.connect(_on_anim_finished)
	_sprite.play("idle_down")

	# What is in his arms gets its own node, IN FRONT of him.
	#
	# It used to be drawn in the body's own _draw(), which runs before its
	# children - so the crate went behind the sprite and all the player could
	# see of a load he was carrying across a district was a brown edge sticking
	# out at his hip. And it was drawn at 1.35 units where the pile on the
	# ground is drawn at 2.6, so the same crate shrank to a third of itself the
	# moment he picked it up. It is the same object at the same size now, held
	# in front with both hands, and it is the first thing you see.
	var held := Node2D.new()
	held.name = "Load"
	held.z_index = 1
	held.set_script(HELD)
	add_child(held)


# ── SpriteFrames from strips ──────────────────────────────────────────────────

func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	for anim: String in ANIMS:
		var spec: Array = ANIMS[anim]
		var tex := APPEARANCE.strip(anim, GameState.alien_appearance)
		_add_frames(sf, anim, tex, 0, int(spec[0]), float(spec[1]), bool(spec[2]))
	# read_down: frames 1-2 are the notebook take-out (played once when
	# dialogue opens), frames 3-6 the look-down/look-up loop
	var read_tex := APPEARANCE.strip("read_down", GameState.alien_appearance)
	_add_frames(sf, "read_in_down", read_tex, 0, 2, 5.0, false)
	_add_frames(sf, "read_down",    read_tex, 2, 4, 5.0, true)
	sf.remove_animation("default")
	return sf


func _add_frames(sf: SpriteFrames, anim: String, tex: Texture2D,
		first: int, count: int, fps: float, loops: bool) -> void:
	if tex == null:
		push_error("Player strip missing for animation: " + anim)
		return
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loops)
	for i in range(count):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(float(first + i) * CELL, 0, CELL, CELL)
		sf.add_frame(anim, at)


# ── Movement ──────────────────────────────────────────────────────────────────

func _physics_process(_delta: float) -> void:
	if get_tree().paused:
		return
	# One vector, from actions Controls owns. It used to read ui_left/ui_right
	# and then, when those were idle, poll KEY_D/KEY_A/KEY_S/KEY_W directly -
	# so WASD could not be rebound, a thumbstick was all-or-nothing because
	# ui_* is a digital action, and the arrow keys drove both the alien and the
	# focus in whatever menu happened to be open.
	#
	# get_vector also gives a stick its analogue range back, so walking is a
	# speed now rather than a switch.
	var direction := Input.get_vector("walk_left", "walk_right",
		"walk_up", "walk_down")
	var pace: float = SPEED * (LADEN if not GameState.carrying.is_empty() else 1.0)
	velocity = direction * pace if direction != Vector2.ZERO else Vector2.ZERO
	move_and_slide()


# ── Animation state ───────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	queue_redraw()   # shadow squash follows the walk state

	# The signature: notebook comes out whenever someone is talking to us
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	var dialogue_open: bool = dlg != null and (dlg as CanvasLayer).visible
	if dialogue_open:
		if not _reading:
			_reading = true
			_interacting = false
			_sprite.play("read_in_down")
		return
	if _reading:
		_reading = false
		_sprite.play("idle_" + _facing)

	if get_tree().paused:
		return   # some other overlay is up — hold the current pose
	if _interacting:
		return   # one-shot playing; animation_finished brings us back

	if velocity.length() > 5.0:
		if absf(velocity.x) >= absf(velocity.y):
			_facing = "right" if velocity.x > 0.0 else "left"
		else:
			_facing = "down" if velocity.y > 0.0 else "up"
		_sprite.play("walk_" + _facing)
	else:
		_sprite.play("idle_" + _facing)


func _unhandled_input(event: InputEvent) -> void:
	# Reach-out animation on the interact key (NPCs handle the interaction
	# itself; if a dialogue opens, the read state takes over immediately)
	if get_tree().paused or _interacting or _reading:
		return
	if event.is_action_pressed("interact"):
		if velocity.length() <= 5.0:
			_interacting = true
			_sprite.play("interact_" + _facing)


func _on_anim_finished() -> void:
	if _sprite.animation == &"read_in_down":
		_sprite.play("read_down")
		return
	if String(_sprite.animation).begins_with("interact_"):
		_interacting = false
		_sprite.play("idle_" + _facing)


# ── Ground shadow (kept from the old drawn player) ────────────────────────────

func _draw() -> void:
	var squash := 1.08 if velocity.length() > 5.0 else 1.0
	var width: float = 12.0 * CHAR.world_unit(self) / 2.0
	var pts := PackedVector2Array()
	for s in range(16):
		var a := float(s) / 16.0 * TAU
		pts.append(Vector2(cos(a) * width * squash, 21.5 + sin(a) * 3.4))
	draw_colored_polygon(pts, Color(0, 0, 0, 0.24))
