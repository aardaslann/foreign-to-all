extends SceneTree

# Real-pace gameplay footage for the research-paper video, played the way a
# person plays: WASD and E on the keyboard, a mouse pointer for menus and
# replies, typed guesses, and time to read each line. Godot's movie writer
# records the game's own frames and sound at a fixed 30 fps.
#   <godot> --path . --resolution 1920x1080 --write-movie out.avi --fixed-fps 30 \
#     --script res://tools/research_film_capture.gd -- <segment>
# Segments:
#   opening  title screen, alien creator, the landing, the first trade
#   berlin   Kerstin's crates, Pfand guessed and corrected, then the notebook
#   flight   the Berlin airport desk, the route map, the flight to London
#   london   Val's "give me a hand" on the terrace
#   cities   a short walk down a street in six more cities
#   kiez     the first trade on its own, for iterating with FILM_DEBUG=1
# The movie writer does not record the system cursor, so the pointer is drawn
# here. trailer/src/research/ edits the recordings into the video; its README
# has the full rebuild.

const FPS := 30
const APPEARANCE := preload("res://scenes/player/AlienAppearance.gd")
const ARRIVE := 10.0
const IDLE_FADE := 2.4        # seconds before a still pointer fades
const TYPE_EVERY := 0.11      # seconds per typed character

# Replies are picked by what they say, the way a reader picks them.
const REPLIES := {
	"opening": ["Nod and hold steady eye contact", "action:buy_bread"],
	"berlin": ["Hold out a coin", "Put the coin away", "Shake your head. Honestly",
		"Put a hand on your own chest", "Sit on the chair", "Nod. Point at the hotel"],
	"london": ["I could.", "Yes. These ones?", "Milk in this one", "Is this another job?"],
}
# A guess typed before the meaning is shown. Other words are shown directly.
const GUESSES := {"pfand": "recycling?"}

const MOST_FRAMES := FPS * 420   # a stuck run must not fill the disk

var gs: Node
var segment := ""
var pointer: Control
var pointer_at := Vector2(1480, 860)
var pointer_idle := 0.0
var frames := 0
var debug := OS.has_environment("FILM_DEBUG")


func _initialize() -> void:
	# Before the autoloads are ready, so settings load from a fresh profile
	# (default volumes, windowed) and nothing touches the player's own saves.
	root.get_node("SaveManager").use_test_storage("research-film")
	_run.call_deferred()


func _run() -> void:
	gs = root.get_node("GameState")
	var args := OS.get_cmdline_user_args()
	segment = args[0] if not args.is_empty() else ""
	_make_pointer()
	match segment:
		"opening": await opening()
		"kiez": await first_trade()
		"berlin": await berlin()
		"flight": await flight()
		"london": await london()
		"cities": await cities()
		_:
			push_error("research film: name a segment (opening, berlin, flight, london, cities, kiez)")
			quit(1)
			return
	await hold(1.5)
	quit(0)


# ── Time ──────────────────────────────────────────────────────────────────────

func frame() -> void:
	await process_frame
	frames += 1
	if frames > MOST_FRAMES:
		push_error("research film: %s ran past %d frames" % [segment, MOST_FRAMES])
		quit(1)
	if debug and frames % FPS == 0:
		_print_state()
	pointer_idle += 1.0 / FPS
	if pointer != null:
		pointer.modulate.a = clampf(1.0 - (pointer_idle - IDLE_FADE) / 0.3, 0.0, 1.0)


# Once a second under FILM_DEBUG: where he is, and what is open if paused.
func _print_state() -> void:
	var p := player()
	print("[%ds] scene=%s player=%s carrying=%s paused=%s" % [frames / FPS,
		current_scene.name if current_scene != null else "-",
		p.global_position if p != null else "-", gs.carrying, paused])
	if not paused:
		return
	var d := get_first_node_in_group("dialogue_box")
	print("    dialog=%s revealing=%s rows=%s discovery=%s thought=%s pickup=%s choice=%s" % [
		d.visible if d else "-", d._revealing if d else "-",
		d._resp_box.get_child_count() if d else "-",
		get_first_node_in_group("word_discovery")._open,
		get_first_node_in_group("thought_box").visible,
		get_first_node_in_group("pickup")._open,
		get_first_node_in_group("choice_panel").get("_open")])


