extends Node

# Runs one chapter of a story as a scene in the street.
#
# A chapter is a list of steps, each a Dictionary with a "do". It is data rather
# than code for the same reason the district activities are: the thing worth
# changing is the writing, and the writing should not be tangled up in awaits.
#
#   label   {name, save}            a place to jump to; `save` makes it the
#                                   point a scene resumes from if he walks off
#   actor   {id, at, act, hold, outfit, visible}   put somebody somewhere
#   walk    {id, to, pace, wait}    and move them
#   act     {id, act, secs, then}   one thing with the body, for a while
#   hold    {id, prop}              what is in their hands
#   line    {id, say, act}          said over their head, out loud, not to him
#   ask     {id, say, stage, options, silent}   said TO him: the dialogue box,
#                                   and the option he takes says where to go
#   think   {text}                  what he makes of it
#   prop    {id, kind, at, label, carryable}  a thing in the street
#   unprop  {id}
#   carry   {props, to, radius, hint}          he carries things somewhere
#   point   {options: [{prop, go, set, misread}], hint}   choose in the street
#   understand {word, meaning, language}       found out without a dialogue
#   goto    {to}   if {flag|register|..., then, else}   set {flag, value}
#   memory  {title, text}           goes in his notebook
#   cue     {call}                  anything the city's story does itself
#   wait    {secs}   hide/show {id}   leave {id, to}   end
#
# The options of an `ask` are dialogue-box responses (gesture/words/say, style,
# rep, ritual, confirm, misread) plus `go`, the label to continue from, `set`,
# flags to set, and `if`/`unless`, flags that decide whether it is offered.
#
# Every wait here is on this node's own signal. When he walks out of the scene
# mid-chapter, this node goes with it and the chapter simply stops - it does
# not wake up in the next district talking to nobody. The story resumes from
# its last saved label the next time he comes back.

signal frame(delta: float)

const ACTOR := preload("res://scenes/story/StoryActor.gd")
const PROP := preload("res://scenes/story/StoryProp.gd")
const ZONE := preload("res://scenes/story/StoryZone.gd")

const LEFT := "__left__"
const END := "__end__"
const STEP_GUARD := 4000

var host: Node2D
var cast: Dictionary = {}
var actors: Dictionary = {}
var props: Dictionary = {}
var story: Object
var chapter: String = ""

var _running: bool = false
var _frozen: bool = false
var _skip: bool = false
var _banner: CanvasLayer
var _banner_label: Label
var _carry_before: String = ""
var _carry_active: bool = false
var _leaving: bool = false
var _pointed_id: String = ""
var _discoveries: Array = []
var _last_context: String = ""
var _last_speaker: String = ""
# The last few lines spoken in this scene, newest last, so a discovery can
# show the sentence its word was actually said in.
var _heard: Array = []
const HEARD_KEPT := 12


func _ready() -> void:
	add_to_group("story_director")


func _process(delta: float) -> void:
	frame.emit(delta)


func running() -> bool:
	return _running


func run(steps: Array, from: String = "", chapter_id: String = "") -> String:
	_leaving = false
	if host != null and not host.tree_exiting.is_connected(cancel):
		host.tree_exiting.connect(cancel, CONNECT_ONE_SHOT)
	chapter = chapter_id
	var labels: Dictionary = {}
	for i in range(steps.size()):
		var s: Dictionary = steps[i]
		if String(s.get("do", "")) == "label":
			labels[String(s.get("name", ""))] = i
	var at: int = int(labels.get(from, 0))
	_running = true
	_freeze(true)
	var result: String = "done"
	var guard: int = 0
	while at < steps.size():
		if String(steps[at].get("do", "")) != "understand":
			await _show_discoveries()
		if _leaving:
			result = "left"
			break
		guard += 1
		if guard > STEP_GUARD:
			push_error("Story %s ran %d steps without ending" % [chapter, guard])
			result = "error"
			break
		var jump: String = await _step(steps[at])
		if _leaving:
			result = "left"
			break
		if jump == LEFT:
			result = "left"
			break
		if jump == END:
			break
		if jump.is_empty():
			at += 1
			continue
		if not labels.has(jump):
			push_error("Story %s has no label '%s'" % [chapter, jump])
			result = "error"
			break
		at = int(labels[jump])
	await _show_discoveries()
	_hide_banner()
	_freeze(false)
	_running = false
	if is_instance_valid(host) and host.tree_exiting.is_connected(cancel):
		host.tree_exiting.disconnect(cancel)
	return result


