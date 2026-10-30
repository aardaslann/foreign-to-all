extends Node

signal operation_failed(message: String)
const BUILD := preload("res://autoload/BuildInfo.gd")
var last_error := ""

const SAVE_DIR := "user://saves/"
const SETTINGS_PATH := "user://settings.json"
const MAX_SLOTS := 5
var storage_dir: String = SAVE_DIR
var settings_path: String = SETTINGS_PATH


# Test tools select an isolated, unique directory before touching game state.
# The caller supplies a label, never a path that could name a player's saves.
func use_test_storage(label: String) -> String:
	storage_dir = "user://test-runs/%s-%d-%d/" % [label.validate_filename(),
		Time.get_ticks_usec(), OS.get_process_id()]
	DirAccess.make_dir_recursive_absolute(storage_dir)
	settings_path = storage_dir.path_join("settings.json")
	return storage_dir

var settings: Dictionary = {
	"key_binds": {},
	"quest_arrow": false,
	"beta_session_notes": false,
	"master_volume":          1.0,
	"music_volume":           0.8,
	"sfx_volume":             0.8,
	"speech_volume":          0.6,
	# 0 windowed · 1 fullscreen · 2 borderless. `fullscreen` is kept so an
	# older settings file still loads and still means something.
	"window_mode":            0,
	"fullscreen":             false,
	"resolution":             2,
	"vsync":                  true,
	"max_fps":                1,
	"reduce_motion":          false,
	"text_size":              1,
	"extra_context_hints":    false,
	"simplified_glyph_set":   false,
	"highlight_partial_words": false,
	# Whether a pause is allowed to answer for him. On by default, because in
	# two cities waiting is the best answer available and switching it off
	# takes that away - but a timed choice is an accessibility question before
	# it is a design one, and it has to be possible to switch off.
	"timed_choices":          false,
}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	load_settings()


# ── Settings ──────────────────────────────────────────────────────────────────

func load_settings() -> void:
	if FileAccess.file_exists(settings_path):
		var data: Variant = _read_json(settings_path)
		if data is Dictionary:
			for key in data:
				if key == "key_binds":
					settings[key] = _valid_bindings(data[key])
				elif settings.has(key) and typeof(settings[key]) == typeof(data[key]):
					settings[key] = data[key]
				elif settings.has(key) and settings[key] is int and _number(data[key]):
					settings[key] = int(data[key])
	apply_settings()


func save_settings() -> bool:
	return _write_json(settings_path, settings, "settings")


func _valid_bindings(value: Variant) -> Dictionary:
	var clean := {}
	if not value is Dictionary: return clean
	for action: String in preload("res://autoload/Controls.gd").ACTIONS:
		if not value.get(action) is Array: continue
		var keys: Array = []
		for key: Variant in value[action]:
			if _number(key) and key > 0 and key <= 0x7fffffff and not keys.has(int(key)):
				keys.append(int(key))
		# An empty array is intentional when another action takes its last key.
		if value[action].is_empty() or not keys.is_empty(): clean[action] = keys
	return clean


func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))


func _fail(message: String) -> bool:
	last_error = message
	operation_failed.emit(message)
	return false


func _read_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK: return null
	return json.data


func _write_json(path: String, data: Dictionary, subject: String) -> bool:
	last_error = ""
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return _fail("Could not save %s. Check available disk space and folder permissions. Your previous file has been kept." % subject)
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK:
		return _fail("Could not finish writing %s. Your previous file has been kept." % subject)
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		return _fail("Could not replace %s. Your previous file has been kept." % subject)
	return true


