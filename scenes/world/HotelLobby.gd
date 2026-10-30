extends Node2D


func _ready() -> void:
	AudioManager.scene_music(self, true)
	AudioManager.set_ambience("interior")
	GameState.skip_next_visit_count = false
	GameState.hotel_floor = 0
	if GameState.spawn_tag == "from_elevator":
		$Player.position = Vector2(980, 400)
	else:
		$Player.position = Vector2(160, 430)
	GameState.spawn_tag = ""

	GameState.world_flags["hotel_entered"] = true
	GameState.complete_quest_step("find_bed", 0)
