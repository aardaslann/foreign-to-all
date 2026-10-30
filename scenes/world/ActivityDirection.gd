extends RefCounted

# Visual direction stays separate from the encounter's choices and rewards.
# The same directed data feeds live activities and preview tools.
static var _directions: Dictionary = {}

static func stage(key: String, original: Dictionary) -> Dictionary:
	if _directions.is_empty():
		_directions = JSON.parse_string(FileAccess.get_file_as_string(
			"res://art/environments/activity-staging.json"))
		var city_path := "res://art/environments/city-activity-staging.json"
		if FileAccess.file_exists(city_path):
			var city_directions: Variant = JSON.parse_string(FileAccess.get_file_as_string(city_path))
			if city_directions is Dictionary: _directions.merge(city_directions,true)
	if not _directions.has(key):
		return original
	var data: Dictionary = original.duplicate(true)
	for id: String in _directions[key]:
		if not data["beats"].has(id):
			continue
		var direction: Dictionary = _directions[key][id]
		var beat: Dictionary = data["beats"][id]
		var staging: Dictionary = direction.get("staging", {})
		beat["staging"] = staging.duplicate(true)
		var film: Array = beat.get("film", [])
		if direction.has("film_count"):
			film.resize(mini(film.size(), int(direction["film_count"])))
		var shots: Array = direction.get("shots", [])
		for i in range(film.size()):
			film[i].merge(staging, true)
			if i < shots.size():
				film[i].merge(shots[i], true)
		# A choice can change who acts before the following result shot.
		# Only visual staging is copied; costs, choices and rewards stay authored.
		var choices: Dictionary = direction.get("choices", {})
		for row: Dictionary in beat.get("rows", []):
			var choice_id: String = String(row.get("id", ""))
			if choices.has(choice_id):
				row["staging"] = choices[choice_id].get("staging", {}).duplicate(true)
	return data
