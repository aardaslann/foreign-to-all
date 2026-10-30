class_name DroppedItem
extends Area2D

# A thing you have just been given, lying on the ground where it landed.
#
# Buying used to be silent: a number moved in a panel nobody had open. Now the
# object leaves the counter, lands on the pavement in front of you, and has to
# be walked over - which is one more second of the game being about a physical
# world rather than about an inventory.
#
# Walking over it is enough. There is no prompt and no key, because bending
# down to pick something up is not a decision.

const GLOW := preload("res://scenes/world/Glow.gd")

var item: String = ""

var _t: float = 0.0
var _taken: bool = false
var _hop: float = 0.0          # the little arc it makes on landing



func _ready() -> void:
	monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 26.0
	shape.shape = circle
	add_child(shape)
	# Its own light, the same one every interactable stands in.
	var g := Node2D.new()
	g.name = "Glow"
	g.set_script(GLOW)
	g.set("radius", 22.0)
	add_child(g)
	body_entered.connect(_on_body_entered)
	_hop = 1.0
	z_index = 1


func _process(delta: float) -> void:
	_t += delta
	_hop = maxf(0.0, _hop - delta * 2.4)
	queue_redraw()
	# Spawned under the player's feet, or walked onto during the same frame it
	# appeared: the area callback can miss that, so check outright as well.
	if _taken:
		return
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p != null and global_position.distance_to(p.global_position) < 30.0:
		_take()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_take()


func _take() -> void:
	if _taken or get_tree().paused:
		return
	var pk := get_tree().get_first_node_in_group("pickup")
	if pk != null and pk.showing:
		return
	_taken = true
	if pk != null:
		pk.play(item)
	else:
		# No pickup layer in this scene - never lose the object over it.
		GameState.add_item(item)
		Items.learn(item)
	queue_free()


func _draw() -> void:
	# A short arc as it lands, then a slow float, so it reads as an object
	# somebody put down rather than a sprite that was switched on.
	var lift: float = sin(_hop * PI) * 20.0 + sin(_t * 2.2) * 2.5
	var y: float = -10.0 - lift
	# Flattened shadow on the ground, shrinking as it rises.
	draw_set_transform(Vector2(0.0, 0.0), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2(0.0, 0.0), 13.0 - lift * 0.25, Color(0.0, 0.0, 0.0, 0.30))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# The object, from the one place that draws objects, so what is lying on
	# the pavement is the same thing the card holds up.
	Items.draw_item(self, Vector2(0.0, y), 0.85, item)
