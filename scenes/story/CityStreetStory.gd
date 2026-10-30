extends RefCounted

const DIRECTOR := preload("res://scenes/story/StoryDirector.gd")
const CHAR := preload("res://scenes/npc/CharacterArt.gd")
var city: String = ""
var chapters: Dictionary = {}
var actor_name: String = ""
var main_id: String = ""
var chapter: String = ""


func state() -> Dictionary:
	if not GameState.world_flags.has(city + "_story"):
		GameState.world_flags[city + "_story"] = {"resume": {}, "stages": {}, "flags": {}, "seen": {}, "done": {}}
	return GameState.world_flags[city + "_story"]


static func play_story(story: RefCounted, chapter_number: int) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var host := tree.current_scene as Node2D
	if host == null:
		return false
	story.chapter = str(chapter_number)
	var key: Node2D = host.get_node_or_null(story.actor_name)
	var old_layer: int = key.collision_layer if key is CollisionObject2D else 0
	if key != null:
		key.hide()
		if key is CollisionObject2D:
			key.collision_layer = 0
		key.set_process(false)
	var previous_carry: String = GameState.carrying
	var director := DIRECTOR.new()
	director.host = host
	director.story = story
	director.cast = story.cast()
	var dressing: Dictionary = host.get_meta("street_story_" + story.city, {})
	for id: String in dressing.get("actors", {}):
		if is_instance_valid(dressing["actors"][id]):
			director.actors[id] = dressing["actors"][id]
			director.actors[id].holding = ""
	for id: String in dressing.get("props", {}):
		if is_instance_valid(dressing["props"][id]):
			director.props[id] = dressing["props"][id]
	host.add_child(director)
	var from: String = story.resume_label(story.chapter)
	if not from.is_empty():
		director.restore(story.saved_stage(story.chapter))
	var result: String = await director.run(story.chapters[story.chapter], from, story.chapter)
	var departing: bool = host.is_queued_for_deletion() or host.has_meta("story_departing")
	var residents: Dictionary = {}
	for id: String in director.actors:
		var actor: Node2D = director.actors[id]
		if not is_instance_valid(actor):
			continue
		if id == story.main_id or departing:
			if id == story.main_id and is_instance_valid(key) and not departing:
				key.position = actor.position
			actor.queue_free()
		else:
			actor.hush()
			actor.act = "stand"
			residents[id] = actor
	var things: Dictionary = {}
	for id: String in director.props:
		var prop: Node2D = director.props[id]
		if not is_instance_valid(prop):
			continue
		if departing or not prop.visible:
			prop.queue_free()
		else:
			prop.carryable = false
			prop.pointable = false
			things[id] = prop
	if not departing:
		# The neighbours and things just placed stay in the world when the
		# conversation closes. The next chapter reuses them instead of doubling.
		host.set_meta("street_story_" + story.city, {"actors":residents, "props":things})
	director.queue_free()
	GameState.carrying = previous_carry
	GameState.job_changed.emit(GameState.active_job)
	if is_instance_valid(key):
		key.show()
		key.set_process(true)
		if key is CollisionObject2D:
			key.collision_layer = old_layer
	return result == "done"


func cast() -> Dictionary:
	return {}


func look(id: String, _outfit: String = "") -> Dictionary:
	return cast().get(id, {}).get("look", {})


func person(_id: String) -> Dictionary:
	return {"build":"adult"}


func relationship(_id: String) -> String:
	return ""


func checkpoint(id: String, label: String) -> void:
	state()["resume"][id] = label
	SaveManager.checkpoint()


func save_stage(id: String, value: Dictionary) -> void:
	state()["stages"][id] = value


func saved_stage(id: String) -> Dictionary:
	return state()["stages"].get(id, {})


func resume_label(id: String) -> String:
	return String(state()["resume"].get(id, ""))


func flag(key: String):
	return state()["flags"].get(key, null)


func set_flag(key: String, value) -> void:
	state()["flags"][key] = value


func allows(option: Dictionary) -> bool:
	for key: String in option.get("if", {}):
		if flag(key) != option["if"][key]:
			return false
	for key: String in option.get("unless", {}):
		if flag(key) == option["unless"][key]:
			return false
	return true


func test(step: Dictionary) -> bool:
	return bool(flag(step.get("flag", "")))


func first_time(key: String) -> bool:
	if state()["seen"].has(key):
		return false
	state()["seen"][key] = true
	return true


func moment(id: String) -> String:
	return "%s, chapter %d" % [String(GameState.CITIES[city]["name"]), int(id) + 1]


func remember(title: String, text: String) -> void:
	if state()["flags"].get("memory_" + title, false):
		return
	state()["flags"]["memory_" + title] = true
	Journey.ledger()["memories"][city] = text
	Journey.record(title, text)


func delivered(_chapter: String, _kind: String, _count: int, _director: Node) -> void:
	pass


func cue(name: String, _step: Dictionary, director: Node):
	if name == "holiday":
		var cinema := director.get_tree().get_first_node_in_group("cutscene")
		if cinema == null:
			return "__left__"
		cinema.play(city, Journey.holiday_reel(city), true)
		await cinema.finished
		if not cinema.completed:
			return "__left__"
	elif name == "done":
		if bool(state()["done"].get(director.chapter, false)):
			return null
		state()["done"][director.chapter] = true
		state()["resume"].erase(director.chapter)
		state()["stages"].erase(director.chapter)
		if int(director.chapter) < 3:
			Story.add_round(city)
		else:
			Story.mark_holiday(city)
		Journey.guide(city)
		SaveManager.checkpoint()
	return null
