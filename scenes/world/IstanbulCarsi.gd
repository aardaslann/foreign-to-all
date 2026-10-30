extends Node2D

# A market lane reached from the metro. The first impression must not assume
# a previous city order, or a conversation the player has not had yet.

const SPAWNS := {
	"from_han":      Vector2(576, 396),
	"from_airport":  Vector2(160, 430),
	"from_otel":     Vector2(212, 380),
	"from_metro":    Vector2(880, 386),
	"from_lokanta":  Vector2(392, 380),
	"from_doviz":    Vector2(700, 380),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "carsi"
	else:
		GameState.visit_region("carsi")
	# The door we came through wins; SPAWNS is the fallback for loads and
	# dev-console jumps, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
	_first_arrival()


func _first_arrival() -> void:
	Services.first_street_arrival()
