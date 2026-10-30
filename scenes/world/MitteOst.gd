extends Node2D

const SPAWNS := {
	"from_restaurant": Vector2(856, 380),
	"from_police":     Vector2(600, 380),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "mitte"
	else:
		GameState.visit_region("mitte")
	# The door we came through wins; SPAWNS is the fallback for loads and
	# dev-console jumps, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
