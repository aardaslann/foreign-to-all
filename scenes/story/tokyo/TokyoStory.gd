extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/tokyo/TokyoScript.gd")

func _init() -> void:
	city = "tokyo"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeySetsuko"
	main_id = "setsuko"

static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/tokyo/TokyoStory.gd").new(), chapter_number)

func cast() -> Dictionary:
	var haru: Dictionary = CHAR.look(394, city)
	haru["build"] = "adult"
	haru["cut"] = "bob"
	var mori: Dictionary = CHAR.look(686, city)
	mori["build"] = "old"
	mori["cut"] = "short"
	return {
		"setsuko":{"name":"Setsuko", "voice":"setsuko", "language":"japanese", "region":"ueno", "look":Story.look_for(city)},
		"haru":{"name":"Haru", "voice":"haru", "language":"japanese", "region":"ueno", "look":haru},
		"mori":{"name":"Mr Mori", "voice":"mori", "language":"japanese", "region":"ueno", "look":mori}
	}

func relationship(id: String) -> String:
	return {"setsuko":"Cups and conversation", "haru":"Designing the paper display", "mori":"A regular with his own preferences"}.get(id, "")

func moment(id: String) -> String:
	return {"0":"a cup and an uncertain answer", "1":"the folded wish", "2":"somewhere within reach", "3":"a wish that belongs to me"}.get(id, "Ueno")