func apply_settings() -> void:
	_apply_bus("Master", settings.get("master_volume", 1.0))
	_apply_bus("Music",  settings.get("music_volume",  0.8))
	_apply_bus("SFX",    settings.get("sfx_volume",    0.8))
	_apply_bus("Speech", settings.get("speech_volume", 0.6))

	# Engine settings first, window settings last.
	#
	# Anything touching DisplayServer is an error when there is no window -
	# a headless tool, a render, a server build - and one failing call aborts
	# the rest of the function, so the frame limit behind it silently stopped
	# being applied at all.
	# A limit of 0 means "as fast as it will go", which is what Godot wants.
	Engine.max_fps = int(FPS_CHOICES[clampi(int(settings.get("max_fps", 1)),
		0, FPS_CHOICES.size() - 1)])

	if DisplayServer.get_name() == "headless":
		return
	var vsync := DisplayServer.VSYNC_ENABLED if settings.get("vsync", true) \
		else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync)
	_apply_window()


# The sizes worth offering, and only windowed: a fullscreen window takes
# the desktop resolution, and forcing a mode switch is how you lose
# somebody's other windows.
const RESOLUTIONS := [
	Vector2i(1280, 720), Vector2i(1600, 900),
	Vector2i(1920, 1080), Vector2i(2560, 1440),
]
const FPS_CHOICES := [30, 60, 120, 144, 0]


func _apply_window() -> void:
	var mode: int = int(settings.get("window_mode", 0))
	# A settings file written before this existed has only the boolean.
	if mode == 0 and bool(settings.get("fullscreen", false)):
		mode = 1
	match mode:
		1:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
			DisplayServer.window_set_position(Vector2i.ZERO)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			var r: Vector2i = RESOLUTIONS[clampi(
				int(settings.get("resolution", 2)), 0, RESOLUTIONS.size() - 1)]
			DisplayServer.window_set_size(r)
			# Re-centre, or a smaller window lands half off the screen.
			DisplayServer.window_set_position((DisplayServer.screen_get_size() - r) / 2)
	settings["fullscreen"] = (mode == 1)


func _apply_bus(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.0001)))


# ── Save slots ────────────────────────────────────────────────────────────────

func get_save_slots(include_checkpoint: bool = false) -> Array:
	var slots := []
	if include_checkpoint and FileAccess.file_exists(storage_dir + "journey_checkpoint.json"):
		slots.append(_slot_info(-1))
	for i in range(MAX_SLOTS):
		slots.append(_slot_info(i))
	return slots


func _slot_path(slot: int) -> String:
	return storage_dir.path_join("journey_checkpoint.json" if slot == -1 else "slot_%d.json" % slot)


func _slot_info(slot: int) -> Dictionary:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return {"slot":slot, "empty":true, "valid":false, "data":{}, "issue":""}
	var data: Variant = _read_json(path)
	var issue := _save_issue(data)
	return {"slot":slot, "empty":false, "valid":issue.is_empty(),
		"data":data if data is Dictionary else {}, "issue":issue}


