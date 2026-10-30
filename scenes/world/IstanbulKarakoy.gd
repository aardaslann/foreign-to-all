extends Node2D

# Karaköy, off the T1. The çarşı and the han are both dry and inland, which is
# a lie about a city that is sea level nearly everywhere and gets to work by
# boat. This is where the act admits it: the Bosphorus across the top, ferries
# actually crossing it, and a quay you can stand on with the water at your feet.
#
# After four plates under a netted sky, the absence of anything overhead should
# read as a change in pressure rather than as scenery.

const SPAWNS := {
	"from_ubahn":  Vector2(920, 430),
	"from_street": Vector2(944, 386),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "karakoy"
	else:
		GameState.visit_region("karakoy")
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
