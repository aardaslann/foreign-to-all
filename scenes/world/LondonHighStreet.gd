extends Node2D

# The high street. Same terrace as one street over, with its ground floor
# replaced by shopfronts — which is exactly how London high streets happen.
#
# This is where the accents live. The terrace is residential and quiet; here
# people talk to each other at speed, and the alien gets to find out that
# understanding English is not the same as understanding anybody.

const SPAWNS := {
	"from_terrace":    Vector2(110, 440),
	"from_caff":       Vector2(392, 380),
	"from_exchange":   Vector2(628, 380),
	"from_police":     Vector2(864, 380),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "highstreet"
	else:
		GameState.visit_region("highstreet")
	# The door we came through wins; SPAWNS is the fallback for loads and
	# dev-console jumps, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
