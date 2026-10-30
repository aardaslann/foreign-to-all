extends Node2D


func _ready() -> void:
	AudioManager.scene_music(self, true)
	AudioManager.set_ambience("interior")
	GameState.skip_next_visit_count = false
	$Player.position = Vector2(150, 430)
	GameState.spawn_tag = ""
	GameState.complete_quest_step("find_bed", 2)
