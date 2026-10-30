extends Node2D

# The part of Berlin's story that is standing in this street.
#
# One of these sits in Mitte and one in Prenzlauer Berg. When the street loads
# it puts out whatever the story says is there - Kerstin at her door with the
# crates she has not moved yet, the chair by the window once there is one, the
# tape on it once it has been written, Emil on his bench while somebody is on
# their way to him - and when he talks to one of them, it hands the street to a
# StoryDirector and lets the chapter play in it. Afterwards it dresses the
# street again from the state, so what is left standing is always what is true.

const STORY := preload("res://scenes/story/berlin/BerlinStory.gd")
const SCRIPT := preload("res://scenes/story/berlin/BerlinScript.gd")
const LATE := preload("res://scenes/story/berlin/BerlinScriptLate.gd")
const DIRECTOR := preload("res://scenes/story/StoryDirector.gd")
const ACTOR := preload("res://scenes/story/StoryActor.gd")
const PROP := preload("res://scenes/story/StoryProp.gd")

@export var district: String = "mitte"

var story: RefCounted
var _people: Dictionary = {}
var _things: Dictionary = {}
var _busy: bool = false


func _ready() -> void:
	add_to_group("berlin_stage")
	story = STORY.new()
	story.stage = self
	# A crate or a chair from a scene he walked out of is not in his arms any
	# more; the bag for Emil is, until Emil has it, because it is his to carry
	# across the city - and `carrying` is not in a save, so a load restores it.
	if GameState.carrying in ["story_crate", "story_chair"]:
		GameState.carrying = ""
	if STORY.flag("bag") == true and not STORY.done("3") and GameState.carrying.is_empty():
		GameState.carry_load("story_bag")
	# After the environment has put the street's own things where they belong.
	_dress.call_deferred()


func busy() -> bool:
	return _busy


# ── Who and what is in the street ────────────────────────────────────────────

func _wanted() -> Dictionary:
	var people: Dictionary = {}
	var things: Dictionary = {}
	if district == "mitte":
		if not STORY.done("1"):
			people["kerstin"] = {"at": [214, 478], "act": "haul"}
			for i in range(3):
				things["c%d" % (i + 1)] = {"kind": "crate", "at": SCRIPT.CRATES[i]}
		else:
			people["kerstin"] = {"at": SCRIPT.K, "act": "stand"}
			things["stack"] = {"kind": "crate", "at": [240, 468], "label": "PFAND"}
			things["chair"] = {"kind": "chair", "at": SCRIPT.CHAIR,
				"label": "DER NEUE" if STORY.done("4") else ""}
		if STORY.done("4"):
			things["emil_chair"] = {"kind": "chair", "at": LATE.EMIL_CHAIR, "label": "EMIL"}
			people["emil"] = {"at": [LATE.EMIL_CHAIR[0], LATE.EMIL_CHAIR[1] + 4], "act": "sit"}
	elif district == "prenzlberg":
		things["bench"] = {"kind": "bench", "at": LATE.BENCH}
		if not STORY.due_emil().is_empty():
			people["emil"] = {"at": LATE.EMIL_SEAT, "act": "sit"}
	return {"people": people, "things": things}


func _dress() -> void:
	var want: Dictionary = _wanted()
	var people: Dictionary = want["people"]
	var things: Dictionary = want["things"]
	var cast: Dictionary = story.cast()
	for id: String in _people.keys():
		if not people.has(id) or not is_instance_valid(_people[id]):
			if is_instance_valid(_people[id]):
				_people[id].queue_free()
			_people.erase(id)
	for id2: String in _things.keys():
		if not things.has(id2) or not is_instance_valid(_things[id2]):
			if is_instance_valid(_things[id2]):
				_things[id2].queue_free()
			_things.erase(id2)
	var host := get_parent() as Node2D
	for id3: String in people:
		var spec: Dictionary = people[id3]
		var a: Node2D = _people.get(id3)
		if a == null:
			a = Node2D.new()
			a.set_script(ACTOR)
			a.set("id", id3)
			host.add_child(a)
			a.interacted.connect(_talk)
			_people[id3] = a
		a.look = Dictionary(cast.get(id3, {})).get("look", {})
		a.position = Vector2(float(spec["at"][0]), float(spec["at"][1]))
		a.act = String(spec.get("act", "stand"))
		a.holding = ""
		a.visible = true
		a.talkable = true
		a.prompt_text = "Talk"
	for id4: String in things:
		var t: Dictionary = things[id4]
		var p: Node2D = _things.get(id4)
		if p == null:
			p = Node2D.new()
			p.set_script(PROP)
			p.set("id", id4)
			host.add_child(p)
			_things[id4] = p
		p.kind = String(t["kind"])
		p.label = String(t.get("label", ""))
		p.position = Vector2(float(t["at"][0]), float(t["at"][1]))
		p.carryable = false
		p.visible = true
		p.queue_redraw()


# ── Talking ───────────────────────────────────────────────────────────────────

func due(id: String) -> String:
	if id == "kerstin":
		return STORY.due_kerstin()
	if id == "emil":
		return "emil_after" if district == "mitte" else STORY.due_emil()
	return ""


func _talk(id: String) -> void:
	if _busy or get_tree().paused:
		return
	var chapter: String = due(id)
	if chapter.is_empty():
		return
	await play(chapter)


# Plays one chapter in this street. Public so the tools that walk the story
# can drive it the same way a player does.
func play(chapter: String) -> String:
	_busy = true
	for a in _people.values():
		if is_instance_valid(a):
			a.talkable = false
	var director: Node = DIRECTOR.new()
	add_child(director)
	director.host = get_parent()
	director.story = story
	director.cast = story.cast()
	director.actors = _people.duplicate()
	director.props = _things.duplicate()
	if not story.resume_label(chapter).is_empty():
		director.restore(story.saved_stage(chapter))
	var result: String = await director.run(STORY.steps(chapter),
		story.resume_label(chapter), chapter)
	# Whatever the chapter made, the street is dressed again from the state.
	for id: String in director.actors:
		if not _people.has(id) and is_instance_valid(director.actors[id]):
			director.actors[id].queue_free()
	for id2: String in director.props:
		if not _things.has(id2) and is_instance_valid(director.props[id2]):
			director.props[id2].queue_free()
	director.queue_free()
	_busy = false
	_dress()
	return result
