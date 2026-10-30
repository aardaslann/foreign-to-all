extends "res://tools/design_campaign.gd"

# Starts with ten learned words to isolate the friendship/errand/holiday
# flow from vocabulary repetition. All progress after that uses live input.
func _run() -> void:
	var gs = root.get_node("GameState")
	var story = root.get_node("Story")
	for city: String in ["berlin","istanbul"]:
		gs.city = city
		gs.world_flags.clear()
		gs.quests.clear()
		gs.region_visits.clear()
		gs.inventory.clear()
		gs.money = 1500
		gs.last_scene = ""
		gs.spawn_tag = ""
		gs.world_flags["arrived_"+city] = true
		var language: String = "german" if city=="berlin" else "turkish"
		var words: Array = ["hallo","danke","bitte","brot","apfel","wasser","ja","nein","gut","tag"] if city=="berlin" else ["merhaba","sağol","çay","ekmek","su","evet","hayır","güzel","tamam","lütfen"]
		gs.familiarity[language] = {}
		for word: String in words:gs.familiarity[language][word]=80
		check(story.can_meet(city),city+" friendship becomes available with learned vocabulary")
		var id: String = "BerlinPrenzlberg" if city=="berlin" else "IstanbulHan"
		var key: String = "KeyKerstin" if city=="berlin" else "KeyArda"
		await load_room(id)
		check(scene.get_node(key).visible,city+" key character appears in their district")
		for round_i in range(2):
			await use_node(key)
			await answer_dialogue()
			check(story.rounds_done(city)==round_i+1,city+" conversation "+str(round_i+1)+" advances")
		await use_node(key)
		check(story.rounds_done(city)==2 and not story.is_friend(city),city+" requires the errand before friendship")
		await close_reading()
		var errand: Dictionary = story.errand_of(city)
		await load_room(String(errand["scene"]).get_basename())
		await use_node("LocalSpot")
		await finish_activity()
		check(story.errand_done(city),city+" activity completes the actual errand")
		await load_room(id)
		await use_node(key)
		await answer_dialogue()
		check(story.is_friend(city) and story.holiday_on(city),city+" friendship opens the invitation")
		await use_node(key)
		await finish_activity()
		check(story.holiday_seen(city) and not story.holiday_on(city),city+" holiday completes and releases control")
		check(not paused,city+" gameplay is unpaused after the holiday")
	print("FRIENDSHIPS: ",failures.size()," failures")
	if is_instance_valid(scene):scene.free()
	quit(0 if failures.is_empty() else 1)
