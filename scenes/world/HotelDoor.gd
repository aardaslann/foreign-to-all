extends Area2D

# A numbered hotel door. The right one (with the card) opens into the room;
# any other gets a muffled, unmistakably hostile reaction from inside.

@export var door_index: int = 1   # 1-4 along the corridor

var player_nearby := false
var _knocked := false   # exposure only for the first angry earful per door

const _ANGRY_WORDS: Array = [
	{"text": "Was?!",  "word": "was"},
	{"text": "Gehen",  "word": "gehen"},
	{"text": "Sie",    "word": "sie"},
	{"text": "weg!",   "word": "weg"},
]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.text = "[E]  %s" % _room_number()


func _room_number() -> String:
	return "%d0%d" % [GameState.hotel_floor, door_index]


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		_try_door()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _try_door() -> void:
	if _room_number() == GameState.HOTEL_ROOM:
		if GameState.world_flags.get("room_booked", false):
			GameState.spawn_tag = "from_corridor"
			TransitionManager.go("res://scenes/world/HotelRoom.tscn")
		else:
			var tb := get_tree().get_first_node_in_group("thought_box")
			if tb:
				tb.show_thought("Locked. Everything here is locked.\n\n" +
					"Maybe the person at the desk downstairs is the key to the keys.")
		return

	# Wrong door — the occupant disagrees, loudly. No conversation to have.
	var ab := get_tree().get_first_node_in_group("angry_box")
	if ab == null:
		return
	if not _knocked:
		for w in _ANGRY_WORDS:
			GameState.expose("german", w["word"], "hear")
		# Waking residents before six — word gets around
		GameState.change_reputation("mitte", -1)
	_knocked = true
	ab.show_angry(_ANGRY_WORDS, "behind door %s  ·  do not disturb" % _room_number())
