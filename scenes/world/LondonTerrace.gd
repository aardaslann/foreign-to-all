extends Node2D

# A residential street reached from the Underground, after the airport.
#
# Berlin's first street was bewildering — you couldn't read a word of it. This
# one is worse in a way that takes a while to notice: you CAN read it. Every
# sign is legible and none of it tells you anything you need.

const SPAWNS := {
	"from_highstreet": Vector2(1040, 440),
	"from_airport":    Vector2(576, 430),
	"from_hotel":      Vector2(212, 380),
	"from_underground": Vector2(560, 386),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "terrace"
	else:
		GameState.visit_region("terrace")
	# The door we came through wins; SPAWNS is the fallback for loads and
	# dev-console jumps, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
	_first_arrival()


# The thought that lands the moment the city resolves. Once only — after that
# the street is just a street, which is its own kind of sad.
func _first_arrival() -> void:
	Services.first_street_arrival()
