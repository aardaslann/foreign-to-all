extends RefCounted

const ENV := preload("res://scenes/world/EnvironmentDesign.gd")
const PLACES := preload("res://scenes/world/ActivityPlaces.gd")
const GRAPH := preload("res://scenes/world/SceneGraph.gd")
const WORLD := "res://scenes/world/"
const ROOM_NAMES := {
	"hotel": "Hotel", "exchange": "Currency exchange", "police": "Police station",
	"hospital": "Hospital", "restaurant": "Restaurant", "airport": "Airport",
	"transit": "Transit station", "ubahn": "U-Bahn station", "metro": "Metro station",
	"underground": "Underground", "shop": "Workshop", "caff": "The caff",
}
const NAMES := {
	"Kiez": "The Kiez", "MitteOst": "Mitte East", "HotelLobby": "Hotel reception",
	"HotelFloor": "Hotel corridor", "HotelRoom": "Room 304", "IstanbulYusuf": "Yusuf's workshop",
}
static var _catalog: Dictionary = {}

static func catalog() -> Dictionary:
	if not _catalog.is_empty(): return _catalog
	var paths: Dictionary = {}
	for path: String in GRAPH.DOORS:
		paths[path] = true
		for edge: Array in GRAPH.DOORS[path]: paths[edge[0]] = true
	for path: String in GRAPH.TRANSIT:
		paths[path] = true
		for dest: String in GRAPH.TRANSIT[path][1]: paths[dest] = true
	paths[WORLD + "HotelFloor.tscn"] = true
	for path: String in paths:
		var id := path.get_file().get_basename()
		var design: Dictionary = ENV.catalog().get(id, {})
		if design.is_empty(): continue
		var place := PLACES.location(id)
		var region := String(place.get("region", design.get("district", "")))
		var room := String(design.get("room", ""))
		var title := String(place.get("title", NAMES.get(id, "")))
		if title.is_empty() and not region.is_empty(): title = _state().region_name(region)
		if title.is_empty(): title = String(ROOM_NAMES.get(room, id.capitalize()))
		_catalog[path] = {"id": id, "path": path, "title": title,
			"city": String(place.get("city", design.get("city", ""))),
			"region": region, "kind": "place" if not place.is_empty() else ("street" if not region.is_empty() else room),
			"design": design}
	# Rooms inherit the district of their connected street, not the player's
	# current district. No second list of all the world's rooms to keep in sync.
	for pass_index in range(4):
		for path: String in _catalog:
			if not String(_catalog[path].region).is_empty(): continue
			for edge: Array in GRAPH.DOORS.get(path, []):
				var other: Dictionary = _catalog.get(edge[0], {})
				if not String(other.get("region", "")).is_empty():
					_catalog[path].region = other.region
					break
	return _catalog

static func _state() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node("GameState")

static func record(path: String) -> Dictionary:
	return catalog().get(path, {})

static func title(path: String) -> String:
	return String(record(path).get("title", path.get_file().get_basename().capitalize()))

static func city_places(city: String) -> Array[String]:
	var result: Array[String] = []
	for path: String in catalog():
		if catalog()[path].city == city: result.append(path)
	result.sort_custom(func(a: String, b: String): return title(a).naturalnocasecmp_to(title(b)) < 0)
	return result

static func neighbors(path: String, live: Node = null) -> Array[String]:
	var result: Array[String] = []
	if live != null and live.scene_file_path == path:
		for pin: Dictionary in live_markers(live):
			if not String(pin.target).is_empty() and not result.has(pin.target): result.append(pin.target)
			for dest: String in pin.get("destinations", []):
				if not result.has(dest): result.append(dest)
	else:
		for dest: String in GRAPH._out_of(path):
			if catalog().has(dest): result.append(dest)
	# These doors are built by the elevator/room scripts, not SceneExit.
	if path == WORLD + "HotelLobby.tscn": result.append(WORLD + "HotelFloor.tscn")
	if path == WORLD + "HotelFloor.tscn":
		if not result.has(WORLD + "HotelLobby.tscn"): result.append(WORLD + "HotelLobby.tscn")
		if _state().world_flags.get("room_booked", false) and not result.has(WORLD + "HotelRoom.tscn"):
			result.append(WORLD + "HotelRoom.tscn")
	return result

static func route(from: String, to: String, live: Node = null) -> Array[String]:
	if not catalog().has(from) or not catalog().has(to): return []
	if from == to: return [from]
	var previous := {from: ""}
	var queue: Array[String] = [from]
	var cursor := 0
	while cursor < queue.size():
		var at: String = queue[cursor]
		cursor += 1
		for next: String in neighbors(at, live):
			if previous.has(next): continue
			previous[next] = at
			if next == to:
				var result: Array[String] = [to]
				var back: String = at
				while not back.is_empty():
					result.push_front(back)
					back = previous[back]
				return result
			queue.append(next)
	return []

static func thumbnail(path: String) -> Texture2D:
	var design: Dictionary = record(path).get("design", {})
	if design.is_empty(): return null
	var texture := AtlasTexture.new()
	texture.atlas = load(String(design.texture))
	var r: Array = design.source
	texture.region = Rect2(r[0], r[1], r[2], r[3])
	return texture

