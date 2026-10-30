extends "res://tools/title_review.gd"

var gs: Node
var sm: Node
var clock: Script


func _run() -> void:
	out = "res://.build/daynight-review"
	DirAccess.make_dir_recursive_absolute(out)
	gs = root.get_node("GameState")
	sm = root.get_node("SaveManager")
	sm.use_test_storage("daynight-review")
	gs.set_process(false)
	check(gs.has_method("clock_text"), "one persistent local clock exists")
	if not gs.has_method("clock_text"):
		_finish()
		return
	gs.reset()
	check(gs.clock_text() == "05:30", "a new journey starts before sunrise")
	clock = load("res://autoload/JourneyClock.gd")
	if OS.get_cmdline_user_args().has("--movie"):
		await _movie()
		_finish()
		return
	if OS.get_cmdline_user_args().has("--details"):
		await _details_checks()
		current_scene.queue_free()
		current_scene = null
		await frames()
		_finish()
		return
	_calendar_checks()
	await _world_checks()
	await _rest_checks()
	await _travel_checks()
	await _save_checks()
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	await frames()
	_finish()


func _calendar_checks() -> void:
	check(clock.text_at(0, "berlin") == "00:00", "midnight zero padding")
	check(clock.text_at(1439.9, "berlin") == "23:59", "last minute of day")
	check(clock.text_at(1440, "berlin") == "00:00", "midnight wraps")
	check(clock.text_at(480, "mumbai") == "12:30", "half-hour local time offset")
	check(clock.text_at(0, "mexico") == "17:00", "westward offset wraps before zero")
	check(clock.next_hour(480, "berlin", 8) == 1920, "sleep at wake time means next morning")
	check(clock.next_hour(479.5, "berlin", 8) == 480, "sleep just before wake time does not skip a day")
	check(clock.next_hour(1200, "berlin", 18) == 2520, "evening rest after sunset rolls forward")
	for entry: Array in [[359,"night"], [360,"morning"], [720,"afternoon"], [1080,"evening"], [1320,"night"]]:
		check(clock.day_part(entry[0], "berlin") == entry[1], "greeting boundary " + str(entry[0]))
	for minute in range(0, 1440, 15):
		var tint: Color = clock.tint(minute, "berlin")
		var next: Color = clock.tint(minute + 0.1, "berlin")
		check(absf(tint.r-next.r) < 0.002 and absf(tint.b-next.b) < 0.002, "continuous light at " + str(minute))
		check(clock.tint(minute, "berlin", true).r > 0.85, "interior readability at " + str(minute))
	for from: String in gs.CITIES:
		check(clock.CITIES.has(from), "local clock supports " + from)
		gs.city = from
		gs.clock_minutes = clock.START
		gs.time_of_day = "dawn"
		check(gs.clock_minutes >= 0 and gs.clock_text() == "05:30", "legacy dawn remains saveable in " + from)
		for to: String in gs.CITIES:
			var duration: float = clock.flight_minutes(from, to)
			check(duration == 0 if from == to else duration >= 90 and duration <= 1620, "bounded flight " + from + "/" + to)
	for value: Variant in [null, "bad", {}, [], -1, INF, NAN, 1e20]:
		check(clock.text_at(clock.restore(value, "morning", "tokyo"), "tokyo") == "08:00", "invalid clock falls back safely: " + str(value))
	gs.clock_minutes = 10000
	gs.reset()
	check(gs.clock_minutes == clock.START, "new journey resets absolute day, not only hour")
	var before: float = gs.clock_minutes
	gs.advance_clock(NAN)
	gs.advance_clock(-10)
	check(gs.clock_minutes == before, "invalid time advance ignored")
	var berlin: Script = load("res://scenes/story/berlin/BerlinStory.gd")
	gs.clock_minutes = 900
	var s: Dictionary = berlin.state()
	s.done["1"] = true
	s.night_at["1"] = 0
	s.morning_at["1"] = clock.next_hour(gs.clock_minutes, "berlin", 8)
	check(berlin.due_kerstin() == "wait_morgen", "same afternoon does not unlock tomorrow")
	gs.advance_clock(500)
	check(berlin.due_kerstin() == "wait_morgen", "same night does not unlock tomorrow")
	gs.advance_clock(520)
	check(berlin.due_kerstin() == "2", "natural next morning opens appointment without bed")
	gs.advance_clock(5000)
	check(berlin.due_kerstin() == "2", "appointments never expire")
	check(not gs.rested_here() and not gs.world_flags.has("nights"), "natural days do not invent hotel stays")