func _step(s: Dictionary) -> String:
	match String(s.get("do", "")):
		"label":
			if bool(s.get("save", false)) and story != null:
				if story.has_method("save_stage"):
					story.save_stage(chapter, snapshot())
				story.checkpoint(chapter, String(s.get("name", "")))
		"actor":
			_place(s)
		"walk":
			var walker: Node2D = _actor(String(s["id"]))
			walker.walk_to(_v(s["to"]), float(s.get("pace", 58.0)))
			while bool(s.get("wait", true)) and walker.is_walking() and not _leaving:
				await frame
		"act":
			var doer: Node2D = _actor(String(s["id"]))
			doer.act = String(s.get("act", "stand"))
			if s.has("secs"):
				await _wait(float(s["secs"]))
				doer.act = String(s.get("then", "stand"))
		"hold":
			_actor(String(s["id"])).holding = String(s.get("prop", ""))
		"line":
			await _line(s)
		"ask":
			return await _ask(s)
		"think":
			await _think(String(s.get("text", "")))
		"prop":
			_prop(s)
		"unprop":
			var gone = props.get(String(s["id"]))
			if gone != null and is_instance_valid(gone):
				gone.queue_free()
			props.erase(String(s["id"]))
		"carry":
			return await _carry(s)
		"point":
			return await _point(s)
		"understand":
			_understand(s)
		"goto":
			return String(s.get("to", ""))
		"if":
			if story != null and story.test(s):
				return String(s.get("then", ""))
			return String(s.get("else", ""))
		"set":
			if story != null:
				story.set_flag(String(s["flag"]), s.get("value", true))
		"memory":
			if story != null:
				story.remember(String(s.get("title", "")), String(s.get("text", "")))
		"cue":
			if story != null:
				var r = await story.cue(String(s.get("call", "")), s, self)
				if r is String:
					return r
		"wait":
			await _wait(float(s.get("secs", 0.5)))
		"hide", "show":
			var who = actors.get(String(s["id"]), props.get(String(s["id"])))
			if who != null and is_instance_valid(who):
				who.visible = String(s["do"]) == "show"
		"leave":
			var leaver: Node2D = _actor(String(s["id"]))
			leaver.walk_to(_v(s["to"]), float(s.get("pace", 58.0)))
			while leaver.is_walking() and not _leaving:
				await frame
			leaver.queue_free()
			actors.erase(String(s["id"]))
		"end":
			return END
		_:
			push_warning("Story %s: unknown step %s" % [chapter, str(s)])
	return ""


# ── People and things ─────────────────────────────────────────────────────────

func _v(xy) -> Vector2:
	if xy is Vector2:
		return xy
	return Vector2(float(xy[0]), float(xy[1]))


func _actor(id: String) -> Node2D:
	if actors.has(id) and is_instance_valid(actors[id]):
		return actors[id]
	var a := Node2D.new()
	a.set_script(ACTOR)
	a.set("id", id)
	a.set("look", Dictionary(cast.get(id, {})).get("look", {}))
	host.add_child(a)
	actors[id] = a
	return a


func _place(s: Dictionary) -> void:
	var a: Node2D = _actor(String(s["id"]))
	if s.has("at"):
		a.position = _v(s["at"])
	if s.has("act"):
		a.act = String(s["act"])
	if s.has("hold"):
		a.holding = String(s["hold"])
	if s.has("outfit") and story != null:
		a.outfit = String(s["outfit"])
		a.look = story.look(String(s["id"]), String(s["outfit"]))
	a.visible = bool(s.get("visible", true))
	# Nobody is pressed E at in the middle of a scene.
	a.talkable = false


func _prop(s: Dictionary) -> void:
	var id: String = String(s["id"])
	var p = props.get(id)
	if p == null or not is_instance_valid(p):
		p = Node2D.new()
		p.set_script(PROP)
		p.set("id", id)
		host.add_child(p)
		props[id] = p
	p.kind = String(s.get("kind", p.kind))
	p.label = String(s.get("label", p.label))
	p.carryable = bool(s.get("carryable", false))
	if s.has("at"):
		p.position = _v(s["at"])
	p.visible = true
	p.queue_redraw()


# ── Speech ────────────────────────────────────────────────────────────────────

# A line as the pieces the glyph system reads: [[as shown, the word], ...].
static func pairs_of(text: String) -> Array:
	var out: Array = []
	for raw: String in text.split(" ", false):
		var key: String = raw.to_lower()
		for ch: String in ["?", "!", "¿", "¡", ".", ",", ";", ":", "\"", "„", "“", "”", "…", "(", ")", "'", "‚", "‘", "’"]:
			key = key.replace(ch, "")
		key = key.strip_edges().trim_prefix("-").trim_suffix("-")
		out.append([raw, key])
	return out


