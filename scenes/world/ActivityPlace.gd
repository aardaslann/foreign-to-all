extends Node2D

const PLACES := preload("res://scenes/world/ActivityPlaces.gd")
const ACTOR := preload("res://scenes/story/StoryActor.gd")
const ROSTER := preload("res://scenes/npc/CastRoster.gd")
const WORD_USE := preload("res://scenes/world/WordUseMoment.gd")
@export var place_id: String = ""
var spawn := Vector2(180, 540)

func _ready() -> void:
	var place := PLACES.location(place_id)
	GameState.city = String(place["city"])
	# It remains the same neighbourhood. Exploring a room is neither another
	# district visit nor completion of its shared, once-rewarded activity.
	GameState.current_region = String(place["region"])
	GameState.skip_next_visit_count = false
	AudioManager.set_ambience(String(place.get("ambience", "street")))
	AudioManager.scene_music(self, String(place.get("ambience", "street")) == "interior")
	if not GameState.place_at_return_door(self, $Player): $Player.position = spawn
	var saved_position: Variant = SaveManager.take_place_position(scene_file_path)
	if saved_position is Vector2: $Player.position = saved_position
	GameState.last_scene = ""
	GameState.spawn_tag = ""
	var residents: Array = []
	var resident_rows: Array = Array(place.get("residents", [])).duplicate(true)
	var encounter: Dictionary = WORD_USE.MOMENTS.get(place_id, {})
	if encounter.has("resident"): resident_rows.append(encounter.resident)
	for row: Dictionary in resident_rows:
		var person := Node2D.new()
		person.set_script(ACTOR)
		person.set("id", String(row["id"]))
		var appearance: Dictionary = ROSTER.clerk_look(String(row["id"]), "local", GameState.city)
		var overrides: Dictionary = row.get("appearance", {})
		# A coat override must not replace the skin/eye/hair palette. Missing
		# palette entries are transparent pixels in CharacterArt's grid.
		for key: String in overrides:
			if key == "pal":
				for ink: String in overrides["pal"]:
					appearance["pal"][ink] = Color(String(overrides["pal"][ink]))
			else: appearance[key] = overrides[key]
		person.set("look", appearance)
		person.position = Vector2(row["feet"][0],row["feet"][1])-Vector2(0,22)
		add_child(person)
		residents.append(person)
	var word_use := WORD_USE.new()
	add_child(word_use)
	word_use.setup(place_id, residents)
	_show_place.call_deferred(String(place["title"]))

func _show_place(title: String) -> void:
	# A location caption, not a modal thought: the player keeps walking.
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	var caption := Label.new()
	caption.position = Vector2(28, get_viewport().get_visible_rect().size.y - 100)
	caption.text = title + "\nExplore freely · E to interact"
	caption.add_theme_font_size_override("font_size",18)
	caption.add_theme_color_override("font_shadow_color",Color("101222"))
	caption.add_theme_constant_override("shadow_offset_x",2)
	caption.add_theme_constant_override("shadow_offset_y",2)
	layer.add_child(caption)
	var tween := create_tween()
	tween.tween_interval(4.0)
	tween.tween_property(caption,"modulate:a",0.0,0.5)
	tween.tween_callback(layer.queue_free)