func _enter(path: String) -> void:
	paused = false
	gs.world_flags["intro_shown"] = true
	for city: String in gs.CITIES:
		gs.world_flags["arrived_" + city] = true
		gs.world_flags[city + "_arrived"] = true
	change_scene_to_file(path)
	await frames(12)
	var thought := get_first_node_in_group("thought_box")
	if thought != null and thought.visible: thought._close()
	await frames(3)


func _world_checks() -> void:
	gs.reset()
	await _enter("res://scenes/world/Airport.tscn")
	check(gs.clock_can_run(), "clock runs during free exploration")
	var before: float = gs.clock_minutes
	for i in range(2400): gs.advance_exploration(1.0, true)
	check(is_equal_approx(gs.clock_minutes - before, 1440), "one day in forty active minutes")
	check(gs.clock_text() == "05:30", "fractional ticks do not lose a displayed minute")
	before = gs.clock_minutes
	gs.advance_exploration(30.0, false)
	check(gs.clock_minutes == before, "unfocused window never advances clock")
	gs.advance_exploration(600.0, true)
	check(is_equal_approx(gs.clock_minutes - before, 0.6), "long frame never skips hours")
	before = gs.clock_minutes
	var journal := get_first_node_in_group("journal")
	journal.open_from_hud()
	gs.advance_exploration(1, true)
	check(gs.clock_minutes == before, "reading journal freezes time")
	journal._close()
	var thought := get_first_node_in_group("thought_box")
	thought.show_thought("Clock regression test")
	gs.advance_exploration(1, true)
	check(gs.clock_minutes == before, "reading thoughts freezes time")
	thought._close()
	root.get_node("Journey").busy = true
	check(not gs.clock_can_run(), "journey sequences freeze time")
	root.get_node("Journey").busy = false
	var director: Node = load("res://scenes/story/StoryDirector.gd").new()
	current_scene.add_child(director)
	director._running = true
	check(not gs.clock_can_run(), "staged dialogue freezes even without scene-tree pause")
	director._running = false
	director.queue_free()
	await frames()
	change_scene_to_file("res://scenes/title/TitleScreen.tscn")
	await frames()
	check(not gs.clock_can_run(), "title never advances journey time")
	for city: String in ["berlin", "london", "istanbul", "paris", "moscow", "mumbai", "tokyo", "mexico"]:
		gs.reset()
		gs.city = city
		await _enter(gs.CITY_ENTRIES[city])
		var light := current_scene.get_node_or_null("DayNightLighting")
		check(light != null and not light.indoors, "outdoor shared lighting: " + city)
		if light == null: continue
		for hour: int in [12, 23]:
			gs.clock_minutes = 1440 + hour * 60 - clock.offset(city)
			await frames()
			check(light.color.is_equal_approx(clock.tint(gs.clock_minutes, city)), "live shared tint: " + city + str(hour))
			var log := get_first_node_in_group("quest_log")
			log._banner_t = -1
			log._banner.hide()
			log._tracker_hold = 0
			await capture(city + "-" + str(hour))
	gs.reset()
	await _enter("res://scenes/world/Kiez.tscn")
	for hour: int in [5, 6, 12, 18, 23]:
		gs.clock_minutes = hour * 60
		await frames()
		await capture("kiez-" + str(hour))
	for size: Vector2i in [Vector2i(1920,1080), Vector2i(1280,720), Vector2i(1024,768)]:
		root.content_scale_size = size
		if DisplayServer.get_name() != "headless": root.size = size
		gs.world_flags.has_map = true
		for currency: String in gs.wallet: gs.wallet[currency] = 987654
		await frames()
		var hud := current_scene.get_node("UILayer/HudBar")
		var clock_box: Rect2 = hud._clock_chip.get_global_rect()
		check(not clock_box.intersects(hud._bar.get_global_rect()), "clock and wallet do not overlap: " + str(size))
		check(not clock_box.intersects(get_first_node_in_group("quest_tracker").get_global_rect()), "clock clears intentions: " + str(size))
		check(clock_box.end.x < size.x and clock_box.end.y < size.y, "clock fits viewport: " + str(size))
		await capture("hud-" + str(size.x))
	root.content_scale_size = Vector2i(1280,720)
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280,720)
	for location: Array in [["HotelRoom",true], ["activities/ActivityBerlinSpati",true]]:
		var path: String = "res://scenes/world/" + location[0] + ".tscn"
		check(ResourceLoader.exists(path), "review scene exists: " + path)
		await _enter(path)
		gs.clock_minutes = 1380
		await frames()
		check(current_scene.get_node("DayNightLighting").indoors == location[1], "correct interior/exterior: " + location[0])
		await capture(location[0].replace("/", "-") + "-night")