func _entry_words(text: String, lang: String) -> Array:
	var out: Array = []
	for pair: Array in pairs_of(text):
		out.append({"text": String(pair[0]), "word": String(pair[1]), "language": lang})
	return out


func _line(s: Dictionary) -> void:
	var id: String = String(s["id"])
	var a: Node2D = _actor(id)
	var c: Dictionary = cast.get(id, {})
	var lang: String = String(s.get("language", c.get("language", "german")))
	var text: String = String(s.get("say", ""))
	var pairs: Array = pairs_of(text)
	_remember_line(String(c.get("name", id.capitalize())), text)
	# Being said near is being said to, as far as learning goes - once.
	if lang != "english" and (story == null or story.first_time(chapter + "|" + text)):
		for pair: Array in pairs:
			if not String(pair[1]).is_empty():
				GameState.expose(lang, String(pair[1]), "hear")
	var voiced: float = AudioManager.say(String(c.get("voice", "")),
		String(s.get("tts", text)))
	var secs: float = maxf(voiced + 0.5, 1.5 + 0.32 * float(pairs.size()))
	if s.has("act"):
		a.act = String(s["act"])
	a.say(pairs, lang, secs)
	await _wait(secs)
	if _skip:
		AudioManager.stop_voice()
	a.hush()
	if s.has("act"):
		a.act = String(s.get("then", "stand"))


func _ask(s: Dictionary) -> String:
	var id: String = String(s["id"])
	var c: Dictionary = cast.get(id, {})
	_last_context = String(s.get("stage", ""))
	_last_speaker = String(c.get("name", id.capitalize()))
	var lang: String = String(s.get("language", c.get("language", "german")))
	var say: String = String(s.get("say", ""))
	_remember_line(_last_speaker, say)
	var entry: Dictionary = {
		"words": _entry_words(say, lang),
		"stage": String(s.get("stage", "")),
		"keep": true,
		"voice": String(c.get("voice", "")),
		"silent": bool(s.get("silent", false)),
		"in_world": true,
	}
	if s.has("tts"):
		entry["tts"] = s["tts"]
	var options: Array = []
	for o: Dictionary in s.get("options", []):
		if story != null and not story.allows(o):
			continue
		var r: Dictionary = o.duplicate(true)
		if not r.has("moment") and story != null:
			r["moment"] = story.moment(chapter)
		if lang == "english" and not r.has("language"):
			r["language"] = GameState.local_language()
		options.append(r)
	entry["responses"] = options
	var a = actors.get(id)
	if a != null and is_instance_valid(a):
		a.act = String(s.get("act", "talk"))
	var dlg := get_tree().get_first_node_in_group("dialogue_box")
	if dlg == null:
		return LEFT
	var key: String = chapter + "|" + say + "|" + String(s.get("stage", ""))
	var who: Dictionary = {
		"name": String(c.get("name", id.capitalize())),
		"relationship": story.relationship(id) if story != null else "",
		"color": c.get("color", Color(0.85, 0.52, 0.42)),
		"region": String(c.get("region", "")),
		"voice": String(c.get("voice", "")),
		"look": a.look if a != null and is_instance_valid(a) else c.get("look", {}),
		"person": story.person(id) if story != null else {},
		"grant": story.first_time(key) if story != null else true,
	}
	var resp: Dictionary = await dlg.ask(entry, who)
	if not resp.is_empty():
		_last_context += "\n\nYou: " + GameState.phrase_for(resp)
	if a != null and is_instance_valid(a):
		a.act = "stand"
	await _settle()
	if resp.is_empty():
		return LEFT
	if story != null:
		var flags: Dictionary = resp.get("set", {})
		for k: String in flags:
			story.set_flag(k, flags[k])
	# Some answers are a decision about how to talk from now on - taking the du
	# somebody offered. That is a habit, so it outlives the scene.
	if resp.has("register"):
		GameState.set_register(String(resp["register"]), GameState.local_language() if lang == "english" else lang)
	return String(resp.get("go", ""))


func _think(text: String) -> void:
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb == null or text.is_empty():
		return
	tb.show_thought(text)
	await frame
	while tb.visible and not _leaving:
		await frame


func _understand(s: Dictionary) -> void:
	var lang: String = String(s.get("language", GameState.local_language()))
	var word: String = String(s["word"])
	var meaning: String = String(s.get("meaning", ""))
	var moment: String = story.moment(chapter) if story != null else ""
	if GameState.understand(lang, word, meaning, moment):
		_discoveries.append({"language":lang, "word":word, "meaning":meaning})


