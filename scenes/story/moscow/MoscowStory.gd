extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/moscow/MoscowScript.gd")

func _init() -> void:
	city = "moscow"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyViktor"
	main_id = "viktor"


static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/moscow/MoscowStory.gd").new(), chapter_number)


func cast() -> Dictionary:
	var alina: Dictionary = CHAR.look(544, city)
	alina["build"] = "adult"
	alina["cut"] = "bob"
	var pavel: Dictionary = CHAR.look(735, city)
	pavel["build"] = "adult"
	pavel["cut"] = "short"
	return {
		"viktor":{"name":"Viktor", "voice":"viktor", "language":"russian", "region":"basmanny", "look":Story.look_for(city)},
		"alina":{"name":"Alina", "voice":"alina", "language":"russian", "region":"basmanny", "look":alina},
		"pavel":{"name":"Pavel", "voice":"pavel", "language":"russian", "region":"basmanny", "look":pavel}
	}


func person(_id: String) -> Dictionary:
	return {"build":"adult", "wants":"vy"}


func relationship(id: String) -> String:
	return {"viktor":"The repair booth", "alina":"Her brooch; her decision", "pavel":"Brings parts and football opinions"}.get(id, "")


func flag(key: String):
	if key == "market":
		return bool(GameState.world_flags.get("spot_izmaylovo", false))
	return super.flag(key)


func moment(id: String) -> String:
	return {"0":"the two brooches", "1":"a story Alina had not offered",
		"2":"testing a repair with its owner", "3":"Maslenitsa beside the repair booth"}.get(id, "Basmanny")
