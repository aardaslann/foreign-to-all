extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/paris/ParisScript.gd")

func _init() -> void:
	city = "paris"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyOdile"
	main_id = "odile"


static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/paris/ParisStory.gd").new(), chapter_number)


func cast() -> Dictionary:
	var ines: Dictionary = CHAR.look(362, city)
	ines["build"] = "adult"
	ines["cut"] = "bob"
	var marcel: Dictionary = CHAR.look(671, city)
	marcel["build"] = "adult"
	marcel["cut"] = "short"
	return {
		"odile":{"name":"Odile", "voice":"odile", "language":"french", "region":"marais", "look":Story.look_for(city)},
		"ines":{"name":"Inès", "voice":"ines", "language":"french", "region":"marais", "look":ines},
		"marcel":{"name":"Marcel", "voice":"marcel", "language":"french", "region":"marais", "look":marcel}
	}


func person(id: String) -> Dictionary:
	return {"build":"elder" if id == "odile" else "adult", "wants":"tu" if id == "ines" else "vous"}


func relationship(id: String) -> String:
	return {"odile":"Forty-one years in this building", "ines":"A neighbour with a phone to answer",
		"marcel":"Bakes early; likes to eat early"}.get(id, "")


func flag(key: String):
	if key == "bakery":
		return bool(GameState.world_flags.get("spot_belleville", false))
	return super.flag(key)


func moment(id: String) -> String:
	return {"0":"a hello before the map", "1":"the call Inès could not miss",
		"2":"a place without a promise", "3":"the neighbours' revised plan"}.get(id, "the Marais")
