extends SceneTree

# Checks actual physics shapes, not just JSON coordinates. A flood fill from
# the live player spawn must reach every exit and service's interaction area.
var _jobs: Array = []
var _scene: Node
var _frames: int = 0
var _count: int = 0
var _targets: int = 0
var _failures: Array = []
var _catalog: Dictionary = {}
const STEP := 12

func _initialize() -> void:
	_catalog = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/layouts.json"))
	var overrides: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/fullsize.json"))
	for id in overrides:
		_catalog[id].merge(overrides[id], true)
	_jobs = _catalog.keys()
	_next.call_deferred()

func _next() -> void:
	if _scene != null:
		_scene.free()
	if _jobs.is_empty():
		print("REACHABILITY: ", _count, " scenes, ", _targets, " interaction areas, ", _failures.size(), " failures")
		for failure in _failures:
			print(failure)
		quit(0 if _failures.is_empty() else 1)
		return
	var id: String = String(_jobs.pop_front())
	var gs = root.get_node("GameState")
	gs.city = String(_catalog[id]["city"])
	gs.world_flags["arrived_" + gs.city] = true
	gs.world_flags["story_met_" + gs.city] = true
	gs.last_scene = ""
	gs.spawn_tag = ""
	_scene = load("res://scenes/world/" + id + ".tscn").instantiate()
	root.add_child(_scene)
	current_scene = _scene
	_scene.set_meta("design_test_id", id)
	_frames = 8

func _process(_delta: float) -> bool:
	if _frames > 0:
		_frames -= 1
		if _frames == 0:
			_measure()
			_next.call_deferred()
	return false

func _measure() -> void:
	_count += 1
	var id: String = String(_scene.get_meta("design_test_id"))
	var player := _scene.get_node_or_null("Player") as CharacterBody2D
	if player == null:
		_failures.append(id + " missing player")
		return
	var col := player.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = col.shape
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	var space := player.get_world_2d().direct_space_state
	var required: Dictionary = {}
	for node in _scene.get_children():
		if node is Area2D and (node.get("service") != null or node.get("target_scene") != null or node.has_method("_stroke")):
			required[node.get_instance_id()] = String(node.name)
		elif node is StaticBody2D and node.get_node_or_null("InteractionArea") is Area2D:
			required[node.get_node("InteractionArea").get_instance_id()] = String(node.name)
	_targets += required.size()
	var reached: Dictionary = {}
	var visited: Dictionary = {}
	var start := Vector2i(roundi(player.position.x / STEP), roundi(player.position.y / STEP))
	var frontier: Array[Vector2i] = [start]
	visited[start] = true
	var head: int = 0
	while head < frontier.size():
		var cell: Vector2i = frontier[head]
		head += 1
		var at := Vector2(cell * STEP)
		if at.x < 12 or at.x > 1140 or at.y < float(_catalog[id]["floor"]) or at.y > 628:
			continue
		query.transform = Transform2D(0.0, at + col.position)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		if not space.intersect_shape(query, 1).is_empty():
			continue
		query.collide_with_areas = true
		query.collide_with_bodies = false
		for hit: Dictionary in space.intersect_shape(query, 32):
			reached[hit["collider_id"]] = true
		for step: Vector2i in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell + step
			if not visited.has(next):
				visited[next] = true
				frontier.append(next)
	for target in required:
		if not reached.has(target):
			_failures.append(id + " unreachable " + String(required[target]))
	print("REACH ", id, " ", required.size(), " targets; ", head, " cells")
