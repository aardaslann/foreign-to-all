extends SceneTree

# What the crowd says in passing, for recording and for native-speaker review.
# Writes docs/beta-language-review/chatter-lines.json; tools/eleven_voices.py
# records each fragment in two passers-by's voices (`crowd` in
# tools/voice_cast.json).
#
# Every language a crowd speaks. Where the screen shows a romanisation (Russian,
# Hindi, Japanese, Korean, Georgian) or leaves accents off, the synthesiser is
# given a proper reading from tools/voice_readings.json instead, so nothing is
# recorded the way a romanisation would be misread.
#
# Run: godot --headless --path . --script res://tools/export_chatter.gd

const LANGUAGES := ["german", "turkish", "english", "french", "spanish_mx",
	"russian", "hindi", "japanese", "portuguese", "italian", "korean",
	"vietnamese", "georgian", "wolof", "swissgerman", "spanish_bo"]
const PARTS := ["night", "morning", "afternoon", "evening"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var chatter: Script = load("res://scenes/npc/Chatter.gd")
	var rows: Dictionary = {}
	for language: String in LANGUAGES:
		for part: String in PARTS:
			for snip: Array in chatter.lines(language, part):
				var shown: PackedStringArray = []
				for pair: Array in snip:
					shown.append(String(pair[0]))
				var text: String = " ".join(shown)
				rows[language + "|" + text] = {"language": language, "text": text,
					"context": "said in passing on the street", "review": "pending"}
	var folder := "res://docs/beta-language-review"
	DirAccess.make_dir_recursive_absolute(folder)
	var file := FileAccess.open(folder + "/chatter-lines.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"lines": rows.values()}, "\t"))
	file.close()
	print("Chatter export: ", rows.size(), " fragments")
	quit()
