extends Area2D

# Any counter, machine or notice board you can walk up to and press E at.
# The behaviour lives in the Services autoload — this node is just the
# proximity prompt and the trigger.

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
# Where the counter this clerk works at actually is, read off the collision
# the scene already declares. Every other person in the game has stood behind
# their furniture this way since the counters were fixed; the ServicePoint
# clerks were the ones still using a hand-typed offset, which is why the hotel
# receptionist was drawn hovering over her own desk.
const COUNTER := preload("res://scenes/npc/Counters.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")
const PLACES := preload("res://scenes/world/ActivityPlaces.gd")

@export var service: String = ""
@export var prompt_text: String = "E — Use"
@export var clerk: String = ""       # optional NPC sheet name behind the counter
@export var clerk_facing: String = "down"
# Where the clerk's FEET go, relative to this point.
#
# Behind the counter means higher up the screen in this flat projection, not
# further back: the counter's top slab is its far edge and its body is the
# face turned towards the player. The old default put the clerk's soles level
# with the slab, so they stood ON the counter - a small figure balanced on the
# furniture in every service room in the game.
@export var clerk_offset: Vector2 = Vector2(0, -134)

var _look: Dictionary = {}
var _t: float = 0.0
var _clerk_layer: Node2D

var player_nearby := false
var _busy := false
var _destination: String = ""

# Only actual entrances expose a destination. Exposing an empty exported
# target on every counter would break the existing single-door return fallback.
func _get(property: StringName) -> Variant:
	if property == &"target_scene" and not _destination.is_empty(): return _destination
	if property == &"is_return" and not _destination.is_empty(): return false
	return null


func _ready() -> void:
	if service == "local":
		var entry: Dictionary = PLACES.entry(get_parent().scene_file_path, String(name))
		if not entry.is_empty():
			_destination = PLACES.scene_path(String(entry["place"]))
			prompt_text = String(entry["prompt"])
			if entry.has("at"): position = Vector2(entry["at"][0],entry["at"][1])
			var shape := RectangleShape2D.new()
			shape.size = Vector2(76,64)
			$CollisionShape2D.shape = shape
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.text = prompt_text
	$Prompt.visible = false
	if not clerk.is_empty():
		# Drawn by CharacterArt like every other person in the game. It used
		# to be one of the five authored 32px sheets, which meant every clerk
		# in the world was one of five Berliners at the wrong scale.
		# Dressed for the counter they are standing at, and from the city they
		# are standing in. They stay nameless - they are the counter, not a
		# character - but a hotel receptionist and a dock foreman should never
		# again be the same coat in two colours.
		_look = ROSTER.clerk_look(clerk, service, GameState.city)
		if get_parent().get_meta("object_silhouettes", false):
			_clerk_layer = Node2D.new()
			_clerk_layer.name = "Clerk_" + String(name)
			# Match the player and object depth origin, 22px above the soles.
			# Drawing stays at the authored feet anchor; only sorting changes.
			_clerk_layer.position = position + clerk_offset - Vector2(0,22)
			get_parent().add_child.call_deferred(_clerk_layer)
			_clerk_layer.draw.connect(_draw_clerk)
		set_process(true)
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby or _busy or get_tree().paused:
		return
	if event.is_action_pressed("interact"):
		if Interactables.dialogue_in_range():
			return
		get_viewport().set_input_as_handled()
		_use()


func _use() -> void:
	_busy = true
	if not _destination.is_empty():
		GameState.last_scene = get_parent().scene_file_path
		GameState.spawn_tag = ""
		TransitionManager.go(_destination)
		return
	await Services.run(service, self)
	_busy = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _process(delta: float) -> void:
	_t += delta
	$Prompt.visible = player_nearby and not _busy and not Interactables.dialogue_in_range()
	queue_redraw()
	if is_instance_valid(_clerk_layer): _clerk_layer.queue_redraw()

func _draw_clerk() -> void:
	CHAR.draw_figure(_clerk_layer, Vector2(0,22), CHAR.world_unit(self), _look,
		"interact" if fmod(_t*0.4,3.0)<1.1 else "stand", _t, absi(clerk.hash()))


func _draw() -> void:
	if _look.is_empty() or is_instance_valid(_clerk_layer):
		return
	# Facing the player, and busy: a clerk who is not doing anything is a
	# mannequin. The dip is the same one the sprite sheet uses for interact.
	var act: String = "interact" if fmod(_t * 0.4, 3.0) < 1.1 else "stand"
	# Clipped at the waist: the counter is drawn under this node, so the legs
	# would otherwise be painted across the front of it.
	# The counter is background art drawn UNDER this node, so the clerk clips
	# themselves against it. `clerk_offset` is only the fallback now, for a
	# counter that is drawn but declares no collision - and barriers.gd exists
	# to find those.
	var unit: float = CHAR.world_unit(self)
	var st: Dictionary = COUNTER.stance(self, unit,
		global_position + clerk_offset)
	var off: Vector2 = st["offset"]
	var at: Vector2 = clerk_offset + Vector2(0.0, off.y)
	var clip: int = int(st["clip"])
	if clip > 90:
		clip = 23
	CHAR.draw_figure(self, at, unit, _look, act, _t, absi(clerk.hash()), clip)
