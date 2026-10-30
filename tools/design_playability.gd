extends SceneTree

# Run with disposable APPDATA. Unlike design_reachability, this checks that
# each usable object has a reachable place where pressing E cannot also hit
# another object, then verifies the real physics proximity flag there.
# Every SceneExit is also loaded with its actual arrival state and checked
# for a clear arrival position and a reachable route back.
const STEP := 8
var failures: Array[String] = []
var warnings: Array[String] = []
var records: Array = []
var routes: Array = []
var scene: Node
var player: CharacterBody2D
var catalog: Dictionary
var cities: Array[String] = ["berlin", "istanbul"]
var scene_count := 0
var target_count := 0
var route_count := 0
var output := "user://design-playability.json"
var predecessors: Dictionary = {}
var walk_start := Vector2.ZERO
var walked_targets := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.ends_with(".json"):
			output = arg
		elif arg in ["berlin", "istanbul"]:
			cities = [arg]
		elif arg.begins_with("--city="):
			cities = [arg.trim_prefix("--city=")]
		elif arg == "--all":
			cities = []
	_run.call_deferred()

func _run() -> void:
	var renderer: Script = load("res://scenes/world/EnvironmentDesign.gd")
	catalog = renderer.catalog().duplicate(true)
	var ids: Array = catalog.keys()
	ids.sort()
	for id: String in ids:
		if not ResourceLoader.exists("res://scenes/world/"+id+".tscn"): continue
		if not cities.is_empty() and String(catalog[id].get("city", "")) not in cities:
			continue
		await _load_scene(id)
		# The first idle signal precedes queued transform notifications. A second
		# idle boundary is required before spatial queries observe scene placement.
		await process_frame
		await _measure(id)
	for route: Dictionary in routes:
		await _measure_route(route)
	if scene != null:
		scene.free()
	var report := {"scenes": scene_count, "targets": target_count,
		"walked_targets": walked_targets,
		"routes": route_count, "failures": failures, "warnings": warnings,
		"interaction_positions": records}
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(report, "  "))
	print("PLAYABILITY: %d scenes, %d targets, %d arrival routes, %d failures, %d warnings" %
		[scene_count, target_count, route_count, failures.size(), warnings.size()])
	for failure in failures:
		print("FAIL ", failure)
	for warning in warnings:
		print("WARN ", warning)
	print("REPORT ", output)
	print("WALKED ", walked_targets, " interactions from scene spawn using player collision sweeps")
	quit(0 if failures.is_empty() else 1)