func _rest_checks() -> void:
	gs.reset()
	gs.world_flags.room_booked = true
	gs.world_flags["room_booked_berlin"] = true
	await _enter("res://scenes/world/HotelRoom.tscn")
	var bed: Node = null
	for child in current_scene.get_children():
		if child.has_method("_choose_rest"): bed = child
	check(bed != null, "real hotel bed has rest choices")
	if bed == null: return
	gs.clock_minutes = 840
	bed._choose_rest()
	await frames()
	var choice := get_first_node_in_group("choice_panel")
	check(choice._open and paused, "bed offers wake-time choice")
	await capture("rest-choices")
	choice._close("")
	check(gs.clock_minutes == 840 and not bed._resting and not paused, "cancel rest has no time or sleep side effects")
	bed._rest(18)
	await create_timer(7.6).timeout
	check(gs.clock_text() == "18:00" and not paused, "nap wakes at evening and releases input")
	check(not gs.world_flags.has("nights"), "afternoon nap is not a full night")
	bed._rest()
	await create_timer(7.6).timeout
	check(gs.clock_text() == "08:00" and gs.rested_here() and not paused, "sleep wakes at morning and retains resting progress")
	check(int(gs.world_flags.get("nights",0)) == 1, "one sleep counted once")
	check(sm.load_game(-1) and gs.clock_text() == "08:00", "waking is checkpointed")


func _travel_checks() -> void:
	gs.reset()
	await _enter(gs.ARRIVALS.berlin)
	gs.clock_minutes = 1200
	var services := root.get_node("Services")
	var arrival: float = gs.clock_minutes + clock.flight_minutes("berlin", "tokyo")
	check(String(services._route_row("tokyo").note).contains(clock.text_at(arrival,"tokyo")), "route shows actual local arrival time")
	services._airport_desk()
	await frames()
	get_first_node_in_group("world_map")._close("")
	check(gs.clock_minutes == 1200, "cancel flight spends no time")
	services._board_flight("tokyo", gs.flight_fare())
	await frames()
	var film := get_first_node_in_group("flight_cutscene")
	check(film != null and not gs.clock_can_run(), "flight holds exploration clock")
	if film == null: return
	film.elapsed = 3.6
	film.set_process(false)
	film._present()
	await capture("night-flight")
	film._request_finish()
	await create_timer(1.4).timeout
	await frames()
	check(gs.city == "tokyo" and gs.clock_minutes == arrival, "skip advances exactly one full journey duration")
	check(current_scene.scene_file_path == gs.ARRIVALS.tokyo, "night flight still lands inside airport")
	check(sm.load_game(-1) and gs.clock_minutes == arrival, "arrival checkpoint retains local clock")
	await capture("tokyo-arrival")
	# Direct airport transfers consume time once; rail transfers are tested by
	# the airport suite and share _ubahn_travel's selected-route commit.
	gs.city = "london"
	gs.world_flags.airport_transfer = "london"
	services.first_street_arrival()
	check(gs.clock_minutes == arrival + 30, "included ground transfer advances half an hour")
	services.first_street_arrival()
	check(gs.clock_minutes == arrival + 30, "street re-entry does not charge travel time twice")
	gs.reset()
	gs.world_flags.airport_transfer = "berlin"
	await _enter(services.AIRPORT_RAIL.berlin.hall)
	var before: float = gs.clock_minutes
	services._ubahn_travel()
	await frames()
	var cp := get_first_node_in_group("choice_panel")
	cp._close("")
	check(gs.clock_minutes == before, "cancel included rail transfer spends no time")
	services._ubahn_travel()
	await frames()
	cp._close(services.AIRPORT_RAIL.berlin.stop)
	await create_timer(0.9).timeout
	await frames()
	check(gs.clock_minutes == before + 30, "included rail transfer advances exactly once")


