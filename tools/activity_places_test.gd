extends SceneTree

const PLACES := preload("res://scenes/world/ActivityPlaces.gd")
const STEP := 6
const GRAPH := preload("res://scenes/world/SceneGraph.gd")
var checks := 0
var failures := 0
var gs: Node
var captures := false
var world: Node2D
var completed_regions := {}
var out := "C:/Users/Arda/Documents/ForeignToAll/work/beta/places/runtime"

func _initialize() -> void: _run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ACTIVITY PLACES: " + message)

func load_world(path: String) -> void:
	if is_instance_valid(world):
		world.queue_free()
		await process_frame
	world = load(path).instantiate()
	root.add_child(world)
	current_scene = world
	for i in range(4): await physics_frame
	world.get_node("Player").set_physics_process(false)

func _run() -> void:
	gs = root.get_node("GameState")
	var saves := root.get_node("SaveManager")
	saves.use_test_storage("activity-places")
	captures = OS.get_cmdline_user_args().has("--capture")
	DirAccess.make_dir_recursive_absolute(out)
	var only := ""
	for arg in OS.get_cmdline_user_args():
		if PLACES.location(arg).size(): only = arg
	for id: String in PLACES.catalog()["places"]:
		if not only.is_empty() and only != id: continue
		var row := PLACES.location(id)
		gs.reset()
		gs.city = row.city
		gs.time_of_day = "morning"
		gs.last_scene = row.parent
		var wallet: Dictionary = gs.wallet.duplicate(true)
		await load_world(PLACES.scene_path(id))
		check(gs.city == row.city and gs.current_region == row.region, id + " retains district")
		check(not root.get_node("Journey").busy and not paused, id + " entry is free exploration")
		check(gs.wallet == wallet and not gs.world_flags.get("spot_" + String(row.region),false), id + " entry awards nothing")
		var player := world.get_node("Player") as CharacterBody2D
		var bg := world.get_node("Background")
		check(bg.design.has("objects") and bg.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, id + " authored pixel/depth mode")
		var local := world.get_node("LocalSpot")
		check(local.get("target_scene") == null and local.service == "local", id + " activity available inside")
		var at := player.position
		for node in world.get_children():
			if node == local or (node is Node2D and node.get("target_scene") != null):
				var route := route_to(player,node.position-Vector2(0,20),bg._standing_floor)
				check(not route.is_empty(), id + " reaches " + String(node.name))
				if route.is_empty(): continue
				for target: Vector2 in route:
					for substep in range(3):
						var delta := target-player.position
						if delta.length() < 0.1: break
						player.move_and_collide(delta.limit_length(3.0))
				check(player.position.distance_to(route.back()) < 0.2,id + " walks real collision path to " + String(node.name))
				await physics_frame
				await physics_frame
				check(node.player_nearby,id + " usable proximity " + String(node.name))
		player.position = at
		saves.save_game(0)
		saves.checkpoint()
		check(saves.load_game(0) and saves.pending_scene == PLACES.scene_path(id),id + " manual save keeps location")
		check(saves.load_game(-1) and saves.pending_scene == PLACES.scene_path(id),id + " checkpoint keeps location")
		await load_world(saves.pending_scene)
		player = world.get_node("Player")
		check(player.position.distance_to(at)<0.2,id + " reload restores exact safe standing position")
		check(not gs.skip_next_visit_count,id + " reload visit suppression consumed")
		check(GRAPH.reachable(PLACES.scene_path(id),row.parent) and GRAPH.reachable(row.parent,PLACES.scene_path(id)),id + " quest route works both ways")
		var map := world.get_node("UILayer/MapView")
		map._open()
		await process_frame
		check(map._title.text != "Somewhere",id + " map identifies location")
		map._close()
		local = world.get_node("LocalSpot")
		var key: String = row.city + ":" + row.region
		if not completed_regions.has(key):
			await complete_activity(local,id)
			completed_regions[key] = true
			check(gs.world_flags.get("spot_" + String(row.region),false),id + " existing activity grants district progress")
			check(not paused and not root.get_node("Journey").busy,id + " activity returns free movement")
		if captures:
			await create_timer(0.4).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out + "/" + id + ".png")
			var probes: Dictionary = {
				"ActivityParisTertre":[Vector2(605,453),Vector2(605,572)],
				"ActivityMumbaiMuseumHall":[Vector2(330,570)],
				"ActivityMexicoCoyoacanCoyotes":[Vector2(532,378),Vector2(664,380),Vector2(588,544)]}
			for p: Vector2 in probes.get(id,[]):
				var floor_nodes: Dictionary = world.get_node("Background")._standing_floor
				var route := route_to(player,p,floor_nodes)
				check(not route.is_empty(),id + " visual depth route " + str(p))
				if route.is_empty(): continue
				for target: Vector2 in route:
					for substep in range(3):
						player.move_and_collide((target-player.position).limit_length(3))
				for frame in range(3): await process_frame
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(out + "/" + id + "-depth-" + str(int(p.y)) + ".png")
			player.position=at
		print("PLACE ",id," complete")
	# Street entrances must themselves expose a return destination. Backgrounds
	# place them before their root calls GameState.place_at_return_door.
	if only.is_empty():
		for source: String in PLACES.catalog()["entries"]:
			var entry: Dictionary = PLACES.catalog()["entries"][source]["LocalSpot"]
			var row := PLACES.location(entry.place)
			gs.reset()
			gs.city = row.city
			gs.world_flags["arrived_" + String(row.city)] = true
			gs.quests["find_bed"] = {"completed":true,"steps":[]}
			gs.last_scene = PLACES.scene_path(entry.place)
			await load_world(source)
			var door := world.get_node("LocalSpot")
			check(door.get("target_scene") == PLACES.scene_path(entry.place),source + " door points to correct place")
			var player := world.get_node("Player") as CharacterBody2D
			check(player.position.distance_to(door.position) < 95,source + " returns at actual entrance")
			var bg: Node = null
			for n in world.get_children():
				if n.has_method("_scene_design"): bg=n
			if bg != null:
				check(not route_to(player,door.position-Vector2(0,20),bg._standing_floor).is_empty(),source + " street entrance reachable")
			# Exercise the real E input and fade transition, then the inverse door.
			await create_timer(0.5).timeout
			player.position = door.position-Vector2(0,20)
			for frame in range(3): await physics_frame
			check(door.player_nearby,source + " entrance responds to proximity")
			var event := InputEventAction.new()
			event.action="interact"
			event.pressed=true
			door._unhandled_input(event)
			await create_timer(0.8).timeout
			world=current_scene
			check(world.scene_file_path==PLACES.scene_path(entry.place),source + " E enters destination")
			if world.scene_file_path!=PLACES.scene_path(entry.place): continue
			player=world.get_node("Player")
			var back:=world.get_node("WayBack")
			player.position=back.position-Vector2(0,20)
			for frame in range(3): await physics_frame
			back._unhandled_input(event)
			await create_timer(0.8).timeout
			world=current_scene
			check(world.scene_file_path==source,source + " E returns to source")
	if is_instance_valid(world): world.queue_free()
	await process_frame
	print("ACTIVITY PLACES: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)

func complete_activity(local: Node, id: String) -> void:
	local._use()
	var cinema := get_first_node_in_group("cutscene")
	var choice := get_first_node_in_group("choice_panel")
	var visits := {}
	for frame in range(400):
		await process_frame
		if not local._busy: return
		if cinema._open:
			cinema._advance()
		elif choice._open:
			var text: String = choice._subtitle.text
			var index := 0
			if visits.has(text): index = choice._rows.get_child_count()-1
			visits[text]=true
			choice._close(str(index))
	check(false,id + " activity exceeded bounded choices")

func route_to(player: CharacterBody2D, destination: Vector2, clear: Dictionary) -> Array[Vector2]:
	var start := Vector2i.ZERO
	var distance := INF
	for cell: Vector2i in clear:
		var at := Vector2(cell*STEP)
		if at.distance_squared_to(player.position)<distance and not player.test_move(player.transform,at-player.position):
			start=cell
			distance=at.distance_squared_to(player.position)
	if distance>STEP*STEP*2: return []
	var queue: Array[Vector2i]=[start]
	var parents := {start:start}
	var end := start
	var index := 0
	var found := false
	while index<queue.size():
		var cell := queue[index]
		index+=1
		var at := Vector2(cell*STEP)
		if absf(at.x-destination.x)<28 and absf(at.y-destination.y)<24:
			end=cell
			found=true
			break
		for dir: Vector2i in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var next := cell+dir
			if parents.has(next) or not clear.has(next): continue
			if player.test_move(Transform2D(0,at),Vector2(dir*STEP)): continue
			parents[next]=cell
			queue.append(next)
	if not found: return []
	var route: Array[Vector2]=[Vector2(end*STEP)]
	while end != start:
		end=parents[end]
		route.push_front(Vector2(end*STEP))
	return route
