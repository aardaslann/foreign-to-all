extends Node2D

# One of the people in a scene that is being staged in the street.
#
# Everybody else in this game stands where they were put and waits to be
# pressed E at, and a conversation with them happens in a box at the bottom of
# the screen. That is fine for a counter. It is wrong for a story, which is a
# thing that happens between people in a place: Kerstin carries a crate, points
# at a word on it, walks back inside, comes out with a bag. These are the
# people who can do that - walk to a mark, do something with their hands, and
# say a sentence over their own heads in a language he cannot read yet.
#
# Drawn by CharacterArt like everybody else. A second renderer for the people
# the story is about is how you get a cast that looks like two casts.

signal arrived
signal interacted(id: String)

const CHAR := preload("res://scenes/npc/CharacterArt.gd")
const NOTEBOOK := preload("res://scenes/ui/Notebook.gd")
const PROP := preload("res://scenes/story/StoryProp.gd")
# The ground line, in the node's own space. The player stands 22 above his
# feet too, so an actor and the alien at the same y sort the same way.
const FEET := Vector2(0.0, 22.0)
const REACH := 54.0
# How wide a line gets before it wraps. A speech bubble half the width of the
# street is a subtitle wearing a costume.
const BUBBLE_WIDTH := 230.0
const BUBBLE_FONT := 13

var id: String = ""
var look: Dictionary = {}
var outfit: String = ""
var act: String = "stand"
# What is in their hands: a CharacterArt prop key, or a StoryProp kind.
var holding: String = ""
var talkable: bool = false
var prompt_text: String = "Talk"
var interaction_reach: float = REACH
var speed: float = 58.0

var _to: Vector2 = Vector2.ZERO
var _walking: bool = false
var _t: float = 0.0
var _said: Array = []          # [[display, word], ...]
var _said_lang: String = ""
var _said_left: float = 0.0
var _near: bool = false
var _prompt: Label
var _body: StaticBody2D


func _ready() -> void:
	add_to_group("story_actor")
	_prompt = Label.new()
	_prompt.position = Vector2(-30.0, -96.0)
	_prompt.add_theme_font_size_override("font_size", 12)
	_prompt.z_index = 10
	_prompt.visible = false
	add_child(_prompt)
	# Solid at the feet, like every named person, so he walks round them
	# rather than through them.
	_body = StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(18.0, 8.0)
	shape.shape = rect
	shape.position = FEET - Vector2(0.0, 3.0)
	_body.add_child(shape)
	add_child(_body)
	visibility_changed.connect(func():
		_body.set_collision_layer_value(1, visible and not _walking))


func walk_to(at: Vector2, pace: float = 58.0) -> void:
	_to = at
	speed = pace
	_walking = position.distance_to(at) > 0.5
	_body.set_collision_layer_value(1, visible and not _walking)
	if not _walking:
		arrived.emit.call_deferred()


func is_walking() -> bool:
	return _walking


func say(pairs: Array, language: String, seconds: float) -> void:
	_said = pairs
	_said_lang = language
	_said_left = seconds
	# A word he has already found, said again over somebody's head.
	var said: PackedStringArray = []
	for pair: Array in pairs:
		said.append(String(pair[0]))
	var context: String = id + "|" + " ".join(said)
	var journal := get_tree().get_first_node_in_group("journal") if is_inside_tree() else null
	for pair2: Array in pairs:
		if NOTEBOOK.recall(language, String(pair2[1]), context) and journal != null:
			journal.toast_recognised(language, String(pair2[1]))


func hush() -> void:
	_said_left = 0.0


func near_player() -> bool:
	return _near


func _process(delta: float) -> void:
	_t += delta
	if get_tree().paused:
		_prompt.visible = false
		queue_redraw()
		return
	if _said_left > 0.0:
		_said_left -= delta
	if _walking:
		var d: Vector2 = _to - position
		var step: float = speed * delta
		if d.length() <= step:
			position = _to
			_walking = false
			_body.set_collision_layer_value(1, visible)
			arrived.emit()
		else:
			position += d.normalized() * step
	var player := get_tree().get_first_node_in_group("player") as Node2D
	_near = talkable and visible and player != null \
		and player.global_position.distance_to(global_position) <= interaction_reach
	_prompt.visible = _near
	if _near:
		_prompt.text = "[%s] %s" % [_key(), prompt_text]
	queue_redraw()


func _key() -> String:
	var controls := get_node_or_null("/root/Controls")
	if controls != null and controls.has_method("label_for"):
		return String(controls.label_for("interact"))
	return "E"


func _unhandled_input(event: InputEvent) -> void:
	if not _near or get_tree().paused:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interacted.emit(id)


func _draw() -> void:
	var unit: float = CHAR.world_unit(self)
	var who: Dictionary = look.duplicate()
	# Staged hands belong to the script, not a random wardrobe accessory.
	who["prop"] = ""
	var shown: String = "walk" if _walking else act
	var custom_hold: bool = false
	if not holding.is_empty():
		if CHAR.PROPS.has(holding):
			who["prop"] = holding
			who["prop_side"] = 0.0
		else:
			custom_hold = true
	# Sitting uses the seat surface as its origin; the node still sorts and
	# collides at ground level. Otherwise the back slats cross the face.
	var origin: Vector2 = FEET - Vector2(0, 7.0 * unit) if shown == "sit" else FEET
	CHAR.draw_figure(self, origin, unit, who, shown, _t, absi(id.hash()))
	if custom_hold:
		PROP.draw_kind(self, FEET + Vector2(0.0, -5.0 * unit), holding, unit * 0.62)
	if _said_left > 0.0 and not _said.is_empty():
		_bubble(Vector2(0.0, FEET.y - 29.0 * unit), clampf(_said_left / 0.35, 0.0, 1.0))


# What they are saying, over their head: glyphs for every word he cannot read
# yet, letters for the ones he can. English is never glyphed - he has been
# surrounded by it since he crashed and can read all of it, which is the joke
# London is built on and the reason Rika is so tempting.
func _bubble(at: Vector2, fade: float) -> void:
	var text: String = ""
	if _said_lang == "english":
		var parts: PackedStringArray = []
		for pair: Array in _said:
			parts.append(String(pair[0]))
		text = " ".join(parts)
	else:
		text = CHAR.snippet_text(_said, _said_lang)
	var font: Font = UIStyles.reading_font
	var size: Vector2 = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER,
		BUBBLE_WIDTH, BUBBLE_FONT)
	var w: float = minf(size.x, BUBBLE_WIDTH)
	var box := Rect2(at.x - w * 0.5 - 9.0, at.y - size.y - 10.0, w + 18.0, size.y + 12.0)
	var back := Color(0.050, 0.045, 0.110, 0.93 * fade)
	draw_rect(box, back)
	draw_rect(Rect2(box.position, Vector2(box.size.x, 1.0)), Color(0.36, 0.33, 0.58, 0.60 * fade))
	draw_colored_polygon(PackedVector2Array([
		Vector2(at.x - 4.0, box.end.y), Vector2(at.x + 4.0, box.end.y),
		Vector2(at.x, box.end.y + 6.0)]), back)
	draw_multiline_string(font, Vector2(box.position.x + 9.0,
		box.position.y + 6.0 + font.get_ascent(BUBBLE_FONT)), text,
		HORIZONTAL_ALIGNMENT_CENTER, w, BUBBLE_FONT, -1,
		Color(0.90, 0.88, 1.00, 0.97 * fade))
