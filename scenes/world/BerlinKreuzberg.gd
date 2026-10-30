extends Node2D

# Kreuzberg, off the U1. Two cities standing in the same place without either
# of them having agreed to it — MANAV and SPÄTI on the same wall, same plastic,
# same height, neither one translated for the other.
#
# A player who has already been to Istanbul reads the Turkish first and is
# wrong about which country they are in. That mistake is the whole reason the
# street exists, and it is the only joke in the game that only lands on a
# second playthrough.

const SPAWNS := {
	"from_ubahn":  Vector2(160, 430),
	"from_street": Vector2(140, 386),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "kreuzberg"
	else:
		GameState.visit_region("kreuzberg")
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