func _show_discoveries() -> void:
	if _discoveries.is_empty(): return
	var words := _discoveries.duplicate(true)
	_discoveries.clear()
	if _leaving: return
	var discovery := get_tree().get_first_node_in_group("word_discovery")
	if discovery != null:
		var context := _last_context.strip_edges()
		if context.is_empty() and story != null: context = story.moment(chapter)
		var speaker := _last_speaker
		# The sentence the word lived in comes first. The last choice's stage
		# direction can belong to an earlier moment of the scene.
		var heard := _spoken_in(String(words[0].get("word", "")))
		if not heard.is_empty():
			speaker = String(heard["speaker"])
			context = ("«%s»\n\n%s" % [String(heard["text"]), context]).strip_edges()
		await discovery.present(words, context, speaker)


func _remember_line(speaker: String, text: String) -> void:
	if text.strip_edges().is_empty():
		return
	_heard.append({"speaker": speaker, "text": text})
	if _heard.size() > HEARD_KEPT:
		_heard.pop_front()


# The most recent line in which this word was said, or {}.
func _spoken_in(word: String) -> Dictionary:
	var key: String = word.to_lower()
	for i in range(_heard.size() - 1, -1, -1):
		for pair: Array in pairs_of(String(_heard[i]["text"])):
			if String(pair[1]) == key:
				return _heard[i]
	return {}


# ── Waiting ───────────────────────────────────────────────────────────────────

# Game time, not wall time: this node pauses with the tree, so a line does not
# run out behind the escape menu. Interact skips a line he has finished reading.
func _wait(secs: float) -> void:
	_skip = false
	var t: float = 0.0
	while t < secs and not _skip and not _leaving:
		t += await frame


# Until whatever the dialogue box left behind - a thought, usually - is closed.
func _settle() -> void:
	if _leaving:
		return
	await frame
	var tb := get_tree().get_first_node_in_group("thought_box")
	while tb != null and tb.visible and not _leaving:
		await frame


# ── Doing ─────────────────────────────────────────────────────────────────────

func _point(s: Dictionary) -> String:
	_pointed_id = ""
	var offered: Array = []
	for option: Dictionary in s.get("options", []):
		if story != null and not story.allows(option):
			continue
		var prop = props.get(String(option.get("prop", "")))
		if not is_instance_valid(prop) or not prop.visible:
			continue
		prop.pointable = true
		prop.pointed.connect(_receive_point)
		offered.append(option)
	if offered.is_empty():
		push_error("Story %s has no visible things to point at" % chapter)
		return LEFT
	_show_banner(String(s.get("hint", "Point at the object you mean.")))
	_freeze(false)
	while _pointed_id.is_empty() and not _leaving:
		await frame
	for option: Dictionary in offered:
		var prop = props.get(String(option["prop"]))
		if is_instance_valid(prop):
			prop.pointable = false
			if prop.pointed.is_connected(_receive_point):
				prop.pointed.disconnect(_receive_point)
	_hide_banner()
	_freeze(true)
	if _leaving:
		return LEFT
	for option: Dictionary in offered:
		if String(option["prop"]) != _pointed_id:
			continue
		for word: String in option.get("misread", {}):
			GameState.misunderstand(GameState.local_language(), word, String(option["misread"][word]))
		if story != null:
			for key: String in option.get("set", {}):
				story.set_flag(key, option["set"][key])
		return String(option.get("go", ""))
	return LEFT


func _receive_point(id: String) -> void:
	_pointed_id = id


func _carry(s: Dictionary) -> String:
	_carry_before = GameState.carrying
	_carry_active = true
	var ids: Array = s.get("props", [])
	var kind: String = ""
	for pid: String in ids:
		var p = props.get(pid)
		if p != null and is_instance_valid(p):
			p.carryable = true
			p.visible = true
			kind = "story_" + String(p.kind)
	var zone := Node2D.new()
	zone.set_script(ZONE)
	zone.position = _v(s["to"])
	zone.radius = float(s.get("radius", 34.0))
	host.add_child(zone)
	_show_banner(String(s.get("hint", "")))
	_freeze(false)
	var left: int = ids.size()
	while left > 0:
		await frame
		if _leaving:
			return LEFT
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			continue
		if GameState.carrying == kind \
				and player.global_position.distance_to(zone.position) <= zone.radius + 12.0:
			GameState.carrying = ""
			GameState.job_changed.emit(GameState.active_job)
			left -= 1
			if story != null:
				story.delivered(chapter, kind, ids.size() - left, self)
	zone.queue_free()
	_restore_load()
	_hide_banner()
	_freeze(true)
	return ""


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