func hold(seconds: float) -> void:
	for i in range(int(round(seconds * FPS))):
		await frame()


func reading(text: String, least := 1.6, most := 6.5) -> float:
	return clampf(1.0 + text.length() / 20.0, least, most)


# ── Hands ─────────────────────────────────────────────────────────────────────

func tap(action: String, held := 4) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	for i in range(held):
		await frame()
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await frame()


func key(code: Key, unicode := 0) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.unicode = unicode
		event.pressed = pressed
		Input.parse_input_event(event)
		await frame()


func type_text(text: String) -> void:
	for ch in text:
		var code: int = ch.to_upper().unicode_at(0)
		await key(code as Key, ch.unicode_at(0))
		await hold(TYPE_EVERY - 2.0 / FPS)


# ── The pointer ───────────────────────────────────────────────────────────────

func _make_pointer() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 1000
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child(layer)
	pointer = Control.new()
	pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pointer.scale = Vector2.ONE * 1.35
	pointer.position = pointer_at
	pointer.modulate.a = 0.0
	pointer_idle = IDLE_FADE + 1.0
	layer.add_child(pointer)
	# The standard arrow, white with a dark edge.
	var arrow := PackedVector2Array([Vector2(0, 0), Vector2(0, 17), Vector2(4, 13),
		Vector2(7, 19.5), Vector2(9.5, 18.5), Vector2(6.5, 12), Vector2(12, 12)])
	pointer.draw.connect(func():
		pointer.draw_colored_polygon(arrow, Color.WHITE)
		var edge := arrow.duplicate()
		edge.append(arrow[0])
		pointer.draw_polyline(edge, Color(0.04, 0.03, 0.08), 1.3, true))


