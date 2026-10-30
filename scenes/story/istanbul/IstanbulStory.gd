extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/istanbul/IstanbulScript.gd")

func _init() -> void:
	city = "istanbul"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyArda"
	main_id = "arda"


static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/istanbul/IstanbulStory.gd").new(), chapter_number)


func cast() -> Dictionary:
	var selin: Dictionary = CHAR.look(283, "istanbul")
	selin["build"] = "adult"
	selin["cut"] = "bob"
	var hasan: Dictionary = CHAR.look(719, "istanbul")
	hasan["build"] = "elder"
	hasan["mark"] = "greybeard"
	return {
		"arda": {"name":"Arda", "language":"turkish", "voice":"arda", "region":"han", "look":Story.look_for("istanbul")},
		"selin": {"name":"Selin", "language":"turkish", "voice":"selin", "region":"han", "look":selin},
		"hasan": {"name":"Hasan", "language":"turkish", "voice":"hasan", "region":"han", "look":hasan}
	}


func look(id: String, _outfit: String = "") -> Dictionary:
	return cast().get(id, {}).get("look", {})


func person(id: String) -> Dictionary:
	return {"build":"elder" if id == "hasan" else "adult",
		"wants":"siz" if id == "hasan" else "sen"}


func relationship(id: String) -> String:
	return {"arda":"A friend learning camera repair" if Story.rounds_done("istanbul") >= 2 else "On the tea round",
		"selin":"A neighbour who likes light tea", "hasan":"A regular with a lot on his mind"}.get(id, "")


func flag(key: String):
	if key == "bakery":
		return bool(GameState.world_flags.get("spot_carsi", false))
	return super.flag(key)


func moment(id: String) -> String:
	return {"0":"the first tea round", "1":"a photograph and a minute's rest",
		"2":"Arda's break and a place in the picture", "3":"Bayram at the han"}.get(id, "the han")


