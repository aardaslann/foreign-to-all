extends "res://scenes/story/CityStreetStory.gd"

const SCRIPT := preload("res://scenes/story/mexico/MexicoScript.gd")

func _init() -> void:
	city = "mexico"
	chapters = SCRIPT.CHAPTERS
	actor_name = "KeyRocio"
	main_id = "rocio"

static func play(chapter_number: int) -> bool:
	return await play_story(load("res://scenes/story/mexico/MexicoStory.gd").new(), chapter_number)

func cast() -> Dictionary:
	var lucia: Dictionary = CHAR.look(512, city)
	lucia["build"] = "adult"
	lucia["cut"] = "bob"
	var tomas: Dictionary = CHAR.look(712, city)
	tomas["build"] = "old"
	tomas["cut"] = "short"
	return {
		"rocio":{"name":"Rocío", "voice":"rocio", "language":"spanish_mx", "region":"coyoacan", "look":Story.look_for(city)},
		"lucia":{"name":"Lucía", "voice":"lucia", "language":"spanish_mx", "region":"coyoacan", "look":lucia},
		"tomas":{"name":"Tomás", "voice":"tomas", "language":"spanish_mx", "region":"coyoacan", "look":tomas}
	}

func relationship(id: String) -> String:
	return {"rocio":"Flowers for her family's gathering", "lucia":"Draws what she wants to remember", "tomas":"Brought a familiar cup"}.get(id, "")

func flag(key: String):
	if key == "market":
		return bool(GameState.world_flags.get("spot_merced", false))
	return super.flag(key)

func moment(id: String) -> String:
	return {"0":"this particular cup", "1":"a story and a silence", "2":"what belongs in the drawing", "3":"the space among the flowers"}.get(id, "Coyoacán")
