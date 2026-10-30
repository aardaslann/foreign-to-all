extends Node2D

# Shared root for every building interior: sets the region for reputation,
# picks the ambience, and puts the player just inside the door.

@export var region: String = "mitte"
@export var spawn: Vector2 = Vector2(210, 430)


func _ready() -> void:
	AudioManager.scene_music(self, true)
	AudioManager.set_ambience("interior")
	var airport: bool = scene_file_path in GameState.ARRIVALS.values()
	var airport_platform: bool = Services.has_airport_transfer(scene_file_path)
	if airport:
		GameState.city = String(GameState.ARRIVALS.find_key(scene_file_path))
		if GameState.skip_next_visit_count:
			GameState.last_scene = ""
			GameState.entered_from = ""
			GameState.world_flags.erase("transit_from")
	if GameState.skip_next_visit_count or airport or airport_platform:
		GameState.skip_next_visit_count = false
		GameState.current_region = region
	else:
		GameState.visit_region(region)
	# Prefer the door we actually came through; fall back to the scene's own
	# spawn point when there is no matching door (a fresh load, or a jump from
	# the dev console).
	if not GameState.place_at_return_door(self, $Player):
		if airport and String(GameState.world_flags.get("airport_transfer", "")) == GameState.city:
			$Player.position = GameState._step_off_door($Exit.position)
		else:
			$Player.position = spawn
	# A transit hall serves every district in its city, so it cannot know
	# which one it belongs to from an export. Remember the street instead, so
	# the platform can decline to sell you a ride back to where you are.
	if not GameState.last_scene.is_empty():
		GameState.world_flags["transit_from"] = GameState.last_scene
	# Remember it for the whole visit, so a door marked as the way back
	# knows where back is after last_scene has been cleared.
	if not GameState.last_scene.is_empty():
		GameState.entered_from = GameState.last_scene
	GameState.spawn_tag = ""
	GameState.last_scene = ""
	if airport:
		Services.prepare_airport.call_deferred(self)
	elif airport_platform:
		# A loaded platform must still lead back to its terminal, not a stale city.
		GameState.entered_from = GameState.ARRIVALS[GameState.city]
		GameState.world_flags["transit_from"] = GameState.entered_from
		Services.refresh_arrival_guidance.call_deferred()
