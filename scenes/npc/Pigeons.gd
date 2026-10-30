extends Node2D

# A small flock pecking at crumbs near the café. Startle them and they take
# off into the sky — properly gone until the scene is revisited.

const STARTLE_DIST := 82.0

var _t: float = 0.0
var _flying: bool = false
var _pigeons: Array = []   # {"pos": Vector2, "phase": float, "vel": Vector2}
var _player: Node2D


func _ready() -> void:
	for i in range(3):
		_pigeons.append({
			"pos":   Vector2(float(i) * 34.0 - 34.0, float(i % 2) * 14.0),
			"phase": float(i) * 2.1,
			"vel":   Vector2.ZERO,
		})


func _process(delta: float) -> void:
	_t += delta

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	if not _flying and _player != null:
		var pl := to_local(_player.global_position)
		for p in _pigeons:
			if pl.distance_to(p["pos"]) < STARTLE_DIST:
				_take_flight(pl)
				break

	if _flying:
		var all_gone := true
		for i in range(_pigeons.size()):
			var p: Dictionary = _pigeons[i]
			var vel: Vector2 = p["vel"]
			vel.y -= 70.0 * delta          # climb harder as they get going
			p["vel"] = vel
			p["pos"] = (p["pos"] as Vector2) + vel * delta
			if (p["pos"] as Vector2).y > -500.0:
				all_gone = false
		if all_gone:
			queue_free()
			return

	queue_redraw()


func _take_flight(player_local: Vector2) -> void:
	_flying = true
	for i in range(_pigeons.size()):
		var p: Dictionary = _pigeons[i]
		var away := ((p["pos"] as Vector2) - player_local).normalized()
		# Mostly up, drifting away from the player, each bird a little different
		p["vel"] = Vector2(
			away.x * 55.0 + (float(i) - 1.0) * 30.0,
			-150.0 - float(i) * 25.0
		)


func _draw() -> void:
	for p in _pigeons:
		var pos: Vector2 = p["pos"]
		var phase: float = p["phase"]
		if _flying:
			if pos.y <= -500.0:
				continue
			# Flapping silhouette — body tucks, wings beat
			var flap := sin(_t * 20.0 + phase * 3.0) * 6.0
			draw_circle(pos, 3.6, Color(0.36, 0.37, 0.42))
			draw_circle(pos + Vector2(3.4, -1.2), 2.2, Color(0.28, 0.29, 0.35))
			draw_line(pos + Vector2(-1, 0), pos + Vector2(-8, -flap),
				Color(0.32, 0.33, 0.38), 2.0, true)
			draw_line(pos + Vector2(1, 0),  pos + Vector2(8, -flap),
				Color(0.32, 0.33, 0.38), 2.0, true)
		else:
			var peck := maxf(0.0, sin(_t * 3.0 + phase)) * 2.0
			draw_circle(pos + Vector2(0, 1.5), 5.5, Color(0, 0, 0, 0.18))
			draw_circle(pos + Vector2(0, -4), 5.0, Color(0.42, 0.43, 0.48))
			draw_circle(pos + Vector2(4.5, -6.0 + peck), 2.8, Color(0.30, 0.31, 0.38))
			draw_rect(Rect2(pos.x + 6.5, pos.y - 6.0 + peck, 2.5, 1.4),
				Color(0.85, 0.65, 0.30))
			draw_line(pos + Vector2(-4, -4), pos + Vector2(2, -7),
				Color(0.30, 0.31, 0.36), 1.5)
