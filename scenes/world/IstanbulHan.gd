extends Node2D

# Through the gate. After the lane — stepped, netted, loud — a rectangle of
# open sky and running water, and the noise stops.
#
# This is the only place in the city that is quiet, and it is where the last
# fragment hangs on a cord above a doorway between two blue glass eyes. It is
# not for sale, and the whole act is the alien finding that out slowly.

const SPAWNS := {
	"from_carsi": Vector2(560, 430),
	"from_yusuf": Vector2(846, 430),
}


func _ready() -> void:
	AudioManager.scene_music(self)
	AudioManager.set_ambience("interior")   # the courtyard is outside and sounds indoors
	if GameState.skip_next_visit_count:
		GameState.skip_next_visit_count = false
		GameState.current_region = "han"
	else:
		GameState.visit_region("han")
	# The door we came through wins; SPAWNS is the fallback for loads and
	# dev-console jumps, where there is no door to match.
	if not GameState.place_at_return_door(self, $Player):
		if SPAWNS.has(GameState.spawn_tag):
			$Player.position = SPAWNS[GameState.spawn_tag]
	GameState.spawn_tag = ""
	GameState.last_scene = ""
	_first_arrival()


func _first_arrival() -> void:
	if GameState.world_flags.get("han_seen", false):
		return
	GameState.world_flags["han_seen"] = true
	var tb := get_tree().get_first_node_in_group("thought_box")
	if tb == null:
		return
	tb.show_thought("Sky. A square of it, straight up, with a tree under it.\n\n" +
		"The city has a hole in it and the hole is the quietest place I have found.")
