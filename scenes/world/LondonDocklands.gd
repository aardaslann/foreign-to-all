extends Node2D

# Canary Wharf, off the DLR. The terrace was illegible and human; this is the
# inverse, and the inversion is done entirely by subtraction — no chimneys, no
# basement areas, no brick, no red. One granite plane laid to a tolerance.
#
# Every legible sign out here is a boundary: a pass reader wired to nothing you
# can see, a line of bollards marking somebody's land, a lit map of the place
# you are already standing in. The alien can read all of it and none of it is
# addressed to the alien, which is London's whole argument in one plaza.

const SPAWNS := {
	"from_ubahn":  Vector2(220, 430),
	"from_street": Vector2(200, 386),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "docklands"
	else:
		GameState.visit_region("docklands")
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
