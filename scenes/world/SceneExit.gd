extends Area2D

@export var target_scene: String = ""
@export var spawn_tag:    String = ""
@export var prompt_text:  String = "E — Leave"

# What the sign over this door says. The street background reads this off the
# door itself and paints the fascia above it, so the sign and the building it
# leads to cannot disagree — they used to be positioned independently, and did.
@export var sign_text: String = ""
# Which trade the frontage should be dressed as: shop | food | pharmacy | civic
# | transit | lodging | medical | money. Drives what the ground floor looks
# like, so a chemist has a chemist's window and not a generic shopfront.
@export var frontage: String = "shop"

# A door that goes back wherever the player came in from, rather than to a
# scene named here. Hubs need it: one staircase out of a metro station has
# to lead to whichever of the four districts you came down from, and the
# arrival code needs to know which door to stand you at.
@export var is_return: bool = false

var player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.text = prompt_text


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		if Interactables.dialogue_in_range():
			return
		get_viewport().set_input_as_handled()
		_go()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false


func _go() -> void:
	if target_scene.is_empty():
		return
	GameState.spawn_tag = spawn_tag
	# Remember which scene we are leaving. The destination uses this to put the
	# player at the door they actually came through, instead of at whatever
	# fixed point the scene happens to declare. Hand-maintained spawn tables
	# drift the moment a door is added; this cannot.
	var cur := get_tree().current_scene
	GameState.last_scene = cur.scene_file_path if cur != null else ""
	var dest: String = target_scene
	if is_return and not GameState.entered_from.is_empty() \
		and ResourceLoader.exists(GameState.entered_from):
		dest = GameState.entered_from
	TransitionManager.go(dest)
