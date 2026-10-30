extends Node2D

# Draws what the collision map actually is, over the art it is supposed to
# match. Used only by tools/collide.gd.

var root_node: Node = null


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if root_node == null:
		return
	_walk(root_node)


# A shape under an Area2D is a trigger, not a wall. Drawing both in red is
# what made a doorway's prompt zone look like an invisible barrier.
static func _is_trigger(n: Node) -> bool:
	var p: Node = n
	while p != null:
		if p is Area2D:
			return true
		if p is PhysicsBody2D:
			return false
		p = p.get_parent()
	return false


func _walk(n: Node) -> void:
	var col: Color = (Color(0.30, 0.62, 1.0, 0.85) if _is_trigger(n)
		else Color(1.0, 0.10, 0.85, 0.90))
	var fill: Color = Color(col.r, col.g, col.b, 0.13)
	if n is CollisionShape2D and n.shape != null:
		var cs: CollisionShape2D = n
		if cs.shape is RectangleShape2D:
			var s: Vector2 = (cs.shape as RectangleShape2D).size
			_box(Rect2(cs.global_position - s * 0.5, s), col, fill)
		elif cs.shape is CircleShape2D:
			draw_arc(cs.global_position, (cs.shape as CircleShape2D).radius,
				0.0, TAU, 24, col, 2.0)
	elif n is CollisionPolygon2D:
		var poly: PackedVector2Array = (n as CollisionPolygon2D).polygon
		if poly.size() >= 3:
			var pts: PackedVector2Array = PackedVector2Array()
			for p in poly:
				pts.append((n as Node2D).to_global(p))
			pts.append(pts[0])
			draw_polyline(pts, col, 2.0)
			draw_colored_polygon(pts, fill,
				PackedVector2Array(), null)
	# Anybody who draws themselves as a person: mark the ground they claim.
	if n is Node2D and (n.has_method("_look") or n.get("npc_id") != null):
		var g: Vector2 = (n as Node2D).global_position
		draw_line(g - Vector2(16, 0), g + Vector2(16, 0),
			Color(0.20, 1.0, 0.40, 0.9), 2.0)
		draw_line(g, g - Vector2(0, 10), Color(0.20, 1.0, 0.40, 0.6), 1.0)
	for c in n.get_children():
		_walk(c)


func _box(r: Rect2, line: Color, fill: Color) -> void:
	draw_rect(r, fill, true)
	draw_rect(r, line, false, 2.0)
