extends RefCounted

# Permanent world locations. Separate from film staging: opening a place never
# completes its activity or changes the established district/story gates.
const PATH := "res://art/environments/activity-world.json"
static var _data: Dictionary = {}

static func catalog() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary: _data = parsed
	return _data

static func location(id: String) -> Dictionary:
	return catalog().get("places", {}).get(id, {})

static func entry(scene: String, node: String) -> Dictionary:
	return catalog().get("entries", {}).get(scene, {}).get(node, {})

static func scene_path(id: String) -> String:
	return "res://scenes/world/activities/" + id + ".tscn"
