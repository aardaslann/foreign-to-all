extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/london/LondonScript.gd")

func _init() -> void:
	city = "london"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyNadia"
	main_id = "nadia"


static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/london/LondonStory.gd").new(), chapter_number)


func cast() -> Dictionary:
	var val: Dictionary = CHAR.look(108, "london")
	val["build"] = "adult"
	val["cut"] = "bun"
	var ahmed: Dictionary = CHAR.look(482, "london")
	ahmed["build"] = "elder"
	ahmed["mark"] = "greybeard"
	return {
		"nadia":{"name":"Nadia", "voice":"nadia", "language":"english", "region":"terrace", "look":Story.look_for("london")},
		"val":{"name":"Val", "voice":"val", "language":"english", "region":"terrace", "look":val},
		"ahmed":{"name":"Mr Ahmed", "voice":"ahmed", "language":"english", "region":"terrace", "look":ahmed}
	}


func relationship(id: String) -> String:
	return {"nadia":"Making a design portfolio" if Story.rounds_done(city) > 0 else "Four doors down",
		"val":"Runs the high-street caff", "ahmed":"Lives along the terrace"}.get(id, "")


func flag(key: String):
	if key == "caff":
		return bool(GameState.world_flags.get("spot_highstreet", false))
	return super.flag(key)


func moment(id: String) -> String:
	return {"0":"a request on the terrace", "1":"Nadia's unfinished drawing",
		"2":"choosing a place to watch", "3":"the evening of the lights"}.get(id, "the terrace")
