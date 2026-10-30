extends Area2D

const COINS := 5
const ART := preload("res://scenes/world/ItemArt.gd")
var _taken := false


func _ready() -> void:
	if GameState.world_flags.get("kiez_pouch_taken", false):
		_taken = true
		queue_free()
		return
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_entered.connect(_on_body_entered)


func _physics_process(_delta: float) -> void:
	# Also covers spawning over the pouch or waiting for another word card.
	if _taken: return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_pick_up()
			break


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_pick_up()


func _pick_up() -> void:
	if _taken or get_tree().paused: return
	var pk := get_tree().get_first_node_in_group("pickup")
	if pk != null and pk.showing: return
	_taken = true
	GameState.world_flags["kiez_pouch_taken"] = true
	GameState.add_money(COINS)
	GameState.complete_quest_step("first_trade", 0)
	if pk != null:
		pk.play("money", false)
	else:
		Items.learn("money")
		var tb := get_tree().get_first_node_in_group("thought_box")
		if tb: tb.show_thought(Items.reading("money"))
	queue_free()


func _draw() -> void:
	draw_rect(Rect2(-15, 3, 29, 5), Color(0.08,0.09,0.09,0.23))
	ART.draw(self, Vector2(0,-5), 1.7, "money_pouch")
