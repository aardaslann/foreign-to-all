extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/mumbai/MumbaiScript.gd")

func _init() -> void:
	city = "mumbai"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyOmkar"
	main_id = "omkar"

static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/mumbai/MumbaiStory.gd").new(), chapter_number)

func cast() -> Dictionary:
	var asha: Dictionary = CHAR.look(472, city)
	asha["build"] = "adult"
	asha["cut"] = "bun"
	var yusuf: Dictionary = CHAR.look(684, city)
	yusuf["build"] = "adult"
	yusuf["cut"] = "short"
	return {
		"omkar":{"name":"Omkar", "voice":"omkar", "language":"hindi", "region":"bhuleshwar", "look":Story.look_for(city)},
		"asha":{"name":"Asha", "voice":"asha", "language":"hindi", "region":"bhuleshwar", "look":asha},
		"yusuf":{"name":"Yusuf", "voice":"yusuf", "language":"hindi", "region":"bhuleshwar", "look":yusuf}
	}

func relationship(id: String) -> String:
	return {"omkar":"Repairs phones; draws stages", "asha":"Planning this gathering", "yusuf":"Deliveries still need a way through"}.get(id, "")

func flag(key: String):
	if key == "market":
		return bool(GameState.world_flags.get("spot_chorbazaar", false))
	return super.flag(key)

func moment(id: String) -> String:
	return {"0":"one thing at a time", "1":"the phone and the sketchbook", "2":"a plan people can use", "3":"Ganesh Chaturthi in Omkar's lane"}.get(id, "Bhuleshwar")
