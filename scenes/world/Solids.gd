extends StaticBody2D

# Collision for the things a room is full of.
#
# The furniture in this game is drawn procedurally inside each *Background.gd,
# so hand-authoring matching CollisionPolygon2D nodes in every .tscn would mean
# two descriptions of the same object that drift apart the moment either moves.
# Instead a background declares `solids() -> Array` of world-space Rect2s next
# to the code that draws them, and this node turns them into bodies at runtime.
#
# Add one of these to a scene as a sibling of `Background` and it wires itself
# up. A background with no solids() simply contributes nothing.

@export var background_path: NodePath = ^"../Background"

# Legacy procedural backgrounds return drawing bounds. Their lower band is
# the footprint; authored collision_footprints() already returns ground depth
# and must be used in full (stairs and mattresses are deeper than a bollard).
const FOOT := 26.0


func _ready() -> void:
	var bg := get_node_or_null(background_path)
	if bg == null or not bg.has_method("solids"):
		return
	var authored: bool = bg.has_method("collision_footprints")
	var footprints: Array = bg.collision_footprints() if authored else bg.solids()
	for r in footprints:
		if not (r is Rect2):
			continue
		_add_box(r as Rect2, authored)


func _add_box(r: Rect2, authored: bool = false) -> void:
	# Only infer a bottom band for legacy drawing bounds.
	var h: float = r.size.y if authored else minf(r.size.y, FOOT)
	var y: float = r.end.y - h
	var shape := RectangleShape2D.new()
	shape.size = Vector2(r.size.x, h)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(r.position.x + r.size.x * 0.5, y + h * 0.5)
	add_child(col)
