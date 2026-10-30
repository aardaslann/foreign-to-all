extends Node2D


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("field")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "kiez"
	else:
		GameState.visit_region("kiez")
	# The door we came through wins; the old tag is the fallback.
	if not GameState.place_at_return_door(self, $Player):
		if GameState.spawn_tag == "from_mitte":
			$Player.position = Vector2(1040, 430)
	GameState.spawn_tag = ""
	GameState.last_scene = ""

	# First quest — the alien works out what the metal discs are for
	if not GameState.quests.has("first_trade"):
		GameState.start_quest("first_trade", "What do these do?", [
			"Take the dropped bag of metal discs from the grass",
			"Offer the discs to the vendor for the warm round food",
		])
	# Back-fill steps for saves made before the quest system existed
	if GameState.world_flags.get("kiez_pouch_taken", false):
		GameState.complete_quest_step("first_trade", 0)
	if GameState.world_flags.get("bread_bought", false):
		GameState.complete_quest_step("first_trade", 1)
	# Reconcile loaded quests once this scene is current, without adding a visit.
	Story.guide.call_deferred()
