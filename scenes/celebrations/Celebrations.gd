extends RefCounted

const VENUES := {
	"berlin":"Neighbourhood fairground | Berlin",
	"istanbul":"Bayram in the han garden | Istanbul",
	"london":"Bonfire Night in the park | London",
	"paris":"14 July in the shared courtyard | Paris",
	"moscow":"Maslenitsa in the park | Moscow",
	"mumbai":"The neighbourhood pandal | Mumbai",
	"tokyo":"Tanabata in the garden | Tokyo",
	"mexico":"D\u00eda de Muertos in the family courtyard | Mexico City"
}

const CAST := {
	"istanbul":["arda", "selin", "hasan"], "london":["nadia", "val", "ahmed"],
	"paris":["odile", "ines", "marcel"], "moscow":["viktor", "alina", "pavel"],
	"mumbai":["omkar", "asha", "yusuf"], "tokyo":["setsuko", "haru", "mori"],
	"mexico":["rocio", "lucia", "tomas"]
}

static func scene_path(city: String) -> String:
	return "res://scenes/celebrations/" + city + ".tscn"

static func stage(city: String, source: Array) -> Array:
	var shots := source.duplicate(true)
	if not VENUES.has(city): return shots
	var people: Dictionary = {}
	if CAST.has(city):
		var class_name_text := city.substr(0, 1).to_upper() + city.substr(1) + "Story"
		var story: RefCounted = load("res://scenes/story/%s/%s.gd" % [city, class_name_text]).new()
		people = story.cast()
	for index in range(shots.size()):
		var shot: Dictionary = shots[index]
		# Berlin has an explicit journey out and a journey home. Keep those on
		# their original street plate; only the gathering moves to the fair.
		if city == "berlin" and index in [0, shots.size() - 1]: continue
		shot["bg_scene"] = "celebration:" + city
		shot["venue"] = VENUES[city]
		shot["authored_plate"] = true
		shot["set"] = "celebration"
		shot["object"] = ""
		shot["cam"] = [0.5, 648.0]
		shot["full_plate"] = true
		shot["ground"] = [0.77, 0.89]
		var cast: Array = shot.get("cast", [])
		if CAST.has(city):
			while cast.size() < 4:
				cast.append({"at":0.5, "act":"watch"})
			shot["cast"] = cast
		for i in range(cast.size()):
			# Keep faces clear of the rear furniture and ornaments.
			cast[i]["world_height"] = 126.0
			if i > 0 and CAST.has(city):
				cast[i]["at"] = [0.22, 0.49, 0.75, 0.96][i % 4]
				if i >= 2:
					cast[i]["world_height"] = 108.0
					cast[i]["feet_y"] = 0.76
				var id: String = CAST[city][(i - 1) % CAST[city].size()]
				if people.has(id): cast[i]["appearance"] = people[id].get("look", {})
	return shots