static func _caption(text: String) -> String:
	for separator: String in ["— ", "- ", "]  "]:
		var at := text.find(separator)
		if at >= 0: return text.substr(at + separator.length())
	return text

static func _pin(name: String, at: Vector2, label: String, kind: String, target := "") -> Dictionary:
	return {"node": name, "pos": at, "label": label, "kind": kind, "target": target}

static func live_markers(scene: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var state := _state()
	for node in scene.get_children():
		if not node is Node2D: continue
		var at: Vector2 = (scene as Node2D).to_local(node.global_position)
		var destination: Variant = node.get("target_scene")
		if destination != null and not String(destination).is_empty():
			var target := String(destination)
			if node.get("is_return") == true and not state.entered_from.is_empty() and ResourceLoader.exists(state.entered_from):
				target = state.entered_from
			if not target.is_empty(): result.append(_pin(node.name, at, title(target), "door", target))
		elif node.get("service") != null:
			var service: String = node.service
			if service.ends_with("_travel") and GRAPH.TRANSIT.has(scene.scene_file_path):
				var pin := _pin(node.name, at, "City transport", "transit")
				pin.destinations = GRAPH.TRANSIT[scene.scene_file_path][1]
				result.append(pin)
			else:
				result.append(_pin(node.name, at, _caption(node.prompt_text), "activity" if service == "local" else "service"))
		elif node.get_script() != null and node.get_script().resource_path == WORLD + "Elevator.gd":
			var dest := WORLD + ("HotelLobby.tscn" if scene.name == &"HotelFloor" else "HotelFloor.tscn")
			result.append(_pin(node.name, at, "Elevator", "door", dest))
		elif node.get("door_index") != null:
			var room: String = node._room_number()
			var target := WORLD + "HotelRoom.tscn" if room == state.HOTEL_ROOM and state.world_flags.get("room_booked", false) else ""
			result.append(_pin(node.name, at, "Room " + room, "door", target))
	return result

static func markers(path: String, live: Node = null) -> Array[Dictionary]:
	if live != null and live.scene_file_path == path: return live_markers(live)
	var result: Array[Dictionary] = []
	var design: Dictionary = record(path).get("design", {})
	if design.is_empty(): return result
	# Inspect resource properties only. Browsing a map must not run a scene's
	# scripts, increment visits, award items or start its story.
	var packed := load(path) as PackedScene
	var state := packed.get_state()
	for i in range(state.get_node_count()):
		var node_path := String(state.get_node_path(i)).trim_prefix("./")
		if node_path.contains("/") or node_path == ".": continue
		var props: Dictionary = {}
		for p in range(state.get_node_property_count(i)):
			props[String(state.get_node_property_name(i, p))] = state.get_node_property_value(i, p)
		var target := String(props.get("target_scene", ""))
		var service := String(props.get("service", ""))
		var instance := state.get_node_instance(i)
		var instance_path := instance.resource_path if instance != null else ""
		var elevator := instance_path == WORLD + "Elevator.tscn"
		var hotel_door := instance_path == WORLD + "HotelDoor.tscn"
		if target.is_empty() and service.is_empty() and not elevator and not hotel_door: continue
		var at: Vector2 = props.get("position", Vector2.ZERO)
		var anchor: Array = design.get("anchors", {}).get(node_path, [])
		if anchor.size() == 2: at = Vector2(anchor[0], anchor[1])
		elif design.has("district"): at.y = remap(at.y, 300, 640, float(design.get("floor", 490)) + 6, 636)
		var label := _caption(String(design.get("prompt_overrides", {}).get(node_path, props.get("prompt_text", service.capitalize()))))
		if elevator:
			target = WORLD + ("HotelLobby.tscn" if path.ends_with("HotelFloor.tscn") else "HotelFloor.tscn")
			result.append(_pin(node_path, at, "Elevator", "door", target))
			continue
		if hotel_door:
			var floor_number: int = _state().hotel_floor if path == _current_path() else 3
			var room := "%d0%d" % [floor_number, int(props.get("door_index", 1))]
			target = WORLD + "HotelRoom.tscn" if room == _state().HOTEL_ROOM and _state().world_flags.get("room_booked", false) else ""
			result.append(_pin(node_path, at, "Room " + room, "door", target))
			continue
		var entry := PLACES.entry(path, node_path)
		if not entry.is_empty():
			target = PLACES.scene_path(entry.place)
			# ServicePoint applies this after the background's anchors.
			if entry.has("at"): at = Vector2(entry.at[0], entry.at[1])
		if not target.is_empty():
			result.append(_pin(node_path, at, title(target), "door", target))
		elif service.ends_with("_travel") and GRAPH.TRANSIT.has(path):
			var pin := _pin(node_path, at, "City transport", "transit")
			pin.destinations = GRAPH.TRANSIT[path][1]
			result.append(pin)
		else: result.append(_pin(node_path, at, label, "activity" if service == "local" else "service"))
	return result

static func _current_path() -> String:
	var scene := (Engine.get_main_loop() as SceneTree).current_scene
	return scene.scene_file_path if scene != null else ""
