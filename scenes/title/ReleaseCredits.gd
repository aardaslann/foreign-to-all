extends RefCounted

const TEXT := """FOREIGN TO ALL

Created by Arda Aslan
Design direction, production and creative decisions

Sound and voices
Audio production directed by Arda Aslan

Technology and type
Godot Engine and its third-party components
Noto Sans Japanese, Korean, Devanagari and Georgian
Noto fonts are distributed under the SIL Open Font License 1.1.

Beta scope
Eight core city stories. Other destinations are not accessible in this beta.
English is the complete beta interface; other interface translations are previews.
Native-language review remains pending.

Privacy
No automatic feedback upload. Playtime notes are optional and stored locally.
Share only the feedback files you choose with the person who supplied your beta.
"""


static func notices() -> String:
	var result := "GODOT ENGINE\n\n" + Engine.get_license_text()
	result += "\n\nGODOT THIRD-PARTY COPYRIGHT NOTICES\n" + JSON.stringify(Engine.get_copyright_info(), "\t")
	for name: String in Engine.get_license_info():
		result += "\n\n" + name + "\n" + String(Engine.get_license_info()[name])
	for font: String in ["NotoSansJP", "NotoSansKR", "NotoSansDevanagari", "NotoSansGeorgian"]:
		result += "\n\n" + font + "\n" + FileAccess.get_file_as_string("res://art/fonts/" + font + "-OFL.txt")
	return result
