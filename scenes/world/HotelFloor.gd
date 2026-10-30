extends Node2D


func _ready() -> void:
	AudioManager.scene_music(self, true)
	AudioManager.set_ambience("interior")
	GameState.skip_next_visit_count = false
	if GameState.hotel_floor < 1:
		GameState.hotel_floor = 1
	$Elevator.current_floor = GameState.hotel_floor
	if GameState.spawn_tag == "from_room":
		var booked_door := get_node_or_null("Door" + GameState.HOTEL_ROOM.right(1)) as Node2D
		$Player.position = booked_door.position + Vector2(0, 30) if booked_door != null else Vector2(864, 451)
	else:
		$Player.position = $Elevator.position + Vector2(60, 30)
	GameState.spawn_tag = ""