# He stands still while somebody is doing something in front of him, and gets
# his feet back the moment it is his turn to do something.
func _freeze(on: bool) -> void:
	_frozen = on
	var p := _player()
	if p == null:
		return
	p.set_physics_process(not on)
	if on and p is CharacterBody2D:
		(p as CharacterBody2D).velocity = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if get_tree().paused or not _running or not event.is_action_pressed("interact"):
		return
	if not _frozen:
		# His turn with his hands. Leave the key to whatever he is standing by
		# that belongs to this scene, and keep it from the Späti door behind it.
		for p in props.values():
			if is_instance_valid(p) and p.near_player():
				return
		get_viewport().set_input_as_handled()
		return
	_skip = true
	get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	cancel()
	# Removing a director must never leave a surviving player unable to move.
	if _frozen:
		_freeze(false)
	AudioManager.stop_voice()
	_restore_load()


func cancel() -> void:
	if _leaving or not _running:
		return
	_leaving = true
	var dialogue := get_tree().get_first_node_in_group("dialogue_box")
	if dialogue != null and dialogue.visible:
		dialogue._close()
	var cinema := get_tree().get_first_node_in_group("cutscene")
	if cinema != null and cinema._open:
		cinema._close()
	var discovery := get_tree().get_first_node_in_group("word_discovery")
	if discovery != null and discovery._open:
		discovery.close()
	# Wake the pending operation so RefCounted story callbacks can unwind.
	# Freeing a signal's node alone leaves their await chain suspended.
	frame.emit(0.0)
	_restore_load()


func _restore_load() -> void:
	if _carry_active:
		GameState.carrying = _carry_before
		GameState.job_changed.emit(GameState.active_job)
		_carry_active = false


func snapshot() -> Dictionary:
	var saved: Dictionary = {"actors": {}, "props": {}, "carrying": GameState.carrying}
	for id: String in actors:
		var actor: Node2D = actors[id]
		if not is_instance_valid(actor):
			continue
		saved["actors"][id] = {"at": [actor.position.x, actor.position.y],
			"act": actor.act, "hold": actor.holding, "visible": actor.visible,
			"outfit": actor.outfit}
	for id: String in props:
		var prop: Node2D = props[id]
		if not is_instance_valid(prop):
			continue
		saved["props"][id] = {"at": [prop.position.x, prop.position.y],
			"kind": prop.kind, "label": prop.label, "visible": prop.visible}
	return saved


func restore(saved: Dictionary) -> void:
	if saved.is_empty():
		return
	for id: String in actors.keys():
		if not saved.get("actors", {}).has(id) and is_instance_valid(actors[id]):
			actors[id].visible = false
	for id: String in props.keys():
		if not saved.get("props", {}).has(id) and is_instance_valid(props[id]):
			props[id].visible = false
	for id: String in saved.get("actors", {}):
		var spec: Dictionary = saved["actors"][id].duplicate(true)
		spec["id"] = id
		_place(spec)
	for id: String in saved.get("props", {}):
		var spec: Dictionary = saved["props"][id].duplicate(true)
		spec["id"] = id
		_prop(spec)
		props[id].visible = spec.get("visible", true)
	GameState.carrying = String(saved.get("carrying", ""))


func _show_banner(text: String) -> void:
	if text.is_empty():
		return
	if _banner == null:
		_banner = CanvasLayer.new()
		_banner.layer = 4
		var panel := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.05, 0.045, 0.11, 0.88)
		sb.border_color = Color(0.886, 0.706, 0.361, 0.55)
		sb.border_width_bottom = 1
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 18.0
		sb.content_margin_right = 18.0
		sb.content_margin_top = 8.0
		sb.content_margin_bottom = 8.0
		panel.add_theme_stylebox_override("panel", sb)
		panel.anchor_left = 0.5
		panel.anchor_right = 0.5
		panel.offset_top = 18.0
		panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_banner_label = Label.new()
		_banner_label.add_theme_font_size_override("font_size", 16)
		_banner_label.add_theme_color_override("font_color", Color(0.95, 0.90, 0.78))
		panel.add_child(_banner_label)
		_banner.add_child(panel)
		add_child(_banner)
	_banner_label.text = text
	_banner.visible = true


func _hide_banner() -> void:
	if _banner != null:
		_banner.visible = false