func _motion(at: Vector2, delta: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = at
	event.global_position = at
	event.relative = delta
	Input.parse_input_event(event)


func move_pointer(to: Vector2, seconds := -1.0) -> void:
	var from := pointer_at
	if seconds < 0.0:
		seconds = clampf(from.distance_to(to) / 1500.0, 0.28, 0.75)
	var steps: int = maxi(1, int(round(seconds * FPS)))
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var eased := t * t * (3.0 - 2.0 * t)
		var at := from.lerp(to, eased)
		_motion(at, at - pointer_at)
		pointer_at = at
		pointer.position = at
		pointer_idle = 0.0
		await frame()


func click_at(at: Vector2) -> void:
	await move_pointer(at)
	await hold(0.18)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = at
		event.global_position = at
		event.pressed = pressed
		Input.parse_input_event(event)
		pointer_idle = 0.0
		for i in range(4 if pressed else 1):
			await frame()


func centre(control: Control) -> Vector2:
	return control.get_global_transform_with_canvas() * (control.size * 0.5)


func click(control: Control, hover := 0.3) -> void:
	# Arrive a little off, then drift onto it: a hand is never quite still,
	# and the drift lets the control see the pointer even if it appeared
	# underneath one that had stopped.
	var at := centre(control)
	await move_pointer(at + Vector2(-14, 5))
	await move_pointer(at, maxf(hover, 0.12))
	await click_at(at)


# ── Walking ───────────────────────────────────────────────────────────────────

func player() -> Node2D:
	return get_first_node_in_group("player") as Node2D


func press(action: String, strength: float) -> void:
	if strength > 0.05:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func release_walk() -> void:
	for a in ["walk_left", "walk_right", "walk_up", "walk_down"]:
		Input.action_release(a)


func steer_towards(target: Vector2) -> float:
	var p := player()
	if p == null:
		return INF
	var to := target - p.global_position
	if to.length() <= ARRIVE:
		release_walk()
		return to.length()
	var d := to.normalized()
	press("walk_right", maxf(d.x, 0.0))
	press("walk_left", maxf(-d.x, 0.0))
	press("walk_down", maxf(d.y, 0.0))
	press("walk_up", maxf(-d.y, 0.0))
	return to.length()


# Walks there with the walk keys, stopping for anything the game puts up.
func walk_to(target: Vector2, timeout := 14.0, arrive := ARRIVE) -> void:
	var waited := 0.0
	var last := Vector2.INF
	var stuck := 0.0
	var began := frames
	# The timeout counts walking only; a minute of reading is the outer limit.
	while waited < timeout and frames - began < (timeout + 60.0) * FPS:
		if await serve():
			continue
		var p := player()
		if p != null and p.global_position.distance_to(target) <= arrive:
			break
		# Nobody keeps walking into a counter.
		if p != null and last != Vector2.INF and p.global_position.distance_to(last) < 0.3:
			stuck += 1.0 / FPS
			if stuck > 0.35:
				break
		else:
			stuck = 0.0
		last = p.global_position if p != null else Vector2.INF
		steer_towards(target)
		await frame()
		waited += 1.0 / FPS
	release_walk()


# Walks to the first of these spots where the thing says he is in reach,
# the way a person shuffles along a counter until the prompt appears.
func reach(thing: Node, spots: Array) -> void:
	for spot: Vector2 in spots:
		await walk_to(spot, 8.0)
		await hold(0.2)
		if debug:
			print("    %s at %s, from %s: nearby=%s" % [thing.name, thing.global_position,
				player().global_position, thing.player_nearby])
		if thing.player_nearby:
			return


# Where a person would stand to talk to somebody: in front, then either side.
func around(thing: Node2D) -> Array:
	var spots: Array = []
	for offset in [Vector2(0, 34), Vector2(-34, 24), Vector2(34, 24), Vector2(0, 46), Vector2(-46, 8), Vector2(46, 8)]:
		spots.append(thing.global_position + offset)
	return spots


# ── Whatever is on screen ─────────────────────────────────────────────────────

# Handles one thing the game is waiting on, as a player would, and says
# whether there was one.
func serve() -> bool:
	var discovery := get_first_node_in_group("word_discovery")
	if discovery != null and discovery._open:
		release_walk()
		await answer_discovery(discovery)
		return true
	var dialog := get_first_node_in_group("dialogue_box")
	if dialog != null and dialog.visible:
		release_walk()
		await answer_dialogue(dialog)
		return true
	var pickup := get_first_node_in_group("pickup")
	if pickup != null and pickup._open:
		release_walk()
		await hold(3.2)
		if pickup._open:
			await tap("interact")
		await hold(0.4)
		return true
	var thought := get_first_node_in_group("thought_box")
	if thought != null and thought.visible:
		release_walk()
		await hold(reading(thought._text_label.get_parsed_text(), 2.6, 7.5))
		if thought.visible:
			await tap("interact")
		await hold(0.5)
		return true
	var choice := get_first_node_in_group("choice_panel")
	if choice != null and choice.get("_open") == true:
		release_walk()
		await hold(2.5)
		var buttons := choice.find_children("*", "Button", true, false)
		for b: Button in buttons:
			if b.is_visible_in_tree() and not b.disabled:
				await click(b)
				break
		await hold(0.5)
		return true
	return false


func answer_dialogue(dialog: Node) -> void:
	# Let the line be said and the words settle before reaching for a reply.
	var waited := 0.0
	while dialog.visible and (dialog._revealing or dialog._resp_box.get_child_count() == 0) and waited < 12.0:
		await frame()
		waited += 1.0 / FPS
	if not dialog.visible:
		return
	await hold(0.6)
	# Debug runs are not paced by the movie writer, so audio lags far behind.
	var voice: AudioStreamPlayer = root.get_node("AudioManager")._voice
	waited = 0.0
	while voice.playing and waited < 15.0 and not debug:
		await frame()
		waited += 1.0 / FPS
	var entry: Dictionary = dialog._entries[dialog._index] if dialog._index < dialog._entries.size() else {}
	await hold(reading(String(entry.get("stage", "")), 1.4, 4.2))
	var row := pick_row(dialog)
	if row == null:
		return
	if debug:
		print("    reply: ", _reply_of(row).get("text", _reply_of(row).get("gesture", "?")))
	await click(row, 0.45)
	await hold(0.5)


func pick_row(dialog: Node) -> Button:
	var rows: Array = []
	for wrap: Node in dialog._resp_box.get_children():
		for child in wrap.get_children():
			if child is Button and child.is_visible_in_tree():
				rows.append(child)
	if rows.is_empty():
		return null
	for want: String in REPLIES.get("opening" if segment == "kiez" else segment, []):
		for row: Button in rows:
			var reply: Dictionary = _reply_of(row)
			if want.begins_with("action:"):
				if String(reply.get("action", "")) == want.trim_prefix("action:"):
					return row
				continue
			for field in ["text", "gesture", "words", "say"]:
				var value: Variant = reply.get(field, "")
				if value is String and value.contains(want):
					return row
	return rows[0]


func _reply_of(row: Button) -> Dictionary:
	for c: Dictionary in row.pressed.get_connections():
		var bound: Array = (c["callable"] as Callable).get_bound_arguments()
		if not bound.is_empty() and bound[0] is Dictionary:
			return bound[0]
	return {}


func answer_discovery(panel: Node) -> void:
	if panel._words.is_empty():
		panel.close()
		return
	var word := String(panel._words[0].word).to_lower()
	await hold(reading(panel._context.text, 2.2, 5.0))
	if GUESSES.has(word):
		await click(panel._guess, 0.25)
		await hold(0.5)
		await type_text(String(GUESSES[word]))
		await hold(0.9)
		await click(panel._primary, 0.35)
	else:
		await click(panel._skip, 0.35)
	await hold(reading(panel._meaning.text, 3.0, 5.5))
	await click(panel._primary, 0.3)
	await hold(0.4)


# Plays a story scene to its end: serving the conversation, and walking and
# picking things up whenever the scene hands him his feet back.
func play_story(is_running: Callable, director_of: Callable, limit := 300.0) -> void:
	var began := frames
	while is_running.call() and frames - began < limit * FPS:
		if await serve():
			continue
		var director: Node = director_of.call()
		if director != null and not director._frozen:
			await carry_step(director)
		else:
			release_walk()
			await frame()
	release_walk()


func carry_step(director: Node) -> void:
	var target := Vector2.INF
	var prop: Node2D = null
	if gs.carrying.is_empty():
		# The nearest one; a crate behind another is reached after it.
		var best := INF
		for p in director.props.values():
			if not (is_instance_valid(p) and p.carryable and p.visible):
				continue
			var d: float = p.global_position.distance_to(player().global_position)
			if p.near_player():
				d = -1.0
			if d < best:
				best = d
				prop = p
				target = p.global_position
	else:
		for node in director.host.get_children():
			if node.get_script() == load("res://scenes/story/StoryZone.gd"):
				target = node.global_position
				break
	if target == Vector2.INF:
		release_walk()
		await frame()
		return
	steer_towards(target)
	if prop != null and prop.near_player():
		release_walk()
		await hold(0.25)
		await tap("interact")
		await hold(0.35)
		return
	await frame()


# ── Scenes ────────────────────────────────────────────────────────────────────

func load_scene(path: String, local_hour := -1.0) -> Node:
	if current_scene != null:
		current_scene.queue_free()
		await frame()
	var world: Node = load(path).instantiate()
	root.add_child(world)
	current_scene = world
	await frame()
	if local_hour >= 0.0:
		set_hour(local_hour)
	for i in range(6):
		await frame()
	return world


func set_hour(local_hour: float) -> void:
	var clock: Script = load("res://autoload/JourneyClock.gd")
	var offset: float = clock.offset(gs.city)
	var base := floorf((gs.clock_minutes + offset) / 1440.0) * 1440.0
	gs.clock_minutes = base + local_hour * 60.0 - offset


func until(condition: Callable, limit: float) -> void:
	var waited := 0.0
	while not condition.call() and waited < limit:
		await frame()
		waited += 1.0 / FPS


func wait_for_scene(path_end: String, limit := 60.0) -> void:
	var waited := 0.0
	while waited < limit:
		if current_scene != null and String(current_scene.scene_file_path).ends_with(path_end):
			break
		await frame()
		waited += 1.0 / FPS
	await hold(0.2)


# Serves the screen until nothing has been waiting for a while.
func settle_ui(quiet: float) -> void:
	var still := 0.0
	while still < quiet:
		if await serve():
			still = 0.0
			continue
		await frame()
		still += 1.0 / FPS


func dressed() -> Dictionary:
	return APPEARANCE.sanitize({"skin": 3, "eyes": 2, "antenna": 2, "coat": 4, "outfit": 1})


# Title screen, the alien creator and the opening, then the first minute in
# the field: a bag of coins in the grass and a man selling bread.
func opening() -> void:
	var title: Node = load("res://scenes/title/TitleScreen.tscn").instantiate()
	root.add_child(title)
	current_scene = title
	await hold(4.2)
	await click(title.get_node("Content/NewJourneyButton"), 0.6)
	await wait_for_scene("CharacterCreator.tscn")
	var creator: Node = current_scene
	await hold(1.6)
	await choose(creator, "skin", 3)
	await choose(creator, "eyes", 2)
	await choose(creator, "antenna", 2)
	await hold(0.5)
	await click(creator._tabs[1], 0.3)
	await hold(0.6)
	await choose(creator, "coat", 4)
	await choose(creator, "outfit", 1)
	await hold(0.4)
	for i in range(2):
		await click(_button_with(creator, "→"), 0.15)
		await hold(0.35)
	await hold(0.8)
	await click(creator._begin, 0.5)
	await wait_for_scene("IntroCutscene.tscn")
	# The opening plays in full; nobody skips it the first time.
	await wait_for_scene("Kiez.tscn", 40.0)
	await first_trade()


# The first minute in the field. "kiez" starts here directly, for iterating.
func first_trade() -> void:
	if current_scene == null or not String(current_scene.scene_file_path).ends_with("Kiez.tscn"):
		gs.reset()
		gs.alien_appearance = dressed()
		await load_scene("res://scenes/world/Kiez.tscn")
	await hold(1.2)
	await settle_ui(2.0)
	await walk_to(Vector2(507, 600), 8.0, 12.0)
	await settle_ui(1.0)
	await hold(0.6)
	await walk_to(Vector2(737, 552), 12.0)
	await hold(0.5)
	await tap("interact")
	await hold(0.3)
	await settle_ui(1.5)
	await hold(1.5)


func choose(creator: Node, key_name: String, index: int) -> void:
	var options: Array = creator._choices.get(key_name, [])
	if index < options.size():
		await click(options[index], 0.25)
		await hold(0.45)


func _button_with(node: Node, caption: String) -> Button:
	for b: Button in node.find_children("*", "Button", true, false):
		if b.text == caption:
			return b
	return null


# Kerstin's crates, a wrong first reading, Pfand guessed and then shown,
# and the notebook afterwards.
func berlin() -> void:
	gs.reset()
	gs.alien_appearance = dressed()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var story: Script = load("res://scenes/story/berlin/BerlinStory.gd")
	await load_scene(story.MITTE, 7.5)
	var stage: Node = get_first_node_in_group("berlin_stage")
	player().global_position = Vector2(470, 500)
	await hold(1.4)
	await walk_to(Vector2(256, 482), 10.0, 6.0)
	await hold(0.4)
	await tap("interact")
	await until(func(): return stage.busy(), 2.0)
	await play_story(func(): return stage.busy(),
		func(): return stage.get_child(stage.get_child_count() - 1) if stage.get_child_count() > 0 else null)
	await settle_ui(1.5)
	await hold(1.0)
	await tap("journal")
	await hold(6.5)
	await tap("journal")
	await hold(1.0)


# The airport desk, the route map and the flight to London.
func flight() -> void:
	gs.reset()
	gs.alien_appearance = dressed()
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	await load_scene("res://scenes/world/Airport.tscn", 11.0)
	await hold(1.2)
	await reach(current_scene.get_node("CheckIn"),
		[Vector2(800, 410), Vector2(780, 400), Vector2(880, 400), Vector2(840, 404)])
	await hold(0.4)
	await tap("interact")
	await hold(0.6)
	var map := get_first_node_in_group("world_map")
	var waited := 0.0
	while map != null and not map._open and waited < 4.0:
		await frame()
		waited += 1.0 / FPS
	if map == null or not map._open:
		push_error("research film: the check-in desk did not open the route map")
		return
	await hold(2.0)
	# Hover a couple of the cities first, as anybody choosing would.
	for city in ["istanbul", "paris", "london"]:
		await move_pointer(marker(map, city), 0.6)
		await hold(1.3)
	await click_at(pointer_at)
	await wait_for_scene("LondonAirport.tscn", 30.0)
	await hold(1.0)
	await settle_ui(2.5)
	await hold(1.0)


func marker(map: Node, city: String) -> Vector2:
	var places: Dictionary = map.get_script().get_script_constant_map()["CITY_POS"]
	return map._canvas.get_global_transform_with_canvas() * map._project(places[city])


# A walk down a street in six more cities, the same alien in each: scene,
# local hour, where he starts, and how long he walks to the right.
const STREETS := [
	["istanbul", "res://scenes/world/IstanbulHan.tscn", 17.5, 260.0, 7.0],
	["paris", "res://scenes/world/ParisMarais.tscn", 8.5, 260.0, 7.0],
	["moscow", "res://scenes/world/MoscowBasmanny.tscn", 12.0, 260.0, 7.0],
	["mumbai", "res://scenes/world/MumbaiBhuleshwar.tscn", 10.0, 260.0, 7.0],
	["tokyo", "res://scenes/world/TokyoUeno.tscn", 13.5, 300.0, 7.0],
	["mexico", "res://scenes/world/MexicoCoyoacan.tscn", 18.5, 260.0, 7.0],
]


func cities() -> void:
	for street: Array in STREETS:
		gs.reset()
		gs.alien_appearance = dressed()
		gs.quests["find_bed"] = {"completed": true, "steps": []}
		gs.city = String(street[0])
		await load_scene(String(street[1]), float(street[2]))
		await until(func(): return player() != null, 3.0)
		var p := player()
		if p == null:
			push_error("research film: no player in " + String(street[1]))
			continue
		p.global_position.x = float(street[3])
		print("CITY %s starts at frame %d" % [street[0], frames])
		await hold(0.6)
		await settle_ui(0.4)
		var start_x := p.global_position.x
		await walk_to(Vector2(start_x + 2000.0, p.global_position.y), float(street[4]))
		await hold(0.6)


# Val's request on the terrace: every word readable, the meaning still not.
func london() -> void:
	gs.reset()
	gs.alien_appearance = dressed()
	gs.city = "london"
	gs.world_flags["london_arrived"] = true
	gs.world_flags["visited_berlin"] = true
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	# The neighbour who comes over about the bins is another take; met already.
	gs.world_flags["enc_london_bins"] = true
	await load_scene("res://scenes/world/LondonTerrace.tscn", 10.5)
	player().global_position = Vector2(640, 600)
	await hold(1.4)
	var journey := root.get_node("Journey")
	var nadia := current_scene.get_node("KeyNadia")
	await reach(nadia, around(nadia))
	await hold(0.4)
	await tap("interact")
	await until(func(): return journey.busy, 2.0)
	await play_story(func(): return journey.busy,
		func(): return get_first_node_in_group("story_director"))
	await settle_ui(1.5)
	await hold(1.0)
