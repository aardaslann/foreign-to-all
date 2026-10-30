extends Node2D

# Shared root for every street built after Berlin.
#
# Berlin, London and Istanbul each grew their own root script, and all twelve
# of them say the same four things in the same order. This is that script, once,
# with the two facts that actually differ hoisted into exports: which district
# you are standing in, and where to put the player when there is no door to
# arrive through.
#
# The door you came through always wins. `spawn` is the fallback for a fresh
# load, a flight, or a jump from the dev console.

@export var region: String = ""
@export var spawn: Vector2 = Vector2(160, 430)

# Non-core cities can supply their own first-street thought. Core arrival
# thoughts are shared across districts, after the airport transfer, once only.
@export_multiline var arrival_thought: String = ""


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("street")
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = region
	else:
		GameState.visit_region(region)
	if not GameState.place_at_return_door(self, $Player):
		$Player.position = spawn
	# Remember it for the whole visit, so a door marked as the way back
	# knows where back is after last_scene has been cleared.
	if not GameState.last_scene.is_empty():
		GameState.entered_from = GameState.last_scene
	GameState.spawn_tag = ""
	GameState.last_scene = ""
	_first_arrival()


# The thought that lands the moment a new city resolves. Once per city, ever.
func _first_arrival() -> void:
	Services.first_street_arrival(arrival_thought)
