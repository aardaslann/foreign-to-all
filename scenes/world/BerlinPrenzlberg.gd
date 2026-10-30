extends Node2D

# Prenzlauer Berg, off the U2. The first street in the game that somebody looks
# after — swept setts, planted tree pits, a child's mitten tied to the fence at
# the height a child looks.
#
# Nothing here is transacted. There is no counter, no clerk, no fee. That is
# the point of the stop: after four scenes of being processed, the alien walks
# down a street that simply carries on without needing anything from it, and
# discovers that being ignored by a place that works is a kind of rest.

const SPAWNS := {
	"from_ubahn":  Vector2(160, 430),
	"from_street": Vector2(140, 386),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "prenzlberg"
	else:
		GameState.visit_region("prenzlberg")
	# The door we came through wins; SPAWNS is the fallback for loads, for the
	# dev console, and for arriving by train, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