func _save_issue(data: Variant) -> String:
	if not data is Dictionary or data.is_empty(): return "This save is damaged or unreadable."
	if not data.has("scene") or not data.has("region") or not data.has("familiarity"):
		return "This file is not a complete journey save."
	if not _number(data.get("schema", 0)): return "This save has an unreadable format."
	if float(data.get("schema", 0)) != int(data.get("schema", 0)) or int(data.get("schema", 0)) < 0:
		return "This save has an unreadable format."
	if int(data.get("schema", 0)) > BUILD.SAVE_SCHEMA: return "This save needs a newer version of Foreign to All."
	# alien_appearance is deliberately absent: it is cosmetic, and loading
	# sanitizes any value back to the original alien. A damaged colour choice
	# must never cost a player their journey.
	for key: String in ["familiarity", "address", "reputation", "inventory", "region_visits", "world_flags", "quests", "wallet", "jobs_done"]:
		if data.has(key) and not data[key] is Dictionary: return "This save contains damaged %s data." % key.replace("_", " ")
	for key: String in ["region", "timestamp", "time_of_day", "city", "active_job", "scene"]:
		if data.has(key) and not data[key] is String: return "This save contains damaged location data."
	for key: String in ["money", "play_time", "hotel_floor", "job_progress"]:
		if data.has(key) and not _number(data[key]): return "This save contains damaged progress data."
	for key: String in ["inventory", "region_visits", "wallet", "jobs_done", "reputation"]:
		for value: Variant in data.get(key, {}).values():
			if not _number(value): return "This save contains damaged %s data." % key.replace("_", " ")
	for language: Variant in data.get("familiarity", {}).values():
		if not language is Dictionary: return "This save contains damaged language data."
		for value: Variant in language.values():
			if not _number(value): return "This save contains damaged vocabulary data."
	if not GameState.CITIES.has(data.get("city", "berlin")): return "This save names an unavailable city."
	var flags: Dictionary = data.get("world_flags", {})
	for key: String in ["understood", "word_observations", "journey_v1"]:
		if flags.has(key) and not flags[key] is Dictionary: return "This save contains damaged notebook data."
	for shelf: Variant in flags.get("understood", {}).values():
		if not shelf is Dictionary: return "This save contains damaged discoveries."
		for entry: Variant in shelf.values():
			if not entry is Dictionary: return "This save contains damaged discoveries."
			if entry.has("applications") and not entry.applications is Dictionary: return "This save contains damaged word memories."
	for quest: Variant in data.get("quests", {}).values():
		if not quest is Dictionary or not quest.get("steps", []) is Array: return "This save contains damaged journal tasks."
		for step: Variant in quest.get("steps", []):
			if not step is Dictionary: return "This save contains damaged journal tasks."
	var scene: String = data.get("scene", "res://scenes/world/Kiez.tscn")
	if not scene.begins_with("res://scenes/world/") or ".." in scene or not scene.ends_with(".tscn") or not ResourceLoader.exists(scene):
		return "This save's location is unavailable in this build."
	var point: Variant = data.get("place_position", [])
	if not point is Array or (not point.is_empty() and (point.size() != 2 or not _number(point[0]) or not _number(point[1]))):
		return "This save contains a damaged position."
	return ""


# Scene to enter after a successful load_game (read by LoadScreen)
var pending_scene: String = "res://scenes/world/Kiez.tscn"
var _pending_place_position: Variant = null

func take_place_position(scene: String) -> Variant:
	if scene != pending_scene: return null
	var result: Variant = _pending_place_position
	_pending_place_position = null
	return result


func save_game(slot: int) -> bool:
	if slot < -1 or slot >= MAX_SLOTS: return _fail("That save slot is unavailable.")
	var scene_path := "res://scenes/world/Kiez.tscn"
	var cur := get_tree().current_scene
	if cur != null and not cur.scene_file_path.is_empty():
		scene_path = cur.scene_file_path
	var data := {
		"version": BUILD.VERSION,
		"build_id": BUILD.BUILD_ID,
		"schema": BUILD.SAVE_SCHEMA,
		"slot":       slot,
		"timestamp":  Time.get_datetime_string_from_system(),
		"play_time":  GameState.play_time,
		"region":     GameState.current_region,
		"scene":      scene_path,
		"familiarity": GameState.familiarity,
		"alien_appearance": GameState.APPEARANCE.sanitize(GameState.alien_appearance),
		# How he has settled into addressing each language. A habit, not a
		# session: coming back to a save and finding yourself back on `Sie`
		# with somebody who calls you `du` would undo the whole mechanic.
		"address":     GameState.address,
		"reputation":  GameState.reputation,
		"money":       GameState.money,
		"inventory":   GameState.inventory,
		"region_visits": GameState.region_visits,
		"world_flags":  GameState.world_flags,
		"quests":       GameState.quests,
		"hotel_floor":  GameState.hotel_floor,
		"time_of_day":  GameState.time_of_day,
		"clock_minutes": GameState.clock_minutes,
		"city":         GameState.city,
		"wallet":       GameState.wallet,
		"active_job":   GameState.active_job,
		"job_progress": GameState.job_progress,
		"jobs_done":    GameState.jobs_done,
	}
	if cur != null and cur.get("place_id") != null:
		var player := cur.get_node_or_null("Player") as Node2D
		if player != null: data["place_position"] = [player.position.x,player.position.y]
	return _write_json(_slot_path(slot), data, "your journey")


