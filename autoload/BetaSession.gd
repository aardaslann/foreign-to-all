extends Node

# Optional, local-only playtime evidence. No network, identifiers or key log.
# The notebook saves this with progress; a tester chooses whether to export it.
var idle_seconds := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		idle_seconds = 0.0
	elif event is InputEventMouseMotion and event.relative.length_squared() > 4.0:
		idle_seconds = 0.0


func _process(delta: float) -> void:
	if not bool(SaveManager.settings.get("beta_session_notes", false)):
		return
	idle_seconds += delta
	if idle_seconds > 120.0 or not Journey.core():
		return
	var scene := get_tree().current_scene
	if scene == null or not scene.scene_file_path.begins_with("res://scenes/world/"):
		return
	if DisplayServer.get_name() != "headless" and not DisplayServer.window_is_focused():
		return
	var mode := "exploring"
	if get_tree().paused:
		var reading := false
		for group: String in ["dialogue_box", "choice_panel", "cutscene", "thought_box"]:
			var panel := get_tree().get_first_node_in_group(group)
			if panel != null:
				reading = reading or (bool(panel.get("_open")) if group in ["choice_panel", "cutscene"] else panel.visible)
		if not reading:
			return
		mode = "reading"
	var totals: Dictionary = Journey.ledger().get("session_seconds", {})
	var city: Dictionary = totals.get(GameState.city, {"exploring": 0.0, "reading": 0.0})
	city[mode] = float(city.get(mode, 0.0)) + minf(delta, 1.0)
	totals[GameState.city] = city
	Journey.ledger()["session_seconds"] = totals


func report(note: String) -> Dictionary:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var scene := get_tree().current_scene
	var payload: Dictionary = {"version": Journey.VERSION,
		"build_id": preload("res://autoload/BuildInfo.gd").BUILD_ID,
		"save_schema": preload("res://autoload/BuildInfo.gd").SAVE_SCHEMA,
		"created": Time.get_datetime_string_from_system(),
		"city": GameState.city, "district": GameState.current_region,
		"scene": scene.scene_file_path if scene != null else "",
		"position": [player.position.x, player.position.y] if player != null else [],
		"friendship_round": Story.rounds_done(GameState.city) if Journey.core() else 0,
		"holiday_seen": Story.holiday_seen(GameState.city) if Journey.core() else false,
		"note": note.strip_edges(), "timing_enabled": bool(SaveManager.settings.get("beta_session_notes", false))}
	if payload["timing_enabled"]:
		payload["session_seconds"] = Journey.ledger().get("session_seconds", {}).duplicate(true)
	return payload


func export_report(note: String) -> String:
	var folder: String = SaveManager.storage_dir.path_join("feedback")
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return ""
	var path: String = folder.path_join("beta-%d-%d.json" % [int(Time.get_unix_time_from_system()), Time.get_ticks_usec()])
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(report(note), "\t"))
	file.flush()
	if file.get_error() != OK:
		return ""
	return ProjectSettings.globalize_path(path)
