extends SceneTree

# Read-only authoring export for recording and native-speaker review.
func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var script: Script = load("res://scenes/story/berlin/BerlinScript.gd")
	var late: Script = load("res://scenes/story/berlin/BerlinScriptLate.gd")
	var istanbul: Script = load("res://scenes/story/istanbul/IstanbulScript.gd")
	var london: Script = load("res://scenes/story/london/LondonScript.gd")
	var paris: Script = load("res://scenes/story/paris/ParisScript.gd")
	var moscow: Script = load("res://scenes/story/moscow/MoscowScript.gd")
	var mumbai: Script = load("res://scenes/story/mumbai/MumbaiScript.gd")
	var tokyo: Script = load("res://scenes/story/tokyo/TokyoScript.gd")
	var mexico: Script = load("res://scenes/story/mexico/MexicoScript.gd")
	var lines: Dictionary = {}
	for pack: Dictionary in [script.CHAPTERS, late.CHAPTERS, istanbul.CHAPTERS, london.CHAPTERS, paris.CHAPTERS, moscow.CHAPTERS, mumbai.CHAPTERS, tokyo.CHAPTERS, mexico.CHAPTERS]:
		for chapter: String in pack:
			for step: Dictionary in pack[chapter]:
				if step.get("do", "") not in ["line", "ask"]:
					continue
				var spoken: String = step.get("tts", step.get("say", ""))
				var voice: String = step.get("id", "")
				var city: String = "istanbul" if voice in ["arda", "selin", "hasan"] else ("london" if voice in ["nadia", "val", "ahmed"] else "berlin")
				if voice in ["odile", "ines", "marcel"]:
					city = "paris"
				if voice in ["viktor", "alina", "pavel"]:
					city = "moscow"
				if voice in ["omkar", "asha", "yusuf"]:
					city = "mumbai"
				if voice in ["setsuko", "haru", "mori"]:
					city = "tokyo"
				if voice in ["rocio", "lucia", "tomas"]:
					city = "mexico"
				if spoken.is_empty() or voice.is_empty():
					continue
				var key: String = voice + "|" + " ".join(spoken.strip_edges().split(" ", false))
				lines[key] = {"voice": voice, "text": spoken,
					"language": step.get("language", {"istanbul":"turkish", "london":"english", "paris":"french", "moscow":"russian", "mumbai":"hindi", "tokyo":"japanese", "mexico":"spanish_mx"}.get(city, "german")), "city": city, "chapter": chapter,
					"context": step.get("stage", ""), "review": "pending"}
	for spoken: String in late.AFTER:
		lines["kerstin|" + spoken] = {"voice":"kerstin", "text":spoken, "language":"german", "city":"berlin", "chapter":"after", "context":"A familiar greeting after the story", "review":"pending"}
	var counters: Script = load("res://scenes/dialogue/CounterEncounter.gd")
	var gs := root.get_node("GameState")
	for city: String in counters.LINES:
		var language: String = gs.CITIES[city]["language"]
		for index in [0, 2, 3]:
			var spoken: String = counters.LINES[city][index]
			var voice: String = "counter_" + city
			lines[voice + "|" + spoken] = {"voice": voice, "text": spoken,
				"language": language, "city": city, "chapter": "services",
				"context": "Offering a room, confirming one night, or offering a ticket", "review": "pending"}
	var folder := "res://docs/beta-language-review"
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder + "/spoken-lines.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"lines": lines.values()}, "\t"))
	file.close()
	print("Speech review export: ", lines.size(), " lines")
	quit()
