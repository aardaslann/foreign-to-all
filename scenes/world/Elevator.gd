extends Area2D

# The moving room. Interact to open the floor picker.
@export var current_floor: int = 0   # 0 = lobby

var player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		var panel := get_tree().get_first_node_in_group("elevator_panel")
		if panel != null and panel.has_method("open_for"):
			panel.open_for(current_floor)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		$Prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		$Prompt.visible = false
