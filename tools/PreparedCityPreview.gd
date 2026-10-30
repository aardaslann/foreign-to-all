extends RefCounted

# Tool-only injection. The shipped game's catalog never loads prepared files.
static func install() -> void:
	var environment = load("res://scenes/world/EnvironmentDesign.gd")
	var catalog: Dictionary = environment.catalog()
	for path: String in ["prepared-worlds.json", "prepared-activity-plates.json"]:
		var prepared: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/" + path))
		for key: String in prepared:
			if catalog.has(key): catalog[key].merge(prepared[key],true)
			else: catalog[key] = prepared[key]
	var direction = load("res://scenes/world/ActivityDirection.gd")
	direction.stage("__preparation_preview__", {})
	var staging: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		"res://art/environments/prepared-activity-staging.json"))
	direction._directions.merge(staging,true)
	print("PREPARED PREVIEW: source art and provisional alignment; not final artwork")