func checkpoint() -> void:
	var cur := get_tree().current_scene
	if cur != null and cur.scene_file_path.begins_with("res://scenes/world/"):
		save_game(-1)


func load_game(slot: int) -> bool:
	last_error = ""
	if slot < -1 or slot >= MAX_SLOTS: return _fail("That save slot is unavailable.")
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return _fail("This save is no longer in the saves folder.")
	var data: Variant = _read_json(path)
	var issue := _save_issue(data)
	if not issue.is_empty(): return _fail(issue + " Your current journey has not changed.")
	GameState.familiarity     = data.get("familiarity", {})
	GameState.alien_appearance = GameState.APPEARANCE.sanitize(data.get("alien_appearance", {}))
	# Older saves have no address at all, and an empty one is correct for them:
	# register_for() falls back to where a stranger starts in each language.
	GameState.address         = data.get("address", {})
	GameState.reputation      = data.get("reputation", GameState.reputation)
	GameState.current_region  = data.get("region", "kiez")
	GameState.play_time       = data.get("play_time", 0.0)
	# JSON stores all numbers as floats — cast integer state back explicitly
	GameState.inventory       = _int_values(data.get("inventory", {}))
	GameState.region_visits   = _int_values(data.get("region_visits", {}))
	GameState.world_flags     = data.get("world_flags", {})
	GameState.quests          = data.get("quests", {})
	GameState.hotel_floor     = int(data.get("hotel_floor", 0))
	GameState.city            = data.get("city", "berlin")
	GameState.clock_minutes = GameState.CLOCK.restore(data.get("clock_minutes"),
		String(data.get("time_of_day", "dawn")), GameState.city)
	GameState.active_job      = data.get("active_job", "")
	GameState.job_progress    = int(data.get("job_progress", 0))
	GameState.jobs_done       = _int_values(data.get("jobs_done", {}))
	# Wallet supersedes the old flat "money" field; fall back for old saves
	if data.has("wallet"):
		GameState.wallet = _int_values(data.get("wallet", {}))
	else:
		# A save from before the wallet existed. Build every pocket the
		# game has now and put the old single figure in the euro one,
		# rather than leaving fourteen currencies missing from the dict.
		GameState.wallet = GameState.fresh_wallet()
		GameState.wallet["EUR"] = int(data.get("money", 0))
	GameState.spawn_tag       = ""
	# Entering the loaded scene shouldn't count as a fresh visit
	GameState.skip_next_visit_count = true
	pending_scene = data.get("scene", "res://scenes/world/Kiez.tscn")
	_pending_place_position = null
	var point: Variant = data.get("place_position")
	if point is Array and point.size() == 2 and pending_scene.begins_with("res://scenes/world/activities/"):
		_pending_place_position = Vector2(float(point[0]),float(point[1]))
	return true


func _int_values(src: Dictionary) -> Dictionary:
	var out := {}
	for k in src:
		out[k] = int(src[k])
	return out


func delete_save(slot: int) -> bool:
	last_error = ""
	if slot < -1 or slot >= MAX_SLOTS: return _fail("That save slot is unavailable.")
	var path := _slot_path(slot)
	if FileAccess.file_exists(path) and DirAccess.remove_absolute(path) != OK:
		return _fail("Could not delete this save. Check folder permissions.")
	return true


# 0.0 when the player has asked for less movement, 1.0 otherwise.
#
# Everything that drifts, breathes, bobs or pulses multiplies its amplitude by
# this. It is not a cosmetic switch: a setting that changes nothing is worse
# than no setting, because the player believes it did something.
func motion() -> float:
	return 0.0 if bool(settings.get("reduce_motion", false)) else 1.0
