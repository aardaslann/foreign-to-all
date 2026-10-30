extends Node2D

# Where the player appears depends on which door they came through.
const SPAWNS := {
	"from_mitte_ost": Vector2(1040, 440),
	"from_hotel":     Vector2(150, 350),
	"from_exchange":  Vector2(1004, 380),
	"from_ubahn":     Vector2(496, 386),
	"from_ubahn_stairs": Vector2(496, 386),
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