func _load_scene(id: String, previous: String = "", tag: String = "") -> void:
	paused = false
	if scene != null:
		scene.free()
		await process_frame
	var gs = root.get_node("GameState")
	gs.city = String(catalog[id]["city"])
	gs.time_of_day = "morning"
	gs.world_flags.clear()
	gs.world_flags["arrived_" + gs.city] = true
	gs.world_flags["story_met_" + gs.city] = true
	gs.world_flags["intro_shown"] = true
	gs.world_flags["room_booked"] = true
	gs.inventory.clear()
	gs.quests.clear()
	gs.region_visits.clear()
	gs.active_job = ""
	gs.carrying = ""
	gs.job_progress = 0
	gs.money = 100
	gs.last_scene = previous
	gs.spawn_tag = tag
	gs.entered_from = previous
	scene = load("res://scenes/world/" + id + ".tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	player = scene.get_node("Player") as CharacterBody2D
	player.set_physics_process(false)
	# A required conversation walking toward each teleported test start makes
	# the previously measured route stale. Keep its real collider in place;
	# encounter approach/departure is exercised by the campaign checks.
	for actor in scene.get_children():
		if actor.get("encounter") != null:
			actor.set_physics_process(false)
	for i in range(5):
		await physics_frame
	# Deferred scene placement is flushed on an idle frame. Several headless
	# physics ticks can otherwise pass before the bodies reach their final map
	# positions, leaving the initial navigation query one transform behind.
	await process_frame
	await physics_frame
	# SceneTree's frame signals are emitted before transforms flush. Explicitly
	# wait for each physics body's server transform to match its authored node.
	for tick in range(8):
		var synchronized := true
		for body in scene.find_children("*","PhysicsBody2D",true,false):
			var physical: Transform2D = PhysicsServer2D.body_get_state(body.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM)
			if not physical.is_equal_approx(body.global_transform): synchronized=false
		if synchronized: break
		await process_frame
		await physics_frame
	paused = false

func _targets() -> Dictionary:
	var required: Dictionary = {}
	for node in scene.find_children("*", "Area2D", true, false):
		var area := node as Area2D
		var host: Node = area
		if area.name == &"InteractionArea":
			host = area.get_parent()
		if not (host is Node2D) or not host.is_visible_in_tree():
			continue
		if host.get("player_nearby") == null and host.get("_near") == null:
			continue
		required[area.get_instance_id()] = {"host": host, "area": area,
			"name": String(scene.get_path_to(host)), "positions": [], "overlaps": {},
			"reachable": 0}
	return required

func _flood(id: String, required: Dictionary) -> Dictionary:
	var col := player.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = col.shape
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	var space := player.get_world_2d().direct_space_state
	var start := Vector2i(roundi(player.position.x / STEP), roundi(player.position.y / STEP))
	walk_start = player.position
	# A valid arrival can sit beside furniture while the rounded grid cell
	# sits inside it. Join the nearest clear cell by a real collision sweep.
	var nearest := INF
	var origin := start
	for dy in range(-1,2):
		for dx in range(-1,2):
			var cell := origin+Vector2i(dx,dy)
			var at := Vector2(cell*STEP)
			var distance := at.distance_squared_to(walk_start)
			if distance>=nearest or not _position_clear(at): continue
			if player.test_move(player.transform,at-walk_start): continue
			nearest=distance
			start=cell
	predecessors = {start: start}
	var frontier: Array[Vector2i] = [start]
	var visited := {start: true}
	var reached: Dictionary = {}
	var head := 0
	while head < frontier.size():
		var cell := frontier[head]
		head += 1
		var at := Vector2(cell * STEP)
		if at.x < 12 or at.x > 1140 or at.y < float(catalog[id]["floor"])-32 or at.y > 628:
			continue
		query.transform = Transform2D(0.0, at + col.position)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		if not space.intersect_shape(query, 1).is_empty():
			continue
		reached[cell] = true
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var touching: Array = []
		for hit: Dictionary in space.intersect_shape(query, 64):
			if required.has(hit["collider_id"]):
				touching.append(hit["collider_id"])
		for target in touching:
			var row: Dictionary = required[target]
			row["reachable"] += 1
			var competitors: Array = []
			for other in touching:
				if other == target or not _can_compete(row["host"], required[other]["host"]):
					continue
				competitors.append(required[other]["name"])
			if competitors.is_empty():
				row["positions"].append(at)
			else:
				for competitor in competitors:
					row["overlaps"][competitor] = true
		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next := cell + direction
			if not visited.has(next):
				# Clear endpoints alone can straddle a thin fence. Plan only
				# edges that the complete player body can continuously cross.
				if player.test_move(Transform2D(0.0,at),Vector2(direction*STEP)):
					continue
				visited[next] = true
				predecessors[next] = cell
				frontier.append(next)
	return reached

func _walk_route(at: Vector2, reached: Dictionary) -> bool:
	var end := Vector2i(roundi(at.x/STEP),roundi(at.y/STEP))
	if not reached.has(end):
		var distance := INF
		for cell: Vector2i in reached:
			var d := Vector2(cell*STEP).distance_squared_to(at)
			if d < distance:
				distance = d
				end = cell
	var route: Array[Vector2] = [at,Vector2(end*STEP)]
	while predecessors[end] != end:
		end = predecessors[end]
		route.append(Vector2(end*STEP))
	route.reverse()
	player.position = walk_start
	await physics_frame
	for point: Vector2 in route:
		# Use the real player's continuous collision sweep along every edge.
		# Only initial scene setup may teleport; the approach cannot do so.
		var hit := player.move_and_collide(point-player.position)
		if hit != null or player.position.distance_to(point)>0.2:
			print("WALK_BLOCKED target=",at," waypoint=",point," actual=",player.position,
				" collider=",hit.get_collider().get_path() if hit!=null else "none")
			return false
	return true

func _can_compete(target: Node, other: Node) -> bool:
	# A job end only handles input while its particular load is active.
	if other.get("job") != null:
		return target.get("job") == other.get("job") and target.get("role") == other.get("role")
	# Taken pickups are absent, and an encounter with no current dialogue
	# deliberately passes E onward.
	var rounds: Variant = other.get("_rounds")
	if rounds is Array and rounds.is_empty():
		return false
	return true

func _position_clear(at: Vector2) -> bool:
	var col := player.get_node("CollisionShape2D") as CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = col.shape
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	query.transform = Transform2D(0.0, at + col.position)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return player.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func _measure(id: String) -> void:
	scene_count += 1
	if not _position_clear(player.position):
		failures.append("%s default player spawn is inside collision at %s" % [id, player.position])
	var required := _targets()
	var reachable := _flood(id, required)
	if reachable.is_empty():
		failures.append("%s cannot walk out of its default spawn at %s" % [id, player.position])
	for row: Dictionary in required.values():
		target_count += 1
		var host: Node = row["host"]
		var name: String = id + "/" + row["name"]
		var candidates: Array = row["positions"]
		var record := {"scene": id, "node": row["name"], "anchor": [host.position.x, host.position.y],
			"reachable_cells": row["reachable"], "exclusive_cells": candidates.size(),
			"overlaps": row["overlaps"].keys()}
		if host.get("target_scene") != null:
			# The player must be able to put their feet ON the visible exit
			# marker, not merely overlap the remote edge of a large trigger.
			var marker: Vector2 = host.global_position
			var glow := host.get_node_or_null("Glow") as Node2D
			if glow != null: marker = glow.global_position - Vector2(0,glow.get("lift"))
			var standing := marker - Vector2(0,20)
			var closest := INF
			var closest_at := Vector2.ZERO
			for cell: Vector2i in reachable:
				var distance := Vector2(cell*STEP).distance_to(standing)
				if distance < closest:
					closest = distance
					closest_at = Vector2(cell*STEP)
			record["marker_distance"] = closest
			record["nearest_marker_floor"] = [closest_at.x,closest_at.y+20]
			record["marker_clear"] = _position_clear(standing)
			if not _position_clear(standing) or closest > STEP:
				failures.append("%s visible exit marker is blocked/unreachable at %s (nearest %.1f)" % [name,marker,closest])
		if int(row["reachable"]) == 0:
			failures.append("%s interaction area is unreachable (anchor %s)" % [name, host.position])
		elif candidates.is_empty():
			failures.append("%s has no reachable interaction position free of %s (anchor %s)" %
				[name, str(row["overlaps"].keys()), host.position])
		else:
			# Prefer the centre of the interaction area, then verify the actual
			# body_entered signal rather than trusting the shape query alone.
			var area: Area2D = row["area"]
			candidates.sort_custom(func(a: Vector2, b: Vector2):
				return a.distance_squared_to(area.global_position) < b.distance_squared_to(area.global_position))
			var at: Vector2 = candidates[0]
			if host.get("target_scene") != null:
				var glow := host.get_node_or_null("Glow") as Node2D
				at = host.global_position - Vector2(0,20)
				if glow != null: at = glow.global_position - Vector2(0,20+glow.get("lift"))
			if await _walk_route(at,reachable):
				walked_targets += 1
			else:
				failures.append("%s collision sweep cannot walk from spawn to %s" % [name,at])
			for i in range(3):
				await physics_frame
			var nearby: Variant = host.get("player_nearby")
			if nearby == null:
				nearby = host.get("_near")
			if nearby != true:
				failures.append("%s real proximity flag does not activate at reachable %s" % [name, at])
			record["usable_position"] = [at.x, at.y]
		records.append(record)
		if host.get("target_scene") != null:
			var path: String = String(host.get("target_scene"))
			if not ResourceLoader.exists(path):
				failures.append(name + " has missing destination " + path)
			elif catalog.has(path.get_file().get_basename()):
				routes.append({"source": id, "node": row["name"], "destination": path.get_file().get_basename(),
					"tag": String(host.get("spawn_tag")), "return": bool(host.get("is_return"))})
	print("CHECK %s: %d targets; %d reachable floor cells" % [id, required.size(), reachable.size()])

func _measure_route(route: Dictionary) -> void:
	var source: String = route["source"]
	var destination: String = route["destination"]
	# Dynamic hub returns are covered by the corresponding incoming street
	# route, where entered_from has the actual value the game records.
	if bool(route["return"]):
		return
	route_count += 1
	var previous := "res://scenes/world/" + source + ".tscn"
	await _load_scene(destination, previous, route["tag"])
	var label := "%s/%s -> %s" % [source, route["node"], destination]
	if not _position_clear(player.position):
		failures.append(label + " arrives inside collision at " + str(player.position))
		var debug_shape := player.get_node("CollisionShape2D") as CollisionShape2D
		var debug_query := PhysicsShapeQueryParameters2D.new()
		debug_query.shape=debug_shape.shape
		debug_query.transform=Transform2D(0.0,player.position+debug_shape.position)
		debug_query.exclude=[player.get_rid()]
		for hit in player.get_world_2d().direct_space_state.intersect_shape(debug_query): print("ARRIVAL_HIT ",label," ",hit["collider"].name)
	var required := _targets()
	var reachable := _flood(destination, required)
	if reachable.is_empty():
		failures.append(label + " arrives in an isolated/blocked grid cell at " + str(player.position))
	var return_found := false
	for row: Dictionary in required.values():
		var host: Node = row["host"]
		if host.get("target_scene") == null:
			continue
		if String(host.get("target_scene")) != previous and host.get("is_return") != true:
			continue
		return_found = true
		if int(row["reachable"]) == 0:
			failures.append(label + " cannot reach its return door " + row["name"])
		if host.get("is_return") == true and root.get_node("GameState").entered_from != previous:
			failures.append(label + " lost entered_from; return would lead to the wrong street")
	if not return_found:
		warnings.append(label + " has no reciprocal SceneExit (check its dedicated elevator/room/transit flow)")
	print("ROUTE ", label, " at ", player.position)
