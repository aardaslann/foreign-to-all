extends SceneTree

const SS = preload("res://scenes/world/Streetside.gd")
const PREVIEW = preload("res://tools/PreparedCityPreview.gd")
var failures: Array[String] = []
var checked_beats: int = 0
var checked_anchors: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool,message: String) -> void:
	if not ok:
		failures.append(message)
		printerr(message)

func without_visuals(source: Dictionary) -> Dictionary:
	var data: Dictionary=source.duplicate(true)
	data.erase("film")
	data.erase("staging")
	for row: Dictionary in data.get("rows",[]): row.erase("staging")
	return data

func _run() -> void:
	var staging: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/prepared-activity-staging.json"))
	PREVIEW.install()
	for key: String in staging:
		var original: Dictionary={}
		for table: Dictionary in [SS.AMERICA.SPOTS,SS.PACIFIC.SPOTS,SS.SOUTH.SPOTS,SS.SOUTHTWO.SPOTS]:
			if table.has(key): original=table[key]
		check(not original.is_empty(),key+": story not found")
		if original.is_empty(): continue
		check(staging[key].size()==original["beats"].size(),key+": missing branch staging")
		var changed: Dictionary=SS.spot(key.get_slice(":",0),key.get_slice(":",1))
		for id: String in original["beats"]:
			checked_beats+=1
			check(staging[key].has(id),key+":"+id+": no prepared staging")
			check(without_visuals(original["beats"][id])==without_visuals(changed["beats"][id]),key+":"+id+": changed story/rewards/choices")
			var old_film: Array=original["beats"][id].get("film",[])
			var new_film: Array=changed["beats"][id].get("film",[])
			check(old_film.size()==new_film.size(),key+":"+id+": film removed")
			for i in range(mini(old_film.size(),new_film.size())):
				check(old_film[i].get("say")==new_film[i].get("say"),key+":"+id+": narration changed")
				check(old_film[i].get("secs")==new_film[i].get("secs"),key+":"+id+": pacing changed")
	var worlds: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/environments/prepared-worlds.json"))
	for key: String in worlds:
		var data: Dictionary=worlds[key]
		root.get_node("GameState").city=data["city"]
		root.get_node("GameState").world_flags["arrived_"+String(data["city"])]=true
		var scene: Node=load("res://scenes/world/"+key+".tscn").instantiate()
		var ui: Node=scene.get_node_or_null("UILayer")
		if ui!=null:
			scene.remove_child(ui)
			ui.free()
		root.add_child(scene)
		await process_frame
		await physics_frame
		for name: String in data["anchors"]:
			checked_anchors+=1
			var node: Node2D=scene.get_node_or_null(NodePath(name))
			check(node!=null,key+":"+name+": missing gameplay node")
			if node==null: continue
			var xy: Array=data["anchors"][name]
			check(node.position.distance_to(Vector2(xy[0],xy[1]))<1.0,key+":"+name+": anchor not applied")
			if node.get("target_scene")!=null:
				check(ResourceLoader.exists(node.get("target_scene")),key+":"+name+": destination missing")
		scene.free()
		await process_frame
	print("PREPARATION_VALIDATION ",worlds.size()," scenes, ",checked_anchors," anchors, ",staging.size()," activities, ",checked_beats," beats, ",failures.size()," failures")
	quit(0 if failures.is_empty() else 1)
