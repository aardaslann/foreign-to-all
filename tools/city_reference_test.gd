extends SceneTree

# Cities can be visited in any order (only Berlin is always first, because the
# journey starts with the crash there), so nothing a player sees may assume an
# earlier trip. An answer that does draw on another country carries
# "needs_city" and is only offered once he has been there. This proves both:
#
#   1. no roster answer names another city or country unless it is gated on it;
#   2. the narration and encounter text is free of "the way that worked in
#      Brazil"-style assumptions;
#   3. the dialogue box really hides a gated answer, and offers it after a visit.
#
# Run: godot --headless --path . --script res://tools/city_reference_test.gd

const ROSTERS := ["res://scenes/npc/CityNPCs.gd", "res://scenes/npc/CityNPCsWorld.gd",
	"res://scenes/npc/CityNPCsAmerica.gd"]
const NARRATION := ["res://scenes/npc/Encounters.gd", "res://scenes/npc/KeyLines.gd",
	"res://autoload/Services.gd", "res://scenes/world/StreetsideAmerica.gd",
	"res://scenes/world/StreetsideSouth.gd", "res://scenes/world/StreetsideSouthTwo.gd",
	"res://scenes/world/StreetsideNorth.gd", "res://scenes/world/StreetsideEast.gd",
	"res://scenes/world/StreetsideWest.gd", "res://scenes/world/StreetsidePacific.gd"]
# The traveller's voice: phrasings that only make sense after another trip.
const ASSUMES := "(?i)(the way (that )?(worked|you would|you did) in [A-Z]|the way [A-Z]\\w+ taught|learned in (?!Berlin)[A-Z]|last city|in \\w+ cities you|anywhere else you have been|did in (?!Berlin)[A-Z]\\w+)"
const ALIASES := {"mumbai": ["Bombay"], "saopaulo": ["Sao Paulo", "Brasil"], "istanbul": ["Turkey"]}

var checks := 0
var failures := 0
var gs: Node


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("CITY REFERENCES: " + message)


func _run() -> void:
	root.get_node("SaveManager").use_test_storage("city_reference")
	gs = root.get_node("GameState")
	gs.reset()
	_check_rosters()
	_check_narration()
	await _check_gate()
	print("CITY REFERENCES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


func _names(city: String) -> Array:
	var info: Dictionary = gs.CITIES[city]
	var out: Array = [String(info.get("name", "")), String(info.get("country", ""))]
	out.append_array(ALIASES.get(city, []))
	return out.filter(func(n: String) -> bool: return n.length() > 2)


func _answers(node: Variant, out: Array) -> void:
	if node is Dictionary:
		if node.has("gesture") or node.has("say"):
			out.append(node)
		for value: Variant in node.values():
			_answers(value, out)
	elif node is Array:
		for value: Variant in node:
			_answers(value, out)


func _check_rosters() -> void:
	var seen := 0
	for path: String in ROSTERS:
		var constants: Dictionary = (load(path) as GDScript).get_script_constant_map()
		for name: String in constants:
			var here := name.to_lower()
			if not gs.CITIES.has(here) or not constants[name] is Dictionary:
				continue
			var answers: Array = []
			_answers(constants[name], answers)
			for answer: Dictionary in answers:
				seen += 1
				var said := " ".join([answer.get("gesture", ""), answer.get("words", ""), answer.get("say", "")])
				for other: String in gs.CITIES:
					if other == here or other == "berlin":
						continue
					for place: String in _names(other):
						if said.contains(place):
							check(String(answer.get("needs_city", "")) == other,
								"%s answer names %s without having been there: %s" % [here, place, said.left(90)])
	check(seen > 300, "the roster answers were all read (%d)" % seen)


func _check_narration() -> void:
	var assumes := RegEx.create_from_string(ASSUMES)
	for path: String in NARRATION + ROSTERS:
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for i in range(lines.size()):
			var line: String = lines[i]
			if line.strip_edges().begins_with("#") or line.contains("needs_city"):
				continue
			var found := assumes.search(line)
			check(found == null, "%s:%d assumes an earlier trip: %s" % [path.get_file(), i + 1,
				found.get_string() if found != null else ""])


# A row reads as the gesture early on and as the sentence once he has words,
# so either phrasing counts.
func _offered(dlg: Node, phrasings: Array) -> bool:
	for node: Node in dlg._resp_box.find_children("*", "RichTextLabel", true, false):
		var shown: String = (node as RichTextLabel).get_parsed_text()
		for phrasing: String in phrasings:
			if shown.contains(phrasing):
				return true
	return false


func _check_gate() -> void:
	gs.quests["find_bed"] = {"completed": true, "steps": []}
	var world: Node = load("res://scenes/world/Mitte.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(8):
		await process_frame
	var dlg := get_first_node_in_group("dialogue_box")
	var entry := {"words": [{"text": "Buyurun.", "word": "buyurun", "language": "turkish"}],
		"responses": [
			{"gesture": "Answer with the Turkish you carried out of Istanbul", "say": "Merhaba.",
				"style": "casual", "rep": 3, "needs_city": "istanbul"},
			{"gesture": "Answer in German", "say": "Hallo.", "style": "direct", "rep": 2},
			{"gesture": "Point, and hold up one finger", "say": "That one.", "style": "gesture", "rep": 1}]}
	for visited: bool in [false, true]:
		gs.world_flags["visited_istanbul"] = visited
		dlg.show_dialogue([entry], "Sibel", "", Color(0.78, 0.46, 0.34), false, "kreuzberg")
		await process_frame
		dlg._render_options(entry)
		await process_frame
		check(_offered(dlg, ["carried out of Istanbul", "Merhaba"]) == visited,
			"the Istanbul answer is %s" % ("offered after a visit" if visited else "hidden before one"))
		check(_offered(dlg, ["Answer in German", "Hallo"]) and _offered(dlg, ["Point, and hold", "That one"]),
			"the ungated answers stay (visited=%s)" % visited)
		check(dlg._resp_box.get_child_count() == (3 if visited else 2),
			"%d answers offered (visited=%s)" % [dlg._resp_box.get_child_count(), visited])
		dlg._close()
		await process_frame
	world.queue_free()
	await process_frame