func _save_checks() -> void:
	await _enter("res://scenes/world/Airport.tscn")
	gs.clock_minutes = 4321.5
	gs.money = 77
	check(sm.save_game(0), "clock save written")
	var data: Dictionary = sm._read_json(sm._slot_path(0))
	gs.clock_minutes = 500
	check(sm.load_game(0) and gs.clock_minutes == 4321.5, "precise time survives reload without offline advance")
	for invalid: Variant in [null, "broken", {}, -7, 1e20]:
		data["clock_minutes"] = invalid
		data["time_of_day"] = "morning"
		sm._write_json(sm._slot_path(0), data, "test")
		check(sm.load_game(0) and gs.money == 77 and gs.clock_text() == "08:00", "damaged optional clock never loses journey")
	data.erase("clock_minutes")
	data["time_of_day"] = "dawn"
	sm._write_json(sm._slot_path(0), data, "test")
	check(sm.load_game(0) and gs.money == 77 and gs.clock_text() == "05:30", "legacy dawn save migrates")
	gs.time_of_day = "morning"
	check(gs.clock_text() == "08:00" and gs.day_part() == "morning", "legacy tools still select morning")


func _details_checks() -> void:
	root.content_scale_size = Vector2i(1280,720)
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280,720)
	var details: Script = load("res://scenes/world/DaylightDetails.gd")
	for id: String in details.WINDOWS:
		gs.reset()
		await _enter("res://scenes/world/" + id + ".tscn")
		gs.clock_minutes = 1440 + 1380 - clock.offset(gs.city)
		await frames()
		check(current_scene.get_node("DayNightLighting").indoors, "window view is in a lit interior: " + id)
		await capture(id + "-window-night")
	gs.reset()
	await _enter("res://scenes/world/Mitte.tscn")
	gs.clock_minutes = 1380
	await frames()
	await capture("berlin-foliage-night")
	var friends := current_scene.get_node("WalkingFriends")
	var words: Array = friends._dialogue_now()[0].words
	check(not words.any(func(word): return word.word == "morgen"), "walking friends do not say good morning at night")
	gs.clock_minutes = 480
	check(friends._dialogue_now()[0].words.any(func(word): return word.word == "morgen"), "morning greeting retained in morning")
	for minute: int in [480, 900, 1140, 1380]:
		gs.clock_minutes = minute
		var entry: Dictionary = friends._dialogue_now()[0]
		var spoken := PackedStringArray()
		for word: Dictionary in entry.words: spoken.append(String(word.text))
		check(root.get_node("AudioManager").has_voice(entry.voice, " ".join(spoken)), "matching recorded greeting at " + str(minute))
		check(root.get_node("AudioManager").voice_seconds(entry.voice, " ".join(spoken)) > 0, "greeting decodes at " + str(minute))
	var places: Dictionary = load("res://scenes/world/ActivityPlaces.gd").catalog().places
	for id: String in places:
		if places[id].get("ambience", "street") == "interior": continue
		await _enter("res://scenes/world/activities/" + id + ".tscn")
		gs.clock_minutes = 1440 + 1380 - clock.offset(gs.city)
		await frames()
		check(not current_scene.get_node("DayNightLighting").indoors, "outdoor activity follows night lighting: " + id)
		await capture("outdoor-activity-night")
		break


func _movie() -> void:
	gs.reset()
	root.content_scale_size = Vector2i(1280,720)
	root.size = Vector2i(1280,720)
	await _enter("res://scenes/world/Kiez.tscn")
	var log := get_first_node_in_group("quest_log")
	log._banner_t = -1
	log._banner.hide()
	for tick in range(480):
		gs.clock_minutes = 300.0 + float(tick) * 3.0
		await process_frame
	check(current_scene.scene_file_path.ends_with("Kiez.tscn"), "accelerated lighting preview stays in the real world")
	current_scene.queue_free()
	current_scene = null
	await frames()
